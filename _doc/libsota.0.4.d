needs QA 889 (ShroudUseLuaConsoleForPrint(true) commented out)

cleaned up libsota... and done some optimizations/polish
libsota.util contains all functions appearing in the global namespace like labelCreate and such. They are compatible to libsota.0.3.x
i am working on libsota.ui a simple window class, a container for labels

i made the decision to move the "gui" parts to an extra file, because there are already lua libs for graphical ui out there. may they can be used, saves a lot of work. And keep libsota small.

there are new events:
onPlayerMoveStart - invoked when the player starts to move
onPlayerMoveStop - invoked when the player stops moving
onPlayerIsStill - invoked when player has stillness bonus. (may i rename it to PlayerStandStill ... sounds better)
onPlayerDamage(health, focus) - invoked when currentHealth or currentFocus are changed. The parameter health and focus contains the _new_ values. player.health and player.focus the _old_ ones (may i turn it around)
onPlayerChanged - invoked when name, flagging, moving, damage or stillness occur (sometimes it is simpler to only have one callback). name changed from onPlayerChange to onPlayerChanged. Because it occurs after change nit during
onSceneChanged - name change, the same as onPlayerChanged

player:
isMoving = false, - true when player is moving
isStill = false, - true when player has stillness bonus active
lastMoved = os.time(), - timestamp when player stopped moving
location = {}, - table containing: x, y, z and scene object
health = {}, - table containing: current, max and percentage values of health (total was renamd to max to use the same words like the shroud-api. percentage can be used for a progress bar)
focus = {}, - table containing: current, max and percentage values of health (total was renamd to max to use the same words like the shroud-api. percentage can be used for a progress bar)

new objects:
ui.keystrokes:
table add - binds a keystroke to a callback/function. ([keyHeld],[keyHeld], ..., keyUp, {func callback | string command})
remove - removes a keystrokes
invoke - invoke the callback/function that belong to the keystroke

ui.command:
string add - bind a command to a callback/function. commands are typed into the chatwindow and starting with \.
remove - removes a command
invoke(command, ...) - invoke the callback/function with the parameters given of the command

changed objects (added methods to them):
ui.timer:
int add - adds a timer. renamed from create
table get - retrieves a timer object
remove - removes a timer object
enabled - sets or get the enabled state of a timer
pause - pauses a timer
resume - resume a timer
toggle - toggle the enabled state of a timer (on/off)
ui.setInterval - creates a interval timer
ui.setTimeout - creates a timerout timer

ui.label:
int add - adds a label (renamed from create)
table get - retrieves a label object
remove - removes a label object
(rect - sets the rect of a label)
caption - sets or get the caption of a label
visible - set or get visibility
toggle - toggles visibility
moveTo - move label to the position
moveBy - moves label by given delta pos
resize - set a new size for the label

ui.verbosity - set verbosity level
ui.consoleLog(message, verbosity) - send a multiline message to the console depending on verbosity level
lua print - is connected to console (needs QA 890)

object properties can be accessed by either using ui.<object>.get(index).property or ui.<object>[index].property

there are may be bugs....
it is planned to leave the object model of libsota like it is with 0.4 , only adding things (when there is something new at the Shroud-API)

---- libsota.util
contains all the function from libsota.0.3.8 (createLabel, isLabelVisible, ...)

--- libsota.ui
hopefully when R73 is released an the last thunderday in month ... oh, wait....


comments are welcome , also bug reports, or how to make things more usefull
