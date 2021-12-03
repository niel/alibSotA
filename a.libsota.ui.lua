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


als.ui.rect = function(left, top, width, height)
	local self = {
		left = left * als.client.screen.pxptRatio,
		top = top * als.client.screen.pxptRatio,
		width = width * als.client.screen.pxptRatio,
		height = height * als.client.screen.pxptRatio,
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
		self.left = self.left + dx
		self.top = self.top + dy
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

als.ui.container = {
	new = function(rect)
		local self = {
			list = {},
			rect = rect,
		}
		setmetatable(self, {__index = als.ui.container})

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

als.ui.titlebar = {
	_new = function(self, caption, icon)

		return self:new(caption, icon)
	end,

	new = function(caption, icon)
		local lbl = als.ui.text(caption:style({ size = 14, bold = true }))
		local ico = als.ui.image(icon)
		local self = als.ui.container.new({ left=0, top=0, width=lbl.rect.width, height=32})
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
setmetatable(als.ui.titlebar, { __index = als.ui.container, __call = als.ui.titlebar._new})

als.ui.button = {
	_new = function(self, caption)

		return self:new(caption)
	end,

	new = function(caption)
		local lbl = als.ui.text(caption:style({ size = 14, bold = true }))
		local ico = als.ui.image("share/libsota/border3.png")
		local self = als.ui.container.new({ left=0, top=0, width=lbl.rect.width, height=32})
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
setmetatable(als.ui.button, { __index = als.ui.container, __call = als.ui.button._new})

als.ui.window = {
	background = function(self, object)
		--self.list["_background"] = object
		--object:moveTo(self.rect.left, self.rect.top)
		--object:resizeTo(self.rect.width, self.rect.width)
		self:add("background", object, 0, 0, self.rect.width, self.rect.height)
		object:zIndex(-2)
		self:refresh()
	end,
}
setmetatable(als.ui.window, { __index = als.ui.container})

als.ui.application = {
	new = function(name, icon, description)
		als.ui.shell.list[tostring(name)] = {
			list = {},
			name = name,
			description = description,
			icon = als.ui.texture.add(0, 0, icon, true),
			onActivate = nil,
			onDeactivate = nil,
		}
		setmetatable(als.ui.shell.list[tostring(name)], { __index = als.ui.application})

		local self = als.ui.shell.list[tostring(name)]

		local ui_tex = als.ui.texture.add
		self.texture = function(left, top, filename, clamped, scaleMode, width, height)
			local tex = ui_tex(left, top, filename, clamped, scaleMode, width, height)
			self.list[#self.list + 1] = tex

			return tex
		end

		als.ui.texture.add = self.texture
		als.ui.image = function(filename, scaleMode)
			return ui_tex(0, 0, filename, true, scaleMode)
		end

		local ui_label = als.ui.label.add
		self.label = function(left, top, width, height, caption)
			local lbl = ui_label(left, top, width, height, caption)
			self.list[#self.list + 1] = lbl

			return lbl
		end

		als.ui.label.add = self.label
		als.ui.text = function(text)
			local r = text:rect()

			return als.ui.label.add(r.left, r.top, r.width, r.height, text)
		end

		return als.ui.shell.list[tostring(name)]
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
		setmetatable(self.list[tostring(name)], {__index = als.ui.window})

		return self.list[tostring(name)]
	end,
}

als.ui.shell = {
	list = {},
	active = nil,
	dragging = nil,
	hover = nil,
	activate = function(name)
		local app = als.ui.shell.list[tostring(name)]
		if app and app.onActivate then
			app.onActivate()
		end
	end,

	deactivate = function(name)
		local app = als.ui.shell.list[tostring(name)]
		if app then
			if app.onDeactivate then
				app.onDeactivate()
			end

			for _,o in app.list do
				o:remove()
			end
		end
	end,

	onMouseMove = function(button, x, y)
		if als.ui.shell.hover and not als.ui.shell.hover.object.rect.hittest(x, y) then
			if als.ui.shell.hover.object.onMouseLeave then als.ui.shell.hover.object.onMouseLeave() end
			als.ui.shell.hover = nil
		end

		for _,a in next, als.ui.shell.list do
			for _,o in next, a.list do
				if o.typeName == "window" then
					if o.rect.hittest(x, y) then
						if not als.ui.shell.hover then
							als.ui.shell.hover = {
								object = o,
								_x = x - o.rect.left,
								_y = y - o.rect.top,
							}

							if o.onMouseEnter then
								o.onMouseEnter()
							end
						end

						if o.onMouseMove then
							o.onMouseMove(button, x - o.rect.left, y - o.rect.top)
						end
					end
				end
			end
		end
	end,

	onMouseButton = function(state, button, x, y)
		if als.ui.shell.dragging and state == "held" and button == 1 then
			local f = als.ui.shell.dragging
			f.object:moveTo(x - f._x, y - f._y)
		elseif als.ui.shell.dragging and state == "up" and button == 1 then
			als.ui.shell.dragging = nil
		end

		for _,a in next, als.ui.shell.list do
			for _,o in next, a.list do
				if o.typeName == "window" then
					if o.rect.hittest(x, y) then
						if state == "down" and button == 1 then
							if not als.ui.shell.active then
								als.ui.shell.active = {
									object = o,
									_x = x - o.rect.left,
									_y = y - o.rect.top,
								}

								als.ui.shell.active.object:zIndex(als.ui.shell.active.object:zIndex() + 100)
							end

							if o ~= als.ui.shell.active.object then
								als.ui.shell.active.object:zIndex(als.ui.shell.active.object:zIndex() - 100)
								als.ui.shell.active = {
									object = o,
									_x = x - o.rect.left,
									_y = y - o.rect.top,
								}

								als.ui.shell.active.object:zIndex(als.ui.shell.active.object:zIndex() + 100)
							end

							als.ui.shell.dragging = {
								object = o,
								_x = x - o.rect.left,
								_y = y - o.rect.top,
							}
						end

						if o.onMouseButton then
							o.onMouseButton(state, button, x - o.rect.left, y - o.rect.top)
						end
					end
				end
			end
		end
	end,

	onStart = function()
		for _,a in next, als.ui.shell.list do
			if a.onActivate then a.onActivate() end
		end
	end
}


function ShroudOnStart()
	als.ui.onInit(function()
		--[[ starter für später
		local texheight = 450 * als.client.screen.pxptRatio
		local tex = als.ui.texture.add(0, (als.client.screen.height - texheight) / 2, "share/libsota/winbg.png", true, -1, 48, texheight)
		tex:visible(true)
		local ico = als.ui.texture.add(4, tex.rect.top + 8, "share/libsota/lua.png", true, -1, 32, 32)
		ico:visible(true)
		]]
		local texsize = 36 * als.client.screen.pxptRatio
		local slotsize = 40 * als.client.screen.pxptRatio
		local tex = als.ui.texture.add(als.client.screen.width - (9 * slotsize), 2, "share/libsota/lua.png", true, -1, texsize, texsize)
		tex:visible(true)
	end)

	als.ui.onMouseMove(als.ui.shell.onMouseMove)
	als.ui.onStart(als.ui.shell.onStart)
	als.ui.onMouseButton(als.ui.shell.onMouseButton)

end -- ShroudOnStart

-- implement other ShroudOn... to allow other scripts
function ShroudOnConsoleInput()
end

function ShroudOnGUI()
end

function ShroudOnLogout()
end

function ShroudOnMouseClick()
end

function ShroudOnMouseOut()
end

function ShroudOnMouseOver()
end

function ShroudOnSceneLoaded(SceneName)
end

function ShroudOnSceneUnloaded()
end

function ShroudOnUpdate()
end
