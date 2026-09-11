## Contributing Guidelines

This project is released with a contributor [Code of Conduct].
By participating, you agree to abide by its terms.

For contribution ideas, have a look at [repository issues].
Awesome lists are curations of the best resources by topic, not everything.

### Scope and inclusion criteria

Contributions must meet the following inclusion criteria.

* The item topic must be related to **research**.
* The item content must aim to **communicate guidance** about conducting research. 
* The item content should have **long-term relevance** (in years).

List items can appear in many formats: text, slides, video, etc.

### How to contribute

The awesome list is compiled from the references.
Do not edit the readme directly; all updates must be made in bib files.

1. Fork and clone [this repository].
2. Go to `references/`
3. Each bib file is a list section: choose a bibliography to edit. 
4. Apply edits to the bibliography.
   Make sure to include a one-sentence description in `abstract`.
5. Commit changes to the forked repository.
6. Open a [pull request] against the upstream repository.

### Previewing

Using Docker, you can preview the rendered output. Run in terminal:
```
docker run --rm --platform linux/amd64 \
   -v $(PWD):$(PWD) -w $(PWD) \
    --platform linux/amd64 \
   ghcr.io/nkrusch/guide-env:latest \
   make readme.md
```

[this repository]: https://github.com/nkrusch/awesome-research-guides/fork
[Code of Conduct]: https://github.com/nkrusch/awesome-research-guides/blob/main/.github/code-of-conduct.md
[repository issues]: https://github.com/nkrusch/awesome-research-guides/issues
[pull request]: https://github.com/nkrusch/awesome-research-guides/pulls
