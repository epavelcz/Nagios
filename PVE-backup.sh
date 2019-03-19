#!/bin/bash


#default valus
#default value is 1=warning, if something goes wrong in for file clause
result=""
errCode=1

for file in `ls /var/log/pve/tasks/[0-9A-F]/*vzdump* -Art | tail -n 1`

do
        result=`grep 'ERROR' $file|grep VM`
        if [ "x$result" != "x" ] ; then
                errCode=2
        else
                errCode=0
                result=`echo $((( $(date +%s) - $(stat -c %Y $file)) / 3600 ))`
                if [ $result -gt 48 ] ; then
                        errCode=3
                fi
        fi

done

case "$errCode" in

        0)
                echo "OK - Backup log age:" $result "hours"
                
                exit 0
        ;;

        1)
                echo "WARNING - Something went wrong with for file. Please check permissions"
                exit 1
        ;;
        2)
                echo $result
                exit 2
        ;;
        3)
                echo "WARNING - Backup log age older than 48 hours ("$result "hours)"
                exit 1
        ;;

esac
