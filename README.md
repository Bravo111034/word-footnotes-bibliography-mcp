# word-footnotes-bibliography-mcp

> **Aura AI build-out in progress.** This repository is being grown into
> **Aura AI**, a voice-controlled AI research agent shipping as a Flutter
> app (mobile + desktop). The Flutter workspace lives under `packages/`
> and `apps/`; see [Aura AI (Flutter)](#aura-ai-flutter) below for its
> phased roadmap and current status. The original Python MCP server
> described below is unaffected and continues to work standalone.

A self-contained [Model Context Protocol](https://modelcontextprotocol.io)
server that adds **footnotes**, **in-text citations**, and a **bibliography /
references / works-cited** section to Microsoft Word `.docx` files — without
Word.

Styles: **APA 7**, **MLA 9**, **Chicago 17** (author-date and notes).
Transport: **stdio**.

> Prefer a Claude skill (SKILL.md + a CLI, no server) with the same
> capabilities? See the companion repo **word-footnotes-bibliography-skill**.

## What's in here

```
word-footnotes-bibliography-mcp/
├── server.py            the MCP server (10 tools)
├── docx_fnbib/          the engine (python-docx + lxml) — importable on its own
├── pyproject.toml       installs `docx-fnbib-mcp` console script
├── requirements.txt
├── examples/build_demo.py
└── tests/               pytest suite (13 tests)
```

## Install

```bash
git clone https://github.com/<you>/word-footnotes-bibliography-mcp
cd word-footnotes-bibliography-mcp
pip install -e .            # or: pip install -r requirements.txt
```

Requires Python 3.10+ and the `mcp` SDK v2 (`MCPServer`). For SDK v1, change the
import in `server.py` to `from mcp.server.fastmcp import FastMCP` — the tool API
is identical.

## Run

```bash
docx-fnbib-mcp            # console script (after pip install -e .)
python server.py         # or run the module directly
```

## Register with a client

```json
{
  "mcpServers": {
    "docx-fnbib": { "command": "docx-fnbib-mcp" }
  }
}
```

Without installing the console script:

```json
{
  "mcpServers": {
    "docx-fnbib": {
      "command": "python",
      "args": ["/absolute/path/to/word-footnotes-bibliography-mcp/server.py"]
    }
  }
}
```

## Tools

| Tool | Purpose |
|------|---------|
| `create_document` | new .docx with optional title + paragraphs |
| `document_outline` | list paragraphs as `{index, style, text}` (indices for the calls below) |
| `add_footnote` | footnote on a paragraph; `anchor` places the mark after a phrase |
| `list_footnotes` | existing footnotes `{id, text}` |
| `add_source` | add/replace a bibliography source (matched by `tag`) |
| `list_sources` / `remove_source` | manage the source store |
| `import_references` | bulk import BibTeX or CSL-JSON |
| `add_citation` | in-text citation (a footnote, for `chicago-notes`) |
| `add_bibliography` | References / Works Cited section |

Styles: `apa`, `mla`, `chicago-author-date`, `chicago-notes`.
Modes: `text` (formatted by the server) or `field` (Word `CITATION` /
`BIBLIOGRAPHY` fields the user refreshes in Word).

Paths resolve on the machine running the server; edits are in place unless an
`out` path is passed.

## Example session

```
create_document {path: "paper.docx", title: "Draft", paragraphs: ["A claim.", "Another point about Rome."]}
add_source      {path: "paper.docx", source: {tag: "Syme1939", type: "Book", authors: ["Syme, Ronald"], title: "The Roman Revolution", year: "1939", city: "Oxford", publisher: "Clarendon Press"}}
add_footnote    {path: "paper.docx", paragraph_index: 2, text: "Founded 753 BC.", anchor: "Rome"}
add_citation    {path: "paper.docx", paragraph_index: 1, tag: "Syme1939", style: "chicago-notes", page: "47"}
add_bibliography{path: "paper.docx", style: "chicago-author-date", heading: "Bibliography"}
```

## How it works (short version)

- **Footnotes** — creates `word/footnotes.xml`, the separator notes, the
  `FootnoteText` / `FootnoteReference` styles, and numbered reference marks.
  Reopen-safe: numbering continues from existing notes.
- **Sources** — stored in Word's native `customXml` bibliography part
  (`b:` namespace), so *References ▸ Manage Sources* in Word sees them.
- **Rendering** — `text` mode formats entries itself (italic titles, hanging
  indent, sorted); `field` mode writes Word fields and sets `SelectedStyle`.
  `chicago-notes` emits real footnotes.

## Run the tests

```bash
pip install -e ".[test]"
pytest
```

## Limitations

- `field` mode needs desktop Word to render; elsewhere fields show cached text.
- The `text` formatter covers common source types well but is not a full CSL
  engine.
- Endnotes: create as footnotes, then *Convert Notes* in Word.
- Verify important documents open cleanly in your target Word version.

## License

MIT — see [LICENSE](LICENSE).

---

## Aura AI (Flutter)

Aura AI is a voice-controlled AI research agent — chat, deep research,
memory, task orchestration, and publishing — shipping as a Flutter app
across mobile and desktop. It's being built in phases; **Phase 0
(Foundation)** is scaffolded here.

```
packages/aura_ui/        shared design system (tokens, theme, primitives)
apps/mobile/             Flutter app — iOS / Android
apps/desktop/            Flutter app — macOS / Windows / Linux
.github/workflows/       flutter-ci.yml — lint → test → build
```

### Phase 0 — Foundation (this commit)

- `AuraColors` / `AuraSpace` / `AuraRadius` / `AuraMotion` design tokens
  (`packages/aura_ui/lib/src/theme/aura_tokens.dart`)
- `AuraTheme.light` / `AuraTheme.dark`, full color-scheme coverage
- `AuraIntelligenceIndicator` — the 7-state animated signature widget
  (idle → thinking → searching → creating → executing → complete → error)
- Primitives: `AuraStatusBadge`, `AuraCard`, `AuraBorder`, `AuraGradientText`
- A widget catalog screen (`apps/mobile/lib/features/catalog`) for live UI QA
- CI: lint, test, and build (Android + iOS simulator) on every push

### Phase 1 — Auth, Home & Command Palette (this commit)

- `AuthController` (Riverpod `StateNotifier`) — persists a signed-in flag
  and onboarding completion via `shared_preferences`; scaffolded ahead of
  real Supabase email/Google auth
- Mobile flow: `SplashScreen` → `SignInScreen` → `OnboardingScreen` (4
  swipeable steps) → `HomeScreen`
- `HomeScreen` — greeting, `AuraCommandBar`, quick-action chips, Continue
  Working / Active Tasks rows, Recent Work grid
- `CommandPaletteOverlay` — full-screen ⌘K-style palette with recent
  commands and suggested actions
- `NotificationCenterScreen` — category-tabbed notifications (mocked data)
- Shared layout primitives added to `aura_ui`: `AuraCommandBar`,
  `AuraTopBar`, `AuraSidebar`
- Desktop: 3-region shell (`DesktopShell`) — sidebar + workspace + a
  collapsible context panel

### Running it

Requires the [Flutter SDK](https://docs.flutter.dev/get-started/install)
(not installed in this environment — these files haven't been built or run
here yet, only authored to match the expected project layout).

```bash
cd apps/mobile
flutter pub get
flutter run              # or: flutter test / flutter analyze
```

### What's next

Phase 2 (AI chat + multi-model engine) per the roadmap — see the project
roadmap artifact for the full phase breakdown.
