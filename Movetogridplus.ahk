; Added the option to pass the window id for snapping non-active windows
MoveToGrid(GridToMove, winid:=false)
{
global
if winid
winid = ahk_id %winid%
else
winid = A
triggerTop := %GridToMove%TriggerTop
triggerBottom := %GridToMove%TriggerBottom
triggerRight := %GridToMove%TriggerRight
triggerLeft := %GridToMove%TriggerLeft
GridBottom :=0
GridRight  :=0
GridTop    :=0
GridLeft   :=0

GridTop := %GridToMove%GridTop
GridBottom := %GridToMove%GridBottom
GridRight := %GridToMove%GridRight
GridLeft := %GridToMove%GridLeft


WinGetPos, WinLeft, WinTop, WinWidth, WinHeight,%winid%
WinGetClass,WinClass,%winid%
WinGet,WindowId,id,%winid%
WinGet,WinStyle,Style,%winid%

if SafeMode
if not (WinStyle & 0x40000) ;0x40000 = WS_SIZEBOX = WS_THICKFRAME
  {
  Return
  }

if (WinClass = "DV2ControlHost" OR Winclass = "Progman"
  OR Winclass = "Shell_TrayWnd")
Return

If Winclass in %Exceptions%
Return

If (GridTop = )
return

If (GridLeft = "WindowWidth" AND GridRight = "WindowWidth")
{
WinGetClass,WinClass,%winid%

if ShouldUseSizeMoveMessage(WinClass)
  SendMessage WM_ENTERSIZEMOVE, , , ,ahk_id %windowid%

WinMove, %winid%, ,%WinLeft%,%GridTop%, %WinWidth%,% GridBottom - GridTop,    

if ShouldUseSizeMoveMessage(WinClass)
  SendMessage WM_EXITSIZEMOVE, , , ,ahk_id %windowid%
StoreWindowState(WindowId,WinLeft,WinTop,WinWidth,WinHeight)
return
}
If (GridTop = "WindowHeight" AND GridBottom = "WindowHeight")
{
WinGetClass,WinClass,%winid%

if ShouldUseSizeMoveMessage(WinClass)
  SendMessage WM_ENTERSIZEMOVE, , , ,ahk_id %windowid%

WinMove, %winid%, ,%GridLeft%,%WinTop%, % GridRight - GridLeft,%WinHeight%,    

if ShouldUseSizeMoveMessage(WinClass)
  SendMessage WM_EXITSIZEMOVE, , , ,ahk_id %windowid%
StoreWindowState(WindowId,WinLeft,WinTop,WinWidth,WinHeight)
return
}
If (GridTop = "AlwaysOnTop")
{
WinSet, AlwaysOnTop, Toggle,%winid%
return
}
If (GridTop =  "Maximize")
{
winget,state,minmax,%winid%
if state = 1
  WinRestore,%winid%
else
  PostMessage, 0x112, 0xF030,,, %winid%,
return 
}
If (GridTop = "Run")
{
Run,%GridLeft% ,%GridRight%
return              
}
if (GridTop = "Restore")
{
data := GetWindowState(WindowId)
If data   
  {
  GridLeft  := WindowX
  GridRight := WindowX + WindowWidth
  GridTop   := WindowY
  GridBottom:= WindowY + WindowHeight 
  WinRestore,%winid%

  WinGetClass,WinClass,%winid%

  if ShouldUseSizeMoveMessage(WinClass)
    SendMessage WM_ENTERSIZEMOVE, , , ,ahk_id %windowid%

  WinMove, %winid%, ,%GridLeft%,%GridTop%,% GridRight - GridLeft,% GridBottom - GridTop

  if ShouldUseSizeMoveMessage(WinClass)
    SendMessage WM_EXITSIZEMOVE, , , ,ahk_id %windowid%

  StoreWindowState(WindowId,WinLeft,WinTop,WinWidth,WinHeight)
  }
return
}
GridTop := round(GridTop)
GridLeft := round(GridLeft)
GridRight := round(GridRight)
GridBottom := round(GridBottom)

GridWidth  := GridRight - GridLeft 
GridHeight := GridBottom - GridTop

WinRestore,%winid%

WinGetClass,WinClass,%winid%

if ShouldUseSizeMoveMessage(WinClass)
SendMessage WM_ENTERSIZEMOVE, , , ,ahk_id %windowid%

if Windows10
WinSnap("ahk_id" windowid, GridLeft,GridTop, GridWidth, GridHeight)
else
WinMove, %winid%, ,%GridLeft%,%GridTop%,%GridWidth%,%GridHeight%

if ShouldUseSizeMoveMessage(WinClass)
SendMessage WM_EXITSIZEMOVE, , , ,ahk_id %windowid%

StoreWindowState(WindowId,WinLeft,WinTop,WinWidth,WinHeight)
return
}
