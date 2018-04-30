// Author: Ivan Kazmenko (gassa@mail.ru)
module solution;
// version = IO_FILES
import std.algorithm;
import std.conv;
import std.range;
import std.stdio;
import std.string;

immutable string problemName = "galactic-comm";
immutable int lenMessage = 30;
immutable int lenCode    = 50;

string encode (string message)
{
	auto numOnes = message.count ('1');
	bool invert = (numOnes > lenMessage / 2);
	char [] code = '0'.repeat (lenCode).array;
	code[0] = (invert ? '1' : '0');
	int pos = 1;
	foreach (ref c; message)
	{
		if ((c == '1') ^ invert)
		{
			code[pos] = '1';
			pos += 2;
		}
		else
		{
			code[pos] = '0';
			pos += 1;
		}
	}
	return code.text;
}

string decode (string code)
{
	bool invert = (code[0] == '1');
	auto message = new char [lenMessage];
	int pos = 1;
	foreach (ref c; message)
	{
		if (code[pos] == '1')
		{
			c = '1' ^ invert;
			pos += 2;
		}
		else
		{
			c = '0' ^ invert;
			pos += 1;
		}
	}
	return message.text;
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
