local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))
local Store = DataStoreService:GetDataStore(Config.DataStoreName)

local remotes = ReplicatedStorage:FindFirstChild("EclipseRemotes") or Instance.new("Folder")
remotes.Name = "EclipseRemotes"
remotes.Parent = ReplicatedStorage

local function getRemote(name)
    local remote = remotes:FindFirstChild(name) or Instance.new("RemoteEvent")
    remote.Name = name
    remote.Parent = remotes
    return remote
end

local SelectClass = getRemote("SelectClass")
local Attack = getRemote("Attack")
local UseSkill = getRemote("UseSkill")
local Notify = getRemote("Notify")

local profiles = {}
local lastAttack = {}
local lastSkill = {}
local comboState = {}
local enemiesFolder = Workspace:FindFirstChild("EclipseEnemies") or Instance.new("Folder")
enemiesFolder.Name = "EclipseEnemies"
enemiesFolder.Parent = Workspace

local function makeLeaderstats(player, data)
    local stats = Instance.new("Folder")
    stats.Name = "leaderstats"
    stats.Parent = player
    for name, value in pairs({Level = data.Level, XP = data.XP, Gold = data.Gold}) do
        local item = Instance.new("IntValue")
        item.Name = name
        item.Value = value
        item.Parent = stats
    end
end

local function syncStats(player)
    local data = profiles[player]
    local stats = player:FindFirstChild("leaderstats")
    if not data or not stats then return end
    stats.Level.Value = data.Level
    stats.XP.Value = data.XP
    stats.Gold.Value = data.Gold
end

local function loadProfile(player)
    local data = {Level = 1, XP = 0, Gold = 0, Class = "Swordsman"}
    local ok, saved = pcall(function()
        return Store:GetAsync("Player_" .. player.UserId)
    end)
    if ok and type(saved) == "table" then
        data.Level = math.max(1, tonumber(saved.Level) or 1)
        data.XP = math.max(0, tonumber(saved.XP) or 0)
        data.Gold = math.max(0, tonumber(saved.Gold) or 0)
        if Config.Classes[saved.Class] then data.Class = saved.Class end
    elseif not ok then
        warn("ECLIPSE: Data load failed for", player.Name, saved)
    end
    profiles[player] = data
    makeLeaderstats(player, data)
    player:SetAttribute("EclipseClass", data.Class)
    player:SetAttribute("EclipseCombo", 0)
    Notify:FireClient(player, "Welcome to Project ECLIPSE, " .. data.Class .. "!")
end

local function saveProfile(player)
    local data = profiles[player]
    if not data then return end
    local payload = {Level = data.Level, XP = data.XP, Gold = data.Gold, Class = data.Class}
    local ok, err = pcall(function()
        Store:UpdateAsync("Player_" .. player.UserId, function()
            return payload
        end)
    end)
    if not ok then warn("ECLIPSE: Data save failed for", player.Name, err) end
end

local function rewardPlayer(player)
    local data = profiles[player]
    if not data then return end
    data.XP += Config.XPPerEnemy
    data.Gold += Config.GoldPerEnemy
    while data.XP >= data.Level * 100 do
        data.XP -= data.Level * 100
        data.Level += 1
        Notify:FireClient(player, "LEVEL UP! You reached Level " .. data.Level)
    end
    syncStats(player)
    Notify:FireClient(player, "+" .. Config.XPPerEnemy .. " XP  |  +" .. Config.GoldPerEnemy .. " Gold")
end

local function damageEnemy(player, enemy, amount)
    if not enemy or not enemy.Parent then return false end
    local health = enemy:FindFirstChild("Health")
    if not health or health.Value <= 0 then return false end
    local tag = enemy:FindFirstChild("LastHitBy") or Instance.new("IntValue")
    tag.Name = "LastHitBy"
    tag.Value = player.UserId
    tag.Parent = enemy
    health.Value = math.max(0, health.Value - amount)
    return true
end

local function createEnemy(position, index)
    local model = Instance.new("Model")
    model.Name = "TrainingShade_" .. index

    local body = Instance.new("Part")
    body.Name = "Core"
    body.Shape = Enum.PartType.Ball
    body.Size = Vector3.new(4, 4, 4)
    body.Material = Enum.Material.Neon
    body.Color = Color3.fromRGB(95, 35, 150)
    body.Anchored = true
    body.CanCollide = true
    body.Position = position
    body.Parent = model

    local health = Instance.new("IntValue")
    health.Name = "Health"
    health.Value = Config.EnemyHealth
    health.Parent = model
    model.PrimaryPart = body

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "HealthDisplay"
    billboard.Size = UDim2.fromOffset(130, 28)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = body

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundColor3 = Color3.fromRGB(25, 15, 35)
    label.BackgroundTransparency = 0.2
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Text = tostring(health.Value) .. " / " .. tostring(Config.EnemyHealth)
    label.Parent = billboard

    health.Changed:Connect(function(value)
        label.Text = tostring(value) .. " / " .. tostring(Config.EnemyHealth)
    end)

    model.Parent = enemiesFolder
    health.Changed:Connect(function(value)
        if value <= 0 and model.Parent then
            local tag = model:FindFirstChild("LastHitBy")
            local killer = tag and Players:GetPlayerByUserId(tag.Value)
            if killer then rewardPlayer(killer) end
            model:Destroy()
            task.delay(Config.EnemyRespawnSeconds, function()
                if enemiesFolder.Parent then createEnemy(position, index) end
            end)
        end
    end)
    return model
end

local function createArena()
    if Workspace:FindFirstChild("EclipseArena") then return end
    local arena = Instance.new("Folder")
    arena.Name = "EclipseArena"
    arena.Parent = Workspace

    local floor = Instance.new("Part")
    floor.Name = "ArenaFloor"
    floor.Size = Vector3.new(120, 2, 90)
    floor.Position = Vector3.new(0, -1, 0)
    floor.Anchored = true
    floor.Material = Enum.Material.Slate
    floor.Color = Color3.fromRGB(24, 27, 42)
    floor.Parent = arena

    local spawn = Instance.new("SpawnLocation")
    spawn.Name = "EclipseSpawn"
    spawn.Size = Vector3.new(8, 1, 8)
    spawn.Position = Vector3.new(0, 1, 25)
    spawn.Anchored = true
    spawn.Neutral = true
    spawn.Color = Color3.fromRGB(40, 150, 220)
    spawn.Parent = arena

    for i = 1, 4 do
        local x = (i - 2.5) * 18
        createEnemy(Vector3.new(x, 3, -12), i)
    end
end

SelectClass.OnServerEvent:Connect(function(player, className)
    if type(className) ~= "string" or not Config.Classes[className] then return end
    local data = profiles[player]
    if not data then return end
    data.Class = className
    player:SetAttribute("EclipseClass", className)
    player:SetAttribute("EclipseCombo", 0)
    comboState[player] = nil
    Notify:FireClient(player, "Class selected: " .. className)
end)

Attack.OnServerEvent:Connect(function(player)
    local now = os.clock()
    if lastAttack[player] and now - lastAttack[player] < Config.AttackCooldown then return end
    lastAttack[player] = now

    local data = profiles[player]
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not data or not root then return end

    local class = Config.Classes[data.Class] or Config.Classes.Swordsman
    local target, nearest = nil, class.Range
    for _, enemy in ipairs(enemiesFolder:GetChildren()) do
        local core = enemy:FindFirstChild("Core")
        local health = enemy:FindFirstChild("Health")
        if core and health and health.Value > 0 then
            local distance = (core.Position - root.Position).Magnitude
            if distance <= nearest then
                nearest = distance
                target = enemy
            end
        end
    end

    if not target then
        Notify:FireClient(player, "No enemy in range.")
        return
    end

    local state = comboState[player] or {Count = 0, Last = 0}
    if now - state.Last > Config.ComboResetSeconds then state.Count = 0 end
    state.Count = (state.Count % 3) + 1
    state.Last = now
    comboState[player] = state
    player:SetAttribute("EclipseCombo", state.Count)

    local damage = class.Damage + math.max(0, data.Level - 1) * 2
    if state.Count == 3 then
        damage = math.floor(damage * 1.5)
        Notify:FireClient(player, "3-HIT COMBO! Finisher!")
    end
    damageEnemy(player, target, damage)
    if state.Count ~= 3 then
        Notify:FireClient(player, class.DisplayName .. " hit for " .. damage .. " damage! Combo " .. state.Count .. "/3")
    end
end)

UseSkill.OnServerEvent:Connect(function(player)
    local now = os.clock()
    local data = profiles[player]
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not data or not root then return end

    local class = Config.Classes[data.Class] or Config.Classes.Swordsman
    local readyAt = lastSkill[player] or 0
    if now < readyAt then
        Notify:FireClient(player, "Skill recharging: " .. math.ceil(readyAt - now) .. "s")
        return
    end
    lastSkill[player] = now + class.SkillCooldown

    local targets = {}
    for _, enemy in ipairs(enemiesFolder:GetChildren()) do
        local core = enemy:FindFirstChild("Core")
        local health = enemy:FindFirstChild("Health")
        if core and health and health.Value > 0 then
            local distance = (core.Position - root.Position).Magnitude
            if distance <= class.SkillRange then
                table.insert(targets, {Enemy = enemy, Distance = distance})
            end
        end
    end

    if #targets == 0 then
        lastSkill[player] = now
        Notify:FireClient(player, "No enemy close enough for " .. class.SkillName .. ".")
        return
    end

    table.sort(targets, function(a, b) return a.Distance < b.Distance end)
    if class.SkillMode == "Single" then
        damageEnemy(player, targets[1].Enemy, class.SkillDamage + math.max(0, data.Level - 1) * 3)
    else
        for _, target in ipairs(targets) do
            damageEnemy(player, target.Enemy, class.SkillDamage + math.max(0, data.Level - 1) * 3)
        end
    end
    Notify:FireClient(player, class.SkillName .. " activated! Cooldown: " .. class.SkillCooldown .. "s")
end)

Players.PlayerAdded:Connect(loadProfile)
Players.PlayerRemoving:Connect(function(player)
    saveProfile(player)
    profiles[player] = nil
    lastAttack[player] = nil
    lastSkill[player] = nil
    comboState[player] = nil
end)

game:BindToClose(function()
    for _, player in ipairs(Players:GetPlayers()) do
        saveProfile(player)
    end
end)

createArena()
