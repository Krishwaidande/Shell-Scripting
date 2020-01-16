# Sending mails from Linux


>> Install the SSMTP utility

#### For Ubuntu

Run the below command on terminal:

``` 
sudo apt-get install ssmtp
```

#### CentOs/RedHat

Run the below command on terminal: 

```
sudo yum install ssmtp
```


>> Configure files to send emails.

Before moving to the configuration add your Linux user to mail group. It will provide access to edit mail configuration file.

Open  /etc/ssmtp/ssmtp.conf mail configuration file and add below properties into it.

```
mailhub=smtp.gmail.com:587

AuthUser=myacocunt@gmail.com
AuthPass=mysecretpassword
AuthMethod=LOGIN
UseSTARTTLS=YES

hostname=gmail.com

```

Once the configuration is done lets send the mail from command line.


>> Send emails

Hello world program of sending mail. Run the below command.

echo "Hello World" | ssmtp myfriendmail@gmail.com

That's it just check if your friend recieves the message.


##### Error may occur while :

``` 
Authorization failed (535 5.7.8 https://support.google.com/mail/?p=BadCredentials k62sm6623445qkc.95 - gsmtp)
```


To resolve the error make sure "Allow less secure app option is on for 'myacocunt@gmail.com' account.



