# Define the Node.js version as an argument for flexibility
ARG NODE_VERSION=18

# Stage 1: Build stage (Runs on any platform)
FROM --platform=$BUILDPLATFORM node:${NODE_VERSION}-alpine AS builder

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json for caching dependencies
COPY package*.json ./

# Install dependencies
RUN npm install --only=production

# Copy the rest of the application files
COPY . .

# Build the application
RUN npm run build


# Stage 2: Final Linux Image (Optimized for Linux/macOS)
FROM node:${NODE_VERSION}-alpine AS linux-app

WORKDIR /app
COPY --from=builder /app ./

# Set a non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Expose the application port
EXPOSE 3000

# Run the application
CMD ["npm", "run", "start"]


# Stage 3: Final Windows Image (Optimized for Windows)
FROM mcr.microsoft.com/windows/nanoserver:ltsc2022 AS windows-app

WORKDIR /app
COPY --from=builder /app ./

# Expose the application port
EXPOSE 3000

# Run the application
CMD ["npm", "run", "start"]


# Final Stage: Choose the appropriate platform
FROM linux-app AS final
