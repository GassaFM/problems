// Author: Ivan Kazmenko (gassa@mail.ru)
module solution;
import std.conv;
import std.stdio;
import std.string;

void main ()
{
	string s;
	while ((s = readln.strip) != "")
	{
		auto t = s.split;
		if (t[0] == "Alice")
		{
			writeln (t[1].to !(int) * 10);
		}
		else if (t[0] == "Carl")
		{
			writeln ((t[1].to !(int) + 1) / 10);
		}
		else
		{
			assert (false);
		}
	}
}
