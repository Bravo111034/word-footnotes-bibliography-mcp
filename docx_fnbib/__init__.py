"""docx_fnbib – footnotes and bibliography for Word (.docx) documents.

Pure python-docx + lxml engine that backs the MCP server in this repo.
Importable on its own if you want to script it without MCP.
"""
from __future__ import annotations

from . import api
from .footnotes import FootnoteManager, FootnoteInfo
from .formatting import STYLES, bibliography_entry, in_text_citation
from .sources import Contributor, Source, load_sources, save_sources

__version__ = "0.1.0"

__all__ = [
    "api",
    "FootnoteManager",
    "FootnoteInfo",
    "Source",
    "Contributor",
    "load_sources",
    "save_sources",
    "bibliography_entry",
    "in_text_citation",
    "STYLES",
]
