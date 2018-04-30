// Author: Ivan Kazmenko (gassa@mail.ru)
module validate;
import std.algorithm;
import testlib;

pragma (lib, "testlib");

immutable int minN       =      1;
immutable int maxN       = 10_000;
immutable int messageLen =     30;

void main (string [] args)
{
	initTestlib !(TestlibRole.validator) (args);

	inFile.skip ("send\n");
	auto n = inFile.read !(int) (minN, maxN, "n");
	inFile.skip ("\n");
	auto messages = new string [n];
	foreach (i, ref line; messages)
	{
		line = inFile.readln;
		if (line.length != messageLen)
		{
			quit (ExitCode.fail, "message ", i,
			    " has length ", line.length,
			    " instead of ", messageLen);
		}
		if (!line.all !(c => c == '0' || c == '1'))
		{
			quit (ExitCode.fail, "message ", i,
			    " has wrong format: `", line, "`");
		}
	}
	inFile.checkEof ();
}
