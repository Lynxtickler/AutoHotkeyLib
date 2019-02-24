#include <MonitorConstants>
;#warn
AHI := new AutoHotInterception()
usb_kb_id := AHI.getkeyboardid(0x04d9, 0x1203)
ps2_kb_id := AHI.getkeyboardidfromhandle("ACPI\VEN_PNP&DEV_0303")
usb_contextmanager := AHI.CreateContextManager(usb_kb_id)
ps2_contextmanager := AHI.CreateContextManager(ps2_kb_id)
np0double := false
np0pressed := false
Lynxmove.initlib(func("movetogrid"))
Soundcard.initlib()

browser_search up::Soundcard.setloudnesseq("off")
browser_stop up::Soundcard.setloudnesseq("on")
launch_app2::Soundcard.setloudnesseq("off")
launch_app1::Soundcard.setloudnesseq("on")
browser_home up::Soundcard.soundcard("e")
browser_favorites up::Soundcard.soundcard("i")

#if usb_contextmanager.isactive

esc::f24
numlock::movetogrid(5)
numpaddiv::movetogrid(6)
numpadmult::movetogrid(7)
backspace::movetogrid(8)
numpadhome::
numpad7::
movetogrid(11)
return
numpadup::
numpad8::
movetogrid(13)
return
numpadpgup::
numpad9::
movetogrid(15)
return
numpadsub::Lynxmove.movetoscreen(CHATMONITOR)
numpadleft::
numpad4::
movetogrid(12)
return
numpadclear::
numpad5::
movetogrid(14)
return
numpadright::
numpad6::
movetogrid(16)
return
numpadadd::Lynxmove.moveallchat()
numpadend::
numpad1::
movetogrid(1)
return
numpaddown::
numpad2::
movetogrid(2)
return
numpadpgdn::
numpad3::
movetogrid(3)
return
numpadenter::movetogrid(4)
numpadins::
numpad0::
np0distinguish()
return
numpaddel::
numpaddot::
Lynxmove.movetoscreen(CODEMONITOR)
return

#if


#if ps2_contextmanager.isactive

numlock::Powermenu.open()
numpaddiv::
msiscreen := 2 ; vertical screen number
msioffset := 8
settitlematchmode, regex
winmove, MSI Afterburner v.* hardware monitor,, monitor%msiscreen%Left - msioffset, monitor%msiscreen%Top,, monitor%msiscreen%Height + msioffset
settitlematchmode, 1
return
numpadmult::Neeamode.neeamodeon()
numpadsub::Neeamode.neeamodeoff()
numpadhome::
numpad7::
return
numpadup::
numpad8::
return
numpadpgup::
numpad9::
return
numpadadd::Lynxmove.moveallwindowstogrid()
numpadleft::
numpad4::
return
numpadclear::
numpad5::
return
numpadright::
numpad6::
return
numpadend::
numpad1::
return
numpaddown::
numpad2::
return
numpadpgdn::
numpad3::
return
numpadenter::
driveget, driveletters, list, CDROM
if (strlen(driveletters) = 1)
    drive, eject, %driveletters%:
else
    msgbox, Several CD drives detected. Halting ejection.
return
numpadins::
numpad0::
return
backspace::
send, ^+1
return
numpaddel::
numpaddot::
return

#if

; The next two functions distinguish between a numpad 0 and 00 press
np0distinguish()
{
    global np0double
    doubletimeout := 35
    if (a_thishotkey = a_priorhotkey and a_timesincepriorhotkey < doubletimeout)
        np0double := true
    else
        np0double := false
    settimer, np0exec, %doubletimeout%
}

np0exec()
{
    global np0double, MAINMONITOR, BASICMONITOR
    if np0double
        Lynxmove.movetoscreen(MAINMONITOR)
    else
        Lynxmove.movetoscreen(BASICMONITOR)
    settimer, np0exec, delete
}


#include <AutoHotInterception>
#include <Lynxmove>
#include <Soundcard>
#include <Neeamode>
#include <Powermenu>