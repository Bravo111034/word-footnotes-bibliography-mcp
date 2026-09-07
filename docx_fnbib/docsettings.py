"""Document-level footnote properties written into ``word/settings.xml``.

Ensures every footnote is numbered continuously (1, 2, 3 ... across the whole
document) and rendered at the foot of the page where its mark appears,
regardless of what the source template's defaults were.
"""
from __future__ import annotations

from lxml import etree

from .ooxml import qn

_MATH_MATHPR = "{http://schemas.openxmlformats.org/officeDocument/2006/math}mathPr"

# In CT_Settings, <w:footnotePr> must sit before these siblings (schema order).
_INSERT_BEFORE = [
    "w:compat",
    "w:rsids",
    "w:themeFontLang",
    "w:clrSchemeMapping",
    "w:doNotAutoCompressPictures",
    "w:shapeDefaults",
    "w:decimalSymbol",
    "w:listSeparator",
]


def ensure_footnote_properties(document, pos: str = "pageBottom") -> None:
    settings = document.settings.element

    for old in settings.findall(qn("w:footnotePr")):
        settings.remove(old)

    fp = etree.Element(qn("w:footnotePr"))
    etree.SubElement(fp, qn("w:pos")).set(qn("w:val"), pos)
    etree.SubElement(fp, qn("w:numFmt")).set(qn("w:val"), "decimal")
    etree.SubElement(fp, qn("w:numStart")).set(qn("w:val"), "1")
    etree.SubElement(fp, qn("w:numRestart")).set(qn("w:val"), "continuous")

    anchor = None
    for name in _INSERT_BEFORE:
        node = settings.find(qn(name))
        if node is not None:
            anchor = node
            break
    if anchor is None:
        anchor = settings.find(_MATH_MATHPR)

    if anchor is not None:
        anchor.addprevious(fp)
    else:
        settings.append(fp)
