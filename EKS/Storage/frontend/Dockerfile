FROM node:16-alpine

WORKDIR /usr/src/app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Install serve to serve the built application
RUN npm install -g serve

# Expose port
EXPOSE 5000

# Start the application
CMD ["serve", "-s", "build", "-l", "5000"]
