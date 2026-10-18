--Lib
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()

--Services
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local RunService = game:GetService("RunService")
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

local function refreshTeamESP()

    for _, hl in pairs(activeTeamHighlights) do
        if hl then
            hl:Destroy()
        end
    end
    table.clear(activeTeamHighlights)

    if not teamESPEnabled then
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Player
            and player.Team
            and table.find(selectedTeamInstances, player.Team)
            and player.Character then

            local character = player.Character
            local lightbox = Instance.new("Highlight")

            lightbox.OutlineColor = player.TeamColor.Color
            lightbox.FillColor = player.TeamColor.Color
            lightbox.FillTransparency = 0.6
            lightbox.Parent = character

            activeTeamHighlights[player] = lightbox
        end
    end
end

local function clearPlayerHighlights()
    for player, highlight in pairs(activePlayerHighlights) do
        if highlight then
            highlight:Destroy()
        end

        activePlayerHighlights[player] = nil
    end
end

function refreshPlayerESP()
    clearPlayerHighlights()

    if not playerESPEnabled then
        return
    end

    for _, target in ipairs(selectedPlayerInstances) do
        if target ~= Player and target.Character then
            local highlight = Instance.new("Highlight")

            highlight.Name = "TargetESP"
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.FillTransparency = 0.6
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.Adornee = target.Character
            highlight.Parent = target.Character

            activePlayerHighlights[target] = highlight
        end
    end
end

--Vars

local selectedTeamInstances = {}
local activeTeamHighlights = {}
local selectedPlayerInstances = {}
local activePlayerHighlights = {}
local teamESPEnabled = false
local playerESPEnabled = false
local Player = Players.LocalPlayer
local Clip = true
local NoclipParts = {}
local Noclipping

--------
--Main--
--------

local window = Rayfield:CreateWindow({
    name = "Platinum",
    subtitle = "By PluvWaffen.cc",
    sidebarLayout = true,
    theme = "cobalt",
})

local systemtab = window:CreateTab({ name = "System", icon = 93364949241311 })
local playertab = window:CreateTab({ name = "Player", icon = 93364949241311 })
local visualtab = window:CreateTab({ name = "Visual", icon = 93364949241311 })
local utilitytab = window:CreateTab({ name = "Utilities", icon = 93364949241311 })
local servertab = window:CreateTab({ name = "Server", icon = 93364949241311 })

--System

local console = systemtab:CreateConsole({
    name = "Console",
    text = [[Platinum 1.0.3)]],
    follow = true,
    maxLines = 300,
})

--Player

playertab:CreateDivider({ text = "Player instance Functions" })

playertab:CreateButton({
    name = "Log UserId",
    callback = function()
        window:Notify({ title = "Logged User Id", content = tostring(Player.UserId) })
    end,
})

playertab:CreateDivider({ text = "Character Functions" })

local noclip = playertab:CreateToggle({
    Name = "Noclip",
    Flag = "NoclipToggle",
    CurrentValue = true,

    Callback = function(value)
        Clip = value

        if Noclipping then
            Noclipping:Disconnect()
            Noclipping = nil
        end

        if value then
            NoclipParts = {}

            Noclipping = RunService.Stepped:Connect(function()
                if Player.Character then
                    for _, child in pairs(
                        Player.Character:GetDescendants()
                    ) do
                        if child:IsA("BasePart")
                            and child.Name ~= floatName then

                            if NoclipParts[child] == nil then
                                NoclipParts[child] = child.CanCollide
                            end

                            child.CanCollide = false
                        end
                    end
                end
            end)
        else
            for part, originalState in pairs(NoclipParts) do
                if part and part.Parent then
                    part.CanCollide = originalState
                end
            end

            NoclipParts = {}
        end
    end,
})

noclip:Set(false)

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
    name = "ResetCharacter()",
    callback = function()
        game.Players.LocalPlayer.Character.Head:Destroy()
    end,
})

playertab:CreateButton({
    name = "BreakJoints()",
    callback = function()
        if Player.Character then
            Player.Character:BreakJoints()
        end
    end,
})

playertab:CreateButton({
    name = "Sit()",
    callback = function()
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.Sit = true
        end
    end,
})

playertab:CreateDivider({ text = "Humanoid Functions" })

playertab:CreateInput({
    name = "Walkspeed",
    numeric = true,
    value = "16",
    placeholder = "Enter a number",
    callback = function(text)
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.WalkSpeed = text
        end
    end,
})

playertab:CreateInput({
    name = "Jumppower",
    numeric = true,
    value = "16",
    placeholder = "Enter a number",
    callback = function(text)
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.JumpPower = text
        end
    end,
})

local platformstand = playertab:CreateToggle({
    name = "Platformstand()",
    flag = "Platformstand",
    value = false,
    callback = function(value)
    if value == true then
        Player.Character.Humanoid.PlatformStand = true
    else
        Player.Character.Humanoid.PlatformStand = false
        end
    end,
})

platformstand:Set(false)



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

-- Visual

local function clearPlayerHighlights()
    for player, highlight in pairs(activePlayerHighlights) do
        if highlight then
            highlight:Destroy()
        end
        activePlayerHighlights[player] = nil
    end
end

local function refreshPlayerESP()
    clearPlayerHighlights()

    if not playerESPEnabled then
        return
    end

    for _, target in ipairs(selectedPlayerInstances) do
        if target ~= Player and target.Character then
            local highlight = Instance.new("Highlight")
            highlight.Name = "TargetESP"
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.FillTransparency = 0.6
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.Adornee = target.Character
            highlight.Parent = target.Character

            activePlayerHighlights[target] = highlight
        end
    end
end

local PlayerDropdown = visualtab:CreateDropdown({
    Name = "Players",
    Options = getPlayerNames(),
    CurrentOption = {},
    MultipleOptions = true,

    Callback = function(selected)
        table.clear(selectedPlayerInstances)

        if typeof(selected) == "table" then
            for _, playerName in ipairs(selected) do
                local target = Players:FindFirstChild(playerName)

                if target then
                    table.insert(selectedPlayerInstances, target)
                end
            end
        elseif typeof(selected) == "string" then
            local target = Players:FindFirstChild(selected)

            if target then
                table.insert(selectedPlayerInstances, target)
            end
        end

        console:Append("Selected players:", #selectedPlayerInstances)

        if playerESPEnabled then
            refreshPlayerESP()
        end
    end,
})

local TeamDropdown = visualtab:CreateDropdown({
    Name = "Teams",
    MultiSelect = true,
    Options = getTeamNames(),
    CurrentOption = {},

    Callback = function(selected)
        table.clear(selectedTeamInstances)

        if typeof(selected) == "table" then
            for _, teamName in ipairs(selected) do
                local teamInstance = Teams:FindFirstChild(teamName)

                if teamInstance then
                    table.insert(selectedTeamInstances, teamInstance)
                end
            end
        elseif typeof(selected) == "string" then
            local teamInstance = Teams:FindFirstChild(selected)

            if teamInstance then
                table.insert(selectedTeamInstances, teamInstance)
            end
        end

        console:Append("Selected teams:", #selectedTeamInstances)

        if teamESPEnabled then
            refreshTeamESP()
        end
    end,
})

local tesptoggle = visualtab:CreateToggle({
    Name = "Target ESP",
    Flag = "TargetEsp",
    CurrentValue = false,

    Callback = function(value)
        playerESPEnabled = value

        if playerESPEnabled then
            if #selectedPlayerInstances == 0 then
                warn("Select at least one player first!")
                playerESPEnabled = false
                clearPlayerHighlights()
                return
            end

            refreshPlayerESP()
            console:Append("Target ESP activated.")
        else
            clearPlayerHighlights()
            console:Append("Target ESP deactivated.")
        end
    end,
})

local function highlighteligable(player, character)
    if player == Player then
        return
    end

    if not teamESPEnabled then
        return
    end

    if not player.Team
        or not table.find(selectedTeamInstances, player.Team) then

        if activeTeamHighlights[player] then
            activeTeamHighlights[player]:Destroy()
            activeTeamHighlights[player] = nil
        end

        return
    end

    if activeTeamHighlights[player] then
        activeTeamHighlights[player]:Destroy()
        activeTeamHighlights[player] = nil
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "TeamESP"
    highlight.OutlineColor = player.TeamColor.Color
    highlight.FillColor = player.TeamColor.Color --dont use teamcolor only reminder nigga granny
    highlight.FillTransparency = 0.6
    highlight.Adornee = character
    highlight.Parent = character 

    activeTeamHighlights[player] = highlight
end

function refreshTeamESP()
    for player, highlight in pairs(activeTeamHighlights) do
        if highlight then
            highlight:Destroy()
        end
        activeTeamHighlights[player] = nil
    end

    if not teamESPEnabled then
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            highlighteligable(player, player.Character)
        end
    end
end

local tteamesptoggle = visualtab:CreateToggle({
    Name = "Team ESP",
    Flag = "TeamEsp",
    CurrentValue = false,

    Callback = function(value)
        teamESPEnabled = value
        refreshTeamESP()

        if teamESPEnabled then
            console:Append("Team ESP activated.")
        else
            console:Append("Team ESP deactivated.")
        end
    end,
})

local function updateTeamDropdown()
    TeamDropdown:Refresh(getTeamNames(), true)
end

Teams.ChildAdded:Connect(updateTeamDropdown)
Teams.ChildRemoved:Connect(updateTeamDropdown)

local function monitorPlayer(player)
    player.CharacterAdded:Connect(function(character)
        task.defer(function()
            if playerESPEnabled
                and table.find(selectedPlayerInstances, player) then

                if activePlayerHighlights[player] then
                    activePlayerHighlights[player]:Destroy()
                    activePlayerHighlights[player] = nil
                end

                local highlight = Instance.new("Highlight")
                highlight.Name = "TargetESP"
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.FillTransparency = 0.6
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.Adornee = character
                highlight.Parent = character

                activePlayerHighlights[player] = highlight
            end

            highlighteligable(player, character)
        end)
    end)

    player:GetPropertyChangedSignal("Team"):Connect(function()
        if player.Character then
            highlighteligable(player, player.Character)
        end
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    monitorPlayer(player)
end

Players.PlayerAdded:Connect(function(player)
    monitorPlayer(player)
    PlayerDropdown:Refresh(getPlayerNames(), true)
end)

Players.PlayerRemoving:Connect(function(player)
    if activePlayerHighlights[player] then
        activePlayerHighlights[player]:Destroy()
        activePlayerHighlights[player] = nil
    end

    if activeTeamHighlights[player] then
        activeTeamHighlights[player]:Destroy()
        activeTeamHighlights[player] = nil
    end

    for i = #selectedPlayerInstances, 1, -1 do
        if selectedPlayerInstances[i] == player then
            table.remove(selectedPlayerInstances, i)
        end
    end

    PlayerDropdown:Refresh(getPlayerNames(), true)
end)

--Server

servertab:CreateButton({
    name = "SaveInstance()",
    callback = function()
        if saveinstance then
		window:Notify({ title = "Saving game", content = "Please wait.." })
		saveinstance()
		window:Notify({ title = "Done!", content = "Game finished downloading." })
	else
		window:Notify({ title = "Failure", content = "Your executor doesnt support this." })
	end
    end,
})
