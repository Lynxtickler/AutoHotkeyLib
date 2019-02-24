;#warn
#include <Monitorconfig>


; Resembles a piece of grid that can have smaller pieces inside it, hence the tree structure
class Gridnode
{
    __New(value)
    {
        this.value := value
        this.children := []
    }

    addchild(gnchild)
    {
        this.children.push(gnchild)
    }

    count()
    {
        if (this.children.length() = 0)
            return 1
        total := 0
        for each, child in this.children
            total += child.count()
        return total
    }
}


/* 
An extension to gridmove. Utilises the dynamic nature I've added to original GridMove functionality and moves many windows at a time.
Using this may require programming skills and AutoHotkey's WindowSpy. This class is coded with my setup and the programs I use in mind.

Due to AutoHotkey's clumsiness this static class must still be initialised with the initlib-function to get the class variables right.
*/
class Lynxmove
{
    static DISCORD_TITLE := "ahk_exe Discord.exe"
    static TELEGRAM_TITLE := "ahk_exe Telegram.exe"
    static WHATSAPP_TITLE := "ahk_exe WhatsApp.exe"
    static STEAM_CLASS := "SDL_app"
    static STEAM_TITLE := "ahk_class SDL_app"
    static ABORTSTRING := "ABORT_EXECUTION"
    static CHATSTRING := "CHAT_CLASS"
    static ANNOUNCEMSGBOXOPTIONS := 48
    static SUBLIMECLASS := "PX_WINDOW_CLASS"
    static EXCLUDE_SUBLIME_RE := ".*\Packages\User\Default (Windows).sublime-.*"
    static CHROMECLASS := "Chrome_WidgetWin_1"
    static STEAMCLASS := "vguiPopupWindow"

    static screencoordinates =
    
    ; make sure to pass the grid moving function as param
    initlib(movetogridref)
    {
        this.ABORTCLASSES := ["TFruityLoopsMainForm"] ; move nothing if one of these exists
        this.CHATCLASSES := {"Qt5QWindowIcon" : ["Telegram", true, "t"], this.STEAM_CLASS : ["Friends List", false, "s"]}
        ; format: {ignoreclass : [exceptIfTitle, exactOrNo]}
        this.SPECIALCLASSES := {"ApplicationFrameWindow" : ["Settings", true], "AutoHotkeyGUI" : ["placeholder", true]}
        this.EXCLUDECLASSES := ["ThumbnailDeviceHelperWnd", "#32770", "RainmeterMeterWindow", "Shell_TrayWnd", "TelegramShadow", "DummyDWMListenerWindow"
            ,"EdgeUiInputTopWndClass", "WorkerW", "Progman", "SysShadow", "Alternate Owner", "HH Parent", "tooltips_class32", "TkTopLevel"
            ,"Afx:00400000:20:00010009:00000000:00000000", "ApolloRuntimeContentWindow", "WindowsForms10.Window.8.app.0.141b42a_r9_ad1"]
        this.PRIORITIES := [["MozillaWindowClass"]
                            ,[this.CHROMECLASS, this.SUBLIMECLASS, "WindowsForms10.Window.8.app.0.2bf8098_r9_ad1"]
                            ,["CabinetWClass", "ConsoleWindowClass", "TaskManagerWindow", "ApplicationFrameWindow"]]
        
        this.screencoordinates := Getmonitorsizes(true)
        this.r_movetogrid := movetogridref
    }

    sysgetwrapper(subcommand, value:="")
    {
        if value
            sysget, retval, %subcommand%, %value%
        else
            sysget, retval, %subcommand%
        return retval
    }

    movetoscreen(screennumber, hwnd:=false)
    {
        if hwnd
            hwnd = ahk_id %hwnd%
        else
            hwnd = a
        xpos := this.screencoordinates[screennumber]["left"]
        ypos := this.screencoordinates[screennumber]["top"]
        winrestore, %hwnd%
        winmove, %hwnd%,, %xpos%, %ypos%
        winmaximize, %hwnd%
    }

    moveallchat(telegram_substitute:=false, whatsapp_substitute:=false, steam_substitute:=false)
    {
        if !winexist(this.DISCORD_TITLE)
        {
            run, dc
            return
        }
        t := telegram_substitute ? telegram_substitute : winexist(this.TELEGRAM_TITLE)
        w := whatsapp_substitute ? whatsapp_substitute : winexist(this.WHATSAPP_TITLE)
        s := steam_substitute ? steam_substitute : winexist(this.STEAM_TITLE)
        if w
        {
            if s
            {
                this.movechat(this.WHATSAPP_TITLE, 3)
                this.movechat(this.STEAM_TITLE, 4)
            }
            else
                this.movechat(this.WHATSAPP_TITLE, 1)
            if t
            {
                this.movechat(this.TELEGRAM_TITLE, 5)
                this.movechat(this.DISCORD_TITLE, 6)
            }
            else
                this.movechat(this.DISCORD_TITLE, 2)
            return
        }
        if t
        {
            if s
            {
                this.movechat(this.TELEGRAM_TITLE, 3)
                this.movechat(this.STEAM_TITLE, 4)
            }
            else
                this.movechat(this.TELEGRAM_TITLE, 1)
        }
        else if s
            this.movechat(this.STEAM_TITLE, 1)
        this.movechat(this.DISCORD_TITLE, 2)
    }

    movechat(title, position)
    {
        chatmon := this.screencoordinates[CHATMONITOR]
        lmonw := chatmon["width"] / 3
        rmonw := lmonw * 2
        winrestore, %title%
        if (position = 1)
            winmove, %title%,, chatmon["left"], chatmon["top"], lmonw, chatmon["height"]
        else if (position = 2)
            winmove, %title%,, chatmon["left"] + lmonw, chatmon["top"], rmonw, chatmon["height"]
        else if (position = 3)
            winmove, %title%,, chatmon["left"], chatmon["top"], lmonw, chatmon["height"] / 2
        else if (position = 4)
            winmove, %title%,, chatmon["left"], chatmon["top"] + chatmon["height"] / 2, lmonw, chatmon["height"] / 2
        else if (position = 5)
            winmove, %title%,, chatmon["left"] + lmonw, chatmon["top"], rmonw, chatmon["height"] / 2
        else
            winmove, %title%,, chatmon["left"] + lmonw, chatmon["top"] + chatmon["height"] / 2, rmonw, chatmon["height"] / 2
    }

    steamchatexist()
    {
        settitlematchmode, 2
        winget, winid,, - Chat
        settitlematchmode, 1
        if winexist("ahk_exe Steam.exe ahk_id " winid)
            return winid
        return false
    }

    moveallwindowstogrid(maximise:=false)
    {
        ; save the hwnd of current active window
        winget, original_active_window, id, a
        ; create the array with root nodes in it
        gridroot := [new Gridnode("mon" . MAINMONITOR), new Gridnode("mon" . BASICMONITOR), new Gridnode("mon" . CODEMONITOR)]
        for each, item in [4, 3]
            gridroot[1].addchild(new Gridnode(item))
        for each, item in [15, 16]
            gridroot[1].children[2].addchild(new Gridnode(item))

        for each, item in [2, 1]
            gridroot[2].addchild(new Gridnode(item))
        for each, item in [13, 14]
            gridroot[2].children[1].addchild(new Gridnode(item))
        for each, item in [11, 12]
            gridroot[2].children[2].addchild(new Gridnode(item))

        for each, item in [8, 5]
            gridroot[3].addchild(new Gridnode(item))
        for each, item in [6, 7]
            gridroot[3].children[1].addchild(new Gridnode(item))

        movablewindows := [[], [], [], []] ; priorities: 1=super 2=high 3=normal 4=low

        sublimepriority =
        sublimeexists := this.checksublimeexists()
        firstchromeoccurence := false
        chromepriority =
        freechatslots := ["t", "w", "s"]
        winget, winlist, list
        loop, %winlist%
        {
            thisid := winlist%a_index%
            wingetclass, thisclass, ahk_id %thisid%
            windowmovepriority := this.getwindowmovepriority(thisid)
            if (windowmovepriority = this.ABORTSTRING)
                return
            else if instr(windowmovepriority, this.CHATSTRING)
            {
                idletter := substr(windowmovepriority, 0)
                if (idletter != "d")
                {
                    if (idletter = "t")
                        freechatslots.removeat(1)
                    else if (idletter = "w")
                        freechatslots.removeat(2)
                    else if (idletter = "s")
                        freechatslots.removeat(3)
                }
            }
            else if windowmovepriority
            {
                if !firstchromeoccurence
                {
                    if (thisclass = this.CHROMECLASS)
                    {
                        firstchromeoccurence := thisid
                        chromepriority := windowmovepriority
                        continue
                    }
                }
                if (thisclass = this.SUBLIMECLASS)
                {
                    sublimepriority := windowmovepriority
                }
                else if (movablewindows[windowmovepriority].length() = 0)
                    movablewindows[windowmovepriority][1] := thisid
                else
                    movablewindows[windowmovepriority].push(thisid)
            }
        }
        if firstchromeoccurence
            movablewindows[chromepriority].insertat(1, firstchromeoccurence)
        if sublimeexists
            movablewindows[sublimepriority].insertat(1, sublimeexists)
        ; determine which grid groups are needed
        wincount := 0
        for each, wingroup in movablewindows
            wincount += wingroup.length()
        freechatslotcount := freechatslots.length()

        superprexists := false
        basicmonitorreserve := false
        if (movablewindows[1].length() = 1)
        {
            superprexists := movablewindows[1][1]
            movablewindows[1].pop()
            wincount--
            basicmonitorreserve := gridroot[2]
            gridroot.removeat(2)
        }
        else if (movablewindows[1].length() > 1)
        {
            msgbox, % this.ANNOUNCEMSGBOXOPTIONS, %a_scriptname%, Too many superpriority windows open. Terminating. Better handler needed.
            return
            ; make every superpriority window a high-priority one
            movablewindows[2] := movablewindows[1].push(movablewindows[2]*)
            movablewindows[1] := []
        }
        this.refreshgridcounts(gridroot, gridslotcount, gridslotnoleftcount, gridrootnoleft)
        if (wincount > gridslotcount + freechatslotcount)
        {
            if (wincount > gridslotcount + freechatslotcount + basicmonitorreserve.count())
            {
                msgbox, % this.ANNOUNCEMSGBOXOPTIONS, %a_scriptname%, Too many windows open`, arrange them manually or consider closing a few.
                return
            }
            movablewindows[2].insertat(1, superprexists)
            gridroot.insertat(2, basicmonitorreserve)
            this.refreshgridcounts(gridroot, gridslotcount, gridslotnoleftcount, gridrootnoleft)
        }
        temparray := []
        temparraysecondary := []
        gridarray := []
        for i in gridroot
        {
            if (i = gridroot.length()) ; TODO: assignaa kaikille näytöille kanssa indeksit ja muuta tää
            {
                if sublimeexists
                    gridarray.insertat(1, gridroot[i])
                else
                    temparraysecondary.push(gridroot[i].children*)
            }
            else
            {
                gridarray.push(gridroot[i].children[1])
                loop, % gridroot[i].children.length() - 1
                    temparray.push(gridroot[i].children[a_index + 1])
            }
        }
        temparray.push(temparraysecondary*)
        for each, node in temparray
            gridarray.push(node)
        ; start splitting grids in half from the end
        nodeidx := gridarray.length()
        fullloops := 0
        substitutes_resolved := 0
        while (wincount > gridarray.length() + substitutes_resolved)
        {
            if (gridslotcount <= gridarray.length())
                break
            len := gridarray.length()
            ; initialise newarray
            newarray := []
            if (nodeidx == 1)
            {
                if (sublimeexists)
                {
                    ; increasing this threshold makes keeping sublime bigger more of a priority
                    if (fullloops > 0)
                    {
                        fullloops := 0
                        ; split the slot sublime occupies if there are children left
                        if (gridarray[1].children.length() != 0)
                        {
                            newarray := [gridarray[1].children[1]]
                            loop, % gridarray.length() - 1
                            {
                                newarray.push(gridarray[a_index + 1])
                            }
                            loop, % gridarray[1].children.length() - 1
                            {
                                newarray.push(gridarray[1].children[a_index + 1])
                            }
                        }
                        gridarray := newarray
                    }
                    fullloops++
                    nodeidx := gridarray.length()
                    continue
                }
                fullloops++ ; the rest is done at the end of the loop
            }

            ; add everything before this node to helper array
            loopidx := 1
            loop, % nodeidx - 1
            {
                newarray.push(gridarray[loopidx])
                loopidx++
            }
            orig_nodeidx := 0
            ; add this node's children to helper array else add this node if there's no children
            if (gridarray[nodeidx].children.length() != 0)
            {
                newarray.push(gridarray[nodeidx].children*)
                orig_nodeidx := nodeidx
            }
            else
            {
                newarray.push(gridarray[nodeidx])
                orig_nodeidx := nodeidx
            }
            ; add the rest of the array to the tail of the new one
            loopidx := orig_nodeidx + 1
            loop, % gridarray.length() - orig_nodeidx
            {
                newarray.push(gridarray[loopidx])
                loopidx++
            }
            ; replace the original array with the new one
            gridarray := newarray
            (nodeidx = 1) ? nodeidx := gridarray.length() : nodeidx--
        }

        telegram_substitute := false
        whatsapp_substitute := false
        steam_substitute := false
        loop, % wincount - gridarray.length()
        {
            lastitemgroupidx := movablewindows.length()
            lastitemidx := 1
            loop, % lastitemgroupidx
            {
                if (movablewindows[lastitemgroupidx].length() != 0)
                {
                    lastitemidx := movablewindows[lastitemgroupidx].length()
                    break
                }
                lastitemgroupidx--
            }

            if (freechatslots[a_index] = "t")
                telegram_substitute := "ahk_id " . movablewindows[lastitemgroupidx][lastitemidx]
            else if (freechatslots[a_index] = "w")
                whatsapp_substitute := "ahk_id " . movablewindows[lastitemgroupidx][lastitemidx]
            else if (freechatslots[a_index] = "s")
                steam_substitute := "ahk_id " . movablewindows[lastitemgroupidx][lastitemidx]
            movablewindows[lastitemgroupidx].removeat(lastitemidx)
            substitutes_resolved++
        }

        ; move all the windows to defined slots
        if superprexists
            this.movetoscreen(BASICMONITOR, superprexists)
        for prioritylevel, prioritygroup in movablewindows
        {
            for each, hwnd in prioritygroup
            {
                if instr(gridarray[1].value, "mon")
                    this.movetoscreen(substr(gridarray[1].value, 0), hwnd)
                else
                    this.r_movetogrid.(gridarray[1].value, hwnd)
                gridarray.removeat(1)
            }
        }
        this.moveallchat(telegram_substitute, whatsapp_substitute, steam_substitute)
        ; activate the original active window
        winactivate, ahk_id %original_active_window%
    }

    refreshgridcounts(root, byref gridslotcount, byref gridslotnoleftcount, byref gridrootnoleft)
    {
        gridslotcount := 0
        gridslotnoleftcount := 0
        gridrootnoleft := []
        for each, mon in root
        {
            gridslotcount += mon.count()
            if not instr(mon, BASICMONITOR)
            {
                gridslotnoleftcount += mon.count()
                gridrootnoleft.push(mon)
            }
        }
    }

    getfirstoccurence(obj, matcharr)
    {
        for idx, item in obj
        {
            for each, match in matcharr
            {
                if (match = item)
                    return idx
            }
        }
        return 0
    }

    getlastoccurence(obj, matcharr)
    {
        retidx := 0
        for idx, item in obj
        {
            for each, match in matcharr
            {
                if (match = item)
                    retidx := idx
            }
        }
        return retidx
    }

    ; debug function
    printarray(name, arr)
    {
        arrtxt = [
        for each, item in arr
        {
            if item =
                item := item.value
            arrtxt .= item . ", "
        }
        arrtxt .= "]"
        msgbox, % name . "`n" . arrtxt
    }

    checksublimeexists()
    {
        sublimeclassid := "ahk_class " . this.SUBLIMECLASS
        sublimehwnd := winexist(sublimeclassid)
        if sublimehwnd
        {
            wingettitle, sublimetitle, %sublimeclassid%
            ; exclude sublime settings window
            if not regexmatch(sublimetitle, this.EXCLUDE_SUBLIME_RE)
                return sublimehwnd
        }
        return false
    }

    ; getting deprecated
    checkfirefoxexists()
    {
        firefoxclass := "MozillaWindowClass"
        firefoxclassid := "ahk_class " . firefoxclass
        firefoxhwnd := winexist(firefoxclassid)
        return (firefoxhwnd ? firefoxhwnd : false)
    }

    ; debug function
    printmatrix(arr)
    {
        msgtext = Matrix printed:`n
        for each, row in arr
        {
            for each, col in row
            {
                wingettitle, printtitle, ahk_id %col%
                if printtitle
                    col := printtitle
                msgtext := msgtext . col . " -- "
            }
            msgtext := msgtext . "`n"
        }
        msgbox, % msgtext
    }

    getwindowmovepriority(hwnd)
    {
        wingetclass, classname, ahk_id %hwnd%
        wingettitle, thistitle, ahk_id %hwnd%
        for each, abortclass in this.ABORTCLASSES
        {
            if instr(classname, abortclass)
                return this.ABORTSTRING
        }
        if (classname = this.SUBLIMECLASS)
        {
            if not regexmatch(thistitle, this.EXCLUDE_SUBLIME_RE)
                return this.definepriority(hwnd)
            return false
        }
        else if (classname = this.STEAMCLASS)
        {
            this.r_movetogrid(2, hwnd)
            return false
        }
        else if (classname = this.CHROMECLASS)
        {
            if regexmatch(thistitle, ".*Discord")
                return this.CHATSTRING . "d"
            if thistitle = "Whatsapp"
                return this.CHATSTRING . "w"
            else
                return 2 ; TODO: return chrome priority level here, make dynamic
        }
        for k, v in this.CHATCLASSES
        {
            if instr(classname, k)
            {
                if v[2]
                {
                    if (thistitle = v[1])
                        return this.CHATSTRING . v[3]
                }
                else
                {
                    if instr(thistitle, v[1])
                        return this.CHATSTRING . v[3]
                }
            }
        }
        for k, v in this.SPECIALCLASSES
        {
            if instr(classname, k)
            {
                if v[2]
                {
                    if (thistitle = v[1])
                        return this.definepriority(hwnd)
                }
                else
                {
                    if instr(thistitle, v[1])
                        return this.definepriority(hwnd)
                }
                return false
            } 
        }
        for each, c in this.EXCLUDECLASSES
        {
            if instr(classname, c)
            {
                return false
            }
        }

        return this.definepriority(hwnd)
    }

    definepriority(hwnd)
    {
        wingetclass, classname, ahk_id %hwnd%
        for i, class_list in this.PRIORITIES
        {
            outerloopindex := a_index ; needed later to return the priority integer
            for i, priorityclass in class_list
            {
                if instr(classname, priorityclass)
                {
                    if outerloopindex in 1,2
                    {
                        return outerloopindex
                    }
                    return outerloopindex + 1
                }
            }
        }
        return 3 ; return normal if no special priority is found
    }
}
