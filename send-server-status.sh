#!/bin/bash

reportFile="/home/user/scripts/server-status-$(date +%Y-%m-%d).txt"
/home/user/scripts/./server-statistics.sh > $reportFile
toEmail=$(cat $reportFile | grep "To:" | cut -d":" -f2)
[ -s $reportFile ] && cat $reportFile | /usr/sbin/ssmtp -v $toEmail
rm $reportFile
