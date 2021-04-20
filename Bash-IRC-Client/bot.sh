#!/bin/bash
#!/user/bin/perl

term_input () {
while [ $sick -lt 10 ]; do
reply=$(zenity --entry --title="SEND MSG TO IRC" --text="Enter PRIVMSG below" --entry-text="PRIVMSG #channel :msg here" )
echo "$reply" >> $input
echo $reply
return 1
done
}

sick=0
. bot.properties
input="bot.cfg"
echo "Starting session: $(date "+[%y:%m:%d %T]")">$log 
echo "NICK $nick" > $input 
echo "USER $user" >> $input

tail -f $input | openssl s_client -connect $server:6697 | while read res
do

  # log the session
  echo "$(date "+[%y-%m-%d %T]")$res" >> $log
  # do things when you see output
  case "$res" in
    # respond to ping requests from the server
    PING*) echo "PONG ${res#PING}" >> $input 
    ;;
    *"This nickname is regist"*) 
     echo "PRIVMSG NICKSERV :IDENTIFY $password" >> $input 
    ;;
    *"You are now logged in as $nick"*)
     echo "JOIN $channel" >> $input
     echo "JOIN #bots" >> $input
    ;;
###################
    *'-speakzen'*)
term_input
    ;;
###################
    # run when a message is seen
    *PRIVMSG*)
      echo "$res"
    ;;
esac
done


