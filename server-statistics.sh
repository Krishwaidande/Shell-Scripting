#/bin/bash

mailfile="server-status-$(date +%Y-%m-%d).txt"
touch $mailfile

#Retrive memory information for report.
totalMem=$(free -m | awk '{ if (NR > 1) print $2 }' | head -1)
usedMem=$(free -m | awk '{ if (NR > 1) print $3 }' | head -1)
freeMem=$(free -m | awk '{ if (NR > 1) print $4+$7 }' | head -1)
sortUsageByMem=$(ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -10)

memUsage=$(( (usedMem*100)/totalMem ))
cpuUsage=$(top -b -n 1| head -3 | grep "Cpu(s)" | awk '{print $2 + $4}' | cut -d"." -f1)

memThreshold=30
cpuThreshold=90

#Mail Properties
to="krishna@krishagni.com"
from="krishna.jenkins@gmail.com"
subject="Alert : $(hostname) server statistics"

setMailProps() {
  echo "To: $to" >> $mailfile
  echo "From: $from" >> $mailfile
  echo "Subject: $subject" >> $mailfile
}

generateReport() {
  echo "The server is running on low memory. Below is detailed information about the memory usage." >> $mailfile
  echo -e "\n" >> $mailfile
  echo "Total Memory : $totalMem MB" >> $mailfile
  echo "Used Memory: $usedMem MB" >> $mailfile
  echo "Free Memory (Free + Available): $freeMem MB" >> $mailfile
  echo "Used Memory in (%): $memUsage %" >> $mailfile
  echo -e "\n" >> $mailfile

  echo "Top 10 processes sorted by memory usage." >> $mailfile
  echo "$sortUsageByMem" >> $mailfile
  echo -e "\n";
}

checkResourceAndSendMail() {
  if [[ $memUsage -gt $memThreshold ]];
  then
    setMailProps;
    generateReport;    
    cat $mailfile | ssmtp -v $to
  fi

  if [[ $cpuUsage -gt $cpuThreshold ]];
  then
    echo "CPU Usage is at max" >> $mailfile
    echo -e "\n" >> $mailfile
  fi
}

main() {
  checkResourceAndSendMail;
  rm $mailfile
}
main;
