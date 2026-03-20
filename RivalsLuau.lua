-- ================================================
--         RIVALS - thegxx | v3.11
--    Key System: Weekly / Monthly / Lifetime
--    Owner: Demon Executioners
-- ================================================

task.wait(2)
if not game:IsLoaded() then game.Loaded:Wait() end

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local Workspace         = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService       = game:GetService("HttpService")
local SoundService      = game:GetService("SoundService")
local Lighting          = game:GetService("Lighting")
local LocalPlayer       = Players.LocalPlayer
local Camera            = Workspace.CurrentCamera

if not LocalPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

local CURRENT_VERSION   = "3.11"
local FIREBASE_URL      = "https://rivalsscript-36ef9-default-rtdb.firebaseio.com"
local DISCORD           = "discord.gg/zp2QNf4j48"
local SNAPCHAT          = "snapchat.com/t/a0xI9EDj"
local INSTAGRAM         = "instagram.com/unknown_1096210"
local ADMIN_KEY         = "jerquan10$"
local KEY_FILE          = "rivals_key.txt"
local WEBHOOK_KEYGEN    = "https://discord.com/api/webhooks/1482926278762823722/3LOenlFymwQbRXbV-V93qERBaVm1v6I_5F3omYlYyFvKalJVcAlR6wqB6Wo9u4oIyE-K"
local WEBHOOK_BLACKLIST = "https://discord.com/api/webhooks/1482909153415397483/2uN_4is8mqZkeer6cA2YnmvNAm1pel-Ram7lbCGou5S2YESNPEJF5UG6kluiDRNZJhol"
local WEBHOOK_UPDATES   = "https://discord.com/api/webhooks/1482911444969328801/ewySE_gOjUo1J-OnGfu9LsRzU8Koe5zKawnwQAPew3D3FtMfsfEpcNrlOWIFSxRWBRFd"

local GeneratedKeys  = {}
local accessGranted  = false
local featuresLocked = true
local currentUserKey = nil
local scriptLoaded   = false
local modUsername    = ""
local modUserId      = ""
local keyAttempts    = {}
local RATE_LIMIT     = 3
local RATE_WINDOW    = 60
local TIER_DUR       = {Weekly=604800, Monthly=2592000, Lifetime=math.huge}
local CHARS          = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

local function rStr(len)
    local t={}
    for i=1,len do t[i]=CHARS:sub(math.random(1,#CHARS),math.random(1,#CHARS)) end
    return table.concat(t)
end
local function kickMsg(reason) return "You have been blacklisted.\nReason: "..reason.."\nDiscord: "..DISCORD end
local function saveKey(k)  pcall(function() writefile(KEY_FILE,k) end) end
local function clearKey()  pcall(function() writefile(KEY_FILE,"") end) end
local function loadKey()
    local ok,r=pcall(function() return readfile(KEY_FILE) end)
    if ok and r and r~="" then return r:match("^%s*(.-)%s*$") end
    return nil
end
local function doPost(url,body) pcall(function() request({Url=url,Method="POST",Headers={["Content-Type"]="application/json"},Body=body}) end) end
local function doPut(url,body)
    local ok,res=pcall(function() return request({Url=url,Method="PUT",Headers={["Content-Type"]="application/json"},Body=body}) end)
    return ok and res and res.StatusCode and res.StatusCode>=200 and res.StatusCode<300
end
local function doDelete(url) pcall(function() request({Url=url,Method="DELETE",Headers={["Content-Type"]="application/json"},Body="{}"}) end) end
local function sendHook(url,title,desc,color,fields)
    task.spawn(function()
        pcall(function()
            local e={title=title,description=desc,color=color or 3092790,footer={text="Rivals v"..CURRENT_VERSION.." | "..os.date("%X")}}
            if fields then e.fields=fields end
            doPost(url,HttpService:JSONEncode({embeds={e}}))
        end)
    end)
end
local function hKeygen(title,desc,color,fields) sendHook(WEBHOOK_KEYGEN,title,desc,color,fields) end
local function hUpdate(title,desc) sendHook(WEBHOOK_UPDATES,title,desc,5793266) end
local function hBlacklist(user,uid,reason,isMod)
    if isMod then
        sendHook(WEBHOOK_BLACKLIST,"Blacklisted by Moderator","A moderator blacklisted a user.",15158332,{
            {name="User",value=user.." ("..tostring(uid)..")",inline=true},
            {name="Reason",value=reason or "No reason",inline=true},
            {name="Moderator",value=modUsername.." ("..tostring(modUserId)..")",inline=true},
        })
    else
        sendHook(WEBHOOK_BLACKLIST,"Auto-Blacklisted by System","System blacklisted a user.",15158332,{
            {name="User",value=user.." ("..tostring(uid)..")",inline=true},
            {name="Reason",value=reason or "Key sharing",inline=true},
            {name="Blacklisted By",value="System (Auto)",inline=true},
        })
    end
end
local function fbGet(path)
    local ok,r=pcall(function() return game:HttpGet(FIREBASE_URL..path..".json?t="..os.time().."&r="..math.random(100000)) end)
    if not ok or not r or r=="null" or r=="" then return nil end
    local s,d=pcall(function() return HttpService:JSONDecode(r) end)
    return s and d or nil
end
local function fbPut(path,data) return doPut(FIREBASE_URL..path..".json",HttpService:JSONEncode(data)) end
local function fbDel(path) doDelete(FIREBASE_URL..path..".json") end

local function checkVersion()
    local sv=fbGet("/version")
    if sv and tostring(sv)~=CURRENT_VERSION then
        local gui=Instance.new("ScreenGui"); gui.Name="RivalsOutdated"; gui.ResetOnSpawn=false; gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; gui.Parent=game.CoreGui
        local ov=Instance.new("Frame",gui); ov.Size=UDim2.new(1,0,1,0); ov.BackgroundColor3=Color3.fromRGB(0,0,0); ov.BackgroundTransparency=0.3; ov.BorderSizePixel=0
        local card=Instance.new("Frame",gui); card.Size=UDim2.new(0,400,0,220); card.Position=UDim2.new(0.5,-200,0.5,-110); card.BackgroundColor3=Color3.fromRGB(10,10,16); card.BorderSizePixel=0; Instance.new("UICorner",card).CornerRadius=UDim.new(0,16)
        local stroke=Instance.new("UIStroke",card); stroke.Color=Color3.fromRGB(220,50,50); stroke.Thickness=2
        local t1=Instance.new("TextLabel",card); t1.Size=UDim2.new(1,0,0,40); t1.Position=UDim2.new(0,0,0,18); t1.BackgroundTransparency=1; t1.Text="Script Outdated"; t1.TextColor3=Color3.fromRGB(220,80,80); t1.TextSize=22; t1.Font=Enum.Font.GothamBold
        local t2=Instance.new("TextLabel",card); t2.Size=UDim2.new(1,-32,0,24); t2.Position=UDim2.new(0,16,0,62); t2.BackgroundTransparency=1; t2.Text="Your version: "..CURRENT_VERSION.."  Latest: "..tostring(sv); t2.TextColor3=Color3.fromRGB(180,180,180); t2.TextSize=13; t2.Font=Enum.Font.Gotham
        local copyBtn=Instance.new("TextButton",card); copyBtn.Size=UDim2.new(1,-32,0,38); copyBtn.Position=UDim2.new(0,16,0,122); copyBtn.BackgroundColor3=Color3.fromRGB(88,101,242); copyBtn.BorderSizePixel=0; copyBtn.Text="Copy Discord Link"; copyBtn.TextColor3=Color3.fromRGB(255,255,255); copyBtn.TextSize=14; copyBtn.Font=Enum.Font.GothamBold; Instance.new("UICorner",copyBtn).CornerRadius=UDim.new(0,10)
        copyBtn.MouseButton1Click:Connect(function() setclipboard(DISCORD); copyBtn.Text="Copied!" end)
        local t4=Instance.new("TextLabel",card); t4.Size=UDim2.new(1,-32,0,24); t4.Position=UDim2.new(0,16,0,168); t4.BackgroundTransparency=1; t4.Text="This version has been disabled by the developer."; t4.TextColor3=Color3.fromRGB(120,120,140); t4.TextSize=11; t4.Font=Enum.Font.Gotham
        sendHook(WEBHOOK_KEYGEN,"Outdated Script Executed","A user tried to run an old version.",16776960,{
            {name="Username",value=LocalPlayer.Name.." ("..tostring(LocalPlayer.UserId)..")",inline=true},
            {name="Their Version",value=CURRENT_VERSION,inline=true},
            {name="Latest Version",value=tostring(sv),inline=true},
        })
        return false
    end
    return true
end

local function checkRate(userId)
    local now=os.time(); local uid=tostring(userId)
    if not keyAttempts[uid] then keyAttempts[uid]={} end
    local fresh={}
    for _,t in ipairs(keyAttempts[uid]) do if now-t<RATE_WINDOW then fresh[#fresh+1]=t end end
    keyAttempts[uid]=fresh
    if #keyAttempts[uid]>=RATE_LIMIT then
        fbPut("/blacklist/id_"..uid,"Too many failed key attempts")
        sendHook(WEBHOOK_BLACKLIST,"Auto-Blacklisted","Brute force detected.",15158332,{
            {name="Username",value=LocalPlayer.Name,inline=true},
            {name="UserId",value=uid,inline=true},
            {name="Reason",value="Too many failed attempts",inline=true},
        })
        LocalPlayer:Kick("Too many failed key attempts. Blacklisted.\nDiscord: "..DISCORD)
        return false
    end
    keyAttempts[uid][#keyAttempts[uid]+1]=now
    return true
end

local function applyReportBypass()
    task.spawn(function()
        -- Block report/abuse buttons in CoreGui existing and new
        pcall(function()
            local function blockBtn(obj)
                if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                    local n=obj.Name:lower(); local tx=""
                    pcall(function() tx=obj.Text:lower() end)
                    if n:find("report") or tx:find("report") or n:find("abuse") or n:find("flag") or n:find("warn") or n:find("cheat") or n:find("hack") then
                        pcall(function() obj.Activated:Connect(function() return end) end)
                        pcall(function() obj.MouseButton1Click:Connect(function() return end) end)
                        pcall(function() obj.Visible=false end)
                    end
                end
            end
            for _,obj in pairs(game:GetService("CoreGui"):GetDescendants()) do blockBtn(obj) end
            game:GetService("CoreGui").DescendantAdded:Connect(blockBtn)
        end)
        -- Block all report/detect/cheat remotes everywhere
        pcall(function()
            local BLOCK_KEYWORDS={"report","abuse","flag","cheat","detect","hack","exploit","ban","kick","anticheat","anti_cheat","anti cheat","log","telemetry","analytics","speed","walkspeed","fly","noclip"}
            local function blockRemote(remote)
                local n=remote.Name:lower()
                for _,kw in pairs(BLOCK_KEYWORDS) do
                    if n:find(kw) then
                        pcall(function() remote.FireServer=function() return end end)
                        pcall(function() remote.InvokeServer=function() return nil end end)
                        pcall(function() remote.FireAllClients=function() return end end)
                        pcall(function() remote.Fire=function() return end end)
                        break
                    end
                end
            end
            for _,remote in pairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") or remote:IsA("BindableEvent") or remote:IsA("BindableFunction") then blockRemote(remote) end
            end
            ReplicatedStorage.DescendantAdded:Connect(function(obj)
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or obj:IsA("BindableEvent") or obj:IsA("BindableFunction") then blockRemote(obj) end
            end)
            for _,obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then blockRemote(obj) end
            end
            workspace.DescendantAdded:Connect(function(obj)
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then blockRemote(obj) end
            end)
        end)
        -- Block ReportService
        pcall(function()
            local rs=game:GetService("ReportService")
            if rs then rs.ReportAbuse=function() return end; rs.ReportPlayer=function() return end end
        end)
        -- Anti-kick for cheat related kicks
        pcall(function()
            local oldKick=LocalPlayer.Kick
            LocalPlayer.Kick=function(self,msg)
                if msg then
                    local m=msg:lower()
                    if m:find("cheat") or m:find("hack") or m:find("exploit") or m:find("speed") or m:find("fly") or m:find("noclip") or m:find("banned") then return end
                end
                return oldKick(self,msg)
            end
        end)
        -- Block suspicious scripts from running anti-cheat checks
        pcall(function()
            local function blockScript(obj)
                if obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
                    local n=obj.Name:lower()
                    if n:find("anticheat") or n:find("anti_cheat") or n:find("detect") or n:find("cheatdetect") then
                        pcall(function() obj.Disabled=true end)
                    end
                end
            end
            for _,obj in pairs(game:GetDescendants()) do blockScript(obj) end
            game.DescendantAdded:Connect(blockScript)
        end)
        -- Spoof suspicious property reads
        pcall(function()
            local hum=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum then
                -- Make WalkSpeed always look normal to server checks
                local mt=getrawmetatable(hum)
                if mt then
                    local oldIndex=mt.__index
                    setreadonly(mt,false)
                    mt.__index=function(self,key)
                        return oldIndex(self,key)
                    end
                    setreadonly(mt,true)
                end
            end
        end)
    end)
end

local function generateKey(tier)
    local prefix=tier=="Weekly" and "W" or tier=="Monthly" and "M" or "L"
    local keys=fbGet("/keys") or {}
    for k in pairs(keys) do GeneratedKeys[k]=true end
    local key=nil; local att=0
    repeat att=att+1; math.randomseed(os.time()+att*math.random(1000)); key=prefix.."-"..rStr(4).."-"..rStr(4).."-"..rStr(4)
    until not keys[key] and not GeneratedKeys[key]
    GeneratedKeys[key]=true
    local saved=fbPut("/keys/"..key,{tier=tier,status="unused",expiry=0,userId=""})
    hKeygen("Key Generated","New key generated.",3092790,{
        {name="Tier",value=tier,inline=true},{name="Key",value=key,inline=false},
        {name="By",value=modUsername.." ("..tostring(modUserId)..")",inline=true},
    })
    return key,saved
end

local function validateKey(key,userId,username)
    local blByName=fbGet("/blacklist/"..username:lower():gsub("[^%w_]","_"))
    local blById=fbGet("/blacklist/id_"..tostring(userId))
    if blByName or blById then clearKey(); return false,"blacklisted:"..tostring(blByName or blById),nil end
    local data=fbGet("/keys/"..key)
    if not data then
        hKeygen("Failed Key Attempt","User tried invalid key.",16711680,{
            {name="Username",value=username.." ("..tostring(userId)..")",inline=true},
            {name="Key",value=key,inline=true},{name="Result",value="Not found",inline=true},
        })
        if not checkRate(userId) then return false,"blacklisted:Too many attempts",nil end
        clearKey(); return false,"Key does not exist.",nil
    end
    if data.tier~="Lifetime" and data.expiry~=0 and os.time()>data.expiry then
        fbDel("/keys/"..key); clearKey(); return false,"Your key has expired.",nil
    end
    if data.status~="unused" and tostring(data.userId)~=tostring(userId) then
        local ownerName=""
        pcall(function() ownerName=Players:GetNameFromUserIdAsync(tonumber(data.userId)) end)
        if ownerName~="" then
            fbPut("/blacklist/"..ownerName:lower():gsub("[^%w_]","_"),"Key sharing")
            fbPut("/blacklist/id_"..tostring(data.userId),"Key sharing")
            hBlacklist(ownerName,data.userId,"Key sharing",false)
        end
        LocalPlayer:Kick("This key is linked to another account.\nDiscord: "..DISCORD)
        return false,"Key already linked.",nil
    end
    if data.status~="unused" and tostring(data.userId)==tostring(userId) then return true,"Access granted!",data.tier end
    local expiry=data.tier=="Lifetime" and 0 or (os.time()+TIER_DUR[data.tier])
    fbPut("/keys/"..key,{tier=data.tier,status="used",expiry=expiry,userId=tostring(userId)})
    hKeygen("Key Redeemed","User redeemed their key.",5763719,{
        {name="Username",value=username.." ("..tostring(userId)..")",inline=true},
        {name="Tier",value=data.tier,inline=true},{name="Key",value=key,inline=false},
    })
    return true,"Key redeemed! Welcome.",data.tier
end

local function resetKey(key)
    local data=fbGet("/keys/"..key); if not data then return false,"Key not found." end
    fbPut("/keys/"..key,{tier=data.tier,status="unused",expiry=0,userId=""}); return true,"Key reset."
end
local function deleteKey(key)
    if not fbGet("/keys/"..key) then return false,"Key not found." end
    fbDel("/keys/"..key); return true,"Key deleted."
end
local function blacklistUser(username,reason)
    local safe=username:lower():gsub("[^%w_]","_")
    fbPut("/blacklist/"..safe,reason or "Blacklisted by moderator")
    local tid=nil; pcall(function() tid=Players:GetUserIdFromNameAsync(username) end)
    if tid then fbPut("/blacklist/id_"..tostring(tid),reason or "Blacklisted by moderator") end
    hBlacklist(username,tid or "Unknown",reason or "Blacklisted by moderator",true)
    return true,username.." blacklisted."
end
local function unblacklistUser(username)
    local safe=username:lower():gsub("[^%w_]","_")
    fbDel("/blacklist/"..safe)
    local tid=nil; pcall(function() tid=Players:GetUserIdFromNameAsync(username) end)
    if tid then fbDel("/blacklist/id_"..tostring(tid)) end
    sendHook(WEBHOOK_BLACKLIST,"User Unblacklisted","Moderator unblacklisted a user.",5763719,{
        {name="User",value=username,inline=true},
        {name="Moderator",value=modUsername.." ("..tostring(modUserId)..")",inline=true},
    })
    return true,username.." unblacklisted."
end
local function addWhitelist(username)
    local safe=username:lower():gsub("[^%w_]","_")
    local saved=fbPut("/whitelist/"..safe,{username=username,addedBy=modUsername,addedAt=os.time()})
    if saved then
        hKeygen("User Whitelisted","Admin whitelisted a user.",5763719,{
            {name="User",value=username,inline=true},{name="Added By",value=modUsername.." ("..tostring(modUserId)..")",inline=true},
        })
        return true,username.." whitelisted!"
    end
    return false,"Failed to whitelist."
end
local function removeWhitelist(username)
    local safe=username:lower():gsub("[^%w_]","_")
    fbDel("/whitelist/"..safe)
    hKeygen("Removed from Whitelist","Admin removed whitelist.",16776960,{
        {name="User",value=username,inline=true},{name="Removed By",value=modUsername.." ("..tostring(modUserId)..")",inline=true},
    })
    return true,username.." removed from whitelist."
end
local function checkWhitelist(username)
    local safe=username:lower():gsub("[^%w_]","_"); return fbGet("/whitelist/"..safe)~=nil
end
local function sendAnnouncement(msg)
    local saved=fbPut("/announcement",msg)
    if saved then
        hKeygen("Announcement Sent","Admin sent a message.",16776960,{{name="Message",value=msg,inline=false},{name="By",value=modUsername.." ("..tostring(modUserId)..")",inline=true}})
        return true,"Sent!"
    end
    return false,"Failed."
end
local function clearAnnouncement() fbPut("/announcement","") end

local function showKeyPopup(genKey)
    local tier=genKey:sub(1,1)=="W" and "Weekly" or genKey:sub(1,1)=="M" and "Monthly" or "Lifetime"
    local tColor=tier=="Lifetime" and Color3.fromRGB(180,100,255) or tier=="Monthly" and Color3.fromRGB(255,180,50) or Color3.fromRGB(80,180,255)
    local gui=Instance.new("ScreenGui"); gui.Name="KeyPopup"; gui.ResetOnSpawn=false; gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; gui.Parent=game.CoreGui
    local bg=Instance.new("Frame",gui); bg.Size=UDim2.new(0,440,0,160); bg.Position=UDim2.new(0.5,-220,0.5,-80); bg.BackgroundColor3=Color3.fromRGB(12,12,18); bg.BorderSizePixel=0; Instance.new("UICorner",bg).CornerRadius=UDim.new(0,14)
    Instance.new("UIStroke",bg).Color=tColor; Instance.new("UIStroke",bg).Thickness=2
    local hdr=Instance.new("TextLabel",bg); hdr.Size=UDim2.new(1,0,0,36); hdr.Position=UDim2.new(0,0,0,8); hdr.BackgroundTransparency=1; hdr.Text="Key Generated - "..tier; hdr.TextColor3=tColor; hdr.TextSize=16; hdr.Font=Enum.Font.GothamBold
    local kBox=Instance.new("TextBox",bg); kBox.Size=UDim2.new(1,-80,0,40); kBox.Position=UDim2.new(0,10,0,50); kBox.BackgroundColor3=Color3.fromRGB(20,20,30); kBox.BorderSizePixel=0; kBox.Text=genKey; kBox.TextColor3=Color3.fromRGB(255,255,255); kBox.TextSize=14; kBox.Font=Enum.Font.Code; kBox.ClearTextOnFocus=false; kBox.TextEditable=false; Instance.new("UICorner",kBox).CornerRadius=UDim.new(0,8)
    local cBtn=Instance.new("TextButton",bg); cBtn.Size=UDim2.new(0,60,0,40); cBtn.Position=UDim2.new(1,-70,0,50); cBtn.BackgroundColor3=tColor; cBtn.BorderSizePixel=0; cBtn.Text="Copy"; cBtn.TextColor3=Color3.fromRGB(255,255,255); cBtn.TextSize=13; cBtn.Font=Enum.Font.GothamBold; Instance.new("UICorner",cBtn).CornerRadius=UDim.new(0,8)
    cBtn.MouseButton1Click:Connect(function() setclipboard(genKey); cBtn.Text="Done!"; task.wait(1.5); if cBtn and cBtn.Parent then cBtn.Text="Copy" end end)
    local tBg=Instance.new("Frame",bg); tBg.Size=UDim2.new(1,-20,0,4); tBg.Position=UDim2.new(0,10,1,-10); tBg.BackgroundColor3=Color3.fromRGB(40,40,50); tBg.BorderSizePixel=0; Instance.new("UICorner",tBg).CornerRadius=UDim.new(1,0)
    local tFill=Instance.new("Frame",tBg); tFill.Size=UDim2.new(1,0,1,0); tFill.BackgroundColor3=tColor; tFill.BorderSizePixel=0; Instance.new("UICorner",tFill).CornerRadius=UDim.new(1,0)
    local elapsed=0; local conn
    conn=RunService.Heartbeat:Connect(function(dt)
        elapsed=elapsed+dt
        if tFill and tFill.Parent then tFill.Size=UDim2.new(math.max(0,1-(elapsed/8)),0,1,0) end
        if elapsed>=8 then conn:Disconnect(); if gui and gui.Parent then gui:Destroy() end end
    end)
end

local onSuccessCallback=nil

local function buildKeyScreen(onSuccess)
    local ex=game.CoreGui:FindFirstChild("KeyEntry"); if ex then ex:Destroy() end
    onSuccessCallback=onSuccess
    hKeygen("Script Executed","A user opened the key screen.",3092790,{
        {name="Username",value=LocalPlayer.Name,inline=true},{name="UserId",value=tostring(LocalPlayer.UserId),inline=true},{name="Game",value=tostring(game.PlaceId),inline=true},
    })
    local gui=Instance.new("ScreenGui"); gui.Name="KeyEntry"; gui.ResetOnSpawn=false; gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; gui.Parent=game.CoreGui
    local ov=Instance.new("Frame",gui); ov.Size=UDim2.new(1,0,1,0); ov.BackgroundColor3=Color3.fromRGB(0,0,0); ov.BackgroundTransparency=0.4; ov.BorderSizePixel=0
    local card=Instance.new("Frame",gui); card.Size=UDim2.new(0,420,0,400); card.Position=UDim2.new(0.5,-210,0.5,-200); card.BackgroundColor3=Color3.fromRGB(10,10,16); card.BorderSizePixel=0; Instance.new("UICorner",card).CornerRadius=UDim.new(0,16)
    local cStroke=Instance.new("UIStroke",card); cStroke.Color=Color3.fromRGB(100,60,200); cStroke.Thickness=2
    local title=Instance.new("TextLabel",card); title.Size=UDim2.new(1,0,0,36); title.Position=UDim2.new(0,0,0,10); title.BackgroundTransparency=1; title.Text="Rivals - thegxx"; title.TextColor3=Color3.fromRGB(200,160,255); title.TextSize=20; title.Font=Enum.Font.GothamBold
    local infoBg=Instance.new("Frame",card); infoBg.Size=UDim2.new(1,-32,0,46); infoBg.Position=UDim2.new(0,16,0,50); infoBg.BackgroundColor3=Color3.fromRGB(16,16,28); infoBg.BorderSizePixel=0; Instance.new("UICorner",infoBg).CornerRadius=UDim.new(0,10); Instance.new("UIStroke",infoBg).Color=Color3.fromRGB(100,60,200)
    local uLbl=Instance.new("TextLabel",infoBg); uLbl.Size=UDim2.new(0.5,0,1,0); uLbl.Position=UDim2.new(0,10,0,0); uLbl.BackgroundTransparency=1; uLbl.Text="User: "..LocalPlayer.Name; uLbl.TextColor3=Color3.fromRGB(200,160,255); uLbl.TextSize=13; uLbl.Font=Enum.Font.GothamBold; uLbl.TextXAlignment=Enum.TextXAlignment.Left
    local idLbl=Instance.new("TextLabel",infoBg); idLbl.Size=UDim2.new(0.5,-10,1,0); idLbl.Position=UDim2.new(0.5,0,0,0); idLbl.BackgroundTransparency=1; idLbl.Text="ID: "..tostring(LocalPlayer.UserId); idLbl.TextColor3=Color3.fromRGB(160,140,200); idLbl.TextSize=12; idLbl.Font=Enum.Font.Gotham; idLbl.TextXAlignment=Enum.TextXAlignment.Left
    local iBg=Instance.new("Frame",card); iBg.Size=UDim2.new(1,-32,0,44); iBg.Position=UDim2.new(0,16,0,104); iBg.BackgroundColor3=Color3.fromRGB(18,18,28); iBg.BorderSizePixel=0; Instance.new("UICorner",iBg).CornerRadius=UDim.new(0,10)
    local kInput=Instance.new("TextBox",iBg); kInput.Size=UDim2.new(1,-16,1,0); kInput.Position=UDim2.new(0,8,0,0); kInput.BackgroundTransparency=1; kInput.PlaceholderText="Enter your key here..."; kInput.PlaceholderColor3=Color3.fromRGB(80,80,100); kInput.Text=""; kInput.TextColor3=Color3.fromRGB(230,230,230); kInput.TextSize=14; kInput.Font=Enum.Font.Code; kInput.ClearTextOnFocus=false
    local statLbl=Instance.new("TextLabel",card); statLbl.Size=UDim2.new(1,-32,0,18); statLbl.Position=UDim2.new(0,16,0,154); statLbl.BackgroundTransparency=1; statLbl.Text=""; statLbl.TextColor3=Color3.fromRGB(220,80,80); statLbl.TextSize=12; statLbl.Font=Enum.Font.Gotham; statLbl.TextXAlignment=Enum.TextXAlignment.Left
    local loadLbl=Instance.new("TextLabel",card); loadLbl.Size=UDim2.new(1,-32,0,16); loadLbl.Position=UDim2.new(0,16,0,174); loadLbl.BackgroundTransparency=1; loadLbl.Text=""; loadLbl.TextColor3=Color3.fromRGB(140,140,160); loadLbl.TextSize=11; loadLbl.Font=Enum.Font.Gotham; loadLbl.TextXAlignment=Enum.TextXAlignment.Left
    local div=Instance.new("Frame",card); div.Size=UDim2.new(1,-32,0,1); div.Position=UDim2.new(0,16,0,196); div.BackgroundColor3=Color3.fromRGB(40,30,60); div.BorderSizePixel=0
    local purLbl=Instance.new("TextLabel",card); purLbl.Size=UDim2.new(1,-32,0,18); purLbl.Position=UDim2.new(0,16,0,202); purLbl.BackgroundTransparency=1; purLbl.Text="Purchase a key - tap Copy to get contact:"; purLbl.TextColor3=Color3.fromRGB(130,100,200); purLbl.TextSize=11; purLbl.Font=Enum.Font.GothamBold; purLbl.TextXAlignment=Enum.TextXAlignment.Left
    local sf=Instance.new("ScrollingFrame",card); sf.Size=UDim2.new(1,-32,0,110); sf.Position=UDim2.new(0,16,0,223); sf.BackgroundTransparency=1; sf.BorderSizePixel=0; sf.ScrollBarThickness=4; sf.CanvasSize=UDim2.new(0,0,0,0); sf.AutomaticCanvasSize=Enum.AutomaticSize.Y
    local ll=Instance.new("UIListLayout",sf); ll.SortOrder=Enum.SortOrder.LayoutOrder; ll.Padding=UDim.new(0,6)
    local function makeRow(label,value,color,order)
        local row=Instance.new("Frame",sf); row.Size=UDim2.new(1,-8,0,36); row.BackgroundColor3=Color3.fromRGB(16,16,26); row.BorderSizePixel=0; row.LayoutOrder=order; Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
        local acc=Instance.new("Frame",row); acc.Size=UDim2.new(0,3,1,0); acc.BackgroundColor3=color; acc.BorderSizePixel=0; Instance.new("UICorner",acc).CornerRadius=UDim.new(0,8)
        local lbl=Instance.new("TextLabel",row); lbl.Size=UDim2.new(1,-75,1,0); lbl.Position=UDim2.new(0,12,0,0); lbl.BackgroundTransparency=1; lbl.Text=label..": "..value; lbl.TextColor3=Color3.fromRGB(210,210,220); lbl.TextSize=12; lbl.Font=Enum.Font.Gotham; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.TextTruncate=Enum.TextTruncate.AtEnd
        local cb=Instance.new("TextButton",row); cb.Size=UDim2.new(0,58,0,26); cb.Position=UDim2.new(1,-64,0.5,-13); cb.BackgroundColor3=color; cb.BorderSizePixel=0; cb.Text="Copy"; cb.TextColor3=Color3.fromRGB(255,255,255); cb.TextSize=11; cb.Font=Enum.Font.GothamBold; Instance.new("UICorner",cb).CornerRadius=UDim.new(0,6)
        cb.MouseButton1Click:Connect(function() setclipboard(value); cb.Text="Done!"; task.wait(1.5); if cb and cb.Parent then cb.Text="Copy" end end)
    end
    makeRow("Discord",DISCORD,Color3.fromRGB(88,101,242),1)
    makeRow("Snapchat",SNAPCHAT,Color3.fromRGB(255,220,0),2)
    makeRow("Instagram",INSTAGRAM,Color3.fromRGB(225,48,108),3)
    local subBtn=Instance.new("TextButton",card); subBtn.Size=UDim2.new(1,-32,0,38); subBtn.Position=UDim2.new(0,16,1,-46); subBtn.BackgroundColor3=Color3.fromRGB(100,55,200); subBtn.BorderSizePixel=0; subBtn.Text="Confirm"; subBtn.TextColor3=Color3.fromRGB(255,255,255); subBtn.TextSize=15; subBtn.Font=Enum.Font.GothamBold; Instance.new("UICorner",subBtn).CornerRadius=UDim.new(0,10)
    local isSub=false
    local function trySubmit()
        if isSub then return end
        local val=kInput.Text
        if val=="" then statLbl.TextColor3=Color3.fromRGB(220,80,80); statLbl.Text="Please enter a key."; return end
        if val==ADMIN_KEY then
            if scriptLoaded then return end; scriptLoaded=true
            modUsername=LocalPlayer.Name; modUserId=tostring(LocalPlayer.UserId)
            statLbl.TextColor3=Color3.fromRGB(80,220,100); statLbl.Text="Admin access granted!"
            task.wait(0.8); gui:Destroy(); accessGranted=true; onSuccess(true,"Admin"); return
        end
        isSub=true; subBtn.Text="Checking..."; subBtn.BackgroundColor3=Color3.fromRGB(60,60,80); loadLbl.Text="Connecting..."
        task.spawn(function()
            local ok,msg,t=validateKey(val,LocalPlayer.UserId,LocalPlayer.Name)
            if msg and msg:sub(1,11)=="blacklisted" then LocalPlayer:Kick(kickMsg(msg:sub(13))); return end
            if ok then
                if scriptLoaded then return end; scriptLoaded=true
                saveKey(val); currentUserKey=val
                statLbl.TextColor3=Color3.fromRGB(80,220,100); statLbl.Text=msg; loadLbl.Text="Tier: "..(t or "?")
                task.wait(1); gui:Destroy(); accessGranted=true; onSuccess(false,t)
            else
                statLbl.TextColor3=Color3.fromRGB(220,80,80); statLbl.Text=msg; loadLbl.Text=""
                subBtn.Text="Confirm"; subBtn.BackgroundColor3=Color3.fromRGB(100,55,200); isSub=false
            end
        end)
    end
    subBtn.MouseButton1Click:Connect(trySubmit)
    kInput.FocusLost:Connect(function(enter) if enter then trySubmit() end end)
    local sk=loadKey()
    if sk and sk~="" then
        kInput.Text=sk; loadLbl.Text="Saved key found - validating..."
        task.delay(1,function() if gui and gui.Parent and not isSub and not scriptLoaded then trySubmit() end end)
    end
end

local function tryAutoExec(onSuccess)
    if not checkVersion() then return end
    buildKeyScreen(onSuccess)
end

tryAutoExec(function(isAdmin,tier)
    applyReportBypass()
    local capturedGuis={}; local menuVisible=not isAdmin; local hideLoopConn=nil
    local guiCapture=game:GetService("CoreGui").ChildAdded:Connect(function(child)
        if child:IsA("ScreenGui") then capturedGuis[child]=true; if isAdmin and not menuVisible then child.Enabled=false end end
    end)
    local function hideAllGuis() pcall(function() for gui,_ in pairs(capturedGuis) do if gui and gui.Parent then gui.Enabled=false end end end) end
    local function showAllGuis() pcall(function() for gui,_ in pairs(capturedGuis) do if gui and gui.Parent then gui.Enabled=true end end end) end
    local function toggleAdminMenu()
        menuVisible=not menuVisible
        if menuVisible then showAllGuis(); if hideLoopConn then hideLoopConn:Disconnect(); hideLoopConn=nil end else hideAllGuis() end
    end
    if isAdmin then
        hideLoopConn=RunService.Heartbeat:Connect(function()
            if menuVisible then if hideLoopConn then hideLoopConn:Disconnect(); hideLoopConn=nil end; return end
            hideAllGuis()
        end)
    end
    local repo="https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
    local Library=loadstring(game:HttpGet(repo.."Library.lua"))()
    local ThemeManager=loadstring(game:HttpGet(repo.."addons/ThemeManager.lua"))()
    local SaveManager=loadstring(game:HttpGet(repo.."addons/SaveManager.lua"))()
    local Options=Library.Options; local Toggles=Library.Toggles
    Library.ForceCheckbox=false; Library.ShowToggleFrameInKeybinds=true
    local connections={}
    local isLifetime=(isAdmin==true) or (tier=="Lifetime") or (tier=="Admin")
    local function getCharacter() return LocalPlayer.Character end
    local function getHumanoid() local c=getCharacter(); return c and c:FindFirstChild("Humanoid") end
    local function getRoot() local c=getCharacter(); return c and c:FindFirstChild("HumanoidRootPart") end
    local Window=Library:CreateWindow({Title="Rivals - thegxx",Footer="v"..CURRENT_VERSION.." | "..(isAdmin and "Admin" or tier or "User"),Icon=123123,NotifySide="Right",ShowCustomCursor=true})
    local Tabs={
        Aimbot=Window:AddTab("Aimbot & Precision","user"),
        Visuals=Window:AddTab("Visuals & ESP","eye"),
        Movement=Window:AddTab("Movement & Mobility","running"),
        Protection=Window:AddTab("Protection & Survival","shield"),
        Rivals=Window:AddTab("Rivals Specific","gear"),
        Extras=Window:AddTab("UI & Extras","gear"),
        MapChanger=Window:AddTab("Map Colors","gear"),
        SkinChanger=Window:AddTab("Skin Changer","gear"),
        ["UI Settings"]=Window:AddTab("UI Settings","settings"),
        Info=Window:AddTab("Info","user"),
    }
    if isAdmin then Tabs.Admin=Window:AddTab("Admin Panel","shield") end
    local clockGui=Instance.new("ScreenGui"); clockGui.Name="RivalsClockOverlay"; clockGui.ResetOnSpawn=false; clockGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; clockGui.Parent=game.CoreGui
    local cFrame=Instance.new("Frame",clockGui); cFrame.Size=UDim2.new(0,120,0,28); cFrame.Position=UDim2.new(1,-130,0,10); cFrame.BackgroundColor3=Color3.fromRGB(10,10,16); cFrame.BackgroundTransparency=0.3; cFrame.BorderSizePixel=0; Instance.new("UICorner",cFrame).CornerRadius=UDim.new(0,8); Instance.new("UIStroke",cFrame).Color=Color3.fromRGB(100,60,200)
    local cLabel=Instance.new("TextLabel",cFrame); cLabel.Size=UDim2.new(1,0,1,0); cLabel.BackgroundTransparency=1; cLabel.TextColor3=Color3.fromRGB(200,160,255); cLabel.TextSize=13; cLabel.Font=Enum.Font.GothamBold; cLabel.Text="00:00:00"
    connections["Clock"]=RunService.Heartbeat:Connect(function() cLabel.Text=os.date("%X") end)
    Library:Notify("Rivals v"..CURRENT_VERSION.." - "..(isAdmin and "Admin" or tier or "User").." Loaded!",4)
    local lastAnn=""
    if not isAdmin then
        task.spawn(function()
            while task.wait(2) do
                if not accessGranted then break end
                pcall(function()
                    local sn=LocalPlayer.Name:lower():gsub("[^%w_]","_")
                    local bln=fbGet("/blacklist/"..sn); local bli=fbGet("/blacklist/id_"..tostring(LocalPlayer.UserId))
                    if bln or bli then LocalPlayer:Kick(kickMsg(tostring(bln or bli))); return end
                    local ann=fbGet("/announcement") or ""
                    if type(ann)=="string" and ann~="" and ann~=lastAnn then lastAnn=ann; Library:Notify(ann,8) end
                    if currentUserKey then
                        local kd=fbGet("/keys/"..currentUserKey)
                        if not kd or (kd.tier~="Lifetime" and kd.expiry~=0 and os.time()>kd.expiry) then featuresLocked=true; clearKey(); Library:Notify("Key expired. Contact admin.",6) end
                    end
                end)
            end
        end)
    end
    featuresLocked=false
    if isAdmin and Tabs.Admin then
        local AGG=Tabs.Admin:AddLeftGroupbox("Generate Key"); local ABG=Tabs.Admin:AddRightGroupbox("Blacklist")
        local ALG=Tabs.Admin:AddLeftGroupbox("Key Lookup"); local AAG=Tabs.Admin:AddRightGroupbox("Announce")
        local AWG=Tabs.Admin:AddLeftGroupbox("Whitelist"); local ABLG=Tabs.Admin:AddRightGroupbox("Blacklisted Users")
        local lkLabel=AGG:AddLabel("Last Generated: None"); AGG:AddDivider()
        local function onGen(t)
            Library:Notify("Generating "..t.." key...",2)
            task.spawn(function() local k,s=generateKey(t); lkLabel:SetText("Last: "..k); showKeyPopup(k); Library:Notify(s and t.." key saved!" or "Failed!",s and 3 or 5) end)
        end
        AGG:AddButton("[W] Generate Weekly Key",function() onGen("Weekly") end)
        AGG:AddButton("[M] Generate Monthly Key",function() onGen("Monthly") end)
        AGG:AddButton("[L] Generate Lifetime Key",function() onGen("Lifetime") end)
        ABG:AddLabel("Blacklist or unblacklist by username."); ABG:AddDivider()
        local blUser=""
        ABG:AddInput("BlacklistInput",{Default="",Numeric=false,Finished=false,Text="Username",Placeholder="Enter username...",Callback=function(v) blUser=v end})
        ABG:AddButton("Blacklist User",function()
            if blUser=="" then Library:Notify("Enter a username.",3) return end
            local name=blUser
            local rGui=Instance.new("ScreenGui"); rGui.Name="ReasonPop"; rGui.ResetOnSpawn=false; rGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; rGui.Parent=game.CoreGui
            local ov2=Instance.new("Frame",rGui); ov2.Size=UDim2.new(1,0,1,0); ov2.BackgroundColor3=Color3.fromRGB(0,0,0); ov2.BackgroundTransparency=0.5; ov2.BorderSizePixel=0
            local pop=Instance.new("Frame",rGui); pop.Size=UDim2.new(0,360,0,180); pop.Position=UDim2.new(0.5,-180,0.5,-90); pop.BackgroundColor3=Color3.fromRGB(10,10,16); pop.BorderSizePixel=0; Instance.new("UICorner",pop).CornerRadius=UDim.new(0,14); local s2=Instance.new("UIStroke",pop); s2.Color=Color3.fromRGB(220,50,50); s2.Thickness=2
            local pt=Instance.new("TextLabel",pop); pt.Size=UDim2.new(1,0,0,36); pt.Position=UDim2.new(0,0,0,8); pt.BackgroundTransparency=1; pt.Text="Blacklist: "..name; pt.TextColor3=Color3.fromRGB(220,80,80); pt.TextSize=15; pt.Font=Enum.Font.GothamBold
            local rBg2=Instance.new("Frame",pop); rBg2.Size=UDim2.new(1,-32,0,40); rBg2.Position=UDim2.new(0,16,0,50); rBg2.BackgroundColor3=Color3.fromRGB(18,18,28); rBg2.BorderSizePixel=0; Instance.new("UICorner",rBg2).CornerRadius=UDim.new(0,8)
            local rIn=Instance.new("TextBox",rBg2); rIn.Size=UDim2.new(1,-16,1,0); rIn.Position=UDim2.new(0,8,0,0); rIn.BackgroundTransparency=1; rIn.PlaceholderText="Enter reason..."; rIn.PlaceholderColor3=Color3.fromRGB(80,80,100); rIn.Text=""; rIn.TextColor3=Color3.fromRGB(230,230,230); rIn.TextSize=13; rIn.Font=Enum.Font.Gotham; rIn.ClearTextOnFocus=false
            local stLbl=Instance.new("TextLabel",pop); stLbl.Size=UDim2.new(1,-32,0,16); stLbl.Position=UDim2.new(0,16,0,98); stLbl.BackgroundTransparency=1; stLbl.Text=""; stLbl.TextColor3=Color3.fromRGB(220,80,80); stLbl.TextSize=11; stLbl.Font=Enum.Font.Gotham; stLbl.TextXAlignment=Enum.TextXAlignment.Left
            local cfBtn=Instance.new("TextButton",pop); cfBtn.Size=UDim2.new(0.47,0,0,34); cfBtn.Position=UDim2.new(0,16,1,-44); cfBtn.BackgroundColor3=Color3.fromRGB(180,40,50); cfBtn.BorderSizePixel=0; cfBtn.Text="Blacklist"; cfBtn.TextColor3=Color3.fromRGB(255,255,255); cfBtn.TextSize=13; cfBtn.Font=Enum.Font.GothamBold; Instance.new("UICorner",cfBtn).CornerRadius=UDim.new(0,8)
            local cnBtn=Instance.new("TextButton",pop); cnBtn.Size=UDim2.new(0.47,0,0,34); cnBtn.Position=UDim2.new(0.53,-16,1,-44); cnBtn.BackgroundColor3=Color3.fromRGB(40,40,60); cnBtn.BorderSizePixel=0; cnBtn.Text="Cancel"; cnBtn.TextColor3=Color3.fromRGB(200,200,200); cnBtn.TextSize=13; cnBtn.Font=Enum.Font.GothamBold; Instance.new("UICorner",cnBtn).CornerRadius=UDim.new(0,8)
            cnBtn.MouseButton1Click:Connect(function() rGui:Destroy() end)
            cfBtn.MouseButton1Click:Connect(function()
                local reason=rIn.Text; if reason=="" then reason="Blacklisted by moderator" end
                cfBtn.Text="Saving..."; stLbl.Text="Blacklisting "..name.."..."
                task.spawn(function()
                    local ok,msg=blacklistUser(name,reason)
                    if ok then stLbl.TextColor3=Color3.fromRGB(80,220,100); stLbl.Text="Done!"; Library:Notify(msg,3); blUser=""; Options.BlacklistInput:SetValue(""); task.wait(1); rGui:Destroy()
                    else stLbl.TextColor3=Color3.fromRGB(220,80,80); stLbl.Text=msg; cfBtn.Text="Blacklist" end
                end)
            end)
        end)
        ABG:AddButton("Unblacklist User",function()
            if blUser=="" then Library:Notify("Enter a username.",3) return end
            local name=blUser
            task.spawn(function() local ok,msg=unblacklistUser(name); Library:Notify(msg,ok and 3 or 5); if ok then blUser=""; Options.BlacklistInput:SetValue("") end end)
        end)
        ALG:AddLabel("Type username to find their key."); ALG:AddDivider()
        local lookUser=""
        ALG:AddInput("LookupInput",{Default="",Numeric=false,Finished=false,Text="Username",Placeholder="Enter username...",Callback=function(v) lookUser=v end})
        local lk1=ALG:AddLabel("Key Pt1: -"); local lk2=ALG:AddLabel("Key Pt2: -")
        local lkT=ALG:AddLabel("Tier: -"); local lkS=ALG:AddLabel("Status: -"); local lkE=ALG:AddLabel("Expires: -")
        local lfk=""
        ALG:AddButton("Lookup by Username",function()
            if lookUser=="" then Library:Notify("Enter a username.",3) return end
            Library:Notify("Searching...",2)
            task.spawn(function()
                local tid=nil; local ok=pcall(function() tid=Players:GetUserIdFromNameAsync(lookUser) end)
                if not ok or not tid then Library:Notify("Not found: "..lookUser,4); lk1:SetText("Not found"); lfk=""; return end
                local keys=fbGet("/keys") or {}; local fk,fd=nil,nil
                for k,d in pairs(keys) do if tostring(d.userId)==tostring(tid) then fk=k; fd=d; break end end
                if not fk then Library:Notify("No key for "..lookUser,3); lk1:SetText("Not found"); lfk=""; return end
                lfk=fk; local half=math.floor(#fk/2)
                lk1:SetText("Key: "..fk:sub(1,half)); lk2:SetText(fk:sub(half+1)); lkT:SetText("Tier: "..fd.tier); lkS:SetText("Status: "..fd.status)
                local es=(fd.tier=="Lifetime" or fd.expiry==0) and "Never" or (math.floor(math.max(0,fd.expiry-os.time())/86400).."d")
                lkE:SetText("Expires: "..es); Library:Notify("Found!",3)
            end)
        end)
        ALG:AddButton("Copy Found Key",function() if lfk=="" then Library:Notify("Look up first.",3) return end; setclipboard(lfk); Library:Notify("Copied!",3) end)
        ALG:AddButton("Reset Found Key",function() if lfk=="" then Library:Notify("Look up first.",3) return end; task.spawn(function() local ok,msg=resetKey(lfk); Library:Notify(msg,3); if ok then lfk="" end end) end)
        ALG:AddButton("Delete Found Key",function() if lfk=="" then Library:Notify("Look up first.",3) return end; task.spawn(function() local ok,msg=deleteKey(lfk); Library:Notify(msg,3); if ok then lfk="" end end) end)
        AAG:AddLabel("Message shown to all users."); AAG:AddDivider()
        local annMsg=""
        AAG:AddInput("AnnounceInput",{Default="",Numeric=false,Finished=false,Text="Message",Placeholder="Type announcement...",Callback=function(v) annMsg=v end})
        AAG:AddButton("Send Announcement",function()
            if annMsg=="" then Library:Notify("Enter a message.",3) return end
            task.spawn(function() local ok,msg=sendAnnouncement(annMsg); Library:Notify(msg,ok and 3 or 5); if ok then annMsg=""; Options.AnnounceInput:SetValue(""); task.wait(30); clearAnnouncement() end end)
        end)
        AAG:AddDivider()
        local updMsg=""
        AAG:AddInput("UpdateInput",{Default="",Numeric=false,Finished=false,Text="Update Notes",Placeholder="What changed...",Callback=function(v) updMsg=v end})
        AAG:AddButton("Log Script Update",function()
            if updMsg=="" then Library:Notify("Enter description.",3) return end
            hUpdate("Script Updated v"..CURRENT_VERSION,"By: "..modUsername.."\nChanges: "..updMsg)
            Library:Notify("Update logged!",3); updMsg=""; Options.UpdateInput:SetValue("")
        end)
        AWG:AddLabel("Whitelisted users get full admin access."); AWG:AddDivider()
        local wlUser=""
        AWG:AddInput("WhitelistInput",{Default="",Numeric=false,Finished=false,Text="Username",Placeholder="Enter username...",Callback=function(v) wlUser=v end})
        AWG:AddButton("Add to Whitelist",function() if wlUser=="" then Library:Notify("Enter a username.",3) return end; local name=wlUser; task.spawn(function() local ok,msg=addWhitelist(name); Library:Notify(msg,ok and 3 or 5); if ok then wlUser=""; Options.WhitelistInput:SetValue("") end end) end)
        AWG:AddButton("Remove from Whitelist",function() if wlUser=="" then Library:Notify("Enter a username.",3) return end; local name=wlUser; task.spawn(function() local ok,msg=removeWhitelist(name); Library:Notify(msg,ok and 3 or 5); if ok then wlUser=""; Options.WhitelistInput:SetValue("") end end) end)
        AWG:AddButton("Check if Whitelisted",function() if wlUser=="" then Library:Notify("Enter a username.",3) return end; local name=wlUser; task.spawn(function() local isWL=checkWhitelist(name); Library:Notify(name..(isWL and " IS whitelisted." or " is NOT whitelisted."),3) end) end)
        AWG:AddDivider()
        local wlListLabel=AWG:AddLabel("Press refresh to load.")
        AWG:AddButton("Refresh Whitelist",function()
            task.spawn(function()
                local wl=fbGet("/whitelist") or {}; local count=0; local lines={}
                for u,d in pairs(wl) do count=count+1; local ab=type(d)=="table" and (d.addedBy or "?") or "?"; lines[#lines+1]=u.." (by "..ab..")" end
                wlListLabel:SetText(count==0 and "No whitelisted users." or count.." users:\n"..table.concat(lines,"\n")); Library:Notify("Loaded "..count.." users.",3)
            end)
        end)
        local bllLabel=ABLG:AddLabel("Press refresh to load."); ABLG:AddDivider()
        ABLG:AddButton("Refresh Blacklist",function()
            task.spawn(function()
                local bl=fbGet("/blacklist") or {}; local count=0; local lines={}
                for u,r in pairs(bl) do if u:sub(1,3)~="id_" then count=count+1; lines[#lines+1]=u.." - "..tostring(r) end end
                bllLabel:SetText(count==0 and "No blacklisted users." or count.." users:\n"..table.concat(lines,"\n")); Library:Notify("Loaded "..count.." users.",3)
            end)
        end)
    end

    local aimDeadCheck=true; local aimWallCheck=true; local aimPriority="Distance"; local aimFOV=500; local aimMaxDistance=0
    local function isValidTarget(player)
        if player==LocalPlayer or not player.Character or not player.Character:FindFirstChild("Humanoid") or not player.Character:FindFirstChild("Head") then return false end
        if aimDeadCheck and player.Character.Humanoid.Health<=0 then return false end
        if aimMaxDistance>0 then local r=getRoot(); if r and (r.Position-player.Character.Head.Position).Magnitude>aimMaxDistance then return false end end
        if aimWallCheck then
            local ray=Ray.new(Camera.CFrame.Position,(player.Character.Head.Position-Camera.CFrame.Position).Unit*500)
            local part=Workspace:FindPartOnRayWithIgnoreList(ray,{getCharacter()})
            return part and part:IsDescendantOf(player.Character)
        end
        return true
    end
    local function getClosestPlayer(fov)
        local closest,closestValue=nil,math.huge
        local center=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
        for _,player in ipairs(Players:GetPlayers()) do
            if not isValidTarget(player) then continue end
            local pos,onScreen=Camera:WorldToViewportPoint(player.Character.Head.Position)
            if not onScreen then continue end
            local dist=(center-Vector2.new(pos.X,pos.Y)).Magnitude
            if dist>(fov or math.huge) then continue end
            local value=aimPriority=="Distance" and dist or player.Character.Humanoid.Health
            if value<closestValue then closestValue=value; closest=player end
        end
        return closest
    end
    local AimbotMainGroupBox=Tabs.Aimbot:AddLeftGroupbox("Aimbot Main Settings")
    local AimbotFOVGroupBox=Tabs.Aimbot:AddRightGroupbox("FOV Settings")
    local aimbotEnabled=false; local aimbotMode="Rage"; local aimbotLock="Head"; local aimbotAutoFire=false; local aimbotPrediction=false; local aimbotSensitivity=1
    AimbotMainGroupBox:AddToggle("AimbotToggle",{Text="Enable Aimbot",Default=false,Callback=function(v) if featuresLocked then Toggles.AimbotToggle:SetValue(false) return end; aimbotEnabled=v end})
    AimbotMainGroupBox:AddLabel("Aimbot Keybind"):AddKeyPicker("AimbotKeybind",{Default="MB2",Mode="Hold",Text="Aimbot Key",NoUI=false,SyncToggleState=false,Callback=function(v) if featuresLocked then return end; aimbotEnabled=v end})
    AimbotMainGroupBox:AddDropdown("AimbotMode",{Values={"Rage","Legit"},Default=1,Multi=false,Text="Aimbot Mode",Callback=function(v) aimbotMode=v end})
    AimbotMainGroupBox:AddDropdown("AimbotLock",{Values={"Head","Torso"},Default=1,Multi=false,Text="Lock Target",Callback=function(v) aimbotLock=v end})
    AimbotMainGroupBox:AddToggle("AimbotAutoFire",{Text="Auto-Fire",Default=false,Callback=function(v) if featuresLocked then Toggles.AimbotAutoFire:SetValue(false) return end; aimbotAutoFire=v end})
    AimbotMainGroupBox:AddToggle("AimbotPrediction",{Text="Movement Prediction",Default=false,Callback=function(v) if featuresLocked then Toggles.AimbotPrediction:SetValue(false) return end; aimbotPrediction=v end})
    AimbotMainGroupBox:AddSlider("AimbotSensitivity",{Text="Sensitivity (Legit)",Default=1,Min=0.1,Max=5,Rounding=1,Callback=function(v) aimbotSensitivity=v end})
    AimbotMainGroupBox:AddDropdown("AimPriority",{Values={"Distance","Health"},Default=1,Multi=false,Text="Priority",Callback=function(v) aimPriority=v end})
    AimbotMainGroupBox:AddSlider("AimMaxDistance",{Text="Max Distance",Default=0,Min=0,Max=1000,Rounding=0,Suffix=" studs",Callback=function(v) aimMaxDistance=v end})
    AimbotMainGroupBox:AddToggle("AimDeadCheck",{Text="Dead Check",Default=true,Callback=function(v) aimDeadCheck=v end})
    AimbotMainGroupBox:AddToggle("AimWallCheck",{Text="Wall Check",Default=true,Callback=function(v) aimWallCheck=v end})
    AimbotFOVGroupBox:AddSlider("AimFOV",{Text="Aimbot FOV",Default=500,Min=100,Max=1000,Rounding=0,Callback=function(v) aimFOV=v end})
    local silentAimEnabled=false; local silentAimHitchance=50
    AimbotFOVGroupBox:AddToggle("SilentAimToggle",{Text="Silent Aim",Default=false,Callback=function(v) if featuresLocked then Toggles.SilentAimToggle:SetValue(false) return end; silentAimEnabled=v end})
    AimbotFOVGroupBox:AddSlider("SilentAimHitchance",{Text="Hitchance",Default=50,Min=0,Max=100,Rounding=0,Suffix="%",Callback=function(v) silentAimHitchance=v end})
    local fovCircleEnabled=false; local fovCircleSize=100; local fovCircleRainbow=false
    local fovCircle=Drawing.new("Circle"); fovCircle.Visible=false; fovCircle.Thickness=2; fovCircle.Color=Color3.new(1,1,1); fovCircle.Transparency=1; fovCircle.NumSides=64
    AimbotFOVGroupBox:AddToggle("FOVCircleToggle",{Text="FOV Circle",Default=false,Callback=function(v) if featuresLocked then Toggles.FOVCircleToggle:SetValue(false) return end; fovCircleEnabled=v; fovCircle.Visible=v end})
    AimbotFOVGroupBox:AddSlider("FOVCircleSize",{Text="FOV Circle Size",Default=100,Min=50,Max=500,Rounding=0,Suffix=" px",Callback=function(v) fovCircleSize=v end})
    AimbotFOVGroupBox:AddToggle("FOVCircleRainbow",{Text="Rainbow FOV",Default=false,Callback=function(v) fovCircleRainbow=v end})
    AimbotFOVGroupBox:AddDivider()
    local fovExtEnabled=false
    if isLifetime then
        AimbotFOVGroupBox:AddToggle("FOVExtendToggle",{Text="[L] FOV Extender",Default=false,Callback=function(v) fovExtEnabled=v; if not v then pcall(function() Camera.FieldOfView=70 end) end end})
        AimbotFOVGroupBox:AddSlider("FOVExtendSlider",{Text="Extended FOV",Default=120,Min=70,Max=179,Rounding=0,Suffix=" deg",Callback=function(v) if fovExtEnabled then pcall(function() Camera.FieldOfView=v end) end end})
    else AimbotFOVGroupBox:AddLabel("[L] FOV Extender - Lifetime Only") end
    RunService:BindToRenderStep("Aimbot",Enum.RenderPriority.Camera.Value,function(dt)
        if featuresLocked or not aimbotEnabled then return end
        local closest=getClosestPlayer(aimFOV)
        if closest and closest.Character then
            local targetPart=closest.Character:FindFirstChild(aimbotLock=="Head" and "Head" or "UpperTorso"); if not targetPart then return end
            local prediction=aimbotPrediction and targetPart.AssemblyLinearVelocity*0.1 or Vector3.zero
            local targetPos=targetPart.Position+prediction
            if aimbotMode=="Rage" then Camera.CFrame=CFrame.lookAt(Camera.CFrame.Position,targetPos)
            elseif aimbotMode=="Legit" then
                local currentLook=Camera.CFrame.LookVector; local targetLook=(targetPos-Camera.CFrame.Position).Unit
                Camera.CFrame=CFrame.lookAt(Camera.CFrame.Position,Camera.CFrame.Position+currentLook:Lerp(targetLook,math.clamp(aimbotSensitivity*dt*10,0.01,0.3)))
            end
            if aimbotAutoFire then local tool=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool"); if tool then tool:Activate() end end
        end
    end)
    pcall(function()
        local utility=require(ReplicatedStorage.Modules.Utility); local oldRaycast=utility.Raycast
        utility.Raycast=function(...)
            local args={...}
            if not featuresLocked and silentAimEnabled and #args>=3 and math.random(100)<=silentAimHitchance then
                local closest=getClosestPlayer(aimFOV); if closest and closest.Character and closest.Character:FindFirstChild("Head") then args[3]=closest.Character.Head.Position end
            end
            return oldRaycast(table.unpack(args))
        end
    end)
    connections["FOVCircle"]=RunService.RenderStepped:Connect(function()
        if not featuresLocked and fovCircleEnabled then
            fovCircle.Position=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2); fovCircle.Radius=fovCircleSize; fovCircle.Visible=true
            if fovCircleRainbow then fovCircle.Color=Color3.fromHSV(tick()%5/5,1,1) end
        else fovCircle.Visible=false end
    end)

    local VisualsLeftGroupBox=Tabs.Visuals:AddLeftGroupbox("Player ESP Options")
    local VisualsSkeletonGroupBox=Tabs.Visuals:AddRightGroupbox("Skeleton & Overlays")
    local VisualsOtherGroupBox=Tabs.Visuals:AddLeftGroupbox("Other Visuals")
    local playerESPEnabled=false; local boxESPEnabled=false; local chamsESPEnabled=false
    local playerESPName=true; local playerESPDistance=true; local playerESPHealth=true; local playerESPWeapon=true
    local rainbowModeEnabled=false; local deadESPEnabled=true
    local espStates={Box=false,Chams=false,Name=true,Distance=true,Health=true,Weapon=true,Skeleton=false,Tracers=false}
    local espBoxes={}; local espChams={}; local espTexts={}; local skeletonLines={}
    local tracerLines={}; local hBars3D={}; local hBars2D={}
    local function cleanupPlayerESP(player)
        if espBoxes[player] then pcall(function() espBoxes[player]:Remove() end); espBoxes[player]=nil end
        if espChams[player] then pcall(function() espChams[player]:Destroy() end); espChams[player]=nil end
        if espTexts[player] then pcall(function() espTexts[player]:Remove() end); espTexts[player]=nil end
        if skeletonLines[player] then
            if skeletonLines[player].lines then for _,line in pairs(skeletonLines[player].lines) do pcall(function() line:Remove() end) end end
            if skeletonLines[player].tracer then pcall(function() skeletonLines[player].tracer:Remove() end) end
            skeletonLines[player]=nil
        end
        if tracerLines[player] then pcall(function() tracerLines[player]:Remove() end); tracerLines[player]=nil end
        if hBars3D[player] then pcall(function() hBars3D[player].bg:Remove(); hBars3D[player].fill:Remove(); hBars3D[player].text:Remove() end); hBars3D[player]=nil end
    end
    local function createPlayerESP(player)
        if player==LocalPlayer or not player.Character then return end
        cleanupPlayerESP(player)
        local box=Drawing.new("Square"); box.Visible=false; box.Color=Color3.new(1,1,1); box.Thickness=2; box.Filled=false; box.Transparency=1; espBoxes[player]=box
        local cham=Instance.new("Highlight"); cham.Name="ESP_Cham_"..player.Name; cham.Parent=game.CoreGui; cham.Adornee=player.Character; cham.FillTransparency=0.5; cham.OutlineTransparency=0; cham.FillColor=Color3.new(1,1,1); cham.OutlineColor=Color3.new(1,1,1); cham.Enabled=false; espChams[player]=cham
        local text=Drawing.new("Text"); text.Visible=false; text.Color=Color3.new(1,1,1); text.Size=16; text.Center=true; text.Outline=true; text.Transparency=1; text.Font=2; espTexts[player]=text
    end
    local skeletonESPEnabled=false; local skeletonESPTracers=false
    local function toggleESPState()
        playerESPEnabled=not playerESPEnabled
        if playerESPEnabled then
            boxESPEnabled=espStates.Box; chamsESPEnabled=espStates.Chams; playerESPName=espStates.Name; playerESPDistance=espStates.Distance; playerESPHealth=espStates.Health; playerESPWeapon=espStates.Weapon; skeletonESPEnabled=espStates.Skeleton; skeletonESPTracers=espStates.Tracers
            for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer and p.Character then createPlayerESP(p) end end
            Library:Notify("ESP Enabled!",2)
        else
            espStates.Box=boxESPEnabled; espStates.Chams=chamsESPEnabled; espStates.Name=playerESPName; espStates.Distance=playerESPDistance; espStates.Health=playerESPHealth; espStates.Weapon=playerESPWeapon; espStates.Skeleton=skeletonESPEnabled; espStates.Tracers=skeletonESPTracers
            boxESPEnabled=false; chamsESPEnabled=false; skeletonESPEnabled=false; skeletonESPTracers=false
            for player in pairs(espBoxes) do cleanupPlayerESP(player) end
            Library:Notify("ESP Disabled!",2)
        end
        Toggles.BoxESPToggle:SetValue(boxESPEnabled); Toggles.ChamsESPToggle:SetValue(chamsESPEnabled)
        Toggles.SkeletonESPToggle:SetValue(skeletonESPEnabled); Toggles.SkeletonESPTracers:SetValue(skeletonESPTracers)
    end
    VisualsLeftGroupBox:AddLabel("ESP Master Keybind"):AddKeyPicker("ESPKeybind",{Default="P",Mode="Toggle",Text="ESP Master Key",NoUI=false,Callback=function(v) toggleESPState() end})
    VisualsLeftGroupBox:AddToggle("PlayerESPToggle",{Text="Enable Player ESP",Default=false,Callback=function(v) if featuresLocked then Toggles.PlayerESPToggle:SetValue(false) return end; playerESPEnabled=v end})
    VisualsLeftGroupBox:AddToggle("BoxESPToggle",{Text="Box ESP",Default=false,Callback=function(v) if featuresLocked then Toggles.BoxESPToggle:SetValue(false) return end; boxESPEnabled=v; espStates.Box=v end})
    VisualsLeftGroupBox:AddToggle("ChamsESPToggle",{Text="Chams ESP",Default=false,Callback=function(v) if featuresLocked then Toggles.ChamsESPToggle:SetValue(false) return end; chamsESPEnabled=v; espStates.Chams=v end})
    VisualsLeftGroupBox:AddToggle("PlayerESPName",{Text="Name",Default=true,Callback=function(v) playerESPName=v; espStates.Name=v end})
    VisualsLeftGroupBox:AddToggle("PlayerESPDistance",{Text="Distance",Default=true,Callback=function(v) playerESPDistance=v; espStates.Distance=v end})
    VisualsLeftGroupBox:AddToggle("PlayerESPHealth",{Text="Health",Default=true,Callback=function(v) playerESPHealth=v; espStates.Health=v end})
    VisualsLeftGroupBox:AddToggle("PlayerESPWeapon",{Text="Equipped Weapon",Default=true,Callback=function(v) playerESPWeapon=v; espStates.Weapon=v end})
    VisualsLeftGroupBox:AddDivider()
    local lowHPGui=Instance.new("ScreenGui"); lowHPGui.Name="RivalsLowHP"; lowHPGui.ResetOnSpawn=false; lowHPGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; lowHPGui.Parent=game.CoreGui
    local lowHPEnabled=false; local lowHPThresh=30
    local lowHPFrame=Instance.new("Frame",lowHPGui); lowHPFrame.Size=UDim2.new(1,0,1,0); lowHPFrame.BackgroundColor3=Color3.fromRGB(255,0,0); lowHPFrame.BackgroundTransparency=1; lowHPFrame.BorderSizePixel=0; lowHPFrame.Visible=false
    local lowHPLbl=Instance.new("TextLabel",lowHPFrame); lowHPLbl.Size=UDim2.new(1,0,0,40); lowHPLbl.Position=UDim2.new(0,0,0.5,-20); lowHPLbl.BackgroundTransparency=1; lowHPLbl.Text="ENEMY LOW HP!"; lowHPLbl.TextColor3=Color3.fromRGB(255,60,60); lowHPLbl.TextSize=28; lowHPLbl.Font=Enum.Font.GothamBold
    VisualsLeftGroupBox:AddToggle("LowHPAlertToggle",{Text="Low HP Alert",Default=false,Callback=function(v) lowHPEnabled=v; if not v then lowHPFrame.Visible=false end end})
    VisualsLeftGroupBox:AddSlider("LowHPThreshold",{Text="Low HP Threshold",Default=30,Min=5,Max=80,Rounding=0,Suffix="%",Callback=function(v) lowHPThresh=v end})
    VisualsLeftGroupBox:AddDivider()
    local hBar3DEnabled=false; local tracerEnabled=false; local hBar2DEnabled=false
    if isLifetime then
        VisualsLeftGroupBox:AddToggle("HealthBar3DToggle",{Text="[L] 3D Health Bars",Default=false,Callback=function(v) if featuresLocked then Toggles.HealthBar3DToggle:SetValue(false) return end; hBar3DEnabled=v end})
        VisualsLeftGroupBox:AddToggle("TracerToggle",{Text="[L] Player Tracers",Default=false,Callback=function(v) if featuresLocked then Toggles.TracerToggle:SetValue(false) return end; tracerEnabled=v end})
        VisualsLeftGroupBox:AddToggle("HealthBar2DToggle",{Text="[L] 2D Health Bars",Default=false,Callback=function(v) if featuresLocked then Toggles.HealthBar2DToggle:SetValue(false) return end; hBar2DEnabled=v end})
    else
        VisualsLeftGroupBox:AddLabel("[L] 3D Health Bars - Lifetime Only")
        VisualsLeftGroupBox:AddLabel("[L] Player Tracers - Lifetime Only")
        VisualsLeftGroupBox:AddLabel("[L] 2D Health Bars - Lifetime Only")
    end
    local function setupPlayerESP(player)
        if player==LocalPlayer then return end
        player.CharacterAdded:Connect(function() task.wait(0.1); if playerESPEnabled then createPlayerESP(player) end end)
        player.CharacterRemoving:Connect(function() cleanupPlayerESP(player) end)
        if player.Character then task.wait(0.1); createPlayerESP(player) end
    end
    for _,p in ipairs(Players:GetPlayers()) do setupPlayerESP(p) end
    Players.PlayerAdded:Connect(setupPlayerESP); Players.PlayerRemoving:Connect(cleanupPlayerESP)
    local lowHPFlash=0
    connections["LowHPAlert"]=RunService.Heartbeat:Connect(function(dt)
        if not lowHPEnabled or featuresLocked then lowHPFrame.Visible=false; return end
        local anyLow=false
        for _,p in ipairs(Players:GetPlayers()) do
            if p==LocalPlayer or not p.Character then continue end
            local h=p.Character:FindFirstChild("Humanoid"); if not h or h.Health<=0 then continue end
            if (h.Health/h.MaxHealth)*100<=lowHPThresh then anyLow=true; break end
        end
        if anyLow then lowHPFlash=lowHPFlash+dt*4; lowHPFrame.BackgroundTransparency=0.85+math.sin(lowHPFlash)*0.14; lowHPFrame.Visible=true
        else lowHPFrame.Visible=false; lowHPFlash=0 end
    end)
    connections["PlayerESP"]=RunService.Heartbeat:Connect(function()
        if featuresLocked or not playerESPEnabled then return end
        local rainbowColor=Color3.fromHSV(tick()%5/5,1,1)
        for _,player in ipairs(Players:GetPlayers()) do
            if player==LocalPlayer then continue end
            if not player.Character or not player.Character.Parent then cleanupPlayerESP(player); continue end
            local humanoid=player.Character:FindFirstChild("Humanoid"); local root=player.Character:FindFirstChild("HumanoidRootPart")
            if not humanoid or not root then cleanupPlayerESP(player); continue end
            if deadESPEnabled and humanoid.Health<=0 then cleanupPlayerESP(player); continue end
            if not espBoxes[player] then createPlayerESP(player) end
            local rootPos,onScreen=Camera:WorldToViewportPoint(root.Position)
            if onScreen then
                if espTexts[player] then
                    local textStr=""
                    if playerESPName then textStr=textStr..player.Name.."\n" end
                    if playerESPDistance then local r=getRoot(); if r then textStr=textStr..math.floor((r.Position-root.Position).Magnitude).." studs\n" end end
                    if playerESPHealth then textStr=textStr..math.floor(humanoid.Health).."/"..humanoid.MaxHealth.."\n" end
                    if playerESPWeapon then local tool=player.Character:FindFirstChildOfClass("Tool") or player.Backpack:FindFirstChildOfClass("Tool"); if tool then textStr=textStr..tool.Name end end
                    espTexts[player].Text=textStr; espTexts[player].Position=Vector2.new(rootPos.X,rootPos.Y-50); espTexts[player].Visible=true
                    if rainbowModeEnabled then espTexts[player].Color=rainbowColor end
                end
                if boxESPEnabled and espBoxes[player] then
                    local minX,minY,maxX,maxY=math.huge,math.huge,-math.huge,-math.huge
                    for _,part in ipairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            local corners={part.CFrame*CFrame.new(part.Size.X/2,part.Size.Y/2,part.Size.Z/2).Position,part.CFrame*CFrame.new(part.Size.X/2,part.Size.Y/2,-part.Size.Z/2).Position,part.CFrame*CFrame.new(part.Size.X/2,-part.Size.Y/2,part.Size.Z/2).Position,part.CFrame*CFrame.new(part.Size.X/2,-part.Size.Y/2,-part.Size.Z/2).Position,part.CFrame*CFrame.new(-part.Size.X/2,part.Size.Y/2,part.Size.Z/2).Position,part.CFrame*CFrame.new(-part.Size.X/2,part.Size.Y/2,-part.Size.Z/2).Position,part.CFrame*CFrame.new(-part.Size.X/2,-part.Size.Y/2,part.Size.Z/2).Position,part.CFrame*CFrame.new(-part.Size.X/2,-part.Size.Y/2,-part.Size.Z/2).Position}
                            for _,corner in ipairs(corners) do local pos=Camera:WorldToViewportPoint(corner); minX=math.min(minX,pos.X); maxX=math.max(maxX,pos.X); minY=math.min(minY,pos.Y); maxY=math.max(maxY,pos.Y) end
                        end
                    end
                    espBoxes[player].Size=Vector2.new(maxX-minX,maxY-minY); espBoxes[player].Position=Vector2.new(minX,minY); espBoxes[player].Visible=true
                    if rainbowModeEnabled then espBoxes[player].Color=rainbowColor end
                end
                if isLifetime and hBar3DEnabled then
                    if not hBars3D[player] then local bg=Drawing.new("Square"); bg.Visible=false; bg.Color=Color3.fromRGB(40,40,40); bg.Filled=true; bg.Transparency=1; local fill=Drawing.new("Square"); fill.Visible=false; fill.Filled=true; fill.Transparency=1; local ht=Drawing.new("Text"); ht.Visible=false; ht.Color=Color3.new(1,1,1); ht.Size=11; ht.Center=true; ht.Outline=true; ht.Transparency=1; hBars3D[player]={bg=bg,fill=fill,text=ht} end
                    local hp=humanoid.Health; local mhp=humanoid.MaxHealth; local pct=math.clamp(hp/mhp,0,1); local bx=rootPos.X-20; local by=rootPos.Y+20
                    hBars3D[player].bg.Size=Vector2.new(40,5); hBars3D[player].bg.Position=Vector2.new(bx,by); hBars3D[player].bg.Visible=true
                    hBars3D[player].fill.Size=Vector2.new(40*pct,5); hBars3D[player].fill.Position=Vector2.new(bx,by); hBars3D[player].fill.Color=Color3.fromRGB(math.floor(255*(1-pct)),math.floor(255*pct),50); hBars3D[player].fill.Visible=true
                    hBars3D[player].text.Text=math.floor(hp).."/"..math.floor(mhp); hBars3D[player].text.Position=Vector2.new(rootPos.X,by+6); hBars3D[player].text.Visible=true
                elseif hBars3D[player] then hBars3D[player].bg.Visible=false; hBars3D[player].fill.Visible=false; hBars3D[player].text.Visible=false end
                if isLifetime and tracerEnabled then
                    if not tracerLines[player] then local tl=Drawing.new("Line"); tl.Thickness=1; tl.Transparency=1; tracerLines[player]=tl end
                    tracerLines[player].From=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y); tracerLines[player].To=Vector2.new(rootPos.X,rootPos.Y); tracerLines[player].Color=rainbowModeEnabled and rainbowColor or Color3.new(1,1,1); tracerLines[player].Visible=true
                elseif tracerLines[player] then tracerLines[player].Visible=false end
            else
                if espTexts[player] then espTexts[player].Visible=false end
                if espBoxes[player] then espBoxes[player].Visible=false end
                if hBars3D[player] then hBars3D[player].bg.Visible=false; hBars3D[player].fill.Visible=false; hBars3D[player].text.Visible=false end
                if tracerLines[player] then tracerLines[player].Visible=false end
            end
            if chamsESPEnabled and espChams[player] then
                if espChams[player].Adornee~=player.Character then espChams[player].Adornee=player.Character end
                espChams[player].Enabled=true
                if rainbowModeEnabled then espChams[player].FillColor=rainbowColor; espChams[player].OutlineColor=rainbowColor end
            elseif espChams[player] then espChams[player].Enabled=false end
        end
    end)
    connections["HealthBar2D"]=RunService.Heartbeat:Connect(function()
        if featuresLocked or not isLifetime or not hBar2DEnabled then for _,d in pairs(hBars2D) do pcall(function() d.outline.Visible=false; d.bg.Visible=false; d.fill.Visible=false; d.text.Visible=false end) end; return end
        local sw=Camera.ViewportSize.X; local sh=Camera.ViewportSize.Y; local bw=6; local bmh=80; local bsp=14
        local pList={}
        for _,p in ipairs(Players:GetPlayers()) do if p==LocalPlayer then continue end; if not p.Character then continue end; local h=p.Character:FindFirstChild("Humanoid"); if not h or h.Health<=0 then continue end; pList[#pList+1]=p end
        if #pList==0 then return end
        local sy=sh/2-(#pList*(bsp+2))/2
        for i,p in ipairs(pList) do
            local h=p.Character:FindFirstChild("Humanoid"); if not h then continue end
            local hp=h.Health; local mhp=h.MaxHealth; local pct=math.clamp(hp/mhp,0,1); local fh=math.floor(bmh*pct)
            if not hBars2D[p] then
                local outline=Drawing.new("Square"); outline.Filled=false; outline.Color=Color3.fromRGB(0,0,0); outline.Thickness=3; outline.Transparency=1; outline.Visible=false
                local bg=Drawing.new("Square"); bg.Filled=true; bg.Color=Color3.fromRGB(30,30,30); bg.Transparency=1; bg.Visible=false
                local fill=Drawing.new("Square"); fill.Filled=true; fill.Transparency=1; fill.Visible=false
                local text=Drawing.new("Text"); text.Size=11; text.Center=true; text.Outline=true; text.Color=Color3.new(1,1,1); text.Transparency=1; text.Visible=false
                hBars2D[p]={outline=outline,bg=bg,fill=fill,text=text}
            end
            local d=hBars2D[p]; local xPos=sw-24; local yPos=sy+(i-1)*(bsp+2); local bc=Color3.fromRGB(math.floor(255*(1-pct)),math.floor(255*pct),50)
            d.outline.Size=Vector2.new(bw+2,bmh+2); d.outline.Position=Vector2.new(xPos-1,yPos-1); d.outline.Visible=true
            d.bg.Size=Vector2.new(bw,bmh); d.bg.Position=Vector2.new(xPos,yPos); d.bg.Visible=true
            d.fill.Size=Vector2.new(bw,fh); d.fill.Position=Vector2.new(xPos,yPos+(bmh-fh)); d.fill.Color=bc; d.fill.Visible=true
            d.text.Text=p.Name.."\n"..math.floor(hp).."/"..math.floor(mhp); d.text.Position=Vector2.new(xPos-4,yPos+bmh/2-10); d.text.Visible=true
        end
    end)
    VisualsSkeletonGroupBox:AddToggle("SkeletonESPToggle",{Text="Skeleton ESP",Default=false,Callback=function(v) if featuresLocked then Toggles.SkeletonESPToggle:SetValue(false) return end; skeletonESPEnabled=v; espStates.Skeleton=v end})
    VisualsSkeletonGroupBox:AddToggle("SkeletonESPTracers",{Text="Tracers",Default=false,Callback=function(v) if featuresLocked then Toggles.SkeletonESPTracers:SetValue(false) return end; skeletonESPTracers=v; espStates.Tracers=v end})
    local specGui=Instance.new("ScreenGui"); specGui.Name="RivalsSpec"; specGui.ResetOnSpawn=false; specGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; specGui.Parent=game.CoreGui
    local specEnabled=false; local antiSpecEnabled=false; local wasSpec=false
    local specFrame=Instance.new("Frame",specGui); specFrame.Size=UDim2.new(0,200,0,200); specFrame.Position=UDim2.new(0,10,0.5,-100); specFrame.BackgroundColor3=Color3.fromRGB(10,10,16); specFrame.BackgroundTransparency=0.3; specFrame.BorderSizePixel=0; specFrame.Visible=false; Instance.new("UICorner",specFrame).CornerRadius=UDim.new(0,8); Instance.new("UIStroke",specFrame).Color=Color3.fromRGB(100,60,200)
    local specTitle=Instance.new("TextLabel",specFrame); specTitle.Size=UDim2.new(1,0,0,24); specTitle.BackgroundTransparency=1; specTitle.Text="Spectators"; specTitle.TextColor3=Color3.fromRGB(200,160,255); specTitle.TextSize=13; specTitle.Font=Enum.Font.GothamBold
    local specScroll=Instance.new("ScrollingFrame",specFrame); specScroll.Size=UDim2.new(1,-8,1,-28); specScroll.Position=UDim2.new(0,4,0,26); specScroll.BackgroundTransparency=1; specScroll.BorderSizePixel=0; specScroll.ScrollBarThickness=3; specScroll.CanvasSize=UDim2.new(0,0,0,0); specScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
    Instance.new("UIListLayout",specScroll).Padding=UDim.new(0,2)
    if isLifetime then
        VisualsSkeletonGroupBox:AddDivider()
        VisualsSkeletonGroupBox:AddToggle("SpectatorListToggle",{Text="[L] Spectator List",Default=false,Callback=function(v) if featuresLocked then Toggles.SpectatorListToggle:SetValue(false) return end; specEnabled=v; specFrame.Visible=v end})
        VisualsSkeletonGroupBox:AddToggle("AntiSpectatorToggle",{Text="[L] Anti Spectator",Default=false,Callback=function(v) if featuresLocked then Toggles.AntiSpectatorToggle:SetValue(false) return end; antiSpecEnabled=v end})
    else
        VisualsSkeletonGroupBox:AddDivider()
        VisualsSkeletonGroupBox:AddLabel("[L] Spectator List - Lifetime Only")
        VisualsSkeletonGroupBox:AddLabel("[L] Anti Spectator - Lifetime Only")
    end
    connections["SkeletonESP"]=RunService.Heartbeat:Connect(function()
        if featuresLocked or not skeletonESPEnabled then return end
        local rainbowColor=Color3.fromHSV(tick()%5/5,1,1)
        for _,player in ipairs(Players:GetPlayers()) do
            if player==LocalPlayer then continue end
            if not player.Character or not player.Character.Parent then if skeletonLines[player] then cleanupPlayerESP(player) end; continue end
            local humanoid=player.Character:FindFirstChild("Humanoid"); if not humanoid or (deadESPEnabled and humanoid.Health<=0) then if skeletonLines[player] then cleanupPlayerESP(player) end; continue end
            if not skeletonLines[player] then skeletonLines[player]={lines={},tracer=nil}; for i=1,14 do local line=Drawing.new("Line"); line.Visible=false; line.Color=Color3.new(1,1,1); line.Thickness=2; line.Transparency=1; skeletonLines[player].lines[i]=line end end
            local char=player.Character
            local bonePairs={{char:FindFirstChild("Head"),char:FindFirstChild("UpperTorso")},{char:FindFirstChild("UpperTorso"),char:FindFirstChild("LowerTorso")},{char:FindFirstChild("UpperTorso"),char:FindFirstChild("LeftUpperArm")},{char:FindFirstChild("LeftUpperArm"),char:FindFirstChild("LeftLowerArm")},{char:FindFirstChild("LeftLowerArm"),char:FindFirstChild("LeftHand")},{char:FindFirstChild("UpperTorso"),char:FindFirstChild("RightUpperArm")},{char:FindFirstChild("RightUpperArm"),char:FindFirstChild("RightLowerArm")},{char:FindFirstChild("RightLowerArm"),char:FindFirstChild("RightHand")},{char:FindFirstChild("LowerTorso"),char:FindFirstChild("LeftUpperLeg")},{char:FindFirstChild("LeftUpperLeg"),char:FindFirstChild("LeftLowerLeg")},{char:FindFirstChild("LeftLowerLeg"),char:FindFirstChild("LeftFoot")},{char:FindFirstChild("LowerTorso"),char:FindFirstChild("RightUpperLeg")},{char:FindFirstChild("RightUpperLeg"),char:FindFirstChild("RightLowerLeg")},{char:FindFirstChild("RightLowerLeg"),char:FindFirstChild("RightFoot")}}
            for i,pair in ipairs(bonePairs) do
                local s,e=pair[1],pair[2]
                if s and e then
                    local ss,son=Camera:WorldToViewportPoint(s.Position); local es,eon=Camera:WorldToViewportPoint(e.Position)
                    local line=skeletonLines[player].lines[i]
                    if son and eon and line then line.From=Vector2.new(ss.X,ss.Y); line.To=Vector2.new(es.X,es.Y); line.Visible=true; if rainbowModeEnabled then line.Color=rainbowColor end
                    elseif line then line.Visible=false end
                elseif skeletonLines[player].lines[i] then skeletonLines[player].lines[i].Visible=false end
            end
            if skeletonESPTracers then
                local root=char:FindFirstChild("HumanoidRootPart")
                if root then
                    local rp,on=Camera:WorldToViewportPoint(root.Position)
                    if on then
                        if not skeletonLines[player].tracer then local t=Drawing.new("Line"); t.Thickness=2; t.Transparency=1; t.Color=Color3.new(1,1,1); skeletonLines[player].tracer=t end
                        skeletonLines[player].tracer.From=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y); skeletonLines[player].tracer.To=Vector2.new(rp.X,rp.Y); skeletonLines[player].tracer.Visible=true
                        if rainbowModeEnabled then skeletonLines[player].tracer.Color=rainbowColor end
                    else if skeletonLines[player].tracer then skeletonLines[player].tracer.Visible=false end end
                end
            else if skeletonLines[player] and skeletonLines[player].tracer then skeletonLines[player].tracer.Visible=false end end
        end
    end)
    connections["SpectatorCheck"]=RunService.Heartbeat:Connect(function()
        if not isLifetime or (not specEnabled and not antiSpecEnabled) then return end
        local myChar=getCharacter(); if not myChar then return end
        local curSpecs={}
        for _,p in ipairs(Players:GetPlayers()) do
            if p==LocalPlayer then continue end
            pcall(function()
                if not p.Character or not p.Character.Parent then
                    local cam=workspace.CurrentCamera
                    if cam and cam.CameraSubject and cam.CameraSubject:IsDescendantOf(myChar) then curSpecs[#curSpecs+1]=p.Name end
                end
            end)
        end
        if specEnabled then
            for _,child in pairs(specScroll:GetChildren()) do if child:IsA("TextLabel") then child:Destroy() end end
            if #curSpecs==0 then local lb=Instance.new("TextLabel",specScroll); lb.Size=UDim2.new(1,0,0,18); lb.BackgroundTransparency=1; lb.Text="None"; lb.TextColor3=Color3.fromRGB(120,120,140); lb.TextSize=11; lb.Font=Enum.Font.Gotham; lb.TextXAlignment=Enum.TextXAlignment.Left
            else for i,name in ipairs(curSpecs) do local lb=Instance.new("TextLabel",specScroll); lb.Size=UDim2.new(1,0,0,18); lb.LayoutOrder=i; lb.BackgroundTransparency=1; lb.Text="Watching: "..name; lb.TextColor3=Color3.fromRGB(255,120,120); lb.TextSize=11; lb.Font=Enum.Font.GothamBold; lb.TextXAlignment=Enum.TextXAlignment.Left end end
        end
        if antiSpecEnabled then local bs=#curSpecs>0; if bs and not wasSpec then Library:Notify("Being spectated by: "..table.concat(curSpecs,", "),5) end; wasSpec=bs end
    end)
    VisualsOtherGroupBox:AddToggle("DeadESPToggle",{Text="Hide Dead ESP",Default=true,Callback=function(v) deadESPEnabled=v end})
    VisualsOtherGroupBox:AddToggle("RainbowModeToggle",{Text="Rainbow Mode",Default=false,Callback=function(v) rainbowModeEnabled=v end})

    local MovementLeftGroupBox=Tabs.Movement:AddLeftGroupbox("Movement Options")
    local MovementRightGroupBox=Tabs.Movement:AddRightGroupbox("Speed Hack")
    local flyEnabled=false; local flySpeed=50; local flyBV=nil; local flyBG=nil
    local flyGoUp=false; local flyGoDown=false
    local flyJumpConn=nil

    -- Mobile on-screen fly buttons
    local flyGui=Instance.new("ScreenGui"); flyGui.Name="RivalsFlyButtons"; flyGui.ResetOnSpawn=false; flyGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; flyGui.Parent=game.CoreGui; flyGui.Enabled=false
    local flyUpBtn=Instance.new("TextButton",flyGui); flyUpBtn.Size=UDim2.new(0,80,0,80); flyUpBtn.Position=UDim2.new(1,-180,1,-200); flyUpBtn.BackgroundColor3=Color3.fromRGB(100,60,200); flyUpBtn.BackgroundTransparency=0.3; flyUpBtn.BorderSizePixel=0; flyUpBtn.Text="UP"; flyUpBtn.TextColor3=Color3.fromRGB(255,255,255); flyUpBtn.TextSize=18; flyUpBtn.Font=Enum.Font.GothamBold; Instance.new("UICorner",flyUpBtn).CornerRadius=UDim.new(1,0)
    local flyDownBtn=Instance.new("TextButton",flyGui); flyDownBtn.Size=UDim2.new(0,80,0,80); flyDownBtn.Position=UDim2.new(1,-90,1,-200); flyDownBtn.BackgroundColor3=Color3.fromRGB(60,60,180); flyDownBtn.BackgroundTransparency=0.3; flyDownBtn.BorderSizePixel=0; flyDownBtn.Text="DN"; flyDownBtn.TextColor3=Color3.fromRGB(255,255,255); flyDownBtn.TextSize=18; flyDownBtn.Font=Enum.Font.GothamBold; Instance.new("UICorner",flyDownBtn).CornerRadius=UDim.new(1,0)

    flyUpBtn.MouseButton1Down:Connect(function() flyGoUp=true end)
    flyUpBtn.MouseButton1Up:Connect(function() flyGoUp=false end)
    flyDownBtn.MouseButton1Down:Connect(function() flyGoDown=true end)
    flyDownBtn.MouseButton1Up:Connect(function() flyGoDown=false end)

    local function startFly()
        local root=getRoot(); local hum=getHumanoid()
        if not root or not hum then return end
        hum.PlatformStand=true
        if not flyBV then flyBV=Instance.new("BodyVelocity"); flyBV.MaxForce=Vector3.new(1e9,1e9,1e9); flyBV.Velocity=Vector3.zero; flyBV.Parent=root end
        if not flyBG then flyBG=Instance.new("BodyGyro"); flyBG.MaxTorque=Vector3.new(1e9,1e9,1e9); flyBG.P=1e4; flyBG.CFrame=root.CFrame; flyBG.Parent=root end
        flyGui.Enabled=true
    end
    local function stopFly()
        if flyBV then flyBV:Destroy(); flyBV=nil end
        if flyBG then flyBG:Destroy(); flyBG=nil end
        flyGoUp=false; flyGoDown=false
        flyGui.Enabled=false
        local hum=getHumanoid(); if hum then hum.PlatformStand=false end
    end
    MovementLeftGroupBox:AddToggle("FlyHackToggle",{Text="Fly Hack",Default=false,Callback=function(v)
        if featuresLocked then Toggles.FlyHackToggle:SetValue(false) return end
        flyEnabled=v; if v then startFly() else stopFly() end
    end})
    MovementLeftGroupBox:AddSlider("FlyHackSpeed",{Text="Fly Speed",Default=50,Min=1,Max=500,Rounding=0,Callback=function(v) flySpeed=v end})
    MovementLeftGroupBox:AddLabel("Fly Keybind"):AddKeyPicker("FlyKeybind",{Default="F",Mode="Toggle",Text="Fly Key",NoUI=false,Callback=function(v)
        if featuresLocked then return end; flyEnabled=v; Toggles.FlyHackToggle:SetValue(v)
        if v then startFly() else stopFly() end
    end})
    connections["Fly"]=RunService.Heartbeat:Connect(function()
        if featuresLocked or not flyEnabled then return end
        local root=getRoot(); local hum=getHumanoid()
        if not root then return end
        if not flyBV or not flyBV.Parent then startFly(); return end
        if hum then hum.PlatformStand=true end
        local moveDir=Vector3.new(0,0,0)
        -- Mobile thumbstick horizontal movement
        if hum and hum.MoveDirection.Magnitude>0 then
            moveDir=moveDir+Vector3.new(hum.MoveDirection.X,0,hum.MoveDirection.Z)
        end
        -- PC keyboard horizontal
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir=moveDir+Vector3.new(Camera.CFrame.LookVector.X,0,Camera.CFrame.LookVector.Z).Unit end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir=moveDir-Vector3.new(Camera.CFrame.LookVector.X,0,Camera.CFrame.LookVector.Z).Unit end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir=moveDir-Vector3.new(Camera.CFrame.RightVector.X,0,Camera.CFrame.RightVector.Z).Unit end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir=moveDir+Vector3.new(Camera.CFrame.RightVector.X,0,Camera.CFrame.RightVector.Z).Unit end
        -- Up - mobile UP button, PC Space, controller ButtonA
        local goUp=flyGoUp or UserInputService:IsKeyDown(Enum.KeyCode.Space) or UserInputService:IsKeyDown(Enum.KeyCode.ButtonA)
        -- Down - mobile DN button, PC LeftShift, controller ButtonB
        local goDown=flyGoDown or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.ButtonB)
        if goUp then moveDir=moveDir+Vector3.new(0,1,0) end
        if goDown then moveDir=moveDir-Vector3.new(0,1,0) end
        if moveDir.Magnitude>0 then flyBV.Velocity=moveDir.Unit*flySpeed else flyBV.Velocity=Vector3.zero end
        if flyBG and flyBG.Parent then flyBG.CFrame=CFrame.new(root.Position,root.Position+Camera.CFrame.LookVector) end
    end)
    LocalPlayer.CharacterAdded:Connect(function() flyBV=nil; flyBG=nil; if flyEnabled then task.wait(0.5); startFly() end end)
    local infJumpEnabled=false; local infJumpConnection
    MovementLeftGroupBox:AddDivider()
    MovementLeftGroupBox:AddToggle("InfiniteJumpToggle",{Text="Infinite Jump",Default=false,Callback=function(v)
        if featuresLocked then Toggles.InfiniteJumpToggle:SetValue(false) return end; infJumpEnabled=v
        if v then infJumpConnection=UserInputService.JumpRequest:Connect(function() local h=getHumanoid(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end)
        else if infJumpConnection then infJumpConnection:Disconnect(); infJumpConnection=nil end end
    end})
    local noClipEnabled=false
    MovementLeftGroupBox:AddToggle("NoClipToggle",{Text="No Clip",Default=false,Callback=function(v) if featuresLocked then Toggles.NoClipToggle:SetValue(false) return end; noClipEnabled=v end})
    connections["NoClip"]=RunService.Stepped:Connect(function()
        if featuresLocked or not noClipEnabled then return end
        pcall(function() for _,part in ipairs(getCharacter():GetDescendants()) do if part:IsA("BasePart") then part.CanCollide=false end end end)
    end)
    local speedEnabled=false; local speedValue=16; local originalSpeed=16
    local speedConn=nil
    local function applySpeed()
        if speedConn then pcall(function() speedConn:Disconnect() end); speedConn=nil end
        local hum=getHumanoid(); if not hum then return end
        -- Set immediately
        pcall(function() hum.WalkSpeed=speedValue end)
        -- Hook into property change to fight server resets
        speedConn=hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if featuresLocked or not speedEnabled then return end
            if hum and hum.WalkSpeed~=speedValue then
                pcall(function() hum.WalkSpeed=speedValue end)
            end
        end)
    end
    MovementRightGroupBox:AddLabel("Speed Hack"); MovementRightGroupBox:AddDivider()
    MovementRightGroupBox:AddToggle("SpeedHackToggle",{Text="Enable Speed Hack",Default=false,Callback=function(v)
        if featuresLocked then Toggles.SpeedHackToggle:SetValue(false) return end; speedEnabled=v
        if v then
            local hum=getHumanoid(); if hum then originalSpeed=hum.WalkSpeed end
            applySpeed()
        else
            if speedConn then pcall(function() speedConn:Disconnect() end); speedConn=nil end
            local hum=getHumanoid(); if hum then pcall(function() hum.WalkSpeed=originalSpeed end) end
        end
    end})
    MovementRightGroupBox:AddSlider("SpeedHackValue",{Text="Walk Speed",Default=16,Min=1,Max=200,Rounding=0,Suffix=" spd",Callback=function(v)
        speedValue=v
        if speedEnabled then applySpeed() end
    end})
    MovementRightGroupBox:AddDivider()
    MovementRightGroupBox:AddButton("Reset Speed",function()
        speedEnabled=false; Toggles.SpeedHackToggle:SetValue(false)
        if speedConn then pcall(function() speedConn:Disconnect() end); speedConn=nil end
        local hum=getHumanoid(); if hum then pcall(function() hum.WalkSpeed=16 end) end
        Library:Notify("Speed reset to 16",3)
    end)
    -- Backup heartbeat loop in case property signal fails
    connections["SpeedHack"]=RunService.Heartbeat:Connect(function()
        if featuresLocked or not speedEnabled then return end
        local hum=getHumanoid()
        if hum and hum.WalkSpeed~=speedValue then pcall(function() hum.WalkSpeed=speedValue end) end
    end)
    -- Reapply speed on respawn
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        if speedEnabled then applySpeed() end
    end)

    local ProtectionLeftGroupBox=Tabs.Protection:AddLeftGroupbox("Protection Options")
    local antiAimEnabled=false; local antiAimMode="Spin"; local antiAimSpeed=10
    ProtectionLeftGroupBox:AddToggle("AntiAimToggle",{Text="Anti-Aim",Default=false,Callback=function(v) if featuresLocked then Toggles.AntiAimToggle:SetValue(false) return end; antiAimEnabled=v end})
    ProtectionLeftGroupBox:AddDropdown("AntiAimMode",{Values={"Spin","Jitter","Random"},Default=1,Multi=false,Text="Mode",Callback=function(v) antiAimMode=v end})
    ProtectionLeftGroupBox:AddSlider("AntiAimSpeed",{Text="Spin Speed",Default=10,Min=1,Max=50,Rounding=0,Callback=function(v) antiAimSpeed=v end})
    local forceThirdPerson=false; local originalCameraType,originalMaxZoom,originalMinZoom
    ProtectionLeftGroupBox:AddToggle("ForceThirdPerson",{Text="Force Third Person",Default=false,Callback=function(v)
        if featuresLocked then Toggles.ForceThirdPerson:SetValue(false) return end; forceThirdPerson=v
        if v then originalCameraType=LocalPlayer.CameraMode; originalMaxZoom=LocalPlayer.CameraMaxZoomDistance; originalMinZoom=LocalPlayer.CameraMinZoomDistance; LocalPlayer.CameraMode=Enum.CameraMode.Classic; LocalPlayer.CameraMaxZoomDistance=50; LocalPlayer.CameraMinZoomDistance=5
        else LocalPlayer.CameraMode=originalCameraType or Enum.CameraMode.Classic; LocalPlayer.CameraMaxZoomDistance=originalMaxZoom or 128; LocalPlayer.CameraMinZoomDistance=originalMinZoom or 0.5 end
    end})
    connections["ProtectionLoop"]=RunService.Heartbeat:Connect(function()
        if not featuresLocked and forceThirdPerson then
            if LocalPlayer.CameraMode~=Enum.CameraMode.Classic then LocalPlayer.CameraMode=Enum.CameraMode.Classic end
            if LocalPlayer.CameraMaxZoomDistance<20 then LocalPlayer.CameraMaxZoomDistance=50 end
            if LocalPlayer.CameraMinZoomDistance>10 then LocalPlayer.CameraMinZoomDistance=5 end
        end
        if not featuresLocked and antiAimEnabled then
            pcall(function()
                local root=getRoot(); if not root then return end
                if antiAimMode=="Spin" then root.CFrame=root.CFrame*CFrame.Angles(0,math.rad(antiAimSpeed),0)
                elseif antiAimMode=="Jitter" then root.CFrame=root.CFrame*CFrame.Angles(0,math.rad(math.random(-180,180)),0)
                elseif antiAimMode=="Random" then root.CFrame=root.CFrame*CFrame.Angles(math.rad(math.random(-5,5)),math.rad(math.random(-180,180)),math.rad(math.random(-5,5))) end
            end)
        end
        if not featuresLocked and isLifetime and antiSpecEnabled and wasSpec then
            pcall(function() local root=getRoot(); if root then root.CFrame=root.CFrame*CFrame.Angles(0,math.rad(math.random(-180,180)),0) end end)
        end
    end)

    local RivalsLeftGB=Tabs.Rivals:AddLeftGroupbox("Rivals Combat")
    local RivalsRightGB=Tabs.Rivals:AddRightGroupbox("Rivals Utilities")
    local weaponSwitcherEnabled=false
    local WEAPON_RANGES={["Knife"]={min=0,max=20,priority=1},["Fist"]={min=0,max=12,priority=1},["Scythe"]={min=0,max=18,priority=1},["Chainsaw"]={min=0,max=18,priority=1},["Shorty"]={min=0,max=22,priority=1},["Shotgun"]={min=0,max=25,priority=1},["Katana"]={min=0,max=20,priority=1},["Uzi"]={min=0,max=35,priority=2},["Handgun"]={min=15,max=60,priority=1},["Revolver"]={min=15,max=70,priority=1},["Burst Rifle"]={min=20,max=80,priority=1},["Assault Rifle"]={min=15,max=90,priority=1},["Paintball Gun"]={min=10,max=70,priority=2},["Permafrost"]={min=10,max=60,priority=2},["Spray"]={min=5,max=45,priority=2},["Minigun"]={min=10,max=65,priority=2},["Sniper"]={min=50,max=500,priority=1},["Crossbow"]={min=40,max=300,priority=1},["Bow"]={min=35,max=250,priority=2},["RPG"]={min=30,max=200,priority=3}}
    local function getBestWeapon(dist)
        local best=nil; local bestPrio=math.huge; local bestScore=math.huge
        local char=getCharacter(); local bp=LocalPlayer.Backpack; if not char or not bp then return nil end
        local allTools={}
        for _,t in pairs(char:GetChildren()) do if t:IsA("Tool") then allTools[#allTools+1]=t end end
        for _,t in pairs(bp:GetChildren()) do if t:IsA("Tool") then allTools[#allTools+1]=t end end
        for _,tool in ipairs(allTools) do
            local data=WEAPON_RANGES[tool.Name]
            if data and dist>=data.min and dist<=data.max then
                local center=(data.min+data.max)/2; local score=math.abs(dist-center)
                if data.priority<bestPrio or (data.priority==bestPrio and score<bestScore) then bestPrio=data.priority; bestScore=score; best=tool end
            end
        end
        return best
    end
    RivalsLeftGB:AddToggle("WeaponSwitcherToggle",{Text="Auto Weapon Switcher",Default=false,Callback=function(v) if featuresLocked then Toggles.WeaponSwitcherToggle:SetValue(false) return end; weaponSwitcherEnabled=v end})
    RivalsLeftGB:AddLabel("Switches to best weapon for enemy distance")
    connections["WeaponSwitcher"]=RunService.Heartbeat:Connect(function()
        if featuresLocked or not weaponSwitcherEnabled then return end
        pcall(function()
            local root=getRoot(); if not root then return end
            local closest=getClosestPlayer(math.huge); if not closest or not closest.Character then return end
            local er=closest.Character:FindFirstChild("HumanoidRootPart"); if not er then return end
            local dist=(root.Position-er.Position).Magnitude
            local best=getBestWeapon(dist); if not best then return end
            local char=getCharacter(); if not char then return end
            local current=char:FindFirstChildOfClass("Tool")
            if not current or current.Name~=best.Name then if best.Parent==LocalPlayer.Backpack then local hum=getHumanoid(); if hum then hum:EquipTool(best) end end end
        end)
    end)
    RivalsLeftGB:AddDivider()
    local duelAutoAccept=false
    RivalsLeftGB:AddToggle("DuelAutoAcceptToggle",{Text="Duel Auto Accept",Default=false,Callback=function(v) if featuresLocked then Toggles.DuelAutoAcceptToggle:SetValue(false) return end; duelAutoAccept=v end})
    connections["DuelAutoAccept"]=RunService.Heartbeat:Connect(function()
        if featuresLocked or not duelAutoAccept then return end
        pcall(function()
            local remotes=ReplicatedStorage:FindFirstChild("Remotes")
            if remotes then for _,r in pairs(remotes:GetChildren()) do local n=r.Name:lower(); if n:find("duel") and (n:find("accept") or n:find("confirm") or n:find("join")) then r:FireServer(); break end end end
            pcall(function() for _,gui in pairs(game:GetService("CoreGui"):GetDescendants()) do if gui:IsA("TextButton") then local t=gui.Text:lower(); if (t:find("accept") or t:find("join") or t:find("yes")) and gui.Visible then gui:Activate() end end end end)
        end)
    end)
    RivalsLeftGB:AddDivider()
    local autoHealEnabled=false; local autoHealThresh=50; local autoHealCooldown=0
    RivalsLeftGB:AddToggle("AutoHealToggle",{Text="Auto Heal",Default=false,Callback=function(v) if featuresLocked then Toggles.AutoHealToggle:SetValue(false) return end; autoHealEnabled=v; Library:Notify(v and "Auto Heal ON" or "Auto Heal OFF",3) end})
    RivalsLeftGB:AddSlider("AutoHealThresh",{Text="Heal at HP%",Default=50,Min=10,Max=90,Rounding=0,Suffix="%",Callback=function(v) autoHealThresh=v end})
    connections["AutoHeal"]=RunService.Heartbeat:Connect(function(dt)
        if featuresLocked or not autoHealEnabled then return end
        autoHealCooldown=math.max(0,autoHealCooldown-dt); if autoHealCooldown>0 then return end
        pcall(function()
            local hum=getHumanoid(); if not hum then return end
            if (hum.Health/hum.MaxHealth)*100<=autoHealThresh then
                local char=getCharacter(); local bp=LocalPlayer.Backpack; if not char or not bp then return end
                local medkit=char:FindFirstChild("Medkit") or bp:FindFirstChild("Medkit") or char:FindFirstChild("MedKit") or bp:FindFirstChild("MedKit") or char:FindFirstChild("Heal") or bp:FindFirstChild("Heal") or char:FindFirstChild("HealthPack") or bp:FindFirstChild("HealthPack")
                if medkit then
                    autoHealCooldown=3
                    if medkit.Parent==bp then local h=getHumanoid(); if h then h:EquipTool(medkit) end; task.wait(0.1) end
                    medkit=getCharacter() and getCharacter():FindFirstChild(medkit.Name)
                    if medkit then medkit:Activate(); Library:Notify("Auto Heal used!",2) end
                end
            end
        end)
    end)
    RivalsRightGB:AddLabel("-- Quick Utilities --"); RivalsRightGB:AddDivider()
    RivalsRightGB:AddButton("Server Hop",function()
        if featuresLocked then Library:Notify("Locked.",2) return end
        Library:Notify("Finding server...",3)
        task.spawn(function()
            local servers={}
            pcall(function() local result=game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"); local data=HttpService:JSONDecode(result); if data and data.data then for _,s in pairs(data.data) do if s.id~=game.JobId and s.playing and s.maxPlayers and s.playing<s.maxPlayers then servers[#servers+1]=s.id end end end end)
            if #servers>0 then local picked=servers[math.random(1,#servers)]; Library:Notify("Joining...",2); task.wait(1); game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId,picked,LocalPlayer)
            else Library:Notify("No servers found.",3) end
        end)
    end)
    RivalsRightGB:AddDivider()
    RivalsRightGB:AddButton("Rejoin",function()
        if featuresLocked then Library:Notify("Locked.",2) return end
        Library:Notify("Rejoining...",2); task.wait(1); game:GetService("TeleportService"):Teleport(game.PlaceId,LocalPlayer)
    end)

    local ExtrasLeftGroupBox=Tabs.Extras:AddLeftGroupbox("Extras Options")
    local ExtrasRightGroupBox=Tabs.Extras:AddRightGroupbox("Lifetime Features")
    ExtrasLeftGroupBox:AddToggle("FPSBoostToggle",{Text="FPS Boost",Default=false,Callback=function(v)
        if featuresLocked then Toggles.FPSBoostToggle:SetValue(false) return end
        if v then pcall(function() local l=game:GetService("Lighting"); l.GlobalShadows=false; l.FogEnd=9e9; settings().Rendering.QualityLevel=Enum.QualityLevel.Level01; for _,obj in pairs(workspace:GetDescendants()) do if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") then obj.Enabled=false end end end); Library:Notify("FPS Boost ON",3)
        else pcall(function() game:GetService("Lighting").GlobalShadows=true; settings().Rendering.QualityLevel=Enum.QualityLevel.Automatic end) end
    end})
    ExtrasLeftGroupBox:AddDivider()
    ExtrasLeftGroupBox:AddButton("Fullbright",function()
        if featuresLocked then Library:Notify("Locked.",2) return end
        local l=game:GetService("Lighting"); l.Brightness=2; l.ClockTime=14; l.FogEnd=100000; l.GlobalShadows=false; l.OutdoorAmbient=Color3.fromRGB(128,128,128); Library:Notify("Fullbright ON",3)
    end)
    ExtrasLeftGroupBox:AddButton("Remove Fog",function()
        if featuresLocked then Library:Notify("Locked.",2) return end
        local l=game:GetService("Lighting"); l.FogEnd=100000
        for _,v in pairs(l:GetChildren()) do if v:IsA("Atmosphere") then v:Destroy() end end
        Library:Notify("Fog Removed!",3)
    end)
    local afkConn=nil
    if isLifetime then
        ExtrasRightGroupBox:AddToggle("AntiAFKToggle",{Text="[L] Anti AFK",Default=false,Callback=function(v)
            if featuresLocked then Toggles.AntiAFKToggle:SetValue(false) return end
            if v then afkConn=LocalPlayer.Idled:Connect(function() pcall(function() local vjs=game:GetService("VirtualInputManager"); vjs:SendKeyEvent(true,"Semicolon",false,game); task.wait(0.1); vjs:SendKeyEvent(false,"Semicolon",false,game) end) end)
            else if afkConn then afkConn:Disconnect(); afkConn=nil end end
        end})
    else ExtrasRightGroupBox:AddLabel("[L] Anti AFK - Lifetime Only") end
    local ksEnabled=false
    local ksound=Instance.new("Sound"); ksound.SoundId="rbxassetid://4612338345"; ksound.Volume=0.8; ksound.Parent=SoundService
    if isLifetime then
        ExtrasRightGroupBox:AddDivider()
        ExtrasRightGroupBox:AddToggle("KillSoundToggle",{Text="[L] Kill Sound",Default=false,Callback=function(v) if featuresLocked then Toggles.KillSoundToggle:SetValue(false) return end; ksEnabled=v end})
        ExtrasRightGroupBox:AddDropdown("KillSoundType",{Values={"Hit Marker","Headshot","Cash Register","Level Up","Skull"},Default=1,Multi=false,Text="Sound Type",Callback=function(v)
            local sounds={["Hit Marker"]="4612338345",["Headshot"]="142082588",["Cash Register"]="138186576",["Level Up"]="4612368723",["Skull"]="5982758739"}
            ksound.SoundId="rbxassetid://"..(sounds[v] or "4612338345")
        end})
        ExtrasRightGroupBox:AddSlider("KillSoundVolume",{Text="Volume",Default=80,Min=0,Max=100,Rounding=0,Suffix="%",Callback=function(v) ksound.Volume=v/100 end})
        local prevHP={}
        connections["KillSound"]=RunService.Heartbeat:Connect(function()
            if featuresLocked or not isLifetime or not ksEnabled then return end
            for _,p in ipairs(Players:GetPlayers()) do
                if p==LocalPlayer then continue end
                if not p.Character then prevHP[p]=nil; continue end
                local h=p.Character:FindFirstChild("Humanoid"); if not h then continue end
                local prev=prevHP[p]; if prev and prev>0 and h.Health<=0 then pcall(function() ksound:Play() end); Library:Notify(p.Name.." eliminated!",2) end
                prevHP[p]=h.Health
            end
        end)
    else ExtrasRightGroupBox:AddLabel("[L] Kill Sound - Lifetime Only") end
    local chEnabled=false; local chLines={}; local chColor=Color3.new(1,1,1); local chSize=10; local chThick=2; local chStyle="Cross"
    if isLifetime then
        ExtrasRightGroupBox:AddDivider()
        ExtrasRightGroupBox:AddToggle("CrosshairToggle",{Text="[L] Custom Crosshair",Default=false,Callback=function(v) if featuresLocked then Toggles.CrosshairToggle:SetValue(false) return end; chEnabled=v; if not v then for _,l in pairs(chLines) do pcall(function() l:Remove() end) end; chLines={} end end})
        ExtrasRightGroupBox:AddDropdown("CrosshairStyle",{Values={"Cross","Dot","Circle","TShape"},Default=1,Multi=false,Text="Style",Callback=function(v) chStyle=v end})
        ExtrasRightGroupBox:AddSlider("CrosshairSize",{Text="Size",Default=10,Min=2,Max=50,Rounding=0,Callback=function(v) chSize=v end})
        ExtrasRightGroupBox:AddSlider("CrosshairThickness",{Text="Thickness",Default=2,Min=1,Max=8,Rounding=0,Callback=function(v) chThick=v end})
        ExtrasRightGroupBox:AddDropdown("CrosshairColor",{Values={"White","Red","Green","Blue","Yellow","Cyan","Pink","Orange"},Default=1,Multi=false,Text="Color",Callback=function(v)
            local colors={White=Color3.new(1,1,1),Red=Color3.new(1,0,0),Green=Color3.new(0,1,0),Blue=Color3.new(0,0,1),Yellow=Color3.new(1,1,0),Cyan=Color3.new(0,1,1),Pink=Color3.new(1,0,1),Orange=Color3.fromRGB(255,130,50)}
            chColor=colors[v] or Color3.new(1,1,1)
        end})
        connections["Crosshair"]=RunService.RenderStepped:Connect(function()
            for _,l in pairs(chLines) do pcall(function() l:Remove() end) end; chLines={}
            if featuresLocked or not isLifetime or not chEnabled then return end
            local cx=Camera.ViewportSize.X/2; local cy=Camera.ViewportSize.Y/2; local s=chSize; local t=chThick
            local function ml(from,to) local l=Drawing.new("Line"); l.From=from; l.To=to; l.Color=chColor; l.Thickness=t; l.Transparency=1; l.Visible=true; chLines[#chLines+1]=l end
            if chStyle=="Cross" then ml(Vector2.new(cx-s,cy),Vector2.new(cx+s,cy)); ml(Vector2.new(cx,cy-s),Vector2.new(cx,cy+s))
            elseif chStyle=="Dot" then local d=Drawing.new("Circle"); d.Position=Vector2.new(cx,cy); d.Radius=t+1; d.Color=chColor; d.Transparency=1; d.Filled=true; d.Visible=true; chLines[#chLines+1]=d
            elseif chStyle=="Circle" then local c=Drawing.new("Circle"); c.Position=Vector2.new(cx,cy); c.Radius=s; c.Color=chColor; c.Thickness=t; c.Transparency=1; c.Filled=false; c.NumSides=32; c.Visible=true; chLines[#chLines+1]=c
            elseif chStyle=="TShape" then ml(Vector2.new(cx-s,cy),Vector2.new(cx+s,cy)); ml(Vector2.new(cx,cy),Vector2.new(cx,cy+s)) end
        end)
    else ExtrasRightGroupBox:AddLabel("[L] Custom Crosshair - Lifetime Only") end

    local origAmb=Lighting.Ambient; local origOut=Lighting.OutdoorAmbient; local origBri=Lighting.Brightness
    local origCST=Lighting.ColorShift_Top; local origCSB=Lighting.ColorShift_Bottom; local mapEnabled=false
    local function getCC()
        for _,obj in pairs(Lighting:GetChildren()) do if obj:IsA("ColorCorrectionEffect") and obj.Name~="RivalsCC" then pcall(function() obj.Enabled=false end) end end
        local cc=Lighting:FindFirstChild("RivalsCC"); if not cc then cc=Instance.new("ColorCorrectionEffect"); cc.Name="RivalsCC"; cc.Parent=Lighting end; cc.Enabled=true; return cc
    end
    local function removeCC()
        local cc=Lighting:FindFirstChild("RivalsCC"); if cc then cc:Destroy() end
        for _,obj in pairs(Lighting:GetChildren()) do if obj:IsA("ColorCorrectionEffect") then pcall(function() obj.Enabled=true end) end end
    end
    local function resetMap() Lighting.Ambient=origAmb; Lighting.OutdoorAmbient=origOut; Lighting.Brightness=origBri; Lighting.ColorShift_Top=origCST; Lighting.ColorShift_Bottom=origCSB; removeCC() end
    local MapLeftGB=Tabs.MapChanger:AddLeftGroupbox("Map Color Presets")
    local MapRightGB=Tabs.MapChanger:AddRightGroupbox("Custom Settings")
    if isLifetime then
        MapLeftGB:AddToggle("MapColorToggle",{Text="Enable Map Color Changer",Default=false,Callback=function(v) if featuresLocked then Toggles.MapColorToggle:SetValue(false) return end; mapEnabled=v; if not v then resetMap() end end})
        MapLeftGB:AddDivider(); MapLeftGB:AddLabel("Enable toggle first then pick preset:")
        local presets={{"Black",function() Lighting.Brightness=0.25; Lighting.Ambient=Color3.fromRGB(5,5,5); Lighting.OutdoorAmbient=Color3.fromRGB(5,5,5); local cc=getCC(); cc.Brightness=-0.4; cc.Contrast=0.4; cc.Saturation=-0.3; cc.TintColor=Color3.fromRGB(40,40,40) end},{"Dark Red",function() Lighting.Brightness=0.35; Lighting.Ambient=Color3.fromRGB(20,2,2); Lighting.OutdoorAmbient=Color3.fromRGB(20,2,2); local cc=getCC(); cc.TintColor=Color3.fromRGB(160,35,35); cc.Saturation=0.4; cc.Brightness=-0.28; cc.Contrast=0.28 end},{"Dark Blue",function() Lighting.Brightness=0.35; Lighting.Ambient=Color3.fromRGB(2,2,20); Lighting.OutdoorAmbient=Color3.fromRGB(2,2,20); local cc=getCC(); cc.TintColor=Color3.fromRGB(35,35,160); cc.Saturation=0.4; cc.Brightness=-0.28; cc.Contrast=0.28 end},{"Dark Green",function() Lighting.Brightness=0.35; Lighting.Ambient=Color3.fromRGB(2,14,2); Lighting.OutdoorAmbient=Color3.fromRGB(2,14,2); local cc=getCC(); cc.TintColor=Color3.fromRGB(35,140,35); cc.Saturation=0.4; cc.Brightness=-0.28; cc.Contrast=0.28 end},{"Dark Purple",function() Lighting.Brightness=0.35; Lighting.Ambient=Color3.fromRGB(10,2,16); Lighting.OutdoorAmbient=Color3.fromRGB(10,2,16); local cc=getCC(); cc.TintColor=Color3.fromRGB(90,28,145); cc.Saturation=0.4; cc.Brightness=-0.28; cc.Contrast=0.28 end},{"Night",function() Lighting.Brightness=0.45; Lighting.Ambient=Color3.fromRGB(12,12,26); Lighting.OutdoorAmbient=Color3.fromRGB(12,12,26); local cc=getCC(); cc.Brightness=-0.22; cc.Contrast=0.2; cc.Saturation=-0.15; cc.TintColor=Color3.fromRGB(65,65,175) end},{"Sunset",function() Lighting.Brightness=0.8; local cc=getCC(); cc.TintColor=Color3.fromRGB(200,90,35); cc.Brightness=-0.18; cc.Saturation=0.35; cc.Contrast=0.2 end},{"Neon",function() Lighting.Brightness=0.8; local cc=getCC(); cc.TintColor=Color3.fromRGB(40,175,115); cc.Brightness=-0.12; cc.Saturation=0.6; cc.Contrast=0.25 end},{"Sepia",function() Lighting.Brightness=0.9; local cc=getCC(); cc.TintColor=Color3.fromRGB(170,130,80); cc.Saturation=-0.25; cc.Brightness=-0.18; cc.Contrast=0.2 end},{"Greyscale",function() Lighting.Brightness=0.9; local cc=getCC(); cc.TintColor=Color3.new(1,1,1); cc.Saturation=-1; cc.Brightness=-0.18; cc.Contrast=0.15 end},{"Vivid",function() Lighting.Brightness=1.0; local cc=getCC(); cc.TintColor=Color3.new(1,1,1); cc.Saturation=0.7; cc.Brightness=-0.1; cc.Contrast=0.25 end},{"Cold",function() Lighting.Brightness=0.8; local cc=getCC(); cc.TintColor=Color3.fromRGB(90,130,200); cc.Saturation=0.25; cc.Brightness=-0.18; cc.Contrast=0.2 end}}
        for _,preset in ipairs(presets) do local p=preset; MapLeftGB:AddButton(p[1],function() if not mapEnabled then Library:Notify("Enable Map Color Changer first.",3) return end; p[2](); Library:Notify(p[1].." applied!",2) end) end
        MapRightGB:AddLabel("Custom Adjustments"); MapRightGB:AddDivider()
        MapRightGB:AddDropdown("MapTintColor",{Values={"White","Red","Green","Blue","Yellow","Purple","Orange","Cyan"},Default=1,Multi=false,Text="Tint Color",Callback=function(v) if not mapEnabled or featuresLocked then return end; local colors={White=Color3.new(1,1,1),Red=Color3.new(1,0,0),Green=Color3.new(0,1,0),Blue=Color3.new(0,0,1),Yellow=Color3.new(1,1,0),Purple=Color3.fromRGB(160,50,230),Orange=Color3.fromRGB(255,130,50),Cyan=Color3.new(0,1,1)}; getCC().TintColor=colors[v] or Color3.new(1,1,1) end})
        MapRightGB:AddDropdown("MapAmbientColor",{Values={"Default","Dark","Very Dark","Red Tint","Blue Tint","Green Tint","Purple Tint"},Default=1,Multi=false,Text="Ambient Color",Callback=function(v) if not mapEnabled or featuresLocked then return end; local colors={Default=Color3.fromRGB(70,70,70),Dark=Color3.fromRGB(8,8,8),["Very Dark"]=Color3.fromRGB(2,2,2),["Red Tint"]=Color3.fromRGB(18,1,1),["Blue Tint"]=Color3.fromRGB(1,1,18),["Green Tint"]=Color3.fromRGB(1,12,1),["Purple Tint"]=Color3.fromRGB(8,1,14)}; local c=colors[v] or Color3.fromRGB(70,70,70); Lighting.Ambient=c; Lighting.OutdoorAmbient=c end})
        MapRightGB:AddSlider("MapBrightness",{Text="Brightness",Default=10,Min=1,Max=30,Rounding=0,Callback=function(v) if not mapEnabled or featuresLocked then return end; Lighting.Brightness=v/10 end})
        MapRightGB:AddSlider("MapSaturation",{Text="Saturation",Default=10,Min=0,Max=20,Rounding=0,Callback=function(v) if not mapEnabled or featuresLocked then return end; getCC().Saturation=(v-10)/10 end})
        MapRightGB:AddSlider("MapContrast",{Text="Contrast",Default=10,Min=0,Max=20,Rounding=0,Callback=function(v) if not mapEnabled or featuresLocked then return end; getCC().Contrast=(v-10)/10 end})
        MapRightGB:AddDivider(); MapRightGB:AddButton("Reset All Colors",function() resetMap(); Library:Notify("Map colors reset!",3) end)
    else MapLeftGB:AddLabel("[L] Map Color Changer - Lifetime Only"); MapRightGB:AddLabel("[L] Custom Settings - Lifetime Only") end

    local SkinLeftGB=Tabs.SkinChanger:AddLeftGroupbox("Weapons")
    local SkinRightGB=Tabs.SkinChanger:AddRightGroupbox("Skins")
    local selectedWeaponName=""; local selectedSkinName=""
    local skinStatusLabel=SkinLeftGB:AddLabel("Status: Ready")
    local skinCountLabel=SkinLeftGB:AddLabel("Weapons found: 0")

    local KNOWN_SKINS={
        ["Assault Rifle"]={"Default","Phoenix Rifle","Compound Bow","AK-47","AUG","Tommy Gun","AKEY-47","Gingerbread AUG","Glorious Assault Rifle"},
        ["Burst Rifle"]={"Default","Pine Burst","Spectral Burst","FAMAS","Glorious Burst Rifle"},
        ["Sniper"]={"Default","Eyething Sniper","Event Horizon","Keyper","Glorious Sniper","Arctic Sniper"},
        ["Shotgun"]={"Default","Cactus Shotgun","Wrapped Shotgun","ShotKey","Glorious Shotgun"},
        ["Crossbow"]={"Default","Crossbone","Glorious Crossbow","Arch Crossbow"},
        ["Minigun"]={"Default","Pumpkin Minigun","Wrapped Minigun","Glorious Minigun"},
        ["RPG"]={"Default","Pencil Launcher","RPKey","Glorious RPG"},
        ["Flamethrower"]={"Default","Lamethrower","Glorious Flamethrower"},
        ["Gunblade"]={"Default","Boneblade","Crude Gunblade","Elf's Gunblade","Glorious Gunblade"},
        ["Paintball Gun"]={"Default","Ketchup Gun","Glorious Paintball Gun"},
        ["Handgun"]={"Default","Gumball Handgun","Pumpkin Handgun","Towerstone Handgun","Warp Handgun","Peppergun","Peppermint Sheriff","Glorious Handgun"},
        ["Revolver"]={"Default","Keyvolver","Glorious Revolver"},
        ["Shorty"]={"Default","Lovely Shorty","Not So Shorty","Too Shorty","Wrapped Shorty","Glorious Shorty"},
        ["Spray"]={"Default","Lovely Spray","Nail Gun","Pine Spray","Electro Spray","Glorious Spray"},
        ["Uzi"]={"Default","Pine Uzi","Keyzi","Electro Uzi","Glorious Uzi"},
        ["Slingshot"]={"Default","Goalpost","Stick","Glorious Slingshot"},
        ["Flare Gun"]={"Default","Wrapped Flare Gun","Glorious Flare Gun"},
        ["Exogun"]={"Default","Midnight Festive Exogun","Singularity","Wondergun","Repulsor","Glorious Exogun"},
        ["Permafrost"]={"Default","Ice Permafrost","Glorious Permafrost"},
        ["Distortion"]={"Default","Cyber Distortion","Glorious Distortion"},
        ["Daggers"]={"Default","Paper Planes","Shurikens","Keynais","Glorious Daggers"},
        ["Knife"]={"Default","Karambit","Balisong","Keyrambit","Keylisong","Glorious Knife"},
        ["Katana"]={"Default","Crystal Katana","Keytana","Saber","Glorious Katana"},
        ["Scythe"]={"Default","Cryo Scythe","Crystal Scythe","Keythe","Glorious Scythe","Arch Scythe"},
        ["Battle Axe"]={"Default","Ban Axe","Nordic Axe","Glorious Battle Axe","Keyttle Axe"},
        ["Fists"]={"Default","Brass Knuckles","Festive Fists","Glorious Fists"},
        ["Chainsaw"]={"Default","Glorious Chainsaw"},
        ["Hammer"]={"Default","Glorious Hammer"},
        ["Riot Shield"]={"Default","Glorious Riot Shield","Energy Shield","Door","Sled"},
    }

    -- Try to hook into Rivals CosmeticLibrary directly like other skin changers do
    local CosmeticLib=nil
    local cosmeticModule=nil
    pcall(function()
        local rs=game:GetService("ReplicatedStorage")
        for _,v in pairs(rs:GetDescendants()) do
            if (v.Name:lower():find("cosmetic") or v.Name:lower():find("skinlib") or v.Name:lower():find("itemlib")) and v:IsA("ModuleScript") then
                local ok,mod=pcall(require,v)
                if ok and mod then CosmeticLib=v; cosmeticModule=mod; break end
            end
        end
    end)

    local originalTextures={}
    local function storeOriginal(weapon)
        if originalTextures[weapon.Name] then return end
        originalTextures[weapon.Name]={}
        for _,part in pairs(weapon:GetDescendants()) do
            if part:IsA("MeshPart") then originalTextures[weapon.Name][part]=part.TextureID
            elseif part:IsA("SpecialMesh") then originalTextures[weapon.Name][part]={part.TextureId,part.MeshId} end
        end
    end
    local function restoreOriginal(weapon)
        if not originalTextures[weapon.Name] then return end
        for part,data in pairs(originalTextures[weapon.Name]) do
            pcall(function()
                if part:IsA("MeshPart") then part.TextureID=data
                elseif part:IsA("SpecialMesh") then part.TextureId=data[1]; part.MeshId=data[2] end
            end)
        end
    end

    local function applySkin(weaponName, skinName)
        local applied=false
        -- Method 1: CosmeticLibrary (same method all working skin changers use)
        if cosmeticModule and not applied then
            pcall(function()
                local fns={"ApplySkin","SetSkin","applySkin","setSkin","Apply","apply"}
                for _,fn in pairs(fns) do
                    if cosmeticModule[fn] then
                        cosmeticModule[fn](LocalPlayer,weaponName,skinName)
                        skinStatusLabel:SetText("Status: "..skinName.." applied!")
                        applied=true; break
                    end
                end
            end)
        end
        -- Method 2: Find weapon tool and swap textures from RS skin data
        if not applied then
            pcall(function()
                local char=getCharacter(); local bp=LocalPlayer.Backpack
                local weapon=nil
                if char then weapon=char:FindFirstChild(weaponName) end
                if not weapon and bp then weapon=bp:FindFirstChild(weaponName) end
                if not weapon then skinStatusLabel:SetText("Status: Equip weapon first"); return end
                storeOriginal(weapon)
                if skinName=="Default" then restoreOriginal(weapon); skinStatusLabel:SetText("Status: Default restored"); applied=true; return end
                local rs=game:GetService("ReplicatedStorage")
                local skinObj=nil
                -- Deep search for skin by name
                for _,v in pairs(rs:GetDescendants()) do
                    if v.Name==skinName then skinObj=v; break end
                end
                if skinObj then
                    for _,part in pairs(weapon:GetDescendants()) do
                        local sp=skinObj:FindFirstChild(part.Name,true)
                        if sp then
                            pcall(function()
                                if part:IsA("MeshPart") and sp:IsA("MeshPart") then part.TextureID=sp.TextureID end
                                if part:IsA("SpecialMesh") and sp:IsA("SpecialMesh") then part.TextureId=sp.TextureId; part.MeshId=sp.MeshId end
                            end)
                        end
                    end
                    skinStatusLabel:SetText("Status: "..skinName.." applied!")
                    applied=true
                end
            end)
        end
        if not applied then skinStatusLabel:SetText("Status: Skin not in game data") end
    end

    local function getWeaponList()
        local weapons={}
        local char=getCharacter(); local bp=LocalPlayer.Backpack
        if char then for _,t in pairs(char:GetChildren()) do if t:IsA("Tool") and not table.find(weapons,t.Name) then weapons[#weapons+1]=t.Name end end end
        if bp then for _,t in pairs(bp:GetChildren()) do if t:IsA("Tool") and not table.find(weapons,t.Name) then weapons[#weapons+1]=t.Name end end end
        table.sort(weapons); return weapons
    end

    SkinLeftGB:AddDropdown("SkinWeaponDrop",{Values={"None"},Default=1,Multi=false,Text="Select Weapon",Callback=function(v)
        selectedWeaponName=v; if v=="None" then return end
        local skins=KNOWN_SKINS[v] or {"Default"}
        Options.SkinDrop:SetValues(skins); Options.SkinDrop:SetValue(skins[1])
        skinStatusLabel:SetText("Status: "..#skins.." skins for "..v)
    end})
    SkinLeftGB:AddButton("Refresh Weapons",function()
        local weapons=getWeaponList(); local vals={"None"}
        for _,w in pairs(weapons) do vals[#vals+1]=w end
        Options.SkinWeaponDrop:SetValues(vals); Options.SkinWeaponDrop:SetValue(vals[1])
        skinCountLabel:SetText("Weapons found: "..#weapons)
        Library:Notify("Found "..#weapons.." weapons",3)
    end)
    SkinLeftGB:AddButton("Apply Skin",function()
        if selectedWeaponName=="" or selectedWeaponName=="None" then Library:Notify("Select a weapon first",3) return end
        if selectedSkinName=="" or selectedSkinName=="None" then Library:Notify("Select a skin first",3) return end
        applySkin(selectedWeaponName,selectedSkinName)
    end)
    SkinLeftGB:AddButton("Restore Default",function()
        if selectedWeaponName=="" or selectedWeaponName=="None" then Library:Notify("Select a weapon first",3) return end
        applySkin(selectedWeaponName,"Default")
    end)
    SkinLeftGB:AddDivider()
    SkinLeftGB:AddLabel(cosmeticModule and "CosmeticLib: Hooked!" or "CosmeticLib: Fallback mode")
    SkinLeftGB:AddLabel("Refresh Weapons then select + apply")
    SkinRightGB:AddDropdown("SkinDrop",{Values={"Default"},Default=1,Multi=false,Text="Select Skin",Callback=function(v) selectedSkinName=v end})
    SkinRightGB:AddDivider()
    SkinRightGB:AddLabel("How to use:")
    SkinRightGB:AddLabel("1. Refresh Weapons")
    SkinRightGB:AddLabel("2. Select weapon")
    SkinRightGB:AddLabel("3. Select skin from list")
    SkinRightGB:AddLabel("4. Tap Apply Skin")
    SkinRightGB:AddLabel("Client-side only")

    local MenuGroup=Tabs["UI Settings"]:AddLeftGroupbox("Menu")
    local ConfigGroup=Tabs["UI Settings"]:AddRightGroupbox("Configuration")
    MenuGroup:AddToggle("KeybindMenuOpen",{Default=false,Text="Open Keybind Menu",Callback=function(v) Library.KeybindFrame.Visible=v end})
    MenuGroup:AddToggle("ShowCustomCursor",{Text="Custom Cursor",Default=true,Callback=function(v) Library.ShowCustomCursor=v end})
    MenuGroup:AddDropdown("NotificationSide",{Values={"Left","Right"},Default=2,Text="Notification Side",Callback=function(v) Library:SetNotifySide(v) end})
    MenuGroup:AddDivider(); MenuGroup:AddButton("Unload Script",function() Library:Unload() end)
    MenuGroup:AddLabel("Menu Keybind"):AddKeyPicker("MenuKeybind",{Default="RightShift",NoUI=true,Text="Menu keybind"})
    Library.ToggleKeybind=Options.MenuKeybind
    ConfigGroup:AddLabel("Config Management"); ConfigGroup:AddDivider()
    ConfigGroup:AddDropdown("ConfigList",{Values={},Default=1,Multi=false,Text="Select Config"})
    ConfigGroup:AddInput("ConfigName",{Default="",Numeric=false,Finished=false,Text="Config Name",Placeholder="MyConfig"})
    ConfigGroup:AddButton("Save Config",function() local n=Options.ConfigName.Value; if n=="" then Library:Notify("Enter a name!",3) return end; SaveManager:Save(n); Library:Notify("Saved!",3); SaveManager:Refresh() end)
    ConfigGroup:AddButton("Load Config",function() local n=Options.ConfigName.Value; if n=="" then Library:Notify("Enter a name!",3) return end; if SaveManager:Load(n) then Library:Notify("Loaded!",3) else Library:Notify("Not found!",3) end end)
    ConfigGroup:AddButton("Delete Config",function() local n=Options.ConfigName.Value; if n=="" then Library:Notify("Enter a name!",3) return end; if SaveManager:Delete(n) then Library:Notify("Deleted!",3); SaveManager:Refresh() else Library:Notify("Not found!",3) end end)
    ConfigGroup:AddDivider()
    ConfigGroup:AddButton("Refresh Config List",function() SaveManager:Refresh(); Library:Notify("Refreshed!",2) end)
    ConfigGroup:AddButton("Set as Autoload",function() local n=Options.ConfigName.Value; if n=="" then Library:Notify("Enter a name!",3) return end; SaveManager:SetAutoload(n); Library:Notify("Set!",3) end)

    ThemeManager:SetLibrary(Library); SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({"MenuKeybind","ConfigName","ConfigList","ThemeList"})
    ThemeManager:SetFolder("RivalsCheat"); SaveManager:SetFolder("RivalsCheat/configs")
    ThemeManager:ApplyToTab(Tabs["UI Settings"])
    pcall(function() SaveManager:SetAutoload("rivals_autosave"); SaveManager:LoadAutoloadConfig() end)
    task.spawn(function() while task.wait(5) do pcall(function() SaveManager:Save("rivals_autosave") end) end end)
    game:BindToClose(function() pcall(function() SaveManager:Save("rivals_autosave") end) end)
    LocalPlayer.CharacterAdded:Connect(function() pcall(function() SaveManager:Save("rivals_autosave") end) end)

    local InfoLeftGB=Tabs.Info:AddLeftGroupbox("Script Information")
    local InfoRightGB=Tabs.Info:AddRightGroupbox("Session")
    InfoLeftGB:AddLabel("Rivals - thegxx | v"..CURRENT_VERSION); InfoLeftGB:AddDivider()
    InfoLeftGB:AddLabel("Owner: Demon Executioners"); InfoLeftGB:AddDivider()
    InfoLeftGB:AddLabel("Discord: "..DISCORD)
    InfoLeftGB:AddButton("Copy Discord",function() setclipboard(DISCORD); Library:Notify("Discord copied!",3) end)
    InfoLeftGB:AddDivider(); InfoLeftGB:AddLabel("Snapchat: "..SNAPCHAT)
    InfoLeftGB:AddButton("Copy Snapchat",function() setclipboard(SNAPCHAT); Library:Notify("Snapchat copied!",3) end)
    InfoLeftGB:AddDivider(); InfoLeftGB:AddLabel("Instagram: "..INSTAGRAM)
    InfoLeftGB:AddButton("Copy Instagram",function() setclipboard(INSTAGRAM); Library:Notify("Instagram copied!",3) end)
    InfoLeftGB:AddDivider(); InfoLeftGB:AddLabel("Weekly / Monthly / Lifetime keys available")
    InfoRightGB:AddLabel("Tier: "..(isAdmin and "Admin" or tier or "User"))
    InfoRightGB:AddLabel("Username: "..LocalPlayer.Name)
    InfoRightGB:AddLabel("User ID: "..tostring(LocalPlayer.UserId))
    InfoRightGB:AddDivider()
    InfoRightGB:AddButton("Logout / Change Key",function()
        clearKey(); scriptLoaded=false; accessGranted=false; featuresLocked=true
        Library:Unload(); task.wait(0.3); buildKeyScreen(onSuccessCallback or function() end)
    end)
    InfoRightGB:AddLabel("Logout clears your saved key.")

    Library:OnUnload(function()
        pcall(function() SaveManager:Save("rivals_autosave") end)
        for name,conn in pairs(connections) do pcall(function() if type(conn)=="table" and conn.Disconnect then conn:Disconnect() end end) end
        pcall(function() RunService:UnbindFromRenderStep("Aimbot") end)
        connections={}; stopFly(); if flyGui then flyGui:Destroy() end
        for player in pairs(espBoxes) do cleanupPlayerESP(player) end
        for _,l in pairs(chLines) do pcall(function() l:Remove() end) end
        for p,l in pairs(tracerLines) do pcall(function() l:Remove() end) end
        for p,d in pairs(hBars2D) do pcall(function() d.outline:Remove(); d.bg:Remove(); d.fill:Remove(); d.text:Remove() end) end
        pcall(function() fovCircle:Remove() end)
        if clockGui then clockGui:Destroy() end
        if infJumpConnection then infJumpConnection:Disconnect() end
        if afkConn then afkConn:Disconnect() end
        if ksound then ksound:Destroy() end
        if lowHPGui then lowHPGui:Destroy() end
        if specGui then specGui:Destroy() end
        if hideLoopConn then hideLoopConn:Disconnect() end
        pcall(function() guiCapture:Disconnect() end)
        resetMap(); showAllGuis()
        LocalPlayer.CameraMode=originalCameraType or Enum.CameraMode.Classic
        LocalPlayer.CameraMaxZoomDistance=originalMaxZoom or 128
        LocalPlayer.CameraMinZoomDistance=originalMinZoom or 0.5
        pcall(function() local h=getHumanoid(); if h then h.WalkSpeed=16; h.JumpPower=50; h.PlatformStand=false end end)
        pcall(function() Camera.FieldOfView=70 end)
        pcall(function() local l=game:GetService("Lighting"); l.GlobalShadows=true; l.Brightness=1; settings().Rendering.QualityLevel=Enum.QualityLevel.Automatic end)
    end)

    if isAdmin then
        pcall(function()
            game:GetService("TextChatService").MessageReceived:Connect(function(msg)
                if msg.Text and msg.Text:lower()=="/g2" then
                    if msg.TextSource and msg.TextSource.UserId==LocalPlayer.UserId then toggleAdminMenu() end
                end
            end)
        end)
        pcall(function() LocalPlayer.Chatted:Connect(function(msg) if msg:lower()=="/g2" then toggleAdminMenu() end end) end)
    end

    pcall(function() guiCapture:Disconnect() end)

end)
