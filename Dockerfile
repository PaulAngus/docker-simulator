FROM centos:7

ENV PATH="/opt/maven/bin:/usr/lib/jvm/java-1.8.0-openjdk/bin:${PATH}"
ENV JAVA_HOME="/usr/lib/jvm/java-1.8.0-openjdk"

RUN yum install -y epel-release deltarpm && yum install -y ca-certificates java-1.8.0-openjdk-devel sudo tar ws-commons-util jpackage-utils gcc glibc-devel mysql-connector-java wget mariadb-server bzip2 git python-setuptools python-pip && yum clean all
COPY my.cnf /etc/my.cnf
RUN /usr/libexec/mariadb-prepare-db-dir mariadb.service && bash -c "/usr/libexec/mysqld --user=mysql --console &" && cd /tmp && wget http://apache.mirror.anlx.net/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz && tar zxf apache-maven-3.6.3-bin.tar.gz && mv apache-maven-3.6.3/ /opt/maven && rm -f apache-maven-3.6.3-bin.tar.gz 
RUN mkdir /acs && cd /tmp && wget http://www.mirrorservice.org/sites/ftp.apache.org/cloudstack/releases/4.13.0.0/apache-cloudstack-4.13.0.0-src.tar.bz2 && tar -jxf /tmp/apache-cloudstack-4.13.0.0-src.tar.bz2 && mv /tmp/apache-cloudstack-4.13.0.0-src/* /acs/ && rm -f /tmp/apache-cloudstack-4.13.0.0-src.tar.bz2 && cd /acs && LIBS=NONOSS && git clone https://github.com/rhtyd/cloudstack-nonoss.git $LIBS && cd $LIBS && bash -x install-non-oss.sh && rm -rf /acs/NONOSS && sed -i 's/<scope>provided,test<\/scope>/<scope>test<\/scope>/g' /acs/pom.xml && cd /acs && mvn -Pdeveloper -Dsimulator -DskipTests clean install -T3 && cd /acs && pip install --upgrade tools/marvin/dist/Marvin*.tar.gz
COPY simulator.sh /usr/local/bin/simulator.sh
COPY advanced.cfg /acs/setup/dev/advanced.cfg 
ENTRYPOINT ["simulator.sh"]
CMD ["simulator.sh"]
