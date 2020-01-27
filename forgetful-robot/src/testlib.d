// Author: Ivan Kazmenko (gassa@mail.ru)
module testlib;
import core.stdc.stdlib;
import std.algorithm;
import std.conv;
import std.exception;
import std.format;
import std.range;
import std.stdio;
import std.string;
import std.traits;
import std.utf;

File outFileToWrite;
File logFileToWrite;

version (ejudge)
{
	enum ExitCode {ok = 0, wa = 5, pe = 4, fail = 6,
	    points = 7, pcStart = 50};
}
else
{
	enum ExitCode {ok = 0, wa = 1, pe = 2, fail = 3,
	    points = 7, pcStart = 50};
}
bool outputXml;

string exitCodeName (int exitCode)
{
	if (exitCode == ExitCode.ok)
	{
		return "ok";
	}
	else if (exitCode == ExitCode.wa)
	{
		return "wrong answer";
	}
	else if (exitCode == ExitCode.pe)
	{
		return "presentation error";
	}
	else if (exitCode == ExitCode.fail)
	{
		return "fail";
	}
	else if (exitCode == ExitCode.points)
	{
		return "points";
	}
	else if (exitCode >= ExitCode.pcStart)
	{
		return format ("partially correct (%s)",
		    (exitCode - ExitCode.pcStart) / 200.0);
	}
	else
	{
		assert (false);
	}
}

void quitImpl (Args...) (int exitCode, string pointsText, Args args)
{
	if (outputXml)
	{
		logFileToWrite.writeln
		    ("<?xml version=\"1.0\" encoding=\"utf-8\"?>");
		if (pointsText != "")
		{
			pointsText = format (" points = \"%s\"", pointsText);
		}
		logFileToWrite.writefln ("<result outcome = \"%s\"%s>",
		    exitCodeName (exitCode), pointsText);
		if (Args.length > 0)
		{
			logFileToWrite.writeln (args);
		}
		logFileToWrite.writeln ("</result>");
	}
	else
	{
		logFileToWrite.writeln (exitCodeName (exitCode),
		    pointsText == "" ? "" : " " ~ pointsText,
		    Args.length ? " " : "", args);
	}
	exit (cast (int) exitCode);
}

void quit (Args...) (int exitCode, Args args)
{
	quitImpl (exitCode, "", args);
}

void quitPoints (Args...) (int exitCode, real points, Args args)
{
	auto pointsText = format ("%.10f", points).stripRight ("0");
	if (pointsText.back == '.')
	{
		pointsText ~= '0';
	}
	quitImpl (exitCode, pointsText, args);
}

File tryOpen (string name, string mode)
{
	try
	{
		File res = File (name, mode);
		return res;
	}
	catch (Exception e)
	{
		quit (ExitCode.pe, e.msg);
	}
	assert (false);
}

bool stringRead (Args...) (Args args)
{
	try
	{
		formattedRead (args);
		return true;
	}
	catch (Exception e)
	{
		return false;
	}
	assert (false);
}

string shorten (T) (T value, int maxPartLength = 10)
{
	auto res = value.text;
	if (res.length > maxPartLength * 2)
	{
		res = res[0..maxPartLength] ~ "..." ~
		    res[$ - maxPartLength..$];
	}
	return res;
}

class InputFileStream
{
	version (Windows)
	{
		enum newLineEncoded = "\r\n";
	}
	else
	{
		enum newLineEncoded = "\n";
	}
	static immutable char newLineChar = '\n';

	File file;
	bool wrongIsFail;
	bool validateBlanks;

	void initThis (bool wrongIsFail_, bool validateBlanks_)
	{
		version (Windows)
		{
			_setmode (file.fileno, _O_BINARY);
			version (CRuntime_DigitalMars) // recipe from:
			{ // https://issues.dlang.org/show_bug.cgi?id=4243
				import core.atomic : atomicOp;
				atomicOp !("&=")
				    (__fhnd_info[file.fileno], ~FHND_TEXT);
			}
		}
		wrongIsFail = wrongIsFail_;
		validateBlanks = validateBlanks_;
	}

	this (File file_, bool wrongIsFail_, bool validateBlanks_)
	{
		file = file_;
		initThis (wrongIsFail_, validateBlanks_);
	}

	this (string name, bool wrongIsFail_, bool validateBlanks_)
	{
		file = tryOpen (name, "rt");
		initThis (wrongIsFail_, validateBlanks_);
	}

	~this ()
	{
		file.close ();
	}

	void quit (Args...) (int exitCode, Args args)
	{
		if (wrongIsFail && exitCode != ExitCode.ok &&
		    exitCode < ExitCode.pcStart)
		{
			exitCode = ExitCode.fail;
		}
		.quit (exitCode, args);
	}

	void skip (string s)
	{
		foreach (i, dchar cCur; s)
		{
			void checkChar (dchar cCheck)
			{
				dchar cActual;
				file.readf ("%s", &cActual);
				if (cCheck != cActual)
				{
					quit (ExitCode.pe,
					    "can not skip character ", i,
					    " of string `", s, "`");
				}
			}

			try
			{
				if (cCur == newLineChar)
				{
					foreach (dchar cCurInner;
					    newLineEncoded)
					{
						checkChar (cCurInner);
					}
				}
				else
				{
					checkChar (cCur);
				}
			}
			catch (Exception e)
			{
				quit (ExitCode.pe, "got exception in skip: ",
				    e.msg);
			}
		}
	}

	void skipBlanks ()
	{
		try
		{
			if (!validateBlanks)
			{
				file.readf (" ");
			}
		}
		catch (Exception e)
		{
			quit (ExitCode.pe, "got exception in skipBlanks: ",
			    e.msg);
		}
	}

	void checkEof ()
	{
		skipBlanks ();
		dchar afterEnd;
		try
		{
			auto num = file.readf ("%s", &afterEnd);
			if (num > 0)
			{
				quit (ExitCode.pe,
				    "got character `", afterEnd,
				    "` instead of end-of-file");
			}
		}
		catch (Exception e)
		{
			quit (ExitCode.pe, "got exception in checkEof: ",
			    e.msg);
		}
	}

	T readFree (T, Args...) (lazy Args args)
	    if (isIntegral !(T))
	{
		skipBlanks ();
		T value;
		try
		{
			auto num = file.readf ("%d", &value);
			if (num != 1)
			{
				quit (ExitCode.pe, "failed to read " ~
				    "an integer value",
				    ["", ": "][args.length > 0], args);
			}
		}
		catch (Exception e)
		{
			quit (ExitCode.pe, "got exception: `", e.msg,
			    "` while reading",
			    ["", ": "][args.length > 0], args);
		}
		return value;
	}

	T read (T, Args...) (T lo, T hi, lazy Args args)
	    if (isIntegral !(T))
	{
		auto value = readFree !(T) ();
		if (!(lo <= value && value <= hi))
		{
			quit (ExitCode.wa, value,
			    " not in [", lo, "-", hi, "]",
			    ["", ": "][args.length > 0], args);
		}
		return value;
	}

	string readln ()
	{
		string res;
		try
		{
			res = file.readln ();
			validate (res);
		}
		catch (Exception e)
		{
			quit (ExitCode.pe, "got exception: `", e.msg,
			    "` in readln");
		}
		if (validateBlanks && res !is null &&
		    !res.endsWith (newLineEncoded))
		{
			quit (ExitCode.pe, "no newline at end of string");
		}
		while (!res.empty &&
		    (res[$ - 1] == '\r' || res[$ - 1] == '\n'))
		{
			res = res[0..$ - 1];
		}
		return res;
	}

	string readln () (string pattern)
	{ // templated, so that not using it = compiling faster
		import std.regex : matchAll, regex;
		string res = readln ();
		if (!matchAll (res, regex ("^" ~ pattern ~ "$")))
		{
			quit (ExitCode.pe, "string `", res,
			    "` does not match pattern `", pattern, "`");
		}
		return res;
	}

	auto byToken ()
	{
		return file.byLine.map !(splitter).joiner;
	}

	auto byLine ()
	{
		return new Lines (this);
	}
}

class Lines
{
	string currentLine;
	InputFileStream file;

	bool empty () const
	{
		return currentLine is null;
	}

	string front () const
	{
		return currentLine;
	}

	void popFront ()
	{
		currentLine = file.readln ();
	}

	this (InputFileStream file_)
	{
		file = file_;
		popFront ();
	}
}

InputFileStream inFile;
InputFileStream outFile;
InputFileStream ansFile;

enum TestlibRole {validator, checker, interactor, channel};

void initTestlib (TestlibRole role) (string [] args)
{
	// Polygon compatibility
	while (args.length > 1 && ["--testset", "--group",
	    "--testOverviewLogFileName"].canFind (args[1]))
	{
		args = args[0] ~ args[3..$];
	}

	logFileToWrite = stdout;

	static if (role == TestlibRole.validator)
	{
		enforce (args.length > 0, "validator usage: " ~
		    "<program> [infile]");
	}
	else static if (role == TestlibRole.checker)
	{
		enforce (args.length > 2, "checker usage: " ~
		    "<program> infile outfile [ansfile [logfile]]");
	}
	else static if (role == TestlibRole.interactor)
	{
		enforce (args.length > 1, "interactor usage: " ~
		    "<program> infile [outfile [ansfile [logfile]]]");
	}
	else static if (role == TestlibRole.channel)
	{
		enforce (args.length > 1, "channel usage: " ~
		    "<program> infile [outfile [ansfile [logfile]]]");
	}
	else static assert (false);

	if (args.length > 5)
	{
		if (args[5].toLower == "-appes")
		{
			outputXml = true;
		}
	}

	if (args.length > 4)
	{
		auto logFileName = args[4];
		logFileToWrite = tryOpen (logFileName, "wt");
	}
	else
	{
		// compatibility with Yandex.Contest and EJudge
		static if (role == TestlibRole.interactor ||
		    role == TestlibRole.channel)
		{
			logFileToWrite = stderr;
		}
	}

	if (args.length > 1)
	{
		auto inFileName = args[1];
		inFile = new InputFileStream (inFileName, true,
		    role == TestlibRole.validator);
	}
	else
	{
		inFile = new InputFileStream (stdin, true,
		    role == TestlibRole.validator);
	}
	if (args.length > 2)
	{
		auto outFileName = args[2];
		static if (role == TestlibRole.interactor ||
		    role == TestlibRole.channel)
		{
			outFileToWrite = tryOpen (outFileName, "wt");
			outFile = new InputFileStream (stdin, false, false);
		}
		else
		{
			outFile = new InputFileStream
			    (outFileName, false, false);
		}
	}
	// compatibility: for now, Yandex.Algorithm and EJudge
	// don't allow reading answer file from interactor
//	static if ((role != TestlibRole.interactor) &&
//	    (role != TestlibRole.channel))
	{
		if (args.length > 3)
		{
			auto ansFileName = args[3];
			ansFile = new InputFileStream
			    (ansFileName, true, false);
		}
	}
}
