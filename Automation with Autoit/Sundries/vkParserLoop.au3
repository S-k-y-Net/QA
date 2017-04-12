#include <File.au3>
#include <Array.au3>
;#include <VK_API_New.au3>
#include <VK_Desktop_API.au3>

$sFile = FileOpen("C:\qalib\Autoit\urls.txt") ; В этом файле надо писать короткое имя групп или id группы, Пример: vk.com/tnull полный путь, то в файле пише tnull

$vklogin = "test@mail.ru" ;Логин от фейк старници, от его имени будут расcылаться сообщения
$vkpass = "password" ; Пароль

_vAPI_OAuth2($vklogin,$vkpass)

Func SendMessage($ids)

	$message = "Test message from Autoit"  ; Здесь пишешь сообщение в личку группы

	$status = _vAPI_GETMethod("messages.send", "peer_id=-"&$ids&"&message="&$message)


EndFunc

Func Post($idp)

	$postmessage = "Test post from Autoit"  ;Здесь пишешь сообщение поста в группу

	$status = _vAPI_GETMethod("wall.post", "owner_id=-"&$idp&"&message='"&$postmessage&"'")


EndFunc

While 1
	$GroupName = FileReadLine($sFile)
	If @error = -1 Then ExitLoop

	if $GroupName = "" then
		ConsoleWrite("Есть пробелы в файле, пропускаю их")
	Else

		$return = _vAPI_GETMethod("groups.getById", "group_ids="&$GroupName&"&fields=can_post,can_message")

		if ($return[1][4] = 0) Then

			if ($return[1][8] = 1) Then

				Post($return[1][1])

			Else

				if ($return[1][9] = 1) Then

					SendMessage($return[1][1])

				Else

					ConsoleWrite("test")

				EndIf

			EndIf

		EndIf

	EndIf

WEnd


