### Shell Scripting projects:

> Server Monitoring script.

This script monitors the memory, CPU, disk and ports of the server. It sends alert with proper report via email when it exceeds a decided threshold.

The report contains.
1. Total, used, free memory, used memory in (%).
2. CPU used/Ideal in (%).
3. Total, used , free disk space in (GB).
4. Top 10 CPU or Memory consuming processes.
5. Top 10 files by size.

With above functionality, it also monitors the ports of the server. If any port is open other than standerd ports like (22, 80, 443) then script sends an alert message saying the port is open.


> Migration of Oracle to MySQL.

Working of the script:
1. Exports the Oracle table data into CSV file.
2. Generate the MySQL query to import the CSV data into MySQL tables.

Limitation: Currently script handles datatypes like int, varchar, date and datetime. Datatype like Blob are not handled by the script.

