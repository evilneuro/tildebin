#!/bin/sh
#
# /* $Id: getmaps,v 1.6 2006/03/19 15:33:27 neuro Exp $ */
# 
# update, (c) 2005 Niklas Lindblad, William Anderson
#         http://neuro.me.uk/projects/lugradio/et/
# 
# This script is used to fetch the maps for Enemy Territory that the 
# LUGRadio clan is playing.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

# ** set up constants for the mirror run:
#    the maps mirror URL
MAPSDL=http://clan.lugradio.zensoft.net/maps
#    the maps file list and MD5
MAPSFL=$MAPSDL/md5sums.txt
# soon, my pretty
# MAPSFL=http://meeja.net/mirrors/clan.lugradio.zensoft.net/maps/MD5SUMS

# ** find applications
echo "Checking dependencies ..."
SELF=`basename $0`
which wget && ERR=$? 
if [ $ERR -gt 0 ]
then
	echo "$SELF: wget required; please install"
	exit 1
fi
which md5sum && ERR=$?
if [ $ERR -gt 0 ] 
then
	echo "$SELF: md5sum required; please install"
	exit 1
fi

if [ ! -d ~/.etwolf/etmain ]
then
	mkdir -p ~/.etwolf/etmain
fi

cd ~/.etwolf/etmain
echo "Changing to `pwd`"

wget -qO /tmp/etmaplist.$$ $MAPSFL && ERR=$?
if [ $ERR -gt 0 ]
then
	echo "$SELF: couldn't download map list; bailing"
	exit 1 
fi
echo Map list downloaded!
for MAP in `cat /tmp/etmaplist.$$ | cut -d" " -f3-`
do
	echo Processing $MAP
	RETRY=0
	GOTFILE=0
	while [ $RETRY -lt 3 ]
	do
		echo "  Downloading map (if necessary)"
		wget -c -nv $MAPSDL/$MAP
		REMOTMAPMD5=`cat /tmp/etmaplist.$$ | grep $MAP | cut -d" " -f1`
		LOCALMAPMD5=`md5sum $MAP | cut -d" " -f1`
		if [ "$REMOTMAPMD5" != "$LOCALMAPMD5" ]
		then
			RETRY=`expr $RETRY + 1`
			GOTFILE=0
			echo "  MD5 sum mismatch for map $MAP, retrying (attempt $RETRY)"
			echo -n " $REMOTMAPMD5 vs $LOCALMAPMD5"
		else
			RETRY=3
			GOTFILE=1
		fi
	done
	if [ ! $GOTFILE ]
	then
		echo "  Couldn't download $MAP; removing"
		rm -f $MAP 
	fi
done

rm -f /tmp/etmaplist.$$
