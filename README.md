# Plot Tracks On Custom Basemap

MoveApps

Github repository: *https://github.com/movestore/plot_on_costum_basemap*

## Description

Plots tracking data on a user-supplied custom background map (geotiff). Instructions how to create a custom map below.

## Documentation

The App overlays the tracking data on a custom background map that the user uploads as a geotiff auxiliary file. The tracks can be all plotted on one map, or each track on a single map. To facilitate the creation of the background map, the App produces a polygon of the extent of all tracking data and also a plot to check if the background map overlaps correctly with the tracks. 
The tracks can be plotted as lines or lines and points. For the single track maps the color of the lines and points can be defined. For the plots of all tracks, each track will be assigned with a color.

**Instructions to create custom background map**

Here are the instructions for *QGIS*, but the same principal can be applied to any GIS software. The saved map has to be a tiff (geotiff) file that maintains the georeference information.

1.   Run this App once to produce the output `tracks_extent_polygon.gpkg` which contains a polygon of the extent of all tracks. This can be used in QGIS to ensure that your background plot covers the entire area of the tracking data (if this is desired). Remember to unselect the layer before saving the map, so it does not show on the saved image.
2.   ensure that the projection of the map is the one expected by the APP: *project* \> *properties* \> *crs* select "EPSG:4326".
3.   personalize map, use many layers as you which, chose shape, size and colors for each layer. There is no limitation in number or type. You can also add basemaps
4.   zoom in/out as you want, the area you see on GQIS, will be area exported. Rather make it a bit larger, the App will then clip the match to match the tracks.
5.   save the map as georeferenciated image: *project* \> *import/export* \> *export map to image* \> ensure that *append georeference information* is checked, and set an appropriate resolution (this might need some trail and error, but depending on the size 200-300 dpi should mostly wok) \> *save* \> give a name and choose TIFF format from the extensions at the bottom right \> *save*


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

`tracks_extent_polygon.gpkg`: GeoPackage polygon of the bounding-box extent of all tracks (EPSG:4326). Always produced.     

`basemap_tracks_overview.png`: single map with all tracks on the custom basemap. This image will contain the supplied map and the tracking data without any changes in the extent. This is useful to check if supplied map and track data overlap as intended before creating all plots. This image will always have landscape DIN-A4 size.     

`all_tracks.png`: overview map with all tracks on the custom basemap clipped to the extent of the tracking data.     

`tracks_own_extent.zip`: one png per track, each zoomed to that track's own extent.    

`tracks_full_extent.zip`: one png per track, all using the full dataset extent.    

### Settings

`Custom background map` (custombm): Upload a customized background map as a geotiff file (e.g. `.tif`). The map is expected to be in lon/lat (EPSG:4326). If it carries no/another CRS, EPSG:4326 is assigned to it (without reprojecting the cells) and the user is informed in the logs.

`Quick check of extent & projection` (check_extent): Obtain map with all tracks on the custom basemap. This image will contain the supplied map and the tracking data without any changes in the extent. This is useful to check if supplied map and track data overlap as intended before creating all plots. When this option is checked all other plotting options below are ignored.

`Choose plot type` (plot_option): Choose which maps to produce.      
-   *Map per track, zoomed to extent of each track*: each track is on a single map, the extent of the map corresponds to the track, maps are output as png and delivered in a zip file. One map with all tracks are output as a png.     
-   *Map per track, extent of dataset*: each track is on a single map, the extent of the map corresponds to all tracks, maps are output as png and delivered in a zip file. One map with all tracks are output as a png.     
-   *Map per track, extent of each track & of dataset*: both of the above options are produced.    
-   *Only the map with all tracks*: only the map with all tracks as a png is produced. The extent of the map corresponds to the extent of all tracks.    

`Plot as lines with/without points` (plot_geometry): Choose whether each track is drawn as lines only, or as lines and points.

`Include legend on map with all tracks` (mlegend): Each track will be assigned a color, check this box to view the legend.

`Colour of the tracks in the per-track maps` (mycol): Color used to draw the tracks in the per-track maps. Provide an colour name (e.g. 'black', 'red', 'darkblue'). The list of recognised colour names can be found for example here https://r-charts.com/colors/. Default: `black`.

`Map width (mm)` (width_pl): Width, in millimetres, of the saved maps. The height is derived automatically from the data aspect ratio. Default: `297` (width of A4).

### Changes in output data

The input data remains unchanged.

### Most common errors

**No basemap provided:** if no basemap is provided the App only produces the extent polygon.

**Basemap and data do not overlap / tracks not visible on the basemap:** usually a projection or extent mismatch. Use the setting `Quick check of extent & projection` to check the basemap and the track data overlap.

### Null or error handling
