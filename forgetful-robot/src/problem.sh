#!/bin/bash
IO_FILES=false
USE_GRADERS=false
PROBLEM=forgetful-robot
AUTHOR=ik
SUFFIX=
LANGUAGE=d
SOLUTION=../solutions/$PROBLEM\_$AUTHOR$SUFFIX.$LANGUAGE
GENERATOR=gen.d
VALIDATOR=validate.d
ANSWER_VALIDATOR=validate-answer.d
CHECKER=../check.d
CHANNEL=../channel.d
TEST_PATTERN=[0-9][0-9][0-9]
DO_CHECK=true
DO_CLEAN=true
CUSTOM_WIPE="encoded_.out refined_.in"
