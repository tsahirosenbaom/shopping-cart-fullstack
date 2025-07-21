#!/bin/bash

echo "🐳 Building Docker images..."

# Load repository URIs
source ecr-repos.txt

# Build .NET API Docker image
echo "Building .NET API image..."
cd ~/dotnet-api/ProductApi

# Create optimized Dockerfile for production
cat > Dockerfile << 'DOCKEREOF'
# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy project files
COPY *.csproj ./
RUN dotnet restore

# Copy everything else and build
COPY . ./
RUN dotnet publish -c Release -o /app/publish --no-restore

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish .

# Create non-root user
RUN addgroup --system --gid 1001 dotnetgroup
RUN adduser --system --uid 1001 --gid 1001 dotnetuser
RUN chown -R dotnetuser:dotnetgroup /app
USER dotnetuser

EXPOSE 80
ENV ASPNETCORE_URLS=http://+:80
ENV ASPNETCORE_ENVIRONMENT=Production

ENTRYPOINT ["dotnet", "ProductApi.dll"]
DOCKEREOF

# Build and tag .NET image
docker build -t $DOTNET_REPO_URI:latest .
docker tag $DOTNET_REPO_URI:latest $DOTNET_REPO_URI:v1.0

# Build Node.js API Docker image
echo "Building Node.js API image..."
cd ~/simple-search-api

# Create optimized Dockerfile for Node.js
cat > Dockerfile << 'DOCKEREOF'
# Build stage
FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# Production stage
FROM node:18-alpine AS production
WORKDIR /app

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001

# Copy built application
COPY --from=build --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --chown=nodejs:nodejs server.js ./
COPY --chown=nodejs:nodejs package.json ./

USER nodejs

EXPOSE 3000
ENV NODE_ENV=production
ENV PORT=3000

CMD ["node", "server.js"]
DOCKEREOF

# Build and tag Node.js image
docker build -t $NODEJS_REPO_URI:latest .
docker tag $NODEJS_REPO_URI:latest $NODEJS_REPO_URI:v1.0

echo "✅ Docker images built successfully"

# Push images to ECR
echo "📤 Pushing images to ECR..."
docker push $DOTNET_REPO_URI:latest
docker push $DOTNET_REPO_URI:v1.0
docker push $NODEJS_REPO_URI:latest  
docker push $NODEJS_REPO_URI:v1.0

echo "✅ Images pushed to ECR"
