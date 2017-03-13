#include <File.au3>
#include <Array.au3>
#include <IE.au3>

$sFile = FileOpen("C:/urls.txt")

while 1

	if @error = -1 Then ExitLoop

	$sURL = FileReadLine($sFile)

	$IEBrowser = _IECreate($sURL)
	Sleep(4000)

	$sHTMLBody = _IEBodyReadHTML($IEBrowser)
	if (StringInStr("Написать сообщение</button>", $sHTMLBody) Then
	$regSearch = StringInStr("Написать сообщение</button>", $sHTMLBody

