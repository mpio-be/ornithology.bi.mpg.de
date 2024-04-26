
# Department of Ornithology

This repository holds the source for the public website of the Department of Ornithology in Seewiesen, accessible at [ornithology.bi.mpg.de](http://ornithology.bi.mpg.de) . 

## Credits

This project uses the following software:

* **quarto**: [quarto ](https://quarto.org/) for dynamic document creation.
* **quarto extension**: [quarto fontawesome](https://github.com/quarto-ext/fontawesome) for using fa in quarto.
* **globe.gl**: [globe.gl ](https://globe.gl/) for interactive 3D globes.
* **marked**: [marked ](https://marked.js.org/) for markdown parsing.
* **bootbox**: [bootbox ](https://bootboxjs.com/) for modal windows and dialogs.
* **d3js**: [d3js ](https://d3js.org) for csv parsing and data visualization.
* **index-array-by**: [index-array-by ](https://github.com/jsocke/index-array-by) for array indexing utilities.


## How to contribute

### Images
 * Images should be `*.webp` files and no larger than 2000px in width.

### Text
 * Text is contained in  `*.qmd` files and written in markdown. See for example [quarto.org](https://quarto.org/docs/authoring/markdown-basics.html) or [markdownguide.org](https://www.markdownguide.org/cheat-sheet/) for more info.
  

### Adding a new publication in `/CONTENT/data/publications.bib`
 * check https://www.bibtex.com/g/bibtex-format/ for more info.
 * search and use Google Scholar to export to bib.
 * always add a space after title, author, etc. 
 * add new publications on top. 

### Adding a __news__ item in `/CONTENT/news/YYYY/`
  * create a new `.*qmd` file using a previous file as template. 
  * if the `news` item refers to a new publication, the file, the image associated with it and the bib entry in`/CONTENT/data/publications.bib` should have the same name. `AuthorKeywordYear` is a good template.
