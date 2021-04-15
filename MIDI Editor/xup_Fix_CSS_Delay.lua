--[[ 
* ReaScript Name:Fix CSS Delay. 
* Version: 2021/04/15 
* Author: xupeng 
* link: https://github.com/xupeng1206
--]] 

local r = reaper

function MoveNote()
    hwnd = r.MIDIEditor_GetActive()
    take = r.MIDIEditor_GetTake(hwnd)

    retval, notecnt, _, _ = r.MIDI_CountEvts(take)
    if notecnt == 0 then 
        r.MB('No notes in the MIDI item.','ERROR',0) 
        return
    end

    if notecnt > 0 then
        for i = 0, notecnt-1 do
            retval, sel, muted, startpos, endpos, chan, pitch, vel = r.MIDI_GetNote(take, i)
            if sel then
                r.SetEditCurPos(r.MIDI_GetProjTimeFromPPQPos(take, startpos), true, false)
                tempo = r.Master_GetTempo()
                tick_1_14note = r.SNM_GetIntConfigVar("miditicksperbeat", -1)
                ms_1_14note = 60 * 1000 / tempo
                tick1ms = tick_1_14note / ms_1_14note
                posDiff = 0
                if vel >= 0 and vel <= 64 then
                    posDiff = -333 * tick1ms
                elseif vel >= 65 and vel <= 100 then
                    posDiff = -250 * tick1ms
                elseif vel >=101 and vel <=127 then
                    posDiff = -100 * tick1ms
                else
                    posDiff = 0
                end
                newStartPos = startpos + posDiff
                if newStartPos < 0 then
                    newStartPos = 0
                end
                r.MIDI_SetNote(take, i, sel, muted, newStartPos, endpos, chan, pitch, vel) 
            end
        end
    end
end


function main() -- local (i, j, item, take, track)
    r.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
    MoveNote()
    r.Undo_EndBlock("Fix CSS Delay", 0) -- End of the undo block. Leave it at the bottom of your main function.
end -- end main()

r.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

main() -- Execute your main function

r.TrackList_AdjustWindows(false)

r.UpdateArrange() -- Update the arrangement (often needed)

r.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.