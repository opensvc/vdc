#!/bin/bash

for ver in 1.8 1.9 2.0
do
	test -d $ver || mkdir $ver
	tmp=current.$ver.$$

	# download latest branch release
	curl -o $tmp https://repo.opensvc.com/deb/${ver}/current

	# extract the filename
	version=$(dpkg-deb --info $tmp | grep 'Version:' | awk '{print $2}')
	fname=$(echo opensvc-${version}_all.deb)

	# move in the branch dir and rename to the extracted fname
	mv -f $tmp $ver/$fname

	# create the links used by "nodemgr updatepkg"
	ln -sf $fname $ver/current
	ln -sf $fname $ver/current.deb
	ln -sf $ver/$fname current-$ver
	ln -sf $ver/$fname current-$ver.deb
done
