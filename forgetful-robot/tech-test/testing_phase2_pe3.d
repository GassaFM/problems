// Author: Ivan Kazmenko (gassa@mail.ru)
module solution;
import std.algorithm, std.stdio, std.string;

void main ()
{
	string s;
	while ((s = readln.strip) != "")
	{
		if (s.startsWith ("Alice"))
		{
			writeln ("123");
			continue;
		}
		writeln ("123");
		writeln ("123");
	}
}
