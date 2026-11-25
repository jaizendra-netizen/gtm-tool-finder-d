import std.stdio;
import gtm_tool_finder;

int main(string[] args)
{
	string kind;
	size_t limit = 20;
	string[] words;
	for (size_t i = 1; i < args.length; i++)
	{
		if (args[i] == "--kind" && i + 1 < args.length)
			kind = args[++i];
		else if (args[i] == "--limit" && i + 1 < args.length)
		{
			import std.conv : to;
			limit = args[++i].to!size_t;
		}
		else
			words ~= args[i];
	}
	import std.array : join;
	auto hits = search(words.join(" "), kind, limit);
	if (hits.length == 0)
	{
		writeln("Nothing found. Try a tool name like apollo or clay.");
		return 1;
	}
	foreach (h; hits)
		writefln("[%s] %s\n    %s", h.kind, h.name, h.url);
	return 0;
}
