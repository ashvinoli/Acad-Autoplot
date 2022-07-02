VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "ThisDrawing"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
'Do not forget to make the NEW configuration befor running this code
'And set ltscale to 5
' Prevent files from opening by unchecking the open in viewer check box in PDF to pc3 file
' Very important:
' If autocad cann't execute certain lines in any way it will return the control to the main calling program when on error resume next is turned on
' ThisDrawing.Plot.PlotToFile ("D:\Arbind_Drawing\" + filename + Str(counter))  This line always returned back to original program without
' executing of the plot command because there was no D drive in my laptop and no arbind_drawing folder. When I corrected it to
' ThisDrawing.Plot.PlotToFile ("E:\Autocad_Output\" + filename + Str(counter)), everything seemed to work all right
' And sometimes the program runs into infinite loops. This is because, the same window containing no drawings is fed back to the
' program which again repeats. The drawing count is never zero. to prevent this copy all the drawings to new drawing which has the
' same settings as your original one, or else a lot of things will change. After you copy the drawings to new sheet run the macro.

Sub Print_me()
    Dim minP As Variant
    Dim maxP As Variant
    
    Dim MinX As Double
    Dim MaxX As Double
    Dim MinY As Double
    Dim MaxY As Double
    
    Dim objects As AcadEntity
    Dim My_Set As AcadSelectionSet
    
    Dim Z_min(2) As Double 'zoom point min
    Dim Z_max(2) As Double
        
    Dim model_count As Integer
    Dim prev_count As Integer
    Dim next_count As Integer
    Dim file_count As Integer
    Dim padding As Double
    Dim filename As String
    Dim location_save As String
    
    location_save = InputBox("Where do you want to save the pdfs?", "Location", "E:\Autocad_Output\")
    padding = ThisDrawing.Utility.GetDistance(, "Enter or draw approx half the distance between two distinct drawings. If confused enter 0")
    filename = InputBox("The name of your drawings should start with?") + "-"
    ThisDrawing.Application.ZoomExtents 'WIthout this line the user had to manually zoom extent before running the code
    ThisDrawing.SetVariable "LTSCALE", 5 'Ltscale adjusted to that dashed lines would remain dashed
    ThisDrawing.SetVariable "BACKGROUNDPLOT", 0 'Let autocad print each pdf
    MinX = 0
    MaxX = 0
    MinY = 0
    MaxY = 0
    next_count = 0
    prev_count = 0
    file_count = 0
    
    
    
    'Set layout properties
    With ThisDrawing.ModelSpace.Layout
        'Load plot configurations from "PDF" that I had just created above. "New" stays with the drawing if saved and cannot be saved.
        .ConfigName = "DWG To PDF.pc3"
        .StandardScale = acScaleToFit
        .CanonicalMediaName = .GetCanonicalMediaNames(16)
        .PlotType = acWindow
        .CenterPlot = True
        'You can select the plot style table here
        .StyleSheet = "Monochrome.ctb"
        'Specifies whether or not to plot using the plot styles
        .PlotWithPlotStyles = True
         'Updates the plot
        .RefreshPlotDeviceInfo
    End With
    
    
    'Get bounding box for each drawing
    While ThisDrawing.ModelSpace.Count > 0
        ThisDrawing.ModelSpace.Item(0).GetBoundingBox minP, maxP
         minP(0) = minP(0) - padding
        minP(1) = minP(1) - padding
        maxP(0) = maxP(0) + padding
        maxP(1) = maxP(1) + padding
        'On Error Resume Next
        With ThisDrawing
            .SelectionSets("Temp").Delete
            Set My_Set = .SelectionSets.Add("Temp")
            My_Set.Select acSelectionSetCrossing, minP, maxP
            next_count = My_Set.Count
                
            Do
                prev_count = next_count
                'MsgBox prev_count
                My_Set.Item(0).GetBoundingBox minP, maxP
                MinX = minP(0)
                MaxX = maxP(0)
                MinY = minP(1)
                MaxY = maxP(1)
                
            
                For Each objects In My_Set
                    objects.GetBoundingBox minP, maxP
                    If maxP(0) > MaxX Then MaxX = maxP(0)
                    If maxP(1) > MaxY Then MaxY = maxP(1)
                    If minP(0) < MinX Then MinX = minP(0)
                    If minP(1) < MinY Then MinY = minP(1)
                Next
                
                Z_min(0) = MinX
                Z_min(1) = MinY
                Z_max(0) = MaxX
                Z_max(1) = MaxY
                
                Z_min(0) = Z_min(0) - padding
                Z_min(1) = Z_min(1) - padding
                Z_max(0) = Z_max(0) + padding
                Z_max(1) = Z_max(1) + padding
                
                My_Set.Select acSelectionSetCrossing, Z_min, Z_max
                next_count = My_Set.Count
                    
            Loop Until prev_count = next_count
            Call Plot_Files_arg(Z_min, Z_max, file_count, filename, location_save)
            file_count = file_count + 1
            My_Set.Erase
            
        End With
    Wend
    'Call Call_another(location_save)
    MsgBox "Congratulations all the drawings have been successfully plotted, converted to jpg and cropped"
End Sub

Sub Plot_Files_arg(p1() As Double, p2() As Double, counter As Integer, filename As String, location_save As String)
    'Macros with arguments won't be shown because arguments can't be passed while running macro by clicking them
    Dim LLwindow(0 To 1) As Double
    Dim URwindow(0 To 1) As Double
    Dim result As Boolean
    Dim PltObj As AcadPlot
    Dim BackPlot As Variant
    
    LLwindow(0) = p1(0)
    LLwindow(1) = p1(1)
    URwindow(0) = p2(0)
    URwindow(1) = p2(1)

    If ThisDrawing.ActiveSpace = acPaperSpace Then
      ThisDrawing.MSpace = True
      ThisDrawing.ActiveSpace = acModelSpace
    End If
    
    Set PltObj = ThisDrawing.Plot
   
    ThisDrawing.ModelSpace.Layout.SetWindowToPlot LLwindow, URwindow 'Lower left and upper right coordinates

    result = PltObj.PlotToFile(location_save + filename + Str(counter))
    
End Sub

Sub Call_another(location_save As String)
    Dim wsh As Object
    Set wsh = VBA.CreateObject("WScript.Shell")
    Dim waitOnReturn As Boolean: waitOnReturn = True
    Dim windowStyle As Integer: windowStyle = 1

    ' Call another program
    ' Shell() did the job but it does it asynchronously
    ' wscript.shell object waits until program terminates as below
    ' But be careful not to run python directly but run it from the cmd
    ' /c switch tells to exit the cmd after code completion
    ' /k makes the cmd wait even after the completion of the code
   
    wsh.Run "cmd /c python " & location_save & "call_pdf2jpg.py", windowStyle, waitOnReturn
    wsh.Run "cmd /c python " & location_save & "call_autocrop.py", windowStyle, waitOnReturn
    wsh.Run "cmd /c python " & location_save & "Pdf2svg.py", windowStyle, waitOnReturn
    wsh.Run "cmd /c python " & location_save & "move_all.py", windowStyle, waitOnReturn
End Sub

Sub FindingPaperSizes()
    'Trying to find out which one is A4
    Dim PlotConfig As AcadPlotConfiguration
    Set PltConfigs = ThisDrawing.PlotConfigurations
     'PlotConfig.CanonicalMediaName =
    PltConfigs.Add "PDF", False
  
     Set PlotConfig = PltConfigs.Item("PDF")
    papersize = ""
    Dim x As Variant
    For i = 0 To UBound(PlotConfig.GetCanonicalMediaNames)
        papersize = papersize & i & ":" & PlotConfig.GetCanonicalMediaNames(i) & " "
    Next i
    MsgBox papersize
End Sub


