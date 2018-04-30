// Author: Ivan Kazmenko (gassa@mail.ru)
module validate_answer;
import testlib;

immutable int minDelta = -1;
immutable int maxDelta = +1;

void main (string [] args)
{
	initTestlib !(TestlibRole.validator) (args);

	inFile.read !(int) (minDelta, maxDelta, "delta");
	inFile.skip ("\n");
	inFile.checkEof ();
}
