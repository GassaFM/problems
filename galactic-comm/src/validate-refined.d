// Author: Ivan Kazmenko (gassa@mail.ru)
module validate_refined;
import std.algorithm;
import testlib;

pragma (lib, "testlib");

immutable int minN    =      1;
immutable int maxN    = 10_000;
immutable int codeLen =     50;

void main (string [] args)
{
	initTestlib !(TestlibRole.validator) (args);

	inFile.skip ("receive\n");
	auto n = inFile.read !(int) (minN, maxN, "n");
	inFile.skip ("\n");
	auto codes = new string [n];
	foreach (i, ref line; codes)
	{
		line = inFile.readln;
		if (line.length != codeLen)
		{
			quit (ExitCode.fail, "code ", i,
			    " has length ", line.length,
			    " instead of ", codeLen);
		}
		if (!line.all !(c => c == '0' || c == '1'))
		{
			quit (ExitCode.fail, "code ", i,
			    " has wrong format: `", line, "`");
		}
	}
	inFile.checkEof ();
}
