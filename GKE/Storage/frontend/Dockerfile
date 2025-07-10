# Multi-stage build for React application
FROM node:16-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY . .

# Set build environment
ENV REACT_APP_BACKEND_URL=http://localhost:8000

# Build the application
RUN npm run build

# Production stage
FROM node:16-alpine

# Install serve globally
RUN npm install -g serve

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set working directory
WORKDIR /app

# Copy build files from builder stage
COPY --from=builder /app/build ./build

# Change ownership to non-root user
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:5000/ || exit 1

# Start the application
CMD ["serve", "-s", "-l", "5000", "build"]
