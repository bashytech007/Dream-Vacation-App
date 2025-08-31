name: Deploy Dream Vacation App
on:
  push:
    branches: [ main ]

env:
  FRONTEND_IMAGE: bashtech007/dream-vacation-frontend
  BACKEND_IMAGE: bashtech007/dream-vacation-backend

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Deploy to EC2
      uses: appleboy/ssh-action@v1.0.0
      with:
        host: ${{ secrets.EC2_HOST }}
        username: ubuntu
        key: ${{ secrets.EC2_SSH_KEY }}
        script: |
          mkdir -p ~/dream-vacation-app
          cd ~/dream-vacation-app
          sudo docker-compose down || true
          sudo docker pull ${{ env.FRONTEND_IMAGE }}:latest
          sudo docker pull ${{ env.BACKEND_IMAGE }}:latest
          cat > docker-compose.yml << 'EOF'
          version: '3.8'
          services:
            backend:
              image: bashtech007/dream-vacation-backend:latest
              ports:
                - "5000:5000"
              restart: unless-stopped
            frontend:
              image: bashtech007/dream-vacation-frontend:latest
              ports:
                - "80:3000"
              restart: unless-stopped
              depends_on:
                - backend
          EOF
          sudo docker-compose up -d