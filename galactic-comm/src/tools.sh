#!/bin/bash

function compile()
{
	local NAME=${1%.*}
	local EXT=${1##*.}
	local BASE_NAME=${NAME##*[\\/]}
	echo [$BASH_SOURCE: compiling \<$NAME\>.\<$EXT\>]

	local GCC_OPTS="-O2 -Wall -B . -I ."
	if [[ ( $OS =~ WINDOWS ) || ( $OS =~ "Windows" ) ]] ; then
		local GCC_OPTS="$GCC_OPTS -Wl,--stack=536870912"
	fi
	local GPP_OPTS="$GCC_OPTS"
	local GCC_OPTS="-x c --std=c11 $GCC_OPTS"
	local GPP_OPTS="-x c++ --std=c++11 $GPP_OPTS"
	local DMD_OPTS="-O -wi -od."
	if [[ ( $OS =~ WINDOWS ) || ( $OS =~ "Windows" ) ]] ; then
		local DMD_OPTS="$DMD_OPTS -L/STACK:536870912"
	fi
	local DCC_OPTS="-cc -E."
	local JAVA_OPTS="-cp ."
	local FPC_OPTS=""

	if   [ $EXT == "c"    ] ; then
		gcc $GCC_OPTS $@ -o $BASE_NAME.exe || exit 1
	elif [ $EXT == "cpp"  ] ; then
		g++ $GPP_OPTS $@ -o $BASE_NAME.exe || exit 1
	elif [ $EXT == "d"    ] ; then
		dmd $DMD_OPTS $@ -of$BASE_NAME.exe || exit 1
		rm -f $BASE_NAME.obj $BASE_NAME.o || exit 1
	elif [ $EXT == "dpr"  ] ; then
		dcc32 $DCC_OPTS $@ || exit 1
		if [[ ( -e $BASE_NAME ) && ( ! -e $BASE_NAME.exe ) ]] ; then
			mv $BASE_NAME $BASE_NAME.exe
		fi
	elif [ $EXT == "java" ] ; then
		javac $JAVA_OPTS $@ || exit 1
		if [[ $NAME != $BASE_NAME ]] ; then
			mv $NAME{,\$*}.class ./
		fi
	elif [ $EXT == "pas"  ] ; then
		fpc $FPC_OPTS $@ -o$BASE_NAME.exe -FE. || exit 1
		rm -f $BASE_NAME.o || exit 1
	elif [ $EXT == "py"   ] ; then
		true
	else
		echo [$BASH_SOURCE: language not recognized]
		exit 1
	fi
}

function compile_grader()
{
	local NAME=${1%.*}
	local EXT=${1##*.}
	local BASE_NAME=${NAME##*[\\/]}
	echo [$BASH_SOURCE: compiling \<$NAME\>.\<$EXT\> with grader]

	local GRADER_DIR="../graders"
	local C_GRADER="$GRADER_DIR/grader.c"
	local CPP_GRADER="$GRADER_DIR/grader.cpp"
	local PAS_GRADER="$GRADER_DIR/grader.pas $GRADER_DIR/graderlib.pas"

	local GCC_OPTS="-O2 -Wall -B . -I ."
	if [[ ( $OS =~ WINDOWS ) || ( $OS =~ "Windows" ) ]] ; then
		local GCC_OPTS="$GCC_OPTS -Wl,--stack=536870912"
	fi
	local GCC_OPTS="-I $GRADER_DIR $GCC_OPTS"
	local GPP_OPTS="$GCC_OPTS"
	local GCC_OPTS="-x c --std=c11 $GCC_OPTS"
	local GPP_OPTS="-x c++ --std=c++11 $GPP_OPTS"
	local FPC_OPTS=""
	local FPC_OPTS="-Fi$GRADER_DIR $FPC_OPTS"

	if   [ $EXT == "c"    ] ; then
		gcc $GCC_OPTS $@ $C_GRADER -o $BASE_NAME.exe || exit 1
	elif [ $EXT == "cpp"  ] ; then
		g++ $GPP_OPTS $@ $CPP_GRADER -o $BASE_NAME.exe || exit 1
	elif [ $EXT == "pas"  ] ; then
		fpc $FPC_OPTS $@ $PAS_GRADER -o$BASE_NAME.exe || exit 1
		rm -f $BASE_NAME.o || exit 1
	else
		echo [$BASH_SOURCE: language not recognized]
		exit 1
	fi
}

function run()
{
	local NAME=${1%.*}
	local EXT=${1##*.}
	local BASE_NAME=${NAME##*[\\/]}
	echo [$BASH_SOURCE: running \<$NAME\>.\<$EXT\>]

	local JAVA_RUN_OPTS="-Xmx256M -Xss64M -cp ."

	if   [ $EXT == "java" ] ; then
		java $JAVA_RUN_OPTS $BASE_NAME ${@:2} || exit 1
	elif [ $EXT == "py"   ] ; then
		python $NAME.py ${@:2}
	elif [ -e $BASE_NAME.exe ] ; then
		./$BASE_NAME.exe ${@:2}
	else
		echo [$BASH_SOURCE: executable $BASE_NAME.exe not found]
		exit 1
	fi
}

function run_io()
{
	local NAME=${1%.*}
	local EXT=${1##*.}
	local BASE_NAME=${NAME##*[\\/]}
	echo [$BASH_SOURCE: running \<$NAME\>.\<$EXT\>]

	local JAVA_RUN_OPTS="-Xmx256M -Xss64M -cp ."

	if   [ $EXT == "java" ] ; then
		java $JAVA_RUN_OPTS $BASE_NAME ${@:4} <$2 >$3 || exit 1
	elif [ $EXT == "py"   ] ; then
		python $NAME.py ${@:4} <$2 >$3
	elif [ -e $BASE_NAME.exe ] ; then
		./$BASE_NAME.exe ${@:4} <$2 >$3
	else
		echo [$BASH_SOURCE: executable $BASE_NAME.exe not found]
		exit 1
	fi
}

function run_interactive()
{
	local NAME=${1%.*}
	local EXT=${1##*.}
	local BASE_NAME=${NAME##*[\\/]}
	echo [$BASH_SOURCE: running \<$NAME\>.\<$EXT\> with interactor]

	local JAVA_RUN_OPTS="-Xmx256M -Xss64M -cp ."

	if   [ $EXT == "java" ] ; then
		local RUN_COMMAND="java $JAVA_RUN_OPTS $BASE_NAME"
	elif [ $EXT == "py"   ] ; then
		local RUN_COMMAND="python $NAME.py"
	elif [ -e $BASE_NAME.exe ] ; then
		local RUN_COMMAND="./$BASE_NAME.exe"
	else
		echo [$BASH_SOURCE: executable $BASE_NAME.exe not found]
		exit 1
	fi

	rdmd ../runtwo/runtwo.d "../iserver.exe $2 $3" "$RUN_COMMAND"
#	../runtwo/runtwo.py "../iserver.exe $2 $3" "$RUN_COMMAND"
}

function clean()
{
	NAME=${1%.*}
	EXT=${1##*.}
	BASE_NAME=${NAME##*[\\/]}
	echo [$BASH_SOURCE: cleaning \<$NAME\>.\<$EXT\>]

	if   [ $EXT == "java" ] ; then
		rm -f $BASE_NAME{,\$*}.class
	elif [ $EXT == "py"   ] ; then
		true
	elif [ -e $BASE_NAME.exe ] ; then
		rm -f $BASE_NAME.exe
	else
		echo [$BASH_SOURCE: executable $BASE_NAME.exe not found]
	fi
}
