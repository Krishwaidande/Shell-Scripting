#!/bin/bash

getTableNames() {
sqlplus -s 'test/password'  <<EOF

SET LINESIZE 200
SET FEEDBACK OFF
SET HEADING OFF
SET COLSEP ,;
SET ECHO OFF;

SPOOL table_names.txt
select table_name from user_tables;
SPOOL OFF

EXIT
EOF
sed -i 's/ //g' table_names.txt
sed -i 1d table_names.txt
}

generateCsv() {
if [ -z "$1" ]; then
  echo "No tables found.";
  exit;
fi

filename="$1.csv"
sqlplus -s 'test/password'  <<EOF

SET LINESIZE 200
SET FEEDBACK OFF
SET HEADING ON
SET COLSEP ,;
SET ECHO OFF;

SPOOL $filename
SELECT * FROM $1;
SPOOL OFF

EXIT
EOF
}

getColAndDataType() {
table_name=$1
sqlplus -s 'test/password'  <<EOF

SET LINESIZE 200
SET FEEDBACK OFF
SET HEADING OFF
SET COLSEP ,;
SET ECHO OFF;

SPOOL columns.txt
SELECT  column_name, data_type FROM all_tab_columns where table_name= '$table_name';
SPOOL OFF

EXIT
EOF

sed -i 's/ //g' columns.txt
sed -i 1d columns.txt
}

writeLoadDataSQL() {
table_name=$1;
mysql_data_dir="/usr/local/mysql/data";

echo -e "\nLOAD DATA INFILE '$mysql_data_dir/$table_name.csv' " >> LOAD_DATA.SQL
echo "INTO TABLE $table_name" >> LOAD_DATA.SQL
echo "FIELDS TERMINATED BY ',' " >> LOAD_DATA.SQL
echo "ENCLOSED BY '\"' " >> LOAD_DATA.SQL
echo "LINES TERMINATED BY '\n'" >> LOAD_DATA.SQL

cat columns.txt | cut -d',' -f2 | grep "DATE"
rc=$?
if [ "$rc" == "0" ]; then
  echo "IGNORE 3 LINES" >> LOAD_DATA.SQL
  writeColumns;
  writeDataConditions;
fi
echo ";" >> LOAD_DATA.SQL

}

insertComma() {
par=$1
par2=$2

if [ $par == $par2 ]; then
  return;
else
  echo -n "," >> LOAD_DATA.SQL
fi

}

writeColumns() {
file="columns.txt"

lines=$(cat $file | wc -l);
rowCount=1
varCount=1

echo -n "(" >> LOAD_DATA.SQL
while [ $rowCount -le $lines ]
do
  col=$(cat $file | head -$rowCount | tail -1 | cut -d',' -f1);
  dtype=$(cat $file | head -$rowCount | tail -1 | cut -d',' -f2);

  if [ "$dtype" == "DATE" ]; then
    echo -n " @var$varCount" >> LOAD_DATA.SQL
    insertComma $rowCount $lines;
    varCount=$((varCount + 1));
  else
    echo -n " $col" >> LOAD_DATA.SQL
    insertComma $rowCount $lines;
  fi
  rowCount=$((rowCount + 1));
done
echo -n ")" >> LOAD_DATA.SQL
}

writeDataConditions() {
file="columns.txt"

lines=$(cat $file | wc -l);
rowCount=1
varCount=1

while [ $rowCount -le $lines ]
do
  col=$(cat $file | head -$rowCount | tail -1 | cut -d',' -f1);
  dtype=$(cat $file | head -$rowCount | tail -1 | cut -d',' -f2);
 
  if [ "$dtype" == "DATE" ]; then
    if [ $varCount -eq 1 ]; then
      echo -e "\nset $col = IF(@var$varCount = '' , NULL, STR_TO_DATE(@var$varCount, '%d-%b-%y'))" >> LOAD_DATA.SQL    
    else
      echo ", set $col = IF(@var$varCount = '' , NULL, STR_TO_DATE(@var$varCount, '%d-%b-%y'))" >> LOAD_DATA.SQL
    fi
    varCount=$((varCount + 1));
  fi
  rowCount=$((rowCount + 1));
done
}


main() {
getTableNames;

while read tabname; do 
  generateCsv $tabname;
  getColAndDataType $tabname;
  writeLoadDataSQL $tabname;
done < table_names.txt

}
main;

