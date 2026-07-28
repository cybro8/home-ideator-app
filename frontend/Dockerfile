FROM node:20-alpine AS base
WORKDIR /app

FROM base AS development
COPY package*.json .
RUN npm ci
COPY . .
EXPOSE 4200
CMD ["npx", "ng", "serve", "--host", "0.0.0.0", "--port", "4200", "--poll", "2000"]

FROM base AS build
COPY package*.json .
RUN npm ci
COPY . .
RUN npx ng build --configuration production

FROM nginx:alpine AS production
COPY --from=build /app/dist/home-ideator-admin /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
