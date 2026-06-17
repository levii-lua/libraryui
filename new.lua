-- ╔══════════════════════════════════════════════════════════╗
-- ║   FLUX UI LIBRARY  v3.0  —  Blue · Black · White        ║
-- ║   Premium animations · Lucide icons · Full component set ║
-- ╚══════════════════════════════════════════════════════════╝
--
-- Upload Lucide PNGs → paste asset IDs in the Icons table.
-- Reference: https://lucide.dev/icons

local FluxLib   = {}
FluxLib.__index = FluxLib

-- ─────────────────────────────────────────────────────────
--  SERVICES
-- ─────────────────────────────────────────────────────────
local TS  = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RS  = game:GetService("RunService")
local CG  = game:GetService("CoreGui")

-- ─────────────────────────────────────────────────────────
--  LUCIDE ASSET IDs  (replace with your uploaded PNGs)
-- ─────────────────────────────────────────────────────────
local Icons = {
    home        = "rbxassetid://11963537893",
    user        = "rbxassetid://11963538045",
    eye         = "rbxassetid://11963537721",
    settings    = "rbxassetid://11963537969",
    layout      = "rbxassetid://11963537801",
    zap         = "rbxassetid://11963538121",
    menu        = "rbxassetid://11963537845",
    minus       = "rbxassetid://11963537869",
    x           = "rbxassetid://11963538097",
    chevronDown = "rbxassetid://11963537649",
    check       = "rbxassetid://11963537625",
    palette     = "rbxassetid://11963537921",
    keyboard    = "rbxassetid://11963537777",
    refresh     = "rbxassetid://11963537945",
    shield      = "rbxassetid://11963537993",
    scan        = "rbxassetid://11963537969",
    highlight   = "rbxassetid://11963537745",
    bucket      = "rbxassetid://11963537897",
    mouse       = "rbxassetid://11963537893",
    bolt        = "rbxassetid://11963538121",
    info        = "rbxassetid://11963537769",
}

-- ─────────────────────────────────────────────────────────
--  THEME  —  Electric Blue · Near-Black · White Lines
-- ─────────────────────────────────────────────────────────
local T = {
    BgDeep      = Color3.fromRGB(8,  10, 18),
    BgPanel     = Color3.fromRGB(12, 15, 26),
    BgSidebar   = Color3.fromRGB(10, 13, 22),
    BgCard      = Color3.fromRGB(16, 20, 34),
    BgCardHov   = Color3.fromRGB(22, 28, 46),
    BgInput     = Color3.fromRGB(14, 18, 30),

    Blue        = Color3.fromRGB(50,  130, 255),
    BlueBright  = Color3.fromRGB(80,  160, 255),
    BlueDim     = Color3.fromRGB(30,  80,  180),
    BlueGlow    = Color3.fromRGB(120, 190, 255),
    BlueDark    = Color3.fromRGB(18,  45,  110),
    Cyan        = Color3.fromRGB(0,   210, 255),
    CyanDim     = Color3.fromRGB(0,   140, 190),

    Border      = Color3.fromRGB(28,  48,  88),
    BorderHi    = Color3.fromRGB(50,  130, 255),
    BorderWhite = Color3.fromRGB(200, 220, 255),

    TextHi      = Color3.fromRGB(240, 245, 255),
    TextMid     = Color3.fromRGB(150, 175, 220),
    TextLow     = Color3.fromRGB(65,  90,  145),
    TextBlue    = Color3.fromRGB(80,  160, 255),

    ToggleOff   = Color3.fromRGB(22,  28,  55),

    RadLg  = UDim.new(0, 14),
    RadMd  = UDim.new(0, 9),
    RadSm  = UDim.new(0, 5),
    RadPill= UDim.new(1, 0),
}

-- ─────────────────────────────────────────────────────────
--  ANIMATION HELPERS
-- ─────────────────────────────────────────────────────────
local function tw(obj, props, dur, style, dir)
    TS:Create(obj, TweenInfo.new(
        dur   or 0.18,
        style or Enum.EasingStyle.Quint,
        dir   or Enum.EasingDirection.Out
    ), props):Play()
end

local function spring(obj, props, dur)
    tw(obj, props, dur or 0.45, Enum.EasingStyle.Spring, Enum.EasingDirection.Out)
end

local function ripple(parent, mx, my)
    local rip = Instance.new("Frame")
    rip.AnchorPoint = Vector2.new(0.5, 0.5)
    rip.Size = UDim2.new(0, 0, 0, 0)
    rip.Position = UDim2.new(0, mx - parent.AbsolutePosition.X,
                               0, my - parent.AbsolutePosition.Y)
    rip.BackgroundColor3 = T.BorderWhite
    rip.BackgroundTransparency = 0.65
    rip.BorderSizePixel = 0
    rip.ZIndex = 20
    rip.Parent = parent
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1,0); c.Parent = rip
    local sz = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2.6
    tw(rip, {Size=UDim2.new(0,sz,0,sz), BackgroundTransparency=1}, 0.5, Enum.EasingStyle.Quart)
    game:GetService("Debris"):AddItem(rip, 0.55)
end

-- Scrolling shimmer highlight
local function shimmer(parent, zIdx)
    local clip = Instance.new("Frame")
    clip.Size = UDim2.new(1,0,1,0)
    clip.BackgroundTransparency = 1
    clip.ClipsDescendants = true
    clip.ZIndex = zIdx or 5
    clip.Parent = parent

    local strip = Instance.new("Frame")
    strip.Size = UDim2.new(0.28,0,1,0)
    strip.Position = UDim2.new(-0.32,0,0,0)
    strip.BackgroundColor3 = Color3.new(1,1,1)
    strip.BackgroundTransparency = 0.87
    strip.BorderSizePixel = 0
    strip.ZIndex = zIdx or 5
    strip.Parent = clip

    local grad = Instance.new("UIGradient")
    grad.Rotation = 18
    grad.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0,  1),
        NumberSequenceKeypoint.new(0.35, 0),
        NumberSequenceKeypoint.new(0.65, 0),
        NumberSequenceKeypoint.new(1,  1),
    }
    grad.Parent = strip

    task.spawn(function()
        while clip.Parent do
            tw(strip, {Position=UDim2.new(1.08,0,0,0)}, 1.3, Enum.EasingStyle.Sine)
            task.wait(1.4)
            strip.Position = UDim2.new(-0.32,0,0,0)
            task.wait(3.8)
        end
    end)
    return clip
end

-- Pulsing glow border
local function pulseStroke(fr, baseCol, glowCol, speed)
    local s  = Instance.new("UIStroke")
    s.Color  = baseCol or T.Border
    s.Thickness = 1.5
    s.Parent = fr
    local t0 = 0
    RS.Heartbeat:Connect(function(dt)
        if not s.Parent then return end
        t0 = t0 + dt * (speed or 1.1)
        local a = (math.sin(t0) + 1) * 0.5
        s.Color = (baseCol or T.Border):Lerp(glowCol or T.Blue, a * 0.55)
    end)
    return s
end

-- ─────────────────────────────────────────────────────────
--  BASE FACTORIES
-- ─────────────────────────────────────────────────────────
local function mkFrame(p)
    local f = Instance.new("Frame")
    f.BackgroundColor3       = p.color or T.BgPanel
    f.BackgroundTransparency = p.trans or 0
    f.BorderSizePixel        = 0
    f.Size                   = p.size  or UDim2.new(1,0,0,40)
    f.Position               = p.pos   or UDim2.new(0,0,0,0)
    f.ClipsDescendants       = p.clip  or false
    f.Name                   = p.name  or "Frame"
    f.ZIndex                 = p.z     or 1
    f.Parent                 = p.parent
    return f
end

local function mkLabel(p)
    local l = Instance.new("TextLabel")
    l.Text              = p.text   or ""
    l.TextSize          = p.size   or 13
    l.TextColor3        = p.color  or T.TextHi
    l.Font              = p.bold and Enum.Font.GothamBold or Enum.Font.Gotham
    l.BackgroundTransparency = 1
    l.TextXAlignment    = p.align  or Enum.TextXAlignment.Left
    l.TextYAlignment    = p.valign or Enum.TextYAlignment.Center
    l.TextTruncate      = Enum.TextTruncate.AtEnd
    l.Size              = p.sizeU  or UDim2.new(1,0,1,0)
    l.Position          = p.posU   or UDim2.new(0,0,0,0)
    l.ZIndex            = p.z      or 2
    l.Name              = p.name   or "Label"
    l.Parent            = p.parent
    return l
end

local function mkIcon(p)
    local i = Instance.new("ImageLabel")
    i.Image             = p.id    or ""
    i.ImageColor3       = p.color or T.TextMid
    i.BackgroundTransparency = 1
    i.ScaleType         = Enum.ScaleType.Fit
    i.Size              = p.sizeU or UDim2.new(0,16,0,16)
    i.Position          = p.posU  or UDim2.new(0,0,0.5,-8)
    i.ZIndex            = p.z     or 3
    i.Name              = p.name  or "Icon"
    i.Parent            = p.parent
    return i
end

local function mkBtn(parent, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,1,0)
    b.BackgroundTransparency = 1
    b.Text   = ""
    b.ZIndex = 12
    b.Parent = parent
    if cb then b.MouseButton1Click:Connect(cb) end
    return b
end

local function mkCorner(p, r)
    local c = Instance.new("UICorner"); c.CornerRadius = r or T.RadMd; c.Parent = p; return c
end

local function mkStroke(p, col, thick, trans)
    local s = Instance.new("UIStroke")
    s.Color       = col   or T.Border
    s.Thickness   = thick or 1
    s.Transparency= trans or 0
    s.Parent      = p
    return s
end

local function mkPad(p, t, b, l, r)
    local pd = Instance.new("UIPadding")
    pd.PaddingTop    = UDim.new(0, t or 0)
    pd.PaddingBottom = UDim.new(0, b or 0)
    pd.PaddingLeft   = UDim.new(0, l or 0)
    pd.PaddingRight  = UDim.new(0, r or 0)
    pd.Parent = p
end

local function mkList(p, dir, gap)
    local l = Instance.new("UIListLayout")
    l.FillDirection = dir or Enum.FillDirection.Vertical
    l.SortOrder     = Enum.SortOrder.LayoutOrder
    l.Padding       = UDim.new(0, gap or 0)
    l.Parent        = p
    return l
end

-- ─────────────────────────────────────────────────────────
--  WINDOW
-- ─────────────────────────────────────────────────────────
function FluxLib.new(config)
    config = config or {}
    local self      = setmetatable({}, FluxLib)
    self._tabs      = {}
    self._activeTab = nil
    self._open      = true

    local sg = Instance.new("ScreenGui")
    sg.Name           = "FluxUI_v3"
    sg.ResetOnSpawn   = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.IgnoreGuiInset = true
    sg.Parent         = CG
    self._gui         = sg

    -- ── Toggle Icon ───────────────────────────────────
    local togHolder = mkFrame{
        name="ToggleBtn", color=T.BgCard,
        size=UDim2.new(0,52,0,52), pos=UDim2.new(0,22,0.5,-26),
        parent=sg
    }
    mkCorner(togHolder, T.RadMd)
    mkStroke(togHolder, T.Border, 1.5)
    mkIcon{id=Icons.menu, color=T.TextHi,
           sizeU=UDim2.new(0,22,0,22), posU=UDim2.new(0.5,-11,0.5,-11), z=4, parent=togHolder}

    -- Pulse ring
    local pulse = mkFrame{color=T.Blue, trans=1,
                           size=UDim2.new(1,0,1,0), pos=UDim2.new(0,0,0,0), parent=togHolder}
    mkCorner(pulse, T.RadMd)
    task.spawn(function()
        while togHolder.Parent do
            tw(pulse, {BackgroundTransparency=0.72, Size=UDim2.new(1,12,1,12), Position=UDim2.new(0,-6,0,-6)}, 0.55, Enum.EasingStyle.Sine)
            task.wait(0.6)
            tw(pulse, {BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Position=UDim2.new(0,0,0,0)}, 0.5, Enum.EasingStyle.Sine)
            task.wait(2.2)
        end
    end)

    -- ── Main Window ───────────────────────────────────
    local win = mkFrame{
        name="Window", color=T.BgDeep,
        size=UDim2.new(0,620,0,430),
        pos=UDim2.new(0.5,-310,0.5,-215),
        clip=true, parent=sg
    }
    mkCorner(win, T.RadLg)
    pulseStroke(win, T.Border, T.Blue, 1.0)
    self._win = win

    -- Spawn scale-up animation
    win.Size     = UDim2.new(0,0,0,0)
    win.Position = UDim2.new(0.5,0,0.5,0)
    win.BackgroundTransparency = 1
    task.defer(function()
        spring(win, {Size=UDim2.new(0,620,0,430), Position=UDim2.new(0.5,-310,0.5,-215), BackgroundTransparency=0}, 0.6)
    end)

    -- ── Title Bar ─────────────────────────────────────
    local titleBar = mkFrame{
        name="TitleBar", color=T.BgPanel,
        size=UDim2.new(1,0,0,50), pos=UDim2.new(0,0,0,0), z=2, parent=win
    }
    -- White hairline under titlebar
    mkFrame{color=T.BorderWhite, trans=0.78,
            size=UDim2.new(1,0,0,1), pos=UDim2.new(0,0,1,-1), z=5, parent=titleBar}
    shimmer(titleBar, 4)

    -- Logo badge
    local badge = mkFrame{color=T.Blue, size=UDim2.new(0,32,0,32), pos=UDim2.new(0,14,0.5,-16), z=3, parent=titleBar}
    mkCorner(badge, T.RadSm)
    mkIcon{id=Icons.bolt, color=T.TextHi, sizeU=UDim2.new(0,17,0,17), posU=UDim2.new(0.5,-8,0.5,-8), z=4, parent=badge}
    -- Cyan pulsing dot on badge
    local dot = mkFrame{color=T.Cyan, size=UDim2.new(0,7,0,7), pos=UDim2.new(1,-3,0,-3), z=6, parent=badge}
    mkCorner(dot, UDim.new(1,0))
    task.spawn(function()
        while dot.Parent do
            tw(dot,{BackgroundTransparency=0.25, Size=UDim2.new(0,9,0,9), Position=UDim2.new(1,-4,0,-4)},0.5,Enum.EasingStyle.Sine)
            task.wait(0.55)
            tw(dot,{BackgroundTransparency=0, Size=UDim2.new(0,7,0,7), Position=UDim2.new(1,-3,0,-3)},0.5,Enum.EasingStyle.Sine)
            task.wait(0.55)
        end
    end)

    mkLabel{text=config.Title or "Flux UI Library", bold=true, size=15,
            sizeU=UDim2.new(1,-130,1,0), posU=UDim2.new(0,54,0,0),
            color=T.TextHi, z=3, parent=titleBar}

    -- Minimize
    local minBox = mkFrame{color=T.BgCard, size=UDim2.new(0,28,0,28), pos=UDim2.new(1,-70,0.5,-14), z=3, parent=titleBar}
    mkCorner(minBox, T.RadSm); mkStroke(minBox, T.Border, 1)
    mkIcon{id=Icons.minus, color=T.TextMid, sizeU=UDim2.new(0,12,0,12), posU=UDim2.new(0.5,-6,0.5,-6), z=4, parent=minBox}

    -- Close
    local closeBox = mkFrame{color=T.Blue, size=UDim2.new(0,28,0,28), pos=UDim2.new(1,-34,0.5,-14), z=3, parent=titleBar}
    mkCorner(closeBox, T.RadSm)
    mkIcon{id=Icons.x, color=T.TextHi, sizeU=UDim2.new(0,12,0,12), posU=UDim2.new(0.5,-6,0.5,-6), z=4, parent=closeBox}

    -- ── Sidebar ───────────────────────────────────────
    local sidebar = mkFrame{
        name="Sidebar", color=T.BgSidebar,
        size=UDim2.new(0,138,1,-51), pos=UDim2.new(0,0,0,51), z=2, parent=win
    }
    mkPad(sidebar,10,10,8,8)
    mkList(sidebar, Enum.FillDirection.Vertical, 3)
    self._sidebar = sidebar

    -- White hairline divider
    mkFrame{color=T.BorderWhite, trans=0.82,
            size=UDim2.new(0,1,1,-51), pos=UDim2.new(0,138,0,51), z=3, parent=win}

    -- ── Content area ──────────────────────────────────
    local content = mkFrame{
        name="Content", color=T.BgPanel, trans=1,
        size=UDim2.new(1,-146,1,-59), pos=UDim2.new(0,146,0,59),
        clip=true, parent=win
    }
    self._content = content

    -- ── Toggle button wiring ──────────────────────────
    local minimized = false
    mkBtn(togHolder, function()
        self._open = not self._open
        if self._open then
            spring(win,{Size=UDim2.new(0,620,0,430), Position=UDim2.new(0.5,-310,0.5,-215), BackgroundTransparency=0},0.52)
        else
            tw(win,{Size=UDim2.new(0,0,0,0), Position=UDim2.new(0.5,0,0.5,0), BackgroundTransparency=1},0.28)
        end
    end)

    -- Minimize
    mkBtn(minBox, function()
        minimized = not minimized
        if minimized then
            tw(win,{Size=UDim2.new(0,620,0,50)},0.25)
        else
            spring(win,{Size=UDim2.new(0,620,0,430)},0.48)
        end
    end)
    local mhb = minBox:FindFirstChildOfClass("TextButton")
    if mhb then
        mhb.MouseEnter:Connect(function() tw(minBox,{BackgroundColor3=T.BgCardHov},0.12) end)
        mhb.MouseLeave:Connect(function() tw(minBox,{BackgroundColor3=T.BgCard},0.12) end)
    end

    -- Close
    mkBtn(closeBox, function()
        tw(win,{Size=UDim2.new(0,0,0,0), Position=UDim2.new(0.5,0,0.5,0), BackgroundTransparency=1},0.26)
        task.delay(0.3, function() sg:Destroy() end)
    end)
    local chb = closeBox:FindFirstChildOfClass("TextButton")
    if chb then
        chb.MouseEnter:Connect(function() tw(closeBox,{BackgroundColor3=T.BlueBright},0.12) end)
        chb.MouseLeave:Connect(function() tw(closeBox,{BackgroundColor3=T.Blue},0.12) end)
    end

    -- ── Drag ─────────────────────────────────────────
    local dragging, dragStart, winStart
    titleBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging=true; dragStart=inp.Position; winStart=win.Position
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType==Enum.UserInputType.MouseMovement then
            local d = inp.Position - dragStart
            win.Position = UDim2.new(winStart.X.Scale, winStart.X.Offset+d.X,
                                     winStart.Y.Scale, winStart.Y.Offset+d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
    end)

    return self
end

-- ─────────────────────────────────────────────────────────
--  TAB SYSTEM
-- ─────────────────────────────────────────────────────────
local TICON = {Main="home",Player="user",Visuals="eye",Settings="settings",Misc="layout"}

function FluxLib:addTab(name)
    local isFirst = next(self._tabs) == nil
    local iconId  = Icons[TICON[name] or "layout"]

    -- Sidebar button
    local sbBtn = mkFrame{
        name="Tab_"..name, color=T.Blue,
        size=UDim2.new(1,0,0,36),
        trans=isFirst and 0.8 or 1,
        parent=self._sidebar
    }
    mkCorner(sbBtn, T.RadMd)

    -- Cyan left-edge indicator
    local ind = mkFrame{color=T.Cyan, size=UDim2.new(0,3,0.55,0),
                         pos=UDim2.new(0,0,0.225,0), parent=sbBtn}
    mkCorner(ind, UDim.new(1,0))
    ind.Visible = isFirst

    mkIcon{id=iconId, color=isFirst and T.BlueGlow or T.TextLow,
           sizeU=UDim2.new(0,15,0,15), posU=UDim2.new(0,11,0.5,-7), z=3, parent=sbBtn}
    mkLabel{text=name, size=12, bold=isFirst,
            color=isFirst and T.TextHi or T.TextMid,
            sizeU=UDim2.new(1,-32,1,0), posU=UDim2.new(0,31,0,0), z=3, parent=sbBtn}

    -- Content page
    local page = Instance.new("ScrollingFrame")
    page.Name="Page_"..name
    page.Size=UDim2.new(1,0,1,0)
    page.BackgroundTransparency=1
    page.BorderSizePixel=0
    page.ScrollBarThickness=2
    page.ScrollBarImageColor3=T.Blue
    page.CanvasSize=UDim2.new(0,0,0,0)
    page.AutomaticCanvasSize=Enum.AutomaticSize.Y
    page.Visible=isFirst
    page.Parent=self._content
    mkPad(page,16,16,14,14)
    mkList(page,Enum.FillDirection.Vertical,7)

    -- Page heading
    local heading = mkFrame{color=T.BgPanel, trans=1, size=UDim2.new(1,0,0,40), parent=page}
    mkIcon{id=iconId, color=T.Blue, sizeU=UDim2.new(0,20,0,20), posU=UDim2.new(0,0,0.5,-10), z=3, parent=heading}
    mkLabel{text=name, bold=true, size=21, color=T.TextHi,
            sizeU=UDim2.new(1,-30,1,0), posU=UDim2.new(0,28,0,0), z=3, parent=heading}
    -- Blue underline
    local uline = mkFrame{color=T.Blue, size=UDim2.new(0,0,0,2), pos=UDim2.new(0,28,1,-1), parent=heading}
    mkCorner(uline, UDim.new(1,0))
    task.defer(function()
        tw(uline,{Size=UDim2.new(0,34,0,2)},0.4,Enum.EasingStyle.Quint)
    end)

    local tabData = {name=name, btn=sbBtn, page=page, ind=ind}
    self._tabs[name] = tabData
    if isFirst then self._activeTab = name end

    local b = mkBtn(sbBtn, function() self:selectTab(name) end)
    b.MouseButton1Down:Connect(function(mx,my) ripple(sbBtn,mx,my) end)
    b.MouseEnter:Connect(function()
        if self._activeTab~=name then tw(sbBtn,{BackgroundTransparency=0.88},0.12) end
    end)
    b.MouseLeave:Connect(function()
        if self._activeTab~=name then tw(sbBtn,{BackgroundTransparency=1},0.12) end
    end)

    return tabData
end

function FluxLib:selectTab(name)
    if not self._tabs[name] then return end
    if self._activeTab and self._tabs[self._activeTab] then
        local old = self._tabs[self._activeTab]
        old.page.Visible = false
        old.ind.Visible  = false
        tw(old.btn,{BackgroundTransparency=1},0.18)
        local oi = old.btn:FindFirstChild("Icon")
        local ol = old.btn:FindFirstChild("Label")
        if oi then tw(oi,{ImageColor3=T.TextLow},0.18) end
        if ol then ol.Font=Enum.Font.Gotham; tw(ol,{TextColor3=T.TextMid},0.18) end
    end
    local tab = self._tabs[name]
    -- Slide in from right
    tab.page.Position = UDim2.new(0.06,0,0,0)
    tab.page.Visible  = true
    spring(tab.page,{Position=UDim2.new(0,0,0,0)},0.42)

    tab.ind.Visible  = true
    tw(tab.btn,{BackgroundTransparency=0.80},0.18)
    local ni = tab.btn:FindFirstChild("Icon")
    local nl = tab.btn:FindFirstChild("Label")
    if ni then tw(ni,{ImageColor3=T.BlueGlow},0.18) end
    if nl then nl.Font=Enum.Font.GothamBold; tw(nl,{TextColor3=T.TextHi},0.18) end
    self._activeTab = name
end

-- ─────────────────────────────────────────────────────────
--  COMPONENTS
-- ─────────────────────────────────────────────────────────

function FluxLib:addDescription(tabName, title, body)
    local page = self._tabs[tabName] and self._tabs[tabName].page; if not page then return end
    local h = mkFrame{color=T.BgPanel,trans=1,size=UDim2.new(1,0,0,56),parent=page}
    mkLabel{text=title or "Welcome!", bold=true, size=18, color=T.TextHi,
            sizeU=UDim2.new(1,0,0,26), posU=UDim2.new(0,0,0,0), parent=h}
    mkLabel{text=body or "", size=12, color=T.TextMid,
            sizeU=UDim2.new(1,0,0,30), posU=UDim2.new(0,0,0,26), parent=h}
end

function FluxLib:addSection(tabName, title)
    local page = self._tabs[tabName] and self._tabs[tabName].page; if not page then return end
    local sec = mkFrame{color=T.BgPanel,trans=1,size=UDim2.new(1,0,0,26),parent=page}
    mkLabel{text=(title or "Section"):upper(), bold=true, size=9, color=T.TextBlue,
            sizeU=UDim2.new(0.42,0,1,0), posU=UDim2.new(0,0,0,0), parent=sec}
    -- hairline right of label
    local line = mkFrame{color=T.BorderWhite, trans=0.82,
                          size=UDim2.new(0.56,0,0,1), pos=UDim2.new(0.44,0,0.5,0), parent=sec}
    mkCorner(line, UDim.new(1,0))
end

-- Full-width blue button
function FluxLib:addButton(tabName, config)
    config = config or {}
    local page = self._tabs[tabName] and self._tabs[tabName].page; if not page then return end

    local card = mkFrame{color=T.Blue, size=UDim2.new(1,0,0,44), parent=page}
    mkCorner(card, T.RadMd)
    local cs = mkStroke(card, T.BlueGlow, 1, 0.5)
    shimmer(card, 6)

    if config.icon then
        mkIcon{id=config.icon, color=T.TextHi, sizeU=UDim2.new(0,16,0,16), posU=UDim2.new(0,14,0.5,-8), z=4, parent=card}
    end
    mkLabel{text=config.Title or "Click Me", bold=true, size=13,
            color=T.TextHi, align=Enum.TextXAlignment.Center,
            sizeU=UDim2.new(1,0,1,0), z=3, parent=card}

    local b = mkBtn(card, function()
        tw(card,{BackgroundColor3=T.BlueBright},0.07)
        task.delay(0.18, function() tw(card,{BackgroundColor3=T.Blue},0.18) end)
        if config.Callback then config.Callback() end
    end)
    b.MouseButton1Down:Connect(function(mx,my) ripple(card,mx,my) end)
    b.MouseEnter:Connect(function()
        tw(card,{BackgroundColor3=T.BlueBright},0.14)
        tw(cs,{Transparency=0},0.14)
    end)
    b.MouseLeave:Connect(function()
        tw(card,{BackgroundColor3=T.Blue},0.14)
        tw(cs,{Transparency=0.5},0.14)
    end)
    return card
end

-- Toggle row
function FluxLib:addToggle(tabName, config)
    config = config or {}
    local page = self._tabs[tabName] and self._tabs[tabName].page; if not page then return end
    local state = config.Default ~= nil and config.Default or false

    local row = mkFrame{color=T.BgCard, size=UDim2.new(1,0,0,48), parent=page}
    mkCorner(row, T.RadMd)
    local rs = mkStroke(row, T.Border, 1)
    mkPad(row,0,0,14,14)

    mkLabel{text=config.Title or "Toggle", size=13, color=T.TextHi,
            sizeU=UDim2.new(1,-60,1,0), posU=UDim2.new(0,0,0,0), parent=row}

    -- Pill
    local pill = mkFrame{color=state and T.Blue or T.ToggleOff,
                          size=UDim2.new(0,48,0,25), pos=UDim2.new(1,-48,0.5,-12), parent=row}
    mkCorner(pill, T.RadPill)
    local ps = mkStroke(pill, state and T.BlueGlow or T.Border, 1)

    local knob = mkFrame{color=T.TextHi, size=UDim2.new(0,19,0,19),
                          pos=UDim2.new(0, state and 25 or 3, 0.5,-9), parent=pill}
    mkCorner(knob, T.RadPill)
    -- knob inner blue dot
    local kdot = mkFrame{color=T.Blue, trans=state and 0 or 1,
                          size=UDim2.new(0,7,0,7), pos=UDim2.new(0.5,-3,0.5,-3), parent=knob}
    mkCorner(kdot, UDim.new(1,0))

    local function refresh()
        tw(pill, {BackgroundColor3=state and T.Blue or T.ToggleOff}, 0.22)
        tw(knob, {Position=UDim2.new(0,state and 25 or 3,0.5,-9)}, 0.22)
        tw(kdot, {BackgroundTransparency=state and 0 or 1}, 0.22)
        tw(ps,   {Color=state and T.BlueGlow or T.Border}, 0.22)
        tw(rs,   {Color=state and T.Blue or T.Border}, 0.22)
        task.delay(0.5, function() if rs.Parent then tw(rs,{Color=T.Border},0.3) end end)
    end

    local b = mkBtn(row, function() state=not state; refresh(); if config.Callback then config.Callback(state) end end)
    b.MouseEnter:Connect(function() tw(row,{BackgroundColor3=T.BgCardHov},0.12) end)
    b.MouseLeave:Connect(function() tw(row,{BackgroundColor3=T.BgCard},0.12) end)

    return row, function() return state end
end

-- Slider
function FluxLib:addSlider(tabName, config)
    config = config or {}
    local page = self._tabs[tabName] and self._tabs[tabName].page; if not page then return end

    local minV = config.Min or 0; local maxV = config.Max or 100
    local val  = math.clamp(config.Default or 50, minV, maxV)

    local card = mkFrame{color=T.BgCard, size=UDim2.new(1,0,0,62), parent=page}
    mkCorner(card, T.RadMd)
    local cs = mkStroke(card, T.Border, 1)
    mkPad(card,0,0,14,14)

    mkLabel{text=config.Title or "Slider", size=13, color=T.TextHi,
            sizeU=UDim2.new(1,-54,0,20), posU=UDim2.new(0,0,0,10), parent=card}
    local valL = mkLabel{text=tostring(val), size=12, bold=true, color=T.TextBlue,
                          align=Enum.TextXAlignment.Right,
                          sizeU=UDim2.new(0,44,0,20), posU=UDim2.new(1,-44,0,10), parent=card}

    local track = mkFrame{color=T.ToggleOff, size=UDim2.new(1,0,0,5), pos=UDim2.new(0,0,0,42), parent=card}
    mkCorner(track, T.RadPill); mkStroke(track, T.Border, 1)

    local pct0 = (val-minV)/(maxV-minV)
    local fill = mkFrame{color=T.Blue, size=UDim2.new(pct0,0,1,0), parent=track}
    mkCorner(fill, T.RadPill)
    local fgrad = Instance.new("UIGradient")
    fgrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0,T.BlueDim),ColorSequenceKeypoint.new(1,T.BlueGlow)}
    fgrad.Parent = fill

    local thumb = mkFrame{color=T.TextHi, size=UDim2.new(0,15,0,15),
                           pos=UDim2.new(pct0,-7,0.5,-7), parent=track}
    mkCorner(thumb, T.RadPill)
    mkStroke(thumb, T.Blue, 2)
    -- Thumb glow ring
    local tring = mkFrame{color=T.Blue, trans=0.72, size=UDim2.new(1,8,1,8), pos=UDim2.new(0,-4,0,-4), parent=thumb}
    mkCorner(tring, T.RadPill)

    local sliding = false

    local function setV(inputPos)
        local a=track.AbsolutePosition; local s=track.AbsoluteSize
        local p=math.clamp((inputPos.X-a.X)/s.X, 0, 1)
        val=math.floor(minV+(maxV-minV)*p+0.5)
        valL.Text=tostring(val)
        fill.Size=UDim2.new(p,0,1,0)
        thumb.Position=UDim2.new(p,-7,0.5,-7)
        if config.Callback then config.Callback(val) end
    end

    local tb = mkBtn(thumb); tb.ZIndex=15
    tb.MouseButton1Down:Connect(function()
        sliding=true
        tw(thumb,{Size=UDim2.new(0,18,0,18)},0.12)
        tw(tring,{BackgroundTransparency=0.42},0.15)
        tw(cs,{Color=T.Blue},0.15)
    end)
    local tkb = Instance.new("TextButton")
    tkb.Size=UDim2.new(1,0,7,0); tkb.Position=UDim2.new(0,0,-3,0)
    tkb.BackgroundTransparency=1; tkb.Text=""; tkb.ZIndex=10; tkb.Parent=track
    tkb.MouseButton1Down:Connect(function(x,y) sliding=true; setV(Vector2.new(x,y)) end)

    UIS.InputChanged:Connect(function(inp)
        if sliding and inp.UserInputType==Enum.UserInputType.MouseMovement then setV(inp.Position) end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 and sliding then
            sliding=false
            tw(thumb,{Size=UDim2.new(0,15,0,15)},0.15)
            tw(tring,{BackgroundTransparency=0.72},0.2)
            tw(cs,{Color=T.Border},0.3)
        end
    end)

    return card, function() return val end
end

-- Color picker swatch
function FluxLib:addColorPicker(tabName, config)
    config = config or {}
    local page = self._tabs[tabName] and self._tabs[tabName].page; if not page then return end
    local color = config.Default or T.Blue

    local row = mkFrame{color=T.BgCard, size=UDim2.new(1,0,0,48), parent=page}
    mkCorner(row, T.RadMd); mkStroke(row, T.Border, 1); mkPad(row,0,0,14,14)

    mkLabel{text=config.Title or "Color", size=13, color=T.TextHi,
            sizeU=UDim2.new(1,-52,1,0), posU=UDim2.new(0,0,0,0), parent=row}

    local swatch = mkFrame{color=color, size=UDim2.new(0,30,0,30), pos=UDim2.new(1,-30,0.5,-15), parent=row}
    mkCorner(swatch, T.RadSm); mkStroke(swatch, T.BorderWhite, 1.5)

    local b = mkBtn(row, function()
        tw(swatch,{Size=UDim2.new(0,34,0,34), Position=UDim2.new(1,-34,0.5,-17)},0.1)
        task.delay(0.14, function() tw(swatch,{Size=UDim2.new(0,30,0,30), Position=UDim2.new(1,-30,0.5,-15)},0.16) end)
        if config.Callback then config.Callback(color) end
    end)
    b.MouseEnter:Connect(function() tw(row,{BackgroundColor3=T.BgCardHov},0.12) end)
    b.MouseLeave:Connect(function() tw(row,{BackgroundColor3=T.BgCard},0.12) end)

    return row, function() return color end
end

-- Dropdown
function FluxLib:addDropdown(tabName, config)
    config = config or {}
    local page = self._tabs[tabName] and self._tabs[tabName].page; if not page then return end

    local opts=config.Options or {"Option 1"}; local sel=config.Default or opts[1]; local open=false

    local wrapper=mkFrame{color=T.BgPanel,trans=1,size=UDim2.new(1,0,0,48),parent=page}
    local row=mkFrame{color=T.BgCard,size=UDim2.new(1,0,0,48),parent=wrapper}
    mkCorner(row,T.RadMd); local rs=mkStroke(row,T.Border,1); mkPad(row,0,0,14,14)

    mkLabel{text=config.Title or "Dropdown", size=13, color=T.TextHi,
            sizeU=UDim2.new(0.48,0,1,0), posU=UDim2.new(0,0,0,0), parent=row}
    local selLbl=mkLabel{text=sel, size=12, color=T.TextBlue,
                          align=Enum.TextXAlignment.Right,
                          sizeU=UDim2.new(0.36,0,1,0), posU=UDim2.new(0.5,-14,0,0), parent=row}
    local chev=mkIcon{id=Icons.chevronDown, color=T.TextLow,
                       sizeU=UDim2.new(0,13,0,13), posU=UDim2.new(1,-13,0.5,-6), z=3, parent=row}

    local dlist=mkFrame{color=T.BgInput, size=UDim2.new(1,0,0,0), pos=UDim2.new(0,0,0,50), clip=true, parent=wrapper}
    mkCorner(dlist,T.RadMd); mkStroke(dlist,T.Border,1); mkList(dlist,Enum.FillDirection.Vertical,0)

    for _,opt in ipairs(opts) do
        local orow=mkFrame{color=T.BgInput,trans=1,size=UDim2.new(1,0,0,34),parent=dlist}
        mkLabel{text=opt, size=12, color=T.TextMid, sizeU=UDim2.new(1,0,1,0), posU=UDim2.new(0,14,0,0), parent=orow}
        mkFrame{color=T.Border, size=UDim2.new(1,-14,0,1), pos=UDim2.new(0,7,1,-1), parent=orow}
        local ob=mkBtn(orow, function()
            sel=opt; selLbl.Text=opt; open=false
            tw(dlist,{Size=UDim2.new(1,0,0,0)},0.18,Enum.EasingStyle.Quint)
            tw(wrapper,{Size=UDim2.new(1,0,0,48)},0.18,Enum.EasingStyle.Quint)
            tw(chev,{Rotation=0},0.18); tw(rs,{Color=T.Border},0.2)
            if config.Callback then config.Callback(sel) end
        end)
        ob.MouseEnter:Connect(function() tw(orow,{BackgroundTransparency=0.84},0.1) end)
        ob.MouseLeave:Connect(function() tw(orow,{BackgroundTransparency=1},0.1) end)
    end

    local rb=mkBtn(row, function()
        open=not open
        local h=open and (34*#opts) or 0
        tw(dlist,{Size=UDim2.new(1,0,0,h)},0.2,Enum.EasingStyle.Quint)
        tw(wrapper,{Size=UDim2.new(1,0,0,48+h)},0.2,Enum.EasingStyle.Quint)
        tw(chev,{Rotation=open and 180 or 0},0.18)
        tw(rs,{Color=open and T.Blue or T.Border},0.18)
    end)
    rb.MouseEnter:Connect(function() tw(row,{BackgroundColor3=T.BgCardHov},0.12) end)
    rb.MouseLeave:Connect(function() tw(row,{BackgroundColor3=T.BgCard},0.12) end)

    return wrapper, function() return sel end
end

-- Keybind
function FluxLib:addKeybind(tabName, config)
    config = config or {}
    local page = self._tabs[tabName] and self._tabs[tabName].page; if not page then return end
    local key=config.Default or Enum.KeyCode.RightShift; local listening=false

    local row=mkFrame{color=T.BgCard,size=UDim2.new(1,0,0,48),parent=page}
    mkCorner(row,T.RadMd); local rs=mkStroke(row,T.Border,1); mkPad(row,0,0,14,14)

    mkLabel{text=config.Title or "Keybind", size=13, color=T.TextHi,
            sizeU=UDim2.new(1,-108,1,0), posU=UDim2.new(0,0,0,0), parent=row}

    local badge=mkFrame{color=T.BgInput,size=UDim2.new(0,92,0,28),pos=UDim2.new(1,-92,0.5,-14),parent=row}
    mkCorner(badge,T.RadSm); mkStroke(badge,T.Border,1)
    local kl=mkLabel{text=key.Name, size=11, bold=true, color=T.TextBlue,
                      align=Enum.TextXAlignment.Center, sizeU=UDim2.new(1,0,1,0), parent=badge}

    local b=mkBtn(row, function()
        if listening then return end
        listening=true; kl.Text="…"
        tw(badge,{BackgroundColor3=T.BlueDark},0.1)
        tw(rs,{Color=T.Blue},0.1)
        local conn
        conn=UIS.InputBegan:Connect(function(inp,gp)
            if gp then return end
            if inp.UserInputType==Enum.UserInputType.Keyboard then
                key=inp.KeyCode; kl.Text=key.Name
                tw(badge,{BackgroundColor3=T.BgInput},0.2)
                tw(rs,{Color=T.Border},0.25)
                listening=false; conn:Disconnect()
                if config.Callback then config.Callback(key) end
            end
        end)
    end)
    b.MouseEnter:Connect(function() tw(row,{BackgroundColor3=T.BgCardHov},0.12) end)
    b.MouseLeave:Connect(function() tw(row,{BackgroundColor3=T.BgCard},0.12) end)

    UIS.InputBegan:Connect(function(inp,gp)
        if not gp and inp.KeyCode==key and config.OnTrigger then config.OnTrigger() end
    end)
    return row, function() return key end
end

-- Action button (secondary)
function FluxLib:addActionButton(tabName, config)
    config = config or {}
    local page = self._tabs[tabName] and self._tabs[tabName].page; if not page then return end

    local card=mkFrame{color=T.BgInput,size=UDim2.new(1,0,0,42),parent=page}
    mkCorner(card,T.RadMd); local cs=mkStroke(card,T.Border,1)

    mkLabel{text=config.Title or "Action", size=13, color=T.TextMid,
            align=Enum.TextXAlignment.Center, sizeU=UDim2.new(1,0,1,0), z=3, parent=card}

    local b=mkBtn(card, function()
        tw(card,{BackgroundColor3=T.BlueDark},0.08)
        tw(cs,{Color=T.Blue},0.08)
        task.delay(0.22, function()
            tw(card,{BackgroundColor3=T.BgInput},0.2)
            tw(cs,{Color=T.Border},0.2)
        end)
        if config.Callback then config.Callback() end
    end)
    b.MouseButton1Down:Connect(function(mx,my) ripple(card,mx,my) end)
    b.MouseEnter:Connect(function() tw(card,{BackgroundColor3=T.BgCardHov},0.12); tw(cs,{Color=T.BlueDim},0.12) end)
    b.MouseLeave:Connect(function() tw(card,{BackgroundColor3=T.BgInput},0.12);  tw(cs,{Color=T.Border},0.12) end)

    return card
end

-- Info box
function FluxLib:addInfoBox(tabName, config)
    config = config or {}
    local page = self._tabs[tabName] and self._tabs[tabName].page; if not page then return end

    local card=mkFrame{color=T.BlueDark,size=UDim2.new(1,0,0,60),parent=page}
    mkCorner(card,T.RadMd); mkStroke(card,T.Blue,1.5)
    mkFrame{color=T.Cyan,size=UDim2.new(0,3,0.65,0),pos=UDim2.new(0,0,0.175,0),parent=card}

    local ib=mkFrame{color=T.Blue,size=UDim2.new(0,36,0,36),pos=UDim2.new(0,12,0.5,-18),parent=card}
    mkCorner(ib,T.RadSm)
    mkIcon{id=Icons.bolt, color=T.TextHi, sizeU=UDim2.new(0,18,0,18), posU=UDim2.new(0.5,-9,0.5,-9), z=4, parent=ib}

    mkLabel{text=config.Title or "Info", bold=true, size=13, color=T.TextHi,
            sizeU=UDim2.new(1,-62,0,20), posU=UDim2.new(0,56,0,12), parent=card}
    mkLabel{text=config.Description or "", size=11, color=T.TextMid,
            sizeU=UDim2.new(1,-62,0,16), posU=UDim2.new(0,56,0,34), parent=card}

    return card
end

-- ─────────────────────────────────────────────────────────
--  NOTIFICATION TOAST
-- ─────────────────────────────────────────────────────────
function FluxLib:notify(config)
    config = config or {}
    local nsg=Instance.new("ScreenGui")
    nsg.Name="FluxNotif"; nsg.ResetOnSpawn=false
    nsg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    nsg.IgnoreGuiInset=true; nsg.Parent=CG

    local toast=mkFrame{color=T.BgCard,size=UDim2.new(0,298,0,74),pos=UDim2.new(1,20,1,-96),parent=nsg}
    mkCorner(toast,T.RadMd); mkStroke(toast,T.Blue,1.5)

    -- Blue left bar
    local bar=mkFrame{color=T.Blue,size=UDim2.new(0,3,0.65,0),pos=UDim2.new(0,0,0.175,0),parent=toast}
    mkCorner(bar,T.RadPill)

    -- Cyan progress drain strip
    local prog=mkFrame{color=T.Cyan,size=UDim2.new(1,0,0,2),pos=UDim2.new(0,0,1,-2),parent=toast}
    mkCorner(prog,T.RadPill)

    shimmer(toast, 8)

    mkLabel{text=config.Title or "Notice", bold=true, size=13, color=T.TextHi,
            sizeU=UDim2.new(1,-20,0,22), posU=UDim2.new(0,14,0,14), parent=toast}
    mkLabel{text=config.Description or "", size=11, color=T.TextMid,
            sizeU=UDim2.new(1,-20,0,18), posU=UDim2.new(0,14,0,38), parent=toast}

    -- Slide in from right with spring
    spring(toast,{Position=UDim2.new(1,-314,1,-96)},0.48)

    local dur=config.Duration or 4
    tw(prog,{Size=UDim2.new(0,0,0,2)},dur-0.3,Enum.EasingStyle.Linear)

    mkBtn(toast, function()
        tw(toast,{Position=UDim2.new(1,20,1,-96), BackgroundTransparency=1},0.22)
        task.delay(0.26, function() nsg:Destroy() end)
    end)

    task.delay(dur, function()
        if toast.Parent then
            tw(toast,{Position=UDim2.new(1,20,1,-96), BackgroundTransparency=1},0.28)
            task.delay(0.32, function() nsg:Destroy() end)
        end
    end)
end

-- ─────────────────────────────────────────────────────────
return FluxLib
-- ─────────────────────────────────────────────────────────


--[[
═══════════════════════════════════════════════════════
  USAGE EXAMPLE  (LocalScript)
═══════════════════════════════════════════════════════

local Flux = require(game.ReplicatedStorage.FluxLibrary_v3)
local win  = Flux.new({ Title = "Flux UI Library" })

-- MAIN tab
win:addTab("Main")
win:addDescription("Main", "Welcome!", "A modern, animated UI library for Roblox.")
win:addSection("Main", "Quick Actions")
win:addButton("Main", { Title="Click Me", Callback=function() print("clicked") end })
win:addToggle("Main", { Title="Toggle Something", Default=true, Callback=function(v) print(v) end })
win:addInfoBox("Main", { Title="Info", Description="Add notifications, alerts and more!" })

-- PLAYER tab
win:addTab("Player")
win:addSection("Player", "Movement")
win:addSlider("Player", { Title="WalkSpeed", Min=0, Max=100, Default=16,
    Callback=function(v)
        local h = game.Players.LocalPlayer.Character and
                  game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
        if h then h.WalkSpeed = v end
    end })
win:addSlider("Player", { Title="JumpPower", Min=0, Max=200, Default=50 })
win:addSection("Player", "Combat")
win:addToggle("Player", { Title="God Mode", Default=false })
win:addActionButton("Player", { Title="Reset Character",
    Callback=function()
        local h = game.Players.LocalPlayer.Character and
                  game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
        if h then h:TakeDamage(math.huge) end
    end })

-- VISUALS tab
win:addTab("Visuals")
win:addSection("Visuals", "ESP")
win:addToggle("Visuals", { Title="ESP Boxes",         Default=true  })
win:addToggle("Visuals", { Title="Tracers",           Default=true  })
win:addToggle("Visuals", { Title="Highlight Players", Default=false })
win:addSection("Visuals", "Colors")
win:addColorPicker("Visuals", { Title="ESP Color",  Default=Color3.fromRGB(50,130,255) })
win:addColorPicker("Visuals", { Title="Fill Color", Default=Color3.fromRGB(0,210,255)  })

-- SETTINGS tab
win:addTab("Settings")
win:addSection("Settings", "Appearance")
win:addDropdown("Settings", {
    Title="Theme", Options={"Dark","Midnight","Stealth"}, Default="Dark",
    Callback=function(v) print("Theme:", v) end })
win:addColorPicker("Settings", { Title="Accent Color" })
win:addSlider("Settings", { Title="UI Scale", Min=50, Max=150, Default=100 })
win:addSection("Settings", "Input")
win:addKeybind("Settings", {
    Title="Toggle Menu", Default=Enum.KeyCode.RightShift,
    OnTrigger=function() print("Menu toggled") end })

-- MISC tab
win:addTab("Misc")
win:addSection("Misc", "Utilities")
win:addButton("Misc", { Title="Copy Game ID", Callback=function()
    setclipboard(tostring(game.PlaceId)) end })

-- Startup notification
task.delay(1, function()
    win:notify({
        Title       = "Flux UI Library v3",
        Description = "Loaded — Blue · Black · White",
        Duration    = 5,
    })
end)

]]
