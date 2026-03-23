#NoEnv  ; 推荐：防止脚本中使用未初始化的环境变量
#Warn   ; 推荐：启用一些常见错误的警告
SendMode Input  ; 推荐：使用更快的发送模式
SetWorkingDir %A_ScriptDir%  ; 确保脚本的工作目录是其自身所在的目录

; ================================================================
; === 配置区：请根据你的游戏和需求修改以下参数                 ===
; ================================================================

; 1. 游戏窗口识别：
;    通过 Window Spy 获取。可以使用完整标题，或更稳定的 ahk_class。
;    如果你使用 ahk_class，请修改 GameTitle := "ahk_class 你的Ahk_Class"
;    例如: GameTitle := "ahk_class UnityWndClass"
GameTitle := "ahk_class G66Win32Window"  ; <<<< !!! 已经为你修改为这个 !!! <<<<

; 2. 按键操作参数 (与Python脚本参数对应):
PressTime := 0.5            ; 按键持续时间（秒），默认0.5
WaitTime := 3.0             ; 每次操作后的等待时间（秒），默认3
N1Threshold := 10           ; N1阈值，决定何时从数字1切换到数字2，默认10
CycleTrigger := 500         ; 每多少个循环触发Y+数字键组合，默认500

; ================================================================
; === 全局变量 (无需修改)                                      ===
; ================================================================
global CycleCount := 0      ; 主循环计数器
global n := 0               ; Y+数字组合执行计数器
global IsRunning := false   ; 脚本运行状态标志

; ================================================================
; === 热键定义 (Ctrl+F10 启动/停止, Esc 退出)                  ===
; ================================================================

; Ctrl + F10 键启动/停止脚本
; ^ 代表 Ctrl 键
^F10::
    ToggleScript()
return

; Esc 键退出脚本
Esc::
    MsgBox, 48, 脚本退出, 脚本已停止并退出。
    ExitApp
return

; ================================================================
; === 函数定义                                                 ===
; ================================================================

; ToggleScript: 用于启动或停止主循环的函数
ToggleScript()
{
    global IsRunning, CycleCount, n
    global GameTitle, PressTime, WaitTime, N1Threshold, CycleTrigger

    IsRunning := !IsRunning ; 切换状态

    If IsRunning
    {
        ; 检查游戏窗口是否存在，不存在则提醒并停止
        If !WinExist(GameTitle)
        {
            MsgBox, 48, 错误, % "未找到游戏窗口: """ GameTitle """`n`n请确保游戏正在运行且窗口标题正确。"
            IsRunning := false ; 重置状态
            return
        }

        ToolTip, % "脚本已启动！正在寻找窗口 """ GameTitle """..." , 100, 100 ; 提示信息
        Sleep, 2000
        ToolTip ; 清除提示
        
        GoSub, MainLoopStart ; 启动主循环
    }
    Else
    {
        SetTimer, MainLoopHandler, Off ; 确保停止定时器
        MsgBox, 48, 脚本状态, 脚本已停止。
        CycleCount := 0 ; 停止时重置计数器
        n := 0          ; 重置Y+数字组合计数器
        ToolTip ; 清除提示
    }
}

; ExecuteYNumberCombo: 执行Y+数字键组合的函数
ExecuteYNumberCombo()
{
    global n, N1Threshold, GameTitle
    global WaitTime

    NumberKey := (n < N1Threshold) ? "1" : "2"

    ; 修改此处 ToolTip 和 OutputDebug 语句
    ToolTip, % "🎯 触发特殊操作 (n=" n ", N1=" N1Threshold ")`n执行组合: Y + " NumberKey, 100, 100
    OutputDebug, % "🎯 触发特殊操作 (n=" n ", N1=" N1Threshold ") - 执行组合: Y + " NumberKey

    ; 按下Y键
    ControlSend, , {y Down}, %GameTitle%
    Sleep, 50 ; 短暂按下
    ControlSend, , {y Up}, %GameTitle%

    Sleep, 200 ; 等待0.2秒

    ; 按下数字键
    ControlSend, , {%NumberKey% Down}, %GameTitle%
    Sleep, 50
    ControlSend, , {%NumberKey% Up}, %GameTitle%

    n++ ; n自增

    ; 修改此处 ToolTip 和 OutputDebug 语句
    ToolTip, % "  [状态] n 已更新: " (n-1) " → " n "`n  [预告] 下次将使用: Y + " ((n < N1Threshold) ? "1" : "2"), 100, 100
    OutputDebug, % "  [状态] n 已更新: " (n-1) " → " n "`n  [预告] 下次将使用: Y + " ((n < N1Threshold) ? "1" : "2")

    Sleep, 1000 ; 短暂显示提示

    ; 特殊操作完成后等待 args.wait_time 秒
    ToolTip, % "  特殊操作完成后等待 " WaitTime "秒...", 100, 100
    Sleep, % WaitTime * 1000
    ToolTip ; 清除提示
}


; MainLoopHandler: 这个Subroutine将作为 SetTimer 的目标，每次被调用时执行一个循环
MainLoopHandler:
    global IsRunning, CycleCount, n, N1Threshold, CycleTrigger
    global GameTitle, PressTime, WaitTime

    If (!IsRunning) ; 如果脚本被停止，则退出定时器
    {
        SetTimer, MainLoopHandler, Off
        return
    }

    CycleCount++

    ; 检查是否需要执行Y+数字组合
    If (Mod(CycleCount, CycleTrigger) = 0)
    {
        ExecuteYNumberCombo()
    }

    ; 修改此处 ToolTip 和 OutputDebug 语句
    ToolTip, % "第 " CycleCount " 个循环开始 (距离下次特殊操作还有 " (CycleTrigger - Mod(CycleCount, CycleTrigger)) " 个循环)", 100, 100
    OutputDebug, % "第 " CycleCount " 个循环开始 (距离下次特殊操作还有 " (CycleTrigger - Mod(CycleCount, CycleTrigger)) " 个循环)"

    ; 按下F键
    ControlSend, , {f Down}, %GameTitle%
    Sleep, % PressTime * 1000
    ControlSend, , {f Up}, %GameTitle%
    OutputDebug, % "  [步骤1] 按下F键并松开"

    ; F键操作完成后等待 args.wait_time 秒
    ; 修改此处 ToolTip 语句
    ToolTip, % "  F键操作完成后等待 " WaitTime "秒后继续...", 100, 100
    Sleep, % WaitTime * 1000
    ToolTip ; 清除提示
    OutputDebug, % "  F键操作完成后等待结束"

    ; 修改此处 ToolTip 和 OutputDebug 语句
    ToolTip, % "第 " CycleCount " 个循环完成", 100, 100
    OutputDebug, % "第 " CycleCount " 个循环完成"

    return

; MainLoopStart: 负责启动循环逻辑，以便更好地控制 Sleep 和 SetTimer
MainLoopStart:
    Loop
    {
        If (!IsRunning)
        {
            break ; 如果脚本停止，则跳出循环
        }
        GoSub, MainLoopHandler ; 执行一次循环内容
        ; MainLoopHandler 内部会进行 Sleep，所以这里不需要额外的 Sleep
    }
return