-- Monitor layout is managed at runtime by Monique
-- (https://github.com/ToRvaLDz/monique), which writes
-- $XDG_CONFIG_HOME/hypr/monitors.lua whenever a profile is applied.
--
-- Guarded with pcall because `require` throws if the module doesn't exist
-- yet (e.g. a brand new install before Monique's first run), which would
-- otherwise abort this whole file.
pcall(require, "monitors")
