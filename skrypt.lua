local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local running = true

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoClickerToggle"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Button = Instance.new("TextButton")
Button.Size = UDim2.new(0, 160, 0, 50)
Button.Position = UDim2.new(0, 50, 0, 50)
Button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
Button.Text = "Status: DZIAŁA (F2)"
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.TextSize = 15
Button.Font = Enum.Font.SourceSansBold
Button.Parent = ScreenGui

local function toggleState()
    running = not running
    if running then
        Button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        Button.Text = "Status: DZIAŁA (F2)"
    else
        Button.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
        Button.Text = "Status: ZATRZYMANY (F2)"
    end
end

Button.MouseButton1Click:Connect(toggleState)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.F2 then
        toggleState()
    end
end)

-- Szybki wątek do obsługi paska +20
task.spawn(function()
    while true do
        if running then
            pcall(function()
                for _, gui in ipairs(PlayerGui:GetDescendants()) do
                    if not running then break end
                    if gui:IsA("TextLabel") or gui:IsA("TextBox") then
                        if gui.Text == "+20" then
                            local pos = gui.AbsolutePosition + (gui.AbsoluteSize / 2)
                            if pos.X > 0 and pos.Y > 0 then
                                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
                                task.wait()
                                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
                                task.wait(0.5) -- Odczekaj po kliknięciu, aby nie spamować
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.02)
    end
end)

-- Wolniejszy wątek do obsługi boostów (raz na sekundę, żeby nie lagować)
task.spawn(function()
    while true do
        if running then
            pcall(function()
                for _, gui in ipairs(PlayerGui:GetDescendants()) do
                    if not running then break end
                    if gui:IsA("TextButton") or gui:IsA("ImageButton") then
                        if gui ~= Button and gui.AbsoluteSize.X > 0 and gui.AbsolutePosition.X > 0 then
                            local text = gui:IsA("TextButton") and gui.Text or ""
                            local combined = (text .. " " .. gui.Name):lower()
                            if combined:find("x2") or combined:find("mult") or combined:find("boost") then
                                local pos = gui.AbsolutePosition + (gui.AbsoluteSize / 2)
                                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
                                task.wait()
                                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
                                if getconnections then
                                    pcall(function()
                                        for _, conn in ipairs(getconnections(gui.MouseButton1Click)) do conn:Fire() end
                                    end)
                                end
                            end
                        end
                    end
                end
            end)
        end
        task.wait(1)
    end
end)
