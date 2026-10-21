--// Lib
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()

--// Window
local window = Rayfield:CreateWindow({
    name = "Platinum",
    subtitle = "By PluvWaffen.cc",
    sidebarLayout = true,
    theme = "default",
    configuration = {
        autoSave = true,
        autoLoad = false,
        fileName = "Autosave",
        customFolder = "PlatinumConfig",
    },
})

--// Services
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

--// Variables
local Player = Players.LocalPlayer
local mouse = Player:GetMouse()
local Camera = Workspace.CurrentCamera
local AimbotConnection
local RmbLockEnabled = false
local RmbLockConnection = nil
local RmbLockTeamCheck = false
local RmbLockWallCheck = false

local savefilename = "" 
local loadfilename = ""

local selectedTeamInstances = {}
local PlayerAimbotInstances = {}
local activeTeamHighlights = {}
local selectedlimb = "Head"
local rmblockselectedlimb = "Head"

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

systemtab:CreateDivider({ text = "Application" })

local console = systemtab:CreateConsole({
    name = "Console",
    text = [[Platinum Console 1.0.2]],
    follow = true,
    maxLines = 400,
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

systemtab:CreateButton({
    name = "Rejoin",
    callback = function()
            local data = nil
    if parseBoolean(args[1], false) == true then
        if queueteleport then
            if speaker.Character then
                data = speaker.Character:GetPivot()
                queueteleport(teleportRespawnHandler)
            end
        else
            console:Append("missing queue_on_teleport")
        end
    end

    if #Players:GetPlayers() <= 1 then
        Players.LocalPlayer:Kick("\nRejoining...")
        task.wait(0.3)
        TeleportService:Teleport(PlaceId, Players.LocalPlayer, data)
    else
        TeleportService:TeleportToPlaceInstance(PlaceId, JobId, Players.LocalPlayer, nil, data)
    end
    end,
})

systemtab:CreateDivider({ text = "Configuration" })

systemtab:CreateInput({
    name = "Save File",
    numeric = false,
    value = "",
    placeholder = "Enter a file name",
    callback = function(text)
        savefilename = text
    end,
})

systemtab:CreateInput({
    name = "Load File",
    numeric = false,
    value = "",
    placeholder = "Enter a file name",
    callback = function(text)
        loadfilename = text
    end,
})

systemtab:CreateButton({
    name = "Save File",
    callback = function()
        window:Save(savefilename)
        window:Notify({ title = "Saved file", content = "Saved your config in PlatinumConfig." })
        console:Append("Saved file")
    end,
})

systemtab:CreateButton({
    name = "Load File",
    callback = function()
        window:Load(loadfilename)
        window:Notify({ title = "Loaded file", content = "Loaded your config." })
        console:Append("Loaded file")
    end,
})

--// PLAYER

playertab:CreateDivider({
    text = "Player instance Functions" --PIF
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
    text = "Character Functions" --CF
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
    value = "50",
    placeholder = "Enter a number",

    callback = function(text)
        if Player.Character
            and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.JumpPower = tonumber(text) or 16
        end
    end,
})

playertab:CreateButton({
    name = "Animation:Destroy()",
    callback = function()
    if Player.Character.Animate.Parent == Player.Character then
        Player.Character.Animate:Destroy()
        else
        console:Append("No animate script found")
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

playertab:CreateDivider({
    text = "Camera Functions" --CF
})

local PlayerAimbotDropdown = playertab:CreateDropdown({
    Name = "Target Player List",
    Options = getPlayerNames(),
    CurrentOption = {},
    MultipleOptions = false,

    Callback = function(selected)
        table.clear(PlayerAimbotInstances)

        if typeof(selected) == "table" then
            for _, playerName in ipairs(selected) do
                local playerInstance = Players:FindFirstChild(playerName)

                if playerInstance then
                    table.insert(PlayerAimbotInstances, playerInstance)
                end
            end

        elseif typeof(selected) == "string" then
            local playerInstance = Players:FindFirstChild(selected)

            if playerInstance then
                table.insert(PlayerAimbotInstances, playerInstance)
            end
        end

        console:Append(
            "Player List selected: " .. tostring(#PlayerAimbotInstances) .. " player(s)"
        )
    end,
})

local Selectlimbs = playertab:CreateDropdown({
    Name = "Target Player Parts",
    Options = { "Head", "HumanoidRootPart" },
    CurrentOption = { "Head" },
    MultipleOptions = false,

    Callback = function(selected)
        if typeof(selected) == "table" then
            selectedlimb = selected[1]
        elseif typeof(selected) == "string" then
            selectedlimb = selected
        end

        console:Append(
            "Target part: " .. tostring(selectedlimb)
        )
    end,
})

local RmblockSelectlimbs = playertab:CreateDropdown({
    Name = "RmbLock Target Player Parts",
    Options = { "Head", "HumanoidRootPart" },
    CurrentOption = { "Head" },
    MultipleOptions = false,

    Callback = function(selected)
        if typeof(selected) == "table" then
            rmblockselectedlimb = selected[1]
        elseif typeof(selected) == "string" then
            rmblockselectedlimb = selected
        end

        console:Append(
            "Rmblock Target part: " .. tostring(selectedlimb)
        )
    end,
})

local aimbottoggle = playertab:CreateToggle({
    Name = "Target aimbot",
    Flag = "TargetAimbot",
    CurrentValue = false,

    Callback = function(value)
        if AimbotConnection then
            AimbotConnection:Disconnect()
            AimbotConnection = nil
        end

        if not value then
            return
        end

        AimbotConnection = RunService.RenderStepped:Connect(function()
            local targetPlayer = PlayerAimbotInstances[1]

            if not targetPlayer then
                return
            end

            local character = targetPlayer.Character
            if not character then
                return
            end

            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health <= 0 then
                return
            end

            local targetPart = character:FindFirstChild(selectedlimb)

            if not targetPart then
                return
            end

            Workspace.CurrentCamera.CFrame = CFrame.lookAt(
                Workspace.CurrentCamera.CFrame.Position,
                targetPart.Position
            )
        end)
    end,
})

aimbottoggle:Set(false)

local RmbLockTeamCheck = playertab:CreateToggle({
    name = "RmbLock Team Check",
    flag = "RmbLockTeamCheck",
    value = false,

    callback = function(value)
        RmbLockTeamCheck = value
    end,
})

local RmbLockWallCheck = playertab:CreateToggle({
    name = "RmbLock Wall Check",
    flag = "RmbLockWallCheck",
    value = false,

    callback = function(value)
        RmbLockWallCheck = value
    end,
})

local RmbLock = playertab:CreateToggle({
    name = "RmbLock",
    flag = "RmbLockToggle",
    value = false,

    callback = function(value)
        RmbLockEnabled = value

        if RmbLockConnection then
            RmbLockConnection:Disconnect()
            RmbLockConnection = nil
        end

        if not value then
            return
        end

        RmbLockConnection = RunService.RenderStepped:Connect(function()
            if not RmbLockEnabled then
                return
            end

            if not UserInputService:IsMouseButtonPressed(
                Enum.UserInputType.MouseButton2
            ) then
                return
            end

            local mousePosition = UserInputService:GetMouseLocation()

            local closestPart = nil
            local closestDistance = math.huge

            for _, targetPlayer in ipairs(Players:GetPlayers()) do
                if targetPlayer ~= Player and targetPlayer.Character then

                    --// Team Check
                    if RmbLockTeamCheck and targetPlayer.Team == Player.Team then
                        continue
                    end

                    local character = targetPlayer.Character
                    local humanoid = character:FindFirstChildOfClass("Humanoid")

                    --// Selected Target Part
                    local targetPart = character:FindFirstChild(rmblockselectedlimb)

                    if humanoid and humanoid.Health > 0 and targetPart then

                        --// Wall Check
                        if RmbLockWallCheck then
                            local origin = Camera.CFrame.Position
                            local direction = targetPart.Position - origin

                            local rayParams = RaycastParams.new()
                            rayParams.FilterType = Enum.RaycastFilterType.Exclude
                            rayParams.FilterDescendantsInstances = {
                                Player.Character
                            }
                            rayParams.IgnoreWater = true

                            local result = Workspace:Raycast(
                                origin,
                                direction,
                                rayParams
                            )

                            -- Something is blocking the target
                            if result and not result.Instance:IsDescendantOf(character) then
                                continue
                            end
                        end

                        --// Get screen position of selected limb
                        local screenPosition, onScreen =
                            Camera:WorldToViewportPoint(targetPart.Position)

                        if onScreen then
                            local distance = (
                                Vector2.new(
                                    screenPosition.X,
                                    screenPosition.Y
                                ) - mousePosition
                            ).Magnitude

                            if distance < closestDistance then
                                closestDistance = distance
                                closestPart = targetPart
                            end
                        end
                    end
                end
            end

            --// Aim at closest valid target
            if closestPart then
                Camera.CFrame = CFrame.lookAt(
                    Camera.CFrame.Position,
                    closestPart.Position
                )
            end
        end)
    end,
})

RmbLock:Set(false)

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
            "https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua"
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

servertab:CreateDivider({ text = "Game" })

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

servertab:CreateInput({
    name = "Max players",
    numeric = true,
    value = "16",
    placeholder = "Enter a number",
    callback = function(text)
        print("Committed:", text)
    end,
})

servertab:CreateDivider({ text = "Workspace" })

local renderingtoggle = servertab:CreateToggle({
    name = "3D Rendering Toggle",
    flag = "RenderingToggle",
    value = true,
    callback = function(value)
        RunService:Set3dRenderingEnabled(value)
    end,
})

renderingtoggle:Set(true)



console:Append("loaded all elements")

