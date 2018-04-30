// Author: Ivan Kazmenko (gassa@mail.ru)
module solution;
// version = IO_FILES
import std.algorithm;
import std.conv;
import std.range;
import std.stdio;
import std.string;

immutable string problemName = "galactic-comm";
immutable int lenMessageBlock = 3;
immutable int lenCodeBlock    = 5;

string [string] fwd;
string [string] rev;

static this ()
{
	fwd["000"] = "00000";
	rev["00000"] = "000";

	fwd["001"] = "00010";
	rev["00010"] = "001";
	rev["00011"] = "001";

	fwd["010"] = "00100";
	rev["00100"] = "010";
	rev["00110"] = "010";

	fwd["011"] = "01000";
	rev["01000"] = "011";
	rev["01100"] = "011";

	fwd["100"] = "01010";
	rev["01010"] = "100";
	rev["01011"] = "100";
	rev["01110"] = "100";
	rev["01111"] = "100";

	fwd["101"] = "10000";
	rev["10000"] = "101";
	rev["11000"] = "101";

	fwd["110"] = "10010";
	rev["10010"] = "110";
	rev["10011"] = "110";
	rev["11010"] = "110";
	rev["11011"] = "110";

	fwd["111"] = "10100";
	rev["10100"] = "111";
	rev["10110"] = "111";
	rev["11100"] = "111";
	rev["11110"] = "111";
}

string encode (string message)
{
	return message.chunks (lenMessageBlock).map !(x => fwd[x.text]).join;
}

string decode (string code)
{
	return code.chunks (lenCodeBlock).map !(x => rev[x.text]).join;
}

void main ()
{
	version (IO_FILES)
	{
		stdin  = File (problemName ~ ".in",  "rt");
		stdout = File (problemName ~ ".out", "wt");
	}

	auto typeIsSend = (readln.strip == "send");
	auto tests = readln.strip.to !(int);
	foreach (test; 0..tests)
	{
		if (typeIsSend)
		{
			readln.strip.encode.writeln;
		}
		else
		{
			readln.strip.decode.writeln;
		}
	}
}
