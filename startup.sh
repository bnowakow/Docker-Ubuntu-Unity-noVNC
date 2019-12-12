#!/bin/bash

if [ ! -f $HOME/.vnc/passwd ] ; then

    if  [ -z "$PASSWORD" ] ; then
        PASSWORD=`pwgen -c -n -1 12`
        echo -e "PASSWORD = $PASSWORD" > $HOME/password.txt
    fi

    echo "$USER:$PASSWORD" | chpasswd

    # Set up vncserver
    su $USER -c "mkdir $HOME/.vnc && echo '$PASSWORD' | vncpasswd -f > $HOME/.vnc/passwd && chmod 600 $HOME/.vnc/passwd && touch $HOME/.Xresources"
    chown -R $USER:$USER $HOME

    if [ ! -z "$SUDO" ]; then
        case "$SUDO" in
            [yY]|[yY][eE][sS])
                adduser $USER sudo
        esac
    fi

else

    VNC_PID=`find $HOME/.vnc -name '*.pid'`
    if [ ! -z "$VNC_PID" ] ; then
        vncserver -kill :1
        rm -rf /tmp/.X1*
    fi

fi

if [ ! -z "$NGROK" ] ; then
        case "$NGROK" in
            [yY]|[yY][eE][sS])
                su ubuntu -c "$HOME/ngrok/ngrok http 6080 --log $HOME/ngrok/ngrok.log --log-format json" &
                sleep 5
                NGROK_URL=`curl -s http://127.0.0.1:4040/status | grep -P "http://.*?ngrok.io" -oh`
                su ubuntu -c "echo -e 'Ngrok URL = $NGROK_URL/vnc.html' > $HOME/ngrok/Ngrok_URL.txt"
        esac
fi



cd /home/ubuntu
apt update
apt install -y wget cpio libxss1 openjdk-8-jre-headless
#wget https://download.code42.com/installs/agent/7.2.0/1641/install/CrashPlanSmb_7.2.0_1525200006720_1641_Linux.tgz
wget https://download.code42.com/installs/agent/7.4.0/566/install/CrashPlanSmb_7.4.0_1525200006740_566_Linux.tgz
echo -e "dupa\ndupa" | passwd
echo -e "dupa\ndupa" | passwd ubuntu
echo 'JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64/bin/"' >> /etc/environment
tar zxf CrashPlanSmb_7.4.0_1525200006740_566_Linux.tgz
cd crashplan-install
echo -e "\n\n\n\n\n\n\n\n\n\n\n\n" | ./install.sh
/usr/local/crashplan/bin/CrashPlanEngine start
cd /etc/ssl/certs/java
keytool -import -keystore cacerts -file crashplan-chain-pem.crt -storepass changeit
cd /home/ubuntu
cat password.txt 

/usr/bin/supervisord -n

