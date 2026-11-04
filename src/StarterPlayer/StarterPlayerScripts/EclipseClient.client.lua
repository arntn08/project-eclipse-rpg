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

local panel = make("Frame", {
    Name = "TopPanel",
    Size = UDim2.new(0, 330, 0, 100),
    Position = UDim2.new(0, 16, 0, 16),
    BackgroundColor3 = Color3.fromRGB(12, 16, 30),
    BackgroundTransparency = 0.12,
    BorderSizePixel = 0,
}, gui)
make("UICorner", {CornerRadius = UDim.new(0, 12)}, panel)
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

local classPanel = make("Frame", {
    Size = UDim2.new(0, 230, 0, 164),
    Position = UDim2.new(0, 16, 0, 128),
    BackgroundColor3 = Color3.fromRGB(12, 16, 30),
    BackgroundTransparency = 0.12,
    BorderSizePixel = 0,
}, gui)
make("UICorner", {CornerRadius = UDim.new(0, 12)}, classPanel)
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
    local button = make("TextButton", {
        Name = className,
        Size = UDim2.new(1, -20, 0, 34),
        Position = UDim2.fromOffset(10, 37 + (index - 1) * 39),
        BackgroundColor3 = classConfig.Color,
        Text = className .. "  —  " .. classConfig.Description,
        TextColor3 = Color3.fromRGB(15, 18, 28),
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        TextWrapped = true,
    }, classPanel)
    make("UICorner", {CornerRadius = UDim.new(0, 7)}, button)
    button.Activated:Connect(function()
        SelectClass:FireServer(className)
    end)
end

local attackButton = make("TextButton", {
    Name = "AttackButton",
    Size = UDim2.fromOffset(112, 112),
    Position = UDim2.new(1, -140, 1, -150),
    BackgroundColor3 = Color3.fromRGB(25, 115, 210),
    Text = "ATTACK",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 19,
    Font = Enum.Font.GothamBlack,
}, gui)
make("UICorner", {CornerRadius = UDim.new(1, 0)}, attackButton)
make("UIStroke", {Color = Color3.fromRGB(130, 220, 255), Thickness = 3}, attackButton)
attackButton.Activated:Connect(function()
    Attack:FireServer()
end)

local skillButton = make("TextButton", {
    Name = "SkillButton",
    Size = UDim2.fromOffset(92, 92),
    Position = UDim2.new(1, -250, 1, -126),
    BackgroundColor3 = Color3.fromRGB(125, 55, 205),
    Text = "SKILL\nQ",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 17,
    Font = Enum.Font.GothamBlack,
    TextWrapped = true,
}, gui)
make("UICorner", {CornerRadius = UDim.new(1, 0)}, skillButton)
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
    skillButton.Text = "SKILL\nQ"
    skillBusy = false
end
skillButton.Activated:Connect(activateSkill)

local notice = make("TextLabel", {
    Name = "Notice",
    Size = UDim2.new(0, 360, 0, 42),
    Position = UDim2.new(0.5, -180, 0, 18),
    BackgroundColor3 = Color3.fromRGB(10, 15, 28),
    BackgroundTransparency = 0.15,
    Text = "",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 16,
    Font = Enum.Font.GothamBold,
    Visible = false,
}, gui)
make("UICorner", {CornerRadius = UDim.new(0, 9)}, notice)

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
    local className = player:GetAttribute("EclipseClass")
    classLabel.Text = "CLASS: " .. tostring(className)
    local skill = Config.Classes[className]
    if skill then skillButton.Text = skill.SkillName .. "\nQ" end
end)

Notify.OnClientEvent:Connect(function(message)
    notice.Text = tostring(message)
    notice.Visible = true
    task.delay(2.5, function()
        if notice.Parent then notice.Visible = false end
    end)
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F then
        Attack:FireServer()
    elseif input.KeyCode == Enum.KeyCode.Q then
        activateSkill()
    end
end)

local initialClass = player:GetAttribute("EclipseClass") or "Swordsman"
skillButton.Text = Config.Classes[initialClass].SkillName .. "\nQ"
