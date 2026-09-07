"""Footnote engine.

python-docx cannot create footnotes, so this module manages the
``/word/footnotes.xml`` part directly and injects ``<w:footnoteReference>``
runs into body paragraphs.
"""
from __future__ import annotations

from dataclasses import dataclass

from docx.text.paragraph import Paragraph
from lxml import etree

from .ooxml import RT_FOOTNOTES, CT_FOOTNOTES, qn, w
from .package_tools import add_part, get_or_none, part_xml, replace_blob
from .styles import ensure_styles
from .docsettings import ensure_footnote_properties

_W = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"

_SKELETON = f"""<w:footnotes xmlns:w="{_W}">
  <w:footnote w:type="separator" w:id="-1">
    <w:p><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto"/></w:pPr>
      <w:r><w:separator/></w:r></w:p>
  </w:footnote>
  <w:footnote w:type="continuationSeparator" w:id="0">
    <w:p><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto"/></w:pPr>
      <w:r><w:continuationSeparator/></w:r></w:p>
  </w:footnote>
</w:footnotes>"""


@dataclass
class FootnoteInfo:
    id: int
    text: str


class FootnoteManager:
    def __init__(self, document):
        self.document = document
        self._part = get_or_none(document, RT_FOOTNOTES)
        if self._part is None:
            root = etree.fromstring(_SKELETON.encode("utf-8"))
            self._part = add_part(
                document,
                "/word/footnotes.xml",
                CT_FOOTNOTES,
                RT_FOOTNOTES,
                root,
            )
            self._root = root
        else:
            self._root = part_xml(self._part)
        ensure_styles(document, ["FootnoteText", "FootnoteReference"])
        ensure_footnote_properties(document)

    # -- internals -------------------------------------------------------
    def _footnote_els(self):
        return self._root.findall(qn("w:footnote"))

    def _real_ids(self) -> list[int]:
        ids = []
        for fn in self._footnote_els():
            if fn.get(qn("w:type")):
                continue
            v = fn.get(qn("w:id"))
            if v is not None:
                ids.append(int(v))
        return ids

    def next_id(self) -> int:
        ids = self._real_ids()
        return max(ids) + 1 if ids else 1

    def _flush(self):
        replace_blob(self._part, self._root)

    # -- public API ----------------------------------------------------
    def add_footnote(self, text: str) -> int:
        fid = self.next_id()
        fn = etree.SubElement(self._root, qn("w:footnote"))
        fn.set(qn("w:id"), str(fid))
        p = etree.SubElement(fn, qn("w:p"))
        ppr = etree.SubElement(p, qn("w:pPr"))
        etree.SubElement(ppr, qn("w:pStyle")).set(qn("w:val"), "FootnoteText")

        r1 = etree.SubElement(p, qn("w:r"))
        rpr = etree.SubElement(r1, qn("w:rPr"))
        etree.SubElement(rpr, qn("w:rStyle")).set(qn("w:val"), "FootnoteReference")
        etree.SubElement(r1, qn("w:footnoteRef"))

        r2 = etree.SubElement(p, qn("w:r"))
        t = etree.SubElement(r2, qn("w:t"))
        t.set(qn("xml:space"), "preserve")
        t.text = " " + text
        self._flush()
        return fid

    def add_reference(self, paragraph: Paragraph, footnote_id: int) -> None:
        r = etree.SubElement(paragraph._p, qn("w:r"))
        rpr = etree.SubElement(r, qn("w:rPr"))
        etree.SubElement(rpr, qn("w:rStyle")).set(qn("w:val"), "FootnoteReference")
        ref = etree.SubElement(r, qn("w:footnoteReference"))
        ref.set(qn("w:id"), str(footnote_id))

    def insert(self, paragraph: Paragraph, text: str) -> int:
        fid = self.add_footnote(text)
        self.add_reference(paragraph, fid)
        return fid

    def list_footnotes(self) -> list[FootnoteInfo]:
        out = []
        for fn in self._footnote_els():
            if fn.get(qn("w:type")):
                continue
            fid = int(fn.get(qn("w:id")))
            texts = fn.findall(f".//{qn('w:t')}")
            body = "".join(t.text or "" for t in texts).strip()
            out.append(FootnoteInfo(fid, body))
        return out
