"""SearXNG web-search tool for AI agents.

Plain function + a JSON tool schema you can register with any agent framework
(Anthropic/OpenAI tool calling, LangChain, etc.). No API key needed.
"""
import json, urllib.parse, urllib.request

SEARXNG_URL = "http://localhost:8080"

def web_search(query: str, max_results: int = 5, categories: str = "general") -> list[dict]:
    """Search the web through your local SearXNG and return compact results."""
    params = urllib.parse.urlencode({"q": query, "format": "json", "categories": categories})
    with urllib.request.urlopen(f"{SEARXNG_URL}/search?{params}", timeout=30) as r:
        data = json.load(r)
    return [
        {"title": x.get("title"), "url": x.get("url"), "snippet": x.get("content", "")}
        for x in data.get("results", [])[:max_results]
    ]

# Tool definition for LLM tool calling (Anthropic format; OpenAI uses "parameters" instead of "input_schema").
WEB_SEARCH_TOOL = {
    "name": "web_search",
    "description": "Search the web and return titles, URLs and snippets of the top results.",
    "input_schema": {
        "type": "object",
        "properties": {
            "query": {"type": "string", "description": "The search query"},
            "max_results": {"type": "integer", "description": "How many results (default 5)"},
        },
        "required": ["query"],
    },
}

if __name__ == "__main__":
    print(json.dumps(web_search("latest AI news"), indent=2))
