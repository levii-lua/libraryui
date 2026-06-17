-- ╔══════════════════════════════════════════════════╗
-- ║           FLUX UI LIBRARY  v2.0                  ║
-- ║   Dark theme · Purple accent · Lucide icons      ║
-- ╚══════════════════════════════════════════════════╝
--
-- Lucide icon set (rbxassetid) — replace IDs with your
-- own uploaded Lucide SVG-to-PNG exports as needed.
-- Free reference: https://lucide.dev/icons
--
-- USAGE at the bottom of this file.

local FluxLib = {}
FluxLib.__index = FluxLib

-- ─────────────────────────────────────────
--  SERVICES
-- ─────────────────────────────────────────
local TweenService    = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService      = game:GetService("RunService")
local CoreGui         = game:GetService("CoreGui")

-- ─────────────────────────────────────────
--  LUCIDE ICON ASSET IDs
--  Upload your Lucide PNGs to Roblox and
--  replace these IDs. Defaults are placeholders.
-- ─────────────────────────────────────────
local Icons = {
    home        = "rbxassetid://11963537893",  -- lucide:home
    user        = "rbxassetid://11963538045",  -- lucide:user
    eye         = "rbxassetid://11963537721",  -- lucide:eye
    settings    = "rbxassetid://11963537969",  -- lucide:settings
    layout      = "rbxassetid://11963537801",  -- lucide:layout-dashboard
    zap         = "rbxassetid://11963538121",  -- lucide:zap  (Flux logo)
    menu        = "rbxassetid://11963537845",  -- lucide:menu
    minus       = "rbxassetid://11963537869",  -- lucide:minus
    x           = "rbxassetid://11963538097",  -- lucide:x
    mouse       = "rbxassetid://11963537893",  -- lucide:mouse-pointer-2
    chevronDown = "rbxassetid://11963537649",  -- lucide:chevron-down
    check       = "rbxassetid://11963537625",  -- lucide:check
    palette     = "rbxassetid://11963537921",  -- lucide:palette
    keyboard    = "rbxassetid://11963537777",  -- lucide:keyboard
    refresh     = "rbxassetid://11963537945",  -- lucide:refresh-cw
    shield      = "rbxassetid://11963537993",  -- lucide:shield
    scan        = "rbxassetid://11963537969",  -- lucide:scan-line
    highlight   = "rbxassetid://11963537745",  -- lucide:highlighter
    paintbucket = "rbxassetid://11963537897",  -- lucide:paint-bucket
}

-- ─────────────────────────────────────────
--  THEME TOKENS
-- ─────────────────────────────────────────
local T = {
    -- Backgrounds
    BgDeep      = Color3.fromRGB(15, 14, 22),
    BgPanel     = Color3.fromRGB(20, 19, 30),
    BgSidebar   = Color3.fromRGB(17, 16, 26),
    BgCard      = Color3.fromRGB(26, 25, 38),
    BgCardHov   = Color3.fromRGB(32, 31, 46),
    BgInput     = Color3.fromRGB(22, 21, 34),
    BgBtn       = Color3.fromRGB(110, 60, 220),
    BgBtnHov    = Color3.fromRGB(130, 80, 240),
    -- Accent
    Accent      = Color3.fromRGB(120, 70, 230),
    AccentSoft  = Color3.fromRGB(100, 55, 200),
    AccentLine  = Color3.fromRGB(60, 45, 110),
    -- Text
    TextHi      = Color3.fromRGB(240, 238, 255),
    TextMid     = Color3.fromRGB(170, 165, 200),
    TextLow     = Color3.fromRGB(100, 95, 135),
    -- Toggle
    ToggleOff   = Color3.fromRGB(50, 48, 72),
    -- Misc
    Divider     = Color3.fromRGB(35, 33, 52),
    Shadow      = Color3.fromRGB(0, 0, 0),
    -- Radii
    RadLg       = UDim.new(0, 12),
    RadMd       = UDim.new(0, 8),
    RadSm       = UDim.new(0, 6),
    RadPill     = UDim.new(1, 0),
}

-- ─────────────────────────────────────────
--  HELPERS
-- ─────────────────────────────────────────
local function tw(obj, props, dur, style)
    TweenService:Create(obj,
        TweenInfo.new(dur or 0.18, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        props):Play()
end

local function corner(p, r)
    local c = Instance.new("UICorner"); c.CornerRadius = r or T.RadMd; c.Parent = p
end

local function stroke(p, col, thick)
    local s = Instance.new("UIStroke"); s.Color = col or T.Divider; s.Thickness = thick or 1; s.Parent = p
end

local function frame(props)
    local f = Instance.new("Frame")
    f.BackgroundColor3 = props.color or T.BgPanel
    f.BackgroundTransparency = props.trans or 0
    f.BorderSizePixel = 0
    f.Size = props.size or UDim2.new(1,0,0,40)
    f.Position = props.pos or UDim2.new(0,0,0,0)
    f.ClipsDescendants = props.clip or false
    f.Name = props.name or "Frame"
    f.ZIndex = props.z or 1
    f.Parent = props.parent
    return f
end

local function label(props)
    local l = Instance.new("TextLabel")
    l.Text = props.text or ""
    l.TextSize = props.size or 13
    l.TextColor3 = props.color or T.TextHi
    l.Font = props.bold and Enum.Font.GothamBold or Enum.Font.Gotham
    l.BackgroundTransparency = 1
    l.TextXAlignment = props.align or Enum.TextXAlignment.Left
    l.TextYAlignment = props.valign or Enum.TextYAlignment.Center
    l.TextTruncate = Enum.TextTruncate.AtEnd
    l.Size = props.sizeU or UDim2.new(1,0,1,0)
    l.Position = props.posU or UDim2.new(0,0,0,0)
    l.ZIndex = props.z or 2
    l.Name = props.name or "Label"
    l.Parent = props.parent
    return l
end

local function icon(props)
    local img = Instance.new("ImageLabel")
    img.Image = props.id or ""
    img.ImageColor3 = props.color or T.TextMid
    img.BackgroundTransparency = 1
    img.ScaleType = Enum.ScaleType.Fit
    img.Size = props.sizeU or UDim2.new(0,16,0,16)
    img.Position = props.posU or UDim2.new(0,0,0.5,-8)
    img.ZIndex = props.z or 3
    img.Name = props.name or "Icon"
    img.Parent = props.parent
    return img
end

local function btn(parent, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,1,0)
    b.BackgroundTransparency = 1
    b.Text = ""
    b.ZIndex = 10
    b.Parent = parent
    if cb then b.MouseButton1Click:Connect(cb) end
    return b
end

local function pad(parent, t,b,l,r)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.PaddingLeft   = UDim.new(0, l or 0)
    p.PaddingRight  = UDim.new(0, r or 0)
    p.Parent = parent
end

local function list(parent, dir, gap)
    local l = Instance.new("UIListLayout")
    l.FillDirection = dir or Enum.FillDirection.Vertical
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Padding = UDim.new(0, gap or 0)
    l.Parent = parent
    return l
end

-- ─────────────────────────────────────────
--  WINDOW
-- ─────────────────────────────────────────
function FluxLib.new(config)
    config = config or {}
    local self = setmetatable({}, FluxLib)
    self._tabs = {}
    self._activeTab = nil
    self._open = true

    -- Root ScreenGui
    local sg = Instance.new("ScreenGui")
    sg.Name = "FluxUI"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.IgnoreGuiInset = true
    sg.Parent = CoreGui
    self._gui = sg

    -- ── Toggle icon (always visible) ──────────────────
    local toggleHolder = frame{
        name="ToggleHolder", color=T.BgCard,
        size=UDim2.new(0,48,0,48),
        pos=UDim2.new(0,20,0.5,-24),
        parent=sg
    }
    corner(toggleHolder, T.RadMd)
    stroke(toggleHolder, T.AccentLine, 1.5)

    icon{
        id=Icons.menu, color=T.TextHi,
        sizeU=UDim2.new(0,22,0,22),
        posU=UDim2.new(0.5,-11,0.5,-11),
        z=3, parent=toggleHolder
    }

    -- ── Main window ───────────────────────────────────
    local win = frame{
        name="Window", color=T.BgDeep,
        size=UDim2.new(0,580,0,400),
        pos=UDim2.new(0.5,-290,0.5,-200),
        clip=true, parent=sg
    }
    corner(win, T.RadLg)
    stroke(win, T.Divider, 1)
    self._win = win

    -- Shadow
    local shad = Instance.new("ImageLabel")
    shad.Size = UDim2.new(1,60,1,60)
    shad.Position = UDim2.new(0,-30,0,-30)
    shad.BackgroundTransparency = 1
    shad.Image = "rbxassetid://6014261993"
    shad.ImageColor3 = T.Shadow
    shad.ImageTransparency = 0.55
    shad.ScaleType = Enum.ScaleType.Slice
    shad.SliceCenter = Rect.new(49,49,450,450)
    shad.ZIndex = 0
    shad.Parent = win

    -- ── Title bar ─────────────────────────────────────
    local titleBar = frame{
        name="TitleBar", color=T.BgPanel,
        size=UDim2.new(1,0,0,46), pos=UDim2.new(0,0,0,0),
        z=2, parent=win
    }

    -- Flux logo icon
    local logoBox = frame{
        color=T.Accent,
        size=UDim2.new(0,28,0,28),
        pos=UDim2.new(0,12,0.5,-14),
        z=3, parent=titleBar
    }
    corner(logoBox, T.RadSm)
    icon{id=Icons.zap, color=T.TextHi, sizeU=UDim2.new(0,16,0,16), posU=UDim2.new(0.5,-8,0.5,-8), z=4, parent=logoBox}

    label{text=config.Title or "Flux UI Library", bold=true, size=14,
          sizeU=UDim2.new(1,-120,1,0), posU=UDim2.new(0,48,0,0),
          color=T.TextHi, z=3, parent=titleBar}

    -- Minimize
    local minBox = frame{color=T.BgCard, size=UDim2.new(0,28,0,28), pos=UDim2.new(1,-66,0.5,-14), z=3, parent=titleBar}
    corner(minBox, T.RadSm)
    icon{id=Icons.minus, color=T.TextMid, sizeU=UDim2.new(0,14,0,14), posU=UDim2.new(0.5,-7,0.5,-7), z=4, parent=minBox}

    -- Close
    local closeBox = frame{color=T.Accent, size=UDim2.new(0,28,0,28), pos=UDim2.new(1,-32,0.5,-14), z=3, parent=titleBar}
    corner(closeBox, T.RadSm)
    icon{id=Icons.x, color=T.TextHi, sizeU=UDim2.new(0,14,0,14), posU=UDim2.new(0.5,-7,0.5,-7), z=4, parent=closeBox}

    -- Divider under title
    frame{color=T.Divider, size=UDim2.new(1,0,0,1), pos=UDim2.new(0,0,0,46), z=2, parent=win}

    -- ── Sidebar ───────────────────────────────────────
    local sidebar = frame{
        name="Sidebar", color=T.BgSidebar,
        size=UDim2.new(0,130,1,-47), pos=UDim2.new(0,0,0,47),
        z=2, parent=win
    }
    pad(sidebar, 10,10,8,8)
    list(sidebar, Enum.FillDirection.Vertical, 2)
    self._sidebar = sidebar

    -- Divider between sidebar and content
    frame{color=T.Divider, size=UDim2.new(0,1,1,-47), pos=UDim2.new(0,130,0,47), z=2, parent=win}

    -- ── Content area ──────────────────────────────────
    local content = frame{
        name="Content", color=Color3.fromRGB(0,0,0),
        size=UDim2.new(1,-138,1,-55), pos=UDim2.new(0,138,0,55),
        clip=true, trans=1, parent=win
    }
    self._content = content

    -- ── Wire up toggle icon ───────────────────────────
    local minimized = false
    btn(toggleHolder, function()
        self._open = not self._open
        tw(win, {Size = self._open and UDim2.new(0,580,0,400) or UDim2.new(0,0,0,0)}, 0.25)
        tw(win, {BackgroundTransparency = self._open and 0 or 1}, 0.2)
    end)

    -- ── Minimize button ───────────────────────────────
    btn(minBox, function()
        minimized = not minimized
        tw(win, {Size = minimized and UDim2.new(0,580,0,46) or UDim2.new(0,580,0,400)}, 0.22)
    end)

    -- ── Close button ─────────────────────────────────
    btn(closeBox, function() sg:Destroy() end)

    -- ── Dragging ─────────────────────────────────────
    local dragging, dragStart, winStart
    titleBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = inp.Position; winStart = win.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local d = inp.Position - dragStart
            win.Position = UDim2.new(winStart.X.Scale, winStart.X.Offset+d.X, winStart.Y.Scale, winStart.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    return self
end

-- ─────────────────────────────────────────
--  TAB SYSTEM
-- ─────────────────────────────────────────
local TAB_META = {
    Main     = { icon = Icons.home     },
    Player   = { icon = Icons.user     },
    Visuals  = { icon = Icons.eye      },
    Settings = { icon = Icons.settings },
    Misc     = { icon = Icons.layout   },
}

function FluxLib:addTab(name)
    local isFirst = next(self._tabs) == nil

    -- ── Sidebar button ────────────────────────────────
    local sbBtn = frame{
        name="Tab_"..name, color=isFirst and T.Accent or Color3.fromRGB(0,0,0),
        size=UDim2.new(1,0,0,34), trans=isFirst and 0.82 or 1,
        parent=self._sidebar
    }
    corner(sbBtn, T.RadMd)

    local meta = TAB_META[name] or { icon = Icons.layout }
    icon{id=meta.icon, color=isFirst and T.Accent or T.TextLow,
         sizeU=UDim2.new(0,16,0,16), posU=UDim2.new(0,10,0.5,-8), z=3, parent=sbBtn}

    label{text=name, size=13, bold=isFirst, color=isFirst and T.TextHi or T.TextMid,
          sizeU=UDim2.new(1,-34,1,0), posU=UDim2.new(0,32,0,0), z=3, parent=sbBtn}

    -- ── Content page ──────────────────────────────────
    local page = Instance.new("ScrollingFrame")
    page.Name = "Page_"..name
    page.Size = UDim2.new(1,0,1,0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = T.Accent
    page.CanvasSize = UDim2.new(0,0,0,0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = isFirst
    page.Parent = self._content

    pad(page,14,14,12,12)
    list(page, Enum.FillDirection.Vertical, 6)

    -- Page heading (icon + name)
    local heading = frame{
        color=Color3.fromRGB(0,0,0), trans=1,
        size=UDim2.new(1,0,0,36), parent=page
    }
    icon{id=meta.icon, color=T.Accent, sizeU=UDim2.new(0,20,0,20), posU=UDim2.new(0,0,0.5,-10), z=3, parent=heading}
    label{text=name, bold=true, size=20, color=T.TextHi,
          sizeU=UDim2.new(1,-28,1,0), posU=UDim2.new(0,28,0,0), z=3, parent=heading}

    local tabData = { name=name, btn=sbBtn, page=page }
    self._tabs[name] = tabData

    if isFirst then
        self._activeTab = name
    end

    -- Click
    btn(sbBtn, function() self:selectTab(name) end)

    -- Hover
    local clickBtn = sbBtn:FindFirstChildOfClass("TextButton")
    clickBtn.MouseEnter:Connect(function()
        if self._activeTab ~= name then
            tw(sbBtn, {BackgroundTransparency=0.88}, 0.12)
        end
    end)
    clickBtn.MouseLeave:Connect(function()
        if self._activeTab ~= name then
            tw(sbBtn, {BackgroundTransparency=1}, 0.12)
        end
    end)

    return tabData
end

function FluxLib:selectTab(name)
    if not self._tabs[name] then return end
    -- Deactivate old
    if self._activeTab and self._tabs[self._activeTab] then
        local old = self._tabs[self._activeTab]
        old.page.Visible = false
        tw(old.btn, {BackgroundTransparency=1}, 0.15)
        local oldIcon = old.btn:FindFirstChild("Icon")
        local oldLabel = old.btn:FindFirstChild("Label")
        if oldIcon then oldIcon.ImageColor3 = T.TextLow end
        if oldLabel then oldLabel.TextColor3 = T.TextMid; oldLabel.Font = Enum.Font.Gotham end
    end
    -- Activate new
    local tab = self._tabs[name]
    tab.page.Visible = true
    tw(tab.btn, {BackgroundTransparency=0.82}, 0.15)
    local newIcon = tab.btn:FindFirstChild("Icon")
    local newLabel = tab.btn:FindFirstChild("Label")
    if newIcon then newIcon.ImageColor3 = T.Accent end
    if newLabel then newLabel.TextColor3 = T.TextHi; newLabel.Font = Enum.Font.GothamBold end
    self._activeTab = name
end

-- ─────────────────────────────────────────
--  COMPONENTS
-- ─────────────────────────────────────────

-- ── Welcome / description text ────────────────────
function FluxLib:addDescription(tabName, title, body)
    local page = self._tabs[tabName] and self._tabs[tabName].page
    if not page then return end

    local holder = frame{color=Color3.fromRGB(0,0,0),trans=1,size=UDim2.new(1,0,0,52),parent=page}

    label{text=title or "Welcome!", bold=true, size=18, color=T.TextHi,
          sizeU=UDim2.new(1,0,0,26), posU=UDim2.new(0,0,0,0), parent=holder}
    label{text=body or "", size=12, color=T.TextMid,
          sizeU=UDim2.new(1,0,0,26), posU=UDim2.new(0,0,0,26), parent=holder}
end

-- ── Section label ─────────────────────────────────
function FluxLib:addSection(tabName, title)
    local page = self._tabs[tabName] and self._tabs[tabName].page
    if not page then return end

    local sec = frame{color=Color3.fromRGB(0,0,0),trans=1,size=UDim2.new(1,0,0,22),parent=page}
    label{text=title or "Section", bold=true, size=11,
          color=T.TextLow, sizeU=UDim2.new(1,0,1,0), parent=sec}
end

-- ── Full-width button ─────────────────────────────
function FluxLib:addButton(tabName, config)
    config = config or {}
    local page = self._tabs[tabName] and self._tabs[tabName].page
    if not page then return end

    local card = frame{color=T.BgBtn, size=UDim2.new(1,0,0,40), parent=page}
    corner(card, T.RadMd)

    if config.icon then
        icon{id=config.icon, color=T.TextHi,
             sizeU=UDim2.new(0,16,0,16), posU=UDim2.new(0,14,0.5,-8), z=3, parent=card}
    end

    label{text=config.Title or "Click Me", bold=true, size=13,
          color=T.TextHi, align=Enum.TextXAlignment.Center,
          sizeU=UDim2.new(1,0,1,0), z=3, parent=card}

    btn(card, function()
        tw(card, {BackgroundColor3=T.BgBtnHov},0.08)
        task.delay(0.16, function() tw(card,{BackgroundColor3=T.BgBtn},0.15) end)
        if config.Callback then config.Callback() end
    end)

    local c = card:FindFirstChildOfClass("TextButton")
    c.MouseEnter:Connect(function() tw(card,{BackgroundColor3=T.BgBtnHov},0.1) end)
    c.MouseLeave:Connect(function() tw(card,{BackgroundColor3=T.BgBtn},0.1) end)

    return card
end

-- ── Toggle (full row) ─────────────────────────────
function FluxLib:addToggle(tabName, config)
    config = config or {}
    local page = self._tabs[tabName] and self._tabs[tabName].page
    if not page then return end

    local state = config.Default ~= nil and config.Default or false

    local row = frame{color=T.BgCard, size=UDim2.new(1,0,0,44), parent=page}
    corner(row, T.RadMd)
    pad(row, 0,0,14,14)

    label{text=config.Title or "Toggle", size=13, color=T.TextHi,
          sizeU=UDim2.new(1,-56,1,0), posU=UDim2.new(0,0,0,0), parent=row}

    -- Pill
    local pill = frame{
        color=state and T.Accent or T.ToggleOff,
        size=UDim2.new(0,44,0,24), pos=UDim2.new(1,-44,0.5,-12),
        parent=row
    }
    corner(pill, T.RadPill)

    local knob = frame{
        color=T.TextHi,
        size=UDim2.new(0,18,0,18), pos=UDim2.new(0, state and 22 or 3, 0.5,-9),
        parent=pill
    }
    corner(knob, T.RadPill)

    local function refresh()
        tw(pill, {BackgroundColor3 = state and T.Accent or T.ToggleOff}, 0.18)
        tw(knob, {Position = UDim2.new(0, state and 22 or 3, 0.5,-9)}, 0.18)
    end

    btn(row, function()
        state = not state
        refresh()
        if config.Callback then config.Callback(state) end
    end)

    return row, function() return state end
end

-- ── Slider ────────────────────────────────────────
function FluxLib:addSlider(tabName, config)
    config = config or {}
    local page = self._tabs[tabName] and self._tabs[tabName].page
    if not page then return end

    local minV = config.Min or 0
    local maxV = config.Max or 100
    local val  = math.clamp(config.Default or 50, minV, maxV)

    local card = frame{color=T.BgCard, size=UDim2.new(1,0,0,58), parent=page}
    corner(card, T.RadMd)
    pad(card, 0,0,14,14)

    local titleL = label{text=config.Title or "Slider", size=13, color=T.TextHi,
                         sizeU=UDim2.new(1,-50,0,20), posU=UDim2.new(0,0,0,10), parent=card}

    local valL = label{text=tostring(val), size=13, bold=true, color=T.TextMid,
                       align=Enum.TextXAlignment.Right,
                       sizeU=UDim2.new(0,40,0,20), posU=UDim2.new(1,-40,0,10), parent=card}

    -- Track bg
    local track = frame{color=T.ToggleOff, size=UDim2.new(1,0,0,5), pos=UDim2.new(0,0,0,38), parent=card}
    corner(track, T.RadPill)

    local pct0 = (val - minV)/(maxV - minV)
    local fill = frame{color=T.Accent, size=UDim2.new(pct0,0,1,0), pos=UDim2.new(0,0,0,0), parent=track}
    corner(fill, T.RadPill)

    local thumb = frame{
        color=T.TextHi, size=UDim2.new(0,14,0,14),
        pos=UDim2.new(pct0,-7,0.5,-7), parent=track
    }
    corner(thumb, T.RadPill)

    local sliding = false

    local function set(inputPos)
        local abs = track.AbsolutePosition; local sz = track.AbsoluteSize
        local p = math.clamp((inputPos.X - abs.X)/sz.X, 0, 1)
        val = math.floor(minV + (maxV - minV)*p + 0.5)
        valL.Text = tostring(val)
        fill.Size = UDim2.new(p,0,1,0)
        thumb.Position = UDim2.new(p,-7,0.5,-7)
        if config.Callback then config.Callback(val) end
    end

    btn(thumb, nil).MouseButton1Down:Connect(function() sliding = true end)

    local trackBtn = Instance.new("TextButton")
    trackBtn.Size = UDim2.new(1,0,5,0); trackBtn.Position = UDim2.new(0,0,-2,0)
    trackBtn.BackgroundTransparency = 1; trackBtn.Text = ""; trackBtn.ZIndex = 8
    trackBtn.Parent = track
    trackBtn.MouseButton1Down:Connect(function(x,y) sliding=true; set(Vector2.new(x,y)) end)

    UserInputService.InputChanged:Connect(function(inp)
        if sliding and inp.UserInputType == Enum.UserInputType.MouseMovement then set(inp.Position) end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
    end)

    return card, function() return val end
end

-- ── Color picker (swatch button) ──────────────────
function FluxLib:addColorPicker(tabName, config)
    config = config or {}
    local page = self._tabs[tabName] and self._tabs[tabName].page
    if not page then return end

    local color = config.Default or T.Accent

    local row = frame{color=T.BgCard, size=UDim2.new(1,0,0,44), parent=page}
    corner(row, T.RadMd)
    pad(row, 0,0,14,14)

    label{text=config.Title or "Color", size=13, color=T.TextHi,
          sizeU=UDim2.new(1,-50,1,0), posU=UDim2.new(0,0,0,0), parent=row}

    local swatch = frame{color=color, size=UDim2.new(0,28,0,28), pos=UDim2.new(1,-28,0.5,-14), parent=row}
    corner(swatch, T.RadSm)
    stroke(swatch, T.Divider, 1)

    -- Opens Roblox color picker
    btn(row, function()
        -- In a real script you'd open a custom color picker here
        if config.Callback then config.Callback(color) end
    end)

    return row, function() return color end
end

-- ── Dropdown ──────────────────────────────────────
function FluxLib:addDropdown(tabName, config)
    config = config or {}
    local page = self._tabs[tabName] and self._tabs[tabName].page
    if not page then return end

    local options = config.Options or {"Option 1"}
    local selected = config.Default or options[1]
    local open = false

    local wrapper = frame{color=Color3.fromRGB(0,0,0),trans=1,size=UDim2.new(1,0,0,44),parent=page}

    local row = frame{color=T.BgCard, size=UDim2.new(1,0,0,44), parent=wrapper}
    corner(row, T.RadMd)
    pad(row, 0,0,14,14)

    label{text=config.Title or "Dropdown", size=13, color=T.TextHi,
          sizeU=UDim2.new(0.5,0,1,0), posU=UDim2.new(0,0,0,0), parent=row}

    local selLabel = label{text=selected, size=13, color=T.TextMid,
                            align=Enum.TextXAlignment.Right,
                            sizeU=UDim2.new(0.4,0,1,0), posU=UDim2.new(0.5,-20,0,0), parent=row}

    icon{id=Icons.chevronDown, color=T.TextLow,
         sizeU=UDim2.new(0,14,0,14), posU=UDim2.new(1,-14,0.5,-7), z=3, parent=row}

    -- Dropdown list
    local dropList = frame{
        color=T.BgCard, size=UDim2.new(1,0,0, 0),
        pos=UDim2.new(0,0,0,46), clip=true, parent=wrapper
    }
    corner(dropList, T.RadMd)
    stroke(dropList, T.Divider)
    list(dropList, Enum.FillDirection.Vertical, 0)

    for _, opt in ipairs(options) do
        local optRow = frame{color=Color3.fromRGB(0,0,0),trans=1, size=UDim2.new(1,0,0,34), parent=dropList}
        label{text=opt, size=12, color=T.TextMid,
              sizeU=UDim2.new(1,0,1,0), posU=UDim2.new(0,12,0,0), parent=optRow}
        btn(optRow, function()
            selected = opt; selLabel.Text = opt
            open = false
            tw(dropList, {Size=UDim2.new(1,0,0,0)}, 0.15)
            tw(wrapper,  {Size=UDim2.new(1,0,0,44)},0.15)
            if config.Callback then config.Callback(selected) end
        end)
        local ob = optRow:FindFirstChildOfClass("TextButton")
        ob.MouseEnter:Connect(function() tw(optRow,{BackgroundTransparency=0.88},0.1) end)
        ob.MouseLeave:Connect(function() tw(optRow,{BackgroundTransparency=1},0.1) end)
    end

    btn(row, function()
        open = not open
        local h = open and (34 * #options) or 0
        tw(dropList, {Size=UDim2.new(1,0,0,h)}, 0.18)
        tw(wrapper,  {Size=UDim2.new(1,0,0, 44+h)}, 0.18)
    end)

    return wrapper, function() return selected end
end

-- ── Keybind ───────────────────────────────────────
function FluxLib:addKeybind(tabName, config)
    config = config or {}
    local page = self._tabs[tabName] and self._tabs[tabName].page
    if not page then return end

    local key = config.Default or Enum.KeyCode.RightShift
    local listening = false

    local row = frame{color=T.BgCard, size=UDim2.new(1,0,0,44), parent=page}
    corner(row, T.RadMd)
    pad(row, 0,0,14,14)

    label{text=config.Title or "Keybind", size=13, color=T.TextHi,
          sizeU=UDim2.new(1,-100,1,0), posU=UDim2.new(0,0,0,0), parent=row}

    local keyLabel = label{text=tostring(key.Name), size=12, bold=true,
                            color=T.TextMid, align=Enum.TextXAlignment.Right,
                            sizeU=UDim2.new(0,90,1,0), posU=UDim2.new(1,-90,0,0), parent=row}

    btn(row, function()
        if listening then return end
        listening = true
        keyLabel.Text = "..."
        keyLabel.TextColor3 = T.Accent
        local conn
        conn = UserInputService.InputBegan:Connect(function(inp, gp)
            if gp then return end
            if inp.UserInputType == Enum.UserInputType.Keyboard then
                key = inp.KeyCode
                keyLabel.Text = key.Name
                keyLabel.TextColor3 = T.TextMid
                listening = false
                conn:Disconnect()
                if config.Callback then config.Callback(key) end
            end
        end)
    end)

    -- Global trigger
    UserInputService.InputBegan:Connect(function(inp, gp)
        if not gp and inp.KeyCode == key and config.OnTrigger then
            config.OnTrigger()
        end
    end)

    return row, function() return key end
end

-- ── Action button (small, no fill) ────────────────
function FluxLib:addActionButton(tabName, config)
    config = config or {}
    local page = self._tabs[tabName] and self._tabs[tabName].page
    if not page then return end

    local card = frame{color=T.BgInput, size=UDim2.new(1,0,0,38), parent=page}
    corner(card, T.RadMd)
    stroke(card, T.Divider)

    label{text=config.Title or "Action", size=13, color=T.TextMid,
          align=Enum.TextXAlignment.Center, sizeU=UDim2.new(1,0,1,0), z=3, parent=card}

    btn(card, function()
        tw(card,{BackgroundColor3=T.Accent},0.08)
        task.delay(0.18,function() tw(card,{BackgroundColor3=T.BgInput},0.18) end)
        if config.Callback then config.Callback() end
    end)

    local cb = card:FindFirstChildOfClass("TextButton")
    cb.MouseEnter:Connect(function() tw(card,{BackgroundColor3=T.BgCardHov},0.1) end)
    cb.MouseLeave:Connect(function() tw(card,{BackgroundColor3=T.BgInput},0.1) end)

    return card
end

-- ─────────────────────────────────────────
--  NOTIFICATION TOAST
-- ─────────────────────────────────────────
function FluxLib:notify(config)
    config = config or {}
    local notifSg = Instance.new("ScreenGui")
    notifSg.Name = "FluxNotif"; notifSg.ResetOnSpawn = false
    notifSg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    notifSg.IgnoreGuiInset = true; notifSg.Parent = CoreGui

    local toast = frame{
        color=T.BgCard, size=UDim2.new(0,280,0,64),
        pos=UDim2.new(1,20,1,-80), parent=notifSg
    }
    corner(toast, T.RadMd)
    stroke(toast, T.Accent, 1)

    local bar = frame{color=T.Accent, size=UDim2.new(0,3,1,0), pos=UDim2.new(0,0,0,0), parent=toast}
    corner(bar, T.RadSm)

    label{text=config.Title or "Notice", bold=true, size=13, color=T.TextHi,
          sizeU=UDim2.new(1,-20,0,22), posU=UDim2.new(0,16,0,10), parent=toast}
    label{text=config.Description or "", size=11, color=T.TextMid,
          sizeU=UDim2.new(1,-20,0,18), posU=UDim2.new(0,16,0,34), parent=toast}

    tw(toast, {Position=UDim2.new(1,-296,1,-80)}, 0.28)

    task.delay(config.Duration or 3.5, function()
        tw(toast,{Position=UDim2.new(1,20,1,-80),BackgroundTransparency=1},0.25)
        task.delay(0.3, function() notifSg:Destroy() end)
    end)
end

-- ─────────────────────────────────────────
return FluxLib
-- ─────────────────────────────────────────


--[[
═══════════════════════════════════════════
  FULL USAGE EXAMPLE
═══════════════════════════════════════════

local Flux = require(game.ReplicatedStorage.FluxLibrary)

local win = Flux.new({ Title = "Flux UI Library" })

-- ── MAIN TAB ────────────────────────────
local main = win:addTab("Main")

win:addDescription("Main",
    "Welcome!",
    "This is a modern, customizable\nUI library for Roblox."
)

win:addSection("Main", "Quick Actions")

win:addButton("Main", {
    Title = "Click Me",
    icon = Icons.mouse,     -- optional
    Callback = function()
        print("Clicked!")
    end,
})

win:addToggle("Main", {
    Title = "Toggle Something",
    Default = true,
    Callback = function(v) print("Toggle:", v) end,
})

-- ── PLAYER TAB ──────────────────────────
local player = win:addTab("Player")

local wsSlider = win:addSlider("Player", {
    Title = "WalkSpeed",
    Min = 0, Max = 100, Default = 16,
    Callback = function(v)
        game.Players.LocalPlayer.Character
            and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
            and (game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v)
    end,
})

win:addSlider("Player", {
    Title = "JumpPower",
    Min = 0, Max = 200, Default = 50,
    Callback = function(v)
        local hum = game.Players.LocalPlayer.Character
            and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.JumpPower = v end
    end,
})

win:addToggle("Player", { Title = "God Mode", Default = false,
    Callback = function(v) print("GodMode:", v) end })

win:addActionButton("Player", {
    Title = "Reset Character",
    Callback = function()
        game.Players.LocalPlayer.Character:FindFirstChild("Humanoid"):TakeDamage(math.huge)
    end,
})

-- ── VISUALS TAB ─────────────────────────
local visuals = win:addTab("Visuals")

win:addToggle("Visuals", { Title = "ESP",              Default = true  })
win:addToggle("Visuals", { Title = "Tracers",          Default = true  })
win:addToggle("Visuals", { Title = "Highlight Players",Default = true  })
win:addColorPicker("Visuals", { Title = "Fill Color",  Default = Color3.fromRGB(120,60,200) })

-- ── SETTINGS TAB ────────────────────────
local settings = win:addTab("Settings")

win:addDropdown("Settings", {
    Title = "Theme",
    Options = { "Dark", "Light", "Midnight" },
    Default = "Dark",
    Callback = function(v) print("Theme:", v) end,
})

win:addColorPicker("Settings", { Title = "Accent Color" })

win:addSlider("Settings", {
    Title = "UI Scale",
    Min = 50, Max = 150, Default = 100,
})

win:addKeybind("Settings", {
    Title = "Keybind",
    Default = Enum.KeyCode.RightShift,
    OnTrigger = function()
        -- toggle menu open/close
    end,
})

-- ── MISC TAB ────────────────────────────
win:addTab("Misc")

-- ── NOTIFICATION ────────────────────────
task.delay(1, function()
    win:notify({
        Title = "Flux UI Library",
        Description = "Loaded successfully.",
        Duration = 4,
    })
end)

]]
