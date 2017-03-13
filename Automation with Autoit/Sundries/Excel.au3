Func _licen()
ShellExecute("notepad.exe")
$hWnd = WinWait("[CLASS:Notepad]", "", 5)
Send("{F5}")
Sleep(500)
Send("^a")
Sleep(400)
Send("^c")
Sleep(300)
WinClose($hWnd)
$readhtml2=ClipGet()
$data2 = StringRegExp($readhtml2, "(\d+.\d+.\d+)", 3)
Global $splitdata2 = StringSplit($data2[0], ".")
Global $data
; $readhtml = BinaryToString(InetRead($url), 4)
for $i=0 to 50
	$data[$i]="GEADL-20-04-2014-6160384-14799010-15459267-5632-0"
Next
;$data = StringRegExp($readhtml, "(\w+-\d+-\d+-\d+-\d+-\d+-\d+-\d+-\d+)", 3)
$splitdata = StringSplit($data[0], "-")
If $licenziya = 1 Then Exit
Global $pizdec = 1
;_informa()
For $i = 0 To UBound($data) - 1
Global $splitdata = StringSplit($data[$i], "-")
If $splitdata[1] = $mycomp Then
If $splitdata2[1] < $splitdata[4] Then _msg()
If $splitdata2[1] = $splitdata[4] Then
If $splitdata2[3] < $splitdata[3] Then _msg()
If $splitdata2[3] = $splitdata[3] Then
If $splitdata2[2] <= $splitdata[2] Then _msg()
EndIf
EndIf
EndIf
EndFunc