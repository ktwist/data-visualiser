# Use official Node image for build step
FROM node:20-alpine AS build

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm install

# Copy source code
COPY . .

# Build the app for production
RUN npm run build

# Use Nginx to serve the built files
FROM nginx:alpine

# Copy built files to Nginx html directory
COPY --from=build /app/dist /usr/share/nginx/html

# Copy custom Nginx config (optional, see below)
# COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]