# Plot With Custom Basemap

MoveApps

Github repository: *github.com/yourAccount/plot_with_costum_basemap*

## Description
Plots tracking data on a user-supplied custom background map (geotiff). Instructions how to create a custom map below. 

## Documentation
The App overlays the tracking data on a custom background map that the user uploads as a geotiff auxiliary file. The tracks can be all plotted on one map, or each track on a single map. To facilitate the creation of the background map, the App produces a polygon of the extent of all data and also a plot to check if the background map overlaps correctly with the tracks.

#### Instructions to create custom background map
Here are the instructions for QGIS, but the same principal can be applied to any GIS software. The saved map has to be a tiff (geotiff) file that maintains the spatial information.      
**In QGIS**:              
- Run this App once to produce the output `tracks_extent_polygon.gpkg` which contains a polygon of the extent of all tracks. This can be used in QGIS to ensure that your background plot covers the entire area of the tracking data (if this is desired). Remember to unselect the layer before saving the map, so it does not show on the saved image.          
- ensure that the projection of the map is the one expected by the APP: *project* > *properties* > *crs* select *"EPSG:4326"*.              
- personalize map, use many layers as you which, chose shape, size and colors for each layer. There is no limitation in number or type. You can also add basemaps        
- zoom in/out as you want, the area you see on GQIS, will be area exported. Taher make it a bit larger, the App will then clip the match to match the tracks.       
- save the map as georeferenciated image: *project* > *import/export* > *export map to image* > ensure that *append georeference information* is checked, and set an appropiate resolution (this might need some trail and error, but depending on the size 200-300 dpi should mostly wok) > *save* > give a name and save as tiff (choose TIFF format from the extentions at the bottom right) > *save*        




The App has two modes:

1. **Quick check of extent & projection** (`check_extent`): produces a single map (`basemap_tracks_overview.png`) with all tracks overlaid on the custom basemap. This is a fast sanity check that the basemap covers the data and that the projections line up. When this option is enabled, all other plotting options are ignored. This overview is saved at a fixed A4-landscape size and without a legend.

2. **What should be plotted** (`plot_option`): used when `check_extent` is `FALSE`. Every option produces the overview map `all_tracks.png` (all tracks on one map at the full dataset extent, coloured per track_id, legend controlled by `mlegend`). Depending on the option, one png per track is additionally produced and bundled into a zip:
   - **`track_extent`** — one map per track, each zoomed to that track's own extent → `all_tracks.png` + `tracks_own_extent.zip`
   - **`total_extent`** — one map per track, all using the full extent of the entire dataset → `all_tracks.png` + `tracks_full_extent.zip`
   - **`both`** — both per-track variants → `all_tracks.png` + `tracks_own_extent.zip` + `tracks_full_extent.zip`
   - **`all_tracks`** — only the overview map → `all_tracks.png`

In the per-track maps, every track is drawn in a single colour (`mycol`) and the map title is the `track_id`; these maps never carry a legend. The png file inside each zip is named after the `track_id`.

### Application scope
#### Generality of App usability
This App was developed for any taxonomic group

#### Required data properties
The App works for any (location) data. A custom background map (geotiff) covering (at least part of) the data region must be supplied.

### Input type
`move2::move2_loc`

### Output type
`move2::move2_loc`

### Artefacts
- `tracks_extent_polygon.gpkg`: GeoPackage polygon of the bounding-box extent of all tracks (EPSG:4326). Always produced.
- `basemap_tracks_overview.png`: single map with all tracks on the custom basemap. This image will contain the supplied map and the tracking data without any changes in the extent. This is useful to check if suplied map and track data overlap as intended before creating all plots. This image will always have DINa4 size.
- `all_tracks.png`: overview map with all tracks on the custom basemap clipped to the extent of the tracking data.
- `tracks_own_extent.zip`: one png per track, each zoomed to that track's own extent.
- `tracks_full_extent.zip`: one png per track, all using the full dataset extent. 

### Settings
- `Quick check of extent & projection` (`check_extent`): If `TRUE`, only the quick-check overview (`basemap_tracks_overview.png`) and the extent GeoPackage are produced, and all other plotting options are ignored. Default: `TRUE`.
- `What should be plotted` (`plot_option`): 
Every option produces the overview map `all_tracks.png` (all tracks on one map at the full dataset extent, coloured per track_id, legend controlled by `mlegend`)
        `track_extent`: one map per track, each zoomed to that track's own extent
        `total_extent`: one map per track, all using the full extent of the entire dataset
        `both`
        `all_tracks`
        
        (see Documentation). Ignored when `check_extent` is `TRUE`. Default: `track_extent`.
used when `check_extent` is `FALSE`. Every option produces the overview map `all_tracks.png` (all tracks on one map at the full dataset extent, coloured per track_id, legend controlled by `mlegend`). Depending on the option, one png per track is additionally produced and bundled into a zip:
   - **`track_extent`** — one map per track, each zoomed to that track's own extent → `all_tracks.png` + `tracks_own_extent.zip`
   - **`total_extent`** — one map per track, all using the full extent of the entire dataset → `all_tracks.png` + `tracks_full_extent.zip`
   - **`both`** — both per-track variants → `all_tracks.png` + `tracks_own_extent.zip` + `tracks_full_extent.zip`
   - **`all_tracks`** — only the overview map → `all_tracks.png`



- `What to draw for each track` (`plot_geometry`): `lines_points` (lines with locations drawn on top) or `lines` (lines only). Default: `lines_points`.
- `Include legend in the overview map` (`mlegend`): checkbox. Whether `all_tracks.png` includes a legend of track_id → colour. Does not affect the quick-check overview or the per-track maps. Default: `TRUE`.
- `Colour of the per-track maps` (`mycol`): string. R colour name used to draw the tracks in the per-track maps (the maps inside the zips). Default: `black`.
- `Map width (mm)` (`width_pl`): integer. Width in millimetres of the saved maps; the height is derived from the data aspect ratio. The quick-check overview ignores this and uses a fixed A4-landscape size. Default: `200`.
- `Custom background map (geotiff)` (`custombm`): the geotiff background map uploaded by the user as an auxiliary file. Read with `terra::rast()` and expected to be in lon/lat (EPSG:4326). If it carries no/another CRS, EPSG:4326 is assigned to it (without reprojecting the cells) and the user is informed in the log.

### Changes in output data
The input data remains unchanged; it is passed on to the next App as received.

### Most common errors
- **No basemap provided / wrong file type:** if no `custombm` geotiff is available, the App logs a fatal message and produces only the extent GeoPackage (no maps). Make sure to upload a geotiff file.
- **Basemap and data do not overlap / tracks not visible on the basemap:** usually a projection or extent mismatch. Use the quick check (`check_extent = TRUE`) and the exported `tracks_extent_polygon.gpkg` to align the basemap to the data in QGIS.

### Null or error handling
- **Setting `custombm`:** if missing or the file does not exist, the App logs a fatal message and returns the input data unchanged (only the extent GeoPackage is written; no maps are produced).
- **Setting `check_extent`:** when `TRUE`, overrides `plot_option` and all other plotting settings.
- **Basemap CRS not EPSG:4326:** EPSG:4326 is assigned (no reprojection of cells) and a message is written to the log.
- **Tracking data CRS not EPSG:4326:** the data are reprojected to EPSG:4326 and a message is written to the log.
