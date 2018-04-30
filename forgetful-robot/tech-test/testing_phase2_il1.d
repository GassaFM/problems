// Author: Ivan Kazmenko (gassa@mail.ru)
module solution;
import core.thread, core.time, std.algorithm, std.stdio, std.string;

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
		Thread.sleep (999.seconds);
	}
}
