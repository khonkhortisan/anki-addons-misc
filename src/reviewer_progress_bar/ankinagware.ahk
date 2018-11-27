;This piggybacks on a modification to an anki plugin in order to extract data.
;In Progress Bar https://ankiweb.net/shared/info/2091361802 in the file reviewer_progress_bar.py at the end of the function _updatePB add this code so ahk knows how many cards you have left without having to ask you
;        with open(os.getenv('APPDATA')+'/Anki2/addons21/AnkiNagwareNumReviews.txt', 'w') as f:
;            f.write(str(barSize-curr))


;number of reviews to do between now and midnight
global reviews:=0
global start:=A_Now
global cardwait:=24*60
global behindcount:=0

global controlmediaplayer:=true
;+Volume_Down::Send {Media_Prev}
;+Volume_Up::Send {Media_Next}
;+Volume_Mute::Send {Media_Play_Pause}
;+Volume_Mute::Send {Media_Stop}


Loop
{
    ;InputBox, reviews
    oldreviews := reviews
    ;Fileread, reviews, C:/Users/Khonkhortisan/AppData/Roaming/Anki2/addons21/AnkiNagwareNumReviews.txt
	 Fileread, reviews, %A_appdata%/Anki2/addons21/AnkiNagwareNumReviews.txt
	;Fileread, reviews, C:/Program Files (x86)/Anki/ankidata/addons21/AnkiNagwareNumReviews.txt
    if (reviews > oldreviews)
    {
        behindcount:=0
    } else {
        behindcount-=oldreviews-reviews
        if behindcount < 0
            behindcount:=0
    }
    
    ;time until midnight or spread out over 24 hours?
    ;time to wait before activating anki for another card
    ;Because I don't know when people work (500 cards 5 minutes before midnight doesn't let you do anything else), I'll just use 24 hours, and let it average out.
    ;at least nag once a day to catch new reviews after having done them all
    
    start:=A_Now
    cardwait:=24*60/(reviews+1)
    
    ;16 means don't beep
    roundedcardwait := Round(cardwait)
    TrayTip, %roundedcardwait% minutes until next card, %reviews% cards at %roundedcardwait% minute intervals,,16
    

    ;wait for anki window
    Loop
    {
        WinGet, Active_ID, ID, A
        WinGet, Active_Process, ProcessName, ahk_id %Active_ID%
        if ( Active_Process ="anki.exe" )
        {
            Tooltip,
            ;stay on top
            ;Winset, Alwaysontop, On , A
            ;disable minimize
            ;WinSet,Style,-0x20000,A 
            break
        }
        
        
        
        timespent:=A_Now
        EnvSub, timespent, start, Minutes
		
        if (timespent > cardwait)
        {
            ;TrayTip, Time to study,%reviews% cards,,16
            ;TrayTip, Time to study,%reviews% cards at %cardwait% minute intervals
            
            ;don't get stuck in this loop
            start:=A_Now
            
            ;generally be more annoying when not behaving
            ;behindcount := Round(timespent / cardwait)
            behindcount++
            ;Tooltip, %behindcount%
            ;Tooltip, Anki
            
            ;raise the window
            ;usinganki:=true
            ;WinActivate, Anki
            ;WinWaitActive, Anki
            
            ;start a card
            ;Send, s
            ;Sleep, 1000
            ;Send, {enter}
            
            ;start a card in the background instead
            ;ControlSend,, s, Anki
            ;Sleep, 1000
            ;ControlSend,, {enter}, Anki
            
            ;making the user fight the nagware is a bad thing.
            ;I should have to cooperate with it.
        }
        ;timeleft:=cardwait-timespent
        ;Tooltip, %timespent% %cardwait% %reviews% %start% %timeleft%
        
        if (behindcount > 0)
        {
            Tooltip, %behindcount%
            ;get slower and more annoying
            tooltipdelay:=(behindcount - 0) * 10
            Sleep, %tooltipdelay%
        }
    }
    
    
    roundedcardwait := Round(cardwait)
    TrayTip, Studying %reviews% cards,%reviews% cards at %roundedcardwait% minute intervals,,16
    
    ;hopefully this acts as Media_Play
    if controlmediaplayer {
        Send {Media_Play_Pause}
        ;ControlSend,, {Media_Play_Pause}, Spotify
    }
    
    
    
    
    
    
    ;wait for not anki window
    Loop
    {
        WinGet, Active_ID, ID, A
        WinGet, Active_Process, ProcessName, ahk_id %Active_ID%
        if ( Active_Process !="anki.exe" )
        {
            ;wait until done with alt-tab, so you can actually use that menu
            if not GetKeyState("LAlt")
            {
                break
            }
        }
    }

    ;hopefully this acts as Media_Pause
    if controlmediaplayer {
        Send {Media_Play_Pause}
        ;ControlSend,, {Media_Play_Pause}, Spotify
    }

    
}
