#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os, json, argparse

print os.getcwd()

parser = argparse.ArgumentParser(description='Convert color assets from storyboards and xibs')
parser.add_argument('--colorSpace', dest="color_space",
          type=str,
          default="calibratedRGB", 
          nargs='?',
          help="Default colorSpace string (default: calibratedRGB)") #calibratedRGB

colorDict = {}

def custom_color_space(space):
    return 'colorSpace="custom" customColorSpace="{}"'.format(space)

args = parser.parse_args()

colorSpaceMap = {
    'calibratedrgb': 'colorSpace="calibratedRGB"',
    'srgb': custom_color_space("sRGB"),
    'displayP3': custom_color_space("displayP3"),
    'calibratedwhite': custom_color_space("calibratedWhite"),
}

defaultColorSpace = colorSpaceMap.get(args.color_space.lower())

# read all colorset
for root, dirs, files in os.walk("./"):
    for d in dirs:
        if d.endswith(".colorset"):
            colorK = d.split(".")[0]
            print "found " + colorK
            for file in files:
                if file == "Contents.json":
                    f = open(os.path.join(root, d, file))
                    jd = json.load(f)
                    color = jd["colors"][0]["color"]
                    rgb = color["components"]
                    colorSpace = color["color-space"]
                    if not colorSpace:
                        colorSpace = defaultColorSpace
                    else:
                        colorSpace = colorSpaceMap.get(colorSpace)

                    colorDict[colorK] = 'name="{}" red="{}" green="{}" blue="{}" alpha="{}" {}'.format(colorK, rgb["red"], rgb["green"], rgb["blue"], rgb["alpha"], colorSpace)

print ""
import re

# replacing
for root, dirs, files in os.walk("./"):
    for file in files:
        if file.endswith((".storyboard", ".xib")):
            path = os.path.join(root, file)
            print "Replacing namedColor in " + path
            f = open(path)
            nf = f.read()
            f.close()

            nf = re.sub(r" +<namedColor name=.*\n.*\n +</namedColor>\n", '', nf)
            nf = re.sub(r" +<capability name=\"Named colors\" minToolsVersion=\".*\n", '', nf)

            for k, v in colorDict.items():
                nf = re.sub(r'name="{}"/>'.format(k), v + "/>", nf)

            f = open(path, 'w')
            f.write(nf)
            f.close()