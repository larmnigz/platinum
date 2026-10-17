--Lib
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()

--Services
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local Workspace = game.Workspace

--Funcs

local function getPlayerNames()
    local names = {}
    for _, player in ipairs(Players:GetPlayers()) do
        table.insert(names, player.Name)
    end
    return names
end

local function getTeamNames()
    local names = {}
    for _, team in ipairs(Teams:GetTeams()) do
        table.insert(names, team.Name) 
    end
    return names -- same as above o algo
end

local function highlighteligable(player, character)
    -- 1. Check if the Team ESP toggle flag is actually turned ON in Rayfield
    if Rayfield.Flags["TeamEspToggle"] and Rayfield.Flags["TeamEspToggle"].CurrentValue == true then
        
        -- 2. Check if they are part of the selected teams
        if table.find(selectedTeamInstances, player.Team) then
            -- Clean up old highlights if they exist on this player
            if activeTeamHighlights[player] then 
                activeTeamHighlights[player]:Destroy() 
            end

            -- 3. Create the new highlight for their new character
            local lightbox = Instance.new("Highlight")
            lightbox.OutlineColor = player.TeamColor.Color
            lightbox.FillColor = player.TeamColor.Color
            lightbox.FillTransparency = 0.6
            
            lightbox.Parent = character
            activeTeamHighlights[player] = lightbox
        end
    end
end


--Vars

local selectedTeamInstances = {}
local activeTeamHighlights = {}
local selectedPlayer = nil
local Player = Players.LocalPlayer

--------
--Main--
--------

local window = Rayfield:CreateWindow({
    name = "Platinum",
    subtitle = "By PluvWaffen.cc",
    sidebarLayout = true,
})

local systemtab = window:CreateTab({ name = "System", icon = 93364949241311 })
local playertab = window:CreateTab({ name = "Player", icon = 93364949241311 })
local visualtab = window:CreateTab({ name = "Visual", icon = 93364949241311 })
local utilitytab = window:CreateTab({ name = "Utilities", icon = 93364949241311 })
local servertab = window:CreateTab({ name = "Server", icon = 93364949241311 })

--System

local console = systemtab:CreateConsole({
    name = "Console",
    text = [[print("Hello world")]],
    follow = true,
    maxLines = 300,
})

--Player
playertab:CreateSlider({
    name = "Walkspeed",
    range = { 0, 1000 },
    increment = 1,
    value = 16,
    suffix = "°",
    callback = function(value)
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.WalkSpeed = value
        end
    end,
})

playertab:CreateSlider({
    name = "Jumppower",
    range = { 0, 1000 },
    increment = 1,
    value = 16,
    suffix = "°",
    callback = function(value)
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.JumpPower = value
        end
    end,
})

playertab:CreateSlider({
    name = "Field of view",
    range = { 70, 120 },
    increment = 1,
    value = 90,
    suffix = "°",
    callback = function(value)
        if Workspace.CurrentCamera then
            Workspace.CurrentCamera.FieldOfView = value
        end
    end,
})

playertab:CreateButton({
    name = "Break Joints",
    callback = function()
        if Player.Character then
            Player.Character:BreakJoints()
        end
    end,
})

playertab:CreateButton({
    name = "Sit",
    callback = function()
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.Sit = true
        end
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

--Visual

local PlayerDropdown = visualtab:CreateDropdown({
    Name = "Players",
    Options = getPlayerNames(),
    CurrentOption = {},
    MultipleOptions = false,
    Callback = function(selected)
        local selectedName = typeof(selected) == "table" and selected[1] or selected
        
        selectedPlayerInstance = Players:FindFirstChild(selectedName)
        print("Target locked on object:", selectedPlayerInstance)
    end,
})

local TeamDropdown = visualtab:CreateDropdown({
    Name = "Teams",                
    MultiSelect = true,            
    Options = getTeamNames(),      
    CurrentOption = {},            
    Callback = function(selected)  
        -- Clear our previous object list so we don't hold onto unselected teams
        table.clear(selectedTeamInstances)
        
        -- Loop through the text strings Rayfield gave us
        for _, teamName in ipairs(selected) do
            -- Find the actual Team Object in the Teams service using the string name
            local teamInstance = Teams:FindFirstChild(teamName)
            
            if teamInstance then
                table.insert(selectedTeamInstances, teamInstance)
            end
        end
        
        print("Selected Team Instances:", selectedTeamInstances)
    end,
})

local tesptoggle = visualtab:CreateToggle({
    name = "Target ESP",
    flag = "TargetEsp",
    value = false,
    callback = function(value)
        if value == true then
             local character = selectedPlayerInstance.Character
            if not character then
                print("Error: Target character not found!")
                return
            end

            if Espbox then Espbox:Destroy() end

            Espbox = Instance.new("Highlight")
            Espbox.FillColor = Color3.fromRGB(255, 0, 0)
            Espbox.FillTransparency = 0.6
            Espbox.OutlineColor = Color3.fromRGB(255, 255, 255)
            
            Espbox.Parent = character
            print("esp+")
            
        else
            if Espbox then
                Espbox:Destroy()
                Espbox = nil --memory
                print("killed highlight")
            else
                print("No active highlight found to destroy.")
            end
        end
    end,
})

tesptoggle:Set(false)

local tteamesptoggle = visualtab:CreateToggle({
    Name = "Team ESP",
    Flag = "TeamEsp",
    CurrentValue = false,
    Callback = function(Value)
        if Value == true then
            -- Clear out any lingering old highlights just in case
            for _, hl in pairs(activeTeamHighlights) do
                if hl then hl:Destroy() end
            end
            table.clear(activeTeamHighlights)

            -- Loop through EVERY player in the server
            for _, player in ipairs(Players:GetPlayers()) do
                -- Check if this player belongs to one of our selected team objects
                if table.find(selectedTeamInstances, player.Team) then
                    local character = player.Character
                    
                    -- Make sure their character exists in Workspace before adding the visual
                    if character then
                        local lightbox = Instance.new("Highlight")
                        
                        -- Match the highlight outline color to their actual Team Color!
                        lightbox.OutlineColor = player.TeamColor.Color
                        lightbox.FillColor = player.TeamColor.Color
                        lightbox.FillTransparency = 0.6
                        
                        lightbox.Parent = character
                        
                        -- Save it to our tracking table bound to the player
                        activeTeamHighlights[player] = lightbox
                    end
                end
            end
            print("Team ESP activated.")
            
        else
            -- Turn off: Clean up all team highlights globally
            for player, hl in pairs(activeTeamHighlights) do
                if hl then hl:Destroy() end
            end
            table.clear(activeTeamHighlights)
            print("Team ESP deactivated.")
        end
    end,
})

local function updateTeamDropdown()
    TeamDropdown:Refresh(getTeamNames(), true)
end
Teams.ChildAdded:Connect(updateTeamDropdown)
Teams.ChildRemoved:Connect(updateTeamDropdown)

tteamesptoggle:Set(false)

local function monitorPlayer(player)
    player.CharacterAdded:Connect(function(character)
        task.defer(function()
            highlighteligable(player, character)
        end)
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    monitorPlayer(player)
end
Players.PlayerAdded:Connect(monitorPlayer)

--Server
