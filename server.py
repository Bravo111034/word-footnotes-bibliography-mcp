"""Standalone MCP server exposing the docx_fnbib engine over stdio.

Run:  python -m server        (from this folder)
or:   docx-fnbib-mcp          (after `pip install .`)

Requires the `mcp` SDK v2 (`MCPServer`). For SDK v1 replace `MCPServer`
with `mcp.server.fastmcp.FastMCP` – the tool API is identical.
"""
from __future__ import annotations

from typing import Any, Optional

from mcp.server.mcpserver import MCPServer

from docx_fnbib import api

mcp = MCPServer(
    "docx-fnbib",
    instructions=(
        "Add and manage footnotes and a bibliography in Word (.docx) files. "
        "Paragraphs are addressed by zero-based index (use `document_outline` "
        "to find them). Citation styles: apa, mla, chicago-author-date, "
        "chicago-notes. Citation modes: 'text' (formatted text we render) or "
        "'field' (Word CITATION/BIBLIOGRAPHY fields the user refreshes in Word)."
    ),
)


# --- documents ---------------------------------------------------------
@mcp.tool()
def create_document(
    path: str, title: Optional[str] = None, paragraphs: Optional[list[str]] = None
) -> dict[str, Any]:
    """Create a new .docx at `path` with an optional title and body paragraphs."""
    return {"saved": api.create_document(path, title=title, paragraphs=paragraphs)}


@mcp.tool()
def document_outline(path: str) -> list[dict[str, Any]]:
    """List every paragraph as {index, style, text} so you can target one."""
    return api.document_outline(path)


# --- footnotes -------------------------------------------------------
@mcp.tool()
def add_footnote(
    path: str,
    paragraph_index: int,
    text: str,
    anchor: Optional[str] = None,
    out: Optional[str] = None,
) -> dict[str, Any]:
    """Attach a footnote to a paragraph.

    If `anchor` is given, the footnote mark is placed right after that
    substring; otherwise it goes at the end of the paragraph. Creates
    word/footnotes.xml and the FootnoteText/FootnoteReference styles on first use.
    """
    return api.add_footnote(path, paragraph_index, text, anchor=anchor, out=out)


@mcp.tool()
def list_footnotes(path: str) -> list[dict[str, Any]]:
    """Return existing footnotes as {id, text}."""
    return api.list_footnotes(path)


# --- sources --------------------------------------------------------
@mcp.tool()
def add_source(path: str, source: dict[str, Any], out: Optional[str] = None) -> dict[str, Any]:
    """Add or replace a bibliography source (matched by `tag`).

    Source fields: tag, type (Book|BookSection|JournalArticle|
    ArticleInAPeriodical|ConferenceProceedings|Report|
    DocumentFromInternetSite|Misc), authors/editors/translators (list of
    {last,first,middle} or {corporate} or "Last, First" strings), title, year,
    month, day, publisher, city, journal, volume, issue, pages, edition, doi,
    url, accessed, note.
    """
    return api.add_source(path, source, out=out)


@mcp.tool()
def list_sources(path: str) -> list[dict[str, Any]]:
    """Return all sources stored in the document."""
    return api.list_sources(path)


@mcp.tool()
def remove_source(path: str, tag: str, out: Optional[str] = None) -> dict[str, Any]:
    """Delete the source with the given tag."""
    return api.remove_source(path, tag, out=out)


@mcp.tool()
def import_references(
    path: str, data: str, fmt: str = "bibtex", out: Optional[str] = None
) -> dict[str, Any]:
    """Bulk-import sources from a BibTeX (`fmt='bibtex'`) or CSL-JSON
    (`fmt='csl-json'`) string."""
    return api.import_references(path, data, fmt=fmt, out=out)


# --- citations + bibliography -------------------------------------
@mcp.tool()
def add_citation(
    path: str,
    paragraph_index: int,
    tag: str,
    style: str = "apa",
    mode: str = "text",
    page: Optional[str] = None,
    prefix: Optional[str] = None,
    out: Optional[str] = None,
) -> dict[str, Any]:
    """Append an in-text citation for `tag` to a paragraph.

    With style 'chicago-notes' the citation is rendered as a footnote instead
    of parenthetical text.
    """
    return api.add_citation(
        path, paragraph_index, tag, style=style, mode=mode, page=page,
        prefix=prefix, out=out,
    )


@mcp.tool()
def add_bibliography(
    path: str,
    style: str = "apa",
    mode: str = "text",
    heading: Optional[str] = "References",
    out: Optional[str] = None,
) -> dict[str, Any]:
    """Append a References / Works Cited section built from the stored sources."""
    return api.add_bibliography(path, style=style, mode=mode, heading=heading, out=out)


def main() -> None:
    mcp.run()


if __name__ == "__main__":
    main()
