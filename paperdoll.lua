-- paperdoll by Catweazle Waldschrath
-- depends on libsota.0.4.6


function ShroudOnStart()
	ui.onInit(function()
		
		paperdoll = {}
		function paperdoll.refresh()
			local c = string.style(player.stat(317).value, { color = "#ef2929"})
			local l = string.style(player.stat(318).value, { color = "#ad7fa8"})
			local t = string.style(player.stat(319).value, { color = "#729fcf"})
			local f = string.style("Courage: %s Love: %s Truth: %s", { size=14 })
			setLabelCaption(paperdoll.label, string.format(f, c, l, t))
		end
		paperdoll.label = createLabelWithShadow()
		paperdoll.timer = setInterval(10, paperdoll.refresh)
		paperdoll.refresh()		

	end)
	
	ui.onClientWindow(function(what, window)
		if what == "moved" then
			moveLabelTo(paperdoll.label, window.left+3, window.top + window.height)
		elseif window.open then
			moveLabelTo(paperdoll.label, window.left+3, window.top + window.height)
			showLabel(paperdoll.label)
			resumeTimer(paperdoll.timer)
		else
			hideLabel(paperdoll.label)
			pauseTimer(paperdoll.timer)
		end
	end)
end


-- not needed
function ShroudOnConsoleInput() end
function ShroudOnGUI() end
function ShroudOnUpdate() end
