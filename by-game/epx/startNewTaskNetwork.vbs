Dim fso, GameName, TaskName, CreateShortcut
Set fso = CreateObject("Scripting.FileSystemObject")
Set objArgs = WScript.Arguments

GameName = objArgs(0)
TaskName = objArgs(1)
CreateShortcut = objArgs(2)

Dim objXMLDoc, NodeList
Dim SelectedNode, FolderName, NodePath, PathArray
Dim NetworkPath, GamePath, TaskPath

Set objXMLDoc = CreateObject("Microsoft.XMLDOM")
objXMLDoc.async = False
objXMLDoc.load("startNewTaskStructure.xml")

Set RootNode = objXMLDoc.documentElement.selectSingleNode("//root")
NetworkPath = RootNode.getAttribute("network")
GamePath = NetworkPath & "\" & GameName
TaskPath = GamePath & "\" & TaskName

Set NodeList = objXMLDoc.getElementsByTagName("dir")
PathArray = array()
For Each Elem In NodeList
    Set SelectedNode = Elem
    Do Until SelectedNode.nodeName = "root"
        FolderName = "\" & SelectedNode.getAttribute("name")
        NodePath = FolderName & NodePath
        Set SelectedNode = SelectedNode.parentNode
    Loop
    ReDim Preserve PathArray(UBound(PathArray) + 1)
    PathArray(UBound(PathArray)) = TaskPath & NodePath
    NodePath = ""
Next

If Not fso.FolderExists(GamePath) Then
    Set GameFolder = fso.CreateFolder(GamePath) 
End If

If fso.FolderExists(TaskPath) Then
    msgPrompt = Msgbox("Conflict: This task has already been created on the network. Do you want to proceed?", vbYesNo, "Network")
    If msgPrompt = vbYes Then
        For Each Path In PathArray
            If Not fso.FolderExists(Path) Then
                fso.CreateFolder(Path)
            End If
        Next
    Else
        Msgbox "Creating network structure aborted."
    End If
Else
    Set TaskFolder = fso.CreateFolder(TaskPath)
    For Each Path In PathArray
        fso.CreateFolder(Path)
    Next
End If

If CreateShortcut = "true" Then
    Dim objShell, objLink, workingDirectory
    workingDirectory = fso.GetAbsolutePathName(".")
    Set objShell = CreateObject("WScript.Shell")
    Set objLink = objShell.CreateShortcut(workingDirectory & "\" & GameName & "\" & TaskName & "\network.lnk")
    objLink.TargetPath = "explorer.exe"
    objLink.Arguments = TaskPath
    objLink.Save
End If

WScript.Quit