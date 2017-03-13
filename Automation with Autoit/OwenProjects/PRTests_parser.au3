#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Comment=Парсер для автоматизации тестирования
#AutoIt3Wrapper_Res_Description=Автоматизация процесса тестирования ПР
#AutoIt3Wrapper_Res_Fileversion=1.2.1.36
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=p
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Run_Debug_Mode
#include <File.au3>
#include <Date.au3>
#include <Excel.au3>
#include <MsgBoxConstants.au3>
#include <Constants.au3>
#include <CommMG.au3>
#include <Array.au3>
#include <FileConstants.au3>
;--------------------------------------------------------------------------------------------------------------
;Блок объявление переменных и массивов
Dim $CommNameMassiv[2] = ["Owen PR", "OWEN AC4 USB to RS"]  ; Список ПР-ов и ПЛК по названиям СОМ-портов
DIM $PRCommNumber
Dim $PLCConnect
Dim $PLCCommNumber
Dim $ErrMessage = 2
Dim $ss ; Переменнная для отладки
Dim $switch
Dim $PRSum = 1
Dim $CSVFiles[10][4]
Dim $OWLFiles[10][4]
Dim $emptyFolder = 0
Dim $maxRange = 0
Dim $OWLSize = 0
Dim $CmdLine1[2]
;$CmdLine1[1] = "/10.2.11.11"
$i = 0
$j = 0
$ii = 0
$jj = 0
;$ss=FileGetVersion("c:\Test\Owen\ProgramRelayFBD.exe","AssemblyVersion")
;MsgBox(64,"Get it",$ss)
;---------------------------------------------------------------------------------------------------------------

;---------------------------------------------------------------------------------------------------------------
;Блок поиска каталогов, csv-файлов и файлов с расширением *owl
$ListOfFolders = _FileListToArray(@ScriptDir,"*",2)
; Знаю, можно было написать и лучше=(
for $i = 1 to $ListOfFolders[0] ; Цикл поиска csv файлов
	$FuncReturnArray = _FileListToArray(@ScriptDir&"\"&$ListOfFolders[$i],"*.csv",1)
	;_ArrayDisplay($FuncReturnArray, "GG")
	if $FuncReturnArray = 0 Then
		$emptyFolder += 1
		ReDim $CSVFiles[$ListOfFolders[0]-$emptyFolder][$maxRange]
		ConsoleWrite("Не найден csv файл в папке "&$ListOfFolders[$i]&@CRLF)
		ConsoleWrite("Количество папок без csv файлов: "&$emptyFolder&@CRLF)
	Else

		if $maxRange < $FuncReturnArray[0] then
			$maxRange = $FuncReturnArray[0]
			ReDim $CSVFiles[$ListOfFolders[0]-$emptyFolder][$maxRange]
		EndIf
		if UBound($CSVFiles,1) < $ListOfFolders[0] Then
			ReDim $CSVFiles[$ListOfFolders[0]-$emptyFolder][$maxRange]
		endif
		for $j = 1 to $FuncReturnArray[0]
			$CSVFiles[$i-$emptyFolder-1][$j-1] = $ListOfFolders[$i]&"\"&$FuncReturnArray[$j]
		Next
	EndIf
Next
ConsoleWrite("Количество csv файлов :" & UBound($CSVFiles)&@CRLF)
For $i = 1 to UBound($CSVFiles)
	ConsoleWrite($i&"  -  "&$CSVFiles[$i-1][0]&@CRLF)
Next
;_ArrayDisplay($CSVFiles, "GGG")
; Знаю, можно было сделать функцию=(
$maxRange = 0
$emptyFolder = 0
for $i = 1 to $ListOfFolders[0] ; Цикл поиска owl файлов
	$FuncReturnArray = _FileListToArray(@ScriptDir&"\"&$ListOfFolders[$i],"*.owl",1)
	;_ArrayDisplay($FuncReturnArray, "GG")
	if $FuncReturnArray = 0 Then
		$emptyFolder += 1
		ReDim $OWLFiles[$ListOfFolders[0]-$emptyFolder][$maxRange]
		ConsoleWrite("Не найден owl файл в папке "&$ListOfFolders[$i]&@CRLF)
	Else

		if $maxRange < $FuncReturnArray[0] then
			$maxRange = $FuncReturnArray[0]
			ReDim $OWLFiles[$ListOfFolders[0]-$emptyFolder][$maxRange]
		EndIf
		if UBound($OWLFiles,1) < $ListOfFolders[0] Then
			ReDim $OWLFiles[$ListOfFolders[0]-$emptyFolder][$maxRange]
		endif
		for $j = 1 to $FuncReturnArray[0]
			$OWLFiles[$i-$emptyFolder-1][$j-1] = $ListOfFolders[$i]&"\"&$FuncReturnArray[$j]
		Next
	EndIf
Next
;_ArrayDisplay($OWLFiles, "GGG")
;---------------------------------------------------------------------------------------------------------------
;Функция поиска файлов по расширению
Func _FileSearch($sPath, $sFileMask)
    Local $sOut = StringToBinary("0"& @CRLF, 2), $aOut
    Local $hDir = Run(@ComSpec & ' /U/C DIR "'& $sPath &'\'& $sFileMask &'" /S/B/A-D', @SystemDir, @SW_HIDE, 6)
    While 1
        $sOut &= StdoutRead($hDir, False, True)
        If @error Then ExitLoop
    Wend
    $aOut = StringRegExp(BinaryToString($sOut,2), "[^\r\n]+", 3)
    If @error Then Return SetError(1)
    $aOut[0] = UBound($aOut)-1
    Return $aOut
EndFunc
;---------------------------------------------------------------------------------------------------------------
$ArrayOfComms=_ComGetPortNames(); Получаем список всех доступных СОМ-портов


;---------------------------------------------------------------------------------------------------------------
; Блок поиска СОМ-портов
For $i = 0 to UBound($ArrayOfComms)-1
	For $j = 0 to UBound($CommNameMassiv)-1
		If StringRegExp($ArrayOfComms[$i][1],$CommNameMassiv[$j]) Then
			;MsgBox(64,"Good","found COM")
			If $PRCommNumber <> 0 Then
				$PRSum+=1
				ReDim $PRCommNumber[$PRSum]
				$PRCommNumber[$PRSum-1] = $ArrayOfComms[$i][0]
				$ErrMessage = 1
			EndIf
			$PRCommNumber = $ArrayOfComms[$i][0]
			$ErrMessage = 0
			ConsoleWrite("Найден "&$CommNameMassiv[$j]&@CRLF)
		EndIf
	Next
Next
;----------------------------------------------------------------------------------------------------------------
;Блок определения переданных параметров программе и загрузка проекта в ПЛК
	If $CmdLine[0] <> 0 Then  ; Если заданы параметры для парсера
		; Проверка на IP
		If StringRegExp($CmdLine[1], "/"&"((25[0-5]|2[0-4]\d|[01]?\d\d?)\.){3}(25[0-5]|2[0-4]\d|[01]?\d\d?)") Then
			$PLCConnect = "/TCP"&StringRegExpReplace($CmdLine[1],"/","")
			;Run(@ComSpec&'plc_io.exe '&$PLCConnect&' /put "PR200.csv"','',@SW_HIDE)
			;Sleep(12000)
			;Run(@ComSpec&'plc_io.exe '&$PLCConnect&' /get "report.log"','',@SW_HIDE)
			$ErrMessage = 0
		;Проверка на СОМ
		ElseIf StringRegExp($CmdLine[1], "/"&"(?i)c(?i)O(?i)M"&"[0-9]{1,3}") Then
			$PLCConnect = "/COM"&StringRegExpReplace($CmdLine[1],"/(?i)c(?i)O(?i)M","")
			;Run(@ComSpec&'plc_io.exe '&$PLCConnect&'/put "PR200.csv"','',@SW_HIDE)
			;Sleep(12000)
			;Run(@ComSpec&'plc_io.exe '&$PLCConnect&' /get "report.log"','',@SW_HIDE)
			$ErrMessage = 0
		EndIf
	EndIf
	if $ErrMessage = 2 and $CmdLine[0] <> 0 Then
		MsgBox(64,"Неправильно задан параметр",$CmdLine[1]&" или не найдены подключенные устройства",5)
		Exit
	EndIf
	if $PLCCommNumber <> 0 And $CmdLine[0] = 0 Then
		if $ErrMessage = 1 Then
			$PLCConnect = $PLCCommNumber[0]
		Else
			$PLCConnect = $PLCCommNumber
		EndIf
		;Run(@ComSpec&'plc_io.exe '&$PLCCommNumber&' /put "PR200.csv"','',@SW_HIDE)
		;	Sleep(12000)
		;Run(@ComSpec&'plc_io.exe '&$PLCCommNumber&' /get "report.log"','',@SW_HIDE)
	EndIf
;MsgBox(64,"",$PLCConnect)
;ConsoleWrite("Запускаю Owen Logic"&@CRLF)
;$iPID=Run('C:\Test\Owen\ProgramRelayFBD.exe /pipe:v1','',@SW_SHOW)
;WinWait($iPID,'',4)
;WinSetState("OWEN Logic",'',@SW_SHOW)
ConsoleWrite("Запускаю Pipe"&@CRLF)
Run(@ScriptDir&"\"&'PipeClient.exe v1 ConnectToDevice /port:'&$PRCommNumber,"",@SW_SHOW)
$hFile = FileOpen(@ScriptDir&"\"&"result.html",2)
if @error = -1 Then
	ConsoleWrite("Ошибка: Не найден файл result.html"&@CRLF)
	Exit
EndIf
FileWrite($hFile,'<!DOCTYPE HTML> <html> <head>	<meta http-equiv="content-type" content="text/html" /> <meta charset="utf-8">	<meta name="author" content="admin" />	<title>Отчет по тесту</title></head><style>   .false {    color: red; /* Цвет символа */    }   .true {    color: green; /* Цвет текста */   }  </style><body>')
$OWLSize = UBound($OWLFiles,2) - 1
;if UBound($CSVFiles) <> UBound($OWLFiles) Then
;	MsgBox(64, " Ошибка: 1", "В какой то из папок не хватает *.csv или *.owl файла")
;	Exit
;EndIf
	for $i = 0 to UBound($CSVFiles) - 1
		if UBound($CSVFiles,2) <> 0 Then
			for $j = 0 to UBound($CSVFiles,2) - 1
				if $CSVFiles[$i][$j] = '' Then ExitLoop
				Local $oExcel = _Excel_Open(False)
				if @error then
					MsgBox(64,"Ошибка", "Не удалось открыть Excel " & @extended)
					Exit
				EndIf
				Local $oWorkbook = _Excel_BookOpen($oExcel,@ScriptDir&"\"&$CSVFiles[$i][$j])
				if @error Then
					MsgBox(64, " Ошибка", "Ошибка при открытии файла csv " & @error & "  " & @ScriptDir&"\"&$CSVFiles[$i][$j])
					Exit
				EndIf
				_Excel_RangeWrite($oWorkbook, $oWorkbook.Activesheet, "=СУММ(B2:B50)", "A50")
				$timeTotal = _Excel_RangeRead($oWorkbook,$oWorkbook.Activesheet, "A50")
				_Excel_RangeDelete($oWorkbook.Activesheet,"A50")
				;MsgBox(64," GGG", $timeTotal)
				_Excel_Close($oExcel)
				if UBound($OWLFiles,2) <> 0 Then
					if $OWLFiles[$i][$jj] = '' Then ExitLoop
					$jj = UBound($OWLFiles,2) - 1 - $OWLSize
					if $jj > UBound($OWLFiles,2) - 1 Then
						$jj = 0
						ConsoleWrite("Загружаю проект Owen Logic: "&$OWLFiles[$i][$jj]&@CRLF)
						$iPipe=RunWait('PipeClient.exe v1 StoreProject '&$OWLFiles[$i][$jj],'',@SW_SHOW)
						;MsgBox(64,"Info","загружаю "&$OWLFiles[$i][$jj],3)
					Else
						ConsoleWrite("Загружаю проект Owen Logic: "&$OWLFiles[$i][$jj]&@CRLF)
						$iPipe=RunWait('PipeClient.exe v1 StoreProject '&$OWLFiles[$i][$jj],'',@SW_SHOW)
						;MsgBox(64,"Info","загружаю "&$OWLFiles[$i][$jj],3)
					EndIf
					$OWLSize = $OWLSize - 1
				Else
					ConsoleWrite("Загружаю проект Owen Logic: "&$OWLFiles[$i]&@CRLF)
					$iPipe=RunWait('PipeClient.exe v1 StoreProject '&$OWLFiles[$i],@ScriptDir,@SW_SHOW)
					;MsgBox(64,"Info","загружаю "&$OWLFiles[$i],3)
				EndIf
				Sleep(4000)
				ConsoleWrite("Загружаю тест "&$CSVFiles[$i][$j]&@CRLF)
				ConsoleWrite("Общее время теста = "&$timeTotal&@CRLF)
				RunWait(@ScriptDir&"\"&'plc_io.exe  '&$PLCConnect&' /put  "'&$CSVFiles[$i][$j]&'"',@ScriptDir,@SW_SHOW)
				;MsgBox(64, " Info " , 'plc_io.exe  '&$PLCConnect&' /put  "'&$CSVFiles[$i][$j]&'"',3)
				Sleep($timeTotal)
				Sleep(8000)
				;MsgBox(64, "Отладка" , ' Запускаю команду /get "report.log"' ,3)
				ConsoleWrite("Запускаю команду /get report.log  1 раз")
				RunWait(@ScriptDir&"\"&'plc_io.exe '&$PLCConnect&' /get "report.log"',@ScriptDir,@SW_SHOW)
				Sleep(5000)
				If Not FileExists(@ScriptDir&"\"&"report.log") Then
					ConsoleWrite("Запускаю команду /get report.log  2 раз")
					RunWait(@ScriptDir&"\"&'plc_io.exe '&$PLCConnect&' /get "report.log"',@ScriptDir,@SW_SHOW)
					Sleep(2000)
				endif
				If Not FileExists(@ScriptDir&"\"&"report.log") Then
					ConsoleWrite("Запускаю команду /get report.log  3 раз")
					RunWait(@ScriptDir&"\"&'plc_io.exe '&$PLCConnect&' /get "report.log"',@ScriptDir,@SW_SHOW)
					Sleep(2000)
				endif
				If Not FileExists(@ScriptDir&"\"&"report.log") Then
					ConsoleWrite("Ошибка: report.log не получен от "&$CSVFiles[$i][$j]&@CRLF)
					Exit
				Else
					ConsoleWrite("Записываю результаты теста в файл result.html"&@CRLF)
					$sFile = FileOpen(@ScriptDir&"\"&"report.log")
					$CurrentTestLog = FileRead($sFile)
					if StringRegExp($CurrentTestLog,"FAILED") Then
						$a = FileWriteLine($hFile,"<b>"&$CSVFiles[$i][$j]&"<b>"&' - <span class = "false"> Тест НЕ прошел</span> <br />'&@CRLF)
						FileWrite($hFile,'<pre>'&$CurrentTestLog&'</pre>'&@CRLF)
						;FileClose($sFile)
						;FileClose($hFile)
						;ProcessClose($iPID)
						;Exit
						;MsgBox(64, "Отладка"," Write to File "&$a)
					Else
						FileWriteLine($hFile,"<b>"&$CSVFiles[$i][$j]&"<b>"&'<span class = "true"> - Тест успешно прошел</span> <br />'&@CRLF)
						FileWrite($hFile,'<pre>'&$CurrentTestLog&'</pre>'&@CRLF)
					EndIf
					FileClose($sFile)
					FileDelete(@ScriptDir&"\"&"report.log")
				EndIf
				if Not FileExists(@ScriptDir&"\"&"plc_io.exe") Then
					ConsoleWrite("Ошибка: Не найден plc_io"&@CRLF)
					Exit
				EndIf
			Next
		Else
			Local $oExcel = _Excel_Open(False)
			Local $oWorkbook = _Excel_BookOpen($oExcel,@ScriptDir&"\"&$CSVFiles[$i])
			_Excel_RangeWrite($oWorkbook, $oWorkbook.Activesheet, "=СУММ(B2:B50)", "A50")
			$timeTotal = _Excel_RangeRead($oWorkbook,$oWorkbook.Activesheet, "A50")
			_Excel_RangeDelete($oWorkbook.Activesheet,"A50")
			;MsgBox(64," GGG", $timeTotal)
			_Excel_Close($oExcel)
			if UBound($OWLFiles,2) <> 0 Then
				if $OWLFiles[$i][$jj] = '' Then ExitLoop
				$jj = UBound($OWLFiles,2) - 1 - $OWLSize
				if $jj > UBound($OWLFiles,2) - 1 Then
					$jj = 0
					ConsoleWrite("Загружаю проект Owen Logic: "&$OWLFiles[$i][$jj]&@CRLF)
					$iPipe=RunWait('PipeClient.exe v1 StoreProject '&$OWLFiles[$i][$jj],'',@SW_SHOW)
					;MsgBox(64,"Info","загружаю "&$OWLFiles[$i][$jj],3)
				Else
					ConsoleWrite("Загружаю проект Owen Logic: "&$OWLFiles[$i][$jj]&@CRLF)
					$iPipe=RunWait('PipeClient.exe v1 StoreProject '&$OWLFiles[$i][$jj],'',@SW_SHOW)
					;MsgBox(64,"Info","загружаю "&$OWLFiles[$i][$jj],3)
				EndIf
				$OWLSize = $OWLSize - 1
			Else
				ConsoleWrite("Загружаю проект Owen Logic: "&$OWLFiles[$i]&@CRLF)
				$iPipe=RunWait('PipeClient.exe v1 StoreProject '&$OWLFiles[$i],'',@SW_SHOW)
				;MsgBox(64,"Info","загружаю "&$OWLFiles[$i],3)
			EndIf
			ConsoleWrite("Загружаю тест "&$CSVFiles[$i][$j]&@CRLF)
			ConsoleWrite("Общее время теста = "&$timeTotal&@CRLF)
			RunWait(@ScriptDir&"\"&'plc_io.exe '&$PLCConnect&' /put "'&$CSVFiles[$i]&'"',@ScriptDir,@SW_SHOW)
			Sleep($timeTotal)
			Sleep(8000)
			ConsoleWrite("Запускаю команду /get report.log  1 раз")
			RunWait(@ScriptDir&"\"&'plc_io.exe '&$PLCConnect&' /get "report.log"',@ScriptDir,@SW_SHOW)
			Sleep(5000)
			If Not FileExists(@ScriptDir&"\"&"report.log") Then
				ConsoleWrite("Запускаю команду /get report.log  2 раз")
				RunWait(@ScriptDir&"\"&'plc_io.exe '&$PLCConnect&' /get "report.log"',@ScriptDir,@SW_SHOW)
				Sleep(2000)
			endif
			If Not FileExists(@ScriptDir&"\"&"report.log") Then
				ConsoleWrite("Запускаю команду /get report.log  3 раз")
				RunWait(@ScriptDir&"\"&'plc_io.exe '&$PLCConnect&' /get "report.log"',@ScriptDir,@SW_SHOW)
				Sleep(2000)
			endif
			If Not FileExists(@ScriptDir&"\"&"report.log") Then
				ConsoleWrite("Ошибка: report.log не получен от "&$CSVFiles[$i][$j]&@CRLF)
				Exit
			Else
				ConsoleWrite("Записываю результаты теста в файл result.html"&@CRLF)
				$sFile = FileOpen(@ScriptDir&"\"&"report.log")
				$CurrentTestLog = FileRead($sFile)
				if StringRegExp($CurrentTestLog,"FAILED") Then
					FileWriteLine($hFile,"<b>"&$CSVFiles[$i]&"<b>"&' - <span class = "false"> Тест НЕ прошел</span> <br />'&@CRLF)
					FileWrite($hFile,'<pre>'&$CurrentTestLog&'</pre>'&@CRLF)
					;FileClose($sFile)
					;FileClose($hFile)
					;ProcessClose($iPID)
					;Exit
				Else
					FileWriteLine($hFile,"<b>"&$CSVFiles[$i]&"<b>"&'<span class = "true"> - Тест успешно прошел</span> <br />'&@CRLF)
					FileWrite($hFile,'<pre>'&$CurrentTestLog&'</pre>'&@CRLF)
				EndIf
				FileClose($sFile)
				FileDelete(@ScriptDir&"\"&"report.log")
			EndIf
			if Not FileExists(@ScriptDir&"\"&"plc_io.exe") Then
				ConsoleWrite("Ошибка: Не найден plc_io"&@CRLF)
				Exit
			EndIf
		EndIf
	Next
	FileWrite($hFile,"<h3>Отчет по тестам был создан "&_NowTime(5)&'</h3> </body></html>')
FileClose($hFile)
;-----------------------------------------------------------------------------------------------------------------
; Блок загрузки проекта в ПР200
;$iPID=ShellExecute('C:\Test\Owen\ProgramRelayFBD.exe','/pipe:v1','','',@SW_HIDE)
;$iPID=Run('C:\Test\Owen\ProgramRelayFBD.exe /pipe:v1','',@SW_HIDE)
;WinWait($iPID,'',4)
;WinSetState("OWEN Logic",'',@SW_HIDE)
;ShellExecute('PipeClient.exe',' v1 ConnectToDevice /port:'&$PRCommNumber,'','',@SW_HIDE)
;for $i = 0 to UBound($OWLFiles)-1
;$iPipe=RunWait('PipeClient.exe v1 StoreProject TON_test.owl',@ScriptDir,@SW_SHOW)

;While 1
;$ss&=StdoutRead($iPipe)&@CRLF
;if @error Then ExitLoop
;WEnd


;_ArrayDisplay($ArrayOfComms," G")
;MsgBox(64,"",$PLCConnect)
;MsgBox(64,"",$PRCommNumber)
;MsgBox(64,"",$PLCCommNumber)
