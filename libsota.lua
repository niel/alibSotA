-- libsota.0.4.8 by Catweazle Waldschrath


--[[
 * libsota.lua
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



client = {
	timeStarted = os.time(),
	timeToLoad = 0,
	timeInGame = 0,
	timeDelta = 0,
	fps = 0,
	accuracy = 0,
	isHitching = false,
	isLoading = false,
	_statEnum = {},
	_statDescr = {},
	screen = {
		width = 0,
		height = 0,
		isFullScreen = false,
		aspectRatio = 0,
		_fsmul = 1,
	},
	api = {
		luaVersion = "",
		luaPath = "",
		list = {},
		isImplemented = function(name)
			return client.api.list[name] ~= nil
		end
	},
	mouse = {
		button = {},
		x = 0,
		y = 0,
	},
	window = {
		paperdoll = { name = "paperdoll", open = false, left = 0, top = 0, width = 267, height = 487 }
	}
}
scene = {
	name = "none",
	maxPlayer = 0,
	isPvp = false,
	isPot = false,
	timeInScene = 0,
	timeToLoad = 0,
	timeStarted = 0,
}
player = {
	caption = "",
	name = "none",
	flag = "",
	isPvp = false,
	isAfk = false,
	isGod = false,
	isMoving = false,
	isStill = false,
	lastMoved = os.time(),
	location = { x = 0, y = 0 , z = 0, scene = scene },
	health = { current = 0, max = 0, percentage = 0 },
	focus = { current = 0, max = 0, percentage = 0 },
	xp = { producer = 0, adventurer = 0 },
	inventory = {},
	stat = function(index)
		local ret = {
			number = -1,
			name = "invalid",
			value = -999,
			description = "",
		}
		if tonumber(index) == nil then
			index = client._statEnum[index]
		else
			index = tonumber(index)
		end
		if index and index <= #client._statEnum then
			ret.number = index
			ret.name = client._statEnum[index]
			ret.value = ShroudGetStatValueByNumber(index)
			ret.description = client._statDescr[index]
		end
		return ret
	end,
}
ui = {
	version = "0.4.8",

	timer = {
		list = {},
		add = function(timeout, once, callback, ...)
			local index = #ui.timer.list + 1
			local interval = nil

			if not once then
				interval = timeout
			end

			ui.timer.list[index] = {
				_index = index,
				time = os.time() + timeout,
				interval = interval,
				enabled = true,
				callback = callback,
				userdata = table.pack(...),
			}
			return index
		end,
		get = function(index)
			return ui.timer.list[index]
		end,
		remove = function(index)
			ui.timer.list[index] = nil
		end,
		enabled = function(index, enabled)
			if enabled ~= nil then
				ui.timer.list[index].enabled = enabled
			end
			return ui.timer.list[index].enabled
		end,
		pause = function(index)
			ui.timer.list[index].enabled = false
		end,
		resume = function(index)
			ui.timer.list[index].enabled = true
		end,
		toggle = function(index)
			ui.timer.list[index].enabled = not ui.timer.list[index].enabled
		end,
	},
	setTimeout = function(timeout, callback, ...) return ui.timer.add(timeout, true, callback, ...) end,
	setInterval = function(interval, callback, ...) return ui.timer.add(interval, false, callback, ...) end,

	
	handler = {
		list = {},
		add = function(name, callback)
			local index = #ui.handler.list + 1

			ui.handler.list[index] = {
				_index = index,
				name = name,
				callback = callback,
			}
			return index	
		end,
		remove = function(index)
			ui.handler.list[index] = nil
		end,
		invoke = function(name, ...)
			if not ui_initialized then return end
			for _,h in next, ui.handler.list do
				if h.name == name then
					h.callback(...)
				end
			end
		end,
	},
	onInit = function(callback) return ui.handler.add("_init", callback) end,
	onStart = function(callback) return ui.handler.add("_start", callback) end,
	onUpdate = function(callback) return ui.handler.add("_update", callback) end,
	onConsoleInput = function(callback) return ui.handler.add("_consoleInput", callback) end,
	onConsoleCommand = function(callback) return ui.handler.add("_consoleCommand", callback) end,
	onSceneChanged = function(callback) return ui.handler.add("_sceneChanged", callback) end,
	onPlayerChanged = function(callback) return ui.handler.add("_playerChanged", callback) end,
	onPlayerMove = function(callback) return ui.handler.add("_playerMove", callback) end,
	onPlayerMoveStart = function(callback) return ui.handler.add("_playerMoveStart", callback) end, -- depricated
	onPlayerMoveStop = function(callback) return ui.handler.add("_playerMoveStop", callback) end, -- depricated
	onPlayerIsStill = function(callback) return ui.handler.add("_playerIsStill", callback) end,
	onPlayerDamage = function(callback) return ui.handler.add("_playerDamage", callback) end,
	onPlayerInventory = function(callback) return ui.handler.add("_playerInventory", callback) end,
	onClientWindow = function(callback) return ui.handler.add("_clientWindow", callback) end,
	onClientIsHitching = function(callback) return ui.handler.add("_clientIsHitching", callback) end,
	onClientIsLoading = function(callback) return ui.handler.add("_clientIsLoading", callback) end,
	onMouseMove = function(callback) return ui.handler.add("_mouseMove", callback) end,
	onMouseButton = function(callback) return ui.handler.add("_mouseButton", callback) end,


	guiObject = {
		add = function(left, top, width, height, drawFunc)
			local index = #ui_guiObjectList + 1
			ui_guiObjectList[index] = {
				rect = { left = left or 0, top = top or 0, width = width or 0, height = height or 0 },
				visible = false,
				shownInScene = true,
				shownInLoadScreen = false,
				zIndex = 0,
			}
			local obj = {
				guiDrawFunc = drawFunc,
				guiObjectId = index,
				rect = ui_guiObjectList[index].rect,
			}
			setmetatable(obj, {__index = ui.guiObject})
			setmetatable(ui_guiObjectList[index], {__index = obj})
			return obj
		end,
		remove = function(obj)
			ui_guiObjectList[obj.guiObjectId] = nil
			obj = nil
			ui_drawListChanged = true
		end,
		shownInScene = function(obj, shown)
			if shown ~= nil and shown ~= ui_guiObjectList[obj.guiObjectId].shownInScene then
				ui_guiObjectList[obj.guiObjectId].shownInScene = shown
				ui_drawListChanged = true
			end
			return ui_guiObjectList[obj.guiObjectId].shownInScene
		end,
		shownInLoadScreen = function(obj, shown)
			if shown ~= nil and shown ~= ui_guiObjectList[obj.guiObjectId].shownInLoadScreen then
				ui_guiObjectList[obj.guiObjectId].shownInLoadScreen = shown
				ui_drawListChanged = true
			end
			return ui_guiObjectList[obj.guiObjectId].shownInLoadScreen
		end,
		zIndex = function(obj, zIndex)
			if zIndex ~= nil and zIndex ~= ui_guiObjectList[obj.guiObjectId].zIndex then
				ui_guiObjectList[obj.guiObjectId].zIndex = zIndex
				ui_drawListChanged = true
			end
			return ui_guiObjectList[obj.guiObjectId].zIndex
		end,
		visible = function(obj, visible)
			if visible ~= nil and visible ~= ui_guiObjectList[obj.guiObjectId].visible then
				ui_guiObjectList[obj.guiObjectId].visible = visible
				ui_drawListChanged = true
			end
			return ui_guiObjectList[obj.guiObjectId].visible
		end,
		toggle = function(obj)
			obj:visible(not obj:visible())
		end,
		rect = function(obj, rect)
			if type(rect) == "table" then
				if rect.left then obj.rect.left = rect.left end
				if rect.top then obj.rect.top = rect.top end
				if rect.width then obj.rect.width = rect.width end
				if rect.height then obj.rect.height = rect.height end
			end
			return obj.rect
		end,
		moveTo = function(obj, x, y)
			obj.rect.left = x
			obj.rect.top = y
		end,
		moveBy = function(obj, x, y)
			obj.rect.left = obj.rect.left + x
			obj.rect.top = obj.rect.top + y
		end,
		resizeTo = function(obj, w, h)
			obj.rect.width = w
			obj.rect.height = h
		end,
		resizeBy = function(obj, x, y)
			obj.rect.width = obj.rect.width + x
			obj.rect.height = obj.rect.height + y
		end,
	},
	
	
	label = {
		add = function(left, top, width, height, caption)
			local l = ui.guiObject.add(left, top, width, height, ui.label.draw)
			l.caption = caption or ""
			
			setmetatable(l, {__index = ui.label})
			return l
		end,
		draw = function(l)
			ShroudGUILabel(l.rect.left, l.rect.top, l.rect.width, l.rect.height, l.caption)
		end,
	},
	
	texture = {
		_loaded = {},
		add = function(left, top, filename, clamped, scaleMode, width, height)
			
			if not ui.texture._loaded[tostring(filename)] then
				local tid = ShroudLoadTexture(filename, clamped or false)
				if tid < 0 then
					print("ui.texture: Unable to load texture with filename '"..filename.."'")
					return nil
				end
				local tw, th = ShroudGetTextureSize(tid)
				ui.texture._loaded[tostring(filename)] = {
					filename = filename,
					id = tid,
					width = tw,
					height = th,
					clamped = clamped or false,
				}
			end
			local tex = ui.texture._loaded[tostring(filename)]

			local t = ui.guiObject.add(left, top, width or tex.width, height or tex.height, ui.texture.draw)
			t.texture = tex
			t.scaleMode = scaleMode or -1

			setmetatable(t, {__index = ui.texture})
			return t
		end,
		draw = function(t)
			ShroudDrawTexture(t.rect.left, t.rect.top, t.rect.width, t.rect.height, t.texture.id, t.scaleMode)
		end,
		clone = function(texture)
			local t = ui.guiObject.add(texture.rect.left, texture.rect.top, texture.rect.width, texture.rect.height, texture.guiDrawFunc)
			t.texture = texture.texture
			t.scaleMode = texture.scaleMode
			t.shownInScene = texture.shownInScene
			t.shownInLoadScreen = texture.shownInLoadScreen
			t.zIndex = texture.zIndex
						
			setmetatable(t, {__index = ui.texture})
			return t
		end,
		clamp = function(texture, clamped)
			if clamped ~= nil and clamped ~= texture.texture.clamped then
				texture.texture.clamped = clamped
				ShroudSetTextureClamp(texture.texture.id, texture.texture.clamped)
			end
			return texture.texture.clamped
		end,
		scaleMode = function(texture, scaleMode)
			if scaleMode ~= nil then
				texture.scaleMode = scaleMode
			end
			return texture.scaleMode
		end,
	},
	
	guiButton = {
		add = function(left, top, texture, caption, tooltip, width, height)
			local b = ui.guiObject.add(left, top, width, height, ui.guiButton.draw)
			b.caption = caption or ""
			b.tooltip = tooltip or ""
			-- b.mode = false -- mode = repeat, click, off/false

			if type(texture) == "table" and texture.texture and texture.texture.id then
				b.texture = texture
			else
				print("ui.guiButton: "..type(texture).." is not a texture object.")
				return nil
			end
			
			setmetatable(b, {__index = ui.guiButton})
			return b
		end,
		draw = function(b)
			ShroudButton(b.rect.left, b.rect.top, b.rect.width, b.rect.height, b.texture.texture.id, b.caption, b.tooltip)
		end,
		onClick = function(button, callback)
			button.callback = callback
			button.guiDrawFunc = function(b)
				if ShroudButton(b.rect.left, b.rect.top, b.rect.width, b.rect.height, b.texture.texture.id, b.caption, b.tooltip) then
					b.callback(ShroudMouseX - b.rect.left, ShroudMouseY - b.rect.top)
				end
			end
		end,
		onRepeat = function(button, callback)
			button.callback = callback
			button.guiDrawFunc = function(b)
				if ShroudButtonRepeat(b.rect.left, b.rect.top, b.rect.width, b.rect.height, b.texture.texture.id, b.caption, b.tooltip) then
					b.callback(ShroudMouseX - b.rect.left, ShroudMouseY - b.rect.top)
				end
			end
		end,
	},


	shortcut = {
		list = { pressed = {}, watch = {} },
		add = function(action, ...)
			local keys = {...}
			local callback = keys[#keys]; keys[#keys] = nil
			local key = keys[#keys]; keys[#keys] = nil
			if not ui.shortcut.list[action][tostring(key)] then
				ui.shortcut.list[action][tostring(key)] = {}
			end
			if type(callback) == "string" then
				callback = ui.command.list[callback].callback
			end
			local id = #ui.shortcut.list[action][key] + 1
			local index = { action = action, key = key, id = id }
			ui.shortcut.list[action][key][id] = {
				_index = index,
				key = key,
				keysHeld = keys,
				callback = callback,
			}
			if type(callback) == string then
				if ui.command.list[callback].shortcut then
					ui.shortcut.remove(ui.command.list[callback].shortcut)
				end
				ui.command.list[callback].shortcut = index
			end
			return index
		end,
		remove = function(index)
			ui.shortcut.list[index.action][index.key][index.id] = nil
			if #ui.shortcut.list[index.action][index.key] == 0 then ui.shortcut.list[index.action][index.key] = nil end
		end,
		invoke = function(index)
			ui.shortcut.list[index.action][index.key][index.id].callback()
		end,
	},
	
	command = {
		list = {},
		add = function(command, callback)
			ui.command.list[tostring(command)] = {
				_command = command,
				callback = callback,
				shortcut = nil,
				channel = nil,
				sender = player.name,
				receiver = nil,
			}
			return command
		end,
		remove = function(command)
			if ui.command.list[command].shortcut then
				ui.shortcut.remove(ui.command.list[command].shortcut)
			end
			ui.command.list[command] = nil
		end,
		invoke = function(command, ...)
			if ... then
				ui.command.list[command].callback(nil, unpack(...))
			else
				ui.command.list[command].callback()
			end
		end,
		restrict = function(command, channel, sender, receiver)
			if ui.command[command] then
				ui.command[command].channel = channel
				ui.command[command].sender = sender
				ui.command[command].receiver = receiver
			end
		end
	},
	
	module = {
		list = {},
		add = function(modulename, prefix)
			local part = {}
			for p in modulename:gmatch("[^\\/.]+") do part[#part + 1] = p end
			if part[#part] == "lua" then part[#part] = nil end
			modulename = table.concat(part, ".")
			if not ui.module.list[modulename] then
				local filename = table.concat(part, "/")..".lua"
				local f = nil
				for _,inc in next, {"/","/lib/","/share/","/bin/","/include/"} do
					f = io.open(ShroudLuaPath..inc..filename)
					if f then break end
				end
				if not f then
					print("ui.module: '",filename,"' not found")
					return nil
				end
				local d = f:read("*a")
				f:close()
				local m,e = loadsafe(d, modulename, "bt", _G)
				if not m then
					print("ui.module: '",modulename,"': "..e)
					return nil
				end
				ui.module.list[modulename] = {}
				ui.module.list[modulename][0] = m
			end
			if prefix then
				if prefix == true or prefix == "" then
					prefix = modulename
				else
					part = {}
					for p in prefix:gmatch("[^\\/.]+") do part[#part + 1] = p end
					if part[#part] == "lua" then part[#part] = nil end
					prefix = table.concat(part, ".")
				end
				if #part == 1 then
					_G[part[1]] = ui.module.list[modulename][0]
				else
					local tree = {}
					local leave = tree
					for i=2,#part-1 do
						if not leave[part[i]] then leave[part[i]] = {} end
						leave = leave[part[i]]
					end
					leave[part[#part]] = ui.module.list[modulename][0]
					_G[part[1]] = tree
				end
				ui.module.list[modulename][#ui.module.list[modulename] + 1] = part
			end
			return ui.module.list[modulename][0]
		end,
		get = function(modulename)
			local part = {}
			for p in modulename:gmatch("[^\\/.]+") do part[#part + 1] = p end
			if part[#part] == "lua" then part[#part] = nil end
			modulename = table.concat(part, ".")
			return ui.module.list[tostring(modulename)][0]
		end,
		remove = function(modulename)
			local part = {}
			for p in modulename:gmatch("[^\\/.]+") do part[#part + 1] = p end
			if part[#part] == "lua" then part[#part] = nil end
			modulename = table.concat(part, ".")
			ui.module.list[tostring(modulename)][0] = nil
			for _,prefix in next, ui.module.list[tostring(modulename)] do
				if #prefix == 1 then
					_G[prefix[1]] = nil
				else
					local tree = _G[prefix[1]]
					local leave = tree
					for i=2,#prefix-1 do
						if leave[prefix[i]] then leave = leave[prefix[i]] end
					end
					leave[prefix[#prefix]] = nil
					_G[prefix[1]] = tree
				end
			end
			ui.module.list[tostring(modulename)] = nil
		end,
		invoke = function(modulename, callback, ...)
			local part = {}
			for p in modulename:gmatch("[^\\/.]+") do part[#part + 1] = p end
			if part[#part] == "lua" then part[#part] = nil end
			modulename = table.concat(part, ".")
			if ui.module.list[modulename] then
				if callback then
					return ui.module.list[modulename][0][tostring(callback)](...)
				else
					return ui.module.list[modulename][0](...)
				end
			else
				print("ui.module: ",modulename," not found")
			end
		end,
	},
	
	verbosity = 0,
	consoleLog = function(message, verbosity)
		if not verbosity then verbosity = 0 end
		if ui.verbosity >= verbosity then
			for l in message:gmatch("[^\n]+") do
				ShroudConsoleLog(l)
			end
		end
	end,
}
--setmetatable(ui.timer, {__index = ui.timer.list})
setmetatable(ui.label, {__index = ui.guiObject})
setmetatable(ui.texture, {__index = ui.guiObject})
setmetatable(ui.guiButton, {__index = ui.guiObject})



-- internal
ui_initialized = false
ui_client_ts = os.time()
ui_client_frame = 0
ui_guiObjectList = {}
ui_drawListChanged = false
local ui_drawInScene = {}
local ui_drawInLoadScreen = {}
local ui_callback_queue = {}

local ui_inventory_quantity = {}
local ui_inventory_durability = {}

local function ui_getPlayerName()
	if player.caption ~= ShroudGetPlayerName() then
		player.caption = ShroudGetPlayerName()
		player.name = player.caption
		player.flag = ""
		player.isPvp = false
		if player.name:byte(#player.name) == 93 then
			player.name, player.flag = player.name:match("^(.-)(%[.-%])$")
			player.isPvp = player.flag and player.flag:find("PVP") ~= nil
			player.isAfk = player.flag and player.flag:find("AFK") ~= nil
			player.isGod = player.flag and player.flag:find("God") ~= nil
		end
		ui.handler.invoke("_playerChanged", "caption")
	end
end
local function ui_getPlayerChange()
	local loc = { x = ShroudPlayerX, y = ShroudPlayerY, z = ShroudPlayerZ, scene = scene }
	local isMoving = loc.x ~= player.location.x or loc.y ~= player.location.y or loc.z ~= player.location.z
	if isMoving then player.lastMoved = os.time() end
	local isStill = os.time() - player.lastMoved > 5
	local invoke = isStill ~= player.isStill or isMoving ~= player.isMoving
	player.isMoving = isMoving
	player.isStill = isStill
	player.location = loc
	if invoke then
		if isMoving then
			ui.handler.invoke("_playerMoveStart") -- depricated
			ui.handler.invoke("_playerMove", "start", loc)
			ui.handler.invoke("_playerChanged", "moving")
		elseif isStill then
			ui.handler.invoke("_playerIsStill") -- depricated?
			ui.handler.invoke("_playerMove", "stillness", loc) -- hm?
			ui.handler.invoke("_playerChanged", "stillness")
		else
			ui.handler.invoke("_playerMoveStop") -- depricated
			ui.handler.invoke("_playerMove", "stop", loc)
			ui.handler.invoke("_playerChanged", "standing")
		end
	end
	if isMoving then
		ui.handler.invoke("_playerMove", "move", loc)
		ui.handler.invoke("_playerChanged", "location", loc)
	end
	local health = { max = ShroudGetStatValueByNumber(30), current = ShroudPlayerCurrentHealth, percentage = 0 }
	local focus =  { max = ShroudGetStatValueByNumber(27), current = ShroudPlayerCurrentFocus, percentage = 0 }
	health.percentage = health.current / health.max
	focus.percentage = focus.current / focus.max
	invoke = player.health.current ~= health.current or player.focus.current ~= focus.current
	if invoke then
		ui.handler.invoke("_playerDamage", health, focus)
		ui.handler.invoke("_playerChanged", "damage", health, focus)
	end
	player.health = health
	player.focus = focus
end
local function ui_getPlayerInventory()
	local inventory = ShroudGetInventory()
	local ret1 = {}
	local ret2 = {}
	local ret3 = {}
	for _, item in next, inventory do
		item = table.pack(item)
		ret1[#ret1 + 1] = {
			name = item[1],
			durability = item[2],
			primaryDurability = item[3],
			maxDurability = item[4],
			weight = item[5],
			quantity = item[6],
			value = item[7],
		}
		if not ret2[tostring(item[1])] then
			ret2[tostring(item[1])] = 0
		end
		ret2[tostring(item[1])] = ret2[tostring(item[1])] + item[6]
	end
	local cs = { n = 0 }
	for n, q in next, ui_inventory_quantity do
		if not ret2[n] then
			--print("Gegenstand entfernt: "..n.."Menge: "..q)
			cs[n] = { quantity = q, action = "removed" }
			cs.n = cs.n + 1
		elseif ret2[n] ~= q then
			--print("Gegenstand geändert: "..n.."Menge: "..(ret2[n] - q))
			cs[n] = { quantity = ret2[n] - q, action = "changed" }
			cs.n = cs.n + 1
		end
	end
	for n, q in next, ret2 do
		if not ui_inventory_quantity[n] then
			--print("Gegenstand zugefügt: "..n.."Menge: "..q)
			cs[n] = { quantity = q, action = "added" }
			cs.n = cs.n + 1
		end
	end
	
	player.inventory = ret1
	ui_inventory_quantity = ret2

	if cs.n > 0 then
		cs.n = nil
		ui.handler.invoke("_playerInventory", cs)
		ui.handler.invoke("_playerChanged", "inventory", cs)
	end
end
local function ui_getSceneName()
	if scene.name ~= ShroudGetCurrentSceneName() then
		scene.name = ShroudGetCurrentSceneName()
		scene.maxPlayer = ShroudGetCurrentSceneMaxPlayerCount()
		scene.isPvp = ShroudGetCurrentSceneIsPVP()
		scene.isPot = ShroudGetCurrentSceneIsPOT()
		scene.timeStarted = os.time()
		ui.handler.invoke("_sceneChanged")
	end
end
local function ui_initialize()

	client.api.luaPath = ShroudLuaPath
	client.api.luaVersion = _G._MOONSHARP.luacompat
	for i,v in next, _G do
		if i:find("^Shroud") then client.api.list[tostring(i)] = type(v) end
	end

	client.timeToLoad = ui_client_ts - client.timeStarted
	client.screen.width = ShroudGetScreenX()
	client.screen.height = ShroudGetScreenY()
	client.screen.isFullScreen = ShroudGetFullScreen()
	client.screen.aspectRatio = client.screen.width / client.screen.height
	client.screen._fsmul = client.screen.height / 1080
	for i=0, ShroudGetStatCount()-1, 1 do
		local name = ShroudGetStatNameByNumber(i)
		client._statEnum[tostring(name)] = i
		client._statEnum[i] = name
		client._statDescr[i] = ShroudGetStatDescriptionByNumber(i)
	end
	ui_getSceneName()
	ui_getPlayerName()
	ui_getPlayerChange()
	ui_getPlayerInventory()

	ShroudRegisterPeriodic("ui_timer_internal", "ui_timer_internal", 0.01, true)
	ShroudRegisterPeriodic("ui_timer_user", "ui_timer_user", 0.120, true)
end
local function ui_buildDrawList()
	local list = ui_guiObjectList
	local ds = {}
	local dl = {}

	for _,o in next, list do
		if o.visible and o.shownInScene then
			ds[#ds + 1] = o
		elseif o.visible and o.shownInLoadScreen then
			dl[#dl + 1] = o
		end
	end

	table.sort(ds, function(a, b) return a.zIndex < b.zIndex end)
	table.sort(dl, function(a, b) return a.zIndex < b.zIndex end)
	
	ui_drawInScene = ds
	ui_drawInLoadScreen = dl
end
local function ui_queue(callback, ...)
	local index = #ui_callback_queue + 1

	if type(callback) == "function" then
		ui_callback_queue[index] = {
			callback = callback,
			userdata = table.pack(...),
		}	
	else
		for _,h in next, ui.handler.list do
			if h.name == callback then
				ui_callback_queue[index] = {
					callback = h.callback,
					userdata = table.pack(...),
				}	
				index = #ui_callback_queue + 1
			end
		end
	end
end


-- shroud callbacks


-- shroud timers
local ui_timer_ts_fast = os.time()
local ui_timer_ts_slow = os.time()
function ui_timer_internal()
	local ts = os.time()
	
	if ts - ui_timer_ts_fast > 0.240 then
		ui_timer_ts_fast = ts

		ui_getPlayerChange()
	end
	
	if ts - ui_timer_ts_slow > 2 then
		ui_timer_ts_slow = ts
		
		-- watch player xp
		player.xp.producer = ShroudGetPooledProducerExperience()
		player.xp.adventurer = ShroudGetPooledAdventurerExperience()

		-- watch player inventory
		ui_getPlayerInventory()
	end


	-- queued callbacks

	for i,q in next, ui_callback_queue do
		q.callback(unpack(q.userdata))
		ui_callback_queue[i] = nil
	end
	
	
	-- watch character sheet window (realtime)

	local wo = ShroudIsCharacterSheetActive()
	if wo then
		local wx, wy = ShroudGetCharacterSheetPosition(); wx = wx - 860 -- bug
		if wx ~= client.window.paperdoll.left or wy ~= client.window.paperdoll.top then
			client.window.paperdoll.left, client.window.paperdoll.top = wx, wy
			ui.handler.invoke("_clientWindow", "moved", client.window.paperdoll)		
		end
	end
	if wo ~= client.window.paperdoll.open then
		client.window.paperdoll.open = wo
		if wo then
			ui.handler.invoke("_clientWindow", "opened", client.window.paperdoll)
		else
			ui.handler.invoke("_clientWindow", "closed", client.window.paperdoll)
		end
	end
end

function ui_timer_user()
	local ts = os.time()
	
	for _,t in next, ui.timer.list do
		if t.enabled and ts >= t.time then
			if t.interval then
				t.time = ts + t.interval
			else
				ui.timer.list[t._index] = nil
			end
			if t.callback(unpack(t.userdata)) then ui.timer.list[t._index] = nil end
		end
	end
end


-- shroud callbacks
local button_ts = {} -- howto: clean up
local button_ts2 = {}

function ShroudOnConsoleInput(channel, sender, message)

	ui_queue(function(...)

		-- handle player flag changes
		if (channel == "Story" or channel == "System") and message:find("PvP") then ui_getPlayerName() end

		-- parse message
		local src, dst, msg = message:match("^(.-) to (.-) %[.-:%s*(.*)$")
		if sender == "" then sender = src end
		if sender == "" then sender = player.name end
		if msg:byte() == 92 or msg:byte() == 95 or msg:byte() == 33 then
			local cmd, tail = msg:match("^[\\_!](%w+)%s*(.*)$")
			local source = {
				channel = channel,
				sender = sender,
				receiver = dst,
			}
			if ui.command.list[cmd] then
				if not ui.command.list[cmd].sender or ui.command.list[cmd].sender == sender
				and not ui.command.list[cmd].channel or ui.command.list[cmd].channel == channel
				and not ui.command.list[cmd].receiver or ui.command.list[cmd].receiver == dst
				then
					local arg = {}
					for a in tail:gmatch("%S+") do arg[#arg + 1] = a end
					arg.n = #arg
					ui.command.list[cmd].callback(source, unpack(arg))
				end
			else
				ui.handler.invoke("_consoleCommand", source, cmd, tail)
			end
		else
			ui.handler.invoke("_consoleInput", channel, sender, dst, msg)
		end

	end, channel, sender, message)
end

function ShroudOnGUI()
	local ts = os.time()
	local isHitching = ts - ui_client_ts >= 2
	local isLoading = ts - ui_client_ts >= 5

	if isHitching and client.isHitching ~= isHitching then
		client.isHitching = isHitching
		ui.handler.invoke("_clientIsHitching")
	end
	if isLoading and client.isLoading ~= isLoading then
		client.isLoading = isLoading
		ui.handler.invoke("_clientIsLoading")
	end
		
	if not isHitching then
		local list = ui_drawInScene
		if isLoading then list = ui_drawInLoadScreen end
		
		for _,o in next, list do
			o:guiDrawFunc()
			if os.time() - ts > 0.01 then break end
		end
	end
end

function ShroudOnStart()
	ShroudUseLuaConsoleForPrint(true)
	ShroudConsoleLog(_G._MOONSHARP.banner)
	ShroudConsoleLog("LUA Version: ".._G._MOONSHARP.luacompat)
end

function ShroudOnUpdate()
	local ts = os.time()

	-- init
	if not ui_initialized then
		if not ShroudServerTime then return end -- shroud Api not ready, yet
		ShroudConsoleLog("Shroud Api Ready. ServerTime: "..ShroudServerTime)

		ui_initialize()
		ui_initialized = true

		ui.handler.invoke("_init")
		ui.handler.invoke("_start")
	end

	-- client stats
	ui_client_frame = ui_client_frame + 1;
	if ts - ui_client_ts >= 1 then
		if client.accuracy > 10 then
			ui_getSceneName()
			ui_getPlayerName()
			client.isLoading = false
			scene.timeToLoad = client.accuracy
		end
		client.timeInGame = ShroudTime
		client.timeDelta =  ShroudDeltaTime
		client.fps = ui_client_frame
		ui_client_frame = 0
		client.accuracy = ts - ui_client_ts - 1
		ui_client_ts = ts
		client.isHitching = false
		scene.timeInScene = ts - scene.timeStarted
	end

	-- check key up
	for ku,r in next, ui.shortcut.list.pressed do
		if ShroudGetOnKeyUp(ku) then
			for _,f in next, r do
				local invoke = true
				for _,kd in next, f.keysHeld do
					invoke = invoke and ShroudGetKeyDown(kd)
				end
				if invoke then f.callback() end
			end
		end
	end
	-- check key held/repeat
	for ku,r in next, ui.shortcut.list.watch do
		if ShroudGetOnKeyDown(ku) then
			for _,f in next, r do
				local invoke = true
				for _,kd in next, f.keysHeld do
					invoke = invoke and ShroudGetKeyDown(kd)
				end
				if invoke then
					f.timeDown = os.time()
					f.callback("down", ku, f.keysHeld)
				end
			end

		elseif ShroudGetKeyDown(ku) then
			for _,f in next, r do
				local invoke = true
				for _,kd in next, f.keysHeld do
					invoke = invoke and ShroudGetKeyDown(kd)
				end
				if invoke then
					if os.time() - f.timeDown >= 0.25 then
						f.callback("held", ku, f.keysHeld)
					end
				end
			end

		elseif ShroudGetOnKeyUp(ku) then
			for _,f in next, r do
				local invoke = true
				for _,kd in next, f.keysHeld do
					invoke = invoke and ShroudGetKeyDown(kd)
				end
				if invoke then
					f.timeUp = os.time()
					f.callback("up", ku, f.keysHeld)
					if os.time() - f.timeDown <= 0.25 then
						f.callback("pressed", ku, f.keysHeld)
					end
				end
			end
		end
	end

	-- check mouse
	for i,mb in next, { "Mouse0", "Mouse1", "Mouse2", "Mouse3", "Mouse4", "Mouse5", "Mouse6" } do
		client.mouse.button[i] = nil
		if ShroudGetOnKeyDown(mb) then
			button_ts[i] = os.time()
			client.mouse.button[i] = "down"
		elseif ShroudGetKeyDown(mb) then
			if os.time() - button_ts[i] >= 0.25 then
				client.mouse.button[i] = "held"
			end
		elseif ShroudGetOnKeyUp(mb) then
			client.mouse.button[i] = "up"
			if os.time() - button_ts[i] <= 0.25 then
				if button_ts2[i] and os.time() - button_ts2[i] <= 0.25 then
					ui.handler.invoke("_mouseButton", "dblclicked", i, ShroudMouseX, ShroudMouseY)
					button_ts2[i] = nil
				else
					ui.handler.invoke("_mouseButton", "clicked", i, ShroudMouseX, ShroudMouseY)
					button_ts2[i] = os.time()
				end
			end
		end
	end
	if client.mouse.x ~= ShroudMouseX or client.mouse.y ~= ShroudMouseY then
		client.mouse.x, client.mouse.y = ShroudMouseX, ShroudMouseY
		ui.handler.invoke("_mouseMove", client.mouse.button, client.mouse.x, client.mouse.y)
	end
	for i,mb in next, client.mouse.button do
		ui.handler.invoke("_mouseButton", mb, i, client.mouse.x, client.mouse.y)
	end


	ui.handler.invoke("_update")	
	
	if ui_drawListChanged then
		ui_drawListChanged = false
		ui_buildDrawList()
	end
end



-- implement other ShroudOn... to allow other scripts
function ShroudOnLogout()
	--client.isLoggedIn = false
end

function ShroudOnMouseClick()
end

function ShroudOnMouseOut()
end

function ShroudOnMouseOver()
end

function ShroudOnSceneLoaded(SceneName)
	--scene.name = SceneName
	--client.isLoggedIn = true
end

function ShroudOnSceneUnloaded()
	--scene.name = ""
end
