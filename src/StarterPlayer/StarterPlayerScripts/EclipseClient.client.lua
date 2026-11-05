local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))
local remotes = ReplicatedStorage:WaitForChild("EclipseRemotes")
local SelectClass = remotes:WaitForChild("SelectClass")
local Attack = remotes:WaitForChild("Attack")
local UseSkill = remotes:WaitForChild("UseSkill")
local Notify = remotes:WaitForChild("Notify")
local DungeonUpdate = remotes:WaitForChild("DungeonUpdate")
local InventoryAction = remotes:WaitForChild("InventoryAction")
local InventoryUpdate = remotes:WaitForChild("InventoryUpdate")

local gui = Instance.new("ScreenGui")
gui.Name = "EclipseHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function make(className, props, parent)
    local obj = Instance.new(className)
    for key, value in pairs(props) do obj[key] = value end
    obj.Parent = parent
    return obj
end

local function rounded(frame, radius)
    make("UICorner", {CornerRadius = UDim.new(0, radius or 10)}, frame)
    return frame
end

local panel = rounded(make("Frame", {
    Name = "TopPanel",
    Size = UDim2.new(0, 330, 0, 100),
    Position = UDim2.new(0, 16, 0, 16),
    BackgroundColor3 = Color3.fromRGB(12, 16, 30),
    BackgroundTransparency = 0.1,
    BorderSizePixel = 0,
}, gui), 12)
make("UIStroke", {Color = Color3.fromRGB(40, 170, 255), Thickness = 1.5}, panel)

make("TextLabel", {
    Size = UDim2.new(1, -20, 0, 32),
    Position = UDim2.fromOffset(12, 7),
    BackgroundTransparency = 1,
    Text = "PROJECT ECLIPSE  //  ALPHA 0.1",
    TextColor3 = Color3.fromRGB(100, 205, 255),
    Font = Enum.Font.GothamBlack,
    TextSize = 17,
    TextXAlignment = Enum.TextXAlignment.Left,
}, panel)

local stats = make("TextLabel", {
    Name = "Stats",
    Size = UDim2.new(1, -24, 0, 26),
    Position = UDim2.fromOffset(12, 43),
    BackgroundTransparency = 1,
    Text = "Loading hunter profile...",
    TextColor3 = Color3.fromRGB(245, 245, 255),
    Font = Enum.Font.GothamMedium,
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
}, panel)

local classLabel = make("TextLabel", {
    Size = UDim2.new(1, -24, 0, 20),
    Position = UDim2.fromOffset(12, 70),
    BackgroundTransparency = 1,
    Text = "CLASS: " .. (player:GetAttribute("EclipseClass") or "Swordsman"),
    TextColor3 = Color3.fromRGB(190, 200, 220),
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
}, panel)

local classPanel = rounded(make("Frame", {
    Size = UDim2.new(0, 230, 0, 164),
    Position = UDim2.new(0, 16, 0, 128),
    BackgroundColor3 = Color3.fromRGB(12, 16, 30),
    BackgroundTransparency = 0.1,
    BorderSizePixel = 0,
}, gui), 12)
make("TextLabel", {
    Size = UDim2.new(1, -16, 0, 28),
    Position = UDim2.fromOffset(8, 5),
    BackgroundTransparency = 1,
    Text = "CHOOSE YOUR CLASS",
    TextColor3 = Color3.fromRGB(100, 205, 255),
    Font = Enum.Font.GothamBlack,
    TextSize = 14,
}, classPanel)

for index, className in ipairs({"Swordsman", "Mage", "Archer"}) do
    local classConfig = Config.Classes[className]
    local button = rounded(make("TextButton", {
        Name = className,
        Size = UDim2.new(1, -20, 0, 34),
        Position = UDim2.fromOffset(10, 37 + (index - 1) * 39),
        BackgroundColor3 = classConfig.Color,
        Text = className .. "  —  " .. classConfig.Description,
        TextColor3 = Color3.fromRGB(15, 18, 28),
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        TextWrapped = true,
    }, classPanel), 7)
    button.Activated:Connect(function()
        SelectClass:FireServer(className)
    end)
end

local attackButton = rounded(make("TextButton", {
    Name = "AttackButton",
    Size = UDim2.fromOffset(112, 112),
    Position = UDim2.new(1, -140, 1, -150),
    BackgroundColor3 = Color3.fromRGB(25, 115, 210),
    Text = "ATTACK",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 19,
    Font = Enum.Font.GothamBlack,
}, gui), 100)
make("UIStroke", {Color = Color3.fromRGB(130, 220, 255), Thickness = 3}, attackButton)
attackButton.Activated:Connect(function()
    Attack:FireServer()
end)

local skillButton = rounded(make("TextButton", {
    Name = "SkillButton",
    Size = UDim2.fromOffset(92, 92),
    Position = UDim2.new(1, -250, 1, -126),
    BackgroundColor3 = Color3.fromRGB(125, 55, 205),
    Text = "SKILL\nQ",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 17,
    Font = Enum.Font.GothamBlack,
    TextWrapped = true,
}, gui), 100)
make("UIStroke", {Color = Color3.fromRGB(210, 155, 255), Thickness = 3}, skillButton)

local skillBusy = false
local function activateSkill()
    if skillBusy then return end
    skillBusy = true
    UseSkill:FireServer()
    local className = player:GetAttribute("EclipseClass") or "Swordsman"
    local cooldown = Config.Classes[className].SkillCooldown
    for remaining = cooldown, 1, -1 do
        skillButton.Text = tostring(remaining) .. "s"
        task.wait(1)
    end
    local currentClass = player:GetAttribute("EclipseClass") or "Swordsman"
    skillButton.Text = Config.Classes[currentClass].SkillName .. "\nQ"
    skillBusy = false
end
skillButton.Activated:Connect(activateSkill)

local notice = rounded(make("TextLabel", {
    Name = "Notice",
    Size = UDim2.new(0, 360, 0, 42),
    Position = UDim2.new(0.5, -180, 0, 18),
    BackgroundColor3 = Color3.fromRGB(10, 15, 28),
    BackgroundTransparency = 0.12,
    Text = "",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 16,
    Font = Enum.Font.GothamBold,
    Visible = false,
}, gui), 9)

local dungeonPanel = rounded(make("Frame", {
    Name = "DungeonPanel",
    Size = UDim2.new(0, 310, 0, 76),
    Position = UDim2.new(0.5, -155, 0, 18),
    BackgroundColor3 = Color3.fromRGB(12, 16, 30),
    BackgroundTransparency = 0.08,
    BorderSizePixel = 0,
    Visible = false,
}, gui), 10)
make("UIStroke", {Color = Color3.fromRGB(40, 170, 255), Thickness = 1.5}, dungeonPanel)

local dungeonTitle = make("TextLabel", {
    Size = UDim2.new(1, -16, 0, 28),
    Position = UDim2.fromOffset(8, 5),
    BackgroundTransparency = 1,
    Text = "DUNGEON",
    TextColor3 = Color3.fromRGB(110, 205, 255),
    TextSize = 17,
    Font = Enum.Font.GothamBlack,
}, dungeonPanel)

local dungeonInfo = make("TextLabel", {
    Size = UDim2.new(1, -16, 0, 24),
    Position = UDim2.fromOffset(8, 36),
    BackgroundTransparency = 1,
    Text = "Stage 1 / 3  •  Wave 1 / 2",
    TextColor3 = Color3.fromRGB(245, 245, 255),
    TextSize = 14,
    Font = Enum.Font.GothamBold,
}, dungeonPanel)

local bossPanel = rounded(make("Frame", {
    Name = "BossHealthPanel",
    Size = UDim2.new(0, 300, 0, 48),
    Position = UDim2.new(0.5, -150, 0, 102),
    BackgroundColor3 = Color3.fromRGB(22, 10, 22),
    BackgroundTransparency = 0.08,
    BorderSizePixel = 0,
    Visible = false,
}, gui), 8)

local bossName = make("TextLabel", {
    Size = UDim2.new(1, -12, 0, 18),
    Position = UDim2.fromOffset(6, 2),
    BackgroundTransparency = 1,
    Text = "ECLIPSE OVERLORD",
    TextColor3 = Color3.fromRGB(255, 125, 145),
    TextSize = 12,
    Font = Enum.Font.GothamBlack,
}, bossPanel)

local bossBack = make("Frame", {
    Size = UDim2.new(1, -16, 0, 13),
    Position = UDim2.fromOffset(8, 27),
    BackgroundColor3 = Color3.fromRGB(60, 25, 35),
    BorderSizePixel = 0,
}, bossPanel)
rounded(bossBack, 5)

local bossFill = make("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(225, 45, 75),
    BorderSizePixel = 0,
}, bossBack)
rounded(bossFill, 5)

local function updateStats()
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then return end
    local level = leaderstats:FindFirstChild("Level")
    local xp = leaderstats:FindFirstChild("XP")
    local gold = leaderstats:FindFirstChild("Gold")
    if level and xp and gold then
        stats.Text = string.format("LEVEL %d     XP %d / %d     GOLD %d", level.Value, xp.Value, level.Value * 100, gold.Value)
    end
end

task.spawn(function()
    local leaderstats = player:WaitForChild("leaderstats", 20)
    if leaderstats then
        for _, value in ipairs(leaderstats:GetChildren()) do
            value.Changed:Connect(updateStats)
        end
        leaderstats.ChildAdded:Connect(function(value)
            value.Changed:Connect(updateStats)
            updateStats()
        end)
        updateStats()
    end
end)

player:GetAttributeChangedSignal("EclipseClass"):Connect(function()
    local className = player:GetAttribute("EclipseClass") or "Swordsman"
    classLabel.Text = "CLASS: " .. tostring(className)
    if not skillBusy then skillButton.Text = Config.Classes[className].SkillName .. "\nQ" end
end)

Notify.OnClientEvent:Connect(function(message)
    notice.Text = tostring(message)
    notice.Visible = true
    task.delay(2.5, function()
        if notice.Parent then notice.Visible = false end
    end)
end)

DungeonUpdate.OnClientEvent:Connect(function(data)
    if type(data) ~= "table" then return end
    if data.Mode == "Show" then
        dungeonPanel.Visible = true
        bossPanel.Visible = false
        dungeonTitle.Text = "ECLIPSE DUNGEON"
    elseif data.Mode == "Progress" then
        dungeonPanel.Visible = true
        dungeonTitle.Text = data.Boss and "BOSS ENCOUNTER" or "ECLIPSE DUNGEON"
        dungeonInfo.Text = string.format("STAGE %d / %d   •   WAVE %d / %d", data.Stage, data.StageCount, data.Wave, data.WaveCount)
        if data.Boss then
            bossPanel.Visible = true
            bossName.Text = "ECLIPSE OVERLORD — DEFEAT THE BOSS"
            bossFill.Size = UDim2.fromScale(1, 1)
        else
            bossPanel.Visible = false
        end
    elseif data.Mode == "Complete" then
        dungeonPanel.Visible = true
        dungeonTitle.Text = "DUNGEON CLEARED!"
        dungeonInfo.Text = "+" .. tostring(data.XP) .. " XP   •   +" .. tostring(data.Gold) .. " GOLD"
        bossPanel.Visible = false
    elseif data.Mode == "Hidden" then
        dungeonPanel.Visible = false
        bossPanel.Visible = false
    elseif data.Mode == "BossHealth" then
        bossPanel.Visible = true
        bossFill.Size = UDim2.fromScale(math.clamp(data.Ratio or 0, 0, 1), 1)
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F then
        Attack:FireServer()
    elseif input.KeyCode == Enum.KeyCode.Q then
        activateSkill()
    end
end)


local inventoryButton = rounded(make("TextButton", {
    Name="InventoryButton",Size=UDim2.fromOffset(112,42),Position=UDim2.new(0,16,1,-62),
    BackgroundColor3=Color3.fromRGB(30,80,125),Text="INVENTORY",TextColor3=Color3.new(1,1,1),
    TextSize=13,Font=Enum.Font.GothamBlack,
},gui),9)

local inventoryPanel = rounded(make("Frame", {
    Name="InventoryPanel",Size=UDim2.new(0,350,0,390),Position=UDim2.new(0.5,-175,0.5,-195),
    BackgroundColor3=Color3.fromRGB(10,14,28),BorderSizePixel=0,Visible=false,
},gui),14)
make("UIStroke",{Color=Color3.fromRGB(55,160,230),Thickness=2},inventoryPanel)
make("TextLabel",{
    Size=UDim2.new(1,-60,0,38),Position=UDim2.fromOffset(12,6),BackgroundTransparency=1,
    Text="HUNTER INVENTORY",TextColor3=Color3.fromRGB(105,205,255),TextSize=18,
    Font=Enum.Font.GothamBlack,TextXAlignment=Enum.TextXAlignment.Left,
},inventoryPanel)
local closeInventory=make("TextButton",{
    Size=UDim2.fromOffset(34,32),Position=UDim2.new(1,-44,0,8),BackgroundColor3=Color3.fromRGB(120,40,55),
    Text="X",TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBlack,
},inventoryPanel)
rounded(closeInventory,7)
local equippedText=make("TextLabel",{
    Size=UDim2.new(1,-20,0,36),Position=UDim2.fromOffset(10,48),BackgroundColor3=Color3.fromRGB(20,28,45),
    Text="Equipped items loading...",TextColor3=Color3.new(1,1,1),TextSize=11,Font=Enum.Font.GothamBold,
    TextWrapped=true,
},inventoryPanel)
rounded(equippedText,7)
local inventoryList=make("ScrollingFrame",{
    Size=UDim2.new(1,-18,1,-96),Position=UDim2.fromOffset(9,91),BackgroundTransparency=1,
    BorderSizePixel=0,ScrollBarThickness=5,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),
},inventoryPanel)
make("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},inventoryList)

local function renderInventory(data)
    for _,child in ipairs(inventoryList:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then child:Destroy() end
    end
    local function itemName(id)
        for _,item in ipairs(data.Items or {}) do if item.Id==id then return item.Name end end
        return id or "None"
    end
    equippedText.Text="WEAPON: "..itemName(data.Equipped and data.Equipped.Weapon).."   |   ARMOR: "..itemName(data.Equipped and data.Equipped.Armor)
    for index,item in ipairs(data.Items or {}) do
        local row=rounded(make("Frame",{
            Size=UDim2.new(1,-4,0,72),BackgroundColor3=Color3.fromRGB(22,29,48),
            BorderSizePixel=0,LayoutOrder=index,
        },inventoryList),7)
        local rarity=({Common=Color3.fromRGB(200,205,215),Rare=Color3.fromRGB(65,175,255),Epic=Color3.fromRGB(190,100,255)})[item.Rarity] or Color3.new(1,1,1)
        make("TextLabel",{
            Size=UDim2.new(1,-126,0,24),Position=UDim2.fromOffset(8,4),BackgroundTransparency=1,
            Text=item.Name.." ["..item.Rarity.."]",TextColor3=rarity,TextSize=12,Font=Enum.Font.GothamBlack,
            TextXAlignment=Enum.TextXAlignment.Left,
        },row)
        make("TextLabel",{
            Size=UDim2.new(1,-126,0,36),Position=UDim2.fromOffset(8,29),BackgroundTransparency=1,
            Text=item.Slot.."  ATK +"..item.Attack.."  DEF +"..item.Defense.."  Lv."..item.Level,
            TextColor3=Color3.fromRGB(190,200,220),TextSize=10,Font=Enum.Font.GothamMedium,
            TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,
        },row)
        local isEquipped=data.Equipped and data.Equipped[item.Slot]==item.Id
        local equip=make("TextButton",{
            Size=UDim2.fromOffset(106,27),Position=UDim2.new(1,-113,0,6),
            BackgroundColor3=isEquipped and Color3.fromRGB(55,115,75) or Color3.fromRGB(35,115,185),
            Text=isEquipped and "EQUIPPED" or "EQUIP",TextColor3=Color3.new(1,1,1),
            TextSize=10,Font=Enum.Font.GothamBlack,
        },row)
        rounded(equip,6)
        equip.Activated:Connect(function()
            if not isEquipped then InventoryAction:FireServer("Equip",item.Id) end
        end)
        local sell=make("TextButton",{
            Size=UDim2.fromOffset(106,27),Position=UDim2.new(1,-113,0,39),
            BackgroundColor3=Color3.fromRGB(125,75,35),Text="SELL +"..item.SellValue,
            TextColor3=Color3.new(1,1,1),TextSize=10,Font=Enum.Font.GothamBlack,
        },row)
        rounded(sell,6)
        sell.Activated:Connect(function() InventoryAction:FireServer("Sell",item.Id) end)
    end
    if #(data.Items or {})==0 then
        make("TextLabel",{
            Size=UDim2.new(1,-10,0,55),BackgroundTransparency=1,
            Text="No equipment yet. Explore dungeons to find loot.",
            TextColor3=Color3.fromRGB(190,200,220),TextWrapped=true,TextSize=13,
        },inventoryList)
    end
end

inventoryButton.Activated:Connect(function()
    inventoryPanel.Visible=not inventoryPanel.Visible
    if inventoryPanel.Visible then InventoryAction:FireServer("Request") end
end)
closeInventory.Activated:Connect(function() inventoryPanel.Visible=false end)
InventoryUpdate.OnClientEvent:Connect(renderInventory)

local initialClass = player:GetAttribute("EclipseClass") or "Swordsman"
skillButton.Text = Config.Classes[initialClass].SkillName .. "\nQ"
