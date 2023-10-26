"""Command line tool to apply the Otsu threshold to a raster"""
import click
import numpy as np
from osgeo import gdal
from skimage.filters import threshold_otsu
from loguru import logger

gdal.UseExceptions()

def threshold(data):
    """Returns the Otsu threshold of a numpy array"""
    return data > threshold_otsu(data[np.isfinite(data)])


@click.command(
    short_help="Otsu threshoold",
    help="Applies the Otsu threshold",
)
@click.argument("raster", nargs=1)
def otsu(raster):
    """Applies the Otsu threshold"""

    logger.info(f"Applying the Otsu threshold to {raster}")
    ds = gdal.Open(raster)

    driver = gdal.GetDriverByName("GTiff")

    dst_ds = driver.Create(
        "otsu.tif",
        ds.RasterXSize,
        ds.RasterYSize,
        1,
        gdal.GDT_Byte,
        options=["TILED=YES", "COMPRESS=DEFLATE", "INTERLEAVE=BAND"],
    )

    dst_ds.SetGeoTransform(ds.GetGeoTransform())
    dst_ds.SetProjection(ds.GetProjectionRef())

    array = ds.GetRasterBand(1).ReadAsArray().astype(float)

    dst_ds.GetRasterBand(1).WriteArray(threshold(array))
    dst_ds.GetRasterBand(1).SetNoDataValue(0)

    dst_ds = None
    ds = None

    logger.info("Done!")

if __name__ == "__main__":
    otsu()
