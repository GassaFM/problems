#!/bin/bash
source ./problem.sh
source ./tools.sh
./clean.sh

echo [$BASH_SOURCE: wiping]
clean $CHECKER
clean $CHANNEL
rm -f ../tests/$TEST_PATTERN{,.[a-z]}
rmdir ../tests
rm -f ../check{,.exe}
rm -f ../channel{,.exe}
rm -f gen.log

if [[ "$CUSTOM_WIPE" != "" ]] ; then
	rm -f $CUSTOM_WIPE
fi
