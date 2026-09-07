"""Shared OOXML namespace helpers."""
from __future__ import annotations

from lxml import etree

NS = {
    "w": "http://schemas.openxmlformats.org/wordprocessingml/2006/main",
    "r": "http://schemas.openxmlformats.org/officeDocument/2006/relationships",
    "ct": "http://schemas.openxmlformats.org/package/2006/content-types",
    "pr": "http://schemas.openxmlformats.org/package/2006/relationships",
    "ds": "http://schemas.openxmlformats.org/officeDocument/2006/customXml",
    "b": "http://schemas.openxmlformats.org/officeDocument/2006/bibliography",
    "xml": "http://www.w3.org/XML/1998/namespace",
}

# Relationship types
RT_FOOTNOTES = "http://schemas.openxmlformats.org/officeDocument/2006/relationships/footnotes"
RT_CUSTOMXML = "http://schemas.openxmlformats.org/officeDocument/2006/relationships/customXml"
RT_CUSTOMXML_PROPS = (
    "http://schemas.openxmlformats.org/officeDocument/2006/relationships/customXmlProps"
)

# Content types
CT_FOOTNOTES = (
    "application/vnd.openxmlformats-officedocument.wordprocessingml.footnotes+xml"
)
CT_CUSTOMXML_PROPS = "application/vnd.openxmlformats-officedocument.customXmlProperties+xml"

BIBLIO_NS = NS["b"]


def qn(tag: str) -> str:
    """Resolve a ``prefix:local`` tag to a Clark-notation name."""
    prefix, local = tag.split(":", 1)
    return "{%s}%s" % (NS[prefix], local)


def w(tag: str) -> str:
    return "{%s}%s" % (NS["w"], tag)


def parse_xml(text: str) -> etree._Element:
    parser = etree.XMLParser(remove_blank_text=False, huge_tree=True)
    return etree.fromstring(text.encode("utf-8") if isinstance(text, str) else text, parser)


def serialize(el: etree._Element, standalone: bool = True) -> bytes:
    return etree.tostring(
        el, xml_declaration=True, encoding="UTF-8", standalone=standalone
    )
