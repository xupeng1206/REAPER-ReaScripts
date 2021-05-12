--[[ 
* ReaScript Name:Fix CSS Short Delay By Move. 
* Version: 2021/05/12 
* Author: xupeng 
* link: https://github.com/xupeng1206
--]] 

local r = reaper

function MoveNote()
    hwnd = r.MIDIEditor_GetActive()
    take = r.MIDIEditor_GetTake(hwnd)

    tick_1_14note = r.SNM_GetIntConfigVar("miditicksperbeat", -1)

    retval, notecnt, _, _ = r.MIDI_CountEvts(take)
    if notecnt == 0 then 
        r.MB('No notes in the MIDI item.','ERROR',0) 
        return
    end

    if notecnt > 0 then
        for i = 0, notecnt-1 do
            retval, sel, muted, startpos, endpos, chan, pitch, vel = r.MIDI_GetNote(take, i)
            if sel then
                -- set edit cursor at the start of the note
                r.SetEditCurPos(r.MIDI_GetProjTimeFromPPQPos(take, startpos), true, false)
                
                tempo = r.Master_GetTempo()
                ms_1_14note = 60 * 1000 / tempo
                
                tick1ms = tick_1_14note / ms_1_14note

                posDiff = -60 * tick1ms

                newStartPos = startpos + posDiff
                if newStartPos < 0 then
                    newStartPos = 0
                end

                newEndPos = endpos + posDiff
                if newEndPos < 0 then
                    newEndPos = 0
                end
                
                r.MIDI_SetNote(take, i, sel, muted, newStartPos, newEndPos, chan, pitch, vel) 
            end
        end
    end
end


function main()
    r.Undo_BeginBlock()
    MoveNote()
    r.Undo_EndBlock("Fix CSS Short Delay By Move", 0)
end

r.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

main()

r.TrackList_AdjustWindows(false)

r.UpdateArrange() -- Update the arrangement (often needed)

r.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.
