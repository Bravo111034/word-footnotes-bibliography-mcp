"""Footnote text inherits document size; settings.xml carries footnotePr."""
import zipfile
from lxml import etree

from docx_fnbib import api

W = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"


def _q(t):
    return f"{{{W}}}{t}"


def test_footnotetext_style_has_no_hardcoded_size(tmp_path):
    p = tmp_path / "d.docx"
    api.create_document(str(p), paragraphs=["Body text here."])
    api.add_footnote(str(p), 0, "A note.")
    with zipfile.ZipFile(str(p)) as z:
        styles = etree.fromstring(z.read("word/styles.xml"))
    fn = next(
        s for s in styles.findall(_q("style"))
        if s.get(_q("styleId")) == "FootnoteText"
    )
    rpr = fn.find(_q("rPr"))
    # no explicit sz / szCs -> inherits docDefaults/Normal (document settings)
    assert rpr is None or (
        rpr.find(_q("sz")) is None and rpr.find(_q("szCs")) is None
    )


def test_settings_has_footnote_pr_page_bottom_continuous(tmp_path):
    p = tmp_path / "d.docx"
    api.create_document(str(p), paragraphs=["Body."])
    api.add_footnote(str(p), 0, "Note.")
    with zipfile.ZipFile(str(p)) as z:
        settings = etree.fromstring(z.read("word/settings.xml"))
    fpr = settings.findall(_q("footnotePr"))
    assert len(fpr) == 1
    assert fpr[0].find(_q("pos")).get(_q("val")) == "pageBottom"
    assert fpr[0].find(_q("numRestart")).get(_q("val")) == "continuous"
    # footnotePr must precede compat in schema order
    kids = list(settings)
    names = [k.tag for k in kids]
    if _q("compat") in names:
        assert names.index(_q("footnotePr")) < names.index(_q("compat"))


def test_footnote_pr_not_duplicated_on_reopen(tmp_path):
    p = tmp_path / "d.docx"
    api.create_document(str(p), paragraphs=["Body one.", "Body two."])
    api.add_footnote(str(p), 0, "One.")
    api.add_footnote(str(p), 1, "Two.")
    with zipfile.ZipFile(str(p)) as z:
        settings = etree.fromstring(z.read("word/settings.xml"))
    assert len(settings.findall(_q("footnotePr"))) == 1
