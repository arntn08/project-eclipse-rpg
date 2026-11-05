local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("GameConfig"))
local ItemConfig = require(Shared:WaitForChild("ItemConfig"))
local DungeonConfig = Config.Dungeon
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
local DungeonUpdate = getRemote("DungeonUpdate")
local InventoryAction = getRemote("InventoryAction")
local InventoryUpdate = getRemote("InventoryUpdate")

local profiles = {}
local lastAttack = {}
local lastSkill = {}
local comboState = {}
local dungeonStates = {}

local enemiesFolder = Workspace:FindFirstChild("EclipseEnemies") or Instance.new("Folder")
enemiesFolder.Name = "EclipseEnemies"
enemiesFolder.Parent = Workspace

local dungeonRoot = Workspace:FindFirstChild("PlayerDungeons") or Instance.new("Folder")
dungeonRoot.Name = "PlayerDungeons"
dungeonRoot.Parent = Workspace

local function notify(player, message)
    if player and player.Parent == Players then
        Notify:FireClient(player, message)
    end
end

local function updateDungeon(player, payload)
    if player and player.Parent == Players then
        DungeonUpdate:FireClient(player, payload)
    end
end

local function sendInventory(player)
    local data = profiles[player]
    if not data then return end
    local items = {}
    for _, id in ipairs(data.Inventory) do
        local item = ItemConfig.Items[id]
        if item then
            table.insert(items, {Id=id,Name=item.Name,Slot=item.Slot,Rarity=item.Rarity,Attack=item.Attack,Defense=item.Defense,Level=item.Level,SellValue=item.SellValue,Description=item.Description})
        end
    end
    InventoryUpdate:FireClient(player, {Items=items, Equipped=data.Equipped})
end

local function getEquipmentBonuses(data)
    local attack, defense = 0, 0
    for slot, id in pairs(data.Equipped) do
        local item = ItemConfig.Items[id]
        if item and item.Slot == slot then
            attack += item.Attack
            defense += item.Defense
        end
    end
    return attack, defense
end

local function refreshWeaponVisual(player)
    local character = player.Character
    local data = profiles[player]
    if not character or not data then return end
    local hand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
    if not hand then return end
    local old = character:FindFirstChild("EclipseWeaponVisual")
    if old then old:Destroy() end
    local weaponId = data.Equipped and data.Equipped.Weapon
    local item = weaponId and ItemConfig.Items[weaponId]
    if not item then return end
    local model = Instance.new("Model")
    model.Name = "EclipseWeaponVisual"
    model.Parent = character
    local colors = {TrainingBlade=Color3.fromRGB(185,205,220),AzureEdge=Color3.fromRGB(45,175,255),ShadowFang=Color3.fromRGB(165,75,235)}
    local blade = Instance.new("Part")
    blade.Name = "Blade"
    blade.Size = Vector3.new(0.22, 2.7, 0.42)
    blade.Material = Enum.Material.Neon
    blade.Color = colors[weaponId] or Color3.fromRGB(90,190,255)
    blade.CanCollide = false
    blade.Massless = true
    blade.Anchored = false
    blade.Parent = model
    local grip = Instance.new("Part")
    grip.Name = "Grip"
    grip.Size = Vector3.new(0.3,0.8,0.3)
    grip.Color = Color3.fromRGB(35,30,45)
    grip.CanCollide = false
    grip.Massless = true
    grip.Anchored = false
    grip.Parent = model
    local offset = CFrame.new(0,-0.9,0) * CFrame.Angles(math.rad(12),0,math.rad(12))
    blade.CFrame = hand.CFrame * offset
    grip.CFrame = blade.CFrame * CFrame.new(0,-1.45,0)
    local bladeWeld = Instance.new("WeldConstraint")
    bladeWeld.Part0 = blade
    bladeWeld.Part1 = grip
    bladeWeld.Parent = blade
    local handWeld = Instance.new("Weld")
    handWeld.Part0 = hand
    handWeld.Part1 = blade
    handWeld.C0 = offset
    handWeld.Parent = hand
end

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

local function grantRewards(player, xp, gold)
    local data = profiles[player]
    if not data then return end
    data.XP += xp
    data.Gold += gold
    while data.XP >= data.Level * 100 do
        data.XP -= data.Level * 100
        data.Level += 1
        notify(player, "LEVEL UP! You reached Level " .. data.Level)
    end
    syncStats(player)
    notify(player, "+" .. xp .. " XP  |  +" .. gold .. " Gold")
end

local function loadProfile(player)
    local data = {Level=1, XP=0, Gold=0, Class="Swordsman", Inventory={"TrainingBlade","NoviceArmor"}, Equipped={Weapon="TrainingBlade",Armor="NoviceArmor"}}
    local ok, saved = pcall(function()
        return Store:GetAsync("Player_" .. player.UserId)
    end)
    if ok and type(saved) == "table" then
        data.Level = math.max(1, tonumber(saved.Level) or 1)
        data.XP = math.max(0, tonumber(saved.XP) or 0)
        data.Gold = math.max(0, tonumber(saved.Gold) or 0)
        if Config.Classes[saved.Class] then data.Class = saved.Class end
        if type(saved.Inventory) == "table" then
            data.Inventory = {}
            for _, id in ipairs(saved.Inventory) do
                if type(id) == "string" and ItemConfig.Items[id] then table.insert(data.Inventory, id) end
            end
            if #data.Inventory == 0 then data.Inventory = {"TrainingBlade","NoviceArmor"} end
        end
        if type(saved.Equipped) == "table" then
            for slot, id in pairs(saved.Equipped) do
                local item = ItemConfig.Items[id]
                if item and item.Slot == slot and table.find(data.Inventory,id) then data.Equipped[slot] = id end
            end
        end
    elseif not ok then
        warn("ECLIPSE: Data load failed for", player.Name, saved)
    end
    profiles[player] = data
    makeLeaderstats(player, data)
    player:SetAttribute("EclipseClass", data.Class)
    player:SetAttribute("EclipseCombo", 0)
    local _, defense = getEquipmentBonuses(data)
    player:SetAttribute("EclipseDefense", defense)
    sendInventory(player)
    refreshWeaponVisual(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.7)
        refreshWeaponVisual(player)
    end)
    notify(player, "Welcome to Project ECLIPSE, " .. data.Class .. "!")
end

local function saveProfile(player)
    local data = profiles[player]
    if not data then return end
    local payload = {Level=data.Level,XP=data.XP,Gold=data.Gold,Class=data.Class,Inventory=data.Inventory,Equipped=data.Equipped}
    local ok, err = pcall(function()
        Store:UpdateAsync("Player_" .. player.UserId, function()
            return payload
        end)
    end)
    if not ok then warn("ECLIPSE: Data save failed for", player.Name, err) end
end

local function awardDrop(player, isBoss)
    local data = profiles[player]
    if not data then return end
    local drops = isBoss and ItemConfig.DropTables.Boss or ItemConfig.DropTables.Normal
    local roll, total = math.random(1,100), 0
    for _, entry in ipairs(drops) do
        total += entry.Chance
        if roll <= total then
            table.insert(data.Inventory, entry.Id)
            local item = ItemConfig.Items[entry.Id]
            notify(player, "LOOT: " .. item.Name .. " [" .. item.Rarity .. "]")
            sendInventory(player)
            return
        end
    end
end

local function createPart(parent, name, size, position, color, material)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.Position = position
    part.Anchored = true
    part.Color = color
    part.Material = material or Enum.Material.Slate
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.Parent = parent
    return part
end

local function addHealthDisplay(core, health, maxHealth, title)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "HealthDisplay"
    billboard.Size = UDim2.fromOffset(170, 42)
    billboard.StudsOffset = Vector3.new(0, core.Size.Y / 2 + 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = core

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 17)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextStrokeTransparency = 0.25
    titleLabel.Font = Enum.Font.GothamBlack
    titleLabel.TextSize = 12
    titleLabel.Parent = billboard

    local back = Instance.new("Frame")
    back.Position = UDim2.fromOffset(0, 20)
    back.Size = UDim2.new(1, 0, 0, 12)
    back.BackgroundColor3 = Color3.fromRGB(35, 20, 30)
    back.BorderSizePixel = 0
    back.Parent = billboard

    local fill = Instance.new("Frame")
    fill.Size = UDim2.fromScale(1, 1)
    fill.BackgroundColor3 = Color3.fromRGB(50, 220, 120)
    fill.BorderSizePixel = 0
    fill.Parent = back

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Position = UDim2.fromOffset(0, 31)
    valueLabel.Size = UDim2.new(1, 0, 0, 12)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = Color3.new(1, 1, 1)
    valueLabel.TextStrokeTransparency = 0.3
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 10
    valueLabel.Parent = billboard

    local function refresh(value)
        local ratio = math.clamp(value / maxHealth, 0, 1)
        fill.Size = UDim2.fromScale(ratio, 1)
        valueLabel.Text = tostring(value) .. " / " .. tostring(maxHealth)
        if ratio <= 0.3 then
            fill.BackgroundColor3 = Color3.fromRGB(230, 55, 65)
        elseif ratio <= 0.6 then
            fill.BackgroundColor3 = Color3.fromRGB(245, 175, 55)
        end
    end
    refresh(health.Value)
    health.Changed:Connect(refresh)
end

local function getPlayerEnemyFolder(player)
    local state = dungeonStates[player]
    if state and state.Active then return state.EnemyFolder end
    return enemiesFolder
end

local function countLivingEnemies(folder)
    local count = 0
    for _, enemy in ipairs(folder:GetChildren()) do
        local health = enemy:FindFirstChild("Health")
        if health and health.Value > 0 then count += 1 end
    end
    return count
end

local checkDungeonWave

local function damageEnemy(player, enemy, amount)
    if not enemy or not enemy.Parent or enemy:GetAttribute("Defeated") then return false end
    local health = enemy:FindFirstChild("Health")
    if not health or health.Value <= 0 then return false end
    local tag = enemy:FindFirstChild("LastHitBy") or Instance.new("IntValue")
    tag.Name = "LastHitBy"
    tag.Value = player.UserId
    tag.Parent = enemy
    health.Value = math.max(0, health.Value - amount)
    local core = enemy:FindFirstChild("Core")
    if core then
        local popup = Instance.new("BillboardGui")
        popup.Name = "DamageNumber"
        popup.Size = UDim2.fromOffset(90,32)
        popup.StudsOffset = Vector3.new(math.random(-2,2),4,0)
        popup.AlwaysOnTop = true
        popup.Parent = core
        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromScale(1,1)
        label.BackgroundTransparency = 1
        label.Text = "-" .. tostring(amount)
        label.TextColor3 = Color3.fromRGB(255,225,110)
        label.TextStrokeTransparency = 0.15
        label.Font = Enum.Font.GothamBlack
        label.TextSize = 22
        label.Parent = popup
        task.delay(0.75,function() if popup.Parent then popup:Destroy() end end)
    end
    return true
end

local function createEnemy(parentFolder, position, name, healthAmount, isBoss, owner)
    local model = Instance.new("Model")
    model.Name = name
    model:SetAttribute("IsBoss", isBoss == true)
    model:SetAttribute("OwnerUserId", owner and owner.UserId or 0)

    local core = Instance.new("Part")
    core.Name = "Core"
    core.Shape = Enum.PartType.Ball
    core.Size = isBoss and Vector3.new(10, 10, 10) or Vector3.new(4, 4, 4)
    core.Material = Enum.Material.Neon
    core.Color = isBoss and Color3.fromRGB(190, 35, 65) or Color3.fromRGB(95, 35, 150)
    core.Anchored = true
    core.CanCollide = true
    core.Position = position
    core.Parent = model

    local health = Instance.new("IntValue")
    health.Name = "Health"
    health.Value = healthAmount
    health.Parent = model
    model.PrimaryPart = core

    addHealthDisplay(core, health, healthAmount, isBoss and "ECLIPSE OVERLORD" or name)
    model.Parent = parentFolder

    health.Changed:Connect(function(value)
        if isBoss and owner then
            updateDungeon(owner, {Mode = "BossHealth", Ratio = value / healthAmount})
        end
        if value > 0 or model:GetAttribute("Defeated") then return end
        model:SetAttribute("Defeated", true)

        local tag = model:FindFirstChild("LastHitBy")
        local killer = tag and Players:GetPlayerByUserId(tag.Value)
        if killer then
            if isBoss then
                grantRewards(killer, 200, 100)
                awardDrop(killer, true)
            else
                grantRewards(killer, Config.XPPerEnemy, Config.GoldPerEnemy)
                if owner then awardDrop(killer, false) end
            end
        end

        model:Destroy()
        if owner and checkDungeonWave then
            task.defer(checkDungeonWave, owner)
        elseif not isBoss then
            task.delay(Config.EnemyRespawnSeconds, function()
                if enemiesFolder.Parent then
                    createEnemy(enemiesFolder, position, name, Config.EnemyHealth, false, nil)
                end
            end)
        end
    end)

    if not isBoss then
        task.spawn(function()
            local nextAttack = 0
            while model.Parent and health.Value > 0 do
                task.wait(0.25)
                if not model.Parent or health.Value <= 0 then break end
                local target = owner
                local targetRoot, targetHumanoid
                if target then
                    local character = target.Character
                    targetRoot = character and character:FindFirstChild("HumanoidRootPart")
                    targetHumanoid = character and character:FindFirstChildOfClass("Humanoid")
                else
                    local nearestDistance = 65
                    for _, candidate in ipairs(Players:GetPlayers()) do
                        local character = candidate.Character
                        local candidateRoot = character and character:FindFirstChild("HumanoidRootPart")
                        local candidateHumanoid = character and character:FindFirstChildOfClass("Humanoid")
                        if candidateRoot and candidateHumanoid and candidateHumanoid.Health > 0 then
                            local distance = (candidateRoot.Position-core.Position).Magnitude
                            if distance < nearestDistance then
                                nearestDistance = distance
                                target, targetRoot, targetHumanoid = candidate, candidateRoot, candidateHumanoid
                            end
                        end
                    end
                end
                if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                    local delta = targetRoot.Position-core.Position
                    local distance = delta.Magnitude
                    if distance > 6 then
                        local direction = delta.Unit
                        local nextPosition = core.Position + direction * math.min(1.6, distance-5)
                        core.Position = Vector3.new(nextPosition.X, core.Position.Y, nextPosition.Z)
                    elseif os.clock() >= nextAttack then
                        nextAttack = os.clock()+2.4
                        local warning = Instance.new("Part")
                        warning.Name = "EnemyAttackWarning"
                        warning.Shape = Enum.PartType.Cylinder
                        warning.Size = Vector3.new(0.18,7,7)
                        warning.CFrame = CFrame.new(targetRoot.Position.X,0.15,targetRoot.Position.Z) * CFrame.Angles(0,0,math.rad(90))
                        warning.Anchored = true
                        warning.CanCollide = false
                        warning.Material = Enum.Material.Neon
                        warning.Color = Color3.fromRGB(255,75,65)
                        warning.Transparency = 0.35
                        warning.Parent = parentFolder
                        task.wait(0.65)
                        if warning.Parent then warning:Destroy() end
                        if targetRoot.Parent and (targetRoot.Position-core.Position).Magnitude <= 9 then
                            local _, defense = getEquipmentBonuses(profiles[target] or {})
                            local hit = math.max(1, 8-math.floor(defense*0.2))
                            targetHumanoid:TakeDamage(hit)
                            notify(target,"SHADE STRIKE! -" .. hit .. " HP")
                        end
                    end
                end
            end
        end)
    end

    if isBoss and owner then
        task.spawn(function()
            while model.Parent and health.Value > 0 do
                task.wait(DungeonConfig.BossAttackInterval)
                if not model.Parent or health.Value <= 0 then break end
                local character = owner.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                if root and humanoid and humanoid.Health > 0 then
                    if (root.Position - core.Position).Magnitude <= DungeonConfig.BossAttackRange then
                        notify(owner, "WARNING: OVERLORD PULSE — MOVE AWAY!")
                        local warning = Instance.new("Part")
                        warning.Name = "BossAttackWarning"
                        warning.Shape = Enum.PartType.Cylinder
                        warning.Size = Vector3.new(0.2,DungeonConfig.BossAttackRange*2,DungeonConfig.BossAttackRange*2)
                        warning.CFrame = CFrame.new(root.Position.X,0.2,root.Position.Z) * CFrame.Angles(0,0,math.rad(90))
                        warning.Anchored = true
                        warning.CanCollide = false
                        warning.Material = Enum.Material.Neon
                        warning.Color = Color3.fromRGB(255,35,65)
                        warning.Transparency = 0.55
                        warning.Parent = parentFolder
                        task.wait(1)
                        if warning.Parent then warning:Destroy() end
                        if not root.Parent or (root.Position-core.Position).Magnitude > DungeonConfig.BossAttackRange then continue end
                        local _, defense = getEquipmentBonuses(profiles[owner] or {})
                        local actualDamage = math.max(1, DungeonConfig.BossDamage - math.floor(defense * 0.25))
                        humanoid:TakeDamage(actualDamage)
                        notify(owner, "OVERLORD PULSE! -" .. actualDamage .. " HP")
                        local pulse = Instance.new("Part")
                        pulse.Name = "BossPulseEffect"
                        pulse.Shape = Enum.PartType.Ball
                        pulse.Size = Vector3.new(2, 2, 2)
                        pulse.Position = core.Position
                        pulse.Anchored = true
                        pulse.CanCollide = false
                        pulse.Material = Enum.Material.Neon
                        pulse.Color = Color3.fromRGB(255, 55, 85)
                        pulse.Transparency = 0.35
                        pulse.Parent = parentFolder
                        task.spawn(function()
                            for step = 1, 8 do
                                if not pulse.Parent then break end
                                pulse.Size += Vector3.new(2, 2, 2)
                                pulse.Transparency = math.min(0.95, pulse.Transparency + 0.07)
                                task.wait(0.05)
                            end
                            pulse:Destroy()
                        end)
                    end
                end
            end
        end)
    end

    return model
end

local function makeDungeonRoom(player)
    local folder = Instance.new("Folder")
    folder.Name = "Dungeon_" .. player.UserId
    folder.Parent = dungeonRoot

    local slot = player.UserId % 1000
    local origin = Vector3.new(slot * 180, 0, 500)
    local room = Instance.new("Folder")
    room.Name = "Room"
    room.Parent = folder

    createPart(room, "DungeonFloor", Vector3.new(100, 2, 100), origin + Vector3.new(0, -1, 0), Color3.fromRGB(19, 20, 36), Enum.Material.Slate)
    createPart(room, "NorthWall", Vector3.new(100, 24, 3), origin + Vector3.new(0, 11, -50), Color3.fromRGB(35, 28, 58), Enum.Material.Basalt)
    createPart(room, "SouthWall", Vector3.new(100, 24, 3), origin + Vector3.new(0, 11, 50), Color3.fromRGB(35, 28, 58), Enum.Material.Basalt)
    createPart(room, "WestWall", Vector3.new(3, 24, 100), origin + Vector3.new(-50, 11, 0), Color3.fromRGB(35, 28, 58), Enum.Material.Basalt)
    createPart(room, "EastWall", Vector3.new(3, 24, 100), origin + Vector3.new(50, 11, 0), Color3.fromRGB(35, 28, 58), Enum.Material.Basalt)

    local gate = createPart(room, "EclipseGate", Vector3.new(12, 18, 2), origin + Vector3.new(0, 8, -43), Color3.fromRGB(30, 145, 220), Enum.Material.Neon)
    gate.Transparency = 0.2
    gate.CanCollide = false

    local enemies = Instance.new("Folder")
    enemies.Name = "Enemies"
    enemies.Parent = folder

    return folder, enemies, origin
end

local function sendDungeonProgress(player, state, message)
    updateDungeon(player, {
        Mode = "Progress",
        Stage = state.Stage,
        StageCount = DungeonConfig.StageCount,
        Wave = state.Wave,
        WaveCount = DungeonConfig.WavesPerStage,
        Message = message or "Defeat all enemies!",
        Boss = state.BossActive,
    })
end

local function spawnDungeonWave(player)
    local state = dungeonStates[player]
    if not state or not state.Active then return end
    state.Transitioning = false
    state.BossActive = state.Stage == DungeonConfig.StageCount and state.Wave == DungeonConfig.WavesPerStage

    if state.BossActive then
        createEnemy(
            state.EnemyFolder,
            state.Origin + Vector3.new(0, 6, -10),
            "EclipseOverlord",
            DungeonConfig.BossHealth,
            true,
            player
        )
        sendDungeonProgress(player, state, "BOSS ENCOUNTER: THE ECLIPSE OVERLORD")
        notify(player, "A powerful presence has appeared...")
        return
    end

    local amount = DungeonConfig.BaseEnemiesPerWave + (state.Stage - 1) * DungeonConfig.ExtraEnemiesPerStage
    for index = 1, amount do
        local x = ((index - 1) - (amount - 1) / 2) * 12
        local z = -12 - ((index % 2) * 8)
        createEnemy(
            state.EnemyFolder,
            state.Origin + Vector3.new(x, 3, z),
            "DungeonShade",
            Config.EnemyHealth + (state.Stage - 1) * 20,
            false,
            player
        )
    end
    sendDungeonProgress(player, state, "Wave " .. state.Wave .. ": eliminate every Shade!")
    notify(player, "DUNGEON WAVE " .. state.Wave .. " — Stage " .. state.Stage)
end

local function finishDungeon(player)
    local state = dungeonStates[player]
    if not state or not state.Active then return end
    state.Active = false
    grantRewards(player, DungeonConfig.FinalClearXP, DungeonConfig.FinalClearGold)
    notify(player, "DUNGEON CLEARED! The gate is opening.")
    updateDungeon(player, {Mode = "Complete", Message = "DUNGEON CLEARED", XP = DungeonConfig.FinalClearXP, Gold = DungeonConfig.FinalClearGold})

    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if root then root.CFrame = CFrame.new(0, 5, 25) end

    task.delay(5, function()
        if state.Folder and state.Folder.Parent then state.Folder:Destroy() end
        if dungeonStates[player] == state then dungeonStates[player] = nil end
        updateDungeon(player, {Mode = "Hidden"})
    end)
end

checkDungeonWave = function(player)
    local state = dungeonStates[player]
    if not state or not state.Active or state.Transitioning then return end
    if countLivingEnemies(state.EnemyFolder) > 0 then return end

    state.Transitioning = true
    if state.BossActive then
        finishDungeon(player)
        return
    end

    grantRewards(player, DungeonConfig.StageClearXP, DungeonConfig.StageClearGold)
    notify(player, "WAVE CLEARED! Bonus rewards earned.")
    task.delay(2, function()
        if not state.Active then return end
        if state.Wave < DungeonConfig.WavesPerStage then
            state.Wave += 1
        elseif state.Stage < DungeonConfig.StageCount then
            state.Stage += 1
            state.Wave = 1
        else
            finishDungeon(player)
            return
        end
        spawnDungeonWave(player)
    end)
end

local function enterDungeon(player)
    if dungeonStates[player] and dungeonStates[player].Active then
        notify(player, "You are already inside a dungeon.")
        return
    end
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then
        notify(player, "Your character is still loading.")
        return
    end

    local folder, enemyFolder, origin = makeDungeonRoom(player)
    local state = {
        Active = true,
        Transitioning = false,
        Stage = 1,
        Wave = 1,
        BossActive = false,
        Folder = folder,
        EnemyFolder = enemyFolder,
        Origin = origin,
    }
    dungeonStates[player] = state
    root.CFrame = CFrame.new(origin + Vector3.new(0, 5, 28))
    updateDungeon(player, {Mode = "Show"})
    spawnDungeonWave(player)
end

local function createArena()
    if Workspace:FindFirstChild("EclipseArena") then return end
    local arena = Instance.new("Folder")
    arena.Name = "EclipseArena"
    arena.Parent = Workspace

    createPart(arena, "ArenaFloor", Vector3.new(120, 2, 90), Vector3.new(0, -1, 0), Color3.fromRGB(24, 27, 42), Enum.Material.Slate)

    local spawn = Instance.new("SpawnLocation")
    spawn.Name = "EclipseSpawn"
    spawn.Size = Vector3.new(8, 1, 8)
    spawn.Position = Vector3.new(0, 1, 25)
    spawn.Anchored = true
    spawn.Neutral = true
    spawn.Color = Color3.fromRGB(40, 150, 220)
    spawn.Parent = arena

    for index = 1, 4 do
        local x = (index - 2.5) * 18
        createEnemy(enemiesFolder, Vector3.new(x, 3, -12), "TrainingShade", Config.EnemyHealth, false, nil)
    end

    local portal = createPart(arena, "DungeonPortal", Vector3.new(12, 16, 2), Vector3.new(0, 8, -34), Color3.fromRGB(20, 145, 255), Enum.Material.Neon)
    portal.Transparency = 0.18
    portal.CanCollide = false

    local light = Instance.new("PointLight")
    light.Color = Color3.fromRGB(40, 160, 255)
    light.Range = 24
    light.Brightness = 2
    light.Parent = portal

    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Enter Dungeon"
    prompt.ObjectText = "ECLIPSE GATE"
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.HoldDuration = 0.5
    prompt.MaxActivationDistance = 14
    prompt.RequiresLineOfSight = false
    prompt.Parent = portal
    prompt.Triggered:Connect(enterDungeon)
end

InventoryAction.OnServerEvent:Connect(function(player, action, itemId)
    local data = profiles[player]
    if not data or type(action) ~= "string" then return end
    if action == "Request" then
        sendInventory(player)
    elseif action == "Equip" then
        if type(itemId) ~= "string" or not table.find(data.Inventory,itemId) then return end
        local item = ItemConfig.Items[itemId]
        if not item then return end
        if data.Level < item.Level then
            notify(player, "Required level: " .. item.Level)
            return
        end
        data.Equipped[item.Slot] = itemId
        local _, defense = getEquipmentBonuses(data)
        player:SetAttribute("EclipseDefense", defense)
        if item.Slot == "Weapon" then refreshWeaponVisual(player) end
        notify(player, item.Name .. " equipped!")
        sendInventory(player)
    elseif action == "Sell" then
        if type(itemId) ~= "string" or not table.find(data.Inventory,itemId) then return end
        local item = ItemConfig.Items[itemId]
        if not item or data.Equipped[item.Slot] == itemId then
            notify(player, "Unequip this item before selling it.")
            return
        end
        table.remove(data.Inventory, table.find(data.Inventory,itemId))
        data.Gold += item.SellValue
        syncStats(player)
        notify(player, item.Name .. " sold for " .. item.SellValue .. " Gold.")
        sendInventory(player)
    end
end)

SelectClass.OnServerEvent:Connect(function(player, className)
    if type(className) ~= "string" or not Config.Classes[className] then return end
    local data = profiles[player]
    if not data then return end
    data.Class = className
    player:SetAttribute("EclipseClass", className)
    player:SetAttribute("EclipseCombo", 0)
    comboState[player] = nil
    notify(player, "Class selected: " .. className)
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
    local folder = getPlayerEnemyFolder(player)
    local target, nearest = nil, class.Range
    for _, enemy in ipairs(folder:GetChildren()) do
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
        notify(player, "No enemy in range.")
        return
    end

    local state = comboState[player] or {Count = 0, Last = 0}
    if now - state.Last > Config.ComboResetSeconds then state.Count = 0 end
    state.Count = (state.Count % 3) + 1
    state.Last = now
    comboState[player] = state
    player:SetAttribute("EclipseCombo", state.Count)

    local weaponAttack = getEquipmentBonuses(data)
    local damage = class.Damage + math.max(0, data.Level - 1) * 2 + weaponAttack
    if state.Count == 3 then
        damage = math.floor(damage * 1.5)
        notify(player, "3-HIT COMBO! Finisher!")
    else
        notify(player, class.DisplayName .. " hit for " .. damage .. " damage! Combo " .. state.Count .. "/3")
    end
    damageEnemy(player, target, damage)
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
        notify(player, "Skill recharging: " .. math.ceil(readyAt - now) .. "s")
        return
    end

    local folder = getPlayerEnemyFolder(player)
    local targets = {}
    for _, enemy in ipairs(folder:GetChildren()) do
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
        notify(player, "No enemy close enough for " .. class.SkillName .. ".")
        return
    end

    lastSkill[player] = now + class.SkillCooldown
    table.sort(targets, function(a, b) return a.Distance < b.Distance end)
    local weaponAttack = getEquipmentBonuses(data)
    local damage = class.SkillDamage + math.max(0, data.Level - 1) * 3 + weaponAttack
    if class.SkillMode == "Single" then
        damageEnemy(player, targets[1].Enemy, damage)
    else
        for _, target in ipairs(targets) do
            damageEnemy(player, target.Enemy, damage)
        end
    end
    notify(player, class.SkillName .. " activated!")
end)

Players.PlayerAdded:Connect(loadProfile)
Players.PlayerRemoving:Connect(function(player)
    saveProfile(player)
    local state = dungeonStates[player]
    if state and state.Folder then state.Folder:Destroy() end
    dungeonStates[player] = nil
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
for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(loadProfile, player)
end
