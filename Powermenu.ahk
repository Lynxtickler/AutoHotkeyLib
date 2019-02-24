;#warn
#include <Create_powericon_png>


class Powermenu
{
    static handle_retrieved_before := false
    static powerguiname := "Powergui"
    static iconsize := 50
    
    open()
    {
        ; static variables fetched into locals that can be used in commands
        pgname := this.powerguiname
        pgiconsize := this.iconsize
        pgheaderfontsize := floor(iconsize * 0.28)
        pgbuttonfontsize := floor(this.iconsize * 0.22)
        pgmarginsize := floor(this.iconsize / 3)
        pgpaddingsize := floor(this.iconsize / 6)
        powericon_handle := Create_powericon_png(this.handle_retrieved_before)
        this.handle_retrieved_before := true   
        
        gui, power:new, +alwaysontop -caption +theme, %pgname%
        gui, power:margin, % pgmargin, % pgmargin
        gui, power:add, picture, w%pgiconsize% h-1, hbitmap:%powericon_handle%
        gui, power:font, s%pgheaderfontsize%, Ubuntu
        gui, power:add, text, x+%pgpaddingsize%, Are you sure you want to shut`ndown your computer now?
        gui, power:font, s%pgbuttonfontsize%
        gui, power:add, button, x%pgmarginsize% gpowersleep, &Sleep
        gui, power:add, button, x+%pgpaddingsize% gpowershutdown, Sh&utdown
        gui, power:add, button, x+%pgpaddingsize% gpowerrestart, &Restart
        gui, power:add, button, x+%pgpaddingsize% gpowercancel, &Cancel
        
        gui, power:show, autosize
    }
    
    destroy()
    {
        gui, power:destroy
    }
}

powerguiescape:
Powermenu.destroy()
return

powersleep:
Powermenu.destroy()
DllCall("PowrProf\SetSuspendState", "int", 0, "int", 0, "int", 0)
return

powershutdown:
Powermenu.destroy()
shutdown, 1
return

powerrestart:
Powermenu.destroy()
shutdown, 2
return

powercancel:
Powermenu.destroy()
return
