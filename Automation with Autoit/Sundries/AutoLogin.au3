#include <Misc.au3>
#include <File.au3>

HotKeySet("{ESC}","stop")
Func stop()
    Exit
EndFunc


$dll = DllOpen("user32.dll")

MsgBox(0,"Шаг 1","Нажми 'ОК' и кликни в поле ввода логина")
While 1
    Sleep(50)
    If _IsPressed("01", $dll) Then ;Ожидание, в цикле, нажатия ЛКМ
        $aCoord=MouseGetPos()
         ToolTip("Нажата ЛКМ"&@CRLF&"Координаты: x="&$aCoord[0]&" y="&$aCoord[1], Default, Default, '_IsPressed', 1)
        ExitLoop
    EndIf

WEnd
MsgBox(0,"Шаг 2","Нажми 'ОК' и кликни в поле ввода пароля")
While 1
    Sleep(50)
    If _IsPressed("01", $dll) Then ;Ожидание, в цикле, нажатия ЛКМ
        $aCoord1=MouseGetPos()
         ToolTip("Нажата ЛКМ"&@CRLF&"Координаты: x="&$aCoord1[0]&" y="&$aCoord1[1], Default, Default, '_IsPressed', 1)
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