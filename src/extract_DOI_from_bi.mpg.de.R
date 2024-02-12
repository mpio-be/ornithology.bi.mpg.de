

require(rvest)
require(glue)
require(stringr)


y = 2021
  
x = 
  read_html( glue("https://www.bi.mpg.de/1506850/Publications?year={y}") ) |>
  html_nodes(".publication_list") |>
  html_nodes(".doi") |>
  html_attr("href") |>
  str_remove('https://dx.doi.org/')


cat(x, sep = " ")  
  