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
	fwd["001"] = "00010";
	fwd["010"] = "00100";
	fwd["011"] = "01000";
	fwd["100"] = "01010";
	fwd["101"] = "10000";
	fwd["110"] = "10010";
	fwd["111"] = "10100";

	void recur (string src, string dst, int pos, bool prev)
	{
		if (pos == dst.length)
		{
			rev[dst] = src;
		}
		else
		{
			recur (src, dst, pos + 1, dst[pos] == '1');
			if (dst[pos] == '0' && prev)
			{
				recur (src, dst[0..pos] ~ '1' ~
				    dst[pos + 1..$], pos + 1, dst[pos] == '1');
			}
		}
	}

	foreach (src, dst; fwd)
	{
		recur (src, dst, 0, false);
	}

	debug {writefln ("%(%s: %s\n%)", rev);}
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
