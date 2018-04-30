// Author: Ivan Kazmenko (gassa@mail.ru)
// Generator for problem "forgetful-robot"
module gen;
import std.exception;
import std.format;
import std.stdio;

immutable string testFormat = "%03d";
enum generateAnswers = true;

immutable int minA =      1;
immutable int maxA =     10;
immutable int minDelta = -1;
immutable int maxDelta = +1;

struct Test
{
	int a;
	int delta;

	string comment;

	void validate () const
	{
		enforce (minA <= a && a <= maxA);
		enforce (minDelta <= delta && delta <= maxDelta);
	}

	void print (File f) const
	{
		f.writeln ("Alice ", a);
	}

	void printAnswer (File f) const
	{
		f.writeln (delta);
	}

	string log () const
	{
		return format ("%s (a = %s, delta = %s)", comment, a, delta);
	}
}

Test [] tests;

void printAllTests ()
{
	foreach (testNumber, test; tests)
	{
		test.validate ();
		auto testString = format (testFormat, testNumber + 1);
		auto f = File (testString, "wt");
		test.print (f);
		static if (generateAnswers)
		{
			auto g = File (testString ~ ".a", "wt");
			test.printAnswer (g);
		}
		writeln (testString, ": ", test.log ());
	}
}

void main ()
{
	int nt;

	void addAllDeltas (int ca, string fstr)
	{
		foreach (cd; [0, -1, +1])
		{
			tests ~= Test (ca, cd, format (fstr, nt + 1));
			nt += 1;
		}
	}

	nt = 0;
	immutable int ea = 3;
	addAllDeltas (ea, "example test %s");

	nt = 0;
	foreach (ca; minA..maxA + 1)
	{
		if (ca != ea)
		{
			addAllDeltas (ca, "general test %s");
		}
	}

	printAllTests ();
}
