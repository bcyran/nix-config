hl.config({ animations = { enabled = true } })

hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 3, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = false })
hl.animation({ leaf = "fadeSwitch", enabled = false })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 4, bezier = "myBezier", style = "slidevert" })
hl.animation({ leaf = "layers", enabled = true, speed = 3, bezier = "default", style = "fade" })

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
