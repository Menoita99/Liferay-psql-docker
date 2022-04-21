FROM alpine:latest

RUN apk update

RUN apk add --upgrade rsync

CMD [ "rsync", "-azvh" , "/backup" , "/bind/backup" ]
