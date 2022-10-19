# OSM Bright but Desaturated

A fork of the OSM Bright style with muted colors to match the CSS transforms in Kibana.

A Mapbox GL basemap style showcasing OpenStreetMap. It is using the vector tile schema of [OpenMapTiles](https://github.com/openmaptiles/openmaptiles).

## Building the style

The `style.json` file is the result of the combination of the different styles from the `layers` folder with the `style-header.json` file, following the OpenMaptiles schema. 

To generate this file you need to run the `style.json` target from the Makefile. 

## Splitting the style

If you edit the style from an external tool like the [Elastic Basemaps editor](https://elastic.github.io/ems-basemap-editor/), or bringing changes from upstream, you need to split the style again into layers using the `split` target of the Makefile.
