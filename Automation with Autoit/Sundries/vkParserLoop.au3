#include <File.au3>
#include <Array.au3>
;#include <VK_API_New.au3>
#include <VK_Desktop_API.au3>

$sFile = FileOpen("C:/urls.txt")

$vklogin = "maximmagnus1@mail.ru"
$vkpass = "magnus92"

_vAPI_OAuth2($vklogin,$vkpass)

$return = _vAPI_GETMethod("groups.getById", "group_ids=tnull&fields=can_post")
_ArrayDisplay($return,"GGG")




