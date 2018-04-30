// Author: Ivan Kazmenko (gassa@mail.ru)
module solution;
import std.algorithm, std.conv, std.stdio, std.string;

void main ()
{
	string s;
	while ((s = readln.strip) != "")
	{
		auto t = s.split;
		if (t[0] == "Alice")
		{
			writeln (t[1], "5");
		}
		else if (t[0] == "Carl")
		{
			writeln (11 - t[1][0..$ - 1].to !(int));
		}
		else
		{
			assert (false);
		}
	}
}
