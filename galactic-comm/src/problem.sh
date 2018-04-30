#!/bin/bash
IO_FILES=false
USE_GRADERS=false
PROBLEM=galactic-comm
AUTHOR=ik
SUFFIX=\_fibstr
LANGUAGE=d
SOLUTION=../solutions/$PROBLEM\_$AUTHOR$SUFFIX.$LANGUAGE
GENERATOR=gen.d
VALIDATOR=validate.d
ANSWER_VALIDATOR=validate-answer.d
REFINED_VALIDATOR=validate-refined.d
CHECKER=../check.d
CHANNEL=../channel.d
TEST_PATTERN=[0-9][0-9][0-9]
DO_CHECK=true
DO_CLEAN=true
CUSTOM_WIPE="encoded_.out refined_.in validate-refined.exe"
