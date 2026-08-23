hl.window_rule({
  match = { class = "terminal-floating" },
  float = true,
  size = { 800, 500 },
})

hl.window_rule({
  match = { class = "terminal-workspace" },
  workspace = "2 silent",
})

hl.window_rule({
  match = { title = "PhilipsTV GUI" },
  float = true,
  size = { 250, 700 },
  move = { "monitor_w-270", 70 },
})

hl.window_rule({
  match = { class = "org.keepassxc.KeePassXC" },
  float = true,
  size = { 1000, 700 },
  center = true,
})

hl.window_rule({
  match = { class = "protonvpn" },
  float = true,
  size = { 400, 760 },
  move = { "monitor_w-420", 70 },
})

hl.window_rule({
  match = { title = "splash" },
  float = true,
})

hl.window_rule({
  match = { title = "Android Emulator" },
  float = true,
})

hl.window_rule({
  match = { class = "org.gnome.Calculator" },
  float = true,
  size = { 400, 620 },
  move = { "monitor_w-420", "monitor_h-640" },
})

hl.window_rule({
  match = { class = "Spotify" },
  workspace = "11 silent",
})

hl.window_rule({
  match = { title = "Spotify Premium" },
  workspace = "11 silent",
})

hl.window_rule({
  match = { class = "Signal" },
  workspace = "9 silent",
})

hl.window_rule({
  match = { class = "signal" },
  workspace = "9 silent",
})

hl.window_rule({
  match = { title = "Postęp działań na plikach" },
  float = true,
})

hl.layer_rule({
  match = { namespace = "noctalia" },
  blur = true,
  blur_popups = true,
  ignore_alpha = 0.5,
})
