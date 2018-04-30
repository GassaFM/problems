// Author: Ivan Kazmenko (gassa@mail.ru)
module solution;
// version = IO_FILES
import std.conv;
import std.format;
import std.range;
import std.stdio;
import std.string;

immutable string problemName = "galactic-comm";
immutable int lenMessage = 30;
immutable int lenCode    = 50;

long [] f;

void prepare ()
{
	f = [1, 2];
	while (f.length <= lenCode)
	{
		f ~= f[$ - 2] + f[$ - 1];
	}
}

string encode (string message)
{
	auto value = message.to !(long) (2);
	auto code = new char [lenCode];
	foreach_reverse (pos, ref cur; code)
	{
		if (value >= f[pos])
		{
			cur = '1';
			value -= f[pos];
		}
		else
		{
			cur = '0';
		}
	}
	return code.retro.text;
}

string decode (string code)
{
	auto temp = code.retro.text;
	long value = 0;
	for (int pos = lenCode - 1; pos >= 0; pos--)
	{
		if (temp[pos] == '1')
		{
			value += f[pos];
			pos -= 1;
		}
	}
	return format ("%0*b", lenMessage, value);
}

void main ()
{
	version (IO_FILES)
	{
		stdin  = File (problemName ~ ".in",  "rt");
		stdout = File (problemName ~ ".out", "wt");
	}

	prepare ();

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
