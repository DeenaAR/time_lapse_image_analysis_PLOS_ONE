CellProfiler Pipeline: http://www.cellprofiler.org
Version:1
SVNRevision:11710

LoadImages:[module_num:1|svn_version:\'11587\'|variable_revision_number:11|show_window:False|notes:\x5B\'track_cells_quickly_v2 is meant for making sure cells track properly.  The output images are labeled with the "object numbers" rather than the usual "labels."  The output file is meant to work with track_cells_quickly.m and does not produce any figures.\'\x5D]
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
    Name this loaded image:masked
    Name this loaded object:Nuclei
    Retain outlines of loaded objects?:No
    Name the outline image:NucleiOutlines
    Channel number:1
    Rescale intensities?:Yes

ColorToGray:[module_num:2|svn_version:\'10318\'|variable_revision_number:2|show_window:False|notes:\x5B\x5D]
    Select the input image:masked
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

ApplyThreshold:[module_num:3|svn_version:\'6746\'|variable_revision_number:5|show_window:False|notes:\x5B\x5D]
    Select the input image:OrigGray
    Name the output image:ThreshBlue
    Select the output image type:Binary (black and white)
    Set pixels below or above the threshold to zero?:Below threshold
    Subtract the threshold value from the remaining pixel intensities?:No
    Number of pixels by which to expand the thresholding around those excluded bright pixels:0.0
    Select the thresholding method:Otsu Global
    Manual threshold:0.05
    Lower and upper bounds on threshold:0.1,1.0
    Threshold correction factor:1
    Approximate fraction of image covered by objects?:0.01
    Select the input objects:None
    Two-class or three-class thresholding?:Two classes
    Minimize the weighted variance or the entropy?:Weighted variance
    Assign pixels in the middle intensity class to the foreground or the background?:Foreground
    Select the measurement to threshold with:None

IdentifyPrimaryObjects:[module_num:4|svn_version:\'10826\'|variable_revision_number:8|show_window:False|notes:\x5B\x5D]
    Select the input image:ThreshBlue
    Name the primary objects to be identified:cells
    Typical diameter of objects, in pixel units (Min,Max):10,1000
    Discard objects outside the diameter range?:Yes
    Try to merge too small objects with nearby larger objects?:No
    Discard objects touching the border of the image?:No
    Select the thresholding method:Binary image
    Threshold correction factor:.3
    Lower and upper bounds on threshold:0.000000,1.000000
    Approximate fraction of image covered by objects?:0.01
    Method to distinguish clumped objects:None
    Method to draw dividing lines between clumped objects:Intensity
    Size of smoothing filter:10
    Suppress local maxima that are closer than this minimum allowed distance:7
    Speed up by using lower-resolution image to find local maxima?:Yes
    Name the outline image:PrimaryOutlines
    Fill holes in identified objects?:Yes
    Automatically calculate size of smoothing filter?:Yes
    Automatically calculate minimum allowed distance between local maxima?:Yes
    Manual threshold:0.0
    Select binary image:ThreshBlue
    Retain outlines of the identified objects?:No
    Automatically calculate the threshold using the Otsu method?:Yes
    Enter Laplacian of Gaussian threshold:0.5
    Two-class or three-class thresholding?:Two classes
    Minimize the weighted variance or the entropy?:Weighted variance
    Assign pixels in the middle intensity class to the foreground or the background?:Foreground
    Automatically calculate the size of objects for the Laplacian of Gaussian filter?:Yes
    Enter LoG filter diameter:5
    Handling of objects if excessive number of objects identified:Truncate
    Maximum number of objects:1000000000
    Select the measurement to threshold with:None

ReassignObjectNumbers:[module_num:5|svn_version:\'10887\'|variable_revision_number:1|show_window:False|notes:\x5B\x5D]
    Select the input objects:cells
    Name the new objects:RelabeledCells
    Operation to perform:Split
    Maximum distance within which to unify objects:0
    Unify using a grayscale image?:No
    Select the grayscale image to guide unification:None
    Minimum intensity fraction:0.9
    Method to find object intensity:Closest point

TrackObjects:[module_num:6|svn_version:\'10629\'|variable_revision_number:4|show_window:False|notes:\x5B\x5D]
    Choose a tracking method:Overlap
    Select the objects to track:RelabeledCells
    Select object measurement to use for tracking:None
    Maximum pixel distance to consider matches:50
    Select display option:Color Only
    Save color-coded image?:Yes
    Name the output image:TrackedCells
    Select the motion model:Both
    Number of standard deviations for search radius:3
    Search radius limit, in pixel units (Min,Max):2,10
    Run the second phase of the LAP algorithm?:2.000000,10.000000
    Gap cost:Yes
    Split alternative cost:40
    Merge alternative cost:40
    Maximum gap displacement:40
    Maximum split score:50
    Maximum merge score:50
    Maximum gap:50

DisplayDataOnImage:[module_num:7|svn_version:\'10412\'|variable_revision_number:2|show_window:False|notes:\x5B\x5D]
    Display object or image measurements?:Object
    Select the input objects:RelabeledCells
    Measurement to display:Number_Object_Number
    Select the image on which to display the measurements:TrackedCells
    Text color:white
    Name the output image that has the measurements displayed:DisplayImage
    Font size (points):15
    Number of decimals:0
    Image elements to save:Image

SaveImages:[module_num:8|svn_version:\'10822\'|variable_revision_number:7|show_window:False|notes:\x5B\x5D]
    Select the type of image to save:Image
    Select the image to save:DisplayImage
    Select the objects to save:None
    Select the module display window to save:None
    Select method for constructing file names:From image filename
    Select image name for file prefix:masked
    Enter single file name:OrigBlue
    Do you want to add a suffix to the image file name?:No
    Text to append to the image name:Do not use
    Select file format to use:jpeg
    Output file location:Default Output Folder\x7CC\x3A\\\\Users\\\\Deena\\\\Google Drive\\\\Chemomechanics_Lab_Temp\\\\temp_image_processing\\\\Prelim_5_Spot_11\\\\Spot 1\\\\Montaged\\\\tracked_9_10_14
    Image bit depth:8
    Overwrite existing files without warning?:Yes
    Select how often to save:Every cycle
    Rescale the images? :No
    Save as grayscale or color image?:Grayscale
    Select colormap:Dark2
    Store file and path information to the saved image?:No
    Create subfolders in the output folder?:No