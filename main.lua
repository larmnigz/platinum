--// Lib
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()

--// Window
local window = Rayfield:CreateWindow({
    name = "Platinum",
    subtitle = "By PluvWaffen.cc",
    sidebarLayout = true,
    theme = "default",
})

--// Services
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

--// Variables
local Player = Players.LocalPlayer

local selectedTeamInstances = {}
local activeTeamHighlights = {}

local selectedPlayerInstances = {}
local activePlayerHighlights = {}

local teamESPEnabled = false
local playerESPEnabled = false

local Clip = true
local NoclipParts = {}
local Noclipping

local selectcolor = {
    color = Color3.fromRGB(96, 205, 255),
    alpha = 0.4,
}

local selectoutlinecolor = {
    color = Color3.fromRGB(255, 255, 255),
    alpha = 1,
}

--// Functions

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

    return names
end

local function clearPlayerHighlights()
    for player, highlight in pairs(activePlayerHighlights) do
        if highlight then
            highlight:Destroy()
        end

        activePlayerHighlights[player] = nil
    end
end

local function createPlayerHighlight(player, character)
    if not player
        or player == Player
        or not character then
        return
    end

    if activePlayerHighlights[player] then
        activePlayerHighlights[player]:Destroy()
        activePlayerHighlights[player] = nil
    end

    local highlight = Instance.new("Highlight")

    highlight.Name = "TargetESP"

    highlight.FillColor = selectcolor.color
    highlight.FillTransparency = selectcolor.alpha

    highlight.OutlineColor = selectoutlinecolor.color
    highlight.OutlineTransparency = selectoutlinecolor.alpha

    highlight.Adornee = character
    highlight.Parent = character

    activePlayerHighlights[player] = highlight
end

local function refreshPlayerESP()
    clearPlayerHighlights()

    if not playerESPEnabled then
        return
    end

    for _, target in ipairs(selectedPlayerInstances) do
        if target ~= Player and target.Character then
            createPlayerHighlight(target, target.Character)
        end
    end
end

local function clearTeamHighlights()
    for player, highlight in pairs(activeTeamHighlights) do
        if highlight then
            highlight:Destroy()
        end

        activeTeamHighlights[player] = nil
    end
end

local function highlightEligible(player, character)
    if not player
        or player == Player
        or not character then
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
    highlight.FillColor = player.TeamColor.Color

    highlight.FillTransparency = 0.6
    highlight.OutlineTransparency = 0

    highlight.Adornee = character
    highlight.Parent = character

    activeTeamHighlights[player] = highlight
end

local function refreshTeamESP()
    clearTeamHighlights()

    if not teamESPEnabled then
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Player and player.Character then
            highlightEligible(player, player.Character)
        end
    end
end

local function monitorPlayer(player)
    player.CharacterAdded:Connect(function(character)
        task.defer(function()

            if playerESPEnabled
                and table.find(selectedPlayerInstances, player) then

                createPlayerHighlight(player, character)
            end

            if teamESPEnabled then
                highlightEligible(player, character)
            end
        end)
    end)

    player:GetPropertyChangedSignal("Team"):Connect(function()
        if player.Character and teamESPEnabled then
            highlightEligible(player, player.Character)
        end
    end)
end

--// TABS

local systemtab = window:CreateTab({
    name = "System",
    icon = 93364949241311
})

local playertab = window:CreateTab({
    name = "Player",
    icon = 93364949241311
})

local visualtab = window:CreateTab({
    name = "Visual",
    icon = 93364949241311
})

local utilitytab = window:CreateTab({
    name = "Utilities",
    icon = 93364949241311
})

local servertab = window:CreateTab({
    name = "Server",
    icon = 93364949241311
})

--// SYSTEM

local console = systemtab:CreateConsole({
    name = "Console",
    text = [[Platinum Console 1.0.0]],
    follow = true,
    maxLines = 300,
})

systemtab:CreateButton({
    name = "Leave game",
    callback = function()
        game:Shutdown()
    end,
})

systemtab:CreateButton({
    name = "Disconnect",
    callback = function()
        Players.LocalPlayer:Destroy()
    end,
})

--// PLAYER

playertab:CreateDivider({
    text = "Player instance Functions"
})

playertab:CreateButton({
    name = "Log UserId",
    callback = function()
        window:Notify({
            title = "Logged User Id",
            content = tostring(Player.UserId)
        })
    end,
})

playertab:CreateDivider({
    text = "Character Functions"
})

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
                    for _, child in pairs(Player.Character:GetDescendants()) do

                        if child:IsA("BasePart")
                            and child.Name ~= "floatName" then

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
    range = {70, 120},
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
        if Player.Character
            and Player.Character:FindFirstChild("Head") then

            Player.Character.Head:Destroy()
        end
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
        if Player.Character
            and Player.Character:FindFirstChild("Humanoid") then

            Player.Character.Humanoid.Sit = true
        end
    end,
})

playertab:CreateDivider({
    text = "Humanoid Functions"
})

playertab:CreateInput({
    name = "Walkspeed",
    numeric = true,
    value = "16",
    placeholder = "Enter a number",

    callback = function(text)
        if Player.Character
            and Player.Character:FindFirstChild("Humanoid") then

            Player.Character.Humanoid.WalkSpeed = tonumber(text) or 16
        end
    end,
})

playertab:CreateInput({
    name = "Jumppower",
    numeric = true,
    value = "16",
    placeholder = "Enter a number",

    callback = function(text)
        if Player.Character
            and Player.Character:FindFirstChild("Humanoid") then

            Player.Character.Humanoid.JumpPower = tonumber(text) or 16
        end
    end,
})

local platformstand = playertab:CreateToggle({
    name = "Platformstand()",
    flag = "Platformstand",
    value = false,

    callback = function(value)
        if Player.Character
            and Player.Character:FindFirstChild("Humanoid") then

            Player.Character.Humanoid.PlatformStand = value
        end
    end,
})

platformstand:Set(false)

--// UTILITIES

utilitytab:CreateButton({
    name = "Dex Explorer",

    callback = function()
        loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"
        ))()
    end,
})

utilitytab:CreateButton({
    name = "RemoteSpy",

    callback = function()
        loadstring(game:HttpGet(
            "https://gitlab.com/upio/cobalt/-/releases/permalink/latest/downloads/Cobalt.luau"
        ))()
    end,
})

--// VISUAL

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

        console:Append(
            "Selected players: " .. tostring(#selectedPlayerInstances)
        )

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

        console:Append(
            "Selected teams: " .. tostring(#selectedTeamInstances)
        )

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

visualtab:CreateColorPicker({
    name = "Target ESP Fill color",

    color = Color3.fromRGB(96, 205, 255),

    callback = function(color, alpha)

        local transparency = 1 - alpha

        selectcolor = {
            color = color,
            alpha = transparency
        }

        if playerESPEnabled then
            for _, highlight in pairs(activePlayerHighlights) do

                if highlight
                    and highlight.Parent
                    and highlight:IsA("Highlight") then

                    highlight.FillColor = color
                    highlight.FillTransparency = transparency
                end
            end
        end
    end,
})

visualtab:CreateColorPicker({
    name = "Target ESP Outline color",

    color = Color3.fromRGB(255, 255, 255),

    callback = function(color, alpha)

        local transparency = 1 - alpha

        selectoutlinecolor = {
            color = color,
            alpha = transparency
        }

        if playerESPEnabled then
            for _, highlight in pairs(activePlayerHighlights) do

                if highlight
                    and highlight.Parent
                    and highlight:IsA("Highlight") then

                    highlight.OutlineColor = color
                    highlight.OutlineTransparency = transparency
                end
            end
        end
    end,
})

--// PLAYER CONNECTIONS

for _, player in ipairs(Players:GetPlayers()) do
    monitorPlayer(player)
end

Players.PlayerAdded:Connect(function(player)

    monitorPlayer(player)

    PlayerDropdown:Refresh(
        getPlayerNames(),
        true
    )
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

    PlayerDropdown:Refresh(
        getPlayerNames(),
        true
    )
end)

--// SERVER

servertab:CreateButton({
    name = "SaveInstance()",

    callback = function()

        if saveinstance then

            window:Notify({
                title = "Saving game",
                content = "Please wait.."
            })

            saveinstance()

            window:Notify({
                title = "Done!",
                content = "Game finished downloading."
            })

        else

            window:Notify({
                title = "Failure",
                content = "Your executor doesnt support this."
            })
        end
    end,
})

console:Append("loaded all elements")
