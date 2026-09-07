"""Build a finished document exercising footnotes + citations + bibliography.

    python examples/build_demo.py            -> examples/demo.docx
"""
from __future__ import annotations

import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from docx_fnbib import api  # noqa: E402

OUT = os.path.join(os.path.dirname(__file__), "demo.docx")

BODY = [
    "Cosmopolitanism holds that every person has obligations to every other, "
    "obligations that do not stop at the border.",
    "Critics answer that thick local loyalties are what actually move people to act.",
    "This tension is old: the Stoics argued for the polis of the world, while "
    "Burke insisted on the little platoon.",
]

SOURCES = [
    {
        "tag": "Appiah2006",
        "type": "Book",
        "authors": ["Appiah, Kwame Anthony"],
        "title": "Cosmopolitanism: Ethics in a World of Strangers",
        "year": "2006",
        "city": "New York",
        "publisher": "W. W. Norton",
    },
    {
        "tag": "Nussbaum1994",
        "type": "ArticleInAPeriodical",
        "authors": ["Nussbaum, Martha C."],
        "title": "Patriotism and Cosmopolitanism",
        "journal": "Boston Review",
        "year": "1994",
        "volume": "19",
        "issue": "5",
        "pages": "3-6",
    },
]


def main() -> None:
    api.create_document(OUT, title="Obligations Beyond Borders", paragraphs=BODY)

    for s in SOURCES:
        api.add_source(OUT, s)

    # paragraph 0 is the title; body starts at 1
    api.add_footnote(
        OUT, 1, "Appiah calls this the claim that we have obligations to strangers.",
        anchor="obligations to every other",
    )
    api.add_citation(OUT, 1, "Appiah2006", style="apa", page="xiii")
    api.add_citation(OUT, 2, "Nussbaum1994", style="apa", page="4")
    api.add_footnote(
        OUT, 3, "Edmund Burke, Reflections on the Revolution in France (1790).",
        anchor="little platoon",
    )

    n = api.add_bibliography(OUT, style="apa", heading="References")
    print(f"wrote {OUT}  ({n} references, {len(api.list_footnotes(OUT))} footnotes)")


if __name__ == "__main__":
    main()
