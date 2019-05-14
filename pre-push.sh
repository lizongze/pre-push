#!/bin/bash

echoc() {
	# 输出黄色字
	echo -e "\n\033[33m $1 \033[0m\n"
}

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
curBranch=`git rev-parse --abbrev-ref HEAD`
git fetch origin $curBranch
diffFiles=`git diff HEAD origin/$curBranch --name-only`
cd $dir

index=0
for project in ${projects[@]}
do
	echo $diffFiles | grep -q $project
	res=$?
	if [[ 0 -eq res ]]; then
		let index++
		echoc "$project --changed"
	fi
done

if [[ 1 -ne $index ]]; then
	echoc "$index: changed"
	echoc "skip for not one project changed!"
	exit 0
fi

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
