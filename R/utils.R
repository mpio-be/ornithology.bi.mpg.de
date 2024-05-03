

colors1 = c("#9A769C", "#AC9CB0", "#e2a066", "#FBFCFC")
colors2 = c("#527C5A", "#9A769C", "#FBFCFC")

char_to_wordcloud <- function(x) {

  d = 
  x |>
  na.omit() |>
  # singularize() |> # pluralize is archived 2024-04-29
  str_to_lower() |>
  str_remove_all( "emph") |>
  str_remove_all( "(?:zero|one|two|three|four|five|six|seven|eight|nine|ten)") |>
  str_remove_all( "[^a-zA-Z\\s-]") |>
  str_replace_all("tits", "tit") |>
  str_replace_all("finches", "finch") |>
  str_replace_all("blue tit", "Blue-Tit") |>
  str_replace_all("house sparrow", "House-Sparrow") |>
  str_replace_all("great tit", "Great-Tit") |>
  str_replace_all("color", "colour") |>
  str_replace_all("lekking", "lek") |>
  str_replace_all("zebra finch", "Zebra-Finch") |>
  str_replace_all("extra pair", "extra-pair") |>
  str_replace_all("extrapair", "extra-pair") |>
  VectorSource() |>
  Corpus() |>
  tm_map(removeWords, c(
    stopwords("english"), 
    "parus major", "cyanistes caeruleus", "caeruleus", "taeniopygia guttata", 
    "can", "associated", "predict", "two", "use", "using", 
    "bird", "comment", "analysis", "testing", "predicts")
    ) 


  mat = TermDocumentMatrix(d) |> as.matrix()
  words = sort(rowSums(mat),decreasing=TRUE) 

  data.frame(word = names(words),freq=words)


}

# modified from  tools:::makeJSS()
this.bibstyle <- function (){

    cleanupLatex =  tools:::cleanupLatex

    collapse = function(strings) paste(strings, collapse = "\n")

    addPeriod = function(string) sub("([^.?!])$", "\\1.", string)

    sentence = function(..., sep = ", ") {
      strings = c(...)
      if (length(strings)) {
        addPeriod(paste(strings, collapse = sep))
      }
    }
    
    plain = function(pages) {
      if (length(pages)) collapse(pages)
    }

    plainclean = function(s) {
      plain(cleanupLatex(s))
    }

    emph = function(s) {
      if (length(s)) {
        paste0("\\emph{", collapse(s), "}")
      }
    }
    
    emphclean = function(s) {
      emph(cleanupLatex(s))
    }

    label = function(prefix = NULL, suffix = NULL, style = plain) {
      force(prefix)
      force(suffix)
      force(style)
      function(s) {
        if (length(s)) {
          style(paste0(prefix, collapse(s), suffix))
        }
      }
    }
    
    labelclean = function(prefix = NULL, suffix = NULL, style = plain) {
      f = label(prefix, suffix, style)
      function(s) f(cleanupLatex(s))
    }
    
    fmtAddress      = plainclean
    fmtBook         = emphclean
    fmtBtitle       = emphclean
    fmtChapter      = labelclean(prefix = "chapter ")
    fmtDOI          = label(prefix = "\\doi{", suffix = "}")
    fmtEdition      = labelclean(suffix = " edition")
    fmtEprint       = plain
    fmtHowpublished = plainclean
    fmtISBN         = label(prefix = "ISBN ")
    fmtISSN         = label(prefix = "ISSN ")
    fmtInstitution  = plainclean
    fmtNote         = plainclean
    fmtSchool       = plainclean
    fmtUrl          = label(prefix = "\\url{", suffix = "}")

    
    fmtPages = function(pages) {
        if(!is.null(pages) && grepl('\\d+--\\d+', pages)) pages else NULL

    }
    

    fmtTitle = function(title) {
      if (length(title)) {
        title = gsub("%", "\\\\\\%", title)
        # paste0("\\dQuote{", addPeriod(collapse(cleanupLatex(title))), "}")
        addPeriod(collapse(cleanupLatex(title)))
      }
    }
    
    fmtYear = function(year) {
      if (!length(year)) {
        year = "????"
      }
      paste0("(", collapse(year), ")")
    }
    
    fmtType = function(type, default) {
      if (length(type) && any(nzchar(type))) {
        plainclean(type)
      } else {
        default
      }
    }
    
    volNum = function(paper) {
      if (length(paper$volume)) {
        result = paste0( "\\bold{", collapse(paper$volume),"}")
        # if (length(paper$number)) {
        #   result = paste0(result, "(", collapse(paper$number),")"
        #   )
        # }
        result
      }
    }
    
    shortName = function(person) {
      if (length(person$family)) {
        result = cleanupLatex(person$family)
        if (length(person$given)) {
          paste(result, paste(substr(sapply(
            person$given,
            cleanupLatex
          ), 1, 1), collapse = ""))
        } else {
          result
        }
      } else {
        paste(cleanupLatex(person$given), collapse = " ")
      }
    }
    
    authorList = function(paper) {
      names = sapply(paper$author, shortName)
      if (length(names) > 1L) {
        result = paste(names, collapse = ", ")
      } else {
        result = names
      }
      result
    }
    
    editorList = function(paper) {
      names = sapply(paper$editor, shortName)
      if (length(names) > 1L) {
        result = paste(paste(names, collapse = ", "), "(eds.)")
      } else if (length(names)) {
        result = paste(names, "(ed.)")
      } else {
        result = NULL
      }
      result
    }
    
    extraInfo = function(paper) {
      
      escapeDOIPercent = function(s) {
        gsub("%", paste0(strrep("\\",11L), "%"), fixed = TRUE, s)
      }

      result = paste(
        c(
          fmtDOI(escapeDOIPercent(paper$doi)),
          fmtNote(paper$note), 
          fmtEprint(paper$eprint), 
          fmtUrl(paper$url)
        ),
        collapse = ", "
      )
      if (nzchar(result)) {
        result
      }
    }
    
    bookVolume = function(book) {
      result = ""
      if (length(book$volume)) {
        result = paste("volume", collapse(book$volume))
      }
      if (length(book$number)) {
        result = paste(result, "number", collapse(book$number))
      }
      if (length(book$series)) {
        result = paste(result, "series", collapse(book$series))
      }
      if (nzchar(result)) {
        result
      }
    }
    
    bookPublisher = function(book) {
      if (length(book$publisher)) {
        result = collapse(book$publisher)
        if (length(book$address)) {
          result = paste(result, collapse(book$address),
            sep = ", "
          )
        }
        result
      }
    }
    
    procOrganization = function(paper) {
      if (length(paper$organization)) {
        result = collapse(cleanupLatex(paper$organization))
        if (length(paper$address)) {
          result = paste(result, collapse(cleanupLatex(paper$address)),
            sep = ", "
          )
        }
        result
      }
    }
    
    
    formatArticle = function(paper) {
      collapse(c(
        fmtPrefix(paper),
        sentence(
          authorList(paper),
          fmtYear(paper$year),
          sep = " "
        ),
        fmtTitle(paper$title),
        sentence(
          fmtBook(paper$journal),
          volNum(paper),
          fmtPages(paper$pages)
        ),
        extraInfo(paper)
      ))
    }
    
    formatBook = function(book) {
      authors = authorList(book)
      if (!length(authors)) {
        authors = editorList(book)
      }
      collapse(c(
        fmtPrefix(book), sentence(authors, fmtYear(book$year),
          sep = " "
        ), sentence(
          fmtBtitle(book$title), bookVolume(book),
          fmtEdition(book$edition)
        ), sentence(bookPublisher(book)),
        sentence(fmtISBN(book$isbn), extraInfo(book))
      ))
    }
    
    formatInbook = function(paper) {
        authors = authorList(paper)
        editors = editorList(paper)
        if (!length(authors)) {
            authors = editors
            editors = NULL
        }
        collapse(c(
          fmtPrefix(paper),
          sentence(authors,
            fmtYear(paper$year),
            sep = " "
          ),
          fmtTitle(paper$title),
          paste("In", sentence(
            editors,
            fmtBtitle(paper$booktitle),
            bookVolume(paper),
            fmtChapter(paper$chapter),
            fmtEdition(paper$edition),
            fmtPages(paper$pages)
          )),
          sentence(bookPublisher(paper)),
          sentence(
            fmtISBN(paper$isbn),
            extraInfo(paper)
          )
        ))
    }

    formatIncollection = function(paper) {
        collapse(c(
          fmtPrefix(paper),
          sentence(
            authorList(paper), 
            fmtYear(paper$year), sep = " "), 
            fmtTitle(paper$title), 
            paste("In", 
            sentence(
              editorList(paper), 
              fmtBtitle(paper$booktitle), 
              bookVolume(paper), 
              fmtEdition(paper$edition), 
              fmtPages(paper$pages))), 
              sentence(bookPublisher(paper)), 
              sentence(fmtISBN(paper$isbn), 
              extraInfo(paper))
            ))
    }

    sortKeys = function(bib) {
      result = character(length(bib))
      for (i in seq_along(bib)) {
        authors = authorList(bib[[i]])
        if (!length(authors)) {
          authors = editorList(bib[[i]])
        }
        if (!length(authors)) {
          authors = ""
        }
        result[i] = authors
      }
      result
    }
    
    fmtPrefix = function(paper) NULL
    
    cite = function(key, bib, ...) utils::citeNatbib(key, bib, ...)
    
    environment()
}
