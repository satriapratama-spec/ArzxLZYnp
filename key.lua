-- ============================================================
-- LZY HUB - FULL GUI, SINGLE-KEY & HWID LOCK SYSTEM (FIXED)
-- ============================================================

local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- CONFIGURATION (GITHUB & WEBHOOK)
local GITHUB_KEY_URL = "https://raw.githubusercontent.com/USERNAME/REPOSITORY/main/keys.txt"
local TARGET_RAW_URL = "https://raw.githubusercontent.com/USERNAME/REPOSITORY/main/main.lua"
local WEBHOOK_URL = "https://discord.com/api/webhooks/1551041219721830441/f3RF5Jt9H-y5ZD63CbTN3tT9JDPEfZrP2s9yO9xE0t0vs4JWaw8oszg8ONE343-HzukF"

-- FUNCTION: Get Player HWID securely
local function getHWID()
    local hwid = ""
    if gethwid then
        hwid = gethwid()
    elseif RbxAuthenticationService and RbxAuthenticationService.GetClientId then
        hwid = RbxAuthenticationService:GetClientId()
    else
        hwid = tostring(LocalPlayer.UserId)
    end
    return string.gsub(hwid, "%s+", "")
end

local PlayerHWID = getHWID()

-- GUI THEME CONFIGURATION
local Theme = {
    panelBg       = Color3.fromRGB(12, 12, 14),
    panelBg2      = Color3.fromRGB(18, 18, 22),
    panelBorder   = Color3.fromRGB(40, 40, 46),
    panelBorderHi = Color3.fromRGB(90, 90, 100),
    text          = Color3.fromRGB(240, 240, 245),
    textDim       = Color3.fromRGB(160, 160, 170),
    accent        = Color3.fromRGB(180, 30, 30),
    success       = Color3.fromRGB(90, 210, 130),
    error         = Color3.fromRGB(240, 90, 90),
}

local function getRootGui()
    if gethui then
        local success, gui = pcall(gethui)
        if success and gui then return gui end
    end
    return CoreGui
end

-- 1. CREATE MAIN SCREEN GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LzyHubSingleKeySystem"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 9999
ScreenGui.Parent = getRootGui()

-- 2. CREATE MAIN FRAME WINDOW (KEY SYSTEM)
local KeyFrame = Instance.new("Frame", ScreenGui)
KeyFrame.Name = "KeyWindow"
KeyFrame.Size = UDim2.fromOffset(400, 240)
KeyFrame.Position = UDim2.new(0.5, -200, 0.5, -120)
KeyFrame.BackgroundColor3 = Theme.panelBg
KeyFrame.BackgroundTransparency = 0.05
KeyFrame.BorderSizePixel = 0
KeyFrame.Active = true
KeyFrame.Draggable = true

Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 12)
local UIStroke = Instance.new("UIStroke", KeyFrame)
UIStroke.Thickness = 1.5
UIStroke.Color = Theme.panelBorderHi

-- Window Header
local Header = Instance.new("TextLabel", KeyFrame)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundTransparency = 1
Header.Font = Enum.Font.GothamBold
Header.TextSize = 16
Header.TextColor3 = Theme.text
Header.Text = "Lzy Hub - Key System"

-- TextBox Input Key
local KeyBox = Instance.new("TextBox", KeyFrame)
KeyBox.Size = UDim2.new(0.85, 0, 0, 40)
KeyBox.Position = UDim2.new(0.075, 0, 0.23, 0)
KeyBox.BackgroundColor3 = Theme.panelBg2
KeyBox.Font = Enum.Font.Gotham
KeyBox.TextSize = 14
KeyBox.TextColor3 = Theme.text
KeyBox.PlaceholderText = "Enter your key here (1 Key = 1 User)..."
KeyBox.Text = ""
KeyBox.ClearTextOnFocus = false
KeyBox.Parent = KeyFrame

Instance.new("UICorner", KeyBox).CornerRadius = UDim.new(0, 6)
local BoxStroke = Instance.new("UIStroke", KeyBox)
BoxStroke.Color = Theme.panelBorder

-- Get Key Button
local GetKeyBtn = Instance.new("TextButton", KeyFrame)
GetKeyBtn.Size = UDim2.new(0.4, 0, 0, 35)
GetKeyBtn.Position = UDim2.new(0.075, 0, 0.56, 0)
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
GetKeyBtn.Font = Enum.Font.GothamSemibold
GetKeyBtn.TextSize = 13
GetKeyBtn.TextColor3 = Theme.text
GetKeyBtn.Text = "Get Key"
GetKeyBtn.Parent = KeyFrame
Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, 6)

-- Verify Button
local VerifyBtn = Instance.new("TextButton", KeyFrame)
VerifyBtn.Size = UDim2.new(0.4, 0, 0, 35)
VerifyBtn.Position = UDim2.new(0.525, 0, 0.56, 0)
VerifyBtn.BackgroundColor3 = Theme.accent
VerifyBtn.Font = Enum.Font.GothamSemibold
VerifyBtn.TextSize = 13
VerifyBtn.TextColor3 = Theme.text
VerifyBtn.Text = "Verify Key"
VerifyBtn.Parent = KeyFrame
Instance.new("UICorner", VerifyBtn).CornerRadius = UDim.new(0, 6)

-- Status Label
local StatusLabel = Instance.new("TextLabel", KeyFrame)
StatusLabel.Size = UDim2.new(1, 0, 0, 25)
StatusLabel.Position = UDim2.new(0, 0, 0.82, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.TextColor3 = Theme.textDim
StatusLabel.Text = "Status: Waiting for input..."
StatusLabel.Parent = KeyFrame

-- Get Key Button Action
GetKeyBtn.MouseButton1Click:Connect(function()
    setclipboard("https://discord.gg/kptjwzKWgX")
    StatusLabel.TextColor3 = Theme.success
    StatusLabel.Text = "Get Key link copied to clipboard!"
end)

-- Verify Button Action
VerifyBtn.MouseButton1Click:Connect(function()
    StatusLabel.TextColor3 = Theme.textDim
    StatusLabel.Text = "Checking key status..."
    
    local inputKey = string.gsub(KeyBox.Text, "%s+", "")
    if inputKey == "" then
        StatusLabel.TextColor3 = Theme.error
        StatusLabel.Text = "Key cannot be empty!"
        return
    end

    -- Fetch valid keys from GitHub repository
    local success, result = pcall(function()
        return game:HttpGet(GITHUB_KEY_URL)
    end)
    
    if success and result then
        local isKeyValid = false
        
        for line in string.gmatch(result, "[^\r\n]+") do
            if inputKey == string.gsub(line, "%s+", "") then
                isKeyValid = true
                break
            end
        end
        
        if not isKeyValid then
            StatusLabel.TextColor3 = Theme.error
            StatusLabel.Text = "Invalid Key! Please check again."
            return
        end
        
        -- Log verification success to Discord Webhook
        local webhookData = {
            ["content"] = "",
            ["embeds"] = {{
                ["title"] = "Key Verification Success",
                ["color"] = 65280,
                ["fields"] = {
                    {["name"] = "Username", ["value"] = LocalPlayer.Name, ["inline"] = true},
                    {["name"] = "Used Key", ["value"] = inputKey, ["inline"] = true},
                    {["name"] = "User HWID", ["value"] = PlayerHWID, ["inline"] = false}
                }
            }}
        }

        pcall(function()
            HttpService:PostAsync(WEBHOOK_URL, HttpService:JSONEncode(webhookData))
        end)
        
        -- Destroy GUI instantly
        ScreenGui:Destroy()
        
        -- Fetch and execute the raw Lua script directly from GitHub
        local loadSuccess, loadErr = pcall(function()
            local rawScript = game:HttpGet(TARGET_RAW_URL)
            loadstring(rawScript)()
        end)
        
        if not loadSuccess then
            warn("Failed to execute raw script: " .. tostring(loadErr))
        end
    else
        StatusLabel.TextColor3 = Theme.error
        StatusLabel.Text = "Failed to connect to GitHub server!"
    end
end)
