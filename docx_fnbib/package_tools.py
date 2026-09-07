"""Low-level helpers for attaching custom parts to a python-docx package.

python-docx has no public API for footnotes or bibliography parts, so we add
them through the ``docx.opc`` layer. On ``Document.save`` python-docx walks the
relationship graph and writes ``[Content_Types].xml`` overrides automatically,
so we only need to create the part and relate it.
"""
from __future__ import annotations

from docx.opc.constants import RELATIONSHIP_TYPE as RT
from docx.opc.package import OpcPackage
from docx.opc.packuri import PackURI
from docx.opc.part import Part
from lxml import etree

from .ooxml import serialize


def get_or_none(document, reltype: str) -> Part | None:
    try:
        return document.part.part_related_by(reltype)
    except KeyError:
        return None


def add_part(
    document,
    partname: str,
    content_type: str,
    reltype: str,
    root_el: etree._Element,
) -> Part:
    """Create a part from an lxml root and relate it to the document part."""
    package: OpcPackage = document.part.package
    uri = PackURI(partname)
    blob = serialize(root_el)
    part = Part(uri, content_type, package, blob)
    document.part.relate_to(part, reltype)
    return part


def replace_blob(part: Part, root_el: etree._Element) -> None:
    part._blob = serialize(root_el)


def part_xml(part: Part) -> etree._Element:
    return etree.fromstring(part.blob)


__all__ = ["get_or_none", "add_part", "replace_blob", "part_xml", "RT"]
