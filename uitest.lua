local app

function test_activate()
	
	win = app:createWindow("win1", ui.rect(300, 300, 600, 300))
	
	win.onMouseMove = function(button, x, y)
		--print(string.format("%d %d", x, y))
		print(x,y)
	end
	win.onMouseButton = function(state, button, x, y)
		print(string.format("%s %d: %d %d", state, button, x, y))
	end
	
	win.onMouseEnter = function()
		print("win1 mouseEnter")
	end
	win.onMouseLeave = function()
		print("win1 mouseLeave")
	end
	
	win:background(ui.image("share/libsota/winbg.png"))


	win:add("tb1", ui.titlebar.new("Fenstertitel", "share/test/fish.png"))

	win:add("img1", ui.image("share/test/dog.jpg"), 200, 30, 200, 240)
	win:add("txt1", ui.text("Hallo Welt"), 10, 40)

	win:add("img2", ui.image("share/libsota/border2.png"), 10, 80, 180, 30)
	win:add("txt2", ui.text("Textinput"), 12, 82, 176, 26)

	win:add("img3", ui.image("share/libsota/border2.png"), 10, 120, 180, 30)
	win:add("txt3", ui.text("Knopf"), 12, 122, 176, 26)
	
	win:add("btn4", ui.button.new("Clickbutton"), 10, 160)

	win:visible(true)
	
	
	win2 = app:createWindow("win2", ui.rect(150, 150, 300, 300))
	win2:background(ui.image("share/libsota/winbg2.png"))
	win2:add("tb2", ui.titlebar.new("Fenster 2", "share/libsota/lua.png"))	
	win2:visible(true)
	win2.onMouseEnter = function() print("win2 enter") end
	win2.onMouseLeave = function() print("win2 leave") end


	win3 = app:createWindow("win3", ui.rect(50, 50, 300, 300))
	win3:background(ui.image("share/libsota/winbg2.png"))
	win3:add("tb3", ui.titlebar.new("Fenster 3", "share/libsota/lua.png"))	
	win3:visible(true)

end

function test_deactivate()
	print("Goodbye")
end




-- implement Shroud calls
function ShroudOnConsoleInput() end
function ShroudOnGUI() end
function ShroudOnUpdate() end
function ShroudOnStart()
	app = ui.application.new("test", "share/libsota/lua.png", "test für ui")
	app.onActivate = test_activate
	app.onDeactivate = test_deactivate
end

