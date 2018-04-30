// Author: Ivan Kazmenko (gassa@mail.ru)
// Generator for problem "galactic-comm"
module gen;
import std.algorithm;
import std.conv;
import std.exception;
import std.format;
import std.random;
import std.range;
import std.stdio;

immutable string testFormat = "%03d";
enum generateAnswers = true;

immutable int minN       =      1;
immutable int maxN       = 10_000;
immutable int messageLen =     30;
immutable int codeLen    =     50;

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

struct Test
{
	string [] messages;
	int [] outputOrder;
	uint seed;
	string [] effects;

	string comment;

	@property int n () const
	{
		return messages.length.to !(int);
	}

	void validate () const
	{
		enforce (minN <= n && n <= maxN);
		foreach (const ref line; messages)
		{
			enforce (line.length == messageLen);
			enforce (line.all !(c => c == '0' || c == '1'));
		}
		enforce (outputOrder.length == n);
		enforce (isPermutation (outputOrder));
		foreach (const ref line; effects)
		{
			enforce (line.length == codeLen);
			enforce (line.all !(c => 'a' <= c && c <= 'k'));
		}
	}

	void print (File f) const
	{
		f.writeln ("send");
		f.writeln (n);
		foreach (const ref line; messages)
		{
			f.writeln (line);
		}
	}

	void printAnswer (File f) const
	{
		f.writeln (n);
		f.writefln ("%(%s %)", outputOrder);
		f.writeln (seed);
		foreach (const ref line; effects)
		{
			f.writeln (line);
		}
	}

	string log () const
	{
		return format ("%s (n = %s)", comment, n);
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

Mt19937 rndLocal;
T rndValue (T) () {return uniform !(T) (rndLocal);}
T rndValue (T) (T lim) {return uniform (cast (T) (0), lim, rndLocal);}
T rndValue (T) (T lo, T hi) {return uniform (lo, hi, rndLocal);}
auto rndChoice (R) (R r) {return r[rndValue (cast (int) (r.length))];}

void rndShuffle (R) (R r)
{
	auto len = r.length.to !(int);
	foreach (i; 0..len)
	{
		int k = rndValue (i, len);
		r.swapAt (i, k);
	}
}

auto genRandomMessages (int cn, int p, int q)
{
	auto res = new string [cn];
	foreach (ref line; res)
	{
		foreach (i; 0..messageLen)
		{
			line ~= "01"[rndValue (p + q) < p];
		}
	}
	return res;
}

auto genRandomPermutation (int cn)
{
	auto res = cn.iota.array;
	rndShuffle (res);
	return res;
}

auto genRandomEffects (int cn, char lo, char hi)
{
	auto res = new string [cn];
	foreach (ref line; res)
	{
		foreach (i; 0..codeLen)
		{
			line ~= cast (char) (rndValue (lo, hi + 1));
		}
	}
	return res;
}

void main ()
{
	rndLocal.seed (192_543_012);

	tests ~= Test ([
	    "00".repeat (messageLen / 2).join,
	    "01".repeat (messageLen / 2).join,
	    "10".repeat (messageLen / 2).join,
	    "11".repeat (messageLen / 2).join,
	    ], [0, 1, 3, 2], 12345, [
	    "a".repeat (codeLen).join,
	    "k".repeat (codeLen).join,
	    "i".repeat (codeLen / 2).join ~ "c".repeat (codeLen / 2).join,
	    "f".repeat (codeLen).join,
	    ], "example test 1");

	tests ~= Test (["0".repeat (messageLen).join], [0], 1_000_000_123,
	    ["a".repeat (codeLen).join], "minimal test 1");

	foreach (nt, cn; [10, 100, 1000, maxN])
	{
		auto messages = genRandomMessages (cn, 1, 1);
		auto seed = rndValue !(uint);
		auto perm = cn.iota.array;
		auto effects = genRandomEffects (cn, 'f', 'f');
		tests ~= Test (messages, perm, seed, effects,
		    format ("%s-case id-perm random med-effect test %s",
		    cn, nt + 1));
	}

	{
		int cn = maxN;
		auto messages = genRandomMessages (cn, 1, 1);
		auto seed = rndValue !(uint);
		auto perm = cn.iota.array;
		auto effects = genRandomEffects (cn, 'a', 'a');
		tests ~= Test (messages, perm, seed, effects,
		    "random id-perm min-effect test");
	}

	{
		int cn = maxN;
		auto messages = genRandomMessages (cn, 1, 1);
		auto seed = rndValue !(uint);
		auto perm = genRandomPermutation (cn);
		auto effects = genRandomEffects (cn, 'a', 'a');
		tests ~= Test (messages, perm, seed, effects,
		    "random min-effect test");
	}

	{
		int cn = maxN;
		auto messages = genRandomMessages (cn, 1, 1);
		auto seed = rndValue !(uint);
		auto perm = genRandomPermutation (cn);
		auto effects = genRandomEffects (cn, 'k', 'k');
		tests ~= Test (messages, perm, seed, effects,
		    "random max-effect test");
	}

	{
		int cn = maxN;
		auto messages = genRandomMessages (cn, 1, 9);
		auto seed = rndValue !(uint);
		auto perm = cn.iota.retro.array;
		auto effects = genRandomEffects (cn, 'k', 'k');
		tests ~= Test (messages, perm, seed, effects,
		    "random mostly-0 max-effect test");
	}

	{
		int cn = maxN;
		auto messages = genRandomMessages (cn, 9, 1);
		auto seed = rndValue !(uint);
		auto perm = chain (cn.iota.drop (0).stride (2),
		    cn.iota.drop (1).stride (2)).array;
		auto effects = genRandomEffects (cn, 'k', 'k');
		tests ~= Test (messages, perm, seed, effects,
		    "random mostly-1 max-effect test");
	}

	{
		int cn = maxN;
		string [] messages;
		foreach (i; 0..cn / 2)
		{
			messages ~= format ("%0*b",
			    messageLen, i);
			messages ~= format ("%0*b",
			    messageLen, (1 << 30) - 1 - i);
		}
		auto seed = rndValue !(uint);
		auto perm = genRandomPermutation (cn);
		auto effects = genRandomEffects (cn, 'g', 'i');
		tests ~= Test (messages, perm, seed, effects,
		    "extremal heavy-effect test");
	}

	{
		int cn = maxN;
		string [] messages;
		foreach (i; 0..cn / 2)
		{
			messages ~= format ("%0*b",
			    messageLen, (1 << 30) - 1 - i).retro.text;
			messages ~= format ("%0*b",
			    messageLen, i).retro.text;
		}
		auto seed = rndValue !(uint);
		auto perm = genRandomPermutation (cn);
		auto effects = genRandomEffects (cn, 'b', 'e');
		tests ~= Test (messages, perm, seed, effects,
		    "inv-extremal light-effect test");
	}

	foreach (nt; 0..10)
	{
		int cn = maxN;
		auto messages = genRandomMessages (cn, 1, 1);
		auto seed = rndValue !(uint);
		auto perm = genRandomPermutation (cn);
		auto effects = genRandomEffects (cn, 'a', 'k');
		tests ~= Test (messages, perm, seed, effects,
		    format ("random smooth test %s", nt + 1));
	}

	foreach (nt; 0..10)
	{
		int cn = maxN;
		int p = rndValue (1, 5);
		int q = rndValue (1, 5);
		auto messages = genRandomMessages (cn, p, q);
		auto seed = rndValue !(uint);
		auto perm = genRandomPermutation (cn);
		char lo = cast (char) ('a' + rndValue (0, 11));
		char hi = cast (char) ('a' + rndValue (0, 11));
		if (hi < lo)
		{
			swap (lo, hi);
		}
		auto effects = genRandomEffects (cn, lo, hi);
		tests ~= Test (messages, perm, seed, effects,
		    format ("random parameters test %s", nt + 1));
	}

	printAllTests ();
}
