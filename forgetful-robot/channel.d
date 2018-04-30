// Author: Ivan Kazmenko (gassa@mail.ru)
// channel for problem "forgetful-robot"
module channel;
import testlib;

pragma (lib, "testlib");

immutable int minV =    1;
immutable int maxV = 1000;

void main (string [] args)
{
	initTestlib !(TestlibRole.channel) (args);

	auto encoded = outFile.read !(int) (minV, maxV, "encoded");
	outFile.checkEof ();
	auto delta = ansFile.readFree !(int);
	auto refined = encoded + delta;
	outFileToWrite.writeln ("Carl ", refined);
	quit (ExitCode.ok, encoded, " to ", refined);
}
