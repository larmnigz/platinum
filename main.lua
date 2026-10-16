local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()

--Services
local Players = game:GetService("Players")

--Vars

local Player = Players.LocalPlayer
local Workspace = game.Workspace

local window = Rayfield:CreateWindow({
    name = "Platinum",
    subtitle = "By PluvWaffen.cc",
    sidebarLayout = true,
})

local hometab = window:CreateTab({ name = "Home", icon = 93364949241311 })
local playertab = window:CreateTab({ name = "Player", icon = 93364949241311 })
local visualtab = window:CreateTab({ name = "Visual", icon = 93364949241311 })
local utilitytab = window:CreateTab({ name = "Utilities", icon = 93364949241311 })

--Player
playertab:CreateSlider({
    name = "Walkspeed",
    range = { 0, 1000 },
    increment = 1,
    value = 16,
    suffix = "°",
    callback = function(value)
        Player.Character.Humanoid.WalkSpeed = value
    end,
})

playertab:CreateSlider({
    name = "Jumppower",
    range = { 0, 1000 },
    increment = 1,
    value = 16,
    suffix = "°",
    callback = function(value)
        Player.Character.Humanoid.JumpPower = value
    end,
})

playertab:CreateSlider({
    name = "Field of view",
    range = { 70, 120 },
    increment = 1,
    value = 90,
    suffix = "°",
    callback = function(value)
        workspace.CurrentCamera.FieldOfView = value
    end,
})

playertab:CreateButton({
    name = "Break Joints",
    callback = function()
        game.Players.LocalPlayer.Character:BreakJoints()
    end,
})

playertab:CreateButton({
    name = "Sit",
    callback = function()
        game.Players.LocalPlayer.Character.Humanoid.Sit = true
    end,
})

--Utilities

utilitytab:CreateButton({
    name = "Dex Explorer",
    callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
    end,
})

utilitytab:CreateButton({
    name = "RemoteSpy",
    callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua"))()
    end,
})
