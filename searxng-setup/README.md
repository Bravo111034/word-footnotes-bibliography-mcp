# SearXNG – free web search for your AI agent (no API key)

## 1. Install Docker
Install **Docker Desktop** (Windows/Mac) or Docker Engine (Linux): https://docs.docker.com/get-docker/

## 2. Start SearXNG
Open a terminal in this folder and run:

    docker compose up -d

Then open http://localhost:8080 in your browser – you should see the search page.

## 3. Test the JSON API

    python test_search.py "hello world"

or open: http://localhost:8080/search?q=hello&format=json

## 4. Use it in your AI agent

**Option A – Python tool:** import `web_search` and `WEB_SEARCH_TOOL` from `searxng_tool.py`
and register it as a tool in your agent.

**Option B – MCP (Claude Desktop, Cursor, etc.):** use the community `mcp-searxng`
server (github.com/ihor-sokoliuk/mcp-searxng). Add to your MCP config (needs Node.js):

```json
{
  "mcpServers": {
    "searxng": {
      "command": "npx",
      "args": ["-y", "mcp-searxng"],
      "env": { "SEARXNG_URL": "http://localhost:8080" }
    }
  }
}
```

## Stop / update

    docker compose down
    docker compose pull && docker compose up -d

## Notes
- Port 8080 is bound to localhost only, so it's not exposed to your network.
- `searxng/settings.yml` enables the JSON format (off by default) and disables the rate limiter for local use.
- If some engines return few results, they may be temporarily rate-limiting you – SearXNG will use the others.
