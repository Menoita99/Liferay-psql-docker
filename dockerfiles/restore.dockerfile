FROM alpine:latest

RUN apk update

RUN apk add --upgrade rsync

#CMD [ "/bin/bash" ]
CMD [ "rsync", "-azvh" , "/bind/backup" , "/backup" ]