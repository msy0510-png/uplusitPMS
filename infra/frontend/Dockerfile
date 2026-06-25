FROM node:20 AS build
WORKDIR /src
COPY package*.json ./
RUN npm ci || npm install
COPY . .
RUN npm run build
FROM nginx:1.27-alpine
COPY --from=build /src/dist /usr/share/nginx/html
COPY ../infra/frontend/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
