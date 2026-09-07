import zipfile
from lxml import etree

import pytest

from docx_fnbib import api
from docx_fnbib.formatting import bibliography_entry, in_text_citation, plain
from docx_fnbib.sources import Source, Contributor

BIB = "http://schemas.openxmlformats.org/officeDocument/2006/bibliography"

BOOK = {
    "tag": "Smith2020",
    "type": "Book",
    "authors": [{"last": "Smith", "first": "Jane"}],
    "title": "A History of Everything",
    "year": "2020",
    "city": "New York",
    "publisher": "Penguin",
}
ARTICLE = {
    "tag": "Doe2019",
    "type": "JournalArticle",
    "authors": [{"last": "Doe", "first": "John"}, {"last": "Roe", "first": "Amy"}],
    "title": "On the matter of things",
    "journal": "Journal of Things",
    "year": "2019",
    "volume": "12",
    "issue": "3",
    "pages": "45-67",
}


@pytest.fixture
def doc(tmp_path):
    p = tmp_path / "d.docx"
    api.create_document(str(p), paragraphs=["A sentence that needs a citation.", "Another one."])
    api.add_source(str(p), BOOK)
    api.add_source(str(p), ARTICLE)
    return str(p)


def test_sources_persist_in_customxml(doc):
    with zipfile.ZipFile(doc) as z:
        item = next(n for n in z.namelist() if n.startswith("customXml/item") and n.endswith(".xml") and "Props" not in n)
        root = etree.fromstring(z.read(item))
    assert root.tag == f"{{{BIB}}}Sources"
    tags = [e.text for e in root.findall(f".//{{{BIB}}}Tag")]
    assert set(tags) == {"Smith2020", "Doe2019"}


def test_list_and_remove_sources(doc):
    assert {s["tag"] for s in api.list_sources(doc)} == {"Smith2020", "Doe2019"}
    api.remove_source(doc, "Doe2019")
    assert {s["tag"] for s in api.list_sources(doc)} == {"Smith2020"}


def test_apa_entry_book():
    s = Source.from_dict(BOOK)
    txt = plain(bibliography_entry(s, "apa"))
    assert txt.startswith("Smith, J. (2020).")
    assert "A History of Everything" in txt
    assert "Penguin." in txt


def test_apa_intext():
    s = Source.from_dict(BOOK)
    assert plain(in_text_citation(s, "apa", page="12")) == "(Smith, 2020, p. 12)"


def test_mla_entry_article():
    s = Source.from_dict(ARTICLE)
    txt = plain(bibliography_entry(s, "mla"))
    assert txt.startswith("Doe, John, and Amy Roe.")
    assert "vol. 12" in txt and "no. 3" in txt and "pp. 45-67" in txt


def test_chicago_notes_citation_is_footnote(doc):
    api.add_citation(doc, 0, "Smith2020", style="chicago-notes", page="5")
    notes = api.list_footnotes(doc)
    assert len(notes) == 1
    assert "A History of Everything" in notes[0]["text"]
    assert notes[0]["text"].endswith("5.")


def test_text_bibliography_section(doc):
    api.add_citation(doc, 0, "Smith2020", style="apa", mode="text", page="7")
    res = api.add_bibliography(doc, style="apa", mode="text", heading="References")
    assert res["entries"] == 2
    outline = api.document_outline(doc)
    assert any(row["text"] == "References" for row in outline)
    assert any("Smith, J. (2020)" in row["text"] for row in outline)


def test_field_mode_writes_citation_field(doc):
    api.add_citation(doc, 0, "Doe2019", style="apa", mode="field", page="50")
    api.add_bibliography(doc, style="apa", mode="field", heading="References")
    with zipfile.ZipFile(doc) as z:
        dx = z.read("word/document.xml").decode()
    assert "CITATION Doe2019" in dx
    assert "BIBLIOGRAPHY" in dx


def test_import_bibtex(doc):
    bib = """@book{Knuth1997,
  author = {Knuth, Donald E.},
  title = {The Art of Computer Programming},
  publisher = {Addison-Wesley},
  year = {1997},
  address = {Boston}
}"""
    res = api.import_references(doc, bib, fmt="bibtex")
    assert "Knuth1997" in res["imported"]
    s = next(s for s in api.list_sources(doc) if s["tag"] == "Knuth1997")
    assert s["authors"][0]["last"] == "Knuth"
