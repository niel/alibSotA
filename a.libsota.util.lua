-- libsota.util
-- helper functions for global namespace to work with the als.ui.objects
-- depends on libsota.0.4.8


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
-- devilcult - for his dorequire. That made als.ui.module, and the utility functions therefore possible


-- timer utility functions

function setTimeout(timeout, callback)
	return als.ui.timer.add(timeout, true, callback)
end

function setInterval(interval, callback)
	return als.ui.timer.add(interval, false, callback)
end

function getTimer(index)
	return als.ui.timer.list[index]
end

function cancelTimer(index)
	als.ui.timer.list[index] = nil;
end

function pauseTimer(index)
	als.ui.timer.list[index].enabled = false
end

function resumeTimer(index)
	als.ui.timer.list[index].enabled = true
end

function isTimerEnabled(index)
	return als.ui.timer.list[index].enabled
end

function toggleTimer(index)
	als.ui.timer.list[index].enabled = not als.ui.timer.list[index].enabled

	return als.ui.timer.list[index].enabled
end

function setTimerEnabled(index, enabled)
	als.ui.timer.list[index].enabled = enabled
end


-- label utility functions

function createLabel(left, top, width, height, caption)
	local r = rect(left, top, width, height)

	return als.ui.label.add(r.left, r.top, r.width, r.height, caption)
end

function createLabelWithShadow(left, top, width, height, caption)
	local r = rect(left, top, width, height)
	local s = als.ui.label.add(r.left+1, r.top+1, r.width, r.height, caption)
	local l = als.ui.label.add(r.left, r.top, r.width, r.height, caption)
	l.shadow = s

	return l
end

function getLabel(label)
	return label
end

function getLabelCaption(label)
	return label.caption
end
getLabelText = getLabelCaption -- depricated

function setLabelCaption(label, caption)
	if label.shadow then
		local c = caption:gsub("<color=.->", "<color=black>")
		label.shadow.caption = "<color=black>"..c.."</color>"
	end

	label.caption = caption
end
setLabelText = setLabelCaption -- depricated

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
	als.ui.guiObject.rect(label, rect)
	if label.shadow then
		als.ui.guiObject.rect(label.shadow, rect:moveBy(1, 1))
	end
end

-- requested by that_shawn_guy
function moveLabelOffsetCenter(label, x, y)
	local r = label.caption:rect()
	r.moveTo(nil, nil):moveBy(x, y)
	als.ui.guiObject.rect(label, r)
end


-- texture utility functions

function createTexture(left, top, width, height, filename)
	local r = rect(left, top, width, height)

	return als.ui.texture.add(r.left, r.top, filename, true, nil, r.width, r.height)
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
	als.ui.guiObject.rect(texture, rect)
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
	als.ui.guiObject.rect(texture, r)
end


-- other utility functions
--load = loadsafe
--loadfile = als.ui.module.add
--dofile = function(modulename)
--	local f = als.ui.module.add(modulename)
--	if f then
--		return f()
--	end
--end

require = function(modulename, ignoreError)
	local f = als.ui.module.get(modulename)
	if f then
		return
	end

	f = als.ui.module.add(modulename)
	if not f then
		if not ignoreError then
			error("required '"..tostring(modulename).."' cannot be loaded", 2)
		end
	else
		local status, err = pcall(f)
		if not status and not ignoreError then
			error(err, 2)
		end
	end
end

include = function(modulename)
	require(modulename, true)
end

module = function(modulename)
	als.ui.module.add(modulename, true)
end


--- all functions and objects below this line may subject to be changed and/or removed

--function als.ui.onShortcutPressed(...)
--	return als.ui.shortcut.add("pressed", ...)
--end

--function als.ui.onShortcut(...)
--	return als.ui.shortcut.add("watch", ...)
--end

--als.ui.registerKey = als.ui.onShortcutPress -- depricated: als.ui.registerKey is about to be removed]]

--als.ui.onCommand = als.ui.command.add


-- compat functions libsota.0.4.x
-- moves to libsota.ui
string.style = function(string, style)
	if style.bold then
		string = "<b>"..string.."</b>"
	end

	if style.italic then
		string = "<i>"..string.."</i>"
	end

	if style.color and #style.color > 3 then
		string = "<color="..style.color..">"..string.."</color>"
	end

	if style.size then
		string = "<size="..math.floor(style.size * als.client.screen._fsmul + 0.5)..">"..string.."</size>"
	end

	return string
end

string.rect = function(string)
	local str = string:gsub("<[^>]*>", "")
	local s = tonumber(string:match("<size=(%d-)>"))
	if not s then
		s = math.floor(12 * als.client.screen._fsmul + 0.5)
	end

	return rect.new(0, 0, str:len() * (s/als.client.screen.aspectRatio) *0.9, s*als.client.screen.aspectRatio) -- size of letter X, 0.9 because of proptional letters
end

-- removed with libsota.ui and replaced with a slightly different ui.rect object
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
			r.width = als.client.screen.width / 3.3
		elseif tonumber(width) == nil then
			width = tonumber(string.match(width, "^%d+"))
			r.width = als.client.screen.width / 100 * math.abs(width)
		end

		if not height then
			r.height = als.client.screen.height / 3.6
		elseif tonumber(height) == nil then
			height = tonumber(string.match(height, "^%d+"))
			r.height = als.client.screen.height / 100 * math.abs(height)
		end

		if not left then
			r.left = (als.client.screen.width - r.width) / 2
		elseif tonumber(left) == nil then
			left = tonumber(string.match(left, "^%d+"))
			if left < 0 then
				r.left = als.client.screen.width - (als.client.screen.width / 100 * -left) - r.width
			else
				r.left = als.client.screen.width / 100 * left
			end
		end

		if not top then
			r.top = (als.client.screen.height - r.height) / 2
		elseif tonumber(top) == nil then
			top = tonumber(string.match(top, "^%d+"))
			if top < 0 then
				r.top = als.client.screen.height - (als.client.screen.height / 100 * -top) - r.height
			else
				r.top = als.client.screen.height / 100 * top
			end
		end

		setmetatable(r, {__index = rect})

		return r
	end,

	fromString = string.style,

	moveTo = function(rect, x, y)
		if not x then
			x = (als.client.screen.width - rect.width) / 2
		end

		if not y then
			y = (als.client.screen.height - rect.height) / 2
		end

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
function ShroudOnStart()
	als.ui.onInit(function()
		als.ui.command.add("lua", function(source, action)
			if action == "api" then
				for f,t in next, als.client.api.list do
					als.ui.consoleLog(t..": "..f)
				end
			elseif action == "lua" or action == "path" or action == "version" then
				als.ui.consoleLog("LUA Version: "..als.client.api.luaVersion)
				als.ui.consoleLog("LUA Path: "..als.client.api.luaPath)
			elseif action == "reload" or action == "unload" then
				als.ui.consoleLog("type: /lua "..action.." in the chat window instead")
			end
		end)

		als.ui.command.add("info", function(source, action, param)
			if action == "xp" then
				als.ui.consoleLog("Adventurer pooled XP: "..als.player.xp.adventurer.."\nProducer pooled XP: "..als.player.xp.producer)
			elseif action == "stat" and param then
				local stat = als.player.stat(param)
				if stat.value ~= -999 then
					als.ui.consoleLog(string.format("Stat %d: %s = %s (%s)", stat.number, stat.name, stat.value, stat.description))
				elseif tonumber(param) == nil then
					for i=0,#als.client._statEnum do
						stat = als.player.stat(i)
						if string.find(stat.name:lower()..stat.description:lower(), param:lower()) then
							als.ui.consoleLog(string.format("Stat %d: %s = %s (%s)", stat.number, stat.name, stat.value, stat.description))
						end
					end
				end
			elseif action == "inventory" then
				for _,i in next, als.player.inventory do
					if not param or i.name:lower():find(param:lower()) then
						if i.quantity > 1 then
							-- stack value / quantity
							als.ui.consoleLog(string.format("%s [e9b96e](%d)   w:%0.1f   v:%d[-]", i.name, i.quantity, i.weight, i.value))
						elseif i.maxDurability > 0 then
							local c = "73d216"
							if i.durability < 1 then
								c = "cc0000"
							elseif i.durability / i.maxDurability < 0.25 then
								c = "edd400"
							end
							als.ui.consoleLog(string.format("%s   [%s]%d/%d[-] (max %d)   w:%0.1f   v:%d", i.name, c, i.durability, i.primaryDurability, i.maxDurability, i.weight, i.value))
						else
							als.ui.consoleLog(string.format("%s   w:%0.1f   v:%d", i.name, i.weight, i.value))
						end
					end
				end
			elseif action == "client" or action == "player" or action == "scene" or action == "ui" then
				for n,v in next, _G[action] do
					if n:byte() ~= 95 then
						if type(v) == "table" then
							for n1,v1 in next, v do
								if action ~= "player" and n ~= "inventory" then
									als.ui.consoleLog(action.."."..n.."."..n1.." = "..tostring(v1))
								end
							end
						else
							als.ui.consoleLog(action.."."..n.." = "..tostring(v))
						end
					end
				end
			elseif action == "lib" then
				als.ui.consoleLog(string.format("timer: %d\nhandler: %d\ngui objects: %d", #als.ui.timer.list, #als.ui.handler.list, #ui_guiObjectList))
				for _,t in next, als.ui.texture._loaded do
					als.ui.consoleLog(string.format("texture %d: %s (%d x %d)", t.id, t.filename, t.width, t.height))
				end

				for n in next, als.ui.command.list do
					als.ui.consoleLog("command: "..n)
				end

				for k,r in next, als.ui.shortcut.list.pressed do
					for _,t in next, r do
						local s = k
						for _,p in next, t.keysHeld do
							s = p.." + "..s
						end

						als.ui.consoleLog("shortcut pressed: "..s)
					end
				end

				for k,r in next, als.ui.shortcut.list.watch do
					for _,t in next, r do
						local s = k
						for _,p in next, t.keysHeld do
							s = p.." + "..s
						end

						als.ui.consoleLog("shortcut watched: "..s)
					end
				end
			end
		end)
	end)
end

-- implement other ShroudOn... to allow other scripts
function ShroudOnConsoleInput()
end

function ShroudOnGUI()
end

function ShroudOnLogout()
	--als.client.isLoggedIn = false
end

function ShroudOnMouseClick()
end

function ShroudOnMouseOut()
end

function ShroudOnMouseOver()
end

function ShroudOnSceneLoaded(SceneName)
	--als.scene.name = SceneName
	--als.client.isLoggedIn = true
end

function ShroudOnSceneUnloaded()
	--als.scene.name = ""
end

function ShroudOnUpdate()
end
