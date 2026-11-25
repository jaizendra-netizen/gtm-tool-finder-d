/// Search the OneGTMLab GTM tool directory (https://www.onegtmlab.dev/tool-directory):
/// API reviews of sales and marketing tools, head-to-head comparisons and GTM glossary terms.
/// The list ships inside the package, so it works offline and sends no data anywhere.
module gtm_tool_finder;

import std.algorithm : all, canFind, filter, sort, startsWith, map;
import std.array : array, split;
import std.json : parseJSON;
import std.string : toLower;
import std.uni : icmp;

/// One page of the directory. `kind` is Tool, Category, Comparison or Glossary.
struct Entry
{
	string name, kind, url, description;
}

/// The page kinds, in result order.
immutable kinds = ["Tool", "Category", "Comparison", "Glossary"];

private immutable indexJson = import("data.json");
private Entry[] cache;

/// Every entry of the directory.
Entry[] allEntries()
{
	if (cache.length == 0)
		foreach (r; parseJSON(indexJson).array)
			cache ~= Entry(r["n"].str, r["k"].str, r["u"].str, r["d"].str);
	return cache;
}

/// Entries whose name or description contains every word of `query`.
/// `kind` filters by Tool, Category, Comparison or Glossary (case-insensitive, empty means all).
Entry[] search(string query = "", string kind = "", size_t limit = 20)
{
	auto words = query.toLower.split;
	size_t[string] order;
	foreach (i, k; kinds)
		order[k] = i;
	auto hits = allEntries.filter!(e => (kind.length == 0 || icmp(e.kind, kind) == 0)
			&& words.all!(w => (e.name ~ " " ~ e.description).toLower.canFind(w))).array;
	size_t rank(Entry e) => (words.length && e.name.toLower.startsWith(words[0])) ? 0 : 1;
	// stable ordering: starts-with first, then kind order, then original position
	import std.algorithm : sort, SwapStrategy;
	hits.sort!((a, b) => rank(a) != rank(b) ? rank(a) < rank(b) : order[a.kind] < order[b.kind], SwapStrategy.stable);
	return hits.length > limit ? hits[0 .. limit] : hits;
}
