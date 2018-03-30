FROM node:carbon

WORKDIR /usr/src/<app name>

COPY package.json yarn.lock  ./

RUN yarn

COPY . . 

EXPOSE <PORT>

CMD ["node", "<app entry point>"]