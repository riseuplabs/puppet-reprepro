#! /bin/sh
#
# This should be a startup script for inoticoming for reprepro, but it doesn't work well.
#
# For some reason, it doesn't log its progress to the logfile when started here, while the following works:
#
# /usr/bin/inoticoming  --logfile /srv/reprepro/logs/i.log /srv/reprepro/incoming/ --stderr-to-log --stdout-to-log  --suffix '.changes'  --chdir /srv/reprepro reprepro -b /srv/reprepro --waitforlock 100 processincoming local {} \;
#
# The arguments are very similar so I'm not sure what's wrong.
#
# skeleton	example file to build /etc/init.d/ scripts.
#		This file should be used to construct scripts for /etc/init.d.
#
#		Written by Miquel van Smoorenburg <miquels@cistron.nl>.
#		Modified for Debian
#		by Ian Murdock <imurdock@gnu.ai.mit.edu>.
#               Further changes by Javier Fernandez-Sanguino <jfs@debian.org>
#
# Version:	@(#)skeleton  1.9  26-Feb-2001  miquels@cistron.nl
#

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DAEMON=/usr/bin/inoticoming
NAME=inoticoming
DESC=inoticoming

test -x $DAEMON || exit 0

basedir=/srv/reprepro

LOGDIR=/var/log/drush
PIDFILE=/var/run/reprepro/$NAME.pid
USER=reprepro
GROUP=$USER
DODTIME=1                   # Time to wait for the server to die, in seconds
                            # If this value is set too low you might not
                            # let some servers to die gracefully and
                            # 'restart' will not work

DAEMON_OPTS="--pid-file $PIDFILE --logfile $basedir/logs/i.log $basedir/incoming/ --stderr-to-log --stdout-to-log --suffix '.changes' --chdir $basedir reprepro -b $basedir --waitforlock 100 processincoming local {} ;"

# Include defaults if available
if [ -f /etc/default/inoticoming ] ; then
	. /etc/default/inoticoming
fi

set -e

running_pid()
{
    # Check if a given process pid's cmdline matches a given name
    pid=$1
    name=$2
    [ -z "$pid" ] && return 1
    [ ! -d /proc/$pid ] &&  return 1
    cmd=`cat /proc/$pid/cmdline | tr "\000" "\n"|head -n 1 |cut -d : -f 1`
    # Is this the expected child?
    [ "$cmd" != "$name" ] &&  return 1
    return 0
}

running()
{
# Check if the process is running looking at /proc
# (works for all users)

    # No pidfile, probably no daemon present
    [ ! -f "$PIDFILE" ] && return 1
    # Obtain the pid and check it against the binary name
    pid=`cat $PIDFILE`
    running_pid $pid $DAEMON || return 1
    return 0
}

force_stop() {
# Forcefully kill the process
    [ ! -f "$PIDFILE" ] && return
    if running ; then
        kill -15 $pid
        # Is it really dead?
        [ -n "$DODTIME" ] && sleep "$DODTIME"s
        if running ; then
            kill -9 $pid
            [ -n "$DODTIME" ] && sleep "$DODTIME"s
            if running ; then
                echo "Cannot kill $LABEL (pid=$pid)!"
                exit 1
            fi
        fi
    fi
    rm -f $PIDFILE
    return 0
}

case "$1" in
  start)
	echo -n "Starting $DESC: "
	start-stop-daemon --start -c $USER:$GROUP --quiet --pidfile $PIDFILE \
		--exec $DAEMON -- $DAEMON_OPTS
        if running ; then
            echo "$NAME."
        else
            echo " ERROR."
        fi
	;;
  stop)
	echo -n "Stopping $DESC: "
	start-stop-daemon --stop -c $USER:$GROUP --quiet --pidfile $PIDFILE \
		--exec $DAEMON
	echo "$NAME."
	;;
  force-stop)
	echo -n "Forcefully stopping $DESC: "
        force_stop
        if ! running ; then
            echo "$NAME."
        else
            echo " ERROR."
        fi
	;;
  #reload)
	#
	#	If the daemon can reload its config files on the fly
	#	for example by sending it SIGHUP, do it here.
	#
	#	If the daemon responds to changes in its config file
	#	directly anyway, make this a do-nothing entry.
	#
	# echo "Reloading $DESC configuration files."
	# start-stop-daemon --stop --signal 1 --quiet --pidfile \
	#	/var/run/$NAME.pid --exec $DAEMON
  #;;
  force-reload)
	#
	#	If the "reload" option is implemented, move the "force-reload"
	#	option to the "reload" entry above. If not, "force-reload" is
	#	just the same as "restart" except that it does nothing if the
	#   daemon isn't already running.
	# check wether $DAEMON is running. If so, restart
	start-stop-daemon -c $USER:$GROUP --stop --test --quiet --pidfile \
		/var/run/$NAME.pid --exec $DAEMON \
	&& $0 restart \
	|| exit 0
	;;
  restart)
    echo -n "Restarting $DESC: "
	start-stop-daemon -c $USER:$GROUP --stop --quiet --pidfile \
		/var/run/$NAME.pid --exec $DAEMON
	[ -n "$DODTIME" ] && sleep $DODTIME
	start-stop-daemon -c $USER:$GROUP --start --quiet --pidfile \
		/var/run/$NAME.pid --exec $DAEMON -- $DAEMON_OPTS
	echo "$NAME."
	;;
  status)
    echo -n "$LABEL is "
    if running ;  then
        echo "running"
    else
        echo " not running."
        exit 1
    fi
    ;;
  *)
	N=/etc/init.d/$NAME
	# echo "Usage: $N {start|stop|restart|reload|force-reload}" >&2
	echo "Usage: $N {start|stop|restart|force-reload|status|force-stop}" >&2
	exit 1
	;;
esac

exit 0
