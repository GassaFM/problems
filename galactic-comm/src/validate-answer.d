// Author: Ivan Kazmenko (gassa@mail.ru)
module validate_answer;
import std.algorithm;
import std.exception;
import testlib;

pragma (lib, "testlib");

immutable int minN    =      1;
immutable int maxN    = 10_000;
immutable int codeLen =     50;

auto isPermutation (T) (T [] a)
{
	auto n = a.length;
	auto vis = new bool [n];
	foreach (c; a)
	{
		if (c < 0 || n <= c)
		{
			return false;
		}
		vis[c] = true;
	}
	return true;
}

void main (string [] args)
{
	initTestlib !(TestlibRole.validator) (args);

	auto n = inFile.read !(int) (minN, maxN, "n");
	inFile.skip ("\n");

	auto outputOrder = new int [n];
	foreach (i; 0..n)
	{
		outputOrder[i] = inFile.read !(int) (0, n - 1);
		inFile.skip (i + 1 < n ? " " : "\n");
	}
	if (!isPermutation (outputOrder))
	{
		quit (ExitCode.fail, "output order is not a permutation");
	}

	auto seed = inFile.readFree !(uint);
	inFile.skip ("\n");

	auto effects = new string [n];
	foreach (i, ref line; effects)
	{
		line = inFile.readln;
		if (line.length != codeLen)
		{
			quit (ExitCode.fail, "effect ", i,
			    " has length ", line.length,
			    " instead of ", codeLen);
		}
		if (!line.all !(c => 'a' <= c && c <= 'k'))
		{
			quit (ExitCode.fail, "effect ", i,
			    " has wrong format: `", line, "`");
		}
	}

	inFile.checkEof ();
}
