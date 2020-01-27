#!/bin/bash
set -e

case "$1" in

  "advanced")
    cp /acs/setup/dev/advanced.cfg /acs/simulator.cfg
    build="yes"
    ;;
  "basic")
    cp /acs/setup/dev/basic.cfg /acs/simulator.cfg
    build="yes"
    ;;
  "advancedsg")  
    cp /acs/setup/dev/advancedsg.cfg /acs/simulator.cfg
    build="yes"
    ;;
  "local")
    cp /acs/setup/dev/local.cfg /acs/simulator.cfg
    build="yes"
    ;;
  "custom")
    build="yes"
    ;;
  "")
    ;;
  "*") 
    cp /acs/setup/dev/advanced.cfg /acs/simulator.cfg
    build="yes"
    ;;
esac

/usr/libexec/mysqld --user=mysql --console &
sleep 5
cd /acs && mvn -q -Pdeveloper -pl developer -Ddeploydb -DskipTests
cd /acs && mvn -q -Pdeveloper -pl developer -Ddeploydb-simulator -DskipTests
cd /acs && mvn -Dsimulator -pl :cloud-client-ui jetty:run -Djava.net.preferIPv4Stack=true &
if [[ "$build" == "yes" ]]; then
  sleep 120
  cat /acs/simulator.cfg
  python /acs/tools/marvin/marvin/deployDataCenter.py -i /acs/simulator.cfg
fi
tail -f /dev/null
