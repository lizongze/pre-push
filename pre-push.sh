#!/bin/bash

NODE=`which node 2> /dev/null`
NODEJS=`which nodejs 2> /dev/null`
IOJS=`which iojs 2> /dev/null`
LOCAL="/usr/local/bin/node"
dir=`pwd`
curNode=$NODE

if [[ -n $NODE ]]; then
	curNode=$NODE
elif [[ -n $NODEJS ]]; then
	curNode=$NODEJS
elif [[ -n $IOJS ]]; then
	curNode=$NODEJS
elif [[ -x $LOCAL ]]; then
	curNode=$LOCAL
fi

projects=(
`$curNode -e "require('./rush.json').projects.forEach(item => console.log(item.projectFolder + '/'));"`
)
diffFiles=`git diff --name-only`
cd $dir

for project in ${projects[@]}
do
	echo $diffFiles | grep -q $project
	res=$?
	if [[ 0 -eq res ]]; then
		# hit
		offsetPath=`echo './'$project`
		cd $offsetPath
		"$curNode" -e "require('pre-push')" 2>dev>null
		res=$?
		if [[ $res -ne 0 ]]; then
		    echo "$offsetPath Error: Cannot find module 'pre-push'"
		else
			"$curNode" $("$curNode" -e "console.log(require.resolve('pre-push'))") $project
		fi
		cd $dir
	fi
done
