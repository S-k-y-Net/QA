#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Comment=Парсер для автоматизации тестирования
#AutoIt3Wrapper_Res_Description=Автоматизация процесса тестирования ПР
#AutoIt3Wrapper_Res_Fileversion=1.3.0.61
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

Dim $CommNameMassiv[2] = ["Owen PR"]  ; Список ПР-ов по названиям СОМ-портов
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
Dim $totalTime
Dim $ignoreTest
Dim $arrayIgnoreTests[1]
Dim $failedTest =0
Dim $sucsessTests = 0
Dim $countTests = 0

;Блок определение установленной версии Owen Logic
;-------------------------------------------------------------------------------------------------------------------------------------------
$OSbits = @OSArch
;MsgBox(64,"GGGG",$OSbits)
$GetVersion = FileGetVersion(@ScriptDir&"\"&"Setup.exe") ; Берем устанавливаемую версию
;$OwenLogicSetupVersion = StringSplit($GetVersion,".") ; Раздеялем версию устанавливаемой программы на массив для сравнения
if FileExists("c:\Test\Owen\ProgramRelayFBD.exe") Then
	if $OSbits = "X86" Then ;Смотрим является 32-разрядной
		$reg = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OWEN Logic_is1" ;берем целый региср
	EndIf
	If $OSbits = "X64" Then ;Смотрим является 64-разрядной
		$reg = "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\OWEN Logic_is1" ;берем целый региср
	EndIf
	if $reg = "" Then
		ConsoleWrite("Не удалось определить разрядность ОС")
	else
	$OwenLogicCurrentVersion = RegRead($reg & "\", "DisplayVersion") ;берем версию из списка регистра
	ConsoleWrite("Установленная версия Owen Logic "&$OwenLogicCurrentVersion&@CRLF)
	endif
	;$OwenLogicCurrentVersion = StringSplit($OwenLogicCurrentVersion,".") ; Раздеялем версию установленной программы на массив для сравнения
EndIf
;--------------------------------------------------------------------------------------------------------------------------------------------

$ListOfFolders = _FileListToArray(@ScriptDir,"*",2) ; получаем список папок в папке где находится парсер

ConsoleWrite("Количество найденных папок :" & UBound($ListOfFolders)&@CRLF)


For $i = 1 to UBound($ListOfFolders) ;перечисляем найденные папки, также входят скрытые

	ConsoleWrite($i&"  -  "&$ListOfFolders[$i-1]&@CRLF)

Next

Func _WatchDog()
	Local $timer
	if (ProcessExists("PipeClient.exe") > 0) Then
		$timer = $timer + 1
		if ($timer = 1200) Then Exit
	EndIf
EndFunc

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
;_ArrayDisplay($ArrayOfComms)
;---------------------------------------------------------------------------------------------------------------
; Блок поиска СОМ-портов c ПР
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

;Блок определения переданных параметров программе для загрузки проекта в ПЛК
	If $CmdLine[0] <> 0 Then  ; Если заданы параметры для парсера
		; Проверка на IP
		If StringRegExp($CmdLine[1], "/"&"((25[0-5]|2[0-4]\d|[01]?\d\d?)\.){3}(25[0-5]|2[0-4]\d|[01]?\d\d?)") Then

			$PLCConnect = "/TCP"&StringRegExpReplace($CmdLine[1],"/","")
			$ErrMessage = 0

		;Проверка на СОМ
		ElseIf StringRegExp($CmdLine[1], "/"&"(?i)c(?i)O(?i)M"&"[0-9]{1,3}") Then

			$PLCConnect = "/COM"&StringRegExpReplace($CmdLine[1],"/(?i)c(?i)O(?i)M","")
			$ErrMessage = 0
		EndIf
	EndIf
	if $ErrMessage = 2 and $CmdLine[0] <> 0 Then

		ConsoleWrite("Неправильно задан параметр "&$CmdLine[1]&" или не найдены подключенные устройства")
		Exit

	EndIf

;----------------------------------------------------------------------------------------------------------------

;Блок определения переданных параметров программе для загрузки проекта в ПР
	If $CmdLine[0] > 1 Then  ; Если заданы параметры для парсера
		If StringRegExp($CmdLine[2], "/"&"(?i)c(?i)O(?i)M"&"[0-9]{1,3}") Then

			$PRCommNumber = StringRegExpReplace($CmdLine[2],"/","")
			$ErrMessage = 0

		EndIf

	EndIf
	if $ErrMessage = 2 and $CmdLine[0] <> 0 Then

		ConsoleWrite("Неправильно задан параметр "&$CmdLine[2]&" или не найдены подключенные устройства")
		Exit

	EndIf

;$PRCommNumber = "COM3"
;$PLCConnect = "/TCP10.2.11.11"
ConsoleWrite("Запускаю Pipe c портом "&$PRCommNumber&@CRLF)
Run(@ScriptDir&"\"&'PipeClient.exe v1 ConnectToDevice /port:'&$PRCommNumber,"",@SW_SHOW)

$hFile = FileOpen(@ScriptDir&"\"&"result.html",2)

if @error = -1 Then
	ConsoleWrite("Ошибка: Не найден файл result.html"&@CRLF)
	Exit
EndIf

FileWrite($hFile,'<!DOCTYPE HTML> <html> <head>	<meta http-equiv="content-type" content="text/html" /> <meta charset="utf-8">	<meta name="author" content="admin" />	<title>Отчет по тесту</title></head><style>   .false {    color: red; /* Цвет символа */    }   .true {    color: green; /* Цвет текста */   }  </style><body>')
;_ArrayDisplay($ListOfFolders,"RRRe")
for $i = 1 to $ListOfFolders[0]

	$FuncReturnArray = _FileListToArray(@ScriptDir&"\"&$ListOfFolders[$i],"*.owl",1)
	;ConsoleWrite($i&"  "&@CRLF)
	;_ArrayDisplay($FuncReturnArray,"RRRR")

	;Поиск  папки на содержание файла pass.test
	$passTest = FileFindFirstFile(@ScriptDir&"\"&$ListOfFolders[$i]&"\"&"pass.test")
	if $passTest  = -1 Then

		if $FuncReturnArray = 0 Then
			ConsoleWrite("Не найден owl файл в папке "&$ListOfFolders[$i]&@CRLF)
		Else
			;$countTests = $countTests + 1 пока еще не надо
			ConsoleWrite("Загружаю проект Owen Logic: "&$ListOfFolders[$i]&"\"&$FuncReturnArray[1]&@CRLF)
			$iPipe=RunWait(@ScriptDir&"\"&'PipeClient.exe v1 StoreProject '&@ScriptDir&"\"&$ListOfFolders[$i]&"\"&$FuncReturnArray[1],'',@SW_SHOW)
			AdlibRegister("_WatchDog")
		EndIf

		ConsoleWrite(@CRLF)

		$FuncReturnCSV = _FileListToArray(@ScriptDir&"\"&$ListOfFolders[$i],"*.csv",1)

		;_ArrayDisplay($FuncReturnCSV,"RRR")

		if $FuncReturnCSV = 0 Then
			ConsoleWrite("Не найден csv файл в папке "&$ListOfFolders[$i]&@CRLF)
		Else


			for $j = 1 to $FuncReturnCSV[0]

				$totalTime = 0

				if $ListOfFolders[$i]&"\"&$FuncReturnCSV[$j] = '' Then ExitLoop

					$efile = FileOpen(@ScriptDir&"\"&$ListOfFolders[$i]&"\"&$FuncReturnCSV[$j], 0)

					if @error = -1 Then
						ConsoleWrite("Can not open "&$ListOfFolders[$i]&"\"&$FuncReturnCSV[$j])
						Exit
					EndIf

					$line = FileReadLine($efile)

					While 1
						$line = FileReadLine($efile)
						if $line = "" Then
							ExitLoop
						EndIf
						ConsoleWrite($line&@CRLF)
						$splitline = StringSplit($line,";")
						;_ArrayDisplay($splitline,"GGGG")
						if (UBound($splitline) > 2) Then
							$totalTime = $totalTime +  Int($splitline[2])
							ConsoleWrite($totalTime&@CRLF)
						EndIf
						If @error = -1 Then ExitLoop
					Wend

					FileClose($efile)
					Sleep(4000)

					ConsoleWrite("Загружаю тест "&$ListOfFolders[$i]&"\"&$FuncReturnCSV[$j]&@CRLF)
					ConsoleWrite("Общее время теста = "&$totalTime&@CRLF)

					$PipePID = Run(@ScriptDir&"\"&'plc_io.exe  '&$PLCConnect&' /put  "'&@ScriptDir&"\"&$ListOfFolders[$i]&"\"&$FuncReturnCSV[$j]&'"',@ScriptDir,@SW_SHOW)

					Sleep(6000)

					Run(@ScriptDir&"\"&'plc_io.exe  '&$PLCConnect&' /put  "'&@ScriptDir&"\"&$ListOfFolders[$i]&"\"&$FuncReturnCSV[$j]&'"',@ScriptDir,@SW_SHOW)

					Sleep(6000)

					;$CmdOutput = StdoutRead($PipePID)

					;If (StringInStr($CmdOutput,"Ошибка")) Then

					;	Run(@ScriptDir&"\"&'plc_io.exe  '&$PLCConnect&' /put  "'&@ScriptDir&"\"&$ListOfFolders[$i]&"\"&$FuncReturnCSV[$j]&'"',@ScriptDir,@SW_SHOW)

					;EndIf
					;RunWait(@ScriptDir&"\"&'plc_io.exe  '&$PLCConnect&' /put  "'&@ScriptDir&"\"&$ListOfFolders[$i]&"\"&$FuncReturnCSV[$j]&'"',@ScriptDir,@SW_SHOW)

					Sleep($totalTime)

					Sleep(8000)

					ConsoleWrite("Запускаю команду /get report.log  1 раз"&@CRLF)
					RunWait(@ScriptDir&"\"&'plc_io.exe '&$PLCConnect&' /get "report.log"',@ScriptDir,@SW_SHOW)
					Sleep(5000)

					If Not FileExists(@ScriptDir&"\"&"report.log") Then
						ConsoleWrite("Запускаю команду /get report.log  2 раз"&@CRLF)
						RunWait(@ScriptDir&"\"&'plc_io.exe '&$PLCConnect&' /get "report.log"',@ScriptDir,@SW_SHOW)
						Sleep(2000)
					endif

					If Not FileExists(@ScriptDir&"\"&"report.log") Then
						ConsoleWrite("Запускаю команду /get report.log  3 раз"&@CRLF)
						RunWait(@ScriptDir&"\"&'plc_io.exe '&$PLCConnect&' /get "report.log"',@ScriptDir,@SW_SHOW)
						Sleep(2000)
					endif

					If Not FileExists(@ScriptDir&"\"&"report.log") Then
						ConsoleWrite("Ошибка: report.log не получен от "&$ListOfFolders[$i]&"\"&$FuncReturnCSV[$j]&@CRLF)
						Exit
					Else

						ConsoleWrite("Записываю результаты теста в файл result.html"&@CRLF)

						$sFile = FileOpen(@ScriptDir&"\"&"report.log")

						$CurrentTestLog = FileRead($sFile)
						if StringRegExp($CurrentTestLog,"FAILED") Then
							$a = FileWriteLine($hFile,"<b>"&$ListOfFolders[$i]&"\"&$FuncReturnCSV[$j]&"<b>"&' - <span class = "false"> Тест НЕ прошел</span> <br />'&@CRLF)
							FileWrite($hFile,'<pre>'&$CurrentTestLog&'</pre>'&@CRLF)
							$failedTest =$failedTest + 1
									;FileClose($sFile)
									;FileClose($hFile)
									;ProcessClose($iPID)
									;Exit
									;MsgBox(64, "Отладка"," Write to File "&$a)
						Else
							FileWriteLine($hFile,"<b>"&$ListOfFolders[$i]&"\"&$FuncReturnCSV[$j]&"<b>"&'<span class = "true"> - Тест успешно прошел</span> <br />'&@CRLF)
							FileWrite($hFile,'<pre>'&$CurrentTestLog&'</pre>'&@CRLF)
							$sucsessTests = $sucsessTests + 1
						EndIf
					EndIf
					FileClose($sFile)
					FileDelete(@ScriptDir&"\"&"report.log")

			Next

		EndIf
	Else
		$ignoreTest = $ignoreTest + 1
		Redim $arrayIgnoreTests[$ignoreTest]
		$arrayIgnoreTests[$ignoreTest - 1] = $ListOfFolders[$i]
	EndIf
Next
$totalTests = $ListOfFolders[0] - 1
FileWrite($hFile,"<h3>Отчет по тестам был создан "&_NowTime(5)&'</h3> </body></html>')
FileWrite($hFile,"<h3>Тестируемая версия Owen Logic "&$OwenLogicCurrentVersion&'</h3>')
FileWrite($hFile,"<h3>Общее количество тестов: "&$totalTests&'</h3>')
FileWrite($hFile,"<h3>Пройденных тестов: "&$sucsessTests&'</h3>')
FileWrite($hFile,"<h3>Непройденных тестов: "&$failedTest&'</h3>')
FileWrite($hFile,"<h3>Пропущенных тестов: "&$ignoreTest&'</h3>')
for $i = 0 to UBound($arrayIgnoreTests) - 1
	FileWrite($hFile,"<h4>"&$i&".  "&$arrayIgnoreTests[$i]&'</h4>')
Next
FileClose($hFile)

$PIDs = ProcessList('ProgramRelayFBD.exe') ;Возвращает двумерный массив, содержащий список выполняемых процессов (имя и PID).
For $i = 1 To $PIDs[0][0] ;$PIDs[0][0] - это количество процессов
    If ProcessExists($PIDs[$i][1]) Then ProcessClose($PIDs[$i][1]) ;Если процесс существует, то закрываем его
Next


