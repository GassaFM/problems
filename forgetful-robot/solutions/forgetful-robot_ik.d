// Author: Ivan Kazmenko (gassa@mail.ru)
module solution;
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
			writeln (t[1], "5");
		}
		else if (t[0] == "Carl")
		{
			writeln (t[1][0..$ - 1]);
		}
		else
		{
			assert (false);
		}
	}
}
