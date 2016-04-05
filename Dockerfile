FROM java:8

ADD . /app
RUN cd /app && ./gradlew assemble
ENV TOMCAT_VERSION=8.0.28
ENV CATALINA_HOME /tomcat

ADD run.sh /tmp/
RUN chmod +x /tmp/run.sh && \
    wget -q https://archive.apache.org/dist/tomcat/tomcat-8/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz && \
    wget -qO- https://archive.apache.org/dist/tomcat/tomcat-8/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz.md5 | md5sum -c - && \
    tar zxf apache-tomcat-$TOMCAT_VERSION.tar.gz && \
    rm apache-tomcat-$TOMCAT_VERSION.tar.gz

RUN mkdir -p /uaa && mkdir /tomcat && \
    mv apache-tomcat-$TOMCAT_VERSION/* /tomcat && \
    rm -rf /tomcat/webapps/* && \
    mv /app/uaa/build/libs/cloudfoundry-identity-uaa-*.war /tomcat/webapps/ROOT.war && \
    rm -rf /app

EXPOSE 8080

CMD ["/tmp/run.sh"]
