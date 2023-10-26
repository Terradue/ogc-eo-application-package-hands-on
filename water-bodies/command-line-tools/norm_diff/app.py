"""Normalized difference"""
import click
import numpy as np
from osgeo import gdal
from loguru import logger

gdal.UseExceptions()

@click.command(
    short_help="Normalized difference",
    help="Performs a normalized difference",
)
@click.argument("rasters", nargs=2)
def normalized_difference(rasters):
    """Performs a normalized difference"""
    
    logger.info(f"Processing the normalized image with {rasters[0]} and {rasters[1]}")

    # Allow division by zero
    np.seterr(divide="ignore", invalid="ignore")

    ds1 = gdal.Open(rasters[0])
    ds2 = gdal.Open(rasters[1])

    driver = gdal.GetDriverByName("GTiff")

    dst_ds = driver.Create(
        "norm_diff.tif",
        ds1.RasterXSize,
        ds1.RasterYSize,
        1,
        gdal.GDT_Float32,
        options=["TILED=YES", "COMPRESS=DEFLATE", "INTERLEAVE=BAND"],
    )

    dst_ds.SetGeoTransform(ds1.GetGeoTransform())
    dst_ds.SetProjection(ds1.GetProjectionRef())

    array1 = ds1.GetRasterBand(1).ReadAsArray().astype(float)
    array2 = ds2.GetRasterBand(1).ReadAsArray().astype(float)

    norm_diff = (array1 - array2) / (array1 + array2)

    dst_ds.GetRasterBand(1).WriteArray(norm_diff)

    dst_ds = None
    ds1 = ds2 = None

    logger.info("Done!")

if __name__ == "__main__":
    normalized_difference()
