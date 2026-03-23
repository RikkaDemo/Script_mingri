#InstallKeybdHook
#UseHook
#Persistent
SetTitleMatchMode, 2

sync := true

; F9 开关
F9::
sync := !sync
if (sync)
    TrayTip,, 多窗口同步：开启
else
    TrayTip,, 多窗口同步：关闭
return


; 广播常用挂机按键
~$f::
~$y::
~$1::
~$2::
~$3::
~$4::
~$5::
if (sync)
{
    key := SubStr(A_ThisHotkey,3)
    WinGet, id, List, 明日之后
    Loop, %id%
    {
        this_id := id%A_Index%
        ControlSend,, %key%, ahk_id %this_id%
    }
}
return