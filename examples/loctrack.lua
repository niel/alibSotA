-- locTracker by Catweazle Waldschrath
-- depends on libsota.0.4.6


function ShroudOnStart()

-- apis are ready, time to compose our mod. (initialize)
als.ui.onInit(function()
	local styleStillness = { size=14, color="#c4a000", bold=true }
	local styleMoving = { size=14, color="yellow", bold=true }
	local styleStanding = { size=14, color="#edd400", bold=true }

	loctrack = {
		enabled = true,
		label = createLabelWithShadow(),
		timer = setInterval(0.25, function()
			local loc = als.player.location
			local caption = string.format("%s (x: %.2f, y: %.2f, z: %.2f)", loc.scene.name, loc.x, loc.y, loc.z)

			if als.player.isMoving then
				caption = caption:style(styleMoving)
			elseif als.player.isStill then
				caption = caption:style(styleStillness)
			else
				caption = caption:style(styleStanding)
			end

			local r = caption:rect():moveTo(nil, 90)
			setLabelRect(loctrack.label, r)
			setLabelCaption(loctrack.label, caption)
		end),
	}

	als.ui.command.add("loctrack", function()
		loctrack.enabled = not loctrack.enabled

		setTimerEnabled(loctrack.timer, loctrack.enabled)
		setLabelVisible(loctrack.label, loctrack.enabled)

		local msg = createLabel(nil, nil, 200, 120)
		if isTimerEnabled(loctrack.timer) then
			setLabelCaption(msg, "<size=18><color=white>locTracker activated</color></size>")
		else
			setLabelCaption(msg, "<size=18><color=white>locTracker deactivated</color></size>")
		end
		showLabel(msg)
		setTimeout(3, function() als.ui.label.remove(msg) end)
	end)
	als.ui.shortcut.add("pressed", "RightAlt", "L", "loctrack")


	-- all mods are initialized, time to start/run
	als.ui.onStart(function()
		showLabel(loctrack.label)
	end)

end)




end -- ShroudOnStart

-- implement other ShroudOn... to allow other scripts
function ShroudOnConsoleInput() end
function ShroudOnGUI() end
function ShroudOnUpdate() end

