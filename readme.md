# SliceNicer

SliceNicer is an ImageJ macro for normalization of time lapse images against a t0 reference image

## Content

- Content
- [Screenshot](#Screenshot)
- [Usage](#Usage)
- [Getting started](#Getting-started)
    - [Notes](#Notes)
    - [Download](#Download)
    - [Installation](#Installation)

## Screenshot

<img alt="Screenshot" src=".assets/screenshot.png">

## Usage

1. Import `.lsm` file (containing the timelapse) into ImageJ
2. Choose a line ROI which represents the image (e.g. 1000px length and 1000px width) and save it via the ROI manager as .roi file
3. Note which image should be used as reference for normalisation
Close all windows except the main ImageJ window.
4. You should now have two files
    - the `.lsm` file
    - the `.roi` file
5. Open the macro via <kbd>Plugins > SliceNicer</kbd>
6. Adjust settings:
    - Username: the username of the user who is logged on to the computer.
    - Input file: the present `.lsm` file
    - ROI file: the present `.roi` file
    - Output directory: the directory where the export folder containing all output files will be created (if the default directory is chosen, the folder content will be overwritten with each application)
    - Reference image: the number of the previously noted reference image (for the first image: 1)
    - Load stack after processing: Keeping this checked is recommended, this will:
        - load all normalized images as hyperstack
        - save the hyperstack as `.tiff` file
        - create timelapse videos of all channels of the hyperstack

## Getting started 

### Notes

- The input file must be in `.tiff` format or any other TIFF dependent format (e.g. `.lsm`)

### Download

<a href="https://github.com/danielbarleben/SliceNicer/slicenicer.ijm">SliceNicer.ijm - September 6, 2022 - 12 KB</a>

### Installation

1. Download the latest macro version using the download button.
2. Open ImageJ or Fiji
3. Go to <kbd>Plugins > Install...</kbd> and select the downloaded SliceNicer.ijm file.
4. Close and reopen ImageJ
5. The macro can now be found under Plugins (at the bottom of the dropdown menu)




