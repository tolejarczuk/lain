--[[

     Licensed under GNU General Public License v2
      * (c) 2016, Luca CPZ

--]]

local helpers = require("lain.helpers")
local shell = require("awful.util").shell
local wibox = require("wibox")
local string = string
local type = type

-- PulseAudio volume
-- lain.widget.pulse

local function factory(args)
	args = args or {}

	local pulse = { widget = args.widget or wibox.widget.textbox(), device = "N/A" }
	local timeout = args.timeout or 5
	local settings = args.settings or function() end

	pulse.devicetype = args.devicetype or "sink"
	pulse.cmd = "wpctl get-volume @DEFAULT_AUDIO_SINK@ && wpctl inspect @DEFAULT_AUDIO_SINK@"

	function pulse.update()
		helpers.async({ shell, "-c", type(pulse.cmd) == "string" and pulse.cmd or pulse.cmd() }, function(s)
			volume_now = {
				volume = math.floor(tonumber(string.match(s, "Volume:%s+(%d*%.?%d+)")) * 100 + 0.5) or "N/A",
				muted = string.find(s, "%[MUTED%]") and "yes" or "no",
				device = string.match(s, 'media.name%s-=%s-"(.-)"') or "N/A",
				id = string.match(s, "id%s+(%d+)") or "N/A",
			}

			pulse.device = volume_now.device

			widget = pulse.widget
			settings()
		end)
	end

	helpers.newtimer("pulse", timeout, pulse.update)

	return pulse
end

return factory
