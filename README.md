# About
This code prints all the drawings in model space. Drawings are clustered based on the provided minimum distance to separate two nearby drawings. Each drawing is plotted in A4 size paper as pdf, then exported to svg and png format. The sole aim of this code is to export vector graphics from autocad to word so that the drawings are not distorted, so scale in the drawing is given no importance.

# How to use
## Enabling VBA in autocad
* Download the VBA enabler for your autocad version from https://knowledge.autodesk.com/support/autocad/troubleshooting/caas/downloads/content/download-the-microsoft-vba-module-for-autocad.html
* Then in the autocad inside the "Manage" tab click on the "Visual Basic Editor" inside "Applications"
* Under File>Import, import the .cls file

## Installing inkscape
* Download and install inkscape 1.2 from https://inkscape.org/release/1.2/windows/ And remember to check the "Add to path" checkbox during the end of installation

## Install python
* Download and install python from https://www.python.org/downloads/  Again make sure the "Add to path" check box is checked during the end of installation.

## Copying required files
* Copy the .py file inside the folder where your output pdfs will be kept. This same folder will later be the location to be provided when the macro is run.


