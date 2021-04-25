#!/bin/bash
#!/user/bin/perl

#useful variables
term_height=0
term_width=0
term_scroll_height=0
status_line_row=0

function paste_data() {
	echo -en '\e7' "\e[${term_scroll_height};0f" '\n' >&2
	echo -n " $1" >&2
	echo -en '\e8' >&2
}

function scroll_bottom() {
	echo -en '\e[999B' >&2
}

#figure out terminal height, NOTE: moves cursor to bottom of terminal
function term_height() {
	echo -en '\e[999B\e[6n' >&2
	read -s -r -d'[' >&2
	read -s -r -d';' term_height
	read -s -r -d'R' term_width >&2
	echo -en '\e[999D' >&2
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

function status_line() {
		echo -en '\e7' "\e[${status_line_row};0f" '\e[2K' >&2
		echo -en "\e[4;44mSTATUS: $nick in $channel @ $server\e[0m" >&2
		echo -en '\e8' >&2
}

function init_screen() {
	echo -en '\e[r' >&2 #reset screen helps for clearing your terminal upon boot
	term_height
	scroll_helper
	bottom_line
}

function read_line() {
local buff=''
while true
do
## Below is the read Line!!!
	while read -r -t1 REPLY
	do 
		echo -en '\e7' "\e[${status_line_row};0f" '\e[2K' >&2
		echo -en "\e[4;44mSTATUS: $nick @ $server\e[0m" >&2
		echo -en '\e8' >&2
		echo -en '\e[2K\rINPUT> ' >&2
## By deafault below is enabled
## Below is for single channel use where INPUT is as simple as typing "Hello World" and it will echo it to IRC
## Denote below lines and continue to next notes for multichannel config 
		echo "PRIVMSG $channel :$REPLY" >> $input	
			buff="<$nick> $channel :${REPLY}"
			paste_data "$buff"
## Below is the multichannel config (CURRENTLY UNDER DEVELOPMENT
#		case "$REPLY" in
#		( /JOIN* )
#			channel="${REPLY##*\ }"
#			echo "$REPLY" >> $input
#			;;
#		( * )
#			echo "PRIVMSG $channel :$REPLY" >> $input
#			;;
#		esac
#			buff="<$nick> ${REPLY}"
#			paste_data "$buff"
	done
done
}


. bot.properties
input=".bot.cfg"
local twig=''
echo "Starting session: $(date "+[%y:%m:%d %T]")">$log 
echo "NICK $nick" > $input 
echo "USER $user" >> $input
echo "JOIN $channel" >> $input

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
## ADD QUIT AND JOIN MSGS BELOW
    # run when a message is seen
    *PRIVMSG*)
     str=$(echo "$res" | perl -pe "s/(.*?)\\r/\1/")
     who=$(echo "$res" | perl -pe "s/:(.*)\!.*@.*/\1/")
     from=$(echo "$res" | perl -pe "s/.*PRIVMSG (.*[#]?([a-zA-Z]|\-)*) :.*/\1/")
     msg=$(echo "$str" | perl -pe "s/^.*? PRIVMSG .*? ://")
twig="<$who> $from :${msg}"
paste_data "$twig"
    ;;
  esac
done
