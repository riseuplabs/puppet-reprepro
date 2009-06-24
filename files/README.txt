Introduction
============

This is the Debian package repository of Koumbit. It is used for internal
distribution of locally built packages not yet part of Debian. Feel free to use
it for yourself, but it comes at no warranty, see http://wiki.koumbit.net/Beta
for more information.

How to use
==========

In your /etc/apt/source.list:

deb http://debian.koumbit.net/debian lenny main
deb-src http://debian.koumbit.net/debian lenny main

"lenny", of course, can be replaced by your distribution. Know that we usually
package straight for etch or lenny. Packages will likely not be available in
squeeze or sid.

Adding the archive key to your keyring
--------------------------------------

This archive self-signs packages uploaded to it (and packages uploaded are
verified against a whitelist of trusted uploaders) using OpenPGP (GnuPG, to be
more precise).

The key of the archive is in the key.asc file above, and it is signed with
another key you may be able to find a path to in key.asc.asc.

So in short, you should add the key using something like this:

wget http://debian.koumbit.net/debian/key.asc
wget http://debian.koumbit.net/debian/key.asc.asc
gpg -v key.asc.asc && apt-key add key.asc
apt-get update
