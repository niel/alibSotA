-- clock by Catweazle Waldschrath
-- depends on libsota.0.4.6 or higher

function durToString(dur)
	h = math.floor(dur / 3600)
	dur = dur - h * 3600
	m = math.floor(dur / 60)
	dur = dur - m * 60
	return string.format("%02d:%02d:%02d", h, m, math.floor(dur))
end

function getTimezone()
	local ts = os.time()
	local utcdate   = os.date("!*t", ts)
	local localdate = os.date("*t", ts)
	localdate.isdst = false
	return os.difftime(os.time(localdate), os.time(utcdate))
end

function timezoneToString(tz)
	local h, m = math.modf(tz / 3600)
	return string.format("%+.4d", 100 * h + 60 * m)
end


function ShroudOnStart()
	local clock = {}

	ui.onInit(function()
		clock.state = 1
		clock.tz = getTimezone()
		clock.timeInGame = false
		clock.timeInScene = false
		clock.label = createLabelWithShadow(5, 0)
		clock.timer = setInterval(1, function()
			local ts = os.time()
			if clock.state == 2 then ts = ts - clock.tz - 21600 end
			
			local caption = os.date("%c", ts)
			
			if clock.timeInGame then caption = caption.." | "..durToString(client.timeInGame) end
			if clock.timeInScene then caption = caption.." | "..durToString(scene.timeInScene) end			

			setLabelCaption(clock.label, caption:style{ size=20, color="#c4a000" })
		end)
		
		ui.command.add("clock", function(source, action)
			local msgText ={
				"Clock deactivated",
				"Clock shows local time",
				"Clock shows Novia time",
			}
		
			if not action then
				clock.state = clock.state + 1
				if clock.state > 2 then clock.state = 0 end
			elseif action == "tz" or action == "timezone" then
				ui.consoleLog("Your current timezone is: "..timezoneToString(clock.tz))
			elseif action == "off" or action == "false" then
				clock.state = 0
			elseif action == "nbb" or action:lower() == "novia" then
				clock.state = 2
			elseif action == "tig" or action:lower() == "timeingame" then
				clock.timeInGame = not clock.timeInGame
			elseif action == "tis" or action:lower() == "timeinscene" then
				clock.timeInScene = not clock.timeInScene
			else
				clock.state = 1
			end
			
			local enabled = clock.state > 0
			setTimerEnabled(clock.timer, enabled)
			setLabelVisible(clock.label, enabled)
			
			local msg = createLabel(nil, nil, 200, 120, msgText[clock.state+1]:style{ size = 18, color = "white" })
			showLabel(msg)
			setTimeout(3, function() removeLabel(msg) end)
		end)
		ui.shortcut.add("pressed", "RightAlt", "C", "clock")
		
		ui.onStart(function()
			showLabel(clock.label)
		end)
	end)

end -- ShroudOnStart

-- implement other ShroudOn... to allow other scripts
function ShroudOnConsoleInput() end
function ShroudOnGUI() end
function ShroudOnUpdate() end

