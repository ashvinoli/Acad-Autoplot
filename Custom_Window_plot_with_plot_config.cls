VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "ThisDrawing"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True

Sub Plot_Files()
'Macros with arguments won't be shown because arguments can't be passed while running macro by clicking them
    Dim LLwindow(0 To 1) As Double
    Dim URwindow(0 To 1) As Double
    LLwindow(0) = 15
    LLwindow(1) = 4
    URwindow(0) = 45
    URwindow(1) = 20
    Dim filename As String
    filename = "C"
    
  For i = 0 To 2
    If ThisDrawing.ActiveSpace = acPaperSpace Then
      ThisDrawing.MSpace = True
      ThisDrawing.ActiveSpace = acModelSpace
     End If
     With ThisDrawing
         'Load plot configurations from "New" that I had just created. "New" stays with the drawing if saved and cannot be saved.
         .ModelSpace.Layout.CopyFrom .PlotConfigurations("New")
     End With
     'Over write the window size from the command below
     ThisDrawing.ModelSpace.Layout.SetWindowToPlot LLwindow, URwindow 'Lower left and upper right coordinates
     ThisDrawing.Plot.PlotToFile ("D:/" & filename & i)
     LLwindow(0) = LLwindow(0) + 27
     URwindow(0) = URwindow(0) + 27
  Next i
End Sub
