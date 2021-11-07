-- libsota.util by Catweazle Waldschrath
-- helper functions for global namespace to work with the ui.objects
-- depends on libsota.0.5.x


--[[
 * libsota.util.lua
 * Copyright (C) 2019 Michael Fritscher <catweazle@tunipages.de>

 This file is part of libsota.

   libsota is free software: you can redistribute it and/or modify it
   under the terms of the GNU Lesser General Public License as published
   by the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   libsota is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
   See the GNU Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.";
]]



--- credits
-- that_shawn_guy - string.rect (from his offsetCenter)
-- Toular - for helping me to find a font size multiplier that helps with fontsize at different resolutions.



-- timer utility functions

function setTimeout(timeout, callback)
	return ui.timer.add(timeout, true, callback)
end

function setInterval(interval, callback)
	return ui.timer.add(interval, false, callback)
end

function getTimer(index)
	return ui.timer.list[index]
end

function cancelTimer(index)
	ui.timer.list[index] = nil;
end

function pauseTimer(index)
	ui.timer.list[index].enabled = false
end

function resumeTimer(index)
	ui.timer.list[index].enabled = true
end

function isTimerEnabled(index)
	return ui.timer.list[index].enabled
end

function toggleTimer(index)
	ui.timer.list[index].enabled = not ui.timer.list[index].enabled
	return ui.timer.list[index].enabled
end

function setTimerEnabled(index, enabled)
	ui.timer.list[index].enabled = enabled
end


-- label utility functions

function createLabel(left, top, width, height, caption)
	local r = rect(left, top, width, height)
	return ui.label.add(r.left, r.top, r.width, r.height, caption)
end

function createLabelWithShadow(left, top, width, height, caption)
	local r = rect(left, top, width, height)
	local s = ui.label.add(r.left+1, r.top+1, r.width, r.height, caption)
	local l = ui.label.add(r.left, r.top, r.width, r.height, caption)
	l.shadow = s
	return l
end

function getLabel(label)
	return label
end

function getLabelCaption(label)
	return label.caption
end

function setLabelCaption(label, caption)
	if label.shadow then
		local c = caption:gsub("<color=.->", "<color=black>")
		label.shadow.caption = "<color=black>"..c.."</color>"
	end
	label.caption = caption
end

function removeLabel(label)
	if label.shadow then
		label.shadow:remove()
	end
	label:remove()
end

function showLabel(label)
	setLabelVisible(label, true)
end

function hideLabel(label)
	setLabelVisible(label, false)
end

function toggleLabel(label)
	setLabelVisible(label, not isLabelVisible(label))
end

function isLabelVisible(label)
	return label:visible()
end

function setLabelVisible(label, visible)
	if label.shadow then
		label.shadow:visible(visible)
	end
	label:visible(visible)
end

function moveLabelBy(label, x, y)
	moveLabelTo(label, label.rect.left + x, label.rect.top + y)
end

function moveLabelTo(label, x, y)
	if label.shadow then
		label.shadow.rect.left = x + 1
		label.shadow.rect.top = y + 1
	end
	label.rect.left = x
	label.rect.top = y
end

function resizeLabelBy(label, w, h)
	resizeLabelTo(label, label.rect.width + w, label.rect.height + h)
end

function resizeLabelTo(label, w, h)
	if label.shadow then
		label.shadow.rect.width = width
		label.shadow.rect.height = height
	end
	label.rect.width = w
	label.rect.height = h
end

function setLabelRect(label, rect)
	ui.guiObject.rect(label, rect)
	if label.shadow then
		ui.guiObject.rect(label.shadow, rect:moveBy(1, 1))
	end
end

-- requested by that_shawn_guy
function moveLabelOffsetCenter(label, x, y)
	local r = label.caption:rect()
	r.moveTo(nil, nil):moveBy(x, y)
	ui.guiObject.rect(label, r)
end


-- texture utility functions

function createTexture(left, top, width, height, filename)
	local r = rect(left, top, width, height)
	return ui.texture.add(r.left, r.top, filename, true, nil, r.width, r.height)
end

function getTexture(texture)
	return texture
end

function cloneTexture(texture)
	return texture:clone()
end

function removeTexture(texture)
	texture:remove()
end

function showTexture(texture)
	setTextureVisible(texture, true)
end

function hideTexture(texture)
	setTextureVisible(texture, false)
end

function toggleTexture(texture)
	texture:toggle()
end

function isTextureVisible(texture)
	return texture:visible()
end

function setTextureVisible(texture, visible)
	texture:visible(visible)
end

function setTextureScaleMode(texture, scaleMode)
	texture.scaleMode = scaleMode
end

function getTextureScaleMode(texture)
	return texture.scaleMode
end

function setTextureClamped(texture, clamped)
	texture:clamp(clamped)
end

function getTextureClamped(texture)
	return texture:clamp()
end

function setTextureRect(texture, rect)
	ui.guiObject.rect(texture, rect)
end

function moveTextureTo(texture, x, y)
	texture:moveTo(x, y)
end

function moveTextureBy(texture, x, y)
	texture:moveBy(x, y)
end

function resizeTextureTo(texture, w, h)
	texture:resizeTo(w, h)
end

function resizeTextureBy(texture, w, h)
	texture:resizeBy(w, h)
end

function moveTextureOffsetCenter(texture, x, y)
	local r = texture.rect
	r.moveTo(nil, nil):moveBy(x, y)
	ui.guiObject.rect(texture, r)
end


--- all functions and objects below this line may subject to be changed and/or removed

function ui.onShortcutPressed(...)
	return ui.shortcut.add("pressed", ...)
end
function ui.onShortcut(...)
	return ui.shortcut.add("watch", ...)
end
ui.registerKey = ui.onShortcutPress -- depricated: ui.registerKey is about to be removed]]

ui.onCommand = ui.command.add


-- compat functions libsota.0.4.x
-- moves to libsota.ui
string.style = function(string, style)
	if style.bold then string = "<b>"..string.."</b>" end
	if style.italic then string = "<i>"..string.."</i>" end
	if style.color and #style.color > 3 then string = "<color="..style.color..">"..string.."</color>" end
	if style.size then string = "<size="..math.floor(style.size * client.screen.pxptRatio + 0.5)..">"..string.."</size>" end
	return string
end
string.rect = function(string)
	local str = string:gsub("<[^>]*>", "")
	local s = tonumber(string:match("<size=(%d-)>"))
	if not s then s = math.floor(12 * client.screen.pxptRatio + 0.5) end
	local mul = 0.9
	if string:contains("<b>") or string:contains("<i>") then mul = 1 end
	return rect.new(0, 0, str:len() * (s/client.screen.aspectRatio) * mul, s*client.screen.aspectRatio) -- size of letter X, 0.9 because of proptional letters
end

table.maxn = function(self)
	local n = 0
	for _ in next, self do
		n = n + 1
	end
	return n
end

-- removed with libsota.ui and replaced with a slighty different ui.rect object
rect = {
	_new = function(self, left, top, width, height)
		return self.new(left, top, width, height)
	end,
	new = function(left, top, width, height)
		local r = {
			left = left,
			top = top,
			width = width,
			height = height,
		}

		if not width then
			r.width = client.screen.width / 3.3
		elseif tonumber(width) == nil then
			width = tonumber(string.match(width, "^%d+"))
			r.width = client.screen.width / 100 * math.abs(width)
		end
		if not height then
			r.height = client.screen.height / 3.6
		elseif tonumber(height) == nil then
			height = tonumber(string.match(height, "^%d+"))
			r.height = client.screen.height / 100 * math.abs(height)
		end
		if not left then
			r.left = (client.screen.width - r.width) / 2
		elseif tonumber(left) == nil then
			left = tonumber(string.match(left, "^%d+"))
			if left < 0 then
				r.left = client.screen.width - (client.screen.width / 100 * -left) - r.width
			else
				r.left = client.screen.width / 100 * left
			end
		end
		if not top then
			r.top = (client.screen.height - r.height) / 2
		elseif tonumber(top) == nil then
			top = tonumber(string.match(top, "^%d+"))
			if top < 0 then
				r.top = client.screen.height - (client.screen.height / 100 * -top) - r.height
			else
				r.top = client.screen.height / 100 * top
			end
		end

		setmetatable(r, {__index = rect})
		return r
	end,

	fromString = string.style,

	moveTo = function(rect, x, y)
		if not x then x = (client.screen.width - rect.width) / 2 end
		if not y then y = (client.screen.height - rect.height) / 2 end
		rect.left = x
		rect.top = y
		return rect
	end,

	moveBy = function(rect, x, y)
		rect.left = rect.left + x
		rect.top = rect.top + y
		return rect
	end,

	resizeTo = function(rect, w, h)
		rect.width = w
		rect.height = h
		return rect
	end,

	resizeBy = function(rect, w, h)
		rect.width = rect.width + w
		rect.height = rect.height + h
		return rect
	end,
}
setmetatable(rect, {__call = rect._new})




-- implement Shroud calls
function ShroudOnConsoleInput() end
function ShroudOnGUI() end
function ShroudOnUpdate() end
function ShroudOnStart()
	ui.onInit(function()
		ui.command.add("lua", function(source, action)
			if action == "api" then
				for f,t in next, client.api.list do
					ui.consoleLog(t..": "..f)
				end
			elseif action == "lua" or action == "path" or action == "version" then
				ui.consoleLog("LUA Version: "..client.api.luaVersion)
				ui.consoleLog("LUA Path: "..client.api.luaPath)
			elseif action == "reload" or action == "unload" then
				ui.consoleLog("type: /lua "..action.." in the chat window instead")
			end
		end)
		ui.command.add("info", function(source, action, param)
			if action == "xp" then
				ui.consoleLog("Adventurer pooled XP: "..player.xp.adventurer.."\nProducer pooled XP: "..player.xp.producer)
			elseif action == "stat" and param then
				local stat = player.stat(param)
				if stat.value ~= -999 then
					ui.consoleLog(string.format("Stat %d: %s = %s (%s)", stat.number, stat.name, stat.value, stat.description))
				elseif tonumber(param) == nil then
					for i=0,#client._statEnum do
						stat = player.stat(i)
						if string.find(stat.name:lower()..stat.description:lower(), param:lower()) then
							ui.consoleLog(string.format("Stat %d: %s = %s (%s)", stat.number, stat.name, stat.value, stat.description))
						end
					end
				end
			elseif action == "inventory" then
				for _,i in next, player.inventory do
					if not param or i.name:lower():find(param:lower()) then
					if i.quantity > 1 then
						-- stack value / quantity
						ui.consoleLog(string.format("%s [e9b96e](%d)   w:%0.1f   v:%d[-]", i.name, i.quantity, i.weight, i.value))
					elseif i.maxDurability > 0 then
						local c = "73d216"
						if i.durability < 1 then
							c = "cc0000"
						elseif i.durability / i.maxDurability < 0.25 then
							c = "edd400"
						end
						ui.consoleLog(string.format("%s   [%s]%d/%d[-] (max %d)   w:%0.1f   v:%d", i.name, c, i.durability, i.primaryDurability, i.maxDurability, i.weight, i.value))
					else
						ui.consoleLog(string.format("%s   w:%0.1f   v:%d", i.name, i.weight, i.value))
					end
					end
				end
			elseif action == "client" or action == "player" or action == "scene" or action == "ui" then
				for n,v in next, _G[action] do
					if n:byte() ~= 95 then
						if type(v) == "table" then
							for n1,v1 in next, v do
								if action ~= "player" and n ~= "inventory" then
									ui.consoleLog(action.."."..n.."."..n1.." = "..tostring(v1))
								end
							end
						else
							ui.consoleLog(action.."."..n.." = "..tostring(v))
						end
					end
				end
			elseif action == "lib" then
				ui.consoleLog(string.format("timer: %d\nhandler: %d\ngui objects: %d", #ui.timer.list, #ui.handler.list, #ui_guiObjectList))
				for _,t in next, ui.texture._loaded do
					ui.consoleLog(string.format("texture %d: %s (%d x %d)", t.id, t.filename, t.width, t.height))
				end
				for n in next, ui.command.list do
					ui.consoleLog("command: "..n)
				end
				for k,r in next, ui.shortcut.list.pressed do
					for _,t in next, r do
						local s = k
						for _,p in next, t.keysHeld do
							s = p.." + "..s
						end
						ui.consoleLog("shortcut pressed: "..s)
					end
				end
				for k,r in next, ui.shortcut.list.watch do
					for _,t in next, r do
						local s = k
						for _,p in next, t.keysHeld do
							s = p.." + "..s
						end
						ui.consoleLog("shortcut watched: "..s)
					end
				end
			end
		end)
	end)
end
