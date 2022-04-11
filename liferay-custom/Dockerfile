FROM alpine

ENV LIFERAY_GIT_PATH=https://github.com/liferay/liferay-portal/releases/download/7.4.3.19-ga19/liferay-ce-portal-tomcat-7.4.3.19-ga19-20220404174529051.tar.gz

RUN apk --no-cache add openjdk11

WORKDIR /download

RUN apk add --no-cache wget &\
    wget $LIFERAY_GIT_PATH

WORKDIR /opt

RUN apk add --no-cache tar &\
    tar -xvzf /download/*.tar.gz -C . 
    
RUN mv ./liferay* ./liferay
RUN mv ./liferay/tomcat* ./liferay/tomcat

RUN rm -rf /download

EXPOSE 8080

CMD [ "/bin/sh" , "/opt/liferay/tomcat/bin/catalina.sh" , "run"]