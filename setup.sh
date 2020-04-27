#!/bin/bash

setup_midnight_commander_for_user() {
	file=$1
	user=$2
	group=`id -gn $user`
	home=`getent passwd $user |cut -d: -f 6`

	path=".config/mc/ini"
	wrapper=/usr/share/mc/bin/mc-wrapper.sh

	if [ -d $home ]; then
		echo "setting up midnight commander configuration for user $user"
		mkdir -p `dirname $home/$path`
		cp -f $file $home/$path
		chown $user:$group $home/$path

		rc=$home/.bashrc

		if [ ! -f $rc ]; then
			touch $rc
		fi

		if [ "`grep 'alias mc' $rc`" = "" ] && [ -f $wrapper ]; then
			echo >>$rc
			echo "alias mc='. $wrapper'" >>$rc
		fi

		if [ "`grep mcedit $rc`" = "" ]; then
			echo >>$rc
			echo "export EDITOR=mcedit" >>$rc
		fi
	fi
}



curdir=`dirname $0`
if [ "$curdir" = "." ]; then curdir=`pwd`; fi
if [ "$curdir" = ".." ]; then echo "run this script from its directory"; exit 1; fi

echo "setting up midnight commander profiles"
cp -f $curdir/templates/mc.skin /usr/share/mc/skins/wheezy.ini

for U in `cat $curdir/config/users.list`; do
	if grep -q ^$U: /etc/passwd; then
		setup_midnight_commander_for_user $curdir/templates/mc.ini $U
	fi
done


loc="/usr/share/locale/pl/LC_MESSAGES"

if [ -f $loc/mc.mo ]; then
	echo "disabling midnight commander polish translation"
	mv $loc/mc.mo $loc/midc.mo
fi
