#include <Misc.au3>
#include <File.au3>

HotKeySet("{ESC}","stop")
Func stop()
    Exit
EndFunc


$dll = DllOpen("user32.dll")

MsgBox(0,"��� 1","����� '��' � ������ � ���� ����� ������")
While 1
    Sleep(50)
    If _IsPressed("01", $dll) Then ;��������, � �����, ������� ���
        $aCoord=MouseGetPos()
         ToolTip("������ ���"&@CRLF&"����������: x="&$aCoord[0]&" y="&$aCoord[1], Default, Default, '_IsPressed', 1)
        ExitLoop
    EndIf

WEnd
MsgBox(0,"��� 2","����� '��' � ������ � ���� ����� ������")
While 1
    Sleep(50)
    If _IsPressed("01", $dll) Then ;��������, � �����, ������� ���
        $aCoord1=MouseGetPos()
         ToolTip("������ ���"&@CRLF&"����������: x="&$aCoord1[0]&" y="&$aCoord1[1], Default, Default, '_IsPressed', 1)
		 ExitLoop
    EndIf

WEnd

_FileCreate(@ScriptDir&"/config.txt")
$hFile = FileOpen("config.txt", 1)
FileWriteLine($hFile,$aCoord[0])
FileWriteLine($hFile,$aCoord[1])
FileWriteLine($hFile,$aCoord1[0])
FileWriteLine($hFile,$aCoord1[1])
FileClose($hFile)