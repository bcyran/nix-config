local generated = require("config.generated")

local mod = "SUPER"
local execWrapper = generated.execWrapper
local noctaliaExecWrapper = execWrapper .. " noctalia-shell ipc call"

local function bindExec(keys, cmd, flags)
  hl.bind(keys, hl.dsp.exec_cmd(cmd), flags)
end

--------------------
-- Window/session --
--------------------
hl.bind(mod .. " + SHIFT + Q", hl.dsp.window.close())
hl.bind(mod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + SHIFT + P", hl.dsp.window.pseudo())
hl.bind(mod .. " + SHIFT + X", hl.dsp.window.pin())

hl.bind(mod .. " + V", hl.dsp.layout("preselect d"))
hl.bind(mod .. " + C", hl.dsp.layout("preselect r"))

-------------
-- Groups  --
-------------
hl.bind(mod .. " + T", hl.dsp.group.toggle())
hl.bind(mod .. " + X", hl.dsp.window.move({ out_of_group = true }))
hl.bind(mod .. " + O", hl.dsp.group.prev())
hl.bind(mod .. " + P", hl.dsp.group.next())
hl.bind(mod .. " + SHIFT + O", hl.dsp.group.move_window({ forward = false }))
hl.bind(mod .. " + SHIFT + P", hl.dsp.group.move_window({ forward = true }))
hl.bind(mod .. " + G", hl.dsp.window.cycle_next({ tiled = true }))
hl.bind(mod .. " + SHIFT + G", hl.dsp.window.cycle_next({ floating = true }))
hl.bind(mod .. " + mouse_left", hl.dsp.group.prev())
hl.bind(mod .. " + mouse_right", hl.dsp.group.next())

------------
-- Focus  --
------------
hl.bind(mod .. " + H", hl.dsp.focus({ direction = "l" }))
hl.bind(mod .. " + L", hl.dsp.focus({ direction = "r" }))
hl.bind(mod .. " + K", hl.dsp.focus({ direction = "u" }))
hl.bind(mod .. " + J", hl.dsp.focus({ direction = "d" }))
hl.bind(mod .. " + U", hl.dsp.focus({ monitor = "l" }))
hl.bind(mod .. " + I", hl.dsp.focus({ monitor = "r" }))
hl.bind(mod .. " + Tab", hl.dsp.focus({ last = true }))

hl.bind(mod .. " + D", hl.dsp.workspace.toggle_special("dropdown"))

hl.bind(mod .. " + SHIFT + H", hl.dsp.window.move({ direction = "l", group_aware = true }))
hl.bind(mod .. " + SHIFT + L", hl.dsp.window.move({ direction = "r", group_aware = true }))
hl.bind(mod .. " + SHIFT + K", hl.dsp.window.move({ direction = "u", group_aware = true }))
hl.bind(mod .. " + SHIFT + J", hl.dsp.window.move({ direction = "d", group_aware = true }))

hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

--------------------
-- Screenshots    --
--------------------
bindExec(mod .. " + S", execWrapper .. " scr area")
bindExec(mod .. " + SHIFT + S", execWrapper .. " scr active")
bindExec(mod .. " + CONTROL + S", execWrapper .. " scr output")

--------------------
-- Apps           --
--------------------
bindExec(mod .. " + RETURN", execWrapper .. " kitty")
bindExec(mod .. " + SHIFT + RETURN", execWrapper .. " kitty --class terminal-floating")
bindExec(mod .. " + Y", execWrapper .. " firefox")
bindExec(mod .. " + N", execWrapper .. " thunar")

--------------------
-- Noctalia shell --
--------------------
bindExec(mod .. " + slash", noctaliaExecWrapper .. " media playPause")
bindExec(mod .. " + SHIFT + slash", noctaliaExecWrapper .. " media toggle")
bindExec(mod .. " + comma", noctaliaExecWrapper .. " media previous")
bindExec(mod .. " + period", noctaliaExecWrapper .. " media next")

bindExec("CONTROL + space", noctaliaExecWrapper .. " notifications toggleHistory")
bindExec("CONTROL + SHIFT + space", noctaliaExecWrapper .. " notifications clear")
bindExec("CONTROL + escape", noctaliaExecWrapper .. " notifications dismissAll")

bindExec(mod .. " + space", noctaliaExecWrapper .. " launcher toggle")
bindExec(mod .. " + W", noctaliaExecWrapper .. " launcher windows")
bindExec(mod .. " + SHIFT + V", noctaliaExecWrapper .. " launcher clipboard")
bindExec(mod .. " + grave", noctaliaExecWrapper .. " settings toggle")
bindExec(mod .. " + SHIFT + space", noctaliaExecWrapper .. " controlCenter toggle")
bindExec(mod .. " + SHIFT + M", noctaliaExecWrapper .. " lockScreen lock")

--------------------
-- Workspaces     --
--------------------
-- Keys 1-9, 0, minus map to workspaces 1-11.
local workspaceKeys = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "minus" }
for workspace, key in ipairs(workspaceKeys) do
  hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = workspace }))
  hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }))
end

--------------------
-- Media keys     --
--------------------
-- Active on lock screen, non-repeatable.
bindExec("XF86AudioMute", noctaliaExecWrapper .. " volume muteOutput", { locked = true })

-- Active on lock screen, repeat while held.
bindExec("XF86AudioRaiseVolume", noctaliaExecWrapper .. " volume increase", { locked = true, repeating = true })
bindExec("XF86AudioLowerVolume", noctaliaExecWrapper .. " volume decrease", { locked = true, repeating = true })
bindExec("XF86MonBrightnessDown", noctaliaExecWrapper .. " brightness decrease", { locked = true, repeating = true })
bindExec("XF86MonBrightnessUp", noctaliaExecWrapper .. " brightness increase", { locked = true, repeating = true })

--------------------
-- Mouse binds    --
--------------------
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

--------------------
-- Submaps        --
--------------------
hl.bind(mod .. " + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
  hl.bind("l", hl.dsp.window.resize({ x = 20, y = 0, relative = true }), { repeating = true })
  hl.bind("h", hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true })
  hl.bind("k", hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true })
  hl.bind("j", hl.dsp.window.resize({ x = 0, y = 20, relative = true }), { repeating = true })
  hl.bind("escape", hl.dsp.submap("reset"))
end)

hl.bind(mod .. " + M", hl.dsp.submap("move"))
hl.define_submap("move", function()
  hl.bind("l", hl.dsp.window.move({ x = 20, y = 0, relative = true }), { repeating = true })
  hl.bind("h", hl.dsp.window.move({ x = -20, y = 0, relative = true }), { repeating = true })
  hl.bind("k", hl.dsp.window.move({ x = 0, y = -20, relative = true }), { repeating = true })
  hl.bind("j", hl.dsp.window.move({ x = 0, y = 20, relative = true }), { repeating = true })
  hl.bind("escape", hl.dsp.submap("reset"))
end)

-- Eats all binds until escape is pressed again, letting keys pass through to
-- the focused application.
hl.bind(mod .. " + escape", hl.dsp.submap("passthrough"))
hl.define_submap("passthrough", function()
  hl.bind(mod .. " + escape", hl.dsp.submap("reset"))
end)
