# Build stage
FROM node:16-alpine AS builder

WORKDIR /usr/src/app

# Copy package files first for better caching
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Production stage
FROM node:16-alpine

WORKDIR /usr/src/app

# Install serve globally
RUN npm install -g serve

# Copy built application from builder stage
COPY --from=builder /usr/src/app/build ./build

# Run as non-root user for security
RUN addgroup -g 1001 -S nodejs
RUN adduser -S reactuser -u 1001
USER reactuser

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000 || exit 1

CMD ["serve", "-s", "-l", "3000", "build"]