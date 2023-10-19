"""Normalized difference"""
import click
from osgeo import gdal
import cv2
import numpy as np

gdal.UseExceptions()

@click.command(
    short_help="Normalized difference",
    help="Performs a normalized difference",
)
@click.argument("rasters", nargs=2)
def normalized_difference(rasters):
    """Performs a normalized difference"""
    
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

    # resizes the arrays to the biggest common size
    if array1.shape != array2.shape:
        max_x = max(array1.shape[0], array2.shape[0])
        max_y = max(array1.shape[1], array2.shape[1])
        
        resized_array1 = cv2.resize(array1, (max_x, max_y), interpolation=cv2.INTER_NEAREST)

        array1 = array1[:min_x, :min_y]
        array2 = array2[:min_x, :min_y]

    norm_diff = (array1 - array2) / (array1 + array2)

    dst_ds.GetRasterBand(1).WriteArray(norm_diff)

    dst_ds = None
    ds1 = ds2 = None

if __name__ == "__main__":
    normalized_difference()
