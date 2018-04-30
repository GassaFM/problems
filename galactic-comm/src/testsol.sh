#!/bin/bash
if [[ ( "$1" == "" ) || ( ( $2 != "" ) && ( $2 != [b-z] ) ) ]] ; then
	echo [$BASH_SOURCE: usage: testsol.sh \<solution source\> [b-z]]
	exit 1
fi

source ./problem.sh
source ./tools.sh
./clean.sh

echo [$BASH_SOURCE: compiling]
if $USE_GRADERS ; then
	compile_grader $1
else
	compile $1
fi
if [ ! -e check.exe ] ; then
	cp ../check.exe . || exit 1
fi
if [ ! -e channel.exe ] ; then
	cp ../channel.exe . || exit 1
fi
compile $REFINED_VALIDATOR testlib.d

echo [$BASH_SOURCE: testing solution \<$1\>]
for t in ../tests/$TEST_PATTERN ; do
	echo [$BASH_SOURCE: test $t]
	rm -f $PROBLEM.{in,out}
	cp $t $PROBLEM.in || exit 1
	if [ -n ${CHANNEL+x} ] ; then
		run_io $1 $PROBLEM.in encoded_.out || exit 1
		run_io $CHANNEL encoded_.out /dev/stdout $PROBLEM.in refined_.in $t.a || exit 1
		run $REFINED_VALIDATOR <refined_.in || exit 1
		run_io $1 refined_.in $PROBLEM.out || exit 1
	elif $IO_FILES ; then
		run $1 || exit 1
	else
		run_io $1 $PROBLEM.in $PROBLEM.out || exit 1
	fi
	run $CHECKER $PROBLEM.in $PROBLEM.out $t.a
	if [ "$2" != "" ] ; then
		cp $PROBLEM.out $t.$2 || exit 1
	fi
done

echo [$BASH_SOURCE: cleaning up]
clean $1
rm -f check.exe
rm -f $PROBLEM.{in,out}
