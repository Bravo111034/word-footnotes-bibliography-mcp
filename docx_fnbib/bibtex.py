"""Minimal BibTeX / CSL-JSON import to :class:`~docx_fnbib.sources.Source`.

Not a full parser: handles the common entry shape ``@type{key, field = {value},
...}`` with braces or quotes, and ``and``-separated author lists.
"""
from __future__ import annotations

import json
import re

from .sources import Contributor, Source

_TYPE_MAP = {
    "book": "Book",
    "inbook": "BookSection",
    "incollection": "BookSection",
    "article": "JournalArticle",
    "inproceedings": "ConferenceProceedings",
    "conference": "ConferenceProceedings",
    "techreport": "Report",
    "report": "Report",
    "online": "DocumentFromInternetSite",
    "misc": "Misc",
}


def _people(value: str) -> list[Contributor]:
    out = []
    for name in re.split(r"\s+and\s+", value.strip()):
        name = name.strip()
        if not name:
            continue
        if name.startswith("{") and name.endswith("}"):
            out.append(Contributor(corporate=name[1:-1]))
        elif "," in name:
            last, first = [p.strip() for p in name.split(",", 1)]
            out.append(Contributor(last=last, first=first))
        else:
            parts = name.split()
            out.append(Contributor(last=parts[-1], first=" ".join(parts[:-1])))
    return out


def _iter_entries(text: str):
    """Yield (etype, key, body) for each @type{...} block, brace-matched."""
    i = 0
    while True:
        at = text.find("@", i)
        if at == -1:
            return
        brace = text.find("{", at)
        if brace == -1:
            return
        etype = text[at + 1 : brace].strip().lower()
        depth, j = 1, brace + 1
        while j < len(text) and depth:
            c = text[j]
            if c == "{":
                depth += 1
            elif c == "}":
                depth -= 1
            j += 1
        inner = text[brace + 1 : j - 1]
        comma = inner.find(",")
        if comma != -1 and re.match(r"[^=\s]+$", inner[:comma].strip()):
            yield etype, inner[:comma].strip(), inner[comma + 1 :]
        i = j


def parse_bibtex(text: str) -> list[Source]:
    sources: list[Source] = []
    for etype, key, body in _iter_entries(text):
        fields: dict[str, str] = {}
        for fm in re.finditer(
            r"(\w+)\s*=\s*(\{(?:[^{}]|\{[^{}]*\})*\}|\"[^\"]*\"|[^,\n]+)", body
        ):
            k = fm.group(1).lower()
            v = fm.group(2).strip().strip(",").strip()
            if v and v[0] in "{\"" and v[-1] in "}\"":
                v = v[1:-1]
            fields[k] = v.strip()
        src = Source(tag=key, type=_TYPE_MAP.get(etype, "Misc"))
        src.authors = _people(fields.get("author", ""))
        src.editors = _people(fields.get("editor", ""))
        src.title = fields.get("title", "")
        src.year = fields.get("year", "")
        src.publisher = fields.get("publisher", "")
        src.city = fields.get("address", "")
        src.journal = fields.get("journal", "") or fields.get("booktitle", "")
        src.volume = fields.get("volume", "")
        src.issue = fields.get("number", "")
        src.pages = fields.get("pages", "").replace("--", "-")
        src.edition = fields.get("edition", "")
        src.doi = fields.get("doi", "")
        src.url = fields.get("url", "")
        src.note = fields.get("note", "")
        sources.append(src)
    return sources


def parse_csl_json(text: str) -> list[Source]:
    data = json.loads(text)
    if isinstance(data, dict):
        data = [data]
    out = []
    tmap = {
        "book": "Book",
        "chapter": "BookSection",
        "article-journal": "JournalArticle",
        "paper-conference": "ConferenceProceedings",
        "report": "Report",
        "webpage": "DocumentFromInternetSite",
    }
    for item in data:
        def names(field):
            res = []
            for n in item.get(field, []) or []:
                if "literal" in n:
                    res.append(Contributor(corporate=n["literal"]))
                else:
                    res.append(
                        Contributor(last=n.get("family", ""), first=n.get("given", ""))
                    )
            return res

        issued = item.get("issued", {}).get("date-parts", [[None]])
        year = str(issued[0][0]) if issued and issued[0] and issued[0][0] else ""
        out.append(
            Source(
                tag=item.get("id", "src"),
                type=tmap.get(item.get("type", ""), "Misc"),
                authors=names("author"),
                editors=names("editor"),
                title=item.get("title", ""),
                year=year,
                publisher=item.get("publisher", ""),
                city=item.get("publisher-place", ""),
                journal=item.get("container-title", ""),
                volume=str(item.get("volume", "")),
                issue=str(item.get("issue", "")),
                pages=str(item.get("page", "")),
                doi=item.get("DOI", ""),
                url=item.get("URL", ""),
            )
        )
    return out
