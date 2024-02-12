

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

  source("./src/Globe_basemap/globe_maps.R")


# DATA
  x = fread()
  setnames(x, "TipLabel", "scinam")
  x[, scinam := str_to_lower(scinam) |> str_replace("_", " ")]

  spl = paste(x$scinam |> unique() |> shQuote(), collapse = ",")

  con = dbcon(db = "AVES_ranges")
  r   = dbq(con, glue("SELECT scinam, taxonomy tax, SHAPE FROM breeding_ranges_v2 WHERE
          scinam in ({spl}) ") , geom = "SHAPE")
  st_crs(r) = 4326
  closeCon(con)

  r = mutate(r, ok = st_is_valid(r))

  setDT(r)
  
  r[(!ok)]

  # FIX using with no_repair = TRUE
  r[(!ok), geometry := ms_simplify(geometry, keep = 0.9) |> list(), by = scinam]
  r[!(ok), ok := st_is_valid(geometry), by = scinam]

  # FIX using planar geom
  sf_use_s2(FALSE)
  r[(!ok),   geometry := st_make_valid(geometry) |> list(), by = scinam]
  sf_use_s2(TRUE)

  r = st_as_sf(r)

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



#* rangeMapper
  con = rmap_connect(path = path_lightness_rangemapper)

  rmap_add_ranges(con, x = r, ID = "scinam")


  plan(multisession, workers = 88)
  handlers(global = TRUE)

  rmap_prepare(con, "hex", cellsize = 0.5, chunksize=  0.01)

  # add bio table
  lightness = copy(x)
  rmap_add_bio(con, lightness, "scinam")

  rmap_save_map(con)

  rmap_save_map(con,
    fun = "avg", src = "lightness", v = "lightness_females",
    dst = "mean_lightness"
  )




#+ MAP
  con = rmap_connect(path = path_lightness_rangemapper)
  
  m = rmap_to_sf(con) |> filter(species_richness > 5)


  colour_ramp_alpha = function(x, alpha) {

    transp <<- alpha

    ramp <- colorRamp(x)
    function(n) {
      x <- ramp(seq.int(0, 1, length.out = n))
      rgb(x[, 1L], x[, 2L], x[, 3L], maxColorValue = 255) |>
      colorspace::adjust_transparency(alpha = transp)
    }

  }

  col_lightness = c("#CB657B", "#9A769C", "#AC9CB0", "#C1956E", "#FBFCFC") |> colour_ramp_alpha(0.8)
  col_dem       = c("#000000", "#525252", "#969696", "#BDBDBD", "#F0F0F0", "#FFFFFF") 
  col_oceans    = "#1f242c"
  col_land      = "#e0e9f7"


  # lightness
  agg_png(path_lightness_export, width = 4096, height = 2048)

  plot(dem, mar = c(0, 0, 0, 0), legend = FALSE, axes = FALSE, col = "#4e4b4b", background = "#4e4b4b")
  plot(m["avg_lightness_females"], add = TRUE, pal = col_lightness, breaks = "fisher", border = NA, alpha = 0.2)
  plot(oceans, add = TRUE, col = col_oceans, border = col_oceans)
  plot(land,   add = TRUE, col = NA, border = col_land)
  plot(rivers, add = TRUE, col = col_oceans, border = NA, size = 0.05)


  dev.off()
