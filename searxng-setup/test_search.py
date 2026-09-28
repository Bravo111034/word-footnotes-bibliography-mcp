"""Quick test of your local SearXNG JSON API.
Usage: python test_search.py "your query"
"""
import json, sys, urllib.parse, urllib.request

query = " ".join(sys.argv[1:]) or "brave search api"
url = "http://localhost:8080/search?" + urllib.parse.urlencode({"q": query, "format": "json"})
with urllib.request.urlopen(url, timeout=30) as r:
    data = json.load(r)

print(f"{len(data.get('results', []))} results for: {query}\n")
for i, res in enumerate(data.get("results", [])[:10], 1):
    print(f"{i}. {res.get('title')}\n   {res.get('url')}\n   engines: {', '.join(res.get('engines', []))}\n")
