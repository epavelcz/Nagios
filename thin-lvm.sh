#!/bin/bash
######
## thin-lvm.sh "warning parameter" "critical parameter"
## Both parameterss are % of usage thin-lvm
## thin-lvm.sh 80 95
## 80 mean warning when thin-lvm is used over 80% and critical when thin-lvm is used over 95%
######

warn=$1
crit=$2
usage=`/sbin/lvs|grep "^  data"|awk '{print$5}'`

isOK=`echo "$usage < $warn"|bc`
isWARN=`echo "$usage >= $warn"|bc`
isCRIT=`echo "$usage >= $crit"|bc`

status=""
if [[ $isOK -eq 1 ]]; then status="OK"
fi
if [[ $isWARN -eq 1 ]]; then status="WARN"
fi
if [[ $isCRIT -eq 1 ]]; then status="CRIT"
fi

case "$status" in
        OK)     echo "OK - thin-lvm used for $usage%"
                exit 0
        ;;
        WARN)   echo "WARNING - thin-lvm used for $usage%"
                exit 1
        ;;
        CRIT)   echo "CRITICAL - thin-lvm used for $usage%"
                exit 2
        ;;
esac
