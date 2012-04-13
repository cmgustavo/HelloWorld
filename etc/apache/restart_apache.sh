#!/bin/bash

CMD='apache2ctl'

if [[ "$OSTYPE" =~ "darwin" ]] 
then
	CMD='/usr/sbin/apachectl'
fi

pgrep apache2 && killall apache2
$CMD -k restart -f apache-light.conf
$CMD -k restart -f apache-heavy.conf
