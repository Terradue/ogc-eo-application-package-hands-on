from cwltool.main import main
import json
import pystac
from io import StringIO

workflow_id = "water_bodies"

params = [
            "--stac_items", 
            "https://earth-search.aws.element84.com/v0/collections/sentinel-s2-l2a-cogs/items/S2B_10TFK_20210713_0_L2A",
            "--stac_items", 
            "https://earth-search.aws.element84.com/v0/collections/sentinel-s2-l2a-cogs/items/S2A_10TFK_20220524_0_L2A",
            "--aoi=-121.399,39.834,-120.74,40.472",
            "--epsg",
            "EPSG:4326"
        ]

args = []

args.extend(["--no-container", "--parallel", "--outdir", "runs"])

#args.append(f"https://github.com/Terradue/ogc-eo-application-package-hands-on/releases/download/1.1.6/app-water-bodies.1.1.6.cwl#{workflow_id}")
args.append(f"water-bodies/app-package.cwl#{workflow_id}")

stream_out = StringIO()
stream_err = StringIO()

res = main(
    [ *args, *params],
    stdout=stream_out,
)

assert(res == 0)

stdout = json.loads(stream_out.getvalue())

with open('results.json', 'w') as f:
    json.dump(stdout, f, indent=2)

for entry in stdout["stac_catalog"]["listing"]:
    if "catalog.json" in entry["basename"]:
        catalog = pystac.read_file(entry["path"])
        break

catalog.describe()