# Sending mails from Linux


## Install the SSMTP utility

##### For Ubuntu

Run the below command on terminal:


>> sudo apt-get install ssmtp


##### CentOs/RedHat

Run the below command on terminal: 

>> sudo yum install ssmtp


## Configure files to send emails.

Before moving to the configuration we need to add our Linux user to mail group. Using below command.
>> usermod -a -G groupname username

Reason for doing it is the our user can read/write the configuration file as well as send the mails.


Open  /etc/ssmtp/ssmtp.conf mail configuration file and add below properties with it's proper values into it.

```
mailhub=smtp.gmail.com:587

AuthUser=myacocunt@gmail.com
AuthPass=mysecretpassword
AuthMethod=LOGIN
UseSTARTTLS=YES

hostname=gmail.com

```

In above example my mail server is gmail. You can configure the values as per your mail server.

Once the configuration is done lets send the mail using ssmtp uility.


## Send emails

This can be called as "Hello World" program of testing mail functionality. 

>> echo "Hello World" | ssmtp myfriendmail@gmail.com



##### Error may occur while :

 
>> Authorization failed (535 5.7.8 https://support.google.com/mail/?p=BadCredentials k62sm6623445qkc.95 - gsmtp)



To resolve the error make sure "Allow less secure app option is on for 'myacocunt@gmail.com' account.



