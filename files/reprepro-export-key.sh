#!/bin/sh
#
# This file is managed by Puppet. Do not edit, any changes will be overwritten!
#

set -e

BASEDIR="$1"
KEY=$(gpg --homedir "$BASEDIR/.gnupg" --with-colon --list-secret-keys | cut -d : -f 5 | head -n 1)

if [ -n "$KEY" ]; then
	TEMPFILE=$(mktemp --tmpdir="$BASEDIR")
	trap "rm -f '$TEMPFILE'" EXIT
	DESTFILE="$BASEDIR/key.asc"
	gpg --homedir "$BASEDIR/.gnupg" --export --armor "$KEY" > "$TEMPFILE"
	mv "$TEMPFILE" "$DESTFILE"
	chown reprepro:reprepro "$DESTFILE"
	chmod 0664 "$DESTFILE"
fi
