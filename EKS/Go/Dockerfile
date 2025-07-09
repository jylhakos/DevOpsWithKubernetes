#FROM ubuntu:18.04

FROM golang:1.16-alpine

RUN mkdir /app

WORKDIR /app

RUN apk add --update --no-cache wget gcc libc-dev
	#&& rm -rf /usr/local/go \ 
	#&& wget -c https://golang.org/dl/go1.16.3.linux-amd64.tar.gz \ 
	#&& tar -C /usr/local -xzf go1.16.3.linux-amd64.tar.gz

#RUN apk add build-base

#ENV PATH /usr/local/go/bin:$PATH

COPY go.* ./

RUN go get -v -d ./...

COPY . .

ENV PORT=8080

ENV REQUEST_ORIGIN=http://localhost:5000

RUN go build -v -o ./server

RUN go test ./...

EXPOSE 8080

CMD ["./server"]