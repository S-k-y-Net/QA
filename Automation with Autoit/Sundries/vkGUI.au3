#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ListBoxConstants.au3>
#include <EditConstants.au3>
#include <ProgressConstants.au3>
#include <GUIConstantsEx.au3>

#NoTrayIcon

Global $sURL = 'http://vk.com/audio'
Global $sSongName
Global $sLog
Global $sLink
Global $sDir = @ScriptDir


$MainWin = GUICreate("VKSave", 400, 450, -1, -1)
GUISetBkColor(0xFFFFFF)
GUISetState()
$icon = GUICtrlCreateIcon('C:\Users\И\Desktop\au3\VKSave\B.ico', 1, 10, 400)
$dl = GUICtrlCreateButton("Скачать", 250, 350, 120, 25)
$StartList = GUICtrlCreateButton("Войти", 250, 300, 120, 25)
$quit = GUICtrlCreateButton("Выйти", 250, 400, 120, 40)
$DirButton = GUICtrlCreateButton("Обзор", 100, 400, 120, 40)
GUICtrlSetBkColor($DirButton, 0x4682B4)
GUICtrlSetColor($DirButton, 0xFFFFFF)
GUICtrlSetBkColor($StartList, 0x4682B4)
GUICtrlSetColor($StartList, 0xFFFFFF)
GUICtrlSetBkColor($quit, 0x4682B4)
GUICtrlSetColor($quit, 0xFFFFFF)
$oEmailLabel = GUICtrlCreateLabel('Телефон или e-mail:', 10, 280, 125, 25)
$oPassLabel = GUICtrlCreateLabel('Пароль:', 10, 330, 125, 25)
GUICtrlSetColor($oEmailLabel, 0x808080)
GUICtrlSetColor($oPassLabel, 0x808080)
$oEmail = GUICtrlCreateInput('Login', 10, 300, 170, 25)
$oPass = GUICtrlCreateInput('Pass', 10, 350, 170, 25, $ES_PASSWORD)
$mylist = GUICtrlCreateListView("Исполнитель         |Название песни         |Размер файла          ", 2, 2, 396, 270)
GUICtrlSetBkColor($mylist, 0xFFFFFF)
GUICtrlSetLimit(-1, 200)
GUICtrlSetState($dl, $GUI_DISABLE)
GUICtrlSetBkColor($dl, 0xDCDCDC)
$oHTTP = ObjCreate("WinHttp.WinHttpRequest.5.1")
$msg = 0

While $msg <> $GUI_EVENT_CLOSE
	$msg = GUIGetMsg()
	Select
		Case $msg = $quit
			Exit
		Case $msg = $dl
			$sRecord = GUICtrlRead(GUICtrlRead($mylist), 2)
			$sLink = GetLink($sRecord)
			$aName = StringRegExp($sRecord, '(.*?\|.*?)\|', 3)
			$sName = StringReplace($aName[0], '|', '-')
			DlSong($sLink, $sName, $sDir)
			ConsoleWrite($sLink & @CRLF &  $sRecord)
		Case $msg = $DirButton
				$sDir = FileSelectFolder('Выберите папку', '')
		Case $msg = $StartList
				GUICtrlSetState($StartList, $GUI_DISABLE)
				GUICtrlSetBkColor($StartList, 0xDCDCDC)
			If Not Connect() Then
				MsgBox(0, '', 'ресурс vk.com не доступен')
				Exit
			EndIf
			If Login() Then
				$sSrc = GetAudioSource()
				GetAudioList($sSrc)
				GUICtrlSetState($dl, $GUI_ENABLE)
				GUICtrlSetBkColor($dl, 0x4682B4)
				GUICtrlSetColor($dl, 0xFFFFFF)
				GUICtrlSetColor($StartList, 0xFFFFFF)
				GUICtrlSetState($oEmail, $GUI_DISABLE)
				GUICtrlSetState($oPass, $GUI_DISABLE)
			Else
				MsgBox(0, '', 'логин или пароль введены неверно')
				GUICtrlSetState($StartList, $GUI_ENABLE)
				GUICtrlSetBkColor($StartList, 0x4682B4)
				GUICtrlSetColor($StartList, 0xFFFFFF)
			EndIf
	EndSelect
	sleep(10)
WEnd



Func Login()
	$sEmail = GUICtrlRead($oEmail)
	$sPass = GUICtrlRead($oPass)
	$oHTTP.Open("POST","http://login.vk.com/?act=login")
	$oHTTP.setTimeouts(5000, 5000, 15000, 15000)
	$oHTTP.SetRequestHeader("Accept", "image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, application/x-shockwave-flash, application/vnd.ms-excel, application/vnd.ms-powerpoint, application/msword, application/x-ms-application, application/x-ms-xbap, application/vnd.ms-xpsdocument, application/xaml+xml, */*")
	$oHTTP.SetRequestHeader("Accept-Language", "ru")
	$oHTTP.SetRequestHeader("Referer","http://vkontakte.ru")
	$oHTTP.SetRequestHeader("Content-Type","application/x-www-form-urlencoded")
	$oHTTP.SetRequestHeader("User-Agent", "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)")
	$oHTTP.SetRequestHeader("Host","login.vk.com")
	$oHTTP.SetRequestHeader("Proxy-Connection", "Keep-alive")
	$oHTTP.Send('email='&$sEmail&'&pass='&$sPass)
	$sData = $oHTTP.ResponseText
	If StringInStr($sData, 'Не удается войти') Then
		Return 1
	Else
		Return 0
	EndIf
EndFunc

Func GetAudioSource()
	$oHTTP.Open('GET', 'http://vk.com/audio', 0)
	$oHTTP.Send()
	$sData = $oHTTP.ResponseText
	Return $sData
EndFunc

Func DlSong($sLink, $sName, $sDir)
	$DlWin = GUICreate('Загрузка', 100, 10, -1, -1, $WS_POPUP)
	GUISetState(@SW_SHOW)
	$oProgress = GUICtrlCreateProgress(0, 0, 100, 10)
	$sName = StringReplace($sName, "'", "")
	$iSize = InetGetSize($sLink)
	If $iSize = 0 Then
		MsgBox(0, '', 'Ошибка загрузки')
		GUIDelete($DlWin)
		Return 0
	EndIf
	ConsoleWrite('$iSize ' & $iSize & @CRLF)
	$hFile = InetGet($sLink, $sDir & '\' & $sName & '.mp3', 0, 1)
    $iPercent = 0
	While $iPercent < 100
		$iReady = InetGetInfo($hFile, 0)
		ConsoleWrite('$iReady ' & $iReady & @CRLF)
		$iPercent = ($iReady/$iSize) * 100
		ConsoleWrite('$iPercent ' & $iPercent & @CRLF)
		GUICtrlSetData($oProgress, $iPercent)
		sleep(10)
	WEnd
	GUICtrlSetData($oProgress, 100)
	sleep(1000)
	GUIDelete($DlWin)
EndFunc

Func GetLink($sRecord)
	$aSong = StringRegExp($sRecord, '.*?\|.*?\|', 3)
	$start = StringInStr($sLog, $aSong[0]) + StringLen($aSong[0]) + 1
	$end = StringInStr($sLog, '.mp3', 0, 1, $start)
	$count = $end - $start
	$sCut = StringMid($sLog, $start, $count)
	$sLink = $sCut & '.mp3'
Return $sLink
EndFunc



Func Connect()
	If ping('vk.com') Then
		Return 1
	Else
		Return 0
	EndIf
EndFunc

Func GetAudioList($sSrc)
	GUISetState(@SW_DISABLE, $MainWin)
	$WinForWait = GUICreate('Пожалуйста подождите...', 180, 40, -1, -1, $WS_POPUP+$WS_BORDER+$WS_DLGFRAME)
	GUISetBkColor(0xFFFFFF, $WinForWait)
	GUICtrlCreateLabel('Построение списка...', 30, 10, 240, 20)
	GUISetState(@SW_SHOW, $WinForWait)
	GUISetState(@SW_DISABLE, $WinForWait)
	$aSrcElement = StringRegExp($sSrc, '(?s)<input type="hidden" id="audio_info.*?Audio\.selectPerformer.*?udio_remove_wrap fl_r', 3)
	For $i = 0 To UBound($aSrcElement) - 1
		$aDlLink = StringRegExp($aSrcElement[$i], '(?s)http://cs.[^<>]*?mp3', 3)
		$aPerformer = StringRegExp($aSrcElement[$i], '(?s)selectPerformer\(event,(.*?)\);', 3)
		$aSongName1 = StringRegExp($aSrcElement[$i], '(?s)<span class="title">([^<>]*?)<\/span><span', 3)
		$aSongName2 = StringRegExp($aSrcElement[$i], '(?s)cancelEvent\(event\);">([^<>]*?)<\/a> <\/span><span', 3)
		$aPerformer[0] = StringReplace($aPerformer[0], "'", "")

		If IsArray($aSongName1) Then
			$iSongSize = InetGetSize($aDlLink[0])
			$iSongSize = $iSongSize/1000000
			$aFormatSize = StringRegExp($iSongSize, '.*?\..', 3)
			If IsArray($aFormatSize) Then
				GUICtrlCreateListViewItem('' & $aPerformer[0] & '|' & $aSongName1[0] & '|' & $aFormatSize[0] & ' Мб' & '', $mylist)
				$sLog &= $aPerformer[0] & '|' & $aSongName1[0] & '| ' & $aDlLink[0] & @CRLF
			Else
				GUICtrlCreateListViewItem('' & $aPerformer[0] & '|' & $aSongName1[0] & '|' & $aFormatSize[0] & ' Мб' & '', $mylist)
				$sLog &= $aPerformer[0] & '|' & $aSongName1[0] & '| ' & '?' & @CRLF
			EndIf
		EndIf
		If IsArray($aSongName2) Then
			$iSongSize = InetGetSize($aDlLink[0])
			$iSongSize = $iSongSize/1000000
			$aFormatSize = StringRegExp($iSongSize, '.*?\..', 3)
			If IsArray($aFormatSize) Then
				GUICtrlCreateListViewItem('' & $aPerformer[0] & '|' & $aSongName2[0] & '|' & $aFormatSize[0] & ' Мб' & '', $mylist)
				$sLog &= $aPerformer[0] & '|' & $aSongName2[0] & '| ' & $aDlLink[0] & @CRLF
			Else
				GUICtrlCreateListViewItem('' & $aPerformer[0] & '|' & $aSongName2[0] & '|' & $aFormatSize[0] & ' Мб' & '', $mylist)
				$sLog &= $aPerformer[0] & '|' & $aSongName2[0] & '| ' & '?' & @CRLF
			EndIf
		EndIf
	Next
	GUISetState(@SW_ENABLE, $MainWin)
	GUIDelete($WinForWait)
EndFunc
