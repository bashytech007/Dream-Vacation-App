# Stage 1: Build the React app
FROM node:16-alpine as build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Stage 2: Serve with Nginx
FROM nginx:alpine
# Copy build output to nginx html folder
COPY --from=build /app/build /usr/share/nginx/html
# Expose port 80 for the container
EXPOSE 80
# Run Nginx in foreground
CMD ["nginx", "-g", "daemon off;"]

