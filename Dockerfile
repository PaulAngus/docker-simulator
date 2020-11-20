FROM centos:7

ENV PATH="/opt/maven/bin:/usr/lib/jvm/java-11-openjdk/bin:${PATH}"
ENV JAVA_HOME="/usr/lib/jvm/java-11-openjdk"

RUN yum install -y epel-release deltarpm && yum install -y ca-certificates java-11-openjdk-devel sudo tar ws-commons-util jpackage-utils gcc glibc-devel mysql-connector-java wget mariadb-server bzip2 git python-setuptools python-pip && yum clean all
COPY my.cnf /etc/my.cnf

RUN /usr/libexec/mariadb-prepare-db-dir mariadb.service && bash -c "/usr/libexec/mysqld --user=mysql --console &" && cd /tmp && wget http://apache.mirror.anlx.net/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz && tar zxf apache-maven-3.6.3-bin.tar.gz && mv apache-maven-3.6.3/ /opt/maven && rm -f apache-maven-3.6.3-bin.tar.gz 

#RUN mkdir /apache && cd /tmp && wget http://www.mirrorservice.org/sites/ftp.apache.org/cloudstack/releases/4.14.0.0/apache-cloudstack-4.14.0.0-src.tar.bz2 && tar -jxf /tmp/apache-cloudstack-4.13.0.0-src.tar.bz2 && mv /tmp/apache-cloudstack-4.13.0.0-src/* /apache/ && rm -f /tmp/apache-cloudstack-4.14.0.0-src.tar.bz2 && cd /apache && LIBS=NONOSS && git clone https://github.com/rhtyd/cloudstack-nonoss.git $LIBS && cd $LIBS && bash -x install-non-oss.sh && rm -rf /apache/NONOSS && sed -i 's/<scope>provided,test<\/scope>/<scope>test<\/scope>/g' /apache/pom.xml && cd /apache && mvn -Pdeveloper -Dsimulator -DskipTests clean install -T3 && cd /apache && pip install --upgrade tools/marvin/dist/Marvin*.tar.gz && cd /apache && mvn -Dsimulator -pl :cloud-client-ui jetty:run -Djava.net.preferIPv4Stack=true &

RUN mkdir /apache && git clone https://github.com/apache/cloudstack && cd /apache/cloudstack && LIBS=NONOSS && git clone https://github.com/rhtyd/cloudstack-nonoss.git $LIBS && cd $LIBS && bash -x install-non-oss.sh && rm -rf /apache/cloudstack/NONOSS && sed -i 's/<scope>provided,test<\/scope>/<scope>test<\/scope>/g' /apache/cloudstack/pom.xml && cd /apache/cloudstack && mvn -Pdeveloper -Dsimulator -DskipTests clean install -T3 && cd /apache/cloudstack && pip install --upgrade tools/marvin/dist/Marvin*.tar.gz && cd /apache/cloudstack && mvn -Dsimulator -pl :cloud-client-ui jetty:run -Djava.net.preferIPv4Stack=true &

COPY startup.sh /usr/local/bin/startup.sh
COPY advanced.cfg /apache/cloudstack/setup/dev/advanced.cfg 
ENTRYPOINT ["startup.sh"]
CMD ["startup.sh"]
