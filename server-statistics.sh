#/bin/bash

#Retrive memory information for report.
totalMem=$(free -m | awk '{ if (NR > 1) print $2 }' | head -1)
usedMem=$(free -m | awk '{ if (NR > 1) print $3 }' | head -1)
freeMem=$(free -m | awk '{ if (NR > 1) print $4+$7 }' | head -1)

memUsage=$(( (usedMem*100)/totalMem ))
cpuUsage=$(top -b -n 1| head -3 | grep "Cpu(s)" | awk '{print $2 + $4}' | cut -d"." -f1)

memThreshold=90
cpuThreshold=90

#Mail Properties
to="krishna@krishagni.com"
from="krishna.jenkins@gmail.com"
subject="Alert !! $(hostname) server statistics"
contentType="text/html"

setMailProps() {
  echo "To: $to"  
  echo "From: $from"  
  echo "Subject: $subject"  
  echo "Content-Type: $contentType"  
}

generateReport() {
  echo "<html>"  
  echo "<body>"  
  echo "<p> Hi customer, </p>"  
  echo "<p> The server is running on low memory ($freeMem MB). Below is detailed information about the memory usage.</p>"  

  echo "<table border=1 style=width:50%>"  
  echo "<tr> <td width=25%> Total Memory  </td> <td width=25%> $totalMem MB </td> </tr>"  
  echo "<tr> <td width=25%> Used Memory   </td> <td width=25%> $usedMem MB </td> </tr>"  
  echo "<tr> <td width=25%> Free Memory   </td> <td width=25%> $freeMem MB </td> </tr>"  
  echo "<tr> <td width=25%> Used Memory in (%) </td> <td width=25%>  $memUsage % </td> <tr>"  
  echo "</table>"  
  echo "<br>"  

  echo "<p> Below are the top 10 processes consuming more memory.</p>"  

  echo "<table border=1 style=width:100%>"  
  ps -eo pid,%mem,%cpu,cmd --sort=-%mem | head -10 | awk '{ print "<tr>" "<td width=10%>" $1 "</td>" "<td width=10%>" $2 "</td>" "<td width=10%>" $3 "</td>" "<td width=70%>" $4  $5 $6"</td>" "</tr>" }'   
  echo "</table>"  
  
  echo "<h4> OpenSpecimen Administrator </h4>"  
  echo "<center> Contact on  <a href='support.krishagni.com'> support@krishagni.com </a> for any OpnSpecimen issues. </center>"  
  echo "</body>"  
  echo "</html>"  
}

checkResourceAndSendMail() {
  if [[ $memUsage -gt $memThreshold ]];
  then
    setMailProps;
    generateReport;    
  fi

  if [[ $cpuUsage -gt $cpuThreshold ]];
  then
    echo "CPU Usage is at max"  
    echo -e "\n"  
  fi
}

main() {
  checkResourceAndSendMail;
}
main;

