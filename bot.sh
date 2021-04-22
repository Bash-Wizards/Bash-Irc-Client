#!/bin/bash
#!/user/bin/perl

#useful variables
term_height=0
term_width=0
term_scroll_height=0
status_line_row=0
irc_host=''
irc_channel=''
irc_nick=''


function scroll_bottom() {
	echo -en '\e[999B'
}

#figure out terminal height, NOTE: moves cursor to bottom of terminal
function term_height() {
	echo -en '\e[999B\e[6n'
	read -s -r -d'['
	read -s -r -d';' term_height
	read -s -r -d'R' term_width
	echo -en '\e[999D'
}

#set the area the terminal is allowed to scroll in
function scroll_helper() {
	term_scroll_height=$((term_height-2))
	status_line_row=$((term_height-1))
	echo -en "\e[0;${term_scroll_height}r"
}

function bottom_line() {
	echo -en "\e[${term_height};0f"
}

function paste_data() {
	echo -en '\e7' "\e[${term_scroll_height};0f" '\n'
	echo -n " $1"
	echo -en '\e8'
}

function status_line() {
	echo -en '\e7' "\e[${status_line_row};0f" '\e[2K'
	echo -en "\e[4;44mSTATUS: $irc_nick in $irc_channel @ $irc_host\e[0m"
	echo -en '\e8'
}

function init_screen() {
	echo -en '\e[r' #reset screen RE-ADD MEEE FOR A HOTFIX
	term_height
	scroll_helper
	bottom_line
}

function read_line() {
while true
do
	while IFS='' read -r -t1
	do 
		status_line
		echo -en '\e[2K\r> '
		case "$REPLY" in
		( :reset )
			init_screen
		break
		;;
		( * )
			echo "$REPLY" >> $input	
		;;
		esac	
	done
done
}

. bot.properties
input=".bot.cfg"
echo "Starting session: $(date "+[%y:%m:%d %T]")">$log 
echo "NICK $nick" > $input 
echo "USER $user" >> $input
#echo "JOIN #$channel" >> $input
scroll_bottom
init_screen

read_line | tail -f $input | openssl s_client -connect $server:6697 | while read res
do
  # log the session
  echo "$(date "+[%y-%m-%d %T]")$res" >> $log
  # do things when you see output
  case "$res" in
    # respond to ping requests from the server
    PING*)
      echo "$res" | sed "s/I/O/" >> $input 
    ;;
    *"This nickname is regist"*) 
     echo "PRIVMSG NICKSERV :IDENTIFY $password" >> $input 
    ;;
    *"You are now logged in as $nick"*)
     echo "JOIN $channel" >> $input
    ;;
################### CONFIGURE THIS
	*"example"*)
	 echo "PRIVMSG $channel :this is the output" >> $input
	;;
################### ^^^^^^^^^^^^^^
    # run when a message is seen
    *PRIVMSG*)
      echo "$res"
      who=$(echo "$res" | perl -pe "s/:(.*)\!.*@.*/\1/")
      from=$(echo "$res" | perl -pe "s/.*PRIVMSG (.*[#]?([a-zA-Z]|\-)*) :.*/\1/")
      # "#" would mean it's a channel
      if [ "$(echo "$from" | grep '#')" ]
      then
        test "$(echo "$res" | grep ":$nick:")" || continue
        will=$(echo "$res" | perl -pe "s/.*:$nick:(.*)/\1/")
      else
        will=$(echo "$res" | perl -pe "s/.*$nick :(.*)/\1/")
        from=$who
      fi
      will=$(echo "$will" | perl -pe "s/^ //")
      com=$(echo "$will" | cut -d " " -f1)
      if [ -z "$(ls modules/ | grep -i -- "$com")" ] || [ -z "$com" ]
      then
       echo "TEST SHIT" 
##./modules/help.sh $who $from >> $input
        continue
      fi
      echo "TEST SHIT"
## ./modules/$com.sh $who $from $(echo "$will" | cut -d " " -f2-99) >> $input
    ;;
    *)
      echo "$res"
    ;;
  esac
done
