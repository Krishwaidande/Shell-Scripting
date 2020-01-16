# Sending mails from Linux


### Install the SSMTP utility

##### Ubuntu

Run the below command on terminal:


>> sudo apt-get install ssmtp


##### CentOs/RedHat

Run the below command on terminal: 

>> sudo yum install ssmtp


#### Configure files to send emails

Before moving to the configuration, we need to add our Linux user to the mail group. Using the below command.
>> usermod -a -G groupname username

The reason for doing it is our user can read/write the configuration file as well as send the mails.


Open /etc/ssmtp/ssmtp.conf configuration file and add below properties with its proper values.

```
mailhub=smtp.gmail.com:587

AuthUser=myacocunt@gmail.com
AuthPass=mysecretpassword
AuthMethod=LOGIN
UseSTARTTLS=YES

hostname=gmail.com

```

Once the configuration is done let's send the mail using ssmtp utility.

#### Send emails

This can be called as "Hello World" program of testing mail functionality. 

>> echo "Hello World" \| ssmtp myfriendmail@gmail.com



##### Error may occur while :

 
>> Authorization failed (535 5.7.8 https://support.google.com/mail/?p=BadCredentials k62sm6623445qkc.95 - gsmtp)


To resolve the error 
1. Make sure "Allow less secure app" option is on for 'myacocunt@gmail.com' account.
2. Special characters in password also may create a problem.
