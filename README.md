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

### Phase 2 — AI Chat + Multi-model Engine (this commit)

- `packages/aura_ai_gateway` — unified `AiGateway` interface over
  `AiProvider` (Claude, GPT, Gemini, local/offline), streaming
  `Stream<String>` completions; `MockAiGateway` streams a canned reply so
  chat can be built and tested before real provider SDKs are wired in
- `ChatScreen` — conversation column, bare (non-bubble) Aura responses,
  thinking indicator while a reply streams, message composer
- `ModelSelector` — Auto / Fast / Balanced / Deep / Research / Creative /
  Custom, each mapped to a provider, with a live availability pill
- Riverpod `ChatController` streams gateway output token-by-token into the
  message list
- Home's quick-action chips and the Command Palette now open Chat with the
  tapped/typed prompt as the first message

### Phase 3 — Voice Control + Deep Research Agent (this commit)

- `packages/aura_voice` — provider-agnostic `VoicePipeline` (mic → partial/
  final transcript), an `IntentRouter` (transcript → research / chat /
  create / task / navigate, with a confidence score), and a
  `MockVoicePipeline` standing in for Whisper.cpp (offline) / Deepgram
  (online) until they're wired in
- `VoiceCommandOverlay` — animated Aura orb, live transcript, and a
  confirm/cancel step once an intent is routed; opened from Home's mic FAB
- `ResearchHomeScreen` — query input + depth control + Start Research
- `ActiveResearchScreen` — Plan / Report / Sources (the desktop spec's
  3-column layout, tabbed on mobile), backed by a `ResearchController`
  that scripts a plan, progressively "finds" sources, and streams a report
  — a placeholder for the real FastAPI + LangGraph agent (web search,
  document reading, cross-checking, report writing tools) and the RAG
  memory system described in the roadmap
- Home's "Research" quick action and voice research intents open
  `ResearchHomeScreen`; other voice intents open Chat with the transcript

### Phase 4 — Projects, Tasks, Memory & Create Studio (this commit)

- `HomeShell` — bottom-nav shell so Phase 4's screens are reachable
  (updated to the spec's Home / Chat / Create / Tasks / Library / More in
  Phase 5); Splash and Onboarding now route here instead of straight to
  `HomeScreen`
- `ProjectsScreen` — project cards (name, description, last activity,
  active-task count) opening `ProjectWorkspaceScreen`
- `ProjectWorkspaceScreen` — tabbed layout (Overview / Chat / Research /
  Files / Notes / Tasks / Memory / Published); Chat, Research, Tasks, and
  Memory tabs embed their real screens, the rest are placeholders
- `TaskCenterScreen` — Active / Scheduled / Awaiting Approval / Completed /
  Failed tabs with progress rows, opening `TaskDetailScreen` (objective,
  plan timeline, Pause/Stop)
- `MemoryManagerScreen` — User / Project / Saved Knowledge / Preferences
  sections with a search field (UI-only until the memory backend lands)
- `CreateStudioScreen` — hero input + an 11-category grid, each routing
  into Chat with a seeded prompt

**Deferred from the roadmap's P4 list, since deepened**: a dedicated
`Library`/file manager, `Image Studio`, and the agent-permissions UI for
consequential actions — see the "Deepening pass" section below.

### Phase 5 — Publishing, Analytics, Settings & Mobile (this commit)

- `PublishingHubScreen` — Drafts / Approved / Scheduled / Published /
  Failed tabs with content cards (the full workflow drawer and calendar
  view are a follow-up)
- `AnalyticsScreen` — Content Intelligence stat tiles; per the spec this
  screen must only ever show real numbers, so every stat renders "—"
  until a publishing platform is actually connected
- `IntegrationsScreen` — AI Models / Google / Publishing / Storage
  categories with connect/connected status pills (OAuth flows are UI-only
  for now)
- `SettingsScreen` — the full category list (General through Advanced);
  "Connected Apps" opens `IntegrationsScreen`, the rest open a shared
  placeholder detail screen
- `MoreScreen` — the mobile "More" sheet holding Publishing, Analytics,
  Integrations, Settings, and the dev widget catalog
- `HomeShell`'s bottom nav now matches spec §46: Home / Chat / Create /
  Tasks / Library / More (Library currently reuses `ProjectsScreen` until
  a dedicated file manager exists)

**Deferred from the roadmap's P5 list, partly deepened**: the publishing
workflow drawer is now built (see below); the content calendar, real
analytics charts, and the motion-system pass remain deferred — plus, as
always, app store submission, which needs a real Apple/Google developer
account.

### Deepening pass — Library, Image Studio, agent permissions, publishing workflow

- `LibraryScreen` — a real grid/list asset manager with a folder filter
  row (All / Documents / Images / Research / Notes) and a view toggle;
  `FilePreviewScreen` adds an "Ask Aura about this file" quick action.
  `HomeShell`'s Library tab now uses this instead of reusing Projects
  (Projects moved into `MoreScreen`, alongside Publishing/Analytics/etc.)
- `ImageStudioScreen` — prompt input, style/aspect-ratio controls, a
  generation canvas, and a variations history, backed by
  `ImageStudioController`. It "generates" color-swatch placeholders after
  a scripted delay — a real image model is a follow-up. Reachable from
  Create Studio's "Image" category.
- `AuraPermissionDialog` (new `aura_ui` primitive) — the agent-permissions
  UI from spec §44: a visually distinct confirmation for consequential
  actions. Wired into three real actions, not just as a demo: stopping a
  running task (`TaskDetailScreen`), forgetting a memory
  (`MemoryManagerScreen` — deletion is now real, in local state), and
  publishing content (`PublishingHubScreen`, both the quick "Approved ->
  Published" path and the full workflow below).
- `PublishingWorkflowDrawer` — the full Content -> Destinations -> Adapt
  -> Preview -> Approval -> Publish -> Verify flow (spec §37) as a
  bottom-sheet stepper, with the Approval step itself gated behind
  `AuraPermissionDialog`. Opened by tapping a Draft in `PublishingHubScreen`.

**Why analytics charts are still just "—"**: the spec is explicit that
this screen must only ever show real numbers, never invented ones. Adding
a charting library now would mean charting fake data, which is the exact
thing the spec rules out — so it stays deferred until there's a real
publishing integration to chart.

**Why the content calendar and motion-system pass are still deferred**:
both are genuinely new scope (calendar date logic; a systematic animation
pass across every screen) rather than wiring up something already built,
and didn't fit in this increment.

### Running it

Requires the [Flutter SDK](https://docs.flutter.dev/get-started/install)
(not installed in this environment — these files haven't been built or run
here yet, only authored to match the expected project layout).

```bash
cd apps/mobile
flutter pub get
flutter run              # or: flutter test / flutter analyze
```

### Known limitations — cannot be completed in this environment

A few roadmap items hit a hard wall here, not a scoping choice, and are
worth naming plainly rather than silently skipping:

- **Offline LLM inference (llama.cpp/Ollama) and on-device STT
  (Whisper.cpp)**: these need native binaries compiled per platform and
  bundled into the app; there's no Flutter SDK or native toolchain in this
  container to build or even smoke-test that integration.
- **Real AI provider calls (Anthropic/OpenAI/Gemini), Deepgram, Supabase,
  and every OAuth integration**: all need real API keys/credentials this
  environment doesn't have. The gateway/pipeline interfaces are built and
  tested against mocks so swapping in real credentials is a matter of
  implementing one class per provider, not a redesign.
- **App Store / Play Store submission**: needs a real Apple/Google
  developer account, signing certificates, and store listing assets —
  none of which exist here.
- **Actually running the app**: there's no Flutter SDK installed in this
  container, so nothing here has been run, only authored to match the
  expected project layout and verified through CI (which does have
  Flutter). See "Running it" above for the commands to try it yourself.

### What's next

All six roadmap phases (P0-P5) have a scaffolded pass, and Phase 4/5's
Library, Image Studio, agent-permissions, and publishing-workflow gaps
have been deepened. What remains is the content calendar, real analytics
charts, the motion-system pass, and the real backend integrations listed
above — see the project roadmap artifact for the full breakdown.
