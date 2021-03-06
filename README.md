# About
This code prints all the drawings in model space. Drawings are clustered based on the provided minimum distance to separate two nearby drawings. Each drawing is plotted in A4 size paper as pdf, then exported to svg and png format. The sole aim of this code is to export vector graphics from autocad to word so that the drawings are not distorted, so scale in the drawing is given no importance.

# How to use
## Enabling VBA in autocad
* Download the VBA enabler for your autocad version from https://knowledge.autodesk.com/support/autocad/troubleshooting/caas/downloads/content/download-the-microsoft-vba-module-for-autocad.html
* Then in the autocad inside the "Manage" tab click on the "Visual Basic Editor" inside "Applications"

## Installing inkscape
* Download and install inkscape 1.2 from https://inkscape.org/release/1.2/windows/ And remember to check the "Add to path" checkbox during the start of installation

## Install python
* Download and install python from https://www.python.org/downloads/  Again make sure the "Add to path" check box is checked during the end of installation.

## Copying required files
* Copy the "rem_word.py" file inside the folder where your output pdfs will be kept. This same folder will later be the location to be provided when the macro is run. Copy the "Acad.lsp" and "printer.dvb" file inside the autocad installed directory for example "C:\Program Files\Autodesk\AutoCAD 2016"

## Running the macro
* Before running the macro just copy all the drawings from your origin sheet to new drawing tab in autocad because all the drawings will be deleted from you modelspace after printing. You can simply press ctrl+z i.e. undo but still better to copy the drawings to a new drawing tab in autocad.
* Run the macro from "Run VBA Macro" inside the "Manage Tab" of autocad. Select the macro named "ThisDrawing.Print_Me". Then you will first be prompted to insert the location of saving directory. Input the full path. Just copy and paste the path. After that,you will be asked to draw a line that denotes the distance to which extent two figures should be considered inside same drawing. This value is just an approx. If you are unsure, just draw a short line. Finally you will be asked to enter the starting character or word. This character or word will later be used to convert the drawings to svg and png. Only the pdfs starting with that character or word will be converted to save time.


## Issues
Code should work for autocad 2016 and above. If you have any issues feel free to contact me.


