-- libsota.0.5.d by Catweazle Waldschrath

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

als = {
	client = nil,
	player = nil,
	scene = nil,
	ui = nil,
}

als.client = {
	timeStarted = os.time(),
	timeToLoad = 0,
	timeInGame = 0,
	timeDelta = 0,
	fps = 0,
	accuracy = 0,
	isHitching = false,
	isLoading = false,
	isLoggedIn = false,
	_statEnum = {},
	_statDescr = {},
	screen = {
		width = 0,
		height = 0,
		isFullScreen = false,
		aspectRatio = 0,
		pxptRatio = 1,	-- The ratio of pixel to point value?
	},

	api = {
		luaVersion = "",
		luaPath = "",
		list = {},
		isImplemented = function(name)
			return als.client.api.list[name] ~= nil
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

als.scene = {
	name = "none",
	levelCap = 200,
	maxPlayer = 0,
	isPvp = false,
	isPot = false,
	timeInScene = 0,
	timeToLoad = 0,
	timeStarted = 0,
}

als.player = {
	caption = "",
	name = "none",
	flag = "",
	isPvp = false,
	isAfk = false,
	isGod = false,
	isMoving = false,
	isStill = false,
	lastMoved = os.time(),
	location = { x = 0, y = 0 , z = 0, scene = als.scene },
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
			index = als.client._statEnum[index]
		else
			index = tonumber(index)
		end

		if index and index <= #als.client._statEnum then
			ret.number = index
			ret.name = als.client._statEnum[index]
			ret.value = ShroudGetStatValueByNumber(index)
			ret.description = als.client._statDescr[index]
		end

		return ret
	end,
}

als.ui = {
	version = "0.5.d",

	-- stubs for functions in a.libsota.ui.lua
	application = nil,
	button = nil,
	container = nil,
	rect = function() print("stub for rect function!") end,
	shell = nil,
	titlebar = nil,
	window = nil,

	timer = {
		list = {},

		add = function(timeout, once, callback, ...)
			local index = #als.ui.timer.list + 1
			local interval = nil

			if not once then
				interval = timeout
			end

			als.ui.timer.list[index] = {
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
			return als.ui.timer.list[index]
		end,

		remove = function(index)
			als.ui.timer.list[index] = nil
		end,

		enabled = function(index, enabled)
			if enabled ~= nil then
				als.ui.timer.list[index].enabled = enabled
			end

			return als.ui.timer.list[index].enabled
		end,

		pause = function(index)
			als.ui.timer.list[index].enabled = false
		end,

		resume = function(index)
			als.ui.timer.list[index].enabled = true
		end,

		toggle = function(index)
			als.ui.timer.list[index].enabled = not als.ui.timer.list[index].enabled
		end,
	},

	handler = {
		list = {},

		add = function(name, callback)
			local index = #als.ui.handler.list + 1
			als.ui.handler.list[index] = {
				_index = index,
				name = name,
				callback = callback,
			}

			return index
		end,

		remove = function(index)
			als.ui.handler.list[index] = nil
		end,

		invoke = function(name, ...)
			if not als_ui_initialized then return end
			for _,h in next, als.ui.handler.list do
				if h.name == name then
					h.callback(...)
				end
			end
		end,
	},

	onInit = function(callback)
		return als.ui.handler.add("_init", callback)
	end,

	onStart = function(callback)
		return als.ui.handler.add("_start", callback)
	end,

	onUpdate = function(callback)
		return als.ui.handler.add("_update", callback)
	end,

	onConsoleInput = function(callback)
		return als.ui.handler.add("_consoleInput", callback)
	end,

	onConsoleCommand = function(callback)
		return als.ui.handler.add("_consoleCommand", callback)
	end,

	onSceneChanged = function(callback)
		return als.ui.handler.add("_sceneChanged", callback)
	end,

	onPlayerChanged = function(callback)
		return als.ui.handler.add("_playerChanged", callback)
	end,

	onPlayerMove = function(callback)
		return als.ui.handler.add("_playerMove", callback)
	end,

	onPlayerMoveStart = function(callback)
		return als.ui.handler.add("_playerMoveStart", callback)
	end, -- deprecated

	onPlayerMoveStop = function(callback)
		return als.ui.handler.add("_playerMoveStop", callback)
	end, -- deprecated

	onPlayerIsStill = function(callback)
		return als.ui.handler.add("_playerIsStill", callback)
	end,

	onPlayerDamage = function(callback)
		return als.ui.handler.add("_playerDamage", callback)
	end,

	onPlayerInventory = function(callback)
		return als.ui.handler.add("_playerInventory", callback)
	end,

	onClientWindow = function(callback)
		return als.ui.handler.add("_clientWindow", callback)
	end,

	onClientIsHitching = function(callback)
		return als.ui.handler.add("_clientIsHitching", callback)
	end,

	onClientIsLoading = function(callback)
		return als.ui.handler.add("_clientIsLoading", callback)
	end,

	onMouseMove = function(callback)
		return als.ui.handler.add("_mouseMove", callback)
	end,

	onMouseButton = function(callback)
		return als.ui.handler.add("_mouseButton", callback)
	end,

	guiObject = {
		add = function(left, top, width, height, drawFunc)
			local index = #als.ui_guiObjectList + 1
			als.ui_guiObjectList[index] = {
				rect = { left = left or 0, top = top or 0, width = width or 0, height = height or 0 },
				visible = false,
				shownInScene = true,
				shownInLoadScreen = false,
				zIndex = 0,
			}

			local obj = {
				guiDrawFunc = drawFunc,
				guiObjectId = index,
				rect = als.ui_guiObjectList[index].rect,
			}

			setmetatable(obj, {__index = als.ui.guiObject})
			setmetatable(als.ui_guiObjectList[index], { __index = obj})

			return obj
		end,

		remove = function(obj)
			als.ui_guiObjectList[obj.guiObjectId] = nil
			obj = nil
			als_ui_drawListChanged = true
		end,

		shownInScene = function(obj, shown)
			if shown ~= nil and shown ~= als.ui_guiObjectList[obj.guiObjectId].shownInScene then
				als.ui_guiObjectList[obj.guiObjectId].shownInScene = shown
				als_ui_drawListChanged = true
			end

			return als.ui_guiObjectList[obj.guiObjectId].shownInScene
		end,

		shownInLoadScreen = function(obj, shown)
			if shown ~= nil and shown ~= als.ui_guiObjectList[obj.guiObjectId].shownInLoadScreen then
				als.ui_guiObjectList[obj.guiObjectId].shownInLoadScreen = shown
				als_ui_drawListChanged = true
			end

			return als.ui_guiObjectList[obj.guiObjectId].shownInLoadScreen
		end,

		zIndex = function(obj, zIndex)
			if zIndex ~= nil and zIndex ~= als.ui_guiObjectList[obj.guiObjectId].zIndex then
				als.ui_guiObjectList[obj.guiObjectId].zIndex = zIndex
				als_ui_drawListChanged = true
			end

			return als.ui_guiObjectList[obj.guiObjectId].zIndex
		end,

		visible = function(obj, visible)
			if visible ~= nil and visible ~= als.ui_guiObjectList[obj.guiObjectId].visible then
				als.ui_guiObjectList[obj.guiObjectId].visible = visible
				als_ui_drawListChanged = true
			end

			return als.ui_guiObjectList[obj.guiObjectId].visible
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
			local l = als.ui.guiObject.add(left, top, width, height, als.ui.label.draw)
			l.caption = caption or ""

			setmetatable(l, {__index = als.ui.label})
			return l
		end,

		draw = function(l)
			ShroudGUILabel(l.rect.left, l.rect.top, l.rect.width, l.rect.height, l.caption)
		end,
	},

	texture = {
		_loaded = {},
		add = function(left, top, filename, clamped, scaleMode, width, height)

			if filename:startsWith(ShroudLuaPath) then
				filename = filename:gsub("^"..ShroudLuaPath.."[\\/]", "")
			end

			if not als.ui.texture._loaded[tostring(filename)] then
				local tid = ShroudLoadTexture(filename, clamped or false)

				if tid < 0 then
					print("als.ui.texture: Unable to load texture with filename '"..filename.."'")
					return nil
				end

				local tw, th = ShroudGetTextureSize(tid)
				als.ui.texture._loaded[tostring(filename)] = {
					filename = filename,
					id = tid,
					width = tw,
					height = th,
					clamped = clamped or false,
				}
			end

			local tex = als.ui.texture._loaded[tostring(filename)]

			local t = als.ui.guiObject.add(left, top, width or tex.width, height or tex.height, als.ui.texture.draw)
			t.texture = tex
			t.scaleMode = scaleMode or -1
			setmetatable(t, {__index = als.ui.texture})

			return t
		end,

		draw = function(t)
			ShroudDrawTexture(t.rect.left, t.rect.top, t.rect.width, t.rect.height, t.texture.id, t.scaleMode)
		end,

		clone = function(texture)
			local t = als.ui.guiObject.add(texture.rect.left, texture.rect.top, texture.rect.width, texture.rect.height, texture.guiDrawFunc)
			t.texture = texture.texture
			t.scaleMode = texture.scaleMode
			t.shownInScene = texture.shownInScene
			t.shownInLoadScreen = texture.shownInLoadScreen
			t.zIndex = texture.zIndex

			setmetatable(t, {__index = als.ui.texture})
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
			local b = als.ui.guiObject.add(left, top, width, height, als.ui.guiButton.draw)
			b.caption = caption or ""
			b.tooltip = tooltip or ""
			-- b.mode = false -- mode = repeat, click, off/false

			if type(texture) == "table" and texture.texture and texture.texture.id then
				b.texture = texture
			else
				print("als.ui.guiButton: "..type(texture)..": "..tostring(texture).." is not a texture object.")
				return nil
			end

			setmetatable(b, {__index = als.ui.guiButton})

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
			if not als.ui.shortcut.list[action][tostring(key)] then
				als.ui.shortcut.list[action][tostring(key)] = {}
			end

			if type(callback) == "string" then
				callback = als.ui.command.list[callback].callback
			end

			local id = #als.ui.shortcut.list[action][key] + 1
			local index = { action = action, key = key, id = id }
			als.ui.shortcut.list[action][key][id] = {
				_index = index,
				key = key,
				keysHeld = keys,
				callback = callback,
			}

			if type(callback) == string then
				if als.ui.command.list[callback].shortcut then
					als.ui.shortcut.remove(als.ui.command.list[callback].shortcut)
				end
				als.ui.command.list[callback].shortcut = index
			end

			return index
		end,

		remove = function(index)
			als.ui.shortcut.list[index.action][index.key][index.id] = nil
			if #als.ui.shortcut.list[index.action][index.key] == 0 then
				als.ui.shortcut.list[index.action][index.key] = nil
			end
		end,

		invoke = function(index)
			als.ui.shortcut.list[index.action][index.key][index.id].callback()
		end,
	},

	command = {
		list = {},
		add = function(command, callback)
			als.ui.command.list[tostring(command)] = {
				_command = command,
				callback = callback,
				shortcut = nil,
				channel = nil,
				sender = als.player.name,
				receiver = nil,
			}
			return command
		end,

		remove = function(command)
			if als.ui.command.list[command].shortcut then
				als.ui.shortcut.remove(als.ui.command.list[command].shortcut)
			end
			als.ui.command.list[command] = nil
		end,

		invoke = function(command, ...)
			if ... then
				als.ui.command.list[command].callback(nil, unpack(...))
			else
				als.ui.command.list[command].callback()
			end
		end,

		restrict = function(command, channel, sender, receiver)
			if als.ui.command[command] then
				als.ui.command[command].channel = channel
				als.ui.command[command].sender = sender
				als.ui.command[command].receiver = receiver
			end
		end
	},

	verbosity = 0,
	consoleLog = function(message, verbosity)
		if not verbosity then
			verbosity = 0
		end

		if als.ui.verbosity >= verbosity then
			for l in message:gmatch("[^\n]+") do
				ShroudConsoleLog(l)
			end
		end
	end,
}

--setmetatable(als.ui.timer, {__index = als.ui.timer.list})
setmetatable(als.ui.label, { __index = als.ui.guiObject})
setmetatable(als.ui.texture, { __index = als.ui.guiObject})
setmetatable(als.ui.guiButton, { __index = als.ui.guiObject})


-- internal

als.ui_initialized = false
als.ui_client_ts = os.time()
als.ui_client_frame = 0
als.ui_guiObjectList = {}
als_ui_drawListChanged = false

local ui_drawInScene = {}
local ui_drawInLoadScreen = {}
local ui_callback_queue = {}

local ui_inventory_quantity = {}
local ui_inventory_durability = {}

local function ui_getPlayerName()
	if als.player.caption ~= ShroudGetPlayerName() then
		als.player.caption = ShroudGetPlayerName()
		als.player.name = als.player.caption
		als.player.flag = ""
		als.player.isPvp = false

		if als.player.name:byte(#als.player.name) == 93 then
			als.player.name, als.player.flag = als.player.name:match("^(.-)(%[.-%])$")
			als.player.isPvp = als.player.flag and als.player.flag:find("PVP") ~= nil
			als.player.isAfk = als.player.flag and als.player.flag:find("AFK") ~= nil
			als.player.isGod = als.player.flag and als.player.flag:find("God") ~= nil
		end

		als.ui.handler.invoke("_playerChanged", "caption")
	end
end

local function ui_getPlayerChange()
	local loc = { x = ShroudPlayerX, y = ShroudPlayerY, z = ShroudPlayerZ, scene = als.scene }
	local isMoving = loc.x ~= als.player.location.x or loc.y ~= als.player.location.y or loc.z ~= als.player.location.z

	if isMoving then
		als.player.lastMoved = os.time()
	end

	local isStill = os.time() - als.player.lastMoved > 5
	local invoke = isStill ~= als.player.isStill or isMoving ~= als.player.isMoving
	als.player.isMoving = isMoving
	als.player.isStill = isStill
	als.player.location = loc

	if invoke then
		if isMoving then
			als.ui.handler.invoke("_playerMoveStart") -- deprecated
			als.ui.handler.invoke("_playerMove", "start", loc)
			als.ui.handler.invoke("_playerChanged", "moving")
		elseif isStill then
			als.ui.handler.invoke("_playerIsStill") -- deprecated?
			als.ui.handler.invoke("_playerMove", "stillness", loc) -- hm?
			als.ui.handler.invoke("_playerChanged", "stillness")
		else
			als.ui.handler.invoke("_playerMoveStop") -- deprecated
			als.ui.handler.invoke("_playerMove", "stop", loc)
			als.ui.handler.invoke("_playerChanged", "standing")
		end
	end

	if isMoving then
		als.ui.handler.invoke("_playerMove", "move", loc)
		als.ui.handler.invoke("_playerChanged", "location", loc)
	end

	local health = { max = ShroudGetStatValueByNumber(30), current = ShroudPlayerCurrentHealth, percentage = 0 }
	local focus =  { max = ShroudGetStatValueByNumber(27), current = ShroudPlayerCurrentFocus, percentage = 0 }

	health.percentage = health.current / health.max
	focus.percentage = focus.current / focus.max
	invoke = als.player.health.current ~= health.current or als.player.focus.current ~= focus.current

	if invoke then
		als.ui.handler.invoke("_playerDamage", health, focus)
		als.ui.handler.invoke("_playerChanged", "damage", health, focus)
	end

	als.player.health = health
	als.player.focus = focus
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

	als.player.inventory = ret1
	ui_inventory_quantity = ret2

	if cs.n > 0 then
		cs.n = nil
		als.ui.handler.invoke("_playerInventory", cs)
		als.ui.handler.invoke("_playerChanged", "inventory", cs)
	end
end

local function ui_getSceneName()
	if als.scene.name ~= ShroudGetCurrentSceneName() then
		als.scene.name = ShroudGetCurrentSceneName()
		als.scene.maxPlayer = ShroudGetCurrentSceneMaxPlayerCount()
		als.scene.isPvp = ShroudGetCurrentSceneIsPVP()
		als.scene.isPot = ShroudGetCurrentSceneIsPOT()
		als.scene.timeStarted = os.time()
		als.scene.levelCap = ShroudGetSceneCap()
		als.ui.handler.invoke("_sceneChanged")
	end
end

local function ui_initialize()
	als.client.api.luaPath = ShroudLuaPath
	als.client.api.luaVersion = _G._MOONSHARP.luacompat

	for i,v in next, _G do
		if i:find("^Shroud") then als.client.api.list[tostring(i)] = type(v) end
	end

	als.client.timeToLoad = als.ui_client_ts - als.client.timeStarted
	als.client.screen.width = ShroudGetScreenX()
	als.client.screen.height = ShroudGetScreenY()
	als.client.screen.isFullScreen = ShroudGetFullScreen()
	als.client.screen.aspectRatio = als.client.screen.width / als.client.screen.height
	als.client.screen.pxptRatio = als.client.screen.height / 1080

	for i=0, ShroudGetStatCount()-1, 1 do
		local name = ShroudGetStatNameByNumber(i)
		als.client._statEnum[tostring(name)] = i
		als.client._statEnum[i] = name
		als.client._statDescr[i] = ShroudGetStatDescriptionByNumber(i)
	end

	ui_getSceneName()
	ui_getPlayerName()
	ui_getPlayerChange()
	ui_getPlayerInventory()

	ShroudRegisterPeriodic("ui_timer_internal", "ui_timer_internal", 0.01, true)
	ShroudRegisterPeriodic("ui_timer_user", "ui_timer_user", 0.120, true)
end

local function ui_buildDrawList()
	local list = als.ui_guiObjectList
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
		for _,h in next, als.ui.handler.list do
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
		als.player.xp.producer = ShroudGetPooledProducerExperience()
		als.player.xp.adventurer = ShroudGetPooledAdventurerExperience()

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
		if wx ~= als.client.window.paperdoll.left or wy ~= als.client.window.paperdoll.top then
			als.client.window.paperdoll.left, als.client.window.paperdoll.top = wx, wy
			als.ui.handler.invoke("_clientWindow", "moved", als.client.window.paperdoll)
		end
	end

	if wo ~= als.client.window.paperdoll.open then
		als.client.window.paperdoll.open = wo
		if wo then
			als.ui.handler.invoke("_clientWindow", "opened", als.client.window.paperdoll)
		else
			als.ui.handler.invoke("_clientWindow", "closed", als.client.window.paperdoll)
		end
	end
end

function ui_timer_user()
	local ts = os.time()

	for _,t in next, als.ui.timer.list do
		if t.enabled and ts >= t.time then
			if t.interval then
				t.time = ts + t.interval
			else
				als.ui.timer.list[t._index] = nil
			end
			--local cts = os.time()
			if t.callback(unpack(t.userdata)) then als.ui.timer.list[t._index] = nil end
			-- experimental
			--if als.ui.timer.list[t._index] and (not als.client.isHitching or als.client.isLoading) and os.time() - cts >= 0.1 then
			--	print("hanging timer: "..t._index.." -> disabled")
			--	als.ui.timer.list[t._index].enabled = false
			--	als.ui.timer.list[t._index].hanging = true
			--end
		end
	end
end


-- shroud callbacks
local button_ts = {} -- howto: clean up
local button_ts2 = {}

function ShroudOnConsoleInput(channel, sender, message)
	ui_queue(function(...)
		-- handle player flag changes
		if (channel == "Story" or channel == "System") and message:find("PvP") then
			ui_getPlayerName()
		end

		-- parse message
		local src, dst, msg = message:match("^(.-) to (.-) %[.-:%s*(.*)$")

		if sender == "" then
			sender = src
		end

		if sender == "" then
			sender = als.player.name
		end

		if msg:byte() == 92 or msg:byte() == 95 or msg:byte() == 33 then
			local cmd, tail = msg:match("^[\\_!](%w+)%s*(.*)$")
			local source = {
				channel = channel,
				sender = sender,
				receiver = dst,
			}

			if als.ui.command.list[cmd] then
				if not als.ui.command.list[cmd].sender or als.ui.command.list[cmd].sender == sender
						and not als.ui.command.list[cmd].channel or als.ui.command.list[cmd].channel == channel
						and not als.ui.command.list[cmd].receiver or als.ui.command.list[cmd].receiver == dst
						then
					local arg = {}

					for a in tail:gmatch("%S+") do
						arg[#arg + 1] = a
					end

					arg.n = #arg
					als.ui.command.list[cmd].callback(source, unpack(arg))
				end
			else
				als.ui.handler.invoke("_consoleCommand", source, cmd, tail)
			end
		else
			als.ui.handler.invoke("_consoleInput", channel, sender, dst, msg)
		end
	end, channel, sender, message)
end

function ShroudOnGUI()
	local ts = os.time()
	local isHitching = ts - als.ui_client_ts >= 2
	local isLoading = ts - als.ui_client_ts >= 5

	if isHitching and als.client.isHitching ~= isHitching then
		als.client.isHitching = isHitching
		als.ui.handler.invoke("_clientIsHitching")
	end

	if isLoading and als.client.isLoading ~= isLoading then
		als.client.isLoading = isLoading
		als.ui.handler.invoke("_clientIsLoading")
	end

	if not isHitching then
		local list = ui_drawInScene

		if isLoading then
			list = ui_drawInLoadScreen
		end

		for _,o in next, list do
			--[[if o.caption then
				ShroudGUILabel(o.rect.left, o.rect.top, o.rect.width, o.rect.height, o.caption)
			elseif o.texture then
				ShroudDrawTexture()
			else
				ShroudButton()
			end]]
			--als.ui.label.draw(o)
			o:guiDrawFunc()
			--if os.time() - ts > 0.01 then print("gui bail out"); break end
			if os.time() - ts > 0.01 then
				break
			end
		end
	end
end

function ShroudOnStart()
	ShroudUseLuaConsoleForPrint(true)
	ShroudConsoleLog(_G._MOONSHARP.banner)
	ShroudConsoleLog("LUA Version: ".._G._MOONSHARP.luacompat)
	als.client.isLoggedIn = true
end

function ShroudOnUpdate()
	local ts = os.time()

	-- init
	if not als.ui_initialized then
		if not ShroudServerTime then
			return
		end -- shroud Api not ready, yet

		ShroudConsoleLog("Shroud Api Ready. ServerTime: "..ShroudServerTime)
		ui_initialize()
		als.ui_initialized = true
		als.ui.handler.invoke("_init")
		als.ui.handler.invoke("_start")
	end

	-- client stats
	als.ui_client_frame = als.ui_client_frame + 1;

	if ts - als.ui_client_ts >= 1 then
		if als.client.accuracy > 10 then
			--ui_getSceneName()
			ui_getPlayerName()
			als.client.isLoading = false
			als.scene.timeToLoad = als.client.accuracy
		end

		als.client.timeInGame = ShroudTime
		als.client.timeDelta =	ShroudDeltaTime
		als.client.fps = als.ui_client_frame
		als.ui_client_frame = 0
		als.client.accuracy = ts - als.ui_client_ts - 1
		als.ui_client_ts = ts
		als.client.isHitching = false
		als.scene.timeInScene = ts - als.scene.timeStarted
	end

	-- check key up
	for ku,r in next, als.ui.shortcut.list.pressed do
		if ShroudGetOnKeyUp(ku) then
			for _,f in next, r do
				local invoke = true

				for _,kd in next, f.keysHeld do
					invoke = invoke and ShroudGetKeyDown(kd)
				end

				if invoke then
					f.callback()
				end
			end
		end
	end

	-- check key held/repeat
	for ku,r in next, als.ui.shortcut.list.watch do
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
		als.client.mouse.button[i] = nil
		if ShroudGetOnKeyDown(mb) then
			button_ts[i] = os.time()
			als.client.mouse.button[i] = "down"
		elseif ShroudGetKeyDown(mb) then
			if os.time() - button_ts[i] >= 0.25 then
				als.client.mouse.button[i] = "held"
			end
		elseif ShroudGetOnKeyUp(mb) then
			als.client.mouse.button[i] = "up"
			if os.time() - button_ts[i] <= 0.25 then
				if button_ts2[i] and os.time() - button_ts2[i] <= 0.25 then
					als.ui.handler.invoke("_mouseButton", "dblclicked", i, ShroudMouseX, ShroudMouseY)
					button_ts2[i] = nil
				else
					als.ui.handler.invoke("_mouseButton", "clicked", i, ShroudMouseX, ShroudMouseY)
					button_ts2[i] = os.time()
				end
			end
		end
	end

	if als.client.mouse.x ~= ShroudMouseX or als.client.mouse.y ~= ShroudMouseY then
		als.client.mouse.x, als.client.mouse.y = ShroudMouseX, ShroudMouseY
		als.ui.handler.invoke("_mouseMove", als.client.mouse.button, als.client.mouse.x, als.client.mouse.y)
	end

	for i,mb in next, als.client.mouse.button do
		als.ui.handler.invoke("_mouseButton", mb, i, als.client.mouse.x, als.client.mouse.y)
	end

	als.ui.handler.invoke("_update")

	if als_ui_drawListChanged then
		als_ui_drawListChanged = false
		ui_buildDrawList()
	end
end


-- implement other ShroudOn... to allow other scripts
function ShroudOnLogout()
	als.client.isLoggedIn = false
end

function ShroudOnMouseClick()
end

function ShroudOnMouseOut()
end

function ShroudOnMouseOver()
end

function ShroudOnSceneLoaded(SceneName)
	ui_getSceneName()
	als.client.isLoggedIn = true
end

function ShroudOnSceneUnloaded()
	--als.scene.name = ""
end
