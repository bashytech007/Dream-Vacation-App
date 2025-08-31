name: Deploy Dream Vacation App
on:
  push:
    branches: [ main ]

env:
  FRONTEND_IMAGE: bashtech007/dream-vacation-frontend
  BACKEND_IMAGE: bashtech007/dream-vacation-backend

jobs:
  build-frontend:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Log in to Docker Hub
      uses: docker/login-action@v2
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}
    
    - name: Build and push Frontend
      uses: docker/build-push-action@v4
      with:
        context: ./frontend
        push: true
        tags: ${{ env.FRONTEND_IMAGE }}:latest

  build-backend:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Log in to Docker Hub
      uses: docker/login-action@v2
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}
    
    - name: Build and push Backend
      uses: docker/build-push-action@v4
      with:
        context: ./backend
        push: true
        tags: ${{ env.BACKEND_IMAGE }}:latest

  terraform:
    needs: [build-frontend, build-backend]
    runs-on: ubuntu-latest
    outputs:
      instance_ip: ${{ steps.terraform-output.outputs.instance_ip }}
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2
      with:
        terraform_wrapper: false
    
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-1
    
    - name: Create SSH key file
      run: |
        mkdir -p ~/.ssh
        echo "${{ secrets.EC2_SSH_PUBLIC_KEY }}" > ~/.ssh/terraform_key.pub
        chmod 644 ~/.ssh/terraform_key.pub
        # Verify the key format
        ssh-keygen -l -f ~/.ssh/terraform_key.pub || (echo "Invalid public key format" && exit 1)
    
    - name: Terraform Init
      working-directory: ./terraform-infrastructure
      run: terraform init
    
    - name: Import existing resources
      working-directory: ./terraform-infrastructure
      run: |
        # Get VPC ID and other resource IDs from terraform state or AWS
        VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=dream-vpc" --query 'Vpcs[0].VpcId' --output text)
        SUBNET_ID=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=dream-subnet" --query 'Subnets[0].SubnetId' --output text)
        IGW_ID=$(aws ec2 describe-internet-gateways --filters "Name=tag:Name,Values=dream-igw" --query 'InternetGateways[0].InternetGatewayId' --output text)
        RT_ID=$(aws ec2 describe-route-tables --filters "Name=tag:Name,Values=dream-rt" --query 'RouteTables[0].RouteTableId' --output text)
        SG_ID=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=dream-security-group" --query 'SecurityGroups[0].GroupId' --output text)
        INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=dream-instance" "Name=instance-state-name,Values=running,stopped" --query 'Reservations[0].Instances[0].InstanceId' --output text)
        
        # Import resources if they exist
        if [ "$VPC_ID" != "None" ] && [ "$VPC_ID" != "" ]; then
          terraform import aws_vpc.dream_vpc $VPC_ID || true
        fi
        if [ "$SUBNET_ID" != "None" ] && [ "$SUBNET_ID" != "" ]; then
          terraform import aws_subnet.dream_subnet $SUBNET_ID || true
        fi
        if [ "$IGW_ID" != "None" ] && [ "$IGW_ID" != "" ]; then
          terraform import aws_internet_gateway.dream_igw $IGW_ID || true
        fi
        if [ "$RT_ID" != "None" ] && [ "$RT_ID" != "" ]; then
          terraform import aws_route_table.dream_rt $RT_ID || true
        fi
        if [ "$SG_ID" != "None" ] && [ "$SG_ID" != "" ]; then
          terraform import aws_security_group.dream_sg $SG_ID || true
        fi
        if [ "$INSTANCE_ID" != "None" ] && [ "$INSTANCE_ID" != "" ]; then
          terraform import aws_instance.dream_instance $INSTANCE_ID || true
        fi
        
        terraform import aws_key_pair.dream_key dream-key || true
        terraform import aws_iam_role.ec2_cloudwatch_role ec2-cloudwatch-role || true
        terraform import aws_iam_role_policy.ec2_cloudwatch_policy ec2-cloudwatch-role:ec2-cloudwatch-policy || true
        terraform import aws_iam_instance_profile.ec2_profile ec2-cloudwatch-profile || true
    
    - name: Terraform Plan
      working-directory: ./terraform-infrastructure
      run: terraform plan -var="public_key_content=${{ secrets.EC2_SSH_PUBLIC_KEY }}"
    
    - name: Terraform Apply
      working-directory: ./terraform-infrastructure
      run: terraform apply -auto-approve -var="public_key_content=${{ secrets.EC2_SSH_PUBLIC_KEY }}"
    
    - name: Get Terraform Outputs
      id: terraform-output
      working-directory: ./terraform-infrastructure
      run: |
        INSTANCE_IP=$(terraform output -raw instance_public_ip || echo "")
        echo "instance_ip=$INSTANCE_IP" >> $GITHUB_OUTPUT
        echo "Instance IP: $INSTANCE_IP"

  deploy:
    needs: terraform
    runs-on: ubuntu-latest
    if: needs.terraform.outputs.instance_ip != ''
    steps:
    - uses: actions/checkout@v3
    
    - name: Wait for EC2 to be ready
      run: sleep 90
    
    - name: Deploy to EC2
      uses: appleboy/ssh-action@v1.0.0
      with:
        host: ${{ needs.terraform.outputs.instance_ip }}
        username: ubuntu
        key: ${{ secrets.EC2_SSH_KEY }}
        port: 22
        timeout: 60s
        script: |
          # Update system
          sudo apt-get update
          
          # Install Docker if not present
          if ! command -v docker &> /dev/null; then
            sudo apt-get install -y docker.io
            sudo systemctl start docker
            sudo systemctl enable docker
            sudo usermod -aG docker ubuntu
          fi
          
          # Install Docker Compose if not present
          if ! command -v docker-compose &> /dev/null; then
            sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
            sudo chmod +x /usr/local/bin/docker-compose
          fi
          
          # Create app directory
          mkdir -p ~/dream-vacation-app
          cd ~/dream-vacation-app
          
          # Stop existing containers
          sudo docker-compose down || true
          
          # Pull latest images
          sudo docker pull bashtech007/dream-vacation-frontend:latest
          sudo docker pull bashtech007/dream-vacation-backend:latest
          
          # Create docker-compose file
          cat > docker-compose.yml << 'EOF'
          version: '3.8'
          services:
            backend:
              image: bashtech007/dream-vacation-backend:latest
              ports:
                - "5000:5000"
              restart: unless-stopped
              healthcheck:
                test: ["CMD", "curl", "-f", "http://localhost:5000/health"]
                interval: 30s
                timeout: 10s
                retries: 3
            
            frontend:
              image: bashtech007/dream-vacation-frontend:latest
              ports:
                - "80:3000"
              restart: unless-stopped
              depends_on:
                - backend
              healthcheck:
                test: ["CMD", "curl", "-f", "http://localhost:3000"]
                interval: 30s
                timeout: 10s
                retries: 3
          EOF
          
          # Start containers
          sudo docker-compose up -d
          
          # Wait for containers to start
          sleep 30
          
          # Check container status
          sudo docker-compose ps
          sudo docker-compose logs --tail=50