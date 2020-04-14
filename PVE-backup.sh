#!/bin/bash

#Variables

#Max file age in hours
maxLogAge=181

#Debug mode - prints variables before execution
debug=0

#Find latest backup file
backupLogFile=`ls /var/log/pve/tasks/[0-9A-F]/*vzdump* -Art | tail -n 1`
#backupLogFile=/usr/local/bin/nagios/testlog

#Get errors and error counts
resultError=`grep ERROR $backupLogFile| grep -v "'\guest-fsfreeze-thaw'\ failed"`
resultErrorCount=`grep ERROR $backupLogFile| grep -v "'\guest-fsfreeze-thaw'\ failed" | wc -l`

#Get warnings and warnings counts
resultWarning=`grep "ERROR\|WARNING\|Warning" $backupLogFile| grep "'\guest-fsfreeze-thaw'\ failed\|WARNING\|Warning"`
resultWarningCount=`grep "ERROR\|WARNING\|Warning" $backupLogFile| grep "'\guest-fsfreeze-thaw'\ failed\|WARNING\|Warning" | wc -l`

#Set debug=1 to see the variable values
if [ $debug -eq 1 ]
then
    echo "backupLogFile =  $backupLogFile" 
	echo "resultError = $resultError"
	echo "resultErrorCount = $resultErrorCount"
	echo "resultWarning = $resultWarning"
	echo "resultWarningCount = $resultWarningCount"
	echo ""
fi

#Readability check
if ! [ -r $backupLogFile ]
then
	echo ERROR: File is not readable, check for permissions or use the plugin with sudo
	exit 2
fi

#RESULTS

#Some errors and warnings
if [ $resultErrorCount -ge 1 ] && [ $resultWarningCount -ge 1 ]
then
	data="\nERRORs:\n$resultError\nWARNINGs:\n$resultWarning"
	echo -e $"ERROR: Found $resultErrorCount ERROR(s) and $resultWarningCount WARNING(s) | $data "
	exit 2

#Only errors
elif [ $resultErrorCount -ge 1 ] && [ $resultWarningCount -eq 0 ]
then
	data="\nERRORs:\n$resultError"
	echo -e "ERROR: Found $resultErrorCount ERROR(s) | $data "
	exit 2

#Only warnings
elif [ $resultErrorCount -eq 0 ] && [ $resultWarningCount -ge 1 ]
then
	data="\nWARNINGs:\n$resultWarning"
	echo -e "WARNING: Found $resultWarningCount WARNING(s) | $data"
	exit 1

#No errors and warnings
elif [ $resultErrorCount -eq 0 ] && [ $resultWarningCount -eq 0 ]
then	
	#Get age of the log file
	logAge=$((( $(date +%s) - $(stat -c %Y $backupLogFile)) / 3600 ))

    #File older than maxLogAge
    if [ $logAge -ge $maxLogAge ]
    then
    	echo "ERROR: Log older than $maxLogAge h - Log age: $logAge h"
		exit 2
	#Everything OK
	else
		echo "OK: Backup Log Age: $logAge hours"
		exit 0
	fi
	
#No condition met
else
	echo "ERROR: Conditions not met, please check permissions"
	exit 2
fi
