FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Expose port (serve uses PORT env var, default 3000)
EXPOSE 3000

# Start the application using serve
CMD ["npm", "start"]