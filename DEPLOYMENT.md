# Deployment Guide

This guide covers deploying the SmartParking application to various platforms.

## Prerequisites

- Backend API deployed and accessible via HTTPS
- MongoDB instance (local, cloud, or managed service)
- SSL/TLS certificate for production (recommended)
- Domain name (optional but recommended)

## Backend Deployment

### Option 1: Docker Deployment (Recommended)

The application includes Docker support for easy deployment.

#### Local Docker

```bash
cd backend
docker-compose up --build
```

#### Docker with Custom Configuration

1. Create a `.env` file from the example:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` with your production settings:
   ```bash
   MONGO_DB_CONNECTION_STRING=mongodb://user:pass@mongo:27017
   JWT_SECRET=your-secure-random-secret-key
   SERIAL_PORT_NAME=  # Leave empty for auto-detection
   ```

3. Build and run:
   ```bash
   docker-compose up -d
   ```

### Option 2: Cloud Platform Deployment

#### Azure App Service

1. **Install Azure CLI**:
   ```bash
   curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
   ```

2. **Login to Azure**:
   ```bash
   az login
   ```

3. **Create Resource Group**:
   ```bash
   az group create --name SmartParkingRG --location eastus
   ```

4. **Create App Service Plan**:
   ```bash
   az appservice plan create --name SmartParkingPlan \
     --resource-group SmartParkingRG --sku B1 --is-linux
   ```

5. **Create Web App**:
   ```bash
   az webapp create --resource-group SmartParkingRG \
     --plan SmartParkingPlan --name smartparking-api \
     --runtime "DOTNET|9.0"
   ```

6. **Configure Environment Variables**:
   ```bash
   az webapp config appsettings set --resource-group SmartParkingRG \
     --name smartparking-api --settings \
     MONGO_DB_CONNECTION_STRING="your-connection-string" \
     JWT_SECRET="your-jwt-secret"
   ```

7. **Deploy Code**:
   ```bash
   cd backend
   az webapp deployment source config-zip \
     --resource-group SmartParkingRG \
     --name smartparking-api \
     --src publish.zip
   ```

#### AWS Elastic Beanstalk

1. **Install EB CLI**:
   ```bash
   pip install awsebcli
   ```

2. **Initialize EB Application**:
   ```bash
   cd backend
   eb init -p "64bit Amazon Linux 2023 v3.0.0 running .NET 9" smartparking
   ```

3. **Create Environment**:
   ```bash
   eb create smartparking-env
   ```

4. **Set Environment Variables**:
   ```bash
   eb setenv MONGO_DB_CONNECTION_STRING="your-string" JWT_SECRET="your-secret"
   ```

5. **Deploy**:
   ```bash
   eb deploy
   ```

#### Heroku

1. **Install Heroku CLI**:
   ```bash
   curl https://cli-assets.heroku.com/install.sh | sh
   ```

2. **Login**:
   ```bash
   heroku login
   ```

3. **Create App**:
   ```bash
   cd backend
   heroku create smartparking-api
   ```

4. **Add Buildpack**:
   ```bash
   heroku buildpacks:set heroku/dotnet
   ```

5. **Set Environment Variables**:
   ```bash
   heroku config:set MONGO_DB_CONNECTION_STRING="your-string"
   heroku config:set JWT_SECRET="your-secret"
   ```

6. **Deploy**:
   ```bash
   git push heroku main
   ```

### Option 3: Traditional Server Deployment

#### Linux Server (Ubuntu/Debian)

1. **Install .NET Runtime**:
   ```bash
   wget https://dot.net/v1/dotnet-install.sh
   chmod +x dotnet-install.sh
   ./dotnet-install.sh --channel 9.0
   ```

2. **Build Application**:
   ```bash
   cd backend
   dotnet publish -c Release -o ./publish
   ```

3. **Create Systemd Service**:
   Create `/etc/systemd/system/smartparking.service`:
   ```ini
   [Unit]
   Description=SmartParking API
   After=network.target

   [Service]
   Type=notify
   WorkingDirectory=/var/www/smartparking
   ExecStart=/usr/bin/dotnet /var/www/smartparking/SmartParking.dll
   Restart=always
   RestartSec=10
   User=www-data
   Environment=ASPNETCORE_ENVIRONMENT=Production
   Environment=MONGO_DB_CONNECTION_STRING=your-connection-string
   Environment=JWT_SECRET=your-secret

   [Install]
   WantedBy=multi-user.target
   ```

4. **Enable and Start Service**:
   ```bash
   sudo systemctl enable smartparking
   sudo systemctl start smartparking
   ```

5. **Configure Nginx Reverse Proxy**:
   Create `/etc/nginx/sites-available/smartparking`:
   ```nginx
   server {
       listen 80;
       server_name api.smartparking.com;
       
       location / {
           proxy_pass http://localhost:8080;
           proxy_http_version 1.1;
           proxy_set_header Upgrade $http_upgrade;
           proxy_set_header Connection keep-alive;
           proxy_set_header Host $host;
           proxy_cache_bypass $http_upgrade;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
       }
   }
   ```

6. **Enable Site and Restart Nginx**:
   ```bash
   sudo ln -s /etc/nginx/sites-available/smartparking /etc/nginx/sites-enabled/
   sudo nginx -t
   sudo systemctl restart nginx
   ```

## Database Deployment

### MongoDB Atlas (Recommended)

1. Create account at [mongodb.com/cloud/atlas](https://www.mongodb.com/cloud/atlas)
2. Create a new cluster
3. Add database user
4. Whitelist IP addresses (or use 0.0.0.0/0 for testing)
5. Get connection string
6. Update `MONGO_DB_CONNECTION_STRING` in your backend configuration

### Self-Hosted MongoDB

```bash
# Docker
docker run -d -p 27017:27017 \
  -e MONGO_INITDB_ROOT_USERNAME=admin \
  -e MONGO_INITDB_ROOT_PASSWORD=password \
  mongo:latest

# Or install directly on server
sudo apt-get install mongodb-org
sudo systemctl start mongod
```

## Mobile App Deployment

### Android (Google Play Store)

1. **Create Keystore**:
   ```bash
   keytool -genkey -v -keystore smartparking-release.jks \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -alias smartparking
   ```

2. **Configure Signing**:
   Create `android/key.properties`:
   ```properties
   storePassword=your-store-password
   keyPassword=your-key-password
   keyAlias=smartparking
   storeFile=/path/to/smartparking-release.jks
   ```

3. **Update build.gradle**:
   ```gradle
   android {
       ...
       signingConfigs {
           release {
               keyAlias keystoreProperties['keyAlias']
               keyPassword keystoreProperties['keyPassword']
               storeFile file(keystoreProperties['storeFile'])
               storePassword keystoreProperties['storePassword']
           }
       }
       buildTypes {
           release {
               signingConfig signingConfigs.release
           }
       }
   }
   ```

4. **Build Release APK**:
   ```bash
   flutter build apk --release \
     --dart-define=API_BASE_URL=https://api.smartparking.com/api
   ```

5. **Build App Bundle** (for Play Store):
   ```bash
   flutter build appbundle --release \
     --dart-define=API_BASE_URL=https://api.smartparking.com/api
   ```

6. **Upload to Play Console**:
   - Go to [play.google.com/console](https://play.google.com/console)
   - Create new app
   - Upload the `.aab` file from `build/app/outputs/bundle/release/`
   - Follow the submission process

### iOS (Apple App Store)

1. **Requirements**:
   - macOS with Xcode installed
   - Apple Developer account ($99/year)

2. **Configure Signing in Xcode**:
   ```bash
   open ios/Runner.xcworkspace
   ```
   - Select Runner target
   - Set Team under Signing & Capabilities
   - Set Bundle Identifier

3. **Build for Release**:
   ```bash
   flutter build ios --release \
     --dart-define=API_BASE_URL=https://api.smartparking.com/api
   ```

4. **Archive and Upload**:
   - In Xcode: Product → Archive
   - Validate the archive
   - Distribute to App Store
   - Follow App Store Connect submission process

### Web Deployment

1. **Build Web Version**:
   ```bash
   flutter build web --release \
     --dart-define=API_BASE_URL=https://api.smartparking.com/api
   ```

2. **Deploy to Hosting Service**:

   **Firebase Hosting**:
   ```bash
   npm install -g firebase-tools
   firebase login
   firebase init hosting
   firebase deploy
   ```

   **Netlify**:
   ```bash
   npm install -g netlify-cli
   netlify deploy --prod --dir=build/web
   ```

   **GitHub Pages**:
   ```bash
   # Add to your repository
   git subtree push --prefix build/web origin gh-pages
   ```

## Security Considerations

### Production Checklist

- [ ] Use HTTPS for all API endpoints
- [ ] Generate strong JWT secret (minimum 32 characters)
- [ ] Use environment variables for sensitive data
- [ ] Enable MongoDB authentication
- [ ] Restrict MongoDB network access
- [ ] Configure CORS to allow only your domains
- [ ] Enable rate limiting on API endpoints
- [ ] Regular security updates for dependencies
- [ ] Implement proper logging and monitoring
- [ ] Backup database regularly

### Generating Secure JWT Secret

```bash
# Linux/macOS
openssl rand -base64 32

# PowerShell (Windows)
[Convert]::ToBase64String((1..32 | ForEach-Object { Get-Random -Minimum 0 -Maximum 256 }))
```

## Monitoring & Maintenance

### Application Insights (Azure)

```bash
# Add to backend
dotnet add package Microsoft.ApplicationInsights.AspNetCore
```

### CloudWatch (AWS)

Configure through AWS Console or EB CLI.

### Custom Logging

The application already includes logging. View logs:

```bash
# Docker
docker-compose logs -f

# Systemd
sudo journalctl -u smartparking -f

# Azure
az webapp log tail --name smartparking-api --resource-group SmartParkingRG
```

## Troubleshooting

### Common Issues

1. **CORS Errors**: Ensure backend CORS is configured correctly
2. **Connection Timeout**: Check firewall rules and security groups
3. **MongoDB Connection Failed**: Verify connection string and network access
4. **SSL/TLS Issues**: Ensure valid certificate is installed
5. **Serial Port Access**: Serial port features only work on servers with hardware access

### Health Checks

Test your deployment:

```bash
# API Health
curl https://api.smartparking.com/api/LightSensor/status

# HTTPS Configuration
curl -I https://api.smartparking.com

# MongoDB Connection
# Check application logs for connection status
```

## Scaling

### Horizontal Scaling

- Use load balancer (Azure Load Balancer, AWS ELB, or Nginx)
- Deploy multiple backend instances
- Use managed database service
- Consider Redis for session storage

### Vertical Scaling

- Increase server resources (CPU, RAM)
- Optimize database queries
- Implement caching strategies
- Use CDN for static assets

## Support

For issues or questions:
- Check the [HARDWARE_SETUP.md](HARDWARE_SETUP.md) for hardware-related issues
- Review application logs
- Consult the main [README.md](README.md)
- Open an issue on GitHub
