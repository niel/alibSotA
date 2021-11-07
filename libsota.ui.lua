-- libsota.ui by Catweazle Waldschrath
-- depends on libsota.0.5.x

--[[
 * libsota.ui.lua
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


ui.rect = function(left, top, width, height)
	local self = {
		left = left * client.screen.pxptRatio,
		top = top * client.screen.pxptRatio,
		width = width * client.screen.pxptRatio,
		height = height * client.screen.pxptRatio,
		x1 = left,
		y1 = top,
		x2 = left + width,
		y2 = top + height,
		z = 0,
	}

	self.hittest = function(x, y)
		return x > self.left and y > self.top and x < self.left + self.width and y < self.top + self.height
	end

	self.pxHittest = function(x, y)
		return x > self.x1 and y > self.y1 and x < self.x2 and y < self.y2
	end

	self.moveTo = function(x, y)
		self.left = x
		self.top = y
	end

	self.moveBy = function(dx, dy)
		self.left = self.left + x
		self.top = self.top + y
	end

	self.resizeTo = function(w, h)
		self.width = w
		self.height = h
	end

	self.resizeBy = function(dw, dh)
		self.width = self.width + dw
		self.height = self.height + dh
	end

	return self
end

ui.container = {
	new = function(rect)
		local self = {
			list = {},
			rect = rect,
		}
		setmetatable(self, {__index = ui.container})
		return self
	end,

	add = function(self, name, object, left, top, width, height)
		self.list[tostring(name)] = object
		object.name = name
		object.clientRect = {
			left = left or 0,
			top = top or 0,
			width = width or object.rect.width,
			height = height or object.rect.height,
			z = table.maxn(self.list)
		}
		self:refresh()
	end,

	get = function(name)
		return self.list[tostring(name)]
	end,

	remove = function(name)
		self.list[tostring(name)]:remove()
		self.list[tostring(name)] = nil
	end,

	refresh = function(self)
		for _,o in next, self.list do
			--[[o.rect.left = self.rect.left + o.clientRect.left
			o.rect.top = self.rect.top + o.clientRect.top
			o.rect.width = o.clientRect.width
			o.rect.height = o.clientRect.height
			]]
			o:moveTo(self.rect.left + o.clientRect.left, self.rect.top + o.clientRect.top)
			o:resizeTo(o.clientRect.width, o.clientRect.height)
		end
	end,

	zIndex = function(self, zIndex)
		if zIndex then
		print(zIndex)
			self.rect.z = zIndex
			for _,o in next, self.list do
				o:zIndex(zIndex + o.clientRect.z)
			end
		end
		return self.rect.z
	end,

	visible = function(self, visible)
		for _,o in next, self.list do
			o:visible(visible)
		end
	end,

	moveTo = function(self, x, y)
		self.rect.left = x
		self.rect.top = y
		self:refresh()
	end,

	moveBy = function(self, x, y)
		self.rect.left = self.rect.left + x
		self.rect.top = self.rect.top + y
		self:refresh()
	end,

	resizeTo = function(self, w, h)
		self.rect.width = w
		self.rect.height = h
		self:refresh()
	end,

	resizeBy = function(self, w, h)
		self.rect.width = self.rect.width + w
		self.rect.height = self.rect.height + h
		self:refresh()
	end,
}

ui.titlebar = {
	_new = function(self, caption, icon)
		return self:new(caption, icon)
	end,

	new = function(caption, icon)
		local lbl = ui.text(caption:style({ size = 14, bold = true }))
		local ico = ui.image(icon)
		local self = ui.container.new({left=0, top=0, width=lbl.rect.width, height=32})
		lbl:zIndex(-1)
		ico:zIndex(-1)
		self:add("_caption", lbl, 32, 2, self.rect.width, 32)
		self:add("_icon", ico, 2, 2, 24, 24)
		return self
	end,

	caption = function(self, caption)
		if caption then
			self.list["_caption"].caption = caption
		end
		return self.list["_caption"].caption
	end,

	icon = function(self, icon)
		if icon then
			self.list["_icon"] = icon
		end
		return self.list["_icon"]
	end,
}
setmetatable(ui.titlebar, {__index = ui.container, __call = ui.titlebar._new})

ui.button = {
	_new = function(self, caption)
		return self:new(caption)
	end,

	new = function(caption)
		local lbl = ui.text(caption:style({ size = 14, bold = true }))
		local ico = ui.image("share/libsota/border3.png")
		local self = ui.container.new({left=0, top=0, width=lbl.rect.width, height=32})
		self:add("_caption", lbl, 2, 2, self.rect.width, 32)
		self:add("_icon", ico, 0, 0, self.rect.width, 32)
		return self
	end,

	caption = function(self, caption)
		if caption then
			self.list["_caption"].caption = caption
		end
		return self.list["_caption"].caption
	end,

	icon = function(self, icon)
		if icon then
			self.list["_icon"] = icon
		end
		return self.list["_icon"]
	end,
}
setmetatable(ui.button, {__index = ui.container, __call = ui.button._new})

ui.window = {
	background = function(self, object)
		--self.list["_background"] = object
		--object:moveTo(self.rect.left, self.rect.top)
		--object:resizeTo(self.rect.width, self.rect.width)
		self:add("background", object, 0, 0, self.rect.width, self.rect.height)
		object:zIndex(-2)
		self:refresh()
	end,
}
setmetatable(ui.window, {__index = ui.container})

ui.application = {
	new = function(name, icon, description)
		ui.shell.list[tostring(name)] = {
			list = {},
			name = name,
			description = description,
			icon = ui.texture.add(0, 0, icon, true),
			onActivate = nil,
			onDeactivate = nil,
		}
		setmetatable(ui.shell.list[tostring(name)], {__index = ui.application})

		local self = ui.shell.list[tostring(name)]

		local ui_tex = ui.texture.add
		self.texture = function(left, top, filename, clamped, scaleMode, width, height)
			local tex = ui_tex(left, top, filename, clamped, scaleMode, width, height)
			self.list[#self.list + 1] = tex
			return tex
		end

		ui.texture.add = self.texture
		ui.image = function(filename, scaleMode)
			return ui_tex(0, 0, filename, true, scaleMode)
		end

		local ui_label = ui.label.add
		self.label = function(left, top, width, height, caption)
			local lbl = ui_label(left, top, width, height, caption)
			self.list[#self.list + 1] = lbl
			return lbl
		end

		ui.label.add = self.label
		ui.text = function(text)
			local r = text:rect()
			return ui.label.add(r.left, r.top, r.width, r.height, text)
		end

		return ui.shell.list[tostring(name)]
	end,

	remove = function(self)
		for _,o in next, self.list do
			o:remove()
		end
	end,

	createWindow = function(self, name, rect)
		self.list[tostring(name)] = {
			typeName = "window",
			list = {},
			name = name,
			icon = self.icon,
			rect = rect,
			onMouseMove = nil,
			onMouseButton = nil,
			onMouseEnter = nil,
			onMouseLeave = nil,
		}
		rect.z = table.maxn(self.list) * 10
		setmetatable(self.list[tostring(name)], {__index = ui.window})
		return self.list[tostring(name)]
	end,
}

ui.shell = {
	list = {},
	active = nil,
	draging = nil,
	hover = nil,
	activate = function(name)
		local app = ui.shell.list[tostring(name)]
		if app and app.onActivate then app.onActivate() end
	end,

	deactivate = function(name)
		local app = ui.shell.list[tostring(name)]
		if app then
			if app.onDeactivate then app.onDeactivate() end
			for _,o in app.list do
				o:remove()
			end
		end
	end,

	onMouseMove = function(button, x, y)
		if ui.shell.hover and not ui.shell.hover.object.rect.hittest(x, y) then
			if ui.shell.hover.object.onMouseLeave then ui.shell.hover.object.onMouseLeave() end
			ui.shell.hover = nil
		end
		for _,a in next, ui.shell.list do
			for _,o in next, a.list do
				if o.typeName == "window" then
					if o.rect.hittest(x, y) then
						if not ui.shell.hover then
							ui.shell.hover = {
								object = o,
								_x = x - o.rect.left,
								_y = y - o.rect.top,
							}
							if o.onMouseEnter then o.onMouseEnter() end
						end
						if o.onMouseMove then o.onMouseMove(button, x - o.rect.left, y - o.rect.top) end
					end
				end
			end
		end
	end,

	onMouseButton = function(state, button, x, y)
		if ui.shell.draging and state == "held" and button == 1 then
			local f = ui.shell.draging
			f.object:moveTo(x - f._x, y - f._y)
		elseif ui.shell.draging and state == "up" and button == 1 then
			ui.shell.draging = nil
		end

		for _,a in next, ui.shell.list do
			for _,o in next, a.list do
				if o.typeName == "window" then
					if o.rect.hittest(x, y) then
						if state == "down" and button == 1 then
							if not ui.shell.active then
								ui.shell.active = {
									object = o,
									_x = x - o.rect.left,
									_y = y - o.rect.top,
								}
								ui.shell.active.object:zIndex(ui.shell.active.object:zIndex() + 100)
							end
							if o ~= ui.shell.active.object then
								ui.shell.active.object:zIndex(ui.shell.active.object:zIndex() - 100)
								ui.shell.active = {
									object = o,
									_x = x - o.rect.left,
									_y = y - o.rect.top,
								}
								ui.shell.active.object:zIndex(ui.shell.active.object:zIndex() + 100)
							end
							ui.shell.draging = {
								object = o,
								_x = x - o.rect.left,
								_y = y - o.rect.top,
							}
						end
						if o.onMouseButton then	o.onMouseButton(state, button, x - o.rect.left, y - o.rect.top) end
					end
				end
			end
		end
	end,

	onStart = function()
		for _,a in next, ui.shell.list do
			if a.onActivate then a.onActivate() end
		end
	end
}


function ShroudOnStart()
	ui.onInit(function()
		--[[ starter für später
		local texheight = 450 * client.screen.pxptRatio
		local tex = ui.texture.add(0, (client.screen.height - texheight) / 2, "share/libsota/winbg.png", true, -1, 48, texheight)
		tex:visible(true)
		local ico = ui.texture.add(4, tex.rect.top + 8, "share/libsota/lua.png", true, -1, 32, 32)
		ico:visible(true)
		]]
		local texsize = 36 * client.screen.pxptRatio
		local slotsize = 40 * client.screen.pxptRatio
		local tex = ui.texture.add(client.screen.width - (9 * slotsize), 2, "share/libsota/lua.png", true, -1, texsize, texsize)
		tex:visible(true)
	end)

	ui.onMouseMove(ui.shell.onMouseMove)
	ui.onStart(ui.shell.onStart)
	ui.onMouseButton(ui.shell.onMouseButton)

end -- ShroudOnStart

-- implement other ShroudOn... to allow other scripts
function ShroudOnConsoleInput()
end

function ShroudOnGUI()
end

function ShroudOnLogout()
	--client.isLoggedIn = false
end

function ShroudOnSceneLoaded(SceneName)
	--scene.name = SceneName
	--client.isLoggedIn = true
end

function ShroudOnSceneUnloaded()
	--scene.name = ""
end

function ShroudOnUpdate()
end
