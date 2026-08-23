local generated = require("config.generated")

hl.on("hyprland.start", function()
  if generated.withUWSM then
    hl.exec_cmd("uwsm finalize")
  end

  if generated.withNoctalia then
    hl.exec_cmd(generated.execWrapper .. " noctalia-shell")
  end

  hl.exec_cmd(generated.execWrapper .. " kitty --class terminal-workspace")
end)
