"""Citation + bibliography string builders for common styles.

Output is a list of ``(text, italic)`` segments so callers can render real
italic runs. ``plain(segments)`` collapses to a string.

Supported styles: ``apa`` (APA 7), ``mla`` (MLA 9),
``chicago-author-date`` and ``chicago-notes`` (Chicago 17).

These are pragmatic implementations covering books, book sections, journal
articles, periodical articles, reports and web pages. They are not a full CSL
processor; for exact style output use Word's field-based bibliography.
"""
from __future__ import annotations

from .sources import Source, Contributor

Segment = tuple[str, bool]
STYLES = ("apa", "mla", "chicago-author-date", "chicago-notes")


def plain(segs: list[Segment]) -> str:
    return "".join(t for t, _ in segs)


# --- name helpers ----------------------------------------------------------
def _name_last_first(c: Contributor) -> str:
    if c.is_corporate:
        return c.corporate
    last, given = c.family_given()
    return f"{last}, {given}".strip().rstrip(",")


def _name_first_last(c: Contributor) -> str:
    if c.is_corporate:
        return c.corporate
    last, given = c.family_given()
    return f"{given} {last}".strip()


def _initials(c: Contributor) -> str:
    if c.is_corporate:
        return c.corporate
    last, given = c.family_given()
    inits = " ".join(f"{p[0]}." for p in given.split() if p)
    return f"{last}, {inits}".strip().rstrip(",")


def _join_names(names: list[str], style: str) -> str:
    names = [n for n in names if n]
    if not names:
        return ""
    if len(names) == 1:
        return names[0]
    if style == "amp":
        return ", ".join(names[:-1]) + ", & " + names[-1] if len(names) > 2 else \
            names[0] + " & " + names[1]
    return ", ".join(names[:-1]) + ", and " + names[-1]


def _authors_apa(src: Source) -> str:
    return _join_names([_initials(a) for a in src.authors], "amp")


def _authors_mla(src: Source) -> str:
    a = src.authors
    if not a:
        return ""
    if len(a) == 1:
        return _name_last_first(a[0])
    if len(a) == 2:
        return f"{_name_last_first(a[0])}, and {_name_first_last(a[1])}"
    return f"{_name_last_first(a[0])}, et al"


def _authors_chicago_bib(src: Source) -> str:
    a = src.authors
    if not a:
        return ""
    if len(a) == 1:
        return _name_last_first(a[0])
    return _join_names(
        [_name_last_first(a[0])] + [_name_first_last(x) for x in a[1:]], "and"
    )


def _authors_chicago_note(src: Source) -> str:
    a = src.authors
    if not a:
        return ""
    if len(a) <= 3:
        return _join_names([_name_first_last(x) for x in a], "and")
    return f"{_name_first_last(a[0])} et al."


# --- year / access -------------------------------------------------------
def _year(src: Source) -> str:
    return src.year or "n.d."


def _period(s: str) -> str:
    s = s.strip()
    if not s:
        return ""
    return s if s.endswith((".", "!", "?")) else s + "."


# --- bibliography entries ----------------------------------------------
def bibliography_entry(src: Source, style: str) -> list[Segment]:
    if style == "apa":
        return _apa_entry(src)
    if style == "mla":
        return _mla_entry(src)
    if style in ("chicago-author-date", "chicago-notes"):
        return _chicago_entry(src, author_date=style == "chicago-author-date")
    raise ValueError(f"unknown style: {style}")


def _apa_entry(src: Source) -> list[Segment]:
    segs: list[Segment] = []
    au = _authors_apa(src)
    lead = f"{au} " if au else ""
    segs.append((f"{lead}({_year(src)}). ", False))
    if src.type in ("JournalArticle", "ArticleInAPeriodical"):
        segs.append((_period(src.title) + " ", False))
        if src.journal:
            segs.append((src.journal, True))
            vol = f", {src.volume}" if src.volume else ""
            iss = f"({src.issue})" if src.issue else ""
            segs.append((f"{vol}{iss}", False))
            if src.pages:
                segs.append((f", {src.pages}", False))
            segs.append((". ", False))
    else:
        segs.append((src.title, True))
        segs.append((". ", False))
        if src.publisher:
            segs.append((_period(src.publisher) + " ", False))
    if src.doi:
        segs.append((f"https://doi.org/{src.doi}", False))
    elif src.url:
        segs.append((src.url, False))
    return _tidy(segs)


def _mla_entry(src: Source) -> list[Segment]:
    segs: list[Segment] = []
    au = _authors_mla(src)
    if au:
        segs.append((_period(au) + " ", False))
    if src.type in ("JournalArticle", "ArticleInAPeriodical"):
        segs.append((f'"{_period(src.title)}" ', False))
        if src.journal:
            segs.append((src.journal, True))
            segs.append((", ", False))
        if src.volume:
            segs.append((f"vol. {src.volume}, ", False))
        if src.issue:
            segs.append((f"no. {src.issue}, ", False))
        if src.year:
            segs.append((f"{src.year}, ", False))
        if src.pages:
            segs.append((f"pp. {src.pages}.", False))
    else:
        segs.append((src.title, True))
        segs.append((". ", False))
        if src.publisher:
            segs.append((f"{src.publisher}, ", False))
        if src.year:
            segs.append((f"{src.year}.", False))
    if src.url:
        segs.append((f" {src.url}.", False))
    if src.accessed:
        segs.append((f" Accessed {src.accessed}.", False))
    return _tidy(segs)


def _chicago_entry(src: Source, author_date: bool) -> list[Segment]:
    segs: list[Segment] = []
    au = _authors_chicago_bib(src)
    if au:
        segs.append((_period(au) + " ", False))
    if author_date and src.year:
        segs.append((f"{src.year}. ", False))
    if src.type in ("JournalArticle", "ArticleInAPeriodical"):
        segs.append((f'"{_period(src.title)}" ', False))
        if src.journal:
            segs.append((src.journal, True))
            segs.append((" ", False))
        if src.volume:
            segs.append((f"{src.volume}", False))
        if src.issue:
            segs.append((f", no. {src.issue}", False))
        if not author_date and src.year:
            segs.append((f" ({src.year})", False))
        if src.pages:
            segs.append((f": {src.pages}", False))
        segs.append((".", False))
    else:
        segs.append((src.title, True))
        segs.append((". ", False))
        if src.city:
            segs.append((f"{src.city}: ", False))
        if src.publisher:
            segs.append((src.publisher, False))
        if not author_date and src.year:
            segs.append((f", {src.year}", False))
        segs.append((".", False))
    if src.url:
        segs.append((f" {src.url}.", False))
    return _tidy(segs)


# --- in-text / note citations ----------------------------------------
def in_text_citation(
    src: Source, style: str, page: str | None = None, note_number: int | None = None
) -> list[Segment]:
    pg = f", {page}" if page else ""
    if style == "apa":
        au = _authors_apa(src).split(",")[0] if src.authors else src.title
        if src.authors and src.authors[0].is_corporate:
            au = src.authors[0].corporate
        elif src.authors:
            au = src.authors[0].last
        p = f", p. {page}" if page else ""
        return [(f"({au}, {_year(src)}{p})", False)]
    if style == "mla":
        au = src.authors[0].last if src.authors and not src.authors[0].is_corporate else (
            src.authors[0].corporate if src.authors else ""
        )
        pg = f" {page}" if page else ""
        inside = f"{au}{pg}".strip()
        return [(f"({inside})", False)]
    if style == "chicago-author-date":
        au = src.authors[0].last if src.authors and not src.authors[0].is_corporate else (
            src.authors[0].corporate if src.authors else src.title
        )
        p = f", {page}" if page else ""
        return [(f"({au} {_year(src)}{p})", False)]
    if style == "chicago-notes":
        segs: list[Segment] = []
        au = _authors_chicago_note(src)
        if au:
            segs.append((f"{au}, ", False))
        if src.type in ("JournalArticle", "ArticleInAPeriodical"):
            segs.append((f'"{src.title}," ', False))
            if src.journal:
                segs.append((src.journal, True))
                segs.append((" ", False))
            if src.volume:
                segs.append((f"{src.volume}", False))
            if src.issue:
                segs.append((f", no. {src.issue}", False))
            if src.year:
                segs.append((f" ({src.year})", False))
            if page:
                segs.append((f": {page}", False))
            segs.append((".", False))
        else:
            segs.append((src.title, True))
            segs.append((" (", False))
            if src.city:
                segs.append((f"{src.city}: ", False))
            if src.publisher:
                segs.append((src.publisher, False))
            if src.year:
                segs.append((f", {src.year}", False))
            segs.append((")", False))
            if page:
                segs.append((f", {page}", False))
            segs.append((".", False))
        return _tidy(segs)
    raise ValueError(f"unknown style: {style}")


def sort_key(src: Source):
    if src.authors:
        c = src.authors[0]
        base = c.corporate or c.last
    else:
        base = src.title
    return (base.lower(), src.year)


def _tidy(segs: list[Segment]) -> list[Segment]:
    out: list[Segment] = []
    for t, i in segs:
        if not t:
            continue
        if out and out[-1][1] == i:
            out[-1] = (out[-1][0] + t, i)
        else:
            out.append((t, i))
    # collapse double spaces / space-before-period
    fixed = []
    for t, i in out:
        t = t.replace(" .", ".").replace("  ", " ").replace(".. ", ". ")
        fixed.append((t, i))
    if fixed:
        t, i = fixed[-1]
        fixed[-1] = (t.rstrip(), i)
    return [seg for seg in fixed if seg[0]]
