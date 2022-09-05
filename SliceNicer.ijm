// ***** .LSM FILES MUST BE OPENED VIA BIOFORMAT IMPORTER ***** 

setBatchMode(true)

close("*");

username = "danielba";
inputFile = "C:/Users/" + username + "/Desktop/";
outputDir = "C:/Users/" + username + "/Desktop/";
roiFile = "C:/Users/" + username + "/Desktop/";
version = "1.1";
refImg = 1;

// **************** HELP *******************

html = "<html>"
    +"<h2>Slice Nicer | v" + version +"</h2>"
    +"Macro for automated analysis of penetration (slice) assay<br>"
    +"and therefor normalize images acquired over a period of time<br>"
    +"<h3>IMPORTANT</h3>"
    +"<ul><li><strong>Always open ImageJ fresh before starting the macro</strong></li>"
    +"<li><strong>Make sure to not have ANY images opened before starting the macro</strong></li>"
    +"<li><strong>Make sure the output directory is empty before starting the macro</strong></li></ul>"
    +"<h3>Username</h3>"
    +"Enter user name for the user who is currently logged in to<br>"
    +"the computer. Necessary so that output files can be saved<br>"
    +"in an existing directory.<br>"
    +"<h3>Choose input file in .lsm format</h3>"
    +"Choose .lsm file to process with this tool. Other multi- <br>"
    +"dimensional stacks haven't been tested so far.<br>"
    +"<h3>Choose ROI file in .roi format</h3>"
    +"Choose ROI file to be used for plotting the profile. .roi files<br>"
    +"can be generated as follows:<br>"
    +"<ol><li>Open an image in ImageJ</li>"
    +"<li>Create an ROI (e.g. via the line tool)</li>"
    +"<li>Open ROI Manager (Analyse > Tools > RoiManager...</li>"
    +"<li>Press 'add' to add the ROI to the ROI Manager</li>"
    +"<li>Press 'more' > 'save' to save the ROI</li></ol>"
    +"<h3>Choose output directory</h3>"
    +"Select the directory in which the processed data will be<br>"
    +"stored. During processing a new 'export' folder will be created.<br>"
    +"Single, unprocessed images will be saved in an 'unprocessed' subfolder<br>"
    +"Single, normalized images will be saved in a 'processed' subfolder<br>"
    +"By default, the 'export' folder is created on the desktop.<br><br>"
    +"<h3>Select reference image frame</h3>"
    +".<br>"
    +"For normalization an initial image of the slice is needed<br>"
    +"as a point of reference. Enter the corresponding number of <br>"
    +"the frame that should be used as the reference."
    +"<br><br><font size=-2>Macro by danielba</font>";

// ************ GET USER INPUT *************

Dialog.create("Slice Nicer | v" + version);
// User selects their name
Dialog.addString("Username:", username);
// User selects input file
Dialog.addFile("Choose input file in .lsm format:", inputFile);
// User selects ROI file
Dialog.addFile("Choose ROI file in .roi format:", roiFile);
// User selects output directory
Dialog.addDirectory("Choose output directory: ", outputDir);
// User selects reference image
Dialog.addNumber("Select reference image:", refImg);
// Help button
Dialog.addHelp(html);
Dialog.show();

// Save user input into strings
username = Dialog.getString();
inputFile = Dialog.getString();
roiFile = Dialog.getString();
outputDir = Dialog.getString();
refImg = Dialog.getNumber() - 1;

// Debug: Log refImg
print("Ref.Image: " + refImg);
print("N open Windows:" + nImages);

// *****************************************

// Import .lsm file
run("Bio-Formats Importer",
    "open=["+ inputFile +"]color_mode=Composite rois_import=[ROI manager] split_channels view=Hyperstack stack_order=XYCZT use_virtual_stack");

// Initialize necessary directories

// maybe initialize folder and delete all data from the directory

File.makeDirectory(outputDir + "/export");
File.makeDirectory(outputDir + "/export/unprocessed/");
File.makeDirectory(outputDir + "/export/processed/");
File.makeDirectory(outputDir + "/export/plots");

// Get ImageDimensions
Stack.getDimensions(width, height, channels, slices, frames);
getPixelSize(unit, pixelWidth, pixelHeight);

// Load custom ROI

if(roiFile != "C:/Users/" + username + "/Desktop/" || roiFile != "") {
    run("ROI Manager...");
    roiManager("Open", roiFile);
}

// Get number of loaded channels
channels = nImages();

// Debug: Log dimensions
print("Width: " + width);
print("Height: " + height);
print("Frames: " + frames);

// Get an array of all open windows (1 image = 1 channel)
channelArray = getList("image.titles");

//Debug: Print name of currently processed channel
//Array.show(channelArray);

// Loop through open channels
for(var i=0; i<channelArray.length; i++){
    selectWindow(channelArray[i]);

    // Debug Info: Current Channel
    print("Currently processing: " + channelArray[i]);

    //Split channel into single images
    run("Stack to Images");

    // Get all open images again
    imageArray = getList("image.titles");

    // Find channel images
    excludeChannelFilter = Array.filter(imageArray, "- C=");

    // Exclude channel images from further processing
    for(var j=0; j<excludeChannelFilter.length; j++){
        imageArray = Array.deleteValue(imageArray, excludeChannelFilter[j]);
    }
    // Debug info
    //Array.show(imageArray);

    // Loop through all single images
    imgCount = 0;
    for(var j=0; j<imageArray.length; j++){
        //print("bef: " + imageArray[j] + "(Count: " + imgCount + ")");
        selectWindow(imageArray[j]);
        rename("C" + i + "_" + imageArray[j]);
        
        // Debug: Print name of currently processed channel
        //print("now: " + getTitle());

        // Save image as tiff
        if(imgCount >= refImg) {
            saveAs("Tiff", outputDir + "export/unprocessed/" + getTitle());
            close();
            imgCount = imgCount + 1;
        } else { 
            print("Closed without save");
            close();
            imgCount = imgCount + 1;}
    }
    
}

// Get FileList of exported, unprocessed Files
unprocessedFiles = getFileList(outputDir + "export/unprocessed/");
frames = unprocessedFiles.length/channels;

// Debug: Print nImagesPerChannel
print("nChannels:" + channels);
print("FileList Length: " + unprocessedFiles.length);

var currentChannel = 1;

// Initialize file count
var reloadedFileCount = 0;

// Iterate through all channels
for(var i=0; i<channels; i++) {

    // Open images of each channel
    for(var j=0; j<frames; j++) {
        open(outputDir + "export/unprocessed/" + unprocessedFiles[reloadedFileCount]);
        reloadedFileCount++;
    }
    
    // Debug Info
    print("C0" + currentChannel + " processed! // Processed " + reloadedFileCount + " files.");

    reloadedImages = getList("image.titles");
    // Set Reference Image
    refImage = reloadedImages[0];
    // Set Images to be normalized
    imagesToCalc = Array.deleteIndex(reloadedImages, 0);

    // Debug
    print("C0" + currentChannel + ": Reference Image is: " + refImage);
    //Array.show(reloadedImages, imagesToCalc);

    // For all images to be calculated
    for(var j=0; j<imagesToCalc.length; j++) {
        // Normalize
        imageCalculator("Divide create 32-bit", imagesToCalc[j], refImage);
        selectWindow("Result of " + imagesToCalc[j]);
        // Debug
        print(getTitle());
        // Save normalized images
        saveAs("Tiff", outputDir + "export/processed/"+ getTitle());

        // Set ROI
        if(roiFile == "C:/Users/" + username + "/Desktop/" || roiFile == "") {
            makeLine(0,(height/2),width,(height/2));
            Roi.setStrokeWidth(height); 
        } else {
            roiManager("Select", 0);
        }

        run("Plot Profile");
        Plot.getValues(x,y);
        //Plot.create("Plot Values", "Distance (" + unit + ")", "Gray Values", x, y);

        // Initializes result table
        run("Clear Results");
        for(k=0; k<x.length; k++) {
            setResult("Distance (" + unit + ")", k, x[k]);
            setResult("Gray Value", k, y[k]);
            updateResults();
        }

        // Save ROI profiles as .csv
        saveAs("Results", outputDir + "export/plots/" + imagesToCalc[j] + ".csv");
        
    }

    // Close all windows
    close("*");
    currentChannel++;
}

close("*");

showMessage("Slice Nicer | v"+ version, "Woah there... Nice slice! Processing was succesful. ImageJ can be closed.");