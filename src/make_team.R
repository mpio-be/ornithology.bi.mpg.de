
sapply(
c('data.table', 'dplyr', 'stringr', 'rvest','foreach','glue'),
require, character.only = TRUE, quietly = TRUE) |> invisible()



d = foreach(i=1:2, .combine=rbind) %do% {
    tt = read_html( paste0("https://www.bi.mpg.de/1506857/Staff?page=",i) ) |>
    html_nodes("table") 

    x = html_nodes(tt, "[class='name first']") |>
    html_element('a') 
    x= x[!sapply(x, inherits, what = "xml_missing")]
    href = html_attr(x, "href")
    Name = html_text(x)

    Position = html_nodes(tt, "[class='position']") |> html_text()

    data.table(Name,Position, href)

}
d[, href := glue_data(.SD, "https:/bi.mpg.de{href}") |> as.character()]

# updates
d[str_detect(Name, 'Emmi'), Position := 'Doctoral Student']


# other members
x = data.table(Name = 'Kaspar Delhey', Position = "Scientist", href = "https://kaspardelhey.wordpress.com/")
d = rbind(d, x)

x = data.table(Name = 'Rowan Stanforth', Position = "Intern", href = "https://ornithology.bi.mpg.de/team")
d = rbind(d, x)

x = data.table(Name = 'Karle Lagrange', Position = "Intern", href = "https://ornithology.bi.mpg.de/team")
d = rbind(d, x)




setorder(d, Position)

d[, Name := glue_data(.SD, "[{Name}]({href})")]
d[, href := NULL]

fwrite(d, "./CONTENT/data/team.csv")