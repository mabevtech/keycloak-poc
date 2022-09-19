FROM node:16.16.0
WORKDIR /app

COPY client/package.json .
RUN npm install
CMD npm start

EXPOSE 3000
