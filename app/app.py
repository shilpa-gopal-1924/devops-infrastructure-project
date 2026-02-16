# app.py - Simple Flask Web Application

from flask import Flask, jsonify, render_template_string, request
import os
import socket
from datetime import datetime
from prometheus_client import Counter, Histogram, Gauge, generate_latest, REGISTRY
from prometheus_client import CollectorRegistry, multiprocess, CONTENT_TYPE_LATEST
import time

app = Flask(__name__)


# Prometheus metrics
REQUEST_COUNT = Counter(
    'app_request_count',
    'Application Request Count',
    ['method', 'endpoint', 'http_status']
)

REQUEST_LATENCY = Histogram(
    'app_request_latency_seconds',
    'Application Request Latency',
    ['method', 'endpoint']
)

ACTIVE_REQUESTS = Gauge(
    'app_active_requests',
    'Number of active requests'
)

@app.before_request
def before_request():
    """Track request start time"""
    request.start_time = time.time()
    ACTIVE_REQUESTS.inc()

@app.after_request
def after_request(response):
    """Record metrics after each request"""
    request_latency = time.time() - request.start_time
    
    REQUEST_COUNT.labels(
        method=request.method,
        endpoint=request.endpoint or 'unknown',
        http_status=response.status_code
    ).inc()
    
    REQUEST_LATENCY.labels(
        method=request.method,
        endpoint=request.endpoint or 'unknown'
    ).observe(request_latency)
    
    ACTIVE_REQUESTS.dec()
    
    return response


# HTML template for the home page
HTML_TEMPLATE = '''
<!DOCTYPE html>
<html>
<head>
    <title>DevOps Infrastructure Project</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        
        .container {
            background: white;
            border-radius: 20px;
            padding: 50px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            max-width: 800px;
            width: 100%;
        }
        
        h1 {
            color: #2d3748;
            margin-bottom: 10px;
            font-size: 2.5em;
            text-align: center;
        }
        
        .subtitle {
            color: #718096;
            text-align: center;
            margin-bottom: 40px;
            font-size: 1.2em;
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin: 30px 0;
        }
        
        .info-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            border-radius: 10px;
            text-align: center;
        }
        
        .info-label {
            font-size: 0.9em;
            opacity: 0.9;
            margin-bottom: 8px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        
        .info-value {
            font-size: 1.5em;
            font-weight: bold;
        }
        
        .status {
            background: #10b981;
            color: white;
            padding: 15px 30px;
            border-radius: 30px;
            display: inline-block;
            margin: 20px 0;
            font-weight: bold;
            font-size: 1.1em;
        }
        
        .tech-stack {
            margin-top: 30px;
            padding-top: 30px;
            border-top: 2px solid #e2e8f0;
        }
        
        .tech-stack h3 {
            color: #2d3748;
            margin-bottom: 15px;
        }
        
        .tech-badges {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            justify-content: center;
        }
        
        .tech-badge {
            background: #667eea;
            color: white;
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 0.9em;
        }
        
        .footer {
            margin-top: 30px;
            text-align: center;
            color: #718096;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 DevOps Infrastructure Project</h1>
        <p class="subtitle">Automated Infrastructure Provisioning with CI/CD</p>
        
        <div style="text-align: center;">
            <span class="status">✓ Application Running Successfully</span>
        </div>
        
        <div class="info-grid">
            <div class="info-card">
                <div class="info-label">Hostname</div>
                <div class="info-value">{{ hostname }}</div>
            </div>
            <div class="info-card">
                <div class="info-label">Server Time</div>
                <div class="info-value">{{ current_time }}</div>
            </div>
            <div class="info-card">
                <div class="info-label">Version</div>
                <div class="info-value">v1.2</div>
            </div>
        </div>
        
        <div class="tech-stack">
            <h3>Technology Stack</h3>
            <div class="tech-badges">
                <span class="tech-badge">Flask</span>
                <span class="tech-badge">Docker</span>
                <span class="tech-badge">Terraform</span>
                <span class="tech-badge">AWS</span>
                <span class="tech-badge">GitHub Actions</span>
                <span class="tech-badge">Prometheus</span>
                <span class="tech-badge">Grafana</span>
            </div>
        </div>
        
        <div class="footer">
            <p>Deployed via automated CI/CD pipeline</p>
            <p>Infrastructure provisioned with Terraform</p>
        </div>
    </div>
</body>
</html>
'''

@app.route('/')
def home():
    """Main landing page"""
    hostname = socket.gethostname()
    current_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    
    return render_template_string(
        HTML_TEMPLATE,
        hostname=hostname,
        current_time=current_time
    )

@app.route('/health')
def health():
    """Health check endpoint for monitoring"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'hostname': socket.gethostname(),
        'version': '1.2'
    }), 200

@app.route('/api/info')
def info():
    """API endpoint with system information"""
    return jsonify({
        'application': 'DevOps Infrastructure Project',
        'version': '1.2',
        'hostname': socket.gethostname(),
        'timestamp': datetime.now().isoformat(),
        'environment': os.getenv('ENVIRONMENT', 'production'),
        'technologies': [
            'Flask',
            'Docker',
            'Terraform',
            'AWS EC2',
            'GitHub Actions',
            'Prometheus',
            'Grafana'
        ]
    }), 200

@app.route('/metrics')
def metrics():
    "Prometheus Metrics Endpoint"
    return generate_latest(REGISTRY), 200, {'Content-Type': CONTENT_TYPE_LATEST}

if __name__ == '__main__':
    # Get port from environment variable or use default
    port = int(os.getenv('PORT', 5000))
    
    # Run the application
    app.run(
        host='0.0.0.0',  # Listen on all interfaces
        port=port,
        debug=False  # Set to False in production
    )