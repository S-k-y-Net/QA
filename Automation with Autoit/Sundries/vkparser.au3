#include <IE.au3>
#include <GUIConstantsEx.au3>
#include <INet.au3>
Global $bool
GLobal $oIE
Global $sHtml
HotKeySet("{ESC}","stop")
Global $sURL
Global $i=1
$Form1 = GUICreate("Form1", 547, 359, 198, 172)
$Input1 = GUICtrlCreateInput("", 32, 32, 281, 21)
$Input2 = GUICtrlCreateInput("", 32, 88, 281, 21)
$Label1 = GUICtrlCreateLabel("Ключевое слово 1", 32, 8, 96, 17)
$Label2 = GUICtrlCreateLabel("Ключевое слово 2", 32, 64, 96, 17)
$Button1 = GUICtrlCreateButton("Начать поиск", 32, 220, 91, 33)
$Button2 = GUICtrlCreateButton("Закрыть", 152, 220, 83, 33)
$Label3 = GUICtrlCreateLabel("Остановка скрипта по кнопке ESC", 32, 165, 181, 17)
$Label5 = GUICtrlCreateLabel("Перед использованием нужно зайти в ВК через IE",32, 190, 280, 17)
$Input3 = GUICtrlCreateInput("", 32, 140, 121, 21)
$Label4 = GUICtrlCreateLabel("Предел поиска", 32, 120, 40, 17)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###
# sgasda
ggs
#
While 1
$nMsg = GUIGetMsg()
Switch $nMsg
Case $GUI_EVENT_CLOSE
Exit
Case $Button2
Exit
Case $Button1
$skey1=GUICtrlRead($Input1)
$skey2=GUICtrlRead($Input2)
$slimit=GUICtrlRead($Input3)
_Parser_Run($skey1,$skey2,$slimit)

EndSwitch
WEnd

func stop()
Exit
EndFunc

Func _Parser_Run($key1,$key2,$limit)
$sURL='http://vk.com/'
$oIE=_IECreate($sURL,0,0,1)
While $i<>$limit
$i=$i+1
_IENavigate($oIE,$sURL&"club"&$i)
$sHtml = _IEBodyReadHTML($oIE)
;FileWriteLine("Log.txt",$sHtml)
if StringInStr($sHtml,$key1)>0 then
if StringInStr($sHtml,$key2)>0 then
FileWriteLine("Log.txt",$sURL&"club"&$i)
FileWriteLine("Logi.txt",$i)
;MsgBox(64,"Ok","Ok")
EndIf
EndIf
WEnd
EndFunc