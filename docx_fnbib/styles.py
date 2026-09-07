"""Ensure the paragraph/character styles that footnotes and bibliographies need."""
from __future__ import annotations

from lxml import etree

from .ooxml import qn, w

_STYLE_XML = {
    "FootnoteText": """
      <w:style xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
               w:type="paragraph" w:styleId="FootnoteText">
        <w:name w:val="footnote text"/>
        <w:basedOn w:val="Normal"/>
        <w:link w:val="FootnoteTextChar"/>
        <w:uiPriority w:val="99"/>
        <w:semiHidden/>
        <w:unhideWhenUsed/>
        <w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto"/></w:pPr>
        <w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr>
      </w:style>""",
    "FootnoteReference": """
      <w:style xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
               w:type="character" w:styleId="FootnoteReference">
        <w:name w:val="footnote reference"/>
        <w:basedOn w:val="DefaultParagraphFont"/>
        <w:uiPriority w:val="99"/>
        <w:semiHidden/>
        <w:unhideWhenUsed/>
        <w:rPr><w:vertAlign w:val="superscript"/></w:rPr>
      </w:style>""",
    "Bibliography": """
      <w:style xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
               w:type="paragraph" w:styleId="Bibliography">
        <w:name w:val="Bibliography"/>
        <w:basedOn w:val="Normal"/>
        <w:uiPriority w:val="37"/>
        <w:unhideWhenUsed/>
        <w:pPr>
          <w:ind w:left="480" w:hanging="480"/>
          <w:spacing w:after="0" w:line="480" w:lineRule="auto"/>
        </w:pPr>
      </w:style>""",
}


def ensure_styles(document, names: list[str]) -> list[str]:
    """Add any missing styles by id. Returns the ids that were added."""
    styles_el = document.styles.element
    existing = {
        s.get(qn("w:styleId"))
        for s in styles_el.findall(qn("w:style"))
    }
    added = []
    for name in names:
        if name in existing or name not in _STYLE_XML:
            continue
        styles_el.append(etree.fromstring(_STYLE_XML[name].strip()))
        added.append(name)
    return added
