FROM node:14-slim

WORKDIR /app

COPY ./package*.json ./

RUN npm ci

COPY . .

# RUN npm install pm2 -g

USER node

EXPOSE 7070

# CMD [ "pm2-runtime", "npm", "--", "start" ]
CMD [ "npm", "start" ]