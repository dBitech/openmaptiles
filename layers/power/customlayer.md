# Creating a layer
Attempt to document how to create a custom OpenMapTiles layer. we will ill use Powerline infrastructure to demo. 

## Create the layer

create a layer called "power"

	mkdir ~/src/github.com/openmaptiles/layers/power
	cd ~/src/github.com/openmaptiles/layers/power

Describe the layer using yaml by creating a `~/src/github.com/openmaptiles/layers/power/power.yaml` file

	layer:
	  id: "power"
	  description: |
	    ** power ** contains Powerlines, Poles/Towers, and Substation information.
	    Power lines are delivered as Lines.
	    Poles/Towers as Points.
	    Substations as Polygons.
	buffer_size: 4
	srs: +proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0.0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs +over

Now we need to create a file to map the osm tags to tables and columns this is done in a `mapping.yaml` file.
What tags as per https://wiki.openstreetmap.org/wiki/Tag:power%3Dline you see a number of tags used to define power lines. lets create a "power_line" table in `mapping.yaml`

	tables:
	  power_line:
	    type: linestring
	    columns:
	    - *ref
	    - name: osm_id
	      type: id
	    - name: geometry
	      type: geometry
	    - name: location
	      key: location
	      type: string
	    - name: line
	      key: line
	      type: string
	    - name: voltage
	      key: voltage
	      type: string
	    - name: frequency
	      key: frequency
	      type: string
	    - name: circuits
	      key: circuits
	      type: integer
	    - name: tunnel
	      key: tunnel
	      type: bool

This mapping is valid for the power=line, power=minor_line, power=cable, power=minor_cable tags

	  mapping:
	    power:
	      line
	      minor_line
	      cable
	      minor_cable


Now we need to generize this data for lower zoomlevels in the `mapping.yaml`.

	generalized_tables:
	  power_line_gen_100:
	    source: power_line
	    tolerance: 100
	    sql_filter: coalesce(convert_voltage(voltage), 0) > 100000 AND ST_length(geometry) > 200 AND line NOT IN ('bay', 'busbar')
	  power_line_gen_500:
	    source: power_line
	    tolerance: 500
	    sql_filter: coalesce(convert_voltage(voltage), 0) > 100000 AND ST_length(geometry) > 600 AND line NOT IN ('bay', 'busbar')
