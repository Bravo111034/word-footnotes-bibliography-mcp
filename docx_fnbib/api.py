"""File-level operations shared by the MCP server and the skill scripts.

Every function takes a ``.docx`` path, mutates it and saves in place unless an
``out`` path is given.
"""
from __future__ import annotations

import os
from typing import Any

import docx

from . import citations as _cit
from .bibtex import parse_bibtex, parse_csl_json
from .footnotes import FootnoteManager
from .formatting import STYLES
from .sources import Source, load_sources, save_sources

CITATION_MODES = ("text", "field")


# --------------------------------------------------------------------------
def _load(path: str):
    if not os.path.exists(path):
        raise FileNotFoundError(path)
    return docx.Document(path)


def _save(document, path: str, out: str | None) -> str:
    target = out or path
    os.makedirs(os.path.dirname(os.path.abspath(target)), exist_ok=True)
    document.save(target)
    return target


def _para(document, index: int):
    paras = document.paragraphs
    if not -len(paras) <= index < len(paras):
        raise IndexError(f"paragraph index {index} out of range (0..{len(paras) - 1})")
    return paras[index]


# --------------------------------------------------------------------------
# documents
# --------------------------------------------------------------------------
def create_document(path: str, title: str | None = None, paragraphs: list[str] | None = None) -> str:
    document = docx.Document()
    if title:
        document.add_heading(title, level=0)
    for text in paragraphs or []:
        document.add_paragraph(text)
    return _save(document, path, None)


def document_outline(path: str) -> list[dict[str, Any]]:
    document = _load(path)
    out = []
    for i, p in enumerate(document.paragraphs):
        out.append(
            {"index": i, "style": p.style.name if p.style else None, "text": p.text}
        )
    return out


# --------------------------------------------------------------------------
# footnotes
# --------------------------------------------------------------------------
def add_footnote(
    path: str,
    paragraph_index: int,
    text: str,
    *,
    anchor: str | None = None,
    out: str | None = None,
) -> dict[str, Any]:
    document = _load(path)
    para = _para(document, paragraph_index)
    fm = FootnoteManager(document)

    if anchor:
        if anchor not in para.text:
            raise ValueError(f"anchor {anchor!r} not found in paragraph {paragraph_index}")
        # place the reference immediately after the run that ends the anchor
        _insert_ref_after_anchor(para, fm, text, anchor)
        fid = fm.list_footnotes()[-1].id
    else:
        fid = fm.insert(para, text)

    saved = _save(document, path, out)
    return {"footnote_id": fid, "saved": saved, "paragraph_index": paragraph_index}


def _insert_ref_after_anchor(para, fm: FootnoteManager, text: str, anchor: str) -> None:
    from lxml import etree
    from .ooxml import qn

    fid = fm.add_footnote(text)
    acc = ""
    target_run = para.runs[-1] if para.runs else None
    for run in para.runs:
        acc += run.text
        if anchor in acc:
            target_run = run
            break
    r = etree.Element(qn("w:r"))
    rpr = etree.SubElement(r, qn("w:rPr"))
    etree.SubElement(rpr, qn("w:rStyle")).set(qn("w:val"), "FootnoteReference")
    ref = etree.SubElement(r, qn("w:footnoteReference"))
    ref.set(qn("w:id"), str(fid))
    target_run._r.addnext(r)


def list_footnotes(path: str) -> list[dict[str, Any]]:
    document = _load(path)
    return [
        {"id": f.id, "text": f.text} for f in FootnoteManager(document).list_footnotes()
    ]


# --------------------------------------------------------------------------
# sources
# --------------------------------------------------------------------------
def list_sources(path: str) -> list[dict[str, Any]]:
    return [s.to_dict() for s in load_sources(_load(path))]


def add_source(path: str, source: dict[str, Any], *, out: str | None = None) -> dict[str, Any]:
    document = _load(path)
    sources = load_sources(document)
    new = Source.from_dict(source)
    sources = [s for s in sources if s.tag != new.tag] + [new]
    save_sources(document, sources)
    saved = _save(document, path, out)
    return {"tag": new.tag, "count": len(sources), "saved": saved}


def remove_source(path: str, tag: str, *, out: str | None = None) -> dict[str, Any]:
    document = _load(path)
    sources = load_sources(document)
    kept = [s for s in sources if s.tag != tag]
    if len(kept) == len(sources):
        raise KeyError(f"no source with tag {tag!r}")
    save_sources(document, kept)
    saved = _save(document, path, out)
    return {"removed": tag, "count": len(kept), "saved": saved}


def import_references(
    path: str, data: str, fmt: str = "bibtex", *, out: str | None = None
) -> dict[str, Any]:
    document = _load(path)
    existing = {s.tag: s for s in load_sources(document)}
    parsed = parse_bibtex(data) if fmt == "bibtex" else parse_csl_json(data)
    for s in parsed:
        existing[s.tag] = s
    merged = list(existing.values())
    save_sources(document, merged)
    saved = _save(document, path, out)
    return {"imported": [s.tag for s in parsed], "count": len(merged), "saved": saved}


# --------------------------------------------------------------------------
# citations + bibliography
# --------------------------------------------------------------------------
def add_citation(
    path: str,
    paragraph_index: int,
    tag: str,
    *,
    style: str = "apa",
    mode: str = "text",
    page: str | None = None,
    prefix: str | None = None,
    out: str | None = None,
) -> dict[str, Any]:
    _validate(style, mode)
    document = _load(path)
    para = _para(document, paragraph_index)
    text = _cit.add_citation(
        document, para, tag, style=style, mode=mode, page=page, prefix=prefix
    )
    saved = _save(document, path, out)
    return {"citation": text, "style": style, "mode": mode, "saved": saved}


def add_bibliography(
    path: str,
    *,
    style: str = "apa",
    mode: str = "text",
    heading: str | None = "References",
    out: str | None = None,
) -> dict[str, Any]:
    _validate(style, mode)
    document = _load(path)
    n = _cit.add_bibliography(document, style=style, mode=mode, heading=heading)
    saved = _save(document, path, out)
    return {"entries": n, "style": style, "mode": mode, "saved": saved}


def _validate(style: str, mode: str) -> None:
    if style not in STYLES:
        raise ValueError(f"style must be one of {STYLES}")
    if mode not in CITATION_MODES:
        raise ValueError(f"mode must be one of {CITATION_MODES}")
