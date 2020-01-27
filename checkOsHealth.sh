#!/bin/bash

init_variables() {
  appUrl=$1

  if [ -z "$appUrl" ]; then
     echo "Provide the application URL as command line arg to script.";
     echo "Run the script as ./checkOsHealth.sh <openspecimen url>";
     exit 0;
  fi

  retry_count=1;
  max_retry_count=10;
  openspecimen_logs="/home/user/app/openspecimen/data/logs"
  mailfile="/home/user/openspecimen/script/os-health-$(date +%Y-%m-%d).txt"
  touch $mailfile

  to="krishna@krishagni.com"
  from="krishna.jenkins@gmail.com"
  subject="Alert !! $(hostname) OpenSpecimen is down."
  contentType="text/html"
}

invoke_server_api() {
  wget -t 10 -T 60 --no-check-certificate -o "$HOME/openspecimen/script/applog"  $appUrl/rest/ng/config-settings/app-props
  rc=$?;
  if [ $rc -eq 0 ]
  then
    echo "App is running";
    rm $mailfile
    rm "$HOME/openspecimen/script/applog"
    rm "$HOME/app-props"
    exit 0;
  fi
}

printMailProps() {
  echo "To: $to" >> $mailfile
  echo "From: $from" >> $mailfile
  echo "Subject: $subject" >> $mailfile
  echo "Content-Type: $contentType" >> $mailfile
}

sendAlert() {
  echo "<html>" >> $mailfile
  echo "<body>" >> $mailfile
  echo "<p> Hi customer, </p>" >> $mailfile
  echo "<p> The OpenSpecimen server is down please check below shared os.log file to find reason. </p>" >> $mailfile
  echo "<br>" >> $mailfile
  echo "<h4> os.log file: </h4>" >> $mailfile
  tail -300 $openspecimen_logs/os.log >> $mailfile
  echo "<br>" >> $mailfile
  echo "<h4> OpenSpecimen Administrator </h4>" >> $mailfile 
  echo "<center> Contact on  <a href='support.krishagni.com'> support@krishagni.com </a> for any OpnSpecimen issues. </center>" >> $mailfile 
  echo "</body>"  >> $mailfile
  echo "</html>" >> $mailfile
  cat $mailfile | /usr/sbin/ssmtp -v $to
}

load_config_props() {
  if [ $retry_count -gt $max_retry_count ]
  then
    printMailProps;
    sendAlert;
    exit 0;
  fi
  invoke_server_api;
  sleep 10
  ((++retry_count));
  load_config_props;
}

main() {
  init_variables $1;
  load_config_props;
  rm $mailfile
}
main $1;
