cwlVersion: v1.0

$namespaces:
  s: https://schema.org/
s:softwareVersion: 1.4.0
schemas:
- http://schema.org/version/9.0/schemaorg-current-http.rdf

$graph:
- class: Workflow

  id: water_bodies
  label: Water bodies detection based on NDWI and otsu threshold
  doc: Water bodies detection based on NDWI and otsu threshold

  requirements:
  - class: ScatterFeatureRequirement
  - class: SubworkflowFeatureRequirement
  
  inputs:
    aoi: 
      label: area of interest
      doc: area of interest as a bounding box
      type: string
    epsg:
      label: EPSG code
      doc: EPSG code 
      type: string
      default: "EPSG:4326"
    stac_items:
      label: Sentinel-2 STAC items
      doc: list of staged Sentinel-2 or Landsat-9 COG STAC items
      type: Directory[]
    bands: 
      label: bands used for the NDWI
      doc: bands used for the NDWI ("green" and "nir" or "green" and "nir08")
      type: string[]
      default: ["green", "nir"]

  outputs:
  - id: stac_catalog
    label: STAC Catalog with the detected water bodies STAC Items
    outputSource:
    - node_stac/stac_catalog
    type: Directory

  steps:
    node_water_bodies:
      run: "#detect_water_body"
      label: Detect water bodies over an area of interest and staged Landsat-9 or Sentinel-2 acquisitions
      in:
        item: stac_items
        aoi: aoi
        epsg: epsg
        bands: bands
      out:
      - detected_water_body
      scatter: item
      scatterMethod: dotproduct
    node_stac:
      run: "#stac"
      label: Generates a STAC catalog with the detected water bodies
      in: 
        item: stac_items
        rasters:
          source: node_water_bodies/detected_water_body
      out:
      - stac_catalog

- class: Workflow
 
  id: detect_water_body
  label: Water body detection based on NDWI and otsu threshold
  doc: Water body detection based on NDWI and otsu threshold

  requirements:
  - class: ScatterFeatureRequirement
  
  inputs:
    aoi: 
      doc: area of interest as a bounding box
      type: string
    epsg:
      doc: EPSG code 
      type: string
      default: "EPSG:4326"
    bands: 
      doc: bands used for the NDWI
      type: string[]
    item:
      doc: staged STAC item
      type: Directory

  outputs:
    - id: detected_water_body
      label: GeoTIFF with detected water body
      outputSource: 
      - node_otsu/binary_mask_item
      type: File

  steps:
    node_crop:
      run: "#crop"
      label: Crops the acquisition bands over the AOI
      in:
        item: item
        aoi: aoi
        epsg: epsg
        band: bands 
      out:
        - cropped
      scatter: band
      scatterMethod: dotproduct
    node_normalized_difference:
      run: "#norm_diff"
      label: Generates the normalized difference
      in: 
        rasters: 
          source: node_crop/cropped
      out:
      - ndwi
    node_otsu:
      run: "#otsu"
      label: "Applies the Ostu automatic threshold"
      in:
        raster:
          source: node_normalized_difference/ndwi
      out:
        - binary_mask_item

- class: CommandLineTool
  id: crop

  requirements:
    InlineJavascriptRequirement: {}
    EnvVarRequirement:
      envDef: 
        PATH: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
        PYTHONPATH: /app
    ResourceRequirement:
      coresMax: 1
      ramMax: 512

  hints:
    DockerRequirement:
      dockerPull: localhost/crop:latest

  baseCommand: ["python", "-m", "app"]
  arguments: []
  inputs:
    item:
      type: Directory
      inputBinding:
        prefix: --input-item
    aoi:
      type: string
      inputBinding:
        prefix: --aoi
    epsg:
      type: string  
      inputBinding:
        prefix: --epsg
    band:
      type: string  
      inputBinding:
        prefix: --band
  outputs: 
    cropped:
      outputBinding:
        glob: '*.tif'
      type: File

- class: CommandLineTool
  id: norm_diff

  requirements:
    InlineJavascriptRequirement: {}
    EnvVarRequirement:
      envDef: 
        PATH: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
        PYTHONPATH: /app
    ResourceRequirement:
      coresMax: 1
      ramMax: 512

  hints:
    DockerRequirement:
      dockerPull: localhost/norm_diff:latest

  baseCommand: ["python", "-m", "app"]
  arguments: []
  inputs:
    rasters:
      type: File[]
      inputBinding:
        position: 1
  outputs: 
    ndwi:
      outputBinding:
        glob: '*.tif'
      type: File

- class: CommandLineTool
  id: otsu

  requirements:
    InlineJavascriptRequirement: {}
    EnvVarRequirement:
      envDef: 
        PATH: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
        PYTHONPATH: /app
    ResourceRequirement:
      coresMax: 1
      ramMax: 512

  hints:
    DockerRequirement:
      dockerPull: localhost/otsu:latest
  
  baseCommand: ["python", "-m", "app"]
  arguments: []
  inputs:
    raster:
      type: File
      inputBinding:
        position: 1
  outputs: 
    binary_mask_item:
      outputBinding:
        glob: '*.tif'
      type: File

- class: CommandLineTool
  id: stac

  requirements:
    InlineJavascriptRequirement: {}
    EnvVarRequirement:
      envDef: 
        PATH: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
        PYTHONPATH: /app
    ResourceRequirement:
      coresMax: 1
      ramMax: 512

  hints:
    DockerRequirement:
      dockerPull: localhost/stac:latest

  baseCommand: ["python", "-m", "app"]
  arguments: []
  inputs:
    item:
      type:
        type: array
        items: Directory
        inputBinding:
          prefix: --input-item
          
    rasters:
      type:
        type: array
        items: File
        inputBinding:
          prefix: --water-body
    
  outputs: 
    stac_catalog:
      outputBinding:
        glob: .
      type: Directory