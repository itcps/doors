-- DOORS ESP Final Script using Cerberus UI Library
-- Author: itcps
-- Version: 3.0

-- Load Cerberus UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Jxereas/UI-Libraries/main/cerberus.lua"))()
local Window = Library.new("DOORS ESP")

-- Wait for game to load
if game.Players.LocalPlayer and game.Players.LocalPlayer.PlayerGui:FindFirstChild("LoadingUI") and game.Players.LocalPlayer.PlayerGui.LoadingUI.Enabled then
    print("[DOORS ESP] Waiting for game to load...")
    repeat task.wait() until not game.Players.LocalPlayer.PlayerGui:FindFirstChild("LoadingUI") or not game.Players.LocalPlayer.PlayerGui.LoadingUI.Enabled
end

-- Variables
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ESP Tables
local ESPTable = {
    Chest = {},
    Door = {},
    Entity = {},
    SideEntity = {},
    Gold = {},
    Guiding = {},
    DroppedItem = {},
    Item = {},
    Objective = {},
    Player = {},
    HidingSpot = {},
    None = {}
}

-- Entity Information
local EntityTable = {
    ["Names"] = {"BackdoorRush", "BackdoorLookman", "RushMoving", "AmbushMoving", "Eyes", "JeffTheKiller", "Dread", "A60", "A120"},
    ["SideNames"] = {"FigureRig", "GiggleCeiling", "GrumbleRig", "Snare"},
    ["ShortNames"] = {
        ["BackdoorRush"] = "Blitz",
        ["JeffTheKiller"] = "Jeff The Killer",
        ["RushMoving"] = "Rush",
        ["AmbushMoving"] = "Ambush",
        ["A60"] = "A-60",
        ["A120"] = "A-120",
        ["BackdoorLookman"] = "Lookman"
    },
    ["Colors"] = {
        ["BackdoorRush"] = Color3.new(1, 0, 0),
        ["RushMoving"] = Color3.new(1, 0, 0),
        ["AmbushMoving"] = Color3.new(1, 0.5, 0),
        ["Eyes"] = Color3.new(1, 1, 0),
        ["JeffTheKiller"] = Color3.new(0.5, 0, 0.5),
        ["A60"] = Color3.new(1, 0, 1),
        ["A120"] = Color3.new(0.5, 0, 1),
        ["BackdoorLookman"] = Color3.new(0, 1, 1)
    }
}

-- Settings
local Settings = {
    ESPEnabled = false,
    EntityESP = false,
    ItemESP = false,
    DoorESP = false,
    ChestESP = false,
    HidingSpotESP = false,
    GoldESP = false,
    PlayerESP = false,
    ESPColor = Color3.new(1, 1, 1),
    ESPThickness = 2,
    ESPDistance = 500,
    ShowNames = true,
    ShowDistance = true,
    ShowHealth = false
}

-- Utility Functions
local function GetShortName(name)
    return EntityTable.ShortNames[name] or name
end

local function GetEntityColor(name)
    return EntityTable.Colors[name] or Color3.new(1, 1, 1)
end

local function DistanceFromCharacter(object)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return math.huge end
    
    local rootPart = character.HumanoidRootPart
    local objectPosition = object:IsA("BasePart") and object.Position or object:GetPivot().Position
    
    return (rootPart.Position - objectPosition).Magnitude
end

local function IsInViewOfPlayer(object, maxDistance)
    if not Camera then return false end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return false end
    
    local rootPart = character.HumanoidRootPart
    local objectPosition = object:IsA("BasePart") and object.Position or object:GetPivot().Position
    
    local distance = (rootPart.Position - objectPosition).Magnitude
    if distance > maxDistance then return false end
    
    local direction = (objectPosition - rootPart.Position).Unit
    local dot = Camera.CFrame.LookVector:Dot(direction)
    
    return dot > 0.5
end

local function CreateESP(object, espType, color, text)
    if not object then return end
    
    local esp = Drawing.new("Box")
    esp.Visible = false
    esp.Color = color or Color3.new(1, 1, 1)
    esp.Thickness = Settings.ESPThickness
    esp.Transparency = 1
    esp.Filled = false
    
    local nameTag = Drawing.new("Text")
    nameTag.Visible = false
    nameTag.Color = color or Color3.new(1, 1, 1)
    nameTag.Size = 20
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.OutlineColor = Color3.new(0, 0, 0)
    nameTag.Text = text or object.Name
    
    table.insert(ESPTable[espType], esp)
    table.insert(ESPTable[espType], nameTag)
    
    return esp, nameTag
end

local function RemoveESP(espType)
    for _, esp in pairs(ESPTable[espType]) do
        if esp and esp.Remove then
            esp:Remove()
        end
    end
    ESPTable[espType] = {}
end

local function UpdateESP()
    for espType, espList in pairs(ESPTable) do
        for i = 1, #espList, 2 do
            local esp = espList[i]
            local nameTag = espList[i + 1]
            
            if esp and nameTag then
                esp.Visible = false
                nameTag.Visible = false
            end
        end
    end
end

-- ESP Functions
local function EntityESP(entity)
    if not entity or not entity:FindFirstChild("PrimaryPart") then return end
    
    local shortName = GetShortName(entity.Name)
    local color = GetEntityColor(entity.Name)
    local distance = DistanceFromCharacter(entity)
    
    local displayText = shortName
    if Settings.ShowDistance then
        displayText = displayText .. " [" .. math.floor(distance) .. "m]"
    end
    
    local esp, nameTag = CreateESP(entity, "Entity", color, displayText)
    
    if esp and nameTag then
        esp.Visible = true
        nameTag.Visible = true
        
        local success, position = pcall(function()
            return Camera:WorldToViewportPoint(entity:GetPivot().Position)
        end)
        
        if success and position.Z > 0 then
            local size = entity.PrimaryPart.Size
            local topLeft = Camera:WorldToViewportPoint((entity:GetPivot() * CFrame.new(-size.X/2, size.Y/2, -size.Z/2)).Position)
            local bottomRight = Camera:WorldToViewportPoint((entity:GetPivot() * CFrame.new(size.X/2, -size.Y/2, size.Z/2)).Position)
            
            esp.Size = Vector2.new(bottomRight.X - topLeft.X, bottomRight.Y - topLeft.Y)
            esp.Position = Vector2.new(topLeft.X, topLeft.Y)
            nameTag.Position = Vector2.new(topLeft.X + (bottomRight.X - topLeft.X) / 2, topLeft.Y - 25)
        end
    end
end

local function ItemESP(item)
    if not item or not item:IsA("BasePart") then return end
    
    local color = Color3.new(0, 1, 0)
    local distance = DistanceFromCharacter(item)
    
    local displayText = item.Name
    if Settings.ShowDistance then
        displayText = displayText .. " [" .. math.floor(distance) .. "m]"
    end
    
    local esp, nameTag = CreateESP(item, "Item", color, displayText)
    
    if esp and nameTag then
        esp.Visible = true
        nameTag.Visible = true
        
        local success, position = pcall(function()
            return Camera:WorldToViewportPoint(item.Position)
        end)
        
        if success and position.Z > 0 then
            local size = item.Size
            local topLeft = Camera:WorldToViewportPoint((item.CFrame * CFrame.new(-size.X/2, size.Y/2, -size.Z/2)).Position)
            local bottomRight = Camera:WorldToViewportPoint((item.CFrame * CFrame.new(size.X/2, -size.Y/2, size.Z/2)).Position)
            
            esp.Size = Vector2.new(bottomRight.X - topLeft.X, bottomRight.Y - topLeft.Y)
            esp.Position = Vector2.new(topLeft.X, topLeft.Y)
            nameTag.Position = Vector2.new(topLeft.X + (bottomRight.X - topLeft.X) / 2, topLeft.Y - 25)
        end
    end
end

local function DoorESP(door)
    if not door or not door:IsA("BasePart") then return end
    
    local color = Color3.new(0, 0, 1)
    local distance = DistanceFromCharacter(door)
    
    local displayText = "Door"
    if Settings.ShowDistance then
        displayText = displayText .. " [" .. math.floor(distance) .. "m]"
    end
    
    local esp, nameTag = CreateESP(door, "Door", color, displayText)
    
    if esp and nameTag then
        esp.Visible = true
        nameTag.Visible = true
        
        local success, position = pcall(function()
            return Camera:WorldToViewportPoint(door.Position)
        end)
        
        if success and position.Z > 0 then
            local size = door.Size
            local topLeft = Camera:WorldToViewportPoint((door.CFrame * CFrame.new(-size.X/2, size.Y/2, -size.Z/2)).Position)
            local bottomRight = Camera:WorldToViewportPoint((door.CFrame * CFrame.new(size.X/2, -size.Y/2, size.Z/2)).Position)
            
            esp.Size = Vector2.new(bottomRight.X - topLeft.X, bottomRight.Y - topLeft.Y)
            esp.Position = Vector2.new(topLeft.X, topLeft.Y)
            nameTag.Position = Vector2.new(topLeft.X + (bottomRight.X - topLeft.X) / 2, topLeft.Y - 25)
        end
    end
end

local function ChestESP(chest)
    if not chest or not chest:IsA("BasePart") then return end
    
    local color = Color3.new(1, 1, 0)
    local distance = DistanceFromCharacter(chest)
    
    local displayText = "Chest"
    if Settings.ShowDistance then
        displayText = displayText .. " [" .. math.floor(distance) .. "m]"
    end
    
    local esp, nameTag = CreateESP(chest, "Chest", color, displayText)
    
    if esp and nameTag then
        esp.Visible = true
        nameTag.Visible = true
        
        local success, position = pcall(function()
            return Camera:WorldToViewportPoint(chest.Position)
        end)
        
        if success and position.Z > 0 then
            local size = chest.Size
            local topLeft = Camera:WorldToViewportPoint((chest.CFrame * CFrame.new(-size.X/2, size.Y/2, -size.Z/2)).Position)
            local bottomRight = Camera:WorldToViewportPoint((chest.CFrame * CFrame.new(size.X/2, -size.Y/2, size.Z/2)).Position)
            
            esp.Size = Vector2.new(bottomRight.X - topLeft.X, bottomRight.Y - topLeft.Y)
            esp.Position = Vector2.new(topLeft.X, topLeft.Y)
            nameTag.Position = Vector2.new(topLeft.X + (bottomRight.X - topLeft.X) / 2, topLeft.Y - 25)
        end
    end
end

-- UI Setup
local MainTab = Window:Tab("Main")
local VisualsTab = Window:Tab("Visuals")
local SettingsTab = Window:Tab("Settings")

-- Main Tab
local MainSection = MainTab:Section("Main Settings")

local ESPEnabled = MainSection:Toggle("Enable ESP", function(enabled)
    Settings.ESPEnabled = enabled
end)

local EntityESPToggle = MainSection:Toggle("Entity ESP", function(enabled)
    Settings.EntityESP = enabled
end)

local ItemESPToggle = MainSection:Toggle("Item ESP", function(enabled)
    Settings.ItemESP = enabled
end)

local DoorESPToggle = MainSection:Toggle("Door ESP", function(enabled)
    Settings.DoorESP = enabled
end)

local ChestESPToggle = MainSection:Toggle("Chest ESP", function(enabled)
    Settings.ChestESP = enabled
end)

local HidingSpotESPToggle = MainSection:Toggle("Hiding Spot ESP", function(enabled)
    Settings.HidingSpotESP = enabled
end)

local GoldESPToggle = MainSection:Toggle("Gold ESP", function(enabled)
    Settings.GoldESP = enabled
end)

-- Visuals Tab
local VisualsSection = VisualsTab:Section("Visuals Settings")

local ESPColor = VisualsSection:ColorWheel("ESP Color", function(color)
    Settings.ESPColor = color
end)

local ESPThickness = VisualsSection:Slider("ESP Thickness", function(value)
    Settings.ESPThickness = value
end, 1, 10)

local ESPDistance = VisualsSection:Slider("ESP Distance", function(value)
    Settings.ESPDistance = value
end, 100, 1000)

-- Settings Tab
local SettingsSection = SettingsTab:Section("Display Settings")

local ShowNamesToggle = SettingsSection:Toggle("Show Names", function(enabled)
    Settings.ShowNames = enabled
end)

local ShowDistanceToggle = SettingsSection:Toggle("Show Distance", function(enabled)
    Settings.ShowDistance = enabled
end)

-- Main Loop
RunService.RenderStepped:Connect(function()
    if not Settings.ESPEnabled then
        UpdateESP()
        return
    end
    
    -- Clear old ESP
    UpdateESP()
    
    -- Entity ESP
    if Settings.EntityESP then
        for _, entity in pairs(Workspace:GetChildren()) do
            if entity:IsA("Model") and table.find(EntityTable.Names, entity.Name) then
                local distance = DistanceFromCharacter(entity)
                if distance <= Settings.ESPDistance then
                    EntityESP(entity)
                end
            end
        end
    end
    
    -- Item ESP
    if Settings.ItemESP then
        for _, item in pairs(Workspace:GetChildren()) do
            if item:IsA("BasePart") and (item.Name:match("Item") or item.Name:match("Tool")) then
                local distance = DistanceFromCharacter(item)
                if distance <= Settings.ESPDistance then
                    ItemESP(item)
                end
            end
        end
    end
    
    -- Door ESP
    if Settings.DoorESP then
        for _, door in pairs(Workspace:GetChildren()) do
            if door:IsA("BasePart") and door.Name:match("Door") then
                local distance = DistanceFromCharacter(door)
                if distance <= Settings.ESPDistance then
                    DoorESP(door)
                end
            end
        end
    end
    
    -- Chest ESP
    if Settings.ChestESP then
        for _, chest in pairs(Workspace:GetChildren()) do
            if chest:IsA("BasePart") and (chest.Name:match("Chest") or chest.Name:match("Box")) then
                local distance = DistanceFromCharacter(chest)
                if distance <= Settings.ESPDistance then
                    ChestESP(chest)
                end
            end
        end
    end
    
    -- Hiding Spot ESP
    if Settings.HidingSpotESP then
        for _, spot in pairs(Workspace:GetChildren()) do
            if spot:IsA("BasePart") and (spot.Name:match("Wardrobe") or spot.Name:match("Locker") or spot.Name:match("Closet")) then
                local distance = DistanceFromCharacter(spot)
                if distance <= Settings.ESPDistance then
                    local color = Color3.new(0, 1, 1)
                    local displayText = "Hiding Spot"
                    if Settings.ShowDistance then
                        displayText = displayText .. " [" .. math.floor(distance) .. "m]"
                    end
                    local esp, nameTag = CreateESP(spot, "HidingSpot", color, displayText)
                    if esp and nameTag then
                        esp.Visible = true
                        nameTag.Visible = true
                        
                        local success, position = pcall(function()
                            return Camera:WorldToViewportPoint(spot.Position)
                        end)
                        
                        if success and position.Z > 0 then
                            local size = spot.Size
                            local topLeft = Camera:WorldToViewportPoint((spot.CFrame * CFrame.new(-size.X/2, size.Y/2, -size.Z/2)).Position)
                            local bottomRight = Camera:WorldToViewportPoint((spot.CFrame * CFrame.new(size.X/2, -size.Y/2, size.Z/2)).Position)
                            
                            esp.Size = Vector2.new(bottomRight.X - topLeft.X, bottomRight.Y - topLeft.Y)
                            esp.Position = Vector2.new(topLeft.X, topLeft.Y)
                            nameTag.Position = Vector2.new(topLeft.X + (bottomRight.X - topLeft.X) / 2, topLeft.Y - 25)
                        end
                    end
                end
            end
        end
    end
    
    -- Gold ESP
    if Settings.GoldESP then
        for _, gold in pairs(Workspace:GetChildren()) do
            if gold:IsA("BasePart") and gold.Name:match("Gold") then
                local distance = DistanceFromCharacter(gold)
                if distance <= Settings.ESPDistance then
                    local color = Color3.new(1, 1, 0)
                    local displayText = "Gold"
                    if Settings.ShowDistance then
                        displayText = displayText .. " [" .. math.floor(distance) .. "m]"
                    end
                    local esp, nameTag = CreateESP(gold, "Gold", color, displayText)
                    if esp and nameTag then
                        esp.Visible = true
                        nameTag.Visible = true
                        
                        local success, position = pcall(function()
                            return Camera:WorldToViewportPoint(gold.Position)
                        end)
                        
                        if success and position.Z > 0 then
                            local size = gold.Size
                            local topLeft = Camera:WorldToViewportPoint((gold.CFrame * CFrame.new(-size.X/2, size.Y/2, -size.Z/2)).Position)
                            local bottomRight = Camera:WorldToViewportPoint((gold.CFrame * CFrame.new(size.X/2, -size.Y/2, size.Z/2)).Position)
                            
                            esp.Size = Vector2.new(bottomRight.X - topLeft.X, bottomRight.Y - topLeft.Y)
                            esp.Position = Vector2.new(topLeft.X, topLeft.Y)
                            nameTag.Position = Vector2.new(topLeft.X + (bottomRight.X - topLeft.X) / 2, topLeft.Y - 25)
                        end
                    end
                end
            end
        end
    end
end)

-- Cleanup function
local function Cleanup()
    for espType, espList in pairs(ESPTable) do
        RemoveESP(espType)
    end
    print("[DOORS ESP] Script unloaded!")
end

-- Connect cleanup to script unloading
game:BindToClose(Cleanup)

print("[DOORS ESP Final] Script loaded successfully!") 
