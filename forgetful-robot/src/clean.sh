#!/bin/bash
source ./problem.sh
source ./tools.sh

echo [$BASH_SOURCE: cleaning up]
clean $SOLUTION
clean $GENERATOR
clean $VALIDATOR
clean $ANSWER_VALIDATOR
rm -f $PROBLEM.{in,out}
rm -f $TEST_PATTERN{,.a}
