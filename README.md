# Bash IRC Client
--------------------------------------
  This is just a bash bot turned into an IRC Client that is in development!!!
  Original code - https://gist.github.com/anonymous/9493e93c46f9a175aebb + https://github.com/TripleZer000/BashBot
--------------------------------------
## readme.md needs to be updated again and new instructions
## but the files here if you can read and understand them are almost the final version
## just one bug... the status line seems to screw up
## more testing needed to figure this out!!!
--------------------------------------
## How to use!!!
  - Not very user friendly atm!!! Will work on this
  - Only Does Single Channel MULTICHANNEL ON THE WAY!!!
  - After you type and enter something the STATUS: line finally appears
1. Configure bot.properties
  - If no password leave it as it is.
  - Really only need to edit server, channel, and nick.
2. Wait for it to connect all the way!!!
3. How to send a msg
INPUT> Type Anything here and hit enter!!!
--------------------------------------
## TO DO
1. Fix not connecting sometimes!!!
  - Possibly openssl cert!!! look into the openssl --help
2. Clean Up!!!
3. Create read input to variables for server, port, nick, and pass unpon startup!!!
  - Rework how u print the variables and join channel all to happen one after another??? maybe i think lol
4. Look into coloring!!! MAKE IT LOOK SICK!!!
5. Maybe add an up arrow feature to grab last msg!!!
6. Fix Multichannel code!
7. Add Join and Quit reads at bottom!
8. Fix status line not appearing right away?
9. Figure out if you can color echo -en '\e[2K\rINPUT> ' >&2
