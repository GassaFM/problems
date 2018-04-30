#!/bin/bash
source ./problem.sh
source ./tools.sh
./clean.sh

echo [$BASH_SOURCE: compiling]
if $USE_GRADERS ; then
	compile_grader $SOLUTION
else
	compile $SOLUTION
fi
compile $GENERATOR
compile $VALIDATOR testlib.d
compile $ANSWER_VALIDATOR testlib.d
if $DO_CHECK ; then
	compile $CHECKER testlib.d
	compile $CHANNEL testlib.d
fi

echo [$BASH_SOURCE: generating tests]
if [ -e small.in ] ; then
	echo [handling small.in not supported]
	exit 1
fi
run $GENERATOR || exit 1

echo [$BASH_SOURCE: validating tests]
for t in $TEST_PATTERN ; do
	echo [$BASH_SOURCE: test $t]
	run $VALIDATOR <$t || exit 1
	run $ANSWER_VALIDATOR <$t.a || exit 1
done

#echo [$BASH_SOURCE: generating answers]
#for t in $TEST_PATTERN ; do
#	echo [$BASH_SOURCE: test $t]
#	rm -f $PROBLEM.{in,out}
#	cp $t $PROBLEM.in || exit 1
#	run $VALIDATOR <$PROBLEM.in || exit 1
#	if $IO_FILES ; then
#		run $SOLUTION || exit 1
#	else
#		run_io $SOLUTION $PROBLEM.in $PROBLEM.out || exit 1
#	fi
#	if $DO_CHECK ; then
##		run $CHECKER $PROBLEM.in $PROBLEM.out $PROBLEM.out || exit 1
#		run $CHECKER $PROBLEM.in $PROBLEM.out $PROBLEM.out
#	fi
#	cp $PROBLEM.out $t.a || exit 1
#done

echo [$BASH_SOURCE: moving tests to ../tests/]
if [ ! -e ../tests ] ; then
	mkdir ../tests
fi
mv $TEST_PATTERN $TEST_PATTERN.a ../tests/ || exit 1
mv check.exe ../ || exit 1
mv channel.exe ../ || exit 1

if $DO_CLEAN ; then
	./clean.sh
fi
