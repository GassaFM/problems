// Author: Ivan Kazmenko (gassa@mail.ru)
// channel for problem "galactic-comm"
module channel;
import std.algorithm;
import std.array;
import std.exception;
import std.random;
import std.stdio;
import testlib;

pragma (lib, "testlib");

immutable int minN       =      1;
immutable int maxN       = 10_000;
immutable int messageLen =     30;
immutable int codeLen    =     50;

void main (string [] args)
{
	initTestlib !(TestlibRole.channel) (args);

	// read input
	inFile.skip ("send\n");
	auto n = inFile.read !(int) (minN, maxN, "n");
	inFile.skip ("\n");
	auto messages = new string [n];
	foreach (ref line; messages)
	{
		line = inFile.readln;
	}

	// read participant's output (encoded)
	auto codes = new string [n];
	foreach (i, ref line; codes)
	{
		line = outFile.readln;
		if (line.length != codeLen)
		{
			quit (ExitCode.pe, "code ", i,
			    " has length ", line.length,
			    " instead of ", codeLen);
		}
		if (!line.all !(c => c == '0' || c == '1'))
		{
			quit (ExitCode.pe, "code ", i,
			    " has wrong format: `", line, "`");
		}
	}
	outFile.checkEof ();

	// read instructions for channel (supplied via answer)
	auto nCheck = ansFile.read !(int) (minN, maxN, "nCheck");
	enforce (n == nCheck);
	ansFile.skip ("\n");
	auto outputOrder = new int [n];
	foreach (i; 0..n)
	{
		outputOrder[i] = ansFile.read !(int) (0, n - 1);
	}
	auto seed = ansFile.readFree !(uint);
	ansFile.skip ("\n");
	auto effects = new string [n];
	foreach (i; 0..n)
	{
		effects[i] = ansFile.readln;
	}

	// create new codes (apply channel effect)
	auto rnd = Mt19937 (seed);
	auto newCodes = codes.map !(line => line.dup).array;
	foreach (i; 0..n)
	{
		foreach (pos; 1..codeLen)
		{
			if (codes[i][pos] == '0' &&
			    codes[i][pos - 1] == '1' &&
			    uniform (0, 10, rnd) < effects[i][pos] - 'a')
			{
				newCodes[i][pos] = '1';
			}
		}
	}

	// write new input for participant (refined)
	outFileToWrite.writeln ("receive");
	outFileToWrite.writeln (n);
	foreach (i; 0..n)
	{
		outFileToWrite.writeln (newCodes[outputOrder[i]]);
	}

	quit (ExitCode.ok, "n = ", n);
}
