## Shell Scripting projects:

#### [Server Monitoring script](https://github.com/Krishwaidande/Shell-Scripting/blob/master/server-monitoring.sh).

This script monitors the memory, CPU, disk and ports of the server. It sends alert with proper report via email when it exceeds a decided threshold. This script can be configured to after certain time to monitor the resources. 

The report contains.
1. Total, used, free memory, used memory in (%).
2. CPU used/Ideal in (%).
3. Total, used , free disk space in (GB).
4. Top 10 CPU or Memory consuming processes.
5. Top 10 files by size.

With above functionality, it also monitors the ports of the server. If any port is open other than standerd ports like (22, 80, 443) then script sends an alert message saying the port is open.

Mail template:

![Mail-alert1](server-monitoring-alert-mail1.png)

![Mail-alert2](server-monitoring-alert-mail2.png)


#### [Migration of Oracle to MySQL](https://github.com/Krishwaidande/Shell-Scripting/blob/master/migrate-oracle-to-mysql.sh).

Working of the script:
1. Exports the Oracle table data into CSV file.
2. Generate the MySQL query to import the CSV data into MySQL tables.

Limitation: Currently script handles datatypes like int, varchar, date and datetime. Datatype like Blob are not handled by the script.

