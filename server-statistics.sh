#/bin/bash

  total=$(free -m | awk '{ if (NR > 1) print $2 }' | head -1)
  used=$(free -m | awk '{ if (NR > 1) print $3 }' | head -1)
  free=$(free -m | awk '{ if (NR > 1) print $4 }' | head -1)
  available=$(free -m | awk '{ if (NR > 1) print $7 }' | head -1)
  unused=$((free + available))
  percentageMem=$(( used*100 ))
  uid=$(id -u)
  diskspace=$(df -h | awk '{ if ( NR > 1) print $0 }')
  sortUsageByMem=$(ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -10)
  sortUsageByCPU=$(ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -10)

  memUsage=$(( percentageMem / total ))
  cpuUsage=$(top -b -n 1| head -3 | grep "Cpu(s)" | awk '{print $2 + $4}' | cut -d"." -f1)
  threshold=90

checkResource() {
  if [[ $memUsage -gt $threshold ]];
  then
    echo "Memory usage is at max";
  else
    echo "Memory usage is normal";
  fi

  if [[ $cpuUsage -gt $threshold ]];
  then
    echo "CPU Usage is at max";
  else
    echo "CPU usage is normal";
  fi
}

 
generateReport() {
  echo "<---------- Physical Memory Status ----------";
  echo "Total Memory : $total MB";
  echo "Used Memory: $used MB";
  echo "Free Memory (Free + Available): $unused MB";
  echo "Used Memory in (%): " $(( percentageMem / total ))"%";
  echo -e "\n";

  echo "<---------- Disk Space Status ---------->";
  echo "$diskspace";
  echo -e "\n";

  echo "<---------- CPU Usage Status  ---------->";
  echo "Top 10 processes sorted by memory usage."
  echo "$sortUsageByMem";
  echo -e "\n";

  echo "Top 10 processes sorted by CPU usage.";
  echo "$sortUsageByCPU";
  echo -e "\n";

  echo "<-------- Used Ports On Server --------->";
  echo "To check the program name run the script with sudo privilege";

  if [ "$uid" -eq 0 ];
  then
    netstat -tlnp | awk '{ if ( NR > 1) print $0 }'
  else
    netstat -tln | awk '{ if ( NR > 1) print $0 }'
  fi
}

main(){
#generateReport;
checkResource;
}
main;
