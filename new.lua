-- ================================================
--   Roblox UI Library
--   Modern dark theme with purple accents
-- ================================================

local UILibrary = {}
UILibrary.__index = UILibrary

-- ========================
--   THEME CONFIGURATION
-- ========================
local Theme = {
    Background      = Color3.fromRGB(18, 18, 26),
    SidebarBg       = Color3.fromRGB(22, 22, 32),
    PanelBg         = Color3.fromRGB(26, 26, 38),
    CardBg          = Color3.fromRGB(30, 30, 44),
    CardHover       = Color3.fromRGB(36, 36, 52),
    InfoBoxBg       = Color3.fromRGB(28, 20, 48),
    Accent          = Color3.fromRGB(130, 80, 255),
    AccentDark      = Color3.fromRGB(90, 50, 200),
    AccentGlow      = Color3.fromRGB(160, 110, 255),
    TextPrimary     = Color3.fromRGB(240, 240, 255),
    TextSecondary   = Color3.fromRGB(160, 160, 190),
    TextMuted       = Color3.fromRGB(100, 100, 130),
    Divider         = Color3.fromRGB(40, 40, 60),
    ToggleOff       = Color3.fromRGB(60, 60, 80),
    SliderTrack     = Color3.fromRGB(50, 50, 70),
    CornerRadius    = UDim.new(0, 10),
    CornerSmall     = UDim.new(0, 6),
}

-- ========================
--   UTILITY HELPERS
-- ========================
local function applyCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or Theme.CornerRadius
    c.Parent = parent
end

local function applyStroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Divider
    s.Thickness = thickness or 1
    s.Parent = parent
end

local function newLabel(text, size, color, bold, parent)
    local lbl = Instance.new("TextLabel")
    lbl.Text = text
    lbl.TextSize = size or 14
    lbl.TextColor3 = color or Theme.TextPrimary
    lbl.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

local function newFrame(size, pos, color, parent)
    local f = Instance.new("Frame")
    f.Size = size or UDim2.new(1, 0, 0, 40)
    f.Position = pos or UDim2.new(0, 0, 0, 0)
    f.BackgroundColor3 = color or Theme.PanelBg
    f.BorderSizePixel = 0
    f.Parent = parent
    return f
end

local function tween(obj, props, t)
    local ts = game:GetService("TweenService")
    local info = TweenInfo.new(t or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    ts:Create(obj, info, props):Play()
end

-- ========================
--   WINDOW CREATION
-- ========================
function UILibrary.new(config)
    config = config or {}
    local self = setmetatable({}, UILibrary)
    self.Tabs = {}
    self.ActiveTab = nil

    -- ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = config.Name or "UILibrary"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = game:GetService("CoreGui")
    self.ScreenGui = screenGui

    -- Main window frame
    local window = newFrame(
        UDim2.new(0, 760, 0, 520),
        UDim2.new(0.5, -380, 0.5, -260),
        Theme.Background,
        screenGui
    )
    window.Name = "Window"
    applyCorner(window, UDim.new(0, 14))
    applyStroke(window, Theme.Divider, 1)
    self.Window = window

    -- Drop shadow effect
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 40, 1, 40)
    shadow.Position = UDim2.new(0, -20, 0, -20)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.ZIndex = 0
    shadow.Parent = window

    -- ========================
    --   TITLE BAR
    -- ========================
    local titleBar = newFrame(
        UDim2.new(1, 0, 0, 56),
        UDim2.new(0, 0, 0, 0),
        Theme.Background,
        window
    )
    titleBar.Name = "TitleBar"
    titleBar.ZIndex = 2

    -- Logo icon
    local logoBox = newFrame(
        UDim2.new(0, 36, 0, 36),
        UDim2.new(0, 14, 0.5, -18),
        Theme.Accent,
        titleBar
    )
    applyCorner(logoBox, UDim.new(0, 8))
    local logoLabel = newLabel("R", 20, Theme.TextPrimary, true, logoBox)
    logoLabel.Size = UDim2.new(1, 0, 1, 0)
    logoLabel.TextXAlignment = Enum.TextXAlignment.Center

    -- Title text
    local titleText = newLabel(
        config.Title or "Roblox UI Library",
        18, Theme.TextPrimary, true, titleBar
    )
    titleText.Size = UDim2.new(1, -120, 1, 0)
    titleText.Position = UDim2.new(0, 60, 0, 0)

    -- Minimize button
    local minimizeBtn = newFrame(UDim2.new(0, 36, 0, 36), UDim2.new(1, -86, 0.5, -18), Theme.CardBg, titleBar)
    applyCorner(minimizeBtn, UDim.new(0, 8))
    local minLabel = newLabel("—", 16, Theme.TextSecondary, true, minimizeBtn)
    minLabel.Size = UDim2.new(1, 0, 1, 0)
    minLabel.TextXAlignment = Enum.TextXAlignment.Center

    -- Close button
    local closeBtn = newFrame(UDim2.new(0, 36, 0, 36), UDim2.new(1, -44, 0.5, -18), Theme.Accent, titleBar)
    applyCorner(closeBtn, UDim.new(0, 8))
    local closeLabel = newLabel("✕", 16, Theme.TextPrimary, true, closeBtn)
    closeLabel.Size = UDim2.new(1, 0, 1, 0)
    closeLabel.TextXAlignment = Enum.TextXAlignment.Center

    -- Close functionality
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(1, 0, 1, 0)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = ""
    closeButton.Parent = closeBtn
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    -- Minimize functionality
    local minimized = false
    local minButton = Instance.new("TextButton")
    minButton.Size = UDim2.new(1, 0, 1, 0)
    minButton.BackgroundTransparency = 1
    minButton.Text = ""
    minButton.Parent = minimizeBtn
    minButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        tween(window, { Size = minimized and UDim2.new(0, 760, 0, 56) or UDim2.new(0, 760, 0, 520) }, 0.25)
    end)

    -- Dragging
    local dragging, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = window.Position
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            window.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Divider line under title bar
    local topDivider = newFrame(UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 0, 56), Theme.Divider, window)
    topDivider.Name = "TopDivider"

    -- ========================
    --   SIDEBAR
    -- ========================
    local sidebar = newFrame(
        UDim2.new(0, 190, 1, -57),
        UDim2.new(0, 0, 0, 57),
        Theme.SidebarBg,
        window
    )
    sidebar.Name = "Sidebar"
    applyCorner(sidebar, UDim.new(0, 0))

    local sidebarList = Instance.new("UIListLayout")
    sidebarList.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarList.Padding = UDim.new(0, 2)
    sidebarList.Parent = sidebar

    local sidebarPadding = Instance.new("UIPadding")
    sidebarPadding.PaddingTop = UDim.new(0, 8)
    sidebarPadding.PaddingLeft = UDim.new(0, 8)
    sidebarPadding.PaddingRight = UDim.new(0, 8)
    sidebarPadding.Parent = sidebar

    -- Vertical divider between sidebar and content
    local sideDivider = newFrame(UDim2.new(0, 1, 1, -57), UDim2.new(0, 190, 0, 57), Theme.Divider, window)
    sideDivider.Name = "SideDivider"

    -- ========================
    --   CONTENT AREA
    -- ========================
    local contentArea = newFrame(
        UDim2.new(1, -198, 1, -65),
        UDim2.new(0, 198, 0, 65),
        Color3.fromRGB(0, 0, 0),
        window
    )
    contentArea.BackgroundTransparency = 1
    contentArea.Name = "ContentArea"
    contentArea.ClipsDescendants = true
    self.ContentArea = contentArea
    self.Sidebar = sidebar

    return self
end

-- ========================
--   TAB CREATION
-- ========================
local TAB_ICONS = {
    Main     = "🏠",
    Player   = "⚡",
    Visuals  = "👤",
    Misc     = "⚙",
    Settings = "</>",
    About    = "ⓘ",
}

function UILibrary:addTab(name)
    local tabData = { Name = name, Sections = {}, Button = nil, Page = nil }

    -- Sidebar button
    local btn = newFrame(UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, 0), Color3.fromRGB(0,0,0), self.Sidebar)
    btn.BackgroundTransparency = 1
    btn.Name = "Tab_" .. name

    local isFirst = #self.Tabs == 0

    -- Active indicator bar
    local indicator = newFrame(UDim2.new(0, 3, 0.6, 0), UDim2.new(0, 0, 0.2, 0), Theme.Accent, btn)
    indicator.Name = "Indicator"
    applyCorner(indicator, UDim.new(0, 4))
    indicator.Visible = isFirst

    -- Button background
    local btnBg = newFrame(UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), Theme.Accent, btn)
    btnBg.BackgroundTransparency = isFirst and 0.85 or 1
    applyCorner(btnBg, UDim.new(0, 8))

    -- Icon
    local icon = newLabel(TAB_ICONS[name] or "●", 15, isFirst and Theme.Accent or Theme.TextMuted, false, btn)
    icon.Size = UDim2.new(0, 26, 1, 0)
    icon.Position = UDim2.new(0, 12, 0, 0)
    icon.TextXAlignment = Enum.TextXAlignment.Center

    -- Label
    local label = newLabel(name, 14, isFirst and Theme.TextPrimary or Theme.TextSecondary, isFirst, btn)
    label.Size = UDim2.new(1, -44, 1, 0)
    label.Position = UDim2.new(0, 44, 0, 0)

    -- Tab content page (ScrollingFrame)
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.Position = UDim2.new(0, 0, 0, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Theme.Accent
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = isFirst
    page.Parent = self.ContentArea

    local pageList = Instance.new("UIListLayout")
    pageList.SortOrder = Enum.SortOrder.LayoutOrder
    pageList.Padding = UDim.new(0, 8)
    pageList.Parent = page

    local pagePad = Instance.new("UIPadding")
    pagePad.PaddingTop = UDim.new(0, 12)
    pagePad.PaddingLeft = UDim.new(0, 12)
    pagePad.PaddingRight = UDim.new(0, 12)
    pagePad.PaddingBottom = UDim.new(0, 12)
    pagePad.Parent = page

    tabData.Button = btn
    tabData.Page = page
    tabData.Indicator = indicator
    tabData.BtnBg = btnBg
    tabData.Icon = icon
    tabData.Label = label

    -- Click logic
    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.Parent = btn
    clickBtn.MouseButton1Click:Connect(function()
        self:selectTab(name)
    end)

    -- Hover effect
    clickBtn.MouseEnter:Connect(function()
        if self.ActiveTab ~= name then
            tween(btnBg, { BackgroundTransparency = 0.92 }, 0.1)
        end
    end)
    clickBtn.MouseLeave:Connect(function()
        if self.ActiveTab ~= name then
            tween(btnBg, { BackgroundTransparency = 1 }, 0.1)
        end
    end)

    self.Tabs[name] = tabData
    if isFirst then
        self.ActiveTab = name

        -- Welcome header auto-added to Main tab
        if name == "Main" then
            self:_addWelcomeHeader(page)
        end
    end

    return tabData
end

function UILibrary:_addWelcomeHeader(page)
    local headerFrame = newFrame(UDim2.new(1, 0, 0, 60), nil, Color3.fromRGB(0,0,0), page)
    headerFrame.BackgroundTransparency = 1
    headerFrame.LayoutOrder = 0

    -- Purple left bar accent
    local bar = newFrame(UDim2.new(0, 3, 1, -8), UDim2.new(0, 0, 0, 4), Theme.Accent, headerFrame)
    applyCorner(bar, UDim.new(0, 2))

    local wTitle = newLabel("Welcome!", 24, Theme.TextPrimary, true, headerFrame)
    wTitle.Size = UDim2.new(1, -16, 0, 30)
    wTitle.Position = UDim2.new(0, 12, 0, 4)

    local wSub = newLabel("This is a modern Roblox UI Library.", 13, Theme.TextSecondary, false, headerFrame)
    wSub.Size = UDim2.new(1, -16, 0, 20)
    wSub.Position = UDim2.new(0, 12, 0, 34)
end

function UILibrary:selectTab(name)
    if not self.Tabs[name] then return end

    -- Deactivate old
    if self.ActiveTab and self.Tabs[self.ActiveTab] then
        local old = self.Tabs[self.ActiveTab]
        old.Page.Visible = false
        old.Indicator.Visible = false
        tween(old.BtnBg, { BackgroundTransparency = 1 }, 0.15)
        old.Label.Font = Enum.Font.Gotham
        old.Label.TextColor3 = Theme.TextSecondary
        old.Icon.TextColor3 = Theme.TextMuted
    end

    -- Activate new
    local tab = self.Tabs[name]
    tab.Page.Visible = true
    tab.Indicator.Visible = true
    tween(tab.BtnBg, { BackgroundTransparency = 0.85 }, 0.15)
    tab.Label.Font = Enum.Font.GothamBold
    tab.Label.TextColor3 = Theme.TextPrimary
    tab.Icon.TextColor3 = Theme.Accent

    self.ActiveTab = name
end

-- ========================
--   SECTION HEADER
-- ========================
function UILibrary:addSection(tab, title)
    local page = self.Tabs[tab] and self.Tabs[tab].Page
    if not page then return end

    local sectionFrame = newFrame(UDim2.new(1, 0, 0, 32), nil, Theme.CardBg, page)
    applyCorner(sectionFrame, UDim.new(0, 8))
    applyStroke(sectionFrame, Theme.Divider, 1)

    local dot = newFrame(UDim2.new(0, 7, 0, 7), UDim2.new(0, 12, 0.5, -3), Theme.Accent, sectionFrame)
    applyCorner(dot, UDim.new(1, 0))

    local lbl = newLabel(title, 13, Theme.TextPrimary, true, sectionFrame)
    lbl.Size = UDim2.new(1, -30, 1, 0)
    lbl.Position = UDim2.new(0, 26, 0, 0)

    return sectionFrame
end

-- ========================
--   BUTTON
-- ========================
function UILibrary:addButton(tab, config)
    config = config or {}
    local page = self.Tabs[tab] and self.Tabs[tab].Page
    if not page then return end

    local card = newFrame(UDim2.new(1, 0, 0, 58), nil, Theme.CardBg, page)
    applyCorner(card)
    applyStroke(card, Theme.Divider, 1)

    -- Icon circle
    local iconBg = newFrame(UDim2.new(0, 38, 0, 38), UDim2.new(0, 10, 0.5, -19), Theme.PanelBg, card)
    applyCorner(iconBg, UDim.new(1, 0))
    local iconLbl = newLabel(config.Icon or "✦", 18, Theme.Accent, false, iconBg)
    iconLbl.Size = UDim2.new(1, 0, 1, 0)
    iconLbl.TextXAlignment = Enum.TextXAlignment.Center

    -- Title & subtitle
    local btnTitle = newLabel(config.Title or "Button", 14, Theme.TextPrimary, true, card)
    btnTitle.Size = UDim2.new(1, -70, 0, 20)
    btnTitle.Position = UDim2.new(0, 56, 0, 10)

    local btnSub = newLabel(config.Description or "", 12, Theme.TextSecondary, false, card)
    btnSub.Size = UDim2.new(1, -70, 0, 16)
    btnSub.Position = UDim2.new(0, 56, 0, 32)

    -- Arrow
    local arrow = newLabel("›", 22, Theme.TextMuted, false, card)
    arrow.Size = UDim2.new(0, 24, 1, 0)
    arrow.Position = UDim2.new(1, -32, 0, 0)
    arrow.TextXAlignment = Enum.TextXAlignment.Center

    -- Clickable
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = card
    btn.MouseButton1Click:Connect(function()
        tween(card, { BackgroundColor3 = Theme.CardHover }, 0.08)
        task.delay(0.15, function() tween(card, { BackgroundColor3 = Theme.CardBg }, 0.15) end)
        if config.Callback then config.Callback() end
    end)
    btn.MouseEnter:Connect(function() tween(card, { BackgroundColor3 = Theme.CardHover }, 0.1) end)
    btn.MouseLeave:Connect(function() tween(card, { BackgroundColor3 = Theme.CardBg }, 0.1) end)

    return card
end

-- ========================
--   TOGGLE
-- ========================
function UILibrary:addToggle(tab, config)
    config = config or {}
    local page = self.Tabs[tab] and self.Tabs[tab].Page
    if not page then return end

    local state = config.Default or false

    local card = newFrame(UDim2.new(0.48, -6, 0, 70), nil, Theme.CardBg, page)
    applyCorner(card)
    applyStroke(card, Theme.Divider, 1)

    -- Dot + title
    local dot = newFrame(UDim2.new(0, 7, 0, 7), UDim2.new(0, 12, 0, 12), Theme.Accent, card)
    applyCorner(dot, UDim.new(1, 0))

    local titleLbl = newLabel(config.Title or "Toggle", 14, Theme.TextPrimary, true, card)
    titleLbl.Size = UDim2.new(1, -28, 0, 20)
    titleLbl.Position = UDim2.new(0, 26, 0, 6)

    local descLbl = newLabel(config.Description or "", 12, Theme.TextSecondary, false, card)
    descLbl.Size = UDim2.new(1, -16, 0, 16)
    descLbl.Position = UDim2.new(0, 12, 0, 42)

    -- Toggle pill
    local pillBg = newFrame(UDim2.new(0, 46, 0, 24), UDim2.new(1, -58, 0, 8), state and Theme.Accent or Theme.ToggleOff, card)
    applyCorner(pillBg, UDim.new(1, 0))

    local knob = newFrame(UDim2.new(0, 18, 0, 18), UDim2.new(0, state and 24 or 4, 0.5, -9), Theme.TextPrimary, pillBg)
    applyCorner(knob, UDim.new(1, 0))

    local function updateToggle()
        tween(pillBg, { BackgroundColor3 = state and Theme.Accent or Theme.ToggleOff }, 0.2)
        tween(knob, { Position = UDim2.new(0, state and 24 or 4, 0.5, -9) }, 0.2)
    end

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = card
    btn.MouseButton1Click:Connect(function()
        state = not state
        updateToggle()
        if config.Callback then config.Callback(state) end
    end)

    return card, function() return state end
end

-- ========================
--   SLIDER
-- ========================
function UILibrary:addSlider(tab, config)
    config = config or {}
    local page = self.Tabs[tab] and self.Tabs[tab].Page
    if not page then return end

    local min = config.Min or 0
    local max = config.Max or 100
    local value = config.Default or 75

    local card = newFrame(UDim2.new(0.48, -6, 0, 70), nil, Theme.CardBg, page)
    applyCorner(card)
    applyStroke(card, Theme.Divider, 1)

    -- Dot + title
    local dot = newFrame(UDim2.new(0, 7, 0, 7), UDim2.new(0, 12, 0, 12), Theme.Accent, card)
    applyCorner(dot, UDim.new(1, 0))

    local titleLbl = newLabel(config.Title or "Slider", 14, Theme.TextPrimary, true, card)
    titleLbl.Size = UDim2.new(1, -60, 0, 20)
    titleLbl.Position = UDim2.new(0, 26, 0, 6)

    local valueLbl = newLabel(tostring(value), 14, Theme.TextPrimary, true, card)
    valueLbl.Size = UDim2.new(0, 40, 0, 20)
    valueLbl.Position = UDim2.new(1, -48, 0, 6)
    valueLbl.TextXAlignment = Enum.TextXAlignment.Right

    -- Track
    local track = newFrame(UDim2.new(1, -24, 0, 6), UDim2.new(0, 12, 0, 46), Theme.SliderTrack, card)
    applyCorner(track, UDim.new(1, 0))

    -- Fill
    local pct = (value - min) / (max - min)
    local fill = newFrame(UDim2.new(pct, 0, 1, 0), UDim2.new(0, 0, 0, 0), Theme.Accent, track)
    applyCorner(fill, UDim.new(1, 0))

    -- Thumb
    local thumb = newFrame(UDim2.new(0, 16, 0, 16), UDim2.new(pct, -8, 0.5, -8), Theme.AccentGlow, track)
    applyCorner(thumb, UDim.new(1, 0))

    local uis = game:GetService("UserInputService")
    local sliding = false

    local function updateSlider(inputPos)
        local absPos = track.AbsolutePosition
        local absSize = track.AbsoluteSize
        local rel = math.clamp((inputPos.X - absPos.X) / absSize.X, 0, 1)
        value = math.floor(min + (max - min) * rel)
        valueLbl.Text = tostring(value)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        thumb.Position = UDim2.new(rel, -8, 0.5, -8)
        if config.Callback then config.Callback(value) end
    end

    local thumbBtn = Instance.new("TextButton")
    thumbBtn.Size = UDim2.new(1, 0, 1, 0)
    thumbBtn.BackgroundTransparency = 1
    thumbBtn.Text = ""
    thumbBtn.Parent = thumb
    thumbBtn.MouseButton1Down:Connect(function() sliding = true end)

    local trackBtn = Instance.new("TextButton")
    trackBtn.Size = UDim2.new(1, 0, 3, -12)
    trackBtn.Position = UDim2.new(0, 0, 0.5, -9)
    trackBtn.BackgroundTransparency = 1
    trackBtn.Text = ""
    trackBtn.Parent = track
    trackBtn.MouseButton1Down:Connect(function(x, y)
        sliding = true
        updateSlider(Vector2.new(x, y))
    end)

    uis.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input.Position)
        end
    end)
    uis.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = false
        end
    end)

    return card, function() return value end
end

-- ========================
--   INFO BOX
-- ========================
function UILibrary:addInfoBox(tab, config)
    config = config or {}
    local page = self.Tabs[tab] and self.Tabs[tab].Page
    if not page then return end

    local card = newFrame(UDim2.new(1, 0, 0, 60), nil, Theme.InfoBoxBg, page)
    applyCorner(card)
    applyStroke(card, Theme.Accent, 1)

    -- Icon box
    local iconBg = newFrame(UDim2.new(0, 38, 0, 38), UDim2.new(0, 10, 0.5, -19), Theme.AccentDark, card)
    applyCorner(iconBg, UDim.new(0, 8))
    local iconLbl = newLabel("ⓘ", 20, Theme.Accent, false, iconBg)
    iconLbl.Size = UDim2.new(1, 0, 1, 0)
    iconLbl.TextXAlignment = Enum.TextXAlignment.Center

    local title = newLabel(config.Title or "Info Box", 14, Theme.TextPrimary, true, card)
    title.Size = UDim2.new(1, -60, 0, 20)
    title.Position = UDim2.new(0, 56, 0, 10)

    local desc = newLabel(config.Description or "Add notifications, alerts and more!", 12, Theme.TextSecondary, false, card)
    desc.Size = UDim2.new(1, -60, 0, 18)
    desc.Position = UDim2.new(0, 56, 0, 32)

    return card
end

-- ========================
--   INLINE ROW (for side-by-side toggle + slider)
-- ========================
function UILibrary:addRow(tab)
    local page = self.Tabs[tab] and self.Tabs[tab].Page
    if not page then return end

    local row = newFrame(UDim2.new(1, 0, 0, 70), nil, Color3.fromRGB(0,0,0), page)
    row.BackgroundTransparency = 1

    local rowLayout = Instance.new("UIListLayout")
    rowLayout.FillDirection = Enum.FillDirection.Horizontal
    rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rowLayout.Padding = UDim.new(0, 10)
    rowLayout.Parent = row

    return row
end

-- ========================
--   NOTIFICATION SYSTEM
-- ========================
function UILibrary:notify(config)
    config = config or {}

    local notifGui = Instance.new("ScreenGui")
    notifGui.Name = "UILibNotif"
    notifGui.ResetOnSpawn = false
    notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    notifGui.Parent = game:GetService("CoreGui")

    local notif = newFrame(UDim2.new(0, 300, 0, 70), UDim2.new(1, -320, 1, -90), Theme.PanelBg, notifGui)
    applyCorner(notif, UDim.new(0, 10))
    applyStroke(notif, Theme.Accent, 1)
    notif.BackgroundTransparency = 1
    notif.Position = UDim2.new(1, 20, 1, -90)

    local iconBox = newFrame(UDim2.new(0, 36, 0, 36), UDim2.new(0, 10, 0.5, -18), Theme.Accent, notif)
    applyCorner(iconBox, UDim.new(0, 8))
    local iconL = newLabel(config.Icon or "ⓘ", 18, Theme.TextPrimary, false, iconBox)
    iconL.Size = UDim2.new(1, 0, 1, 0)
    iconL.TextXAlignment = Enum.TextXAlignment.Center

    local t = newLabel(config.Title or "Notification", 13, Theme.TextPrimary, true, notif)
    t.Size = UDim2.new(1, -60, 0, 18)
    t.Position = UDim2.new(0, 54, 0, 12)

    local d = newLabel(config.Description or "", 11, Theme.TextSecondary, false, notif)
    d.Size = UDim2.new(1, -60, 0, 16)
    d.Position = UDim2.new(0, 54, 0, 32)

    -- Slide in
    tween(notif, { BackgroundTransparency = 0, Position = UDim2.new(1, -320, 1, -90) }, 0.3)

    task.delay(config.Duration or 3, function()
        tween(notif, { BackgroundTransparency = 1, Position = UDim2.new(1, 20, 1, -90) }, 0.3)
        task.delay(0.35, function() notifGui:Destroy() end)
    end)
end

-- ========================
--   RETURN LIBRARY
-- ========================
return UILibrary


--[[
========================================
  USAGE EXAMPLE
========================================

local Library = require(game.ReplicatedStorage.UILibrary)

local win = Library.new({
    Title = "My Cheat Menu",
})

local mainTab = win:addTab("Main")
local playerTab = win:addTab("Player")
win:addTab("Visuals")
win:addTab("Misc")
win:addTab("Settings")
win:addTab("About")

-- Welcome header is auto-added to Main tab

-- Buttons section
win:addSection("Main", "Buttons")

win:addButton("Main", {
    Title = "Click Me!",
    Description = "This is an example button.",
    Icon = "✦",
    Callback = function()
        print("Button clicked!")
    end,
})

-- Toggle + Slider in a row
win:addSection("Main", "Controls")

local row = win:addRow("Main")

local toggleCard, getToggle = win:addToggle("Main", {
    Title = "Toggle",
    Description = "Enable feature",
    Default = true,
    Callback = function(val)
        print("Toggle:", val)
    end,
})
toggleCard.LayoutOrder = 1
toggleCard.Parent = row

local sliderCard, getSlider = win:addSlider("Main", {
    Title = "Slider",
    Min = 0,
    Max = 100,
    Default = 75,
    Callback = function(val)
        print("Slider:", val)
    end,
})
sliderCard.LayoutOrder = 2
sliderCard.Parent = row

-- Info box
win:addInfoBox("Main", {
    Title = "Info Box",
    Description = "You can add notifications, alerts and more!",
})

-- Notification test
task.delay(1, function()
    win:notify({
        Title = "Welcome!",
        Description = "UI Library loaded successfully.",
        Icon = "✓",
        Duration = 4,
    })
end)

]]
