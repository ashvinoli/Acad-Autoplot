VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "ThisDrawing"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
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

    If ThisDrawing.ActiveSpace = acPaperSpace Then
      ThisDrawing.MSpace = True
      ThisDrawing.ActiveSpace = acModelSpace
    End If
    
    location_save = InputBox("Where do you want to save the pdfs?", "Location", "E:\Autocad_Output\")
    
    If Right(location_save, 1) <> "\" Then
        location_save = location_save & "\"
    End If
    
    'location_save = "E:\Autocad_Output\"

    padding = ThisDrawing.Utility.GetDistance(, "Max separation between objects to consider them into one drawing?. If confused enter 0")
    'padding = 0
    filename = InputBox("The name of your drawings should start with?") + "-"
    'filename = "x" + "-"
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
    
    Dim item As Variant
    counter = 0
    
    'Get bounding box for each drawing
    Do While ThisDrawing.ModelSpace.Count > 0

starts_here:
        On Error GoTo handle_error 'Trying to handle null extents error
        ThisDrawing.ModelSpace.item(counter).GetBoundingBox minP, maxP
        GoTo resume_task_normally
        
handle_error:
        Select Case Err.Number
            Case -2145386308 'Null extents error
                If ThisDrawing.ModelSpace.Count = 1 Then 'If the only element if the one which has null bounds exit loop
                    Exit Do
                End If
                ThisDrawing.ModelSpace.item(counter).Delete
                'counter = counter  + 1
                Resume starts_here 'Instead of "goto starts_here" "resume starts_here" is necessary because goto prevents error to be raised the second time, as vba thinks that the error was within error
            Case Else
                MsgBox "Error " & Err.Number & " occured!"
        End Select
        
resume_task_normally:
        minP(0) = minP(0) - padding
        minP(1) = minP(1) - padding
        maxP(0) = maxP(0) + padding
        maxP(1) = maxP(1) + padding
        'On Error Resume Next
        With ThisDrawing
            For Each item In .SelectionSets
                If item.Name = "Temp" Then
                    .SelectionSets("Temp").Delete
                    Exit For
                End If
            Next
            Set My_Set = .SelectionSets.Add("Temp")
            My_Set.Select acSelectionSetCrossing, minP, maxP
            'My_Set.Select acSelectionSetWindow, minP, maxP
            next_count = My_Set.Count
                
            Do
                prev_count = next_count
                'MsgBox prev_count
                If My_Set.Count = 0 Then
                    'If any autocad object gives the bounding box values,
                    'there at least has to be the same object inside the bounding box,
                    'but in somecases like empty strings the strings
                    'themselves won't be selected inside the bounding box,
                    'so we have to erase them or else the program will run in infinite loops, as the same empty string will the the
                    'object providing bounding box and since it won't be selected it won't be erased so we have to erase it manually
                    ThisDrawing.ModelSpace.item(counter).Delete '
                    Exit Do
                End If
                My_Set.item(0).GetBoundingBox minP, maxP
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
        counter = 0
    Loop
    Call Call_another(location_save, filename)
    MsgBox "Congratulations all the drawings have been successfully plotted, converted to svg and png format!", vbInformation
End Sub

Sub Plot_Files_arg(p1() As Double, p2() As Double, counter As Integer, filename As String, location_save As String)
    'Macros with arguments won't be shown because arguments can't be passed while running macro by clicking them
    Dim LLwindow(0 To 1) As Double
    Dim URwindow(0 To 1) As Double
    Dim result As Boolean
    Dim PltObj As AcadPlot
    
    LLwindow(0) = p1(0)
    LLwindow(1) = p1(1)
    URwindow(0) = p2(0)
    URwindow(1) = p2(1)

    
    Set PltObj = ThisDrawing.Plot
   
    'Set layout properties
    With ThisDrawing.ModelSpace.Layout
        .ConfigName = "DWG To PDF.pc3"
        .StandardScale = acScaleToFit
        .CanonicalMediaName = .GetCanonicalMediaNames(16)
         'Updates the plot
        .RefreshPlotDeviceInfo
        'You can select the plot style table here
        .StyleSheet = "Monochrome.ctb"
        'Specifies whether or not to plot using the plot styles
        .PlotWithPlotStyles = True
        .CenterPlot = True
        .RefreshPlotDeviceInfo
        .SetWindowToPlot LLwindow, URwindow 'Lower left and upper right coordinates
        'MsgBox acWindow
        .PlotType = acWindow
    End With
    
    
    result = PltObj.PlotToFile(location_save + filename + Str(counter))
    
End Sub

Sub Call_another(location_save As String, filename As String)
    Dim wsh As Object
    Set wsh = VBA.CreateObject("WScript.Shell")
    Dim waitOnReturn As Boolean: waitOnReturn = True
    Dim windowStyle As Integer: windowStyle = 1
    Dim run_str As String
    ' Call another program
    ' Shell() did the job but it does it asynchronously
    ' wscript.shell object waits until program terminates as below
    ' But be careful not to run python directly but run it from the cmd
    ' /c switch tells to exit the cmd after code completion
    ' /k makes the cmd wait even after the completion of the code
    location_save = Chr(34) & location_save & "rem_work.py" & Chr(34) & " " & filename
    run_str = "cmd /k python " & location_save
    'MsgBox run_str
    wsh.Run run_str, windowStyle, waitOnReturn
End Sub

Sub FindingPaperSizes()
    'Trying to find out which one is A4
    Dim PlotConfig As AcadPlotConfiguration
    Set PltConfigs = ThisDrawing.PlotConfigurations
     'PlotConfig.CanonicalMediaName =
    PltConfigs.Add "PDF", False
  
    Set PlotConfig = PltConfigs.item("PDF")
    PlotConfig.ConfigName = "DWG To PDF.pc3"
    papersize = ""
    Dim x As Variant
    For i = 0 To UBound(PlotConfig.GetCanonicalMediaNames)
        papersize = papersize & i & ":" & PlotConfig.GetCanonicalMediaNames(i) & " "
    Next i
    MsgBox papersize
End Sub



