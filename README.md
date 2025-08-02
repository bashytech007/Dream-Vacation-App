# Dream Vacation Destinations

This application allows users to create a list of countries they'd like to visit, providing basic information about each country. The project is structured to mimic a real-world application environment, employing best practices for software engineering, deployment, and CI/CD processes.

## Project Structure

```
Dream-Vacation-App/
├── frontend/           # React frontend application
├── backend/           # Node.js backend API
├── .github/workflows/ # CI/CD pipeline configurations
├── docker-compose.yml # Docker container orchestration
└── README.md         # Project documentation
```

## CI/CD Pipeline

This project implements automated CI/CD pipelines using GitHub Actions with separate workflows for frontend and backend components.

### Workflow Architecture

#### Frontend Pipeline (`.github/workflows/frontend.yml`)
- **Triggers**: Push to main/develop branches, PRs to main (frontend changes only)
- **CI Stage**:
  - Install Node.js dependencies
  - Run tests with coverage
  - Build React application
- **CD Stage**:
  - Build Docker image
  - Push to Docker Hub registry

#### Backend Pipeline (`.github/workflows/backend.yml`)
- **Triggers**: Push to main/develop branches, PRs to main (backend changes only)
- **CI Stage**:
  - Install Node.js dependencies
  - Run backend tests
- **CD Stage**:
  - Build Docker image
  - Push to Docker Hub registry

### Multi-Stage Workflow Benefits
- **Separation of Concerns**: Frontend and backend pipelines run independently
- **Efficient Resource Usage**: Only affected components trigger their respective pipelines
- **Parallel Execution**: Both pipelines can run simultaneously when both components change
- **Fail-Fast Approach**: Tests run before expensive build operations

### GitHub Secrets Configuration
The following secrets are configured in GitHub repository settings:
- `DOCKER_USERNAME`: Docker Hub username for image registry access
- `DOCKER_PASSWORD`: Docker Hub password/token for authenticated pushes

## Docker Configuration

### Individual Dockerfiles
- **Frontend Dockerfile**: Multi-stage build (build → nginx serving)
- **Backend Dockerfile**: Node.js application with production optimizations

### Docker Compose
The `docker-compose.yml` orchestrates both services:
- **Backend Service**: Runs on port 5000
- **Frontend Service**: Runs on port 3000 (mapped to nginx port 80)
- **Networking**: Services communicate through shared bridge network

## Getting Started

### Prerequisites
- Docker and Docker Compose
- Node.js (for local development)
- GitHub account with repository access

### Local Development
```bash
# Clone the repository
git clone https://github.com/bashytech007/Dream-Vacation-App.git
cd Dream-Vacation-App

# Run with Docker Compose
docker-compose up --build

# Or run individually
cd frontend && npm install && npm start
cd backend && npm install && npm start
```

### Production Deployment
The CI/CD pipeline automatically:
1. Tests code changes
2. Builds optimized Docker images
3. Pushes images to Docker Hub registry
4. Images are ready for deployment to any Docker-compatible platform

## Automated Features

- **Continuous Integration**: Automated testing on every push/PR
- **Continuous Deployment**: Automated Docker image builds and registry pushes
- **Quality Gates**: Tests must pass before deployment
- **Environment Isolation**: Separate staging and production workflows
- **Security**: Credentials managed through GitHub Secrets

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes and ensure tests pass
4. Submit a pull request
5. CI/CD pipeline will automatically validate changes

## Deployments

Docker images are automatically built and available at:
- Frontend: `[dockerhub-username]/dream-vacation-frontend:latest`
- Backend: `[dockerhub-username]/dream-vacation-backend:latest`# Test change
