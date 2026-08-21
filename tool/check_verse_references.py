#!/usr/bin/env python3
"""Check every verse the post-office game quotes against St-Takla's text.

Run by hand after editing a level's verses:

    python3 tool/check_verse_references.py

It reads the verse strings out of the level files, parses the citation off
the end of each one, fetches those verses from St-Takla and reports any
quoted text that is not in the verses it cites. Diacritics and punctuation
are normalised away before comparing, because the play's transcription and
the site differ in تشكيل. A quote split by "..." matches when every segment
appears in the cited range.
"""

from __future__ import annotations

import html
import re
import sys
import unicodedata
import urllib.parse
import urllib.request
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path


BOOK_INDEX = {
    'أع': 54,
    'رو': 55,
    '1 كو': 56,
    '2 كو': 57,
    'غل': 58,
    'أف': 59,
    'في': 60,
    'كو': 61,
    '1 تس': 62,
    '2 تس': 63,
    '1 تي': 64,
    '2 تي': 65,
    'تي': 66,
    'فل': 67,
    'عب': 68,
}

# Places the game deliberately shows something other than St-Takla's text,
# keyed by citation. The play is normative for what the room hears, so where
# it glosses a word the card follows the play and this records why. Any
# other drift from St-Takla still fails.
DELIBERATE = {
    'غل 1: 8': (
        'The play has the actor say «محروماً» where Van Dyck reads '
        '«أَنَاثِيمَا». The card follows the play so the room does not read '
        'one word while hearing another.'
    ),
}

FILES = (
    'lib/src/data/game/post_office_road_levels.dart',
    'lib/src/data/game/post_office_prison_levels.dart',
    'lib/src/data/game/post_office_script.dart',
)


def entries(source: str) -> list[tuple[str, str]]:
    return re.findall(r"'([^']*)\\n\(([^)]+)\)'", source)


def all_verses(source: str) -> list[str]:
    """Every string in a `verses:` list, cited or not."""
    return [
        verse
        for block in re.findall(r'verses: \[(.*?)\n    \],', source, flags=re.S)
        for verse in re.findall(r"^\s*'(.*?)',$", block, flags=re.M)
    ]


def verse_ranges(citation: str) -> list[tuple[int, int, int]]:
    book, chapter, verses = re.fullmatch(
        r'(.+?) (\d+): (.+)', citation,
    ).groups()
    del book
    ranges = []
    for part in verses.split('، '):
        start, separator, end = part.partition('-')
        ranges.append((int(chapter), int(start), int(end or start)))
        if not separator:
            continue
    return ranges


def fetch(book: int, chapter: int, start: int, end: int) -> str:
    query = urllib.parse.urlencode({
        'book': book,
        'chapter': chapter,
        'vmin': start,
        'vmax': end,
    })
    url = f'https://st-takla.org/Bibles/BibleSearch/showVerses.php?{query}'
    with urllib.request.urlopen(url, timeout=20) as response:
        page = response.read().decode('utf-8')
    verses = re.findall(
        r'<div id="bodytext"[^>]*itemprop="description"[^>]*>(.*?)</div>',
        page,
        flags=re.S,
    )
    return ' '.join(
        re.sub(r'\s+', ' ', re.sub(r'<[^>]+>', ' ', html.unescape(verse))).strip()
        for verse in verses
    )


def normalize(text: str) -> str:
    decomposed = unicodedata.normalize('NFKD', text)
    return ''.join(
        character
        for character in decomposed
        if not unicodedata.combining(character)
        and character not in ' "«».,:؛؟?!،-—…'
    )


def main() -> int:
    repo = Path.cwd()
    quoted_entries = [
        (relative, shown, citation)
        for relative in FILES
        for shown, citation in entries((repo / relative).read_text())
    ]
    requests = {
        (BOOK_INDEX[book], chapter, start, end)
        for _, _, citation in quoted_entries
        for book in [next(name for name in BOOK_INDEX if citation.startswith(f'{name} '))]
        for chapter, start, end in verse_ranges(citation)
    }
    with ThreadPoolExecutor(max_workers=12) as executor:
        fetched = {
            request: text
            for request, text in zip(requests, executor.map(lambda request: fetch(*request), requests))
        }
    uncited = [
        (relative, shown[:60])
        for relative in FILES
        for shown in all_verses((repo / relative).read_text())
        if not re.search(r'\\n\([^)]+\)$', shown)
    ]
    checked = 0
    checked_ranges = 0
    mismatches = []
    for relative, shown, citation in quoted_entries:
        book = next((name for name in BOOK_INDEX if citation.startswith(f'{name} ')), None)
        if book is None:
            raise ValueError(f'Unknown book abbreviation: {citation}')
        actual = []
        for chapter, start, end in verse_ranges(citation):
            actual.append(fetched[(BOOK_INDEX[book], chapter, start, end)])
            checked_ranges += 1
        unmatched = [
            segment
            for segment in shown.split('...')
            if normalize(segment) not in normalize(' '.join(actual))
        ]
        checked += 1
        if unmatched and citation not in DELIBERATE:
            mismatches.append((relative, citation, unmatched, actual))
    print(f'checked {checked} quoted entries')
    print(f'checked {checked_ranges} referenced verse ranges')
    for relative, shown in uncited:
        print(f'NO CITATION {relative}: {shown}')
    if not mismatches and not uncited:
        print('all quoted text matches its cited St-Takla verses')
    for citation, reason in DELIBERATE.items():
        print(f'ALLOWED {citation}: {reason}')
    for relative, citation, unmatched, actual in mismatches:
        print(f'MISMATCH {relative}: {citation}')
        print(f'  unmatched: {unmatched}')
        print(f"  St-Takla: {' '.join(actual)}")
    return 1 if mismatches or uncited else 0


if __name__ == '__main__':
    sys.exit(main())
