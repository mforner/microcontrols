--[[ "MicroControls.lua"
    Extension Information:
        Name: Micro Controls
        Version: 1.0
        Author: Marcel Hinsch
        Website: http://addons.videolan.org/content/show.php?content=160547
        Description: A small Controll Window to Control your VLC Player. More Features to come.
]]--

--[[
    INSTALLATION:
    Put the file in the VLC subdir /lua/extensions, by default:
    * Windows (all users): %ProgramFiles%\VideoLAN\VLC\lua\extensions\
    * Windows (current user): %APPDATA%\VLC\lua\extensions\
    * Linux (all users): /usr/share/vlc/lua/extensions/
    * Linux (current user): ~/.local/share/vlc/lua/extensions/
    * Mac OS X (all users): /Applications/VLC.app/Contents/MacOS/share/lua/extensions/
    (create directories if they don't exist)
    Restart the VLC.
    USAGE:
    Load some Songs in your Playlist and start a song.
    Then you simply use the extension by going to the "View" menu and selecting it there.
    You can then hide VLC in your taskbar by clicking the little Pylon Symbol in your tray once.
--]]

--[[
    
    Copyright © 2013 Marcel Hinsch (Wolvan)
     
     Authors:  Marcel Hinsch (Wolvan)
     Contact: http://addons.videolan.org/messages/?action=newmessage&username=Wolvan
     
     This program is free software; you can redistribute it and/or modify
     it under the terms of the GNU General Public License as published by
     the Free Software Foundation; either version 2 of the License, or
     (at your option) any later version.
     
     This program is distributed in the hope that it will be useful,
     but WITHOUT ANY WARRANTY; without even the implied warranty of
     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
     GNU General Public License for more details.
     
     You should have received a copy of the GNU General Public License
     along with this program; if not, write to the Free Software
     Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
]]--

--[[
--  Basic structure template
--  https://forum.videolan.org/viewtopic.php?t=98644
]]--


--[[
--    Array that safes all dialog objects for use in the script
]]--
d = {}

MSG_INFO = 0
MSG_ERR = 1
MSG_WARN = 2
MSG_DEBUG = 3
VERSION="1.06"
MICROCONTROLS="Micro Controls" .. " " .. "v" .. VERSION

--[[
    VLC-Event Functions
]]--
function descriptor()
	return {
        title = "Micro Controls";
        version = "";
        author = "";
        url = "https://";
        -- version = "1.0";
        -- author = "Wolvan";
        --url = 'http://addons.videolan.org/content/show.php?content=160547';
        shortdesc = "Small Controls for VLC.";
        description = "<div style=\"background-color:lightgreen;\"><b>Micro Controls</b> is VLC extension that allows you to control VLC using a compact GUI.</div><br><br><b>Usage</b><br>Load some Songs in your Playlist and start a song.<br>Then you simply use the extension by going to the 'View' menu and selecting it there.<br>You can then hide VLC in your taskbar by clicking the little Pylon Symbol in your tray once.";
        capabilities = {
            "input-listener", "playing-listener", "input-listener"
        }
    }
end

function activate()
   -- this is where extension starts
   -- for example activation of extension opens custom dialog box:
   lg("Starting " .. MICROCONTROLS)
   create_dialog()
   update_volume_label()
end

function deactivate()
   -- what should be done on deactivation of extension
   close_mc()
end

function close()
   -- function triggered on dialog box close event
   -- for example to deactivate extension on dialog box close:
   close_mc()
end

function meta_changed()
   -- related to capabilities={"meta-listener"} in descriptor()
   -- triggered by available media input meta data?
end

function playing_changed()
   -- related to capabilities={"playing-listener"} in descriptor()
   -- triggered by Pause/Play madia input event
   lg("Playing changed")
   if "playing" == vlc.playlist:status() then
      add_pause_button()
   else
      add_play_button()
   end
   update_volume_label()
end

function input_changed()
   -- related to capabilities={"input-listener"} in descriptor()
   -- triggered by Start/Stop media input event
   lg("Input changed")
   update_now_playing()
   if vlc.input and vlc.input.is_playing()  then
      local secs = vlc.input.item():duration()
      d.label_duration:set_text(timestamp(secs))
   end
end

--[[
    Custom Functions
]]--

function lg(s, t)
   -- logging function
   text = "[" .. MICROCONTROLS .. "][" .. os.date("%c") .. "]" .. s
   if t == MSG_INFO or t == nil then
      vlc.msg.info(text)
   elseif t == MSG_ERR then
      vlc.msg.err(text)
   elseif t == MSG_WARN then
      vlc.msg.warn(text)
   elseif t == MSG_DEBUG then
      vlc.msg.dbg(text)
   end
end

function round(x)
    return math.floor(x + 0.5)
end

function close_mc()
   lg("Stopping " .. MICROCONTROLS)
   -- d.dialog:delete()
   vlc.deactivate()
end

function click_play()
   vlc.playlist.play()
end

function click_pause()
   vlc.playlist.pause()
end

function click_stop()
   vlc.playlist.stop()
end

function add_play_button(col, row)
   if not col then col = 1 end
   if not row then row = 3 end
   local b = d.button_play_pause
   if b then d.dialog:del_widget(b) end
   b = d.dialog:add_button("Play", click_play, col, row)
end

function add_pause_button(col, row)
   if not col then col = 1 end
   if not row then row = 3 end
   local b = d.button_play_pause
   if b then d.dialog:del_widget(b) end
   b = d.dialog:add_button("Pause", click_pause, col, row)
end

function click_next_item()
   vlc.playlist.next()
end

function click_previous_item()
   vlc.playlist.prev()
end

function click_exit()
   close_mc()
end

function update_now_playing()
   if vlc.input then
      local name = vlc.input.item():name()
      if string.len(name) > 20 then
	 name = string.sub(name,1,20) .. "..."
      end
      d.label_now_playing:set_text(name)
      d.dialog:set_title(MICROCONTROLS .. vlc.input.item():name())
   else
      d.label_now_playing:set_text("--" )
      d.dialog:set_title(MICROCONTROLS .. " " .. _VERSION)
   end
end

function update_volume_label(x)
   if x == nil then x = vlc.volume.get() end
   d.label_volume:set_text(
      "Volume: " .. round(100 * x / 256) .. " %")
end

function clear_dropdown_playlist()
   d.dropdown_playlist:clear()
end

function click_toggle_mute()
   lg("click_toggle_mute not implemented", MSG_WARN)
end

function click_volume_reset()
   -- https://forum.videolan.org/viewtopic.php?t=101117
   vlc.volume.set(256)  -- 256 should correspond to 100% of volume
   update_volume_label(256)
end

function click_volume_down()
   vlc.volume.down()
   update_volume_label()
end

function click_volume_up()
   if vlc.volume.get() < 320 then
      vlc.volume.up()
      update_volume_label()
   end
end

function timestamp(secs)
   return string.format("%.2d:%.2d:%.2d",
			secs/(60*60), secs/60%60, secs%60)
end

function click_get_position()
   local input = vlc.object.input()
   if input then
      local secs = vlc.var.get(input, "time")
      d.label_position:set_text(timestamp(secs));
	   if vlc.input.is_playing()  then
		  local secstotal = vlc.input.item():duration()
		  d.label_remain:set_text("Remain: -" .. timestamp(secstotal-secs))
	   end
   else
      lg("no input", MSG_WARN)
   end
end

function click_get_duration()
   if vlc.input.is_playing()  then
      local secs = vlc.input.item():duration()
      d.label_duration:set_text(timestamp(secs))
   end
end

function click_toggle_fullscreen()
   vlc.video.fullscreen()
end

function click_fetch_playlist()
   for _,v in pairs(vlc.playlist.get("playlist",false).children) do
      d.dropdown_playlist:add_value(v.name, v.id)
   end
end

function click_clear_playlist()
   d.dropdown_playlist:clear()
end

function click_goto_track()
   vlc.playlist['goto'](d.dropdown_playlist:get_value())
end

function click_button_goto_position()
   local input = vlc.object.input()
   if input then
      local seconds = d.dropdown_hour:get_value() * 3600 +
	 d.dropdown_minute:get_value()*60 + d.dropdown_second:get_value()

      vlc.var.set(input, "time", seconds)
      d.label_position:set_text(timestamp(seconds))
   end
end

function create_dialog()
   d.dialog = vlc.dialog(MICROCONTROLS .. " " .. _VERSION)

   local dialog = d.dialog

   d.blabel_now_playing_001 = dialog:add_label(
      "Now Playing:", 1, 1, 1, 1)
   d.label_now_playing = dialog:add_label(
      "--", 2,1,3,1)

   d.label_controls = dialog:add_label(
      "Player Controls", 1, 2, 2, 1)

   if vlc.playlist.status() == "stopped"
   or vlc.playlist.status() == "paused" then
      add_play_button(1,3)
   else
      add_play_button(1,3)
   end
   d.button_stop = dialog:add_button(
      "Stop", click_stop, 2, 3)
   d.button_previous = dialog:add_button(
      "<<", click_previous_item, 3, 3)
   d.button_next = dialog:add_button(
      ">>", click_next_item, 4, 3)
   d.button_fetch_playlist = dialog:add_button(
      "Fetch", click_fetch_playlist,1,4)
   d.button_clear_playlist = dialog:add_button(
      "Clear", click_clear_playlist,2,4)

   d.dropdown_playlist = dialog:add_dropdown(
      1,5,2,1)
   d.button_goto_track = dialog:add_button(
      "Goto", click_goto_track,3,5,2,1)

   d.button_volume_reset = dialog:add_button(
      "Reset Volume", click_volume_reset, 1,7,1,1)
   d.button_volume_reset = dialog:add_button(
      "Volume -", click_volume_down, 2,7,1,1)
   d.button_volume_reset = dialog:add_button(
      "Volume +", click_volume_up, 3,7,1,1)
   d.button_mute = dialog:add_button(
      "Mute", click_toggle_mute, 4,7,1,1)

   d.label_volume = dialog:add_label(
      "Volume: ", 1, 8, 2, 1)
   d.button_fullscreen = dialog:add_button(
      "Fullscreen", click_toggle_fullscreen, 2,8,2,1)

   d.label_position = dialog:add_label(
      "--", 1,9)
   d.button_get_position = dialog:add_button(
      "Get Pos", click_get_position, 2,9)
   d.label_remain = dialog:add_label(
      "Remain: --", 3,9)

   d.label_duration = dialog:add_label(
      "--",1,10)
   d.button_get_duration = dialog:add_button(
      "Get Dur" , click_get_duration,2,10)

   d.dropdown_hour = dialog:add_dropdown(1,11,1,1)
   d.dropdown_minute = dialog:add_dropdown(2,11,1,1)
   d.dropdown_second = dialog:add_dropdown(3,11,1,1)
   for i = 0,59 do
       d.dropdown_second:add_value(i, i)
       d.dropdown_minute:add_value(i, i)
   end
   for i = 0,9 do
      d.dropdown_hour:add_value(i, i)
   end
   d.button_goto_posistion = dialog:add_button(
      "Goto", click_button_goto_position, 4,11,1,1)

   d.divider_002 = dialog:add_label("", 1, 12, 2, 1)
   d.button_exit = dialog:add_button(
      "Exit", click_exit, 1, 13, 4, 1)

   dialog:update()
   dialog:show()
   -- update_now_playing()
end
