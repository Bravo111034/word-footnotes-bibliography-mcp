"""Bibliography source model + Word-native storage (customXml bibliography part)."""
from __future__ import annotations

import re
from dataclasses import dataclass, field, asdict
from typing import Any

from docx.opc.packuri import PackURI
from docx.opc.part import Part
from lxml import etree

from .ooxml import (
    BIBLIO_NS,
    CT_CUSTOMXML_PROPS,
    RT_CUSTOMXML,
    RT_CUSTOMXML_PROPS,
    qn,
)

B = BIBLIO_NS

# Word SourceType values we understand.
SOURCE_TYPES = {
    "Book",
    "BookSection",
    "JournalArticle",
    "ArticleInAPeriodical",
    "ConferenceProceedings",
    "Report",
    "DocumentFromInternetSite",
    "InternetSite",
    "Misc",
}


def _b(tag: str) -> str:
    return "{%s}%s" % (B, tag)


@dataclass
class Contributor:
    last: str = ""
    first: str = ""
    middle: str = ""
    corporate: str = ""

    @property
    def is_corporate(self) -> bool:
        return bool(self.corporate)

    def family_given(self) -> tuple[str, str]:
        return self.last, " ".join(x for x in (self.first, self.middle) if x)


@dataclass
class Source:
    tag: str
    type: str = "Book"
    authors: list[Contributor] = field(default_factory=list)
    editors: list[Contributor] = field(default_factory=list)
    translators: list[Contributor] = field(default_factory=list)
    title: str = ""
    year: str = ""
    month: str = ""
    day: str = ""
    publisher: str = ""
    city: str = ""
    journal: str = ""          # periodical / journal / site name
    volume: str = ""
    issue: str = ""
    pages: str = ""
    edition: str = ""
    doi: str = ""
    url: str = ""
    accessed: str = ""         # free-form "1 March 2024"
    note: str = ""

    # ---- serialization -------------------------------------------------
    def to_dict(self) -> dict[str, Any]:
        d = asdict(self)
        return d

    @classmethod
    def from_dict(cls, d: dict[str, Any]) -> "Source":
        def conv(items):
            out = []
            for it in items or []:
                if isinstance(it, str):
                    # "Last, First" or "Corporate Name"
                    if "," in it:
                        last, first = [p.strip() for p in it.split(",", 1)]
                        out.append(Contributor(last=last, first=first))
                    else:
                        out.append(Contributor(corporate=it.strip()))
                else:
                    out.append(Contributor(**it))
            return out

        d = dict(d)
        for k in ("authors", "editors", "translators"):
            d[k] = conv(d.get(k))
        d.setdefault("tag", _slug(d.get("title", "src")))
        allowed = {f.name for f in cls.__dataclass_fields__.values()}
        return cls(**{k: v for k, v in d.items() if k in allowed})

    # ---- Word XML ----------------------------------------------------
    def to_word_element(self) -> etree._Element:
        src = etree.Element(_b("Source"))
        _text(src, "Tag", self.tag)
        _text(src, "SourceType", self.type if self.type in SOURCE_TYPES else "Misc")
        _contrib_block(src, "Author", self.authors)
        _contrib_block(src, "Editor", self.editors)
        _contrib_block(src, "Translator", self.translators)
        _text(src, "Title", self.title)
        _text(src, "Year", self.year)
        _text(src, "Month", self.month)
        _text(src, "Day", self.day)
        # JournalName / PeriodicalTitle / InternetSiteTitle share self.journal
        if self.journal:
            if self.type == "JournalArticle":
                _text(src, "JournalName", self.journal)
            elif self.type in ("DocumentFromInternetSite", "InternetSite"):
                _text(src, "InternetSiteTitle", self.journal)
            else:
                _text(src, "PeriodicalTitle", self.journal)
        _text(src, "Volume", self.volume)
        _text(src, "Issue", self.issue)
        _text(src, "Pages", self.pages)
        _text(src, "Edition", self.edition)
        _text(src, "City", self.city)
        _text(src, "Publisher", self.publisher)
        _text(src, "DOI", self.doi)
        _text(src, "URL", self.url)
        _text(src, "YearAccessed", self.accessed)
        _text(src, "Comments", self.note)
        return src

    @classmethod
    def from_word_element(cls, el: etree._Element) -> "Source":
        def g(tag):
            node = el.find(_b(tag))
            return node.text or "" if node is not None else ""

        authors = _read_contrib_block(el, "Author")
        editors = _read_contrib_block(el, "Editor")
        translators = _read_contrib_block(el, "Translator")
        journal = g("JournalName") or g("PeriodicalTitle") or g("InternetSiteTitle")
        return cls(
            tag=g("Tag") or _slug(g("Title")),
            type=g("SourceType") or "Misc",
            authors=authors,
            editors=editors,
            translators=translators,
            title=g("Title"),
            year=g("Year"),
            month=g("Month"),
            day=g("Day"),
            publisher=g("Publisher"),
            city=g("City"),
            journal=journal,
            volume=g("Volume"),
            issue=g("Issue"),
            pages=g("Pages"),
            edition=g("Edition"),
            doi=g("DOI"),
            url=g("URL"),
            accessed=g("YearAccessed"),
            note=g("Comments"),
        )


def _slug(s: str) -> str:
    s = re.sub(r"[^A-Za-z0-9]+", "", s.title())
    return (s[:20] or "Source")


def _text(parent, tag, value):
    if value:
        etree.SubElement(parent, _b(tag)).text = str(value)


def _contrib_block(src, role, people):
    if not people:
        return
    role_el = etree.SubElement(src, _b(role))
    inner = etree.SubElement(role_el, _b(role))
    namelist = etree.SubElement(inner, _b("NameList"))
    for p in people:
        if p.is_corporate:
            etree.SubElement(namelist, _b("Corporate")).text = p.corporate
        else:
            person = etree.SubElement(namelist, _b("Person"))
            _text(person, "Last", p.last)
            _text(person, "First", p.first)
            _text(person, "Middle", p.middle)


def _read_contrib_block(src, role):
    outer = src.find(_b(role))
    if outer is None:
        return []
    namelist = outer.find(f".//{_b('NameList')}")
    if namelist is None:
        return []
    people = []
    for child in namelist:
        if child.tag == _b("Corporate"):
            people.append(Contributor(corporate=child.text or ""))
        elif child.tag == _b("Person"):
            people.append(
                Contributor(
                    last=(child.findtext(_b("Last")) or ""),
                    first=(child.findtext(_b("First")) or ""),
                    middle=(child.findtext(_b("Middle")) or ""),
                )
            )
    return people


# ---------------------------------------------------------------------------
# customXml storage
# ---------------------------------------------------------------------------
_PROPS_TMPL = (
    '<ds:datastoreItem xmlns:ds="http://schemas.openxmlformats.org/officeDocument/2006/customXml" '
    'ds:itemID="{{{itemid}}}">'
    '<ds:schemaRefs><ds:schemaRef ds:uri="%s"/></ds:schemaRefs>'
    "</ds:datastoreItem>" % B
)


def _iter_customxml_parts(document):
    for rel in document.part.rels.values():
        if rel.reltype == RT_CUSTOMXML and not rel.is_external:
            yield rel.target_part


def _find_sources_part(document):
    for part in _iter_customxml_parts(document):
        try:
            root = etree.fromstring(part.blob)
        except etree.XMLSyntaxError:
            continue
        if root.tag == _b("Sources"):
            return part, root
    return None, None


def _next_customxml_index(document) -> int:
    used = set()
    for part in document.part.package.iter_parts():
        m = re.match(r"/customXml/item(\d+)\.xml$", part.partname)
        if m:
            used.add(int(m.group(1)))
    i = 1
    while i in used:
        i += 1
    return i


def load_sources(document) -> list[Source]:
    _, root = _find_sources_part(document)
    if root is None:
        return []
    return [Source.from_word_element(el) for el in root.findall(_b("Source"))]


def save_sources(document, sources: list[Source]) -> None:
    root = etree.Element(_b("Sources"))
    root.set("SelectedStyle", "")
    root.set("StyleName", "")
    for s in sources:
        root.append(s.to_word_element())
    blob = etree.tostring(root, xml_declaration=True, encoding="UTF-8", standalone=True)

    part, existing_root = _find_sources_part(document)
    if part is not None:
        part._blob = blob
        return

    package = document.part.package
    idx = _next_customxml_index(document)
    item_uri = PackURI(f"/customXml/item{idx}.xml")
    props_uri = PackURI(f"/customXml/itemProps{idx}.xml")
    import uuid

    props_blob = (
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\r\n'
        + _PROPS_TMPL.format(itemid=str(uuid.uuid4()).upper())
    ).encode("utf-8")

    item_part = Part(item_uri, "application/xml", package, blob)
    props_part = Part(props_uri, CT_CUSTOMXML_PROPS, package, props_blob)
    item_part.relate_to(props_part, RT_CUSTOMXML_PROPS)
    document.part.relate_to(item_part, RT_CUSTOMXML)
