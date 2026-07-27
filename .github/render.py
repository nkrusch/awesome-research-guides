import bibtexparser
import json
import os
import re
from bibtexparser.customization import convert_to_unicode
from pathlib import Path
from sys import argv


def render_entry(entry):
    href = entry.get('url', f"https://doi.org/{entry.get('doi')}")
    title = entry.get('title')
    desc = entry.get('abstract')
    icon = " 🎦" if 'video' in entry.get('keywords', '') else ''
    assert desc, "missing description" + title
    desc += "" if desc.endswith('.') else "."
    return f"* [{title}{icon}]({href}) - {desc}"


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


def main(in_, out):
    out.mkdir(parents=True, exist_ok=True)
    with open(in_ / Path("_toc.txt"), 'r') as f:
        sections = [tuple(line.strip().split(','))
                    for line in f if line.strip()]
    toc = "# Contents\n\n"
    for i, (ttl, src) in enumerate(sections):
        href = toc_link(ttl)
        raw_bib = load_bib(in_ / Path(src.strip()))
        entries = [render_entry(entry) for entry in raw_bib]
        content = f"# {ttl}\n\n" + ("\n".join(sorted(entries)))
        with open(out / Path(md_name(i, ttl)), 'w') as f:
            f.write(content)
        toc += f'* [{ttl}](#{href})\n'
    with open(out / Path('00_toc.md'), 'w') as f:
        f.write(toc + '\n---\n')


if __name__ == "__main__":
    main(Path("references"), Path(argv[1]))
