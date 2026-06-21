library("move2")
library("terra")
library("sf")
library("zip")
library("ggplot2")
library("terrainr")

rFunction = function(data, check_extent, plot_option, plot_geometry,mycol, mlegend, width_pl) {
  
  if (sf::st_crs(data) != sf::st_crs("EPSG:4326")) {
    logger.info("The tracking data are not in EPSG:4326. Reprojecting them to EPSG:4326 to match the custom basemap.")
    data_ll <- sf::st_transform(data, crs = "EPSG:4326")
  } else {
    data_ll <- data
  }
  
  full_bbox <- sf::st_bbox(data_ll)
  ext_poly  <- sf::st_as_sf(sf::st_as_sfc(full_bbox))
  sf::st_write(ext_poly, appArtifactPath("tracks_extent_polygon.gpkg"), driver = "GPKG", delete_dsn = TRUE, quiet = TRUE)
  
  ## read & prepare the custom background map ##
  custombm <- getAuxiliaryFilePath("custombm")
  # custombm <- "./data/auxiliary/user-files/uploaded-app-files/save3.tiff"
  
  if (is.null(custombm) || !file.exists(custombm)) {
    logger.fatal("No custom background map (geotiff) was provided. Please upload a geotiff file containing the background map.")
  } else {
    
    bm <- terra::rast(custombm)
    if (!terra::same.crs(bm, "EPSG:4326")) {
      terra::crs(bm) <- "EPSG:4326"
      logger.info(paste(
        "The uploaded custom background map did not have CRS EPSG:4326 so it was assigend to it.",
        "NOTE: this assigns the CRS without reprojecting the raster cells, assuming the raster is already stored in lon/lat coordinates."
      ))
    }
    
    ## function draw all tracks on one map
    make_plot_all_tracks <- function(trk_data, file, main, show_legend) {
      id_col <- sym(mt_track_id_column(data))
      p <- ggplot() +
        geom_spatial_rgb(data = bm, aes(x = x, y = y, r = red, g = green, b = blue))
      
      # track lines (built with mt_track_lines(); skip if unavailable / empty)
      if (plot_geometry=="lines_points") {
        p <- p + 
          geom_sf(data=mt_track_lines(trk_data), aes(color=!!id_col))+
          geom_sf(data=trk_data, aes(color=!!id_col))
      }
      # optionally draw the locations (points) on top of the lines
      if (plot_geometry=="lines") {
        p <- p + 
          geom_sf(data=mt_track_lines(trk_data), aes(color=!!id_col))
      }
      
      if(!check_extent){
        dbbox <- st_bbox(trk_data)
        p <- p +
          coord_sf(xlim = c(dbbox[1],dbbox[3]), ylim = c(dbbox[2],dbbox[4]), expand = T)
        
        x_range <- dbbox[3] - dbbox[1]
        y_range <- dbbox[4] - dbbox[2]
        asp     <- y_range / x_range
        width_mm  <- width_pl
        height_mm <- width_mm * asp
      }
      p <- p +
        labs(title = main, x = NULL, y = NULL) +
        theme(
          panel.background = element_rect(fill = "white", color = "black"),
          legend.position = if (isTRUE(show_legend)) "right" else "none")
      
      ggsave(filename = file, plot = p, width = width_mm, height = height_mm, units="mm",
             dpi = 300, limitsize = FALSE)
    }
    ## function draw each track on one single map
    make_plot_per_track <- function(trk_data) {
      
      trk_id <- unique(mt_track_id(trk_data))
      
      p <- ggplot() +
        geom_spatial_rgb(data = bm, aes(x = x, y = y, r = red, g = green, b = blue))
      if (plot_geometry=="lines_points") {
        p <- p + 
          geom_sf(data=mt_track_lines(trk_data), color=mycol)+
          geom_sf(data=trk_data, color=mycol)
      }
      if (plot_geometry=="lines") {
        p <- p + 
          geom_sf(data=mt_track_lines(trk_data), color=mycol)
      }
      
      if(plot_option == "track_extent"){
        dbbox <- st_bbox(trk_data)
        p <- p +
          coord_sf(xlim = c(dbbox[1],dbbox[3]), ylim = c(dbbox[2],dbbox[4]), expand = T)
        
        x_range <- dbbox[3] - dbbox[1]
        y_range <- dbbox[4] - dbbox[2]
        asp     <- y_range / x_range
        width_mm  <- width_pl
        height_mm <- width_mm * asp
      }
      
      if(plot_option == "total_extent"){
        dbbox <- st_bbox(data_ll)
        p <- p +
          coord_sf(xlim = c(dbbox[1],dbbox[3]), ylim = c(dbbox[2],dbbox[4]), expand = T)
        
        x_range <- dbbox[3] - dbbox[1]
        y_range <- dbbox[4] - dbbox[2]
        asp     <- y_range / x_range
        width_mm  <- width_pl
        height_mm <- width_mm * asp
      }
      
      p <-  p +
        ggplot2::labs(title = trk_id, x = NULL, y = NULL) +
        ggplot2::theme(
          panel.background = ggplot2::element_rect(fill = "white", color = "black"),
          legend.position = "none")
      valid_trk_id <- make.names(trk_id)
      ggsave(filename = paste0(targetDirFiles,"/",valid_trk_id,".png"), plot = p, width = width_mm, height = height_mm, units="mm", dpi = 300, limitsize = FALSE)
    }
    
    ## output depends on settings selection
    if(check_extent){
      height_mm <-  210
      width_mm <- 297
      make_plot_all_tracks(
        trk_data = data_ll, 
        file = appArtifactPath("basemap_tracks_overview.png"), 
        main = "All tracks on custom basemap (full extent)",
        show_legend = F)
      logger.info("'Quick check of extent & projection' is selected: plotting all tracks on the custom basemap to verify extent & projection. All other plotting options are ignored.")
    }else{
      ## plot per track, extent of each track
      if(plot_option == "track_extent"){
        make_plot_all_tracks(
          trk_data = data_ll, 
          file = appArtifactPath("all_tracks.png"), 
          main = "",
          show_legend = mlegend)
        
        dir.create(targetDirFiles <- tempfile())
        lapply(split(data_ll, mt_track_id(data_ll)),  make_plot_per_track)
        zip_file <- appArtifactPath("tracks_own_extent.zip")
        zip::zip(zip_file,
                 files = list.files(targetDirFiles, full.names = TRUE),
                 mode = "cherry-pick")
      }
      ## plot per track, extent of dataset of tracks
      if(plot_option == "total_extent"){
        make_plot_all_tracks(
          trk_data = data_ll, 
          file = appArtifactPath("all_tracks.png"), 
          main = "",
          show_legend = mlegend)
        
        dir.create(targetDirFiles <- tempfile())
        lapply(split(data_ll, mt_track_id(data_ll)),  make_plot_per_track)
        zip_file <- appArtifactPath("tracks_full_extent.zip")
        zip::zip(zip_file,
                 files = list.files(targetDirFiles, full.names = TRUE),
                 mode = "cherry-pick")
      }
      if(plot_option == "both"){
        make_plot_all_tracks(
          trk_data = data_ll, 
          file = appArtifactPath("all_tracks.png"), 
          main = "",
          show_legend = mlegend)
        
        plot_option <- "track_extent"
        dir.create(targetDirFiles <- tempfile())
        lapply(split(data_ll, mt_track_id(data_ll)),  make_plot_per_track)
        zip_file <- appArtifactPath("tracks_own_extent.zip")
        zip::zip(zip_file,
                 files = list.files(targetDirFiles, full.names = TRUE),
                 mode = "cherry-pick")
        
        unlink(list.files(targetDirFiles, full.names = TRUE, recursive = TRUE))
        plot_option <- "total_extent"
        dir.create(targetDirFiles <- tempfile())
        lapply(split(data_ll, mt_track_id(data_ll)),  make_plot_per_track)
        zip_file <- appArtifactPath("tracks_full_extent.zip")
        zip::zip(zip_file,
                 files = list.files(targetDirFiles, full.names = TRUE),
                 mode = "cherry-pick")
        
      }
      if(plot_option == "all_tracks"){
        make_plot_all_tracks(
          trk_data = data_ll, 
          file = appArtifactPath("all_tracks.png"), 
          main = "",
          show_legend = mlegend)
      }
    }
  }
  return(data)
}
