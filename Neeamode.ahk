class Neeamode
{
    neeamodeon()
    {
        hotkey, xbutton1, TakeNoActionLabel
        hotkey, xbutton2, TakeNoActionLabel
        run, taskkill /f /im StartKiller.exe
    }

    neeamodeoff()
    {
        hotkey, xbutton1, off
        hotkey, xbutton2, off
        run, "D:\Program Files\StartKiller\StartKiller.exe"
    }

    noaction()
    {
        return
    }
}

TakeNoActionLabel:
return