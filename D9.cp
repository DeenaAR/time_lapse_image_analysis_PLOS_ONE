CellProfiler Pipeline: http://www.cellprofiler.org
Version:1
SVNRevision:11710

LoadImages:[module_num:1|svn_version:\'11587\'|variable_revision_number:11|show_window:False|notes:\x5B\'This version (v4) was created to analyze several distances to consider objects touching.  Unlike v3, it does not  saving images for that purpose (number of neighbors, percent touching).\', \'(11/11/15)\'\x5D]
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
    Select display option:Color and Number
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

SaveImages:[module_num:7|svn_version:\'10822\'|variable_revision_number:7|show_window:False|notes:\x5B\x5D]
    Select the type of image to save:Image
    Select the image to save:TrackedCells
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

MeasureImageAreaOccupied:[module_num:8|svn_version:\'10563\'|variable_revision_number:3|show_window:False|notes:\x5B\x5D]
    Hidden:2
    Measure the area occupied in a binary image, or in objects?:Objects
    Select objects to measure:RelabeledCells
    Retain a binary image of the object regions?:Objects
    Name the output binary image:RelabeledCells
    Select a binary image to measure:None
    Measure the area occupied in a binary image, or in objects?:Objects
    Select objects to measure:cells
    Retain a binary image of the object regions?:Stain
    Name the output binary image:masked
    Select a binary image to measure:None

MeasureObjectNeighbors:[module_num:9|svn_version:\'Unknown\'|variable_revision_number:1|show_window:False|notes:\x5B\x5D]
    Select objects to measure:RelabeledCells
    Method to determine neighbors:Within a specified distance
    Neighbor distance:5
    Retain the image of objects colored by numbers of neighbors for use later in the pipeline (for example, in SaveImages)?:No
    Name the output image:NumberOfNeighbors_5
    Select colormap:Dark2
    Retain the image of objects colored by percent of touching pixels for use later in the pipeline (for example, in SaveImages)?:No
    Name the output image:PercentTouching_5
    Select a colormap:Dark2

MeasureObjectNeighbors:[module_num:10|svn_version:\'Unknown\'|variable_revision_number:1|show_window:False|notes:\x5B\x5D]
    Select objects to measure:RelabeledCells
    Method to determine neighbors:Within a specified distance
    Neighbor distance:10
    Retain the image of objects colored by numbers of neighbors for use later in the pipeline (for example, in SaveImages)?:No
    Name the output image:NumberOfNeighbors_10
    Select colormap:Dark2
    Retain the image of objects colored by percent of touching pixels for use later in the pipeline (for example, in SaveImages)?:No
    Name the output image:PercentTouching_10
    Select a colormap:Dark2

MeasureObjectNeighbors:[module_num:11|svn_version:\'Unknown\'|variable_revision_number:1|show_window:False|notes:\x5B\x5D]
    Select objects to measure:RelabeledCells
    Method to determine neighbors:Within a specified distance
    Neighbor distance:15
    Retain the image of objects colored by numbers of neighbors for use later in the pipeline (for example, in SaveImages)?:No
    Name the output image:NumberOfNeighbors_15
    Select colormap:Dark2
    Retain the image of objects colored by percent of touching pixels for use later in the pipeline (for example, in SaveImages)?:No
    Name the output image:PercentTouching_15
    Select a colormap:Dark2

MeasureObjectNeighbors:[module_num:12|svn_version:\'Unknown\'|variable_revision_number:1|show_window:False|notes:\x5B\x5D]
    Select objects to measure:RelabeledCells
    Method to determine neighbors:Within a specified distance
    Neighbor distance:20
    Retain the image of objects colored by numbers of neighbors for use later in the pipeline (for example, in SaveImages)?:No
    Name the output image:NumberOfNeighbors_20
    Select colormap:Dark2
    Retain the image of objects colored by percent of touching pixels for use later in the pipeline (for example, in SaveImages)?:No
    Name the output image:PercentTouching_20
    Select a colormap:Dark2

MeasureObjectSizeShape:[module_num:13|svn_version:\'1\'|variable_revision_number:1|show_window:False|notes:\x5B\x5D]
    Select objects to measure:RelabeledCells
    Calculate the Zernike features?:Yes

ConvertObjectsToImage:[module_num:14|svn_version:\'10807\'|variable_revision_number:1|show_window:False|notes:\x5B\x5D]
    Select the input objects:RelabeledCells
    Name the output image:CellImage
    Select the color type:uint16
    Select the colormap:Default

SaveImages:[module_num:15|svn_version:\'10822\'|variable_revision_number:7|show_window:False|notes:\x5B\x5D]
    Select the type of image to save:Image
    Select the image to save:CellImage
    Select the objects to save:RelabeledCells
    Select the module display window to save:None
    Select method for constructing file names:From image filename
    Select image name for file prefix:masked
    Enter single file name:OrigBlue
    Do you want to add a suffix to the image file name?:Yes
    Text to append to the image name:ID
    Select file format to use:mat
    Output file location:Default Output Folder sub-folder\x7CIDs
    Image bit depth:8
    Overwrite existing files without warning?:Yes
    Select how often to save:Every cycle
    Rescale the images? :No
    Save as grayscale or color image?:Color
    Select colormap:Dark2
    Store file and path information to the saved image?:No
    Create subfolders in the output folder?:Yes

DisplayDataOnImage:[module_num:16|svn_version:\'10412\'|variable_revision_number:2|show_window:False|notes:\x5B\x5D]
    Display object or image measurements?:Object
    Select the input objects:RelabeledCells
    Measurement to display:Number_Object_Number
    Select the image on which to display the measurements:TrackedCells
    Text color:white
    Name the output image that has the measurements displayed:DisplayImage
    Font size (points):15
    Number of decimals:0
    Image elements to save:Image

SaveImages:[module_num:17|svn_version:\'10822\'|variable_revision_number:7|show_window:False|notes:\x5B\x5D]
    Select the type of image to save:Image
    Select the image to save:DisplayImage
    Select the objects to save:None
    Select the module display window to save:None
    Select method for constructing file names:From image filename
    Select image name for file prefix:masked
    Enter single file name:OrigBlue
    Do you want to add a suffix to the image file name?:No
    Text to append to the image name:
    Select file format to use:jpeg
    Output file location:Default Output Folder sub-folder\x7Cobject_numbers
    Image bit depth:8
    Overwrite existing files without warning?:Yes
    Select how often to save:Every cycle
    Rescale the images? :No
    Save as grayscale or color image?:Grayscale
    Select colormap:Dark2
    Store file and path information to the saved image?:No
    Create subfolders in the output folder?:Yes
