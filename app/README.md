# DevOps Web Application

A containerized Flask web application demonstrating automated infrastructure provisioning.

## Features

- ✅ Beautiful responsive landing page
- ✅ Health check endpoint (`/health`)
- ✅ API information endpoint (`/api/info`)
- ✅ Metrics endpoint for Prometheus monitoring (`/metrics`)
- ✅ Fully containerized with Docker

## Technology Stack

- **Backend:** Python 3.9 + Flask 3.0
- **Containerization:** Docker
- **Deployment:** AWS EC2 (via Terraform)
- **CI/CD:** GitHub Actions (coming soon)
- **Monitoring:** Prometheus + Grafana (coming soon)

## Running Locally

### With Python
```bash
pip install -r requirements.txt
python app.py
# Visit: http://localhost:5000
```

### With Docker
```bash
docker build -t devops-web-app:v1 .
docker run -d -p 5000:5000 devops-web-app:v1
# Visit: http://localhost:5000
```

## Docker Hub

Public image available at: `shilpa1999/devops-web-app:v1`
```bash
docker pull shilpa1999/devops-web-app:v1
docker run -d -p 5000:5000 shilpa1999/devops-web-app:v1
```

## Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Landing page with app information |
| `/health` | GET | Health check (returns JSON status) |
| `/api/info` | GET | Application details and tech stack |
| `/metrics` | GET | Prometheus metrics |

## Project Status

- ✅ Day 1: Setup completed
- ✅ Day 2: Application built and containerized
- 🔜 Day 3: Infrastructure as Code with Terraform
- 🔜 Day 4: AWS Deployment
- 🔜 Day 5-6: CI/CD Pipeline
- 🔜 Day 7-8: Monitoring with Prometheus & Grafana

## Author

Built as part of a DevOps learning project.

## License

MIT License