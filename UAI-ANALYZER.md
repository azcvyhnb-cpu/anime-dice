# Project UAI Game Analyzer

## Payload

After `uai.lua` has been uploaded to this repository, run:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/azcvyhnb-cpu/anime-dice/main/uai-payload.lua"))()
```

The payload only downloads and starts the bundled Project UAI client. The analyzer itself is read-only: it inspects client-visible Roblox instance structure and metadata and does not invoke remotes or modify game state.

## Direct payload

You can also load the bundled file directly:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/azcvyhnb-cpu/anime-dice/main/uai.lua"))()
```
