FROM node:14-slim

WORKDIR /app

COPY ./package*.json ./

RUN npm ci

COPY . .

USER node

EXPOSE 7070

CMD [ "npm", "start" ]