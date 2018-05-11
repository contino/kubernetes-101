FROM node:10.1.0-alpine

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

ENV ENV_CONFIG 1st env config
ENV ENV_SECRET 1st env secret
ENV READINESS_TIMEOUT 1000

ARG NODE_ENV
ENV NODE_ENV $NODE_ENV
COPY package.json /usr/src/app/
RUN npm install && npm cache clean --force
COPY . /usr/src/app

EXPOSE 8080

CMD [ "npm", "start" ]
