#/bin/bash

initVariables() {
  mailfile="/home/user/scripts/server-statistics-$(date +%Y-%m-%d).txt"
  touch $mailfile;

  #Memory information.
  totalMem=$(free -m | awk '{ if (NR > 1) print $2 }' | head -1)
  usedMem=$(free -m | awk '{ if (NR > 1) print $3 }' | head -1)
  freeMem=$(free -m | awk '{ if (NR > 1) print $4+$7 }' | head -1)
  percentMemUsed=$(( (usedMem*100)/totalMem ))

  #CPU information
  percentCpuUsed=$(top -b -n 1| head -3 | grep "Cpu(s)" | awk '{print $2 + $4}' | cut -d"." -f1)
  cpuIdeal=$(top -b -n 1| head -3 | grep "Cpu(s)" | awk '{print $8}' | cut -d"." -f1)

  #Disk information
  partition="/dev/vda1"
  totalDisk=$(df -m | grep -w "$partition" | awk '{ print $2}')
  usedDisk=$(df -m | grep -w "$partition" | awk '{ print $3}')
  freeDisk=$(( (totalDisk - usedDisk)/1000 ))

  #Threshold values
  memThreshold=90
  cpuThreshold=90
  diskThreshold=2

  #Mail properties
  to="krishna@krishagni.com"
  from="krishna.jenkins@gmail.com"
  subject="Alert !! os-demo server statistics"
  contentType="text/html"
}

printMailProps() {
  echo "To: $to" 			>> $mailfile 
  echo "From: $from" 			>> $mailfile  
  echo "Subject: $subject" 		>> $mailfile  
  echo "Content-Type: $contentType"  	>> $mailfile
}

topResourceConsumeProcesses() {
  resource=$1
  echo "<table border=1 style=width:100%>" >> $mailfile  
  ps -eo pid,%mem,%cpu,cmd --sort=-%$resource | head -10 | awk '{ print "<tr>" "<td width=10%>" $1 "</td>" "<td width=10%>" $2 "</td>" "<td width=10%>" $3 "</td>" "<td width=70%>" $4 $5 $6 "</td>" "</tr>" }'  >> $mailfile 
  echo "</table>"  >> $mailfile
}

topMemConsumeDirs() {
  echo "<table border=1 style=width:100%>" >> $mailfile
  echo "<tr> <th> Directory </th> <th> Size </th> </tr>" >> $mailfile  
  find / -not -path "/proc/*" -type f -printf "%s\t%p\n" | sort -nr | head -10 | awk '{print "<tr> <td width=50%>" $2 "</td> <td width=50%>" (($1/1024)/1024) "MB </td> </tr>"}' >> $mailfile
  echo "</table>" >> $mailfile
  echo "<br>" >> $mailfile
}

generateReport() {
  echo "<html>" >> $mailfile 
  echo "<body>" >> $mailfile
  echo "<p> Hi customer, </p>" >> $mailfile  
  echo "<p> The server is consuming resources at its peak. Please check below detailed information. </p>" >> $mailfile

  echo "<h3> Memory report: </h3>" >> $mailfile
  echo "<table border=1 style=width:50%>"  >> $mailfile
  echo "<tr> <td width=25%> Total Memory  </td> <td width=25%> $totalMem MB </td> </tr>" >> $mailfile  
  echo "<tr> <td width=25%> Used Memory   </td> <td width=25%> $usedMem MB </td> </tr>"  >> $mailfile
  echo "<tr> <td width=25%> Free Memory   </td> <td width=25%> $freeMem MB </td> </tr>"  >> $mailfile
  echo "<tr> <td width=25%> Used Memory in (%) </td> <td width=25%>  $percentMemUsed % </td> <tr>"  >> $mailfile
  echo "</table>"  >> $mailfile
  echo "<br>"  >> $mailfile

  echo "<h3> CPU report: </h3>" >> $mailfile
  echo "<table border=1 style=width:50%>" >> $mailfile
  echo "<tr> <td width=25%> CPU Used  </td> <td width=25%> $percentCpuUsed % </td> </tr>" >> $mailfile
  echo "<tr> <td width=25%> CPU Ideal </td> <td width=25%> $cpuIdeal % </td> </tr>" >> $mailfile
  echo "</table>" >> $mailfile
  echo "<br>" >> $mailfile
  
  echo "<h3> Disk report: </h3>" >> $mailfile
  echo "<table border=1 style=width:50%>" >> $mailfile
  echo "<tr> <td width=25%> Total Disk  </td> <td width=25%> "$(( $totalDisk/1000 ))" GB </td> </tr>" >> $mailfile
  echo "<tr> <td width=25%> Used Disk   </td> <td width=25%> "$(( $usedDisk/1000 )) " GB </td> </tr>" >> $mailfile
  echo "<tr> <td width=25%> Free Disk   </td> <td width=25%> $freeDisk  GB </td> </tr>" >> $mailfile
  echo "</table>" >> $mailfile
  echo "<br>" >> $mailfile

  echo "<h4> Top 10 CPU consuming processes  </h4>" >> $mailfile
  topResourceConsumeProcesses $1;
  echo "<br>" >> $mailfile

  echo "<h4> Top 10 files by size  </h4>" >> $mailfile
  topMemConsumeDirs;

  echo "<h4> OpenSpecimen Administrator </h4>"  >> $mailfile
  echo "<center> Contact on  <a href='support.krishagni.com'> support@krishagni.com </a> for any OpnSpecimen issues. </center>" >> $mailfile 
  echo "</body>" >> $mailfile 
  echo "</html>" >> $mailfile
}

monitorResource() {
  if [ $percentMemUsed -gt $memThreshold ];
  then
    printMailProps;
    generateReport "mem"; 
    cat $mailfile | /usr/sbin/ssmtp -v $to
    return;
  fi

  if [ $percentCpuUsed -gt $cpuThreshold ];
  then
    printMailProps;
    generateReport "cpu";
    cat $mailfile | /usr/sbin/ssmtp -v $to
    return;
  fi

  if [ $diskThreshold -gt $freeDisk ];
  then
    printMailProps;
    generateReport "mem";
    cat $mailfile | /usr/sbin/ssmtp -v $to
    return;
  fi
}

main() {
  initVariables;
  monitorResource;
  rm $mailfile
}
main;
