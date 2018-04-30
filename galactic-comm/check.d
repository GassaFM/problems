// Author: Ivan Kazmenko (gassa@mail.ru)
// checker for problem "galactic-comm"
module check;
import std.algorithm;
import testlib;

pragma (lib, "testlib");

immutable int minN       =      1;
immutable int maxN       = 10_000;
immutable int messageLen =     30;
immutable int codeLen    =     50;

void main (string [] args)
{
	initTestlib !(TestlibRole.checker) (args);

	// read input
	inFile.skip ("send\n");
	auto n = inFile.read !(int) (minN, maxN, "n");
	inFile.skip ("\n");
	auto inMessages = new string [n];
	foreach (ref line; inMessages)
	{
		line = inFile.readln;
	}

	// read participant's output (messages)
	auto outMessages = new string [n];
	foreach (i, ref line; outMessages)
	{
		line = outFile.readln;
		if (line.length != messageLen)
		{
			quit (ExitCode.pe, "message ", i,
			    " has length ", line.length,
			    " instead of ", messageLen);
		}
		if (!line.all !(c => c == '0' || c == '1'))
		{
			quit (ExitCode.pe, "message ", i,
			    " has wrong format: `", line, "`");
		}
	}
	outFile.checkEof ();

	// read instructions for channel (supplied via answer)
	auto nCheck = ansFile.read !(int) (minN, maxN, "nCheck");
	if (n != nCheck)
	{
		quit (ExitCode.fail, "n = ", n, ", nCheck = ", nCheck);
	}
	ansFile.skip ("\n");
	auto outputOrder = new int [n];
	foreach (i; 0..n)
	{
		outputOrder[i] = ansFile.read !(int) (0, n - 1);
	}

	// check messages
	foreach (i; 0..n)
	{
		if (outMessages[i] != inMessages[outputOrder[i]])
		{
			quit (ExitCode.wa, "out-message ", i + 1,
			    " != in-message ", outputOrder[i] + 1,
			    ": `", outMessages[i], "` != `",
			    inMessages[outputOrder[i]], "`");
		}
	}

	quit (ExitCode.ok, "n = ", n);
}
