CellProfiler Pipeline: http://www.cellprofiler.org
Version:1
SVNRevision:11710

LoadImages:[module_num:1|svn_version:\'11587\'|variable_revision_number:11|show_window:False|notes:\x5B\'load seeded image (white dots on identified_objects image)\'\x5D]
    File type to be loaded:individual images
    File selection method:Text-Exact match
    Number of images in each group?:3
    Type the text that the excluded images have in common:Do not use
    Analyze all subfolders within the selected folder?:None
    Input image file location:Default Input Folder\x7CC\x3A\\Users\\Deena\\Dropbox (MIT)\\UROPs\\UROP_images\\Jacky\\Training\\artifacts_removed
    Check image sets for missing or duplicate files?:Yes
    Group images by metadata?:No
    Exclude certain files?:No
    Specify metadata fields to group by:
    Select subfolders to analyze:
    Image count:1
    Text that these images have in common (case-sensitive):Colony
    Position of this image in each group:1
    Extract metadata from where?:None
    Regular expression that finds metadata in the file name:^(?P<Plate>.*)_(?P<Well>\x5BA-P\x5D\x5B0-9\x5D{2})_s(?P<Site>\x5B0-9\x5D)
    Type the regular expression that finds metadata in the subfolder path:.*\x5B\\\\/\x5D(?P<Date>.*)\x5B\\\\/\x5D(?P<Run>.*)$
    Channel count:1
    Group the movie frames?:No
    Grouping method:Interleaved
    Number of channels per group:3
    Load the input as images or objects?:Images
    Name this loaded image:seeded
    Name this loaded object:seeds
    Retain outlines of loaded objects?:No
    Name the outline image:NucleiOutlines
    Channel number:1
    Rescale intensities?:Yes

ColorToGray:[module_num:2|svn_version:\'10318\'|variable_revision_number:2|show_window:False|notes:\x5B\'converts color image to grayscale\'\x5D]
    Select the input image:seeded
    Conversion method:Combine
    Image type\x3A:RGB
    Name the output image:OrigGray
    Relative weight of the red channel:1
    Relative weight of the green channel:1
    Relative weight of the blue channel:1
    Convert red to gray?:Yes
    Name the output image:OrigRed
    Convert green to gray?:Yes
    Name the output image:OrigGreen
    Convert blue to gray?:Yes
    Name the output image:OrigBlue
    Channel count:1
    Channel number\x3A:Red\x3A 1
    Relative weight of the channel:1
    Image name\x3A:Channel1

ApplyThreshold:[module_num:3|svn_version:\'6746\'|variable_revision_number:5|show_window:False|notes:\x5B\'converts grayscale to binary (only seeds/"nuclei" remain in image)\'\x5D]
    Select the input image:OrigGray
    Name the output image:seedsonly
    Select the output image type:Binary (black and white)
    Set pixels below or above the threshold to zero?:Below threshold
    Subtract the threshold value from the remaining pixel intensities?:No
    Number of pixels by which to expand the thresholding around those excluded bright pixels:0.0
    Select the thresholding method:Manual
    Manual threshold:0.95
    Lower and upper bounds on threshold:0.000000,1.000000
    Threshold correction factor:1
    Approximate fraction of image covered by objects?:0.01
    Select the input objects:None
    Two-class or three-class thresholding?:Two classes
    Minimize the weighted variance or the entropy?:Weighted variance
    Assign pixels in the middle intensity class to the foreground or the background?:Foreground
    Select the measurement to threshold with:Scaling

ConserveMemory:[module_num:4|svn_version:\'9401\'|variable_revision_number:1|show_window:False|notes:\x5B\x5D]
    Specify which images?:Images to keep
    Select image to keep:seedsonly
    Select image to keep:OrigGray

IdentifyPrimaryObjects:[module_num:5|svn_version:\'10826\'|variable_revision_number:8|show_window:False|notes:\x5B\x5D]
    Select the input image:seedsonly
    Name the primary objects to be identified:seeds
    Typical diameter of objects, in pixel units (Min,Max):10,1000000
    Discard objects outside the diameter range?:Yes
    Try to merge too small objects with nearby larger objects?:No
    Discard objects touching the border of the image?:Yes
    Select the thresholding method:Otsu Global
    Threshold correction factor:1
    Lower and upper bounds on threshold:0.1,1.0
    Approximate fraction of image covered by objects?:0.01
    Method to distinguish clumped objects:None
    Method to draw dividing lines between clumped objects:Intensity
    Size of smoothing filter:10
    Suppress local maxima that are closer than this minimum allowed distance:7
    Speed up by using lower-resolution image to find local maxima?:Yes
    Name the outline image:PrimaryOutlines
    Fill holes in identified objects?:No
    Automatically calculate size of smoothing filter?:Yes
    Automatically calculate minimum allowed distance between local maxima?:Yes
    Manual threshold:0.0
    Select binary image:seeded
    Retain outlines of the identified objects?:No
    Automatically calculate the threshold using the Otsu method?:Yes
    Enter Laplacian of Gaussian threshold:0.5
    Two-class or three-class thresholding?:Two classes
    Minimize the weighted variance or the entropy?:Weighted variance
    Assign pixels in the middle intensity class to the foreground or the background?:Foreground
    Automatically calculate the size of objects for the Laplacian of Gaussian filter?:Yes
    Enter LoG filter diameter:5
    Handling of objects if excessive number of objects identified:Truncate
    Maximum number of objects:10000000
    Select the measurement to threshold with:None

IdentifySecondaryObjects:[module_num:6|svn_version:\'10826\'|variable_revision_number:7|show_window:False|notes:\x5B\x5D]
    Select the input objects:seeds
    Name the objects to be identified:cells
    Select the method to identify the secondary objects:Propagation
    Select the input image:OrigGray
    Select the thresholding method:Otsu Global
    Threshold correction factor:1
    Lower and upper bounds on threshold:0.1,1.0
    Approximate fraction of image covered by objects?:0.01
    Number of pixels by which to expand the primary objects:10
    Regularization factor:0.05
    Name the outline image:SecondaryOutlines
    Manual threshold:0.0
    Select binary image:None
    Retain outlines of the identified secondary objects?:No
    Two-class or three-class thresholding?:Two classes
    Minimize the weighted variance or the entropy?:Weighted variance
    Assign pixels in the middle intensity class to the foreground or the background?:Foreground
    Discard secondary objects that touch the edge of the image?:No
    Discard the associated primary objects?:No
    Name the new primary objects:FilteredNuclei
    Retain outlines of the new primary objects?:No
    Name the new primary object outlines:FilteredNucleiOutlines
    Select the measurement to threshold with:None
    Fill holes in identified objects?:Yes

ExpandOrShrinkObjects:[module_num:7|svn_version:\'10830\'|variable_revision_number:1|show_window:False|notes:\x5B\'the original segmentation pipeline (up to v3) did not have expand module. when overlaying the outline, tiny fragments of the cell would get split off because the outline is overlayed on inside of object (thereby systematically shrinking all cells AND potentially creating artifacts)\'\x5D]
    Select the input objects:cells
    Name the output objects:Expanded cell
    Select the operation:Expand objects by a specified number of pixels
    Number of pixels by which to expand or shrink:5
    Fill holes in objects so that all objects shrink to a single point?:No
    Retain the outlines of the identified objects for use later in the pipeline (for example, in SaveImages)?:Yes
    Name the outline image:expandedcelloutline

ConvertObjectsToImage:[module_num:8|svn_version:\'10807\'|variable_revision_number:1|show_window:False|notes:\x5B\'select cells, NOT expanded cells. we want to overlay our expanded cell outline onto our original cell images so that cells dont get shrunken\'\x5D]
    Select the input objects:cells
    Name the output image:CellImage
    Select the color type:Color
    Select the colormap:Default

OverlayOutlines:[module_num:9|svn_version:\'10672\'|variable_revision_number:2|show_window:False|notes:\x5B\x5D]
    Display outlines on a blank image?:No
    Select image on which to display outlines:CellImage
    Name the output image:OrigOverlay
    Select outline display mode:Color
    Select method to determine brightness of outlines:Max of image
    Width of outlines:5
    Select outlines to display:expandedcelloutline
    Select outline color:Black

SaveImages:[module_num:10|svn_version:\'10822\'|variable_revision_number:7|show_window:False|notes:\x5B\x5D]
    Select the type of image to save:Image
    Select the image to save:OrigOverlay
    Select the objects to save:cells
    Select the module display window to save:3\x3A IdentifyPrimaryObjects
    Select method for constructing file names:From image filename
    Select image name for file prefix:seeded
    Enter single file name:OrigBlue
    Do you want to add a suffix to the image file name?:No
    Text to append to the image name:Do not use
    Select file format to use:png
    Output file location:Default Output Folder\x7CC\x3A\\\\Users\\\\Deena\\\\Google Drive\\\\Chemomechanics_Lab_Temp\\\\temp_image_processing\\\\Prelim_5_Spot_11\\\\Spot 1\\\\Montaged\\\\tracked_9_10_14
    Image bit depth:8
    Overwrite existing files without warning?:Yes
    Select how often to save:Every cycle
    Rescale the images? :No
    Save as grayscale or color image?:Color
    Select colormap:Dark2
    Store file and path information to the saved image?:No
    Create subfolders in the output folder?:No
