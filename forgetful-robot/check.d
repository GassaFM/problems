// Author: Ivan Kazmenko (gassa@mail.ru)
// checker for problem "forgetful-robot"
module check;
import testlib;

pragma (lib, "testlib");

void main (string [] args)
{
	initTestlib !(TestlibRole.checker) (args);

	inFile.skip ("Alice ");
	auto a = inFile.readFree !(int);
	auto res = outFile.readFree !(int);
	outFile.checkEof ();
	quit (res == a ? ExitCode.ok : ExitCode.wa,
	    "cont: ", res, ", jury: ", a);
}
