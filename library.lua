--[[
    DarkUI - A Dark Theme UI Library for Roblox
    Version: 1.0.0

    USAGE:
        local DarkUI = loadstring(game:HttpGet("..."))() -- or require(module)
        local Window = DarkUI:CreateWindow({ Title = "My Menu" })
        local Tab    = Window:AddTab("Main")
        Tab:AddButton({ Text = "Click Me", Callback = function() print("clicked") end })
--]]

local DarkUI = {}
DarkUI.__index = DarkUI

-- ─── Palette ────────────────────────────────────────────────────────────────
local Colors = {
    Background    = Color3.fromRGB(13,  14,  17),   -- near-black base
    Surface       = Color3.fromRGB(22,  24,  29),   -- card / panel
    Elevated      = Color3.fromRGB(30,  32,  40),   -- raised element
    Border        = Color3.fromRGB(45,  48,  60),   -- subtle divider
    Accent        = Color3.fromRGB(99,  102, 241),  -- indigo-500 brand colour
    AccentHover   = Color3.fromRGB(129, 132, 255),  -- lighter on hover
    AccentPressed = Color3.fromRGB(67,  70,  200),  -- darker on press
    Danger        = Color3.fromRGB(239, 68,  68),   -- red-500
    Success       = Color3.fromRGB(34,  197, 94),   -- green-500
    Warning       = Color3.fromRGB(234, 179, 8),    -- yellow-500
    TextPrimary   = Color3.fromRGB(240, 241, 245),
    TextSecondary = Color3.fromRGB(148, 150, 170),
    TextDisabled  = Color3.fromRGB(75,  78,  100),
    ToggleOn      = Color3.fromRGB(99,  102, 241),
    ToggleOff     = Color3.fromRGB(45,  48,  60),
    SliderFill    = Color3.fromRGB(99,  102, 241),
    SliderTrack   = Color3.fromRGB(45,  48,  60),
}

-- ─── Tween helper ───────────────────────────────────────────────────────────
local TweenService = game:GetService("TweenService")
local function Tween(obj, props, t, style, dir)
    t     = t     or 0.15
    style = style or Enum.EasingStyle.Quad
    dir   = dir   or Enum.EasingDirection.Out
    TweenService:Create(obj, TweenInfo.new(t, style, dir), props):Play()
end

-- ─── Corner / Stroke helpers ────────────────────────────────────────────────
local function AddCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    c.Parent = parent
    return c
end

local function AddStroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color     = color or Colors.Border
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function AddPadding(parent, px)
    local p = Instance.new("UIPadding")
    p.PaddingLeft   = UDim.new(0, px)
    p.PaddingRight  = UDim.new(0, px)
    p.PaddingTop    = UDim.new(0, px)
    p.PaddingBottom = UDim.new(0, px)
    p.Parent = parent
    return p
end

-- ─── Label helper ───────────────────────────────────────────────────────────
local function MakeLabel(parent, text, size, color, bold, xAlign)
    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Text      = text or ""
    lbl.TextColor3 = color or Colors.TextPrimary
    lbl.TextSize  = size or 14
    lbl.Font      = bold and Enum.Font.GothamBold or Enum.Font.Gotham
    lbl.TextXAlignment = xAlign or Enum.TextXAlignment.Left
    lbl.TextTruncate   = Enum.TextTruncate.AtEnd
    lbl.Parent    = parent
    return lbl
end

-- ─── Screen GUI root ────────────────────────────────────────────────────────
local function GetScreenGui()
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    local sg = lp.PlayerGui:FindFirstChild("DarkUI_Root")
    if not sg then
        sg = Instance.new("ScreenGui")
        sg.Name            = "DarkUI_Root"
        sg.ResetOnSpawn    = false
        sg.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
        sg.Parent          = lp.PlayerGui
    end
    return sg
end

-- ════════════════════════════════════════════════════════════════════════════
--  WINDOW
-- ════════════════════════════════════════════════════════════════════════════
function DarkUI:CreateWindow(cfg)
    cfg = cfg or {}
    local title    = cfg.Title    or "DarkUI"
    local subtitle = cfg.Subtitle or ""
    local width    = cfg.Width    or 520
    local height   = cfg.Height   or 380

    local sg  = GetScreenGui()
    local win = {}

    -- ── Main frame ──────────────────────────────────────────────────────────
    local Main = Instance.new("Frame")
    Main.Name            = "DarkUI_Window"
    Main.Size            = UDim2.new(0, width, 0, height)
    Main.Position        = UDim2.new(0.5, -width/2, 0.5, -height/2)
    Main.BackgroundColor3 = Colors.Background
    Main.BorderSizePixel = 0
    Main.Parent          = sg
    AddCorner(Main, 10)
    AddStroke(Main, Colors.Border, 1)

    -- drop shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name               = "Shadow"
    Shadow.AnchorPoint        = Vector2.new(0.5, 0.5)
    Shadow.BackgroundTransparency = 1
    Shadow.Position           = UDim2.new(0.5, 0, 0.5, 8)
    Shadow.Size               = UDim2.new(1, 30, 1, 30)
    Shadow.Image              = "rbxassetid://6014261993"
    Shadow.ImageColor3        = Color3.new(0, 0, 0)
    Shadow.ImageTransparency  = 0.55
    Shadow.ScaleType          = Enum.ScaleType.Slice
    Shadow.SliceCenter        = Rect.new(49, 49, 450, 450)
    Shadow.ZIndex             = -1
    Shadow.Parent             = Main

    -- ── Title bar ───────────────────────────────────────────────────────────
    local TitleBar = Instance.new("Frame")
    TitleBar.Name              = "TitleBar"
    TitleBar.Size              = UDim2.new(1, 0, 0, 48)
    TitleBar.BackgroundColor3  = Colors.Surface
    TitleBar.BorderSizePixel   = 0
    TitleBar.Parent            = Main

    local TitleBarTop = Instance.new("UICorner")
    TitleBarTop.CornerRadius = UDim.new(0, 10)
    TitleBarTop.Parent       = TitleBar

    -- bottom-flatten the top corners
    local TitleBarFix = Instance.new("Frame")
    TitleBarFix.Size              = UDim2.new(1, 0, 0, 10)
    TitleBarFix.Position          = UDim2.new(0, 0, 1, -10)
    TitleBarFix.BackgroundColor3  = Colors.Surface
    TitleBarFix.BorderSizePixel   = 0
    TitleBarFix.Parent            = TitleBar

    -- accent stripe
    local Stripe = Instance.new("Frame")
    Stripe.Size             = UDim2.new(0, 3, 1, -16)
    Stripe.Position         = UDim2.new(0, 12, 0, 8)
    Stripe.BackgroundColor3 = Colors.Accent
    Stripe.BorderSizePixel  = 0
    Stripe.Parent           = TitleBar
    AddCorner(Stripe, 2)

    local TitleLbl = MakeLabel(TitleBar, title, 15, Colors.TextPrimary, true)
    TitleLbl.Size     = UDim2.new(1, -80, 0, 20)
    TitleLbl.Position = UDim2.new(0, 24, 0, 6)

    if subtitle ~= "" then
        local SubLbl = MakeLabel(TitleBar, subtitle, 11, Colors.TextSecondary)
        SubLbl.Size     = UDim2.new(1, -80, 0, 14)
        SubLbl.Position = UDim2.new(0, 24, 0, 28)
    end

    -- close button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name              = "CloseBtn"
    CloseBtn.Size              = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position          = UDim2.new(1, -38, 0, 10)
    CloseBtn.BackgroundColor3  = Colors.Elevated
    CloseBtn.Text              = "✕"
    CloseBtn.TextColor3        = Colors.TextSecondary
    CloseBtn.TextSize          = 12
    CloseBtn.Font              = Enum.Font.GothamBold
    CloseBtn.AutoButtonColor   = false
    CloseBtn.Parent            = TitleBar
    AddCorner(CloseBtn, 6)

    CloseBtn.MouseEnter:Connect(function()
        Tween(CloseBtn, { BackgroundColor3 = Colors.Danger })
        Tween(CloseBtn, { TextColor3 = Colors.TextPrimary })
    end)
    CloseBtn.MouseLeave:Connect(function()
        Tween(CloseBtn, { BackgroundColor3 = Colors.Elevated })
        Tween(CloseBtn, { TextColor3 = Colors.TextSecondary })
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(Main, { Size = UDim2.new(0, width, 0, 0) }, 0.2)
        task.delay(0.2, function() Main:Destroy() end)
    end)

    -- ── Drag logic ──────────────────────────────────────────────────────────
    local UIS = game:GetService("UserInputService")
    local dragging, dragStart, startPos = false, nil, nil
    TitleBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = inp.Position
            startPos  = Main.Position
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = inp.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- ── Tab bar ─────────────────────────────────────────────────────────────
    local TabBar = Instance.new("Frame")
    TabBar.Name              = "TabBar"
    TabBar.Size              = UDim2.new(0, 120, 1, -48)
    TabBar.Position          = UDim2.new(0, 0, 0, 48)
    TabBar.BackgroundColor3  = Colors.Surface
    TabBar.BorderSizePixel   = 0
    TabBar.Parent            = Main

    local TabList = Instance.new("UIListLayout")
    TabList.Padding          = UDim.new(0, 4)
    TabList.SortOrder        = Enum.SortOrder.LayoutOrder
    TabList.Parent           = TabBar
    AddPadding(TabBar, 8)

    -- divider between sidebar and content
    local Divider = Instance.new("Frame")
    Divider.Size             = UDim2.new(0, 1, 1, -48)
    Divider.Position         = UDim2.new(0, 120, 0, 48)
    Divider.BackgroundColor3 = Colors.Border
    Divider.BorderSizePixel  = 0
    Divider.Parent           = Main

    -- ── Content area ────────────────────────────────────────────────────────
    local ContentArea = Instance.new("Frame")
    ContentArea.Name              = "ContentArea"
    ContentArea.Size              = UDim2.new(1, -121, 1, -48)
    ContentArea.Position          = UDim2.new(0, 121, 0, 48)
    ContentArea.BackgroundTransparency = 1
    ContentArea.BorderSizePixel   = 0
    ContentArea.Parent            = Main

    local activeTab    = nil
    local activeBtn    = nil
    local tabPages     = {}
    local tabBtns      = {}

    local function SelectTab(name)
        for n, page in pairs(tabPages) do
            page.Visible = (n == name)
        end
        for n, btn in pairs(tabBtns) do
            if n == name then
                Tween(btn, { BackgroundColor3 = Colors.Accent })
                Tween(btn, { TextColor3 = Colors.TextPrimary })
            else
                Tween(btn, { BackgroundColor3 = Color3.fromRGB(0,0,0) })
                Tween(btn, { BackgroundTransparency = 1 })
                Tween(btn, { TextColor3 = Colors.TextSecondary })
            end
        end
        activeTab = name
    end

    -- ── AddTab ──────────────────────────────────────────────────────────────
    function win:AddTab(name, icon)
        icon = icon or ""

        local TabBtn = Instance.new("TextButton")
        TabBtn.Name              = "Tab_" .. name
        TabBtn.Size              = UDim2.new(1, 0, 0, 32)
        TabBtn.BackgroundColor3  = Colors.Background
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text              = (icon ~= "" and icon .. "  " or "") .. name
        TabBtn.TextColor3        = Colors.TextSecondary
        TabBtn.TextSize          = 13
        TabBtn.Font              = Enum.Font.Gotham
        TabBtn.TextXAlignment    = Enum.TextXAlignment.Left
        TabBtn.AutoButtonColor   = false
        TabBtn.LayoutOrder       = #tabBtns + 1
        TabBtn.Parent            = TabBar
        AddCorner(TabBtn, 6)
        local tbPad = Instance.new("UIPadding")
        tbPad.PaddingLeft = UDim.new(0, 10)
        tbPad.Parent = TabBtn

        -- Page scroll frame
        local Page = Instance.new("ScrollingFrame")
        Page.Name                  = "Page_" .. name
        Page.Size                  = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel        = 0
        Page.ScrollBarThickness     = 3
        Page.ScrollBarImageColor3   = Colors.Accent
        Page.CanvasSize             = UDim2.new(0, 0, 0, 0)
        Page.AutomaticCanvasSize    = Enum.AutomaticSize.Y
        Page.Visible                = false
        Page.Parent                 = ContentArea
        AddPadding(Page, 12)

        local PageList = Instance.new("UIListLayout")
        PageList.Padding    = UDim.new(0, 8)
        PageList.SortOrder  = Enum.SortOrder.LayoutOrder
        PageList.Parent     = Page

        tabPages[name] = Page
        tabBtns[name]  = TabBtn

        TabBtn.MouseEnter:Connect(function()
            if activeTab ~= name then
                Tween(TabBtn, { TextColor3 = Colors.TextPrimary })
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if activeTab ~= name then
                Tween(TabBtn, { TextColor3 = Colors.TextSecondary })
            end
        end)
        TabBtn.MouseButton1Click:Connect(function()
            SelectTab(name)
        end)

        if activeTab == nil then
            SelectTab(name)
        end

        -- ── Element helpers shared across all component adders ──────────────
        local function NewRow(h)
            local row = Instance.new("Frame")
            row.Size             = UDim2.new(1, 0, 0, h or 36)
            row.BackgroundColor3 = Colors.Surface
            row.BorderSizePixel  = 0
            row.LayoutOrder      = PageList.AbsoluteContentSize.Y
            row.Parent           = Page
            AddCorner(row, 6)
            AddStroke(row, Colors.Border, 1)
            return row
        end

        local tab = {}

        -- ── Section label ───────────────────────────────────────────────────
        function tab:AddSection(text)
            local sec = Instance.new("Frame")
            sec.Size             = UDim2.new(1, 0, 0, 24)
            sec.BackgroundTransparency = 1
            sec.LayoutOrder      = 9999
            sec.Parent           = Page

            local lbl = MakeLabel(sec, text:upper(), 10, Colors.TextSecondary, true)
            lbl.Size     = UDim2.new(1, -8, 1, 0)
            lbl.Position = UDim2.new(0, 8, 0, 0)

            local line = Instance.new("Frame")
            line.Size             = UDim2.new(0, 0, 0, 1)  -- animated in
            line.Position         = UDim2.new(0, 0, 1, -1)
            line.BackgroundColor3 = Colors.Accent
            line.BorderSizePixel  = 0
            line.Parent           = sec
            AddCorner(line, 1)
            task.delay(0.05, function()
                Tween(line, { Size = UDim2.new(1, 0, 0, 1) }, 0.35, Enum.EasingStyle.Quad)
            end)
        end

        -- ── Button ──────────────────────────────────────────────────────────
        function tab:AddButton(cfg2)
            cfg2 = cfg2 or {}
            local row = NewRow(36)

            local btn = Instance.new("TextButton")
            btn.Size             = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text             = cfg2.Text or "Button"
            btn.TextColor3       = Colors.TextPrimary
            btn.TextSize         = 13
            btn.Font             = Enum.Font.Gotham
            btn.AutoButtonColor  = false
            btn.Parent           = row

            if cfg2.Description then
                btn.TextXAlignment = Enum.TextXAlignment.Left
                local pad = Instance.new("UIPadding")
                pad.PaddingLeft = UDim.new(0, 12)
                pad.Parent = btn
                local desc = MakeLabel(row, cfg2.Description, 11, Colors.TextSecondary)
                desc.Size     = UDim2.new(1, -12, 0, 14)
                desc.Position = UDim2.new(0, 12, 1, -16)
                row.Size = UDim2.new(1, 0, 0, 52)
            end

            btn.MouseEnter:Connect(function()
                Tween(row, { BackgroundColor3 = Colors.Elevated })
            end)
            btn.MouseLeave:Connect(function()
                Tween(row, { BackgroundColor3 = Colors.Surface })
            end)
            btn.MouseButton1Down:Connect(function()
                Tween(row, { BackgroundColor3 = Colors.Border })
            end)
            btn.MouseButton1Up:Connect(function()
                Tween(row, { BackgroundColor3 = Colors.Elevated })
            end)
            btn.MouseButton1Click:Connect(function()
                if cfg2.Callback then
                    task.spawn(cfg2.Callback)
                end
            end)

            return btn
        end

        -- ── Toggle ──────────────────────────────────────────────────────────
        function tab:AddToggle(cfg2)
            cfg2 = cfg2 or {}
            local row  = NewRow(44)
            local state = cfg2.Default or false

            local lbl = MakeLabel(row, cfg2.Text or "Toggle", 13, Colors.TextPrimary)
            lbl.Size     = UDim2.new(1, -60, 0, 18)
            lbl.Position = UDim2.new(0, 12, 0, 6)
            if cfg2.Description then
                local d = MakeLabel(row, cfg2.Description, 11, Colors.TextSecondary)
                d.Size     = UDim2.new(1, -60, 0, 14)
                d.Position = UDim2.new(0, 12, 0, 26)
            end

            local Track = Instance.new("Frame")
            Track.Size             = UDim2.new(0, 40, 0, 20)
            Track.Position         = UDim2.new(1, -50, 0.5, -10)
            Track.BackgroundColor3 = state and Colors.ToggleOn or Colors.ToggleOff
            Track.BorderSizePixel  = 0
            Track.Parent           = row
            AddCorner(Track, 10)

            local Knob = Instance.new("Frame")
            Knob.Size             = UDim2.new(0, 14, 0, 14)
            Knob.Position         = state and UDim2.new(0, 22, 0.5, -7) or UDim2.new(0, 4, 0.5, -7)
            Knob.BackgroundColor3 = Colors.TextPrimary
            Knob.BorderSizePixel  = 0
            Knob.Parent           = Track
            AddCorner(Knob, 7)

            local ToggleBtn = Instance.new("TextButton")
            ToggleBtn.Size             = UDim2.new(1, 0, 1, 0)
            ToggleBtn.BackgroundTransparency = 1
            ToggleBtn.Text             = ""
            ToggleBtn.AutoButtonColor  = false
            ToggleBtn.Parent           = row

            local function Refresh()
                if state then
                    Tween(Track, { BackgroundColor3 = Colors.ToggleOn })
                    Tween(Knob,  { Position = UDim2.new(0, 22, 0.5, -7) })
                else
                    Tween(Track, { BackgroundColor3 = Colors.ToggleOff })
                    Tween(Knob,  { Position = UDim2.new(0, 4,  0.5, -7) })
                end
            end

            ToggleBtn.MouseButton1Click:Connect(function()
                state = not state
                Refresh()
                if cfg2.Callback then
                    task.spawn(cfg2.Callback, state)
                end
            end)

            local ctrl = {}
            function ctrl:Set(v)
                state = v
                Refresh()
            end
            function ctrl:Get() return state end
            return ctrl
        end

        -- ── Slider ──────────────────────────────────────────────────────────
        function tab:AddSlider(cfg2)
            cfg2 = cfg2 or {}
            local row  = NewRow(54)
            local min  = cfg2.Min     or 0
            local max  = cfg2.Max     or 100
            local val  = cfg2.Default or min
            local step = cfg2.Step    or 1

            local topRow = Instance.new("Frame")
            topRow.Size             = UDim2.new(1, -24, 0, 20)
            topRow.Position         = UDim2.new(0, 12, 0, 8)
            topRow.BackgroundTransparency = 1
            topRow.Parent           = row

            local nameLbl = MakeLabel(topRow, cfg2.Text or "Slider", 13, Colors.TextPrimary)
            nameLbl.Size     = UDim2.new(1, -60, 1, 0)

            local valLbl = MakeLabel(topRow, tostring(val), 13, Colors.Accent, true, Enum.TextXAlignment.Right)
            valLbl.Size     = UDim2.new(0, 55, 1, 0)
            valLbl.Position = UDim2.new(1, -55, 0, 0)
            if cfg2.Suffix then
                valLbl.Text = val .. cfg2.Suffix
            end

            local Track = Instance.new("Frame")
            Track.Size             = UDim2.new(1, -24, 0, 6)
            Track.Position         = UDim2.new(0, 12, 0, 36)
            Track.BackgroundColor3 = Colors.SliderTrack
            Track.BorderSizePixel  = 0
            Track.Parent           = row
            AddCorner(Track, 3)

            local Fill = Instance.new("Frame")
            Fill.Size             = UDim2.new((val - min) / (max - min), 0, 1, 0)
            Fill.BackgroundColor3 = Colors.SliderFill
            Fill.BorderSizePixel  = 0
            Fill.Parent           = Track
            AddCorner(Fill, 3)

            local Handle = Instance.new("Frame")
            Handle.Size             = UDim2.new(0, 14, 0, 14)
            Handle.AnchorPoint      = Vector2.new(0.5, 0.5)
            Handle.Position         = UDim2.new((val - min) / (max - min), 0, 0.5, 0)
            Handle.BackgroundColor3 = Colors.TextPrimary
            Handle.BorderSizePixel  = 0
            Handle.ZIndex           = 2
            Handle.Parent           = Track
            AddCorner(Handle, 7)
            AddStroke(Handle, Colors.Accent, 2)

            local UIS2 = game:GetService("UserInputService")
            local sliding = false

            local function UpdateSlider(inputPos)
                local absPos  = Track.AbsolutePosition.X
                local absSize = Track.AbsoluteSize.X
                local pct     = math.clamp((inputPos - absPos) / absSize, 0, 1)
                local raw     = min + (max - min) * pct
                local snapped = math.round(raw / step) * step
                snapped       = math.clamp(snapped, min, max)
                val           = snapped

                local fillPct = (val - min) / (max - min)
                Fill.Size     = UDim2.new(fillPct, 0, 1, 0)
                Handle.Position = UDim2.new(fillPct, 0, 0.5, 0)
                valLbl.Text   = tostring(val) .. (cfg2.Suffix or "")
                if cfg2.Callback then
                    task.spawn(cfg2.Callback, val)
                end
            end

            local TrackBtn = Instance.new("TextButton")
            TrackBtn.Size             = UDim2.new(1, 0, 0, 26)
            TrackBtn.Position         = UDim2.new(0, 0, 0, -10)
            TrackBtn.BackgroundTransparency = 1
            TrackBtn.Text             = ""
            TrackBtn.AutoButtonColor  = false
            TrackBtn.ZIndex           = 3
            TrackBtn.Parent           = Track

            TrackBtn.MouseButton1Down:Connect(function(x)
                sliding = true
                UpdateSlider(x)
            end)
            UIS2.InputChanged:Connect(function(inp)
                if sliding and inp.UserInputType == Enum.UserInputType.MouseMovement then
                    UpdateSlider(inp.Position.X)
                end
            end)
            UIS2.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding = false
                end
            end)

            local ctrl = {}
            function ctrl:Set(v)
                val = math.clamp(v, min, max)
                local fillPct = (val - min) / (max - min)
                Fill.Size     = UDim2.new(fillPct, 0, 1, 0)
                Handle.Position = UDim2.new(fillPct, 0, 0.5, 0)
                valLbl.Text   = tostring(val) .. (cfg2.Suffix or "")
            end
            function ctrl:Get() return val end
            return ctrl
        end

        -- ── Dropdown ────────────────────────────────────────────────────────
        function tab:AddDropdown(cfg2)
            cfg2 = cfg2 or {}
            local options  = cfg2.Options or {}
            local selected = cfg2.Default or options[1] or "Select..."
            local open     = false

            local Wrap = Instance.new("Frame")
            Wrap.Size             = UDim2.new(1, 0, 0, 36)
            Wrap.BackgroundTransparency = 1
            Wrap.ClipsDescendants = false
            Wrap.LayoutOrder      = PageList.AbsoluteContentSize.Y
            Wrap.Parent           = Page

            local row = Instance.new("Frame")
            row.Size             = UDim2.new(1, 0, 0, 36)
            row.BackgroundColor3 = Colors.Surface
            row.BorderSizePixel  = 0
            row.Parent           = Wrap
            AddCorner(row, 6)
            AddStroke(row, Colors.Border, 1)

            local nameLbl = MakeLabel(row, cfg2.Text or "Dropdown", 13, Colors.TextPrimary)
            nameLbl.Size     = UDim2.new(0.5, -12, 1, 0)
            nameLbl.Position = UDim2.new(0, 12, 0, 0)

            local selLbl = MakeLabel(row, selected, 13, Colors.Accent, false, Enum.TextXAlignment.Right)
            selLbl.Size     = UDim2.new(0.5, -30, 1, 0)
            selLbl.Position = UDim2.new(0.5, 0, 0, 0)

            local Arrow = MakeLabel(row, "▾", 14, Colors.TextSecondary, false, Enum.TextXAlignment.Right)
            Arrow.Size     = UDim2.new(0, 20, 1, 0)
            Arrow.Position = UDim2.new(1, -24, 0, 0)

            -- dropdown list
            local DropList = Instance.new("Frame")
            DropList.Name             = "DropList"
            DropList.Size             = UDim2.new(1, 0, 0, 0)
            DropList.Position         = UDim2.new(0, 0, 1, 4)
            DropList.BackgroundColor3 = Colors.Elevated
            DropList.BorderSizePixel  = 0
            DropList.ClipsDescendants = true
            DropList.ZIndex           = 10
            DropList.Visible          = false
            DropList.Parent           = Wrap
            AddCorner(DropList, 6)
            AddStroke(DropList, Colors.Border, 1)

            local ListLayout = Instance.new("UIListLayout")
            ListLayout.Padding   = UDim.new(0, 2)
            ListLayout.Parent    = DropList
            AddPadding(DropList, 4)

            local targetH = #options * 34 + 8

            for _, opt in ipairs(options) do
                local optBtn = Instance.new("TextButton")
                optBtn.Size             = UDim2.new(1, 0, 0, 30)
                optBtn.BackgroundColor3 = Colors.Elevated
                optBtn.BackgroundTransparency = 1
                optBtn.Text             = opt
                optBtn.TextColor3       = Colors.TextSecondary
                optBtn.TextSize         = 13
                optBtn.Font             = Enum.Font.Gotham
                optBtn.AutoButtonColor  = false
                optBtn.ZIndex           = 11
                optBtn.Parent           = DropList
                AddCorner(optBtn, 4)

                optBtn.MouseEnter:Connect(function()
                    Tween(optBtn, { BackgroundTransparency = 0, BackgroundColor3 = Colors.Border })
                    Tween(optBtn, { TextColor3 = Colors.TextPrimary })
                end)
                optBtn.MouseLeave:Connect(function()
                    Tween(optBtn, { BackgroundTransparency = 1 })
                    Tween(optBtn, { TextColor3 = Colors.TextSecondary })
                end)
                optBtn.MouseButton1Click:Connect(function()
                    selected     = opt
                    selLbl.Text  = opt
                    open         = false
                    Tween(DropList, { Size = UDim2.new(1, 0, 0, 0) }, 0.15)
                    task.delay(0.15, function() DropList.Visible = false end)
                    Tween(Wrap, { Size = UDim2.new(1, 0, 0, 36) }, 0.15)
                    if cfg2.Callback then task.spawn(cfg2.Callback, opt) end
                end)
            end

            local RowBtn = Instance.new("TextButton")
            RowBtn.Size             = UDim2.new(1, 0, 1, 0)
            RowBtn.BackgroundTransparency = 1
            RowBtn.Text             = ""
            RowBtn.AutoButtonColor  = false
            RowBtn.Parent           = row

            RowBtn.MouseButton1Click:Connect(function()
                open = not open
                if open then
                    DropList.Visible = true
                    Tween(DropList, { Size = UDim2.new(1, 0, 0, targetH) }, 0.2, Enum.EasingStyle.Quad)
                    Tween(Wrap,     { Size = UDim2.new(1, 0, 0, 36 + targetH + 4) }, 0.2)
                else
                    Tween(DropList, { Size = UDim2.new(1, 0, 0, 0) }, 0.15)
                    Tween(Wrap,     { Size = UDim2.new(1, 0, 0, 36) }, 0.15)
                    task.delay(0.15, function() DropList.Visible = false end)
                end
            end)

            local ctrl = {}
            function ctrl:Get() return selected end
            function ctrl:Set(v)
                selected    = v
                selLbl.Text = v
            end
            return ctrl
        end

        -- ── Text Input ──────────────────────────────────────────────────────
        function tab:AddTextbox(cfg2)
            cfg2 = cfg2 or {}
            local row = NewRow(44)

            local lbl = MakeLabel(row, cfg2.Text or "Input", 13, Colors.TextPrimary)
            lbl.Size     = UDim2.new(1, -24, 0, 16)
            lbl.Position = UDim2.new(0, 12, 0, 6)

            local Box = Instance.new("TextBox")
            Box.Size             = UDim2.new(1, -24, 0, 18)
            Box.Position         = UDim2.new(0, 12, 0, 24)
            Box.BackgroundTransparency = 1
            Box.Text             = cfg2.Default or ""
            Box.TextColor3       = Colors.TextPrimary
            Box.PlaceholderText  = cfg2.Placeholder or "Type here..."
            Box.PlaceholderColor3 = Colors.TextDisabled
            Box.TextSize         = 13
            Box.Font             = Enum.Font.Gotham
            Box.TextXAlignment   = Enum.TextXAlignment.Left
            Box.ClearTextOnFocus = cfg2.ClearOnFocus ~= false
            Box.Parent           = row

            local Underline = Instance.new("Frame")
            Underline.Size             = UDim2.new(1, -24, 0, 1)
            Underline.Position         = UDim2.new(0, 12, 1, -1)
            Underline.BackgroundColor3 = Colors.Border
            Underline.BorderSizePixel  = 0
            Underline.Parent           = row

            Box.Focused:Connect(function()
                Tween(Underline, { BackgroundColor3 = Colors.Accent })
            end)
            Box.FocusLost:Connect(function(enter)
                Tween(Underline, { BackgroundColor3 = Colors.Border })
                if cfg2.Callback then
                    task.spawn(cfg2.Callback, Box.Text, enter)
                end
            end)

            local ctrl = {}
            function ctrl:Get() return Box.Text end
            function ctrl:Set(v) Box.Text = v end
            return ctrl
        end

        -- ── Color display label ─────────────────────────────────────────────
        function tab:AddLabel(text, color)
            local row = Instance.new("Frame")
            row.Size             = UDim2.new(1, 0, 0, 28)
            row.BackgroundTransparency = 1
            row.LayoutOrder      = 9999
            row.Parent           = Page
            local lbl = MakeLabel(row, text or "", 13, color or Colors.TextSecondary)
            lbl.Size     = UDim2.new(1, -8, 1, 0)
            lbl.Position = UDim2.new(0, 8, 0, 0)
            return lbl
        end

        -- ── Keybind ─────────────────────────────────────────────────────────
        function tab:AddKeybind(cfg2)
            cfg2 = cfg2 or {}
            local row     = NewRow(36)
            local current = cfg2.Default or Enum.KeyCode.Unknown
            local binding = false

            local nameLbl = MakeLabel(row, cfg2.Text or "Keybind", 13, Colors.TextPrimary)
            nameLbl.Size     = UDim2.new(1, -110, 1, 0)
            nameLbl.Position = UDim2.new(0, 12, 0, 0)

            local KeyBtn = Instance.new("TextButton")
            KeyBtn.Size             = UDim2.new(0, 90, 0, 22)
            KeyBtn.Position         = UDim2.new(1, -100, 0.5, -11)
            KeyBtn.BackgroundColor3 = Colors.Elevated
            KeyBtn.Text             = tostring(current.Name)
            KeyBtn.TextColor3       = Colors.Accent
            KeyBtn.TextSize         = 12
            KeyBtn.Font             = Enum.Font.GothamBold
            KeyBtn.AutoButtonColor  = false
            KeyBtn.Parent           = row
            AddCorner(KeyBtn, 4)
            AddStroke(KeyBtn, Colors.Border, 1)

            KeyBtn.MouseButton1Click:Connect(function()
                binding         = true
                KeyBtn.Text     = "..."
                KeyBtn.TextColor3 = Colors.Warning
            end)

            game:GetService("UserInputService").InputBegan:Connect(function(inp, gp)
                if binding and not gp and inp.UserInputType == Enum.UserInputType.Keyboard then
                    binding         = false
                    current         = inp.KeyCode
                    KeyBtn.Text     = inp.KeyCode.Name
                    KeyBtn.TextColor3 = Colors.Accent
                    if cfg2.Callback then task.spawn(cfg2.Callback, inp.KeyCode) end
                end
            end)

            local ctrl = {}
            function ctrl:Get() return current end
            return ctrl
        end

        return tab
    end

    -- ── Notification (static method on window) ───────────────────────────────
    function win:Notify(cfg2)
        cfg2 = cfg2 or {}
        local nTitle   = cfg2.Title   or "Notification"
        local nDesc    = cfg2.Description or ""
        local nDur     = cfg2.Duration or 3
        local nType    = cfg2.Type    or "info"  -- info / success / warning / danger

        local typeColor = ({
            info    = Colors.Accent,
            success = Colors.Success,
            warning = Colors.Warning,
            danger  = Colors.Danger,
        })[nType] or Colors.Accent

        local nSg = GetScreenGui()
        local nW, nH = 280, 64 + (nDesc ~= "" and 18 or 0)

        local nFrame = Instance.new("Frame")
        nFrame.Size             = UDim2.new(0, nW, 0, 0)
        nFrame.Position         = UDim2.new(1, -(nW + 16), 1, -16 - nH)
        nFrame.BackgroundColor3 = Colors.Surface
        nFrame.BorderSizePixel  = 0
        nFrame.ClipsDescendants = true
        nFrame.Parent           = nSg
        AddCorner(nFrame, 8)
        AddStroke(nFrame, Colors.Border, 1)

        local bar = Instance.new("Frame")
        bar.Size             = UDim2.new(0, 3, 1, -16)
        bar.Position         = UDim2.new(0, 10, 0, 8)
        bar.BackgroundColor3 = typeColor
        bar.BorderSizePixel  = 0
        bar.Parent           = nFrame
        AddCorner(bar, 2)

        local tLbl = MakeLabel(nFrame, nTitle, 13, Colors.TextPrimary, true)
        tLbl.Size     = UDim2.new(1, -30, 0, 16)
        tLbl.Position = UDim2.new(0, 22, 0, 12)

        if nDesc ~= "" then
            local dLbl = MakeLabel(nFrame, nDesc, 11, Colors.TextSecondary)
            dLbl.Size     = UDim2.new(1, -30, 0, 14)
            dLbl.Position = UDim2.new(0, 22, 0, 30)
        end

        -- Progress bar
        local prog = Instance.new("Frame")
        prog.Size             = UDim2.new(1, 0, 0, 2)
        prog.Position         = UDim2.new(0, 0, 1, -2)
        prog.BackgroundColor3 = typeColor
        prog.BorderSizePixel  = 0
        prog.Parent           = nFrame

        -- Slide in
        Tween(nFrame, { Size = UDim2.new(0, nW, 0, nH) }, 0.25)
        task.delay(0.05, function()
            Tween(prog, { Size = UDim2.new(0, 0, 0, 2) }, nDur, Enum.EasingStyle.Linear)
        end)

        task.delay(nDur + 0.05, function()
            Tween(nFrame, { Size = UDim2.new(0, nW, 0, 0),
                            Position = UDim2.new(1, -(nW + 16) + nW + 20,
                                                  1, -16 - nH) }, 0.2)
            task.delay(0.2, function() nFrame:Destroy() end)
        end)
    end

    -- ── SetTitle ─────────────────────────────────────────────────────────────
    function win:SetTitle(t)
        TitleLbl.Text = t
    end

    -- ── Destroy ──────────────────────────────────────────────────────────────
    function win:Destroy()
        Main:Destroy()
    end

    return win
end

return DarkUI
