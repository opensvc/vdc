#!/bin/bash

for ver in 1.8 1.9
do
	test -d $ver || mkdir $ver
	tmp=current.$ver.$$

	# download latest branch release
	curl -o $tmp https://repo.opensvc.com/rpms/${ver}/current

	# extract the filename
	fname=$(rpm -qp $tmp)

	# move in the branch dir and rename to the extracted fname
	mv -f $tmp $ver/$fname

	# create the links used by "nodemgr updatepkg"
	ln -sf $fname $ver/current
	ln -sf $ver/$fname current-$ver
done

