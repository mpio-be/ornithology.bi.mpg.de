

#! Packages, settings
  sapply(
    c("data.table", "dbo","stringr","glue", "dplyr",
      "future", "progressr",
      "sf","terra", "tidyterra", "rangeMapper", "rmapshaper","rnaturalearth",
      "ggplot2", "ggnewscale", "ragg", "colorspace"),
    function(x) {require(x,
        character.only = TRUE, quietly = TRUE
      )
    })

  source("./src/_src_settings.R")


# DATA
  # layers
  land   = ne_download(scale = 10, type = "land", category = "physical", returnclass = 'sf')   |> st_geometry()
  oceans = ne_download(scale = 10, type = "ocean", category = "physical", returnclass = 'sf')  |> st_geometry()
  rivers = ne_download(scale = 10, type = "rivers_lake_centerlines", category = "physical", returnclass = "sf") |>
    filter(featurecla == "River" & scalerank < 6) |>
    st_geometry()
  
  bbox = ne_download(scale = 10, type = "geographic_lines", category = "physical", returnclass = "sf") |>
    st_union() |>
    st_bbox() |>
    st_as_sfc() |>
    st_as_sf()

  dem = rast(path_prisma)
  # dem = terra::mask(dem, oceans, inverse = TRUE)

#+ MAP
  # col_lightness = c("#CB657B", "#9A769C", "#AC9CB0", "#C1956E", "#FBFCFC") |> colour_ramp_alpha(0.8)
  col_dem       = c("#000000", "#525252", "#969696", "#BDBDBD", "#F0F0F0", "#FFFFFF") 
  col_oceans    = "#1f242c"
  col_land      = "#e0e9f7"


  # lightness
  agg_png(path_lightness_export, width = 4096, height = 2048)

  plot(dem, mar = c(0, 0, 0, 0), legend = FALSE, axes = FALSE, col = "#4e4b4b", background = "#4e4b4b")
  # plot(m["avg_lightness_females"], add = TRUE, pal = col_lightness, breaks = "fisher", border = NA, alpha = 0.2)
  plot(oceans, add = TRUE, col = col_oceans, border = col_oceans)
  # plot(land,   add = TRUE, col = NA, border = col_land)
  plot(rivers, add = TRUE, col = col_oceans, border = NA, size = 0.01)


  dev.off()
