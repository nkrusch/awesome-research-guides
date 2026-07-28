import argparse
import bibtexparser
import json
import os
import re
from bibtexparser.customization import convert_to_unicode
from pathlib import Path
from sys import argv


def render_entry(entry, cite=False):
    href = entry.get('url', f"https://doi.org/{entry.get('doi')}")
    id, title, desc = map(entry.get, ('ID', 'title', 'abstract'))
    assert desc, "missing description" + title
    desc += "" if desc.endswith('.') else "."
    ref = f' [@{id}]' if cite else ''
    icon = "" if 'video' in entry.get('keywords', '') else ''
    return f"* [{title}{icon}]({href}){ref} - {desc}"


def load_bib(bib_path):
    with open(bib_path, 'r') as bib_file:
        e = bibtexparser.load(bib_file).entries
        return map(convert_to_unicode, e)
    assert False


def toc_link(title):
    return title.lower().replace(' ', '-').replace('&', '')


def md_name(idx, title):
    n = f"{(idx + 1):02d}"
    f = (re.sub(r'-+', '-', re.sub(
        r'[^a-z0-9 ]', '', title.lower()
    ).replace(' ', '-')).strip('-'))
    return f'{n}-{f}.md'


def main(in_, out, level, gen_toc, cite):
    out.mkdir(parents=True, exist_ok=True)
    with open(in_ / Path("_toc.txt"), 'r') as f:
        sections = [tuple(line.strip().split(','))
                    for line in f if line.strip()]
    h = '#' * level
    toc = f"{h} Contents\n\n"
    for i, (ttl, src) in enumerate(sections):
        href = toc_link(ttl)
        raw_bib = load_bib(in_ / Path(src.strip()))
        entries = [render_entry(entry, cite) for entry in raw_bib]
        content = f"{h} {ttl}\n\n" + ("\n".join(sorted(entries)))
        with open(out / Path(md_name(i, ttl)), 'w') as f:
            f.write(content + "\n\n")
        toc += f'* [{ttl}](#{href})\n'
    if gen_toc:
        with open(out / Path('toc.md'), 'w') as f:
            f.write(toc + '\n---\n\n')


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    ag = parser.add_argument
    ag("out", help="output directory")
    ag('--refs', help="bibs path", default="references")
    ag('--level', type=int, help="header level", default=1)
    ag('--toc', action='store_true', help="output toc")
    ag('--cite', action='store_true', help="apply citations")
    args = parser.parse_args()
    main(Path(args.refs), Path(args.out),
         args.level, args.toc, args.cite)
