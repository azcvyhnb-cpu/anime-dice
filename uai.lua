-- Project UAI Game Analyzer
-- Standalone read-only client analyzer. No remotes are invoked and no game state is modified.
local VERSION="0.8-standalone"
local MAX=15000
local function safe(f,...) local ok,a,b,c=pcall(f,...);if ok then return a,b,c end end
local function low(v)return string.lower(tostring(v or ""))end
local function has(s,...) s=low(s);for i=1,select("#",...) do if string.find(s,low(select(i,...)),1,true) then return true end end return false end
local function classify(n,p,c)
 local s=low(n.." "..p.." "..c)
 if has(s,"boss","worldboss","raidboss")then return"Boss"end
 if has(s,"enemy","monster","mob","hostile","zombie","goblin")then return"Enemy"end
 if has(s,"character","unit","hero","tower","fighter")then return"Character"end
 if has(s,"stage","level","chapter","map")then return"Stage"end
 if has(s,"wave","round")then return"Wave"end
 if has(s,"quest","mission","task")then return"Quest"end
 if has(s,"shop","store","merchant")then return"Shop"end
 if has(s,"inventory","backpack","item")then return"Inventory"end
 if has(s,"gacha","summon","banner","egg","spin","roll")then return"Gacha"end
 if has(s,"upgrade","enhance","levelup")then return"Upgrade"end
 if has(s,"currency","coins","money","cash","gold","gems")then return"Currency"end
 if has(s,"rebirth","prestige")then return"Rebirth"end
 if has(s,"craft","forge","recipe")then return"Crafting"end
 if has(s,"trade","trading")then return"Trading"end
 if c=="RemoteEvent"or c=="RemoteFunction"then return"Network"end
end
local function path(x)return safe(function()return x:GetFullName()end)or tostring(x.Name or"?")end
local function analyze(root)
 root=root or game;local nodes,classes,remotes,entities={}, {}, {}, {};local seen=0
 local list=safe(function()return root:GetDescendants()end)or{}
 for _,x in ipairs(list)do seen+=1;if seen>MAX then break end
  local n=tostring(safe(function()return x.Name end)or"?");local c=tostring(safe(function()return x.ClassName end)or"?");local p=path(x)
  classes[c]=(classes[c]or 0)+1
  if c=="RemoteEvent"or c=="RemoteFunction"then if #remotes<100 then remotes[#remotes+1]={name=n,class=c,path=p}end end
  local k=classify(n,p,c);if k then nodes[k]=(nodes[k]or 0)+1;if #entities<500 then entities[#entities+1]={kind=k,name=n,className=c,path=p,attributes=safe(function()return x:GetAttributes()end)or{}}end end
 end
 local score={
  ["Tower Defense"]=(nodes.Stage or 0)+(nodes.Wave or 0)+(nodes.Enemy or 0)+(nodes.Character or 0),
  RPG=(nodes.Character or 0)+(nodes.Quest or 0)+(nodes.Inventory or 0)+(nodes.Enemy or 0),
  Simulator=(nodes.Currency or 0)+(nodes.Upgrade or 0)+(nodes.Inventory or 0)+(nodes.Rebirth or 0),
  Gacha=(nodes.Gacha or 0)+(nodes.Character or 0)+(nodes.Inventory or 0),
  Adventure=(nodes.Stage or 0)+(nodes.Quest or 0)+(nodes.Character or 0)+(nodes.Enemy or 0)}
 local primary,best="Unknown",0;for k,v in pairs(score)do if v>best then primary,best=k,v end end
 return{version=VERSION,root=path(root),scanned=math.min(seen,MAX),truncated=seen>MAX,classCounts=classes,systems=nodes,entities=entities,remotes=remotes,classification=primary,classificationScore=best}
end
local function report(r)
 print("========== Project UAI Game Analyzer "..VERSION.." ==========");print("Root: "..r.root);print("Scanned: "..r.scanned..(r.truncated and" (LIMIT REACHED)"or""));print("Classification: "..r.classification)
 print("-- Detected systems --");local keys={};for k in pairs(r.systems)do keys[#keys+1]=k end;table.sort(keys);if #keys==0 then print("  none")end;for _,k in ipairs(keys)do print(("  %-12s %d"):format(k,r.systems[k]))end
 print("-- Network objects (names/paths only; never invoked) --");for i,x in ipairs(r.remotes)do print(("  [%d] %s | %s"):format(i,x.class,x.path))end;if #r.remotes==0 then print("  none found")end
 print("-- Entity samples --");for i=1,math.min(#r.entities,80)do local e=r.entities[i];print(("  [%d] %-10s %s"):format(i,e.kind,e.path))end
 print("===================================================")
end
local UAI={version=VERSION,analyze=analyze,report=report}
function UAI.refresh(root)local r=analyze(root or game);UAI.last=r;report(r);return r end
function UAI.destroy()UAI.last=nil;return true end
local ok,res=pcall(function()return UAI.refresh(game)end);if not ok then warn("[Project UAI] Analyzer failed: "..tostring(res));return nil end
_G.ProjectUAI=UAI
return UAI
