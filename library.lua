--[[
    DarkUI - Dark Theme UI Library for Roblox
    Version: 2.0.0

    Features:
      • Floating toggle button (open/close the window) with custom icon
      • Title bar with Minimize / Maximize / Close image-icon buttons
      • Draggable window
      • Tabs, Buttons, Toggles, Sliders, Dropdowns, Textboxes, Keybinds, Labels
      • Notification toasts

    USAGE:
        local DarkUI = require(path.to.DarkUI)

        local Win = DarkUI:CreateWindow({
            Title    = "My Script",
            Subtitle = "v2.0",
            Icon     = "rbxassetid://YOUR_ICON_ID",   -- optional window icon
            ToggleKey = Enum.KeyCode.RightShift,      -- optional hotkey
        })

        local Tab = Win:AddTab("Main", "🏠")
        Tab:AddButton({ Text = "Hello", Callback = function() print("hi") end })
        Win:Notify({ Title = "Ready", Type = "success" })
--]]

local DarkUI = {}
DarkUI.__index = DarkUI

-- ─── Services ───────────────────────────────────────────────────────────────
local TweenService  = game:GetService("TweenService")
local UIS           = game:GetService("UserInputService")
local Players       = game:GetService("Players")

-- ─── Palette ────────────────────────────────────────────────────────────────
local C = {
    Bg            = Color3.fromRGB(13,  14,  17),
    Surface       = Color3.fromRGB(22,  24,  29),
    Elevated      = Color3.fromRGB(30,  32,  40),
    Border        = Color3.fromRGB(45,  48,  60),
    Accent        = Color3.fromRGB(99,  102, 241),
    AccentHov     = Color3.fromRGB(129, 132, 255),
    Danger        = Color3.fromRGB(239, 68,  68),
    Success       = Color3.fromRGB(34,  197, 94),
    Warning       = Color3.fromRGB(234, 179, 8),
    TextPri       = Color3.fromRGB(240, 241, 245),
    TextSec       = Color3.fromRGB(148, 150, 170),
    TextDis       = Color3.fromRGB(75,  78,  100),
    ToggleOn      = Color3.fromRGB(99,  102, 241),
    ToggleOff     = Color3.fromRGB(45,  48,  60),
}

-- ─── Roblox icon asset IDs (built-in rbxasset/system images) ────────────────
-- These use Roblox's own built-in decal IDs that are always available.
local Icons = {
    -- Window control buttons
    Close    = "rbxassetid://7059346373",   -- X / close
    Minimize = "rbxassetid://7059346373",   -- reuse; we'll draw a bar via Frame instead
    Maximize = "rbxassetid://7059346373",   -- reuse; we'll draw a square via Frame
    -- Floating toggle button
    MenuOpen  = "rbxassetid://6034509993",  -- grid / menu icon
    MenuClose = "rbxassetid://6034509984",  -- X icon for toggle
    -- Tab sidebar default icon
    Tab       = "rbxassetid://6034509993",
}

-- ─── Helpers ─────────────────────────────────────────────────────────────────
local function Tween(obj, props, t, style, dir)
    TweenService:Create(obj,
        TweenInfo.new(t or 0.15, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
        props):Play()
end

local function Corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = p
    return c
end

local function Stroke(p, col, th)
    local s = Instance.new("UIStroke")
    s.Color = col or C.Border
    s.Thickness = th or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p
    return s
end

local function Pad(p, px)
    local u = Instance.new("UIPadding")
    u.PaddingLeft   = UDim.new(0, px)
    u.PaddingRight  = UDim.new(0, px)
    u.PaddingTop    = UDim.new(0, px)
    u.PaddingBottom = UDim.new(0, px)
    u.Parent = p
end

local function Label(parent, text, size, col, bold, xAlign)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text           = text or ""
    l.TextColor3     = col or C.TextPri
    l.TextSize       = size or 14
    l.Font           = bold and Enum.Font.GothamBold or Enum.Font.Gotham
    l.TextXAlignment = xAlign or Enum.TextXAlignment.Left
    l.TextTruncate   = Enum.TextTruncate.AtEnd
    l.Parent         = parent
    return l
end

-- ImageLabel icon helper
local function ImgIcon(parent, id, size, col)
    local img = Instance.new("ImageLabel")
    img.BackgroundTransparency = 1
    img.Image      = id or ""
    img.ImageColor3 = col or C.TextSec
    img.Size       = UDim2.new(0, size or 16, 0, size or 16)
    img.ScaleType  = Enum.ScaleType.Fit
    img.Parent     = parent
    return img
end

local function GetSG()
    local lp = Players.LocalPlayer
    local sg = lp.PlayerGui:FindFirstChild("DarkUI_Root")
    if not sg then
        sg = Instance.new("ScreenGui")
        sg.Name           = "DarkUI_Root"
        sg.ResetOnSpawn   = false
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        sg.Parent         = lp.PlayerGui
    end
    return sg
end

-- ─── Draggable util ─────────────────────────────────────────────────────────
local function MakeDraggable(handle, target)
    local dragging, dragStart, startPos = false, nil, nil
    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = inp.Position
            startPos  = target.Position
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local d = inp.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- ─── Window control button factory ──────────────────────────────────────────
-- Draws a small square button with an inline SVG-like icon drawn with Frames.
local function WinCtrlBtn(parent, iconType, hoverCol)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(0, 28, 0, 28)
    btn.BackgroundColor3 = C.Elevated
    btn.Text             = ""
    btn.AutoButtonColor  = false
    btn.Parent           = parent
    Corner(btn, 6)

    -- Draw icon using frames (no external asset needed — always renders)
    local function DrawClose()
        -- Two diagonal bars forming an X
        for _, angle in ipairs({45, -45}) do
            local bar = Instance.new("Frame")
            bar.AnchorPoint      = Vector2.new(0.5, 0.5)
            bar.Size             = UDim2.new(0, 14, 0, 2)
            bar.Position         = UDim2.new(0.5, 0, 0.5, 0)
            bar.BackgroundColor3 = C.TextSec
            bar.BorderSizePixel  = 0
            bar.Rotation         = angle
            bar.Name             = "CloseBar"
            bar.Parent           = btn
            Corner(bar, 1)
        end
    end

    local function DrawMinimize()
        -- Horizontal bar at bottom center
        local bar = Instance.new("Frame")
        bar.AnchorPoint      = Vector2.new(0.5, 0.5)
        bar.Size             = UDim2.new(0, 14, 0, 2)
        bar.Position         = UDim2.new(0.5, 0, 0.68, 0)
        bar.BackgroundColor3 = C.TextSec
        bar.BorderSizePixel  = 0
        bar.Name             = "MinBar"
        bar.Parent           = btn
        Corner(bar, 1)
    end

    local function DrawMaximize()
        -- Hollow square
        local outer = Instance.new("Frame")
        outer.AnchorPoint      = Vector2.new(0.5, 0.5)
        outer.Size             = UDim2.new(0, 13, 0, 11)
        outer.Position         = UDim2.new(0.5, 0, 0.5, 0)
        outer.BackgroundColor3 = C.TextSec
        outer.BorderSizePixel  = 0
        outer.Name             = "MaxOuter"
        outer.Parent           = btn
        Corner(outer, 2)
        local inner = Instance.new("Frame")
        inner.AnchorPoint      = Vector2.new(0.5, 0.5)
        inner.Size             = UDim2.new(0, 9, 0, 7)
        inner.Position         = UDim2.new(0.5, 0, 0.5, 1)
        inner.BackgroundColor3 = C.Elevated  -- will update on hover
        inner.BorderSizePixel  = 0
        inner.Name             = "MaxInner"
        inner.Parent           = btn
        Corner(inner, 1)
        return inner
    end

    local innerRef = nil
    if iconType == "close" then
        DrawClose()
    elseif iconType == "minimize" then
        DrawMinimize()
    elseif iconType == "maximize" then
        innerRef = DrawMaximize()
    end

    -- Hover colour logic
    local defaultBg = C.Elevated
    btn.MouseEnter:Connect(function()
        Tween(btn, { BackgroundColor3 = hoverCol or C.Border })
        if innerRef then innerRef.BackgroundColor3 = hoverCol or C.Border end
        -- tint the icon bars
        for _, ch in ipairs(btn:GetChildren()) do
            if ch:IsA("Frame") and ch.Name ~= "MaxInner" then
                Tween(ch, { BackgroundColor3 = C.TextPri })
            end
        end
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, { BackgroundColor3 = defaultBg })
        if innerRef then innerRef.BackgroundColor3 = defaultBg end
        for _, ch in ipairs(btn:GetChildren()) do
            if ch:IsA("Frame") and ch.Name ~= "MaxInner" then
                Tween(ch, { BackgroundColor3 = C.TextSec })
            end
        end
    end)

    return btn
end

-- ════════════════════════════════════════════════════════════════════════════
--  CREATE WINDOW
-- ════════════════════════════════════════════════════════════════════════════
function DarkUI:CreateWindow(cfg)
    cfg = cfg or {}
    local title     = cfg.Title     or "DarkUI"
    local subtitle  = cfg.Subtitle  or ""
    local winIcon   = cfg.Icon      or ""   -- rbxassetid for title bar icon
    local width     = cfg.Width     or 540
    local height    = cfg.Height    or 390
    local toggleKey = cfg.ToggleKey or Enum.KeyCode.RightShift

    local sg  = GetSG()
    local win = {}

    -- ── Main frame ──────────────────────────────────────────────────────────
    local Main = Instance.new("Frame")
    Main.Name             = "DarkUI_Window"
    Main.Size             = UDim2.new(0, width, 0, height)
    Main.Position         = UDim2.new(0.5, -width/2, 0.5, -height/2)
    Main.BackgroundColor3 = C.Bg
    Main.BorderSizePixel  = 0
    Main.ClipsDescendants = true
    Main.Parent           = sg
    Corner(Main, 10)
    Stroke(Main, C.Border, 1)

    -- Drop shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.AnchorPoint         = Vector2.new(0.5, 0.5)
    Shadow.BackgroundTransparency = 1
    Shadow.Position            = UDim2.new(0.5, 0, 0.5, 10)
    Shadow.Size                = UDim2.new(1, 40, 1, 40)
    Shadow.Image               = "rbxassetid://6014261993"
    Shadow.ImageColor3         = Color3.new(0, 0, 0)
    Shadow.ImageTransparency   = 0.5
    Shadow.ScaleType           = Enum.ScaleType.Slice
    Shadow.SliceCenter         = Rect.new(49, 49, 450, 450)
    Shadow.ZIndex              = -1
    Shadow.Parent              = Main

    -- ── Title bar ───────────────────────────────────────────────────────────
    local TitleBar = Instance.new("Frame")
    TitleBar.Name             = "TitleBar"
    TitleBar.Size             = UDim2.new(1, 0, 0, 52)
    TitleBar.BackgroundColor3 = C.Surface
    TitleBar.BorderSizePixel  = 0
    TitleBar.ZIndex           = 3
    TitleBar.Parent           = Main
    Corner(TitleBar, 10)

    -- flatten bottom corners of title bar
    local TBFix = Instance.new("Frame")
    TBFix.Size             = UDim2.new(1, 0, 0, 10)
    TBFix.Position         = UDim2.new(0, 0, 1, -10)
    TBFix.BackgroundColor3 = C.Surface
    TBFix.BorderSizePixel  = 0
    TBFix.ZIndex           = 3
    TBFix.Parent           = TitleBar

    -- Accent left stripe
    local Stripe = Instance.new("Frame")
    Stripe.Size             = UDim2.new(0, 3, 1, -18)
    Stripe.Position         = UDim2.new(0, 14, 0, 9)
    Stripe.BackgroundColor3 = C.Accent
    Stripe.BorderSizePixel  = 0
    Stripe.ZIndex           = 4
    Stripe.Parent           = TitleBar
    Corner(Stripe, 2)

    -- Optional window icon image
    local iconOffset = 26
    if winIcon ~= "" then
        local wIco = Instance.new("ImageLabel")
        wIco.BackgroundTransparency = 1
        wIco.Image      = winIcon
        wIco.Size       = UDim2.new(0, 20, 0, 20)
        wIco.Position   = UDim2.new(0, 26, 0.5, -10)
        wIco.ScaleType  = Enum.ScaleType.Fit
        wIco.ZIndex     = 4
        wIco.Parent     = TitleBar
        iconOffset = 52
    end

    local TitleLbl = Label(TitleBar, title, 15, C.TextPri, true)
    TitleLbl.Size     = UDim2.new(1, -180, 0, 20)
    TitleLbl.Position = UDim2.new(0, iconOffset, 0, 7)
    TitleLbl.ZIndex   = 4

    if subtitle ~= "" then
        local SubLbl = Label(TitleBar, subtitle, 11, C.TextSec)
        SubLbl.Size     = UDim2.new(1, -180, 0, 14)
        SubLbl.Position = UDim2.new(0, iconOffset, 0, 30)
        SubLbl.ZIndex   = 4
    end

    -- ── Window control buttons (right side of title bar) ────────────────────
    -- [ _ ]  [ □ ]  [ X ]
    local minimized = false
    local maximized = false
    local savedSize = UDim2.new(0, width, 0, height)
    local savedPos  = Main.Position

    -- Minimize button
    local MinBtn = WinCtrlBtn(TitleBar, "minimize", C.Warning)
    MinBtn.Position = UDim2.new(1, -102, 0.5, -14)
    MinBtn.ZIndex   = 5
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            -- collapse to just the title bar
            Tween(Main, { Size = UDim2.new(0, width, 0, 52) }, 0.22, Enum.EasingStyle.Quint)
        else
            Tween(Main, { Size = savedSize }, 0.22, Enum.EasingStyle.Quint)
        end
    end)

    -- Maximize button
    local MaxBtn = WinCtrlBtn(TitleBar, "maximize", C.Success)
    MaxBtn.Position = UDim2.new(1, -68, 0.5, -14)
    MaxBtn.ZIndex   = 5
    MaxBtn.MouseButton1Click:Connect(function()
        if minimized then return end  -- don't maximize while minimized
        maximized = not maximized
        if maximized then
            savedSize = Main.Size
            savedPos  = Main.Position
            Tween(Main, {
                Size     = UDim2.new(1, -20, 1, -20),
                Position = UDim2.new(0, 10, 0, 10),
            }, 0.25, Enum.EasingStyle.Quint)
        else
            Tween(Main, { Size = savedSize, Position = savedPos }, 0.25, Enum.EasingStyle.Quint)
        end
    end)

    -- Close button
    local CloseBtn = WinCtrlBtn(TitleBar, "close", C.Danger)
    CloseBtn.Position = UDim2.new(1, -34, 0.5, -14)
    CloseBtn.ZIndex   = 5
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(Main, { Size = UDim2.new(0, width, 0, 0), BackgroundTransparency = 1 }, 0.2)
        task.delay(0.22, function()
            Main:Destroy()
            -- also remove toggle button if exists
            local sg2 = GetSG()
            local tb = sg2:FindFirstChild("DarkUI_ToggleBtn")
            if tb then tb:Destroy() end
        end)
    end)

    -- ── Drag ────────────────────────────────────────────────────────────────
    MakeDraggable(TitleBar, Main)

    -- ── Sidebar ─────────────────────────────────────────────────────────────
    local Sidebar = Instance.new("Frame")
    Sidebar.Name             = "Sidebar"
    Sidebar.Size             = UDim2.new(0, 128, 1, -52)
    Sidebar.Position         = UDim2.new(0, 0, 0, 52)
    Sidebar.BackgroundColor3 = C.Surface
    Sidebar.BorderSizePixel  = 0
    Sidebar.Parent           = Main

    local SideList = Instance.new("UIListLayout")
    SideList.Padding   = UDim.new(0, 4)
    SideList.SortOrder = Enum.SortOrder.LayoutOrder
    SideList.Parent    = Sidebar
    Pad(Sidebar, 8)

    -- Divider line
    local Divider = Instance.new("Frame")
    Divider.Size             = UDim2.new(0, 1, 1, -52)
    Divider.Position         = UDim2.new(0, 128, 0, 52)
    Divider.BackgroundColor3 = C.Border
    Divider.BorderSizePixel  = 0
    Divider.Parent           = Main

    -- ── Content area ────────────────────────────────────────────────────────
    local Content = Instance.new("Frame")
    Content.Size                  = UDim2.new(1, -129, 1, -52)
    Content.Position              = UDim2.new(0, 129, 0, 52)
    Content.BackgroundTransparency = 1
    Content.Parent                = Main

    local activeTab = nil
    local tabPages  = {}
    local tabBtns   = {}

    local function SelectTab(name)
        for n, page in pairs(tabPages) do page.Visible = (n == name) end
        for n, btn  in pairs(tabBtns)  do
            if n == name then
                Tween(btn, { BackgroundColor3 = C.Accent, BackgroundTransparency = 0 })
                -- tint label child
                for _, ch in ipairs(btn:GetChildren()) do
                    if ch:IsA("TextLabel") then Tween(ch, { TextColor3 = C.TextPri }) end
                    if ch:IsA("ImageLabel") then Tween(ch, { ImageColor3 = C.TextPri }) end
                end
            else
                Tween(btn, { BackgroundColor3 = C.Elevated, BackgroundTransparency = 1 })
                for _, ch in ipairs(btn:GetChildren()) do
                    if ch:IsA("TextLabel") then Tween(ch, { TextColor3 = C.TextSec }) end
                    if ch:IsA("ImageLabel") then Tween(ch, { ImageColor3 = C.TextSec }) end
                end
            end
        end
        activeTab = name
    end

    -- ════════════════════════════════════════════════════════════════════════
    --  AddTab
    -- ════════════════════════════════════════════════════════════════════════
    function win:AddTab(name, icon)
        -- Sidebar tab button
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size                  = UDim2.new(1, 0, 0, 34)
        TabBtn.BackgroundColor3      = C.Elevated
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text                  = ""
        TabBtn.AutoButtonColor       = false
        TabBtn.LayoutOrder           = #tabBtns + 1
        TabBtn.Parent                = Sidebar
        Corner(TabBtn, 6)

        -- Icon image in tab button
        if icon and icon ~= "" then
            -- If icon is an asset ID string
            if icon:sub(1,4) == "rbx" then
                local ico = ImgIcon(TabBtn, icon, 16, C.TextSec)
                ico.Position   = UDim2.new(0, 8, 0.5, -8)
                ico.AnchorPoint = Vector2.new(0, 0.5)
            else
                -- Treat as emoji/text
                local emojiLbl = Label(TabBtn, icon, 14, C.TextSec)
                emojiLbl.Size     = UDim2.new(0, 22, 1, 0)
                emojiLbl.Position = UDim2.new(0, 6, 0, 0)
                emojiLbl.TextXAlignment = Enum.TextXAlignment.Center
            end
        end

        local TabLbl = Label(TabBtn, name, 13, C.TextSec)
        TabLbl.Size     = UDim2.new(1, -36, 1, 0)
        TabLbl.Position = UDim2.new(0, 30, 0, 0)

        -- Page
        local Page = Instance.new("ScrollingFrame")
        Page.Size                  = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel        = 0
        Page.ScrollBarThickness     = 3
        Page.ScrollBarImageColor3   = C.Accent
        Page.CanvasSize             = UDim2.new(0, 0, 0, 0)
        Page.AutomaticCanvasSize    = Enum.AutomaticSize.Y
        Page.Visible                = false
        Page.Parent                 = Content
        Pad(Page, 12)

        local PageList = Instance.new("UIListLayout")
        PageList.Padding   = UDim.new(0, 8)
        PageList.SortOrder = Enum.SortOrder.LayoutOrder
        PageList.Parent    = Page

        tabPages[name] = Page
        tabBtns[name]  = TabBtn

        TabBtn.MouseEnter:Connect(function()
            if activeTab ~= name then
                Tween(TabBtn, { BackgroundTransparency = 0, BackgroundColor3 = C.Elevated })
                Tween(TabLbl, { TextColor3 = C.TextPri })
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if activeTab ~= name then
                Tween(TabBtn, { BackgroundTransparency = 1 })
                Tween(TabLbl, { TextColor3 = C.TextSec })
            end
        end)
        TabBtn.MouseButton1Click:Connect(function() SelectTab(name) end)

        if activeTab == nil then SelectTab(name) end

        -- ── Row factory ────────────────────────────────────────────────────
        local function NewRow(h)
            local r = Instance.new("Frame")
            r.Size             = UDim2.new(1, 0, 0, h or 36)
            r.BackgroundColor3 = C.Surface
            r.BorderSizePixel  = 0
            r.LayoutOrder      = 9999
            r.Parent           = Page
            Corner(r, 6)
            Stroke(r, C.Border, 1)
            return r
        end

        local tab = {}

        -- ── Section ────────────────────────────────────────────────────────
        function tab:AddSection(text)
            local sec = Instance.new("Frame")
            sec.Size             = UDim2.new(1, 0, 0, 24)
            sec.BackgroundTransparency = 1
            sec.LayoutOrder      = 9999
            sec.Parent           = Page
            local l = Label(sec, text:upper(), 10, C.TextSec, true)
            l.Size     = UDim2.new(1, -8, 1, 0)
            l.Position = UDim2.new(0, 8, 0, 0)
            local line = Instance.new("Frame")
            line.Size             = UDim2.new(0, 0, 0, 1)
            line.Position         = UDim2.new(0, 0, 1, -1)
            line.BackgroundColor3 = C.Accent
            line.BorderSizePixel  = 0
            line.Parent           = sec
            Corner(line, 1)
            task.delay(0.05, function()
                Tween(line, { Size = UDim2.new(1, 0, 0, 1) }, 0.35)
            end)
        end

        -- ── Button ─────────────────────────────────────────────────────────
        function tab:AddButton(cfg2)
            cfg2 = cfg2 or {}
            local h   = cfg2.Description and 52 or 36
            local row = NewRow(h)

            -- Optional left icon in button
            local leftOff = 12
            if cfg2.Icon then
                local bIco = Instance.new("ImageLabel")
                bIco.BackgroundTransparency = 1
                bIco.Image      = cfg2.Icon
                bIco.Size       = UDim2.new(0, 18, 0, 18)
                bIco.Position   = UDim2.new(0, 10, 0.5, -9)
                bIco.ScaleType  = Enum.ScaleType.Fit
                bIco.ImageColor3 = C.Accent
                bIco.Parent     = row
                leftOff = 34
            end

            local lbl = Label(row, cfg2.Text or "Button", 13, C.TextPri)
            lbl.Size     = UDim2.new(1, -leftOff - 8, 0, 18)
            lbl.Position = UDim2.new(0, leftOff, 0, cfg2.Description and 8 or 9)

            if cfg2.Description then
                local d = Label(row, cfg2.Description, 11, C.TextSec)
                d.Size     = UDim2.new(1, -leftOff - 8, 0, 14)
                d.Position = UDim2.new(0, leftOff, 0, 30)
            end

            local btn = Instance.new("TextButton")
            btn.Size             = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text             = ""
            btn.AutoButtonColor  = false
            btn.Parent           = row

            btn.MouseEnter:Connect(function() Tween(row, { BackgroundColor3 = C.Elevated }) end)
            btn.MouseLeave:Connect(function() Tween(row, { BackgroundColor3 = C.Surface  }) end)
            btn.MouseButton1Down:Connect(function() Tween(row, { BackgroundColor3 = C.Border }) end)
            btn.MouseButton1Up:Connect(function() Tween(row, { BackgroundColor3 = C.Elevated }) end)
            btn.MouseButton1Click:Connect(function()
                if cfg2.Callback then task.spawn(cfg2.Callback) end
            end)
            return btn
        end

        -- ── Toggle ─────────────────────────────────────────────────────────
        function tab:AddToggle(cfg2)
            cfg2  = cfg2 or {}
            local row   = NewRow(44)
            local state = cfg2.Default or false

            local lbl = Label(row, cfg2.Text or "Toggle", 13, C.TextPri)
            lbl.Size     = UDim2.new(1, -70, 0, 18)
            lbl.Position = UDim2.new(0, 12, 0, cfg2.Description and 6 or 13)
            if cfg2.Description then
                local d = Label(row, cfg2.Description, 11, C.TextSec)
                d.Size     = UDim2.new(1, -70, 0, 14)
                d.Position = UDim2.new(0, 12, 0, 26)
            end

            local Track = Instance.new("Frame")
            Track.Size             = UDim2.new(0, 40, 0, 20)
            Track.Position         = UDim2.new(1, -52, 0.5, -10)
            Track.BackgroundColor3 = state and C.ToggleOn or C.ToggleOff
            Track.BorderSizePixel  = 0
            Track.Parent           = row
            Corner(Track, 10)

            local Knob = Instance.new("Frame")
            Knob.Size             = UDim2.new(0, 14, 0, 14)
            Knob.Position         = state and UDim2.new(0, 22, 0.5, -7) or UDim2.new(0, 4, 0.5, -7)
            Knob.BackgroundColor3 = C.TextPri
            Knob.BorderSizePixel  = 0
            Knob.Parent           = Track
            Corner(Knob, 7)

            local function Refresh()
                if state then
                    Tween(Track, { BackgroundColor3 = C.ToggleOn })
                    Tween(Knob,  { Position = UDim2.new(0, 22, 0.5, -7) })
                else
                    Tween(Track, { BackgroundColor3 = C.ToggleOff })
                    Tween(Knob,  { Position = UDim2.new(0, 4,  0.5, -7) })
                end
            end

            local TogBtn = Instance.new("TextButton")
            TogBtn.Size             = UDim2.new(1, 0, 1, 0)
            TogBtn.BackgroundTransparency = 1
            TogBtn.Text             = ""
            TogBtn.AutoButtonColor  = false
            TogBtn.Parent           = row
            TogBtn.MouseButton1Click:Connect(function()
                state = not state
                Refresh()
                if cfg2.Callback then task.spawn(cfg2.Callback, state) end
            end)

            local ctrl = {}
            function ctrl:Set(v) state = v; Refresh() end
            function ctrl:Get() return state end
            return ctrl
        end

        -- ── Slider ─────────────────────────────────────────────────────────
        function tab:AddSlider(cfg2)
            cfg2  = cfg2 or {}
            local row  = NewRow(54)
            local min  = cfg2.Min     or 0
            local max  = cfg2.Max     or 100
            local val  = cfg2.Default or min
            local step = cfg2.Step    or 1

            local top = Instance.new("Frame")
            top.Size             = UDim2.new(1, -24, 0, 20)
            top.Position         = UDim2.new(0, 12, 0, 8)
            top.BackgroundTransparency = 1
            top.Parent           = row

            local nameLbl = Label(top, cfg2.Text or "Slider", 13, C.TextPri)
            nameLbl.Size  = UDim2.new(1, -60, 1, 0)

            local valLbl = Label(top, tostring(val) .. (cfg2.Suffix or ""), 13, C.Accent, true, Enum.TextXAlignment.Right)
            valLbl.Size     = UDim2.new(0, 55, 1, 0)
            valLbl.Position = UDim2.new(1, -55, 0, 0)

            local Track = Instance.new("Frame")
            Track.Size             = UDim2.new(1, -24, 0, 6)
            Track.Position         = UDim2.new(0, 12, 0, 36)
            Track.BackgroundColor3 = C.ToggleOff
            Track.BorderSizePixel  = 0
            Track.Parent           = row
            Corner(Track, 3)

            local Fill = Instance.new("Frame")
            Fill.Size             = UDim2.new((val - min) / (max - min), 0, 1, 0)
            Fill.BackgroundColor3 = C.Accent
            Fill.BorderSizePixel  = 0
            Fill.Parent           = Track
            Corner(Fill, 3)

            local Handle = Instance.new("Frame")
            Handle.Size             = UDim2.new(0, 14, 0, 14)
            Handle.AnchorPoint      = Vector2.new(0.5, 0.5)
            Handle.Position         = UDim2.new((val - min) / (max - min), 0, 0.5, 0)
            Handle.BackgroundColor3 = C.TextPri
            Handle.BorderSizePixel  = 0
            Handle.ZIndex           = 2
            Handle.Parent           = Track
            Corner(Handle, 7)
            Stroke(Handle, C.Accent, 2)

            local sliding = false
            local function Update(x)
                local pct     = math.clamp((x - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                local snapped = math.clamp(math.round((min + (max - min) * pct) / step) * step, min, max)
                val           = snapped
                local fp      = (val - min) / (max - min)
                Fill.Size     = UDim2.new(fp, 0, 1, 0)
                Handle.Position = UDim2.new(fp, 0, 0.5, 0)
                valLbl.Text   = tostring(val) .. (cfg2.Suffix or "")
                if cfg2.Callback then task.spawn(cfg2.Callback, val) end
            end

            local TB = Instance.new("TextButton")
            TB.Size             = UDim2.new(1, 0, 0, 26)
            TB.Position         = UDim2.new(0, 0, 0, -10)
            TB.BackgroundTransparency = 1
            TB.Text             = ""
            TB.AutoButtonColor  = false
            TB.ZIndex           = 3
            TB.Parent           = Track
            TB.MouseButton1Down:Connect(function(x) sliding = true; Update(x) end)
            UIS.InputChanged:Connect(function(inp)
                if sliding and inp.UserInputType == Enum.UserInputType.MouseMovement then Update(inp.Position.X) end
            end)
            UIS.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
            end)

            local ctrl = {}
            function ctrl:Set(v)
                val = math.clamp(v, min, max)
                local fp = (val - min) / (max - min)
                Fill.Size = UDim2.new(fp, 0, 1, 0)
                Handle.Position = UDim2.new(fp, 0, 0.5, 0)
                valLbl.Text = tostring(val) .. (cfg2.Suffix or "")
            end
            function ctrl:Get() return val end
            return ctrl
        end

        -- ── Dropdown ───────────────────────────────────────────────────────
        function tab:AddDropdown(cfg2)
            cfg2     = cfg2 or {}
            local options  = cfg2.Options or {}
            local selected = cfg2.Default or options[1] or "Select..."
            local open     = false

            local Wrap = Instance.new("Frame")
            Wrap.Size                  = UDim2.new(1, 0, 0, 36)
            Wrap.BackgroundTransparency = 1
            Wrap.ClipsDescendants      = false
            Wrap.LayoutOrder           = 9999
            Wrap.Parent                = Page

            local row = Instance.new("Frame")
            row.Size             = UDim2.new(1, 0, 0, 36)
            row.BackgroundColor3 = C.Surface
            row.BorderSizePixel  = 0
            row.Parent           = Wrap
            Corner(row, 6)
            Stroke(row, C.Border, 1)

            Label(row, cfg2.Text or "Dropdown", 13, C.TextPri).Size = UDim2.new(0.45, -12, 1, 0)
            local selLbl = Label(row, selected, 13, C.Accent, false, Enum.TextXAlignment.Right)
            selLbl.Size     = UDim2.new(0.5, -30, 1, 0)
            selLbl.Position = UDim2.new(0.5, 0, 0, 0)
            Label(row, "▾", 14, C.TextSec, false, Enum.TextXAlignment.Right).Size = UDim2.new(0, 20, 1, 0)
            -- hack: right-align the arrow
            local arLbl = row:FindFirstChildWhichIsA("TextLabel", true)
            -- just put a dedicated arrow
            local arrLbl = Label(row, "▾", 14, C.TextSec, false, Enum.TextXAlignment.Right)
            arrLbl.Size     = UDim2.new(0, 20, 1, 0)
            arrLbl.Position = UDim2.new(1, -24, 0, 0)

            local DropList = Instance.new("Frame")
            DropList.Size             = UDim2.new(1, 0, 0, 0)
            DropList.Position         = UDim2.new(0, 0, 1, 4)
            DropList.BackgroundColor3 = C.Elevated
            DropList.BorderSizePixel  = 0
            DropList.ClipsDescendants = true
            DropList.ZIndex           = 10
            DropList.Visible          = false
            DropList.Parent           = Wrap
            Corner(DropList, 6)
            Stroke(DropList, C.Border, 1)

            local DL = Instance.new("UIListLayout")
            DL.Padding = UDim.new(0, 2)
            DL.Parent  = DropList
            Pad(DropList, 4)

            local tH = #options * 34 + 8
            for _, opt in ipairs(options) do
                local ob = Instance.new("TextButton")
                ob.Size             = UDim2.new(1, 0, 0, 30)
                ob.BackgroundColor3 = C.Elevated
                ob.BackgroundTransparency = 1
                ob.Text             = opt
                ob.TextColor3       = C.TextSec
                ob.TextSize         = 13
                ob.Font             = Enum.Font.Gotham
                ob.AutoButtonColor  = false
                ob.ZIndex           = 11
                ob.Parent           = DropList
                Corner(ob, 4)
                ob.MouseEnter:Connect(function() Tween(ob, { BackgroundTransparency = 0, BackgroundColor3 = C.Border, TextColor3 = C.TextPri }) end)
                ob.MouseLeave:Connect(function() Tween(ob, { BackgroundTransparency = 1, TextColor3 = C.TextSec }) end)
                ob.MouseButton1Click:Connect(function()
                    selected = opt; selLbl.Text = opt; open = false
                    Tween(DropList, { Size = UDim2.new(1, 0, 0, 0) }, 0.15)
                    Tween(Wrap,     { Size = UDim2.new(1, 0, 0, 36) }, 0.15)
                    task.delay(0.15, function() DropList.Visible = false end)
                    if cfg2.Callback then task.spawn(cfg2.Callback, opt) end
                end)
            end

            local RB = Instance.new("TextButton")
            RB.Size             = UDim2.new(1, 0, 1, 0)
            RB.BackgroundTransparency = 1
            RB.Text             = ""
            RB.AutoButtonColor  = false
            RB.Parent           = row
            RB.MouseButton1Click:Connect(function()
                open = not open
                if open then
                    DropList.Visible = true
                    Tween(DropList, { Size = UDim2.new(1, 0, 0, tH) }, 0.2)
                    Tween(Wrap,     { Size = UDim2.new(1, 0, 0, 36 + tH + 4) }, 0.2)
                else
                    Tween(DropList, { Size = UDim2.new(1, 0, 0, 0) }, 0.15)
                    Tween(Wrap,     { Size = UDim2.new(1, 0, 0, 36) }, 0.15)
                    task.delay(0.15, function() DropList.Visible = false end)
                end
            end)

            local ctrl = {}
            function ctrl:Get() return selected end
            function ctrl:Set(v) selected = v; selLbl.Text = v end
            return ctrl
        end

        -- ── Textbox ────────────────────────────────────────────────────────
        function tab:AddTextbox(cfg2)
            cfg2 = cfg2 or {}
            local row = NewRow(44)
            Label(row, cfg2.Text or "Input", 13, C.TextPri).Size = UDim2.new(1, -24, 0, 16)
            local lbl2 = row:FindFirstChildWhichIsA("TextLabel")
            if lbl2 then lbl2.Position = UDim2.new(0, 12, 0, 6) end

            local Box = Instance.new("TextBox")
            Box.Size             = UDim2.new(1, -24, 0, 18)
            Box.Position         = UDim2.new(0, 12, 0, 24)
            Box.BackgroundTransparency = 1
            Box.Text             = cfg2.Default or ""
            Box.TextColor3       = C.TextPri
            Box.PlaceholderText  = cfg2.Placeholder or "Type here..."
            Box.PlaceholderColor3 = C.TextDis
            Box.TextSize         = 13
            Box.Font             = Enum.Font.Gotham
            Box.TextXAlignment   = Enum.TextXAlignment.Left
            Box.ClearTextOnFocus = cfg2.ClearOnFocus ~= false
            Box.Parent           = row

            local ULine = Instance.new("Frame")
            ULine.Size             = UDim2.new(1, -24, 0, 1)
            ULine.Position         = UDim2.new(0, 12, 1, -1)
            ULine.BackgroundColor3 = C.Border
            ULine.BorderSizePixel  = 0
            ULine.Parent           = row

            Box.Focused:Connect(function() Tween(ULine, { BackgroundColor3 = C.Accent }) end)
            Box.FocusLost:Connect(function(enter)
                Tween(ULine, { BackgroundColor3 = C.Border })
                if cfg2.Callback then task.spawn(cfg2.Callback, Box.Text, enter) end
            end)

            local ctrl = {}
            function ctrl:Get() return Box.Text end
            function ctrl:Set(v) Box.Text = v end
            return ctrl
        end

        -- ── Label ──────────────────────────────────────────────────────────
        function tab:AddLabel(text, color)
            local row = Instance.new("Frame")
            row.Size                  = UDim2.new(1, 0, 0, 28)
            row.BackgroundTransparency = 1
            row.LayoutOrder           = 9999
            row.Parent                = Page
            local l = Label(row, text or "", 13, color or C.TextSec)
            l.Size     = UDim2.new(1, -8, 1, 0)
            l.Position = UDim2.new(0, 8, 0, 0)
            return l
        end

        -- ── Keybind ────────────────────────────────────────────────────────
        function tab:AddKeybind(cfg2)
            cfg2    = cfg2 or {}
            local row     = NewRow(36)
            local current = cfg2.Default or Enum.KeyCode.Unknown
            local binding = false

            local nameLbl = Label(row, cfg2.Text or "Keybind", 13, C.TextPri)
            nameLbl.Size     = UDim2.new(1, -110, 1, 0)
            nameLbl.Position = UDim2.new(0, 12, 0, 0)

            local KB = Instance.new("TextButton")
            KB.Size             = UDim2.new(0, 90, 0, 22)
            KB.Position         = UDim2.new(1, -100, 0.5, -11)
            KB.BackgroundColor3 = C.Elevated
            KB.Text             = current.Name
            KB.TextColor3       = C.Accent
            KB.TextSize         = 12
            KB.Font             = Enum.Font.GothamBold
            KB.AutoButtonColor  = false
            KB.Parent           = row
            Corner(KB, 4)
            Stroke(KB, C.Border, 1)

            KB.MouseButton1Click:Connect(function() binding = true; KB.Text = "..."; KB.TextColor3 = C.Warning end)
            UIS.InputBegan:Connect(function(inp, gp)
                if binding and not gp and inp.UserInputType == Enum.UserInputType.Keyboard then
                    binding = false; current = inp.KeyCode
                    KB.Text = inp.KeyCode.Name; KB.TextColor3 = C.Accent
                    if cfg2.Callback then task.spawn(cfg2.Callback, inp.KeyCode) end
                end
            end)

            local ctrl = {}
            function ctrl:Get() return current end
            return ctrl
        end

        return tab
    end

    -- ════════════════════════════════════════════════════════════════════════
    --  FLOATING TOGGLE BUTTON  (open / close the window)
    -- ════════════════════════════════════════════════════════════════════════
    local ToggleBtn = Instance.new("ImageButton")
    ToggleBtn.Name             = "DarkUI_ToggleBtn"
    ToggleBtn.Size             = UDim2.new(0, 44, 0, 44)
    ToggleBtn.Position         = UDim2.new(0, 16, 0.5, -22)
    ToggleBtn.BackgroundColor3 = C.Surface
    ToggleBtn.Image            = Icons.MenuOpen
    ToggleBtn.ImageColor3      = C.Accent
    ToggleBtn.ScaleType        = Enum.ScaleType.Fit
    ToggleBtn.AutoButtonColor  = false
    ToggleBtn.ZIndex           = 20
    ToggleBtn.Parent           = sg
    Corner(ToggleBtn, 12)
    Stroke(ToggleBtn, C.Accent, 2)

    -- Inner glow ring
    local BtnGlow = Instance.new("ImageLabel")
    BtnGlow.BackgroundTransparency = 1
    BtnGlow.Image      = "rbxassetid://6014261993"
    BtnGlow.ImageColor3 = C.Accent
    BtnGlow.ImageTransparency = 0.7
    BtnGlow.Size       = UDim2.new(1, 16, 1, 16)
    BtnGlow.Position   = UDim2.new(0, -8, 0, -8)
    BtnGlow.ScaleType  = Enum.ScaleType.Slice
    BtnGlow.SliceCenter = Rect.new(49, 49, 450, 450)
    BtnGlow.ZIndex     = 19
    BtnGlow.Parent     = ToggleBtn

    -- Make the toggle button draggable too
    MakeDraggable(ToggleBtn, ToggleBtn)

    local winVisible = true
    local function SetWindowVisible(v)
        winVisible = v
        if v then
            Main.Visible = true
            Tween(Main, { Size = savedSize }, 0.25, Enum.EasingStyle.Back)
            ToggleBtn.Image      = Icons.MenuClose
            ToggleBtn.ImageColor3 = C.Danger
            Tween(ToggleBtn, { BackgroundColor3 = Color3.fromRGB(40, 22, 22) })
            -- stroke colour
        else
            Tween(Main, { Size = UDim2.new(0, width, 0, 0) }, 0.18)
            task.delay(0.18, function() Main.Visible = false end)
            ToggleBtn.Image      = Icons.MenuOpen
            ToggleBtn.ImageColor3 = C.Accent
            Tween(ToggleBtn, { BackgroundColor3 = C.Surface })
        end
    end

    ToggleBtn.MouseButton1Click:Connect(function()
        SetWindowVisible(not winVisible)
    end)
    ToggleBtn.MouseEnter:Connect(function()
        Tween(ToggleBtn, { Size = UDim2.new(0, 48, 0, 48) })
    end)
    ToggleBtn.MouseLeave:Connect(function()
        Tween(ToggleBtn, { Size = UDim2.new(0, 44, 0, 44) })
    end)

    -- Hotkey toggle
    UIS.InputBegan:Connect(function(inp, gp)
        if not gp and inp.KeyCode == toggleKey then
            SetWindowVisible(not winVisible)
        end
    end)

    -- ── Notify ──────────────────────────────────────────────────────────────
    function win:Notify(cfg2)
        cfg2 = cfg2 or {}
        local nTitle = cfg2.Title or "Notification"
        local nDesc  = cfg2.Description or ""
        local nDur   = cfg2.Duration or 3
        local nType  = cfg2.Type or "info"
        local tCol   = ({ info = C.Accent, success = C.Success, warning = C.Warning, danger = C.Danger })[nType] or C.Accent
        local nW, nH = 290, 64 + (nDesc ~= "" and 18 or 0)

        local nSg = GetSG()
        local nF  = Instance.new("Frame")
        nF.Size             = UDim2.new(0, nW, 0, 0)
        nF.Position         = UDim2.new(1, -(nW + 16), 1, -16 - nH)
        nF.BackgroundColor3 = C.Surface
        nF.BorderSizePixel  = 0
        nF.ClipsDescendants = true
        nF.Parent           = nSg
        Corner(nF, 8)
        Stroke(nF, C.Border, 1)

        -- Type icon bar
        local bar = Instance.new("Frame")
        bar.Size             = UDim2.new(0, 3, 1, -16)
        bar.Position         = UDim2.new(0, 10, 0, 8)
        bar.BackgroundColor3 = tCol
        bar.BorderSizePixel  = 0
        bar.Parent           = nF
        Corner(bar, 2)

        local tLbl = Label(nF, nTitle, 13, C.TextPri, true)
        tLbl.Size     = UDim2.new(1, -30, 0, 16)
        tLbl.Position = UDim2.new(0, 22, 0, 12)

        if nDesc ~= "" then
            local dLbl = Label(nF, nDesc, 11, C.TextSec)
            dLbl.Size     = UDim2.new(1, -30, 0, 14)
            dLbl.Position = UDim2.new(0, 22, 0, 30)
        end

        local prog = Instance.new("Frame")
        prog.Size             = UDim2.new(1, 0, 0, 2)
        prog.Position         = UDim2.new(0, 0, 1, -2)
        prog.BackgroundColor3 = tCol
        prog.BorderSizePixel  = 0
        prog.Parent           = nF

        Tween(nF, { Size = UDim2.new(0, nW, 0, nH) }, 0.25)
        task.delay(0.05, function()
            Tween(prog, { Size = UDim2.new(0, 0, 0, 2) }, nDur, Enum.EasingStyle.Linear)
        end)
        task.delay(nDur + 0.05, function()
            Tween(nF, { Size = UDim2.new(0, nW, 0, 0) }, 0.2)
            task.delay(0.2, function() nF:Destroy() end)
        end)
    end

    function win:SetTitle(t) TitleLbl.Text = t end
    function win:Toggle() SetWindowVisible(not winVisible) end
    function win:Destroy() Main:Destroy(); ToggleBtn:Destroy() end

    return win
end

return DarkUI
