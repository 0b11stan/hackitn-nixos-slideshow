FROM alpine

WORKDIR /root

RUN apk add git nodejs npm
RUN git clone https://github.com/hakimel/reveal.js.git

COPY index.html /root/reveal.js/index.html
COPY dist/ /root/reveal.js/dist/

WORKDIR /root/reveal.js
RUN npm install
