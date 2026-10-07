-- Project UAI Game Analyzer payload
-- Read-only client-side analyzer bootstrap.
-- Usage:
--   loadstring(game:HttpGet("https://raw.githubusercontent.com/azcvyhnb-cpu/anime-dice/main/uai-payload.lua"))()
--
-- This payload expects uai.lua to exist in the same repository.

local BASE = "https://raw.githubusercontent.com/azcvyhnb-cpu/anime-dice/main/"
local URL = BASE .. "uai.lua"

local ok, body = pcall(function()
    return game:HttpGet(URL)
end)

if not ok then
    warn("[Project UAI] Failed to download uai.lua: " .. tostring(body))
    return nil
end

local loader, compileErr = loadstring(body)
if not loader then
    warn("[Project UAI] Failed to compile uai.lua: " .. tostring(compileErr))
    return nil
end

local ran, result = pcall(loader)
if not ran then
    warn("[Project UAI] Failed to start: " .. tostring(result))
    return nil
end

return result
