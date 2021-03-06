Attribute VB_Name = "VBIOHelper"
Option Explicit

Private mOriginalPath As String

Public Sub SetupTestPath()
    mOriginalPath = App.Path
    ChDrive "c"
    ChDir "c:\windows"
End Sub

Public Sub RestoreOriginalPath()
    ChDrive Left$(mOriginalPath, 1)
    ChDir mOriginalPath
End Sub

Public Function FolderExists(ByRef Folder As String) As Boolean
    On Error GoTo Finally
    
    Dim FileName As String
    FileName = Folder & "\_dummyfile.txt"
    
    Dim FileNumber As Long
    FileNumber = FreeFile
    Open FileName For Output As FileNumber
    Close #FileNumber
    
    Kill FileName
    
    FolderExists = True
Finally:
End Function

Public Sub DeleteFolder(ByRef Folder As String)
    If FolderExists(Folder) Then
        RmDir Folder
    End If
End Sub

Public Sub CreateFolder(ByRef Folder As String)
    If Not FolderExists(Folder) Then
        MkDir Folder
    End If
End Sub

Public Function FileExists(ByRef FileName As String) As Boolean
    On Error GoTo FileNotFoundError
    
    ' We check for a file this way because using Dir$ places a lock on the file
    ' causing some of the Teardowns to fail.
    Dim FileNumber As Long
    FileNumber = FreeFile
    Open FileName For Input As #FileNumber
    Close #FileNumber
    
    FileExists = True
FileNotFoundError:
End Function

Public Sub CreateFile(ByRef FileName As String)
    If Not FileExists(FileName) Then
        Dim FileNumber As Long
        FileNumber = FreeFile
        Open FileName For Output As #FileNumber
        Close #FileNumber
    End If
End Sub

Public Sub DeleteFile(ByRef FileName As String)
    If FileExists(FileName) Then
        Kill FileName
    End If
End Sub

Public Function ReadFile(ByVal FileName As String) As String
    Dim FileNumber As Long
    FileNumber = FreeFile
    Open FileName For Input As #FileNumber
    Line Input #FileNumber, ReadFile
    Close #FileNumber
End Function
