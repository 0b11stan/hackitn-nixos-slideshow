FROM alpine

ENV PORT=8000

WORKDIR /root

RUN apk add git nodejs npm
RUN git clone https://github.com/hakimel/reveal.js.git

COPY index.html /root/reveal.js/index.html
COPY dist/ /root/reveal.js/dist/custom/

WORKDIR /root/reveal.js
RUN npm install

CMD ["/usr/bin/npm", "start", "--", "--port=$PORT", "--host=0.0.0.0"]
