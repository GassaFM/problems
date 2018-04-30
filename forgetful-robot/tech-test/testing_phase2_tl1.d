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
		int a = 1;
		while (a % 3 != 0)
		{
			a = (a + 9) % 999_999_999;
		}
	}
}
