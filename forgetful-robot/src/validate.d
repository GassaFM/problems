// Author: Ivan Kazmenko (gassa@mail.ru)
module validate;
import testlib;

immutable int minA =  1;
immutable int maxA = 10;

void main (string [] args)
{
	initTestlib !(TestlibRole.validator) (args);

	inFile.skip ("Alice ");
	inFile.read !(int) (minA, maxA, "a");
	inFile.skip ("\n");
	inFile.checkEof ();
}
