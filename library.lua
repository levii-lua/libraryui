cat > /mnt/user-data/outputs/DarkUI.lua << 'LUAEOF'
--[[
╔══════════════════════════════════════════════════════════════════╗
║            DarkUI  –  Dark Theme UI Library  v3.0               ║
║  • Floating toggle button  (open / hide)                        ║
║  • Title-bar  Minimize / Maximize / Close  (Frame-drawn icons)  ║
║  • Lucide-style icons on every tab & element via SVG frames     ║
║  • Built-in OUTPUT CONSOLE tab  (print / warn / error hooks)    ║
║  • Tabs, Buttons, Toggles, Sliders, Dropdowns, Textbox,        ║
║    Keybind, Label, Section, Notify toasts                       ║
╠══════════════════════════════════════════════════════════════════╣
║  QUICK START                                                    ║
║    local UI  = require(script.DarkUI)                          ║
║    local Win = UI:CreateWindow({ Title="My Script" })          ║
║    local Tab = Win:AddTab("Main","terminal")                   ║
║    Tab:AddButton({ Text="Run", Callback=function()             ║
║        Win:Log("Button pressed!", "success") end })            ║
╚══════════════════════════════════════════════════════════════════╝
--]]

local DarkUI = {}
DarkUI.__index = DarkUI

-- ───────────────────────── Services ─────────────────────────────
local TS      = game:GetService("TweenService")
local UIS     = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunSvc  = game:GetService("RunService")

-- ───────────────────────── Palette ──────────────────────────────
local C = {
    Bg         = Color3.fromRGB(11,  12,  16),
    Surface    = Color3.fromRGB(20,  22,  28),
    Elevated   = Color3.fromRGB(28,  31,  40),
    Border     = Color3.fromRGB(42,  46,  60),
    Accent     = Color3.fromRGB(99,  102, 241),
    AccentDim  = Color3.fromRGB(60,  63,  180),
    Danger     = Color3.fromRGB(239, 68,  68),
    Success    = Color3.fromRGB(34,  197, 94),
    Warning    = Color3.fromRGB(234, 179, 8),
    Info       = Color3.fromRGB(56,  189, 248),
    TextPri    = Color3.fromRGB(238, 240, 248),
    TextSec    = Color3.fromRGB(140, 143, 165),
    TextDis    = Color3.fromRGB(65,  68,  90),
    ConsoleBg  = Color3.fromRGB(8,   9,   12),
    -- Log level colours
    LogInfo    = Color3.fromRGB(140, 143, 165),
    LogWarn    = Color3.fromRGB(234, 179, 8),
    LogError   = Color3.fromRGB(239, 68,  68),
    LogSuccess = Color3.fromRGB(34,  197, 94),
    LogSystem  = Color3.fromRGB(99,  102, 241),
}

-- ─────────────────── Lucide SVG Icon Library ────────────────────
-- Each icon is drawn with Frames/UICorners — no external assets.
-- Call  LucideIcon(parent, name, size, colour)  to create one.
--
-- Supported names:
--   terminal, console, trash-2, copy, x, minus, maximize-2,
--   chevron-down, chevron-right, settings, sliders-horizontal,
--   play, zap, info, check, alert-triangle, circle-x,
--   home, layers, code-2, bot, layout-dashboard, activity

local function NewFrame(parent, size, pos, col, zIndex, cornerR)
    local f = Instance.new("Frame")
    f.BackgroundColor3 = col or C.TextSec
    f.BorderSizePixel  = 0
    f.Size             = size
    f.Position         = pos
    if zIndex then f.ZIndex = zIndex end
    f.Parent           = parent
    if cornerR and cornerR > 0 then
        local cr = Instance.new("UICorner")
        cr.CornerRadius = UDim.new(0, cornerR)
        cr.Parent = f
    end
    return f
end

-- Thin bar helper (like a stroke line)
local function Bar(p, w, h, x, y, col, rot, z)
    local f = NewFrame(p,
        UDim2.new(0, w, 0, h),
        UDim2.new(0, x, 0, y),
        col, z, math.min(w,h)/2)
    if rot and rot ~= 0 then f.Rotation = rot end
    return f
end

local LucideIcons = {}

-- ── terminal / console ──────────────────────────────────────────
LucideIcons["terminal"] = function(p, s, col)
    local z = p.ZIndex or 1
    -- ">" chevron left
    Bar(p, 2, s*0.35, s*0.12, s*0.32, col, -35, z+1)
    Bar(p, 2, s*0.35, s*0.12, s*0.40, col,  35, z+1)
    -- underline
    Bar(p, s*0.45, 2, s*0.38, s*0.72, col, 0, z+1)
end

-- ── x / close ──────────────────────────────────────────────────
LucideIcons["x"] = function(p, s, col)
    local z = p.ZIndex or 1
    Bar(p, 2, s*0.65, s*0.18, s*0.17, col, 45, z+1)
    Bar(p, 2, s*0.65, s*0.18, s*0.17, col,-45, z+1)
end

-- ── minus ───────────────────────────────────────────────────────
LucideIcons["minus"] = function(p, s, col)
    Bar(p, s*0.6, 2, s*0.2, s*0.47, col, 0, (p.ZIndex or 1)+1)
end

-- ── maximize-2 ──────────────────────────────────────────────────
LucideIcons["maximize-2"] = function(p, s, col)
    local z = (p.ZIndex or 1)+1
    -- hollow rect
    Bar(p, s*0.55, 2,    s*0.22, s*0.22, col, 0, z)  -- top
    Bar(p, s*0.55, 2,    s*0.22, s*0.76, col, 0, z)  -- bottom
    Bar(p, 2,    s*0.55, s*0.22, s*0.22, col, 0, z)  -- left
    Bar(p, 2,    s*0.55, s*0.75, s*0.22, col, 0, z)  -- right
end

-- ── check ───────────────────────────────────────────────────────
LucideIcons["check"] = function(p, s, col)
    local z = (p.ZIndex or 1)+1
    Bar(p, 2, s*0.32, s*0.15, s*0.55, col, -45, z)
    Bar(p, 2, s*0.55, s*0.43, s*0.30, col,  45, z)
end

-- ── info ────────────────────────────────────────────────────────
LucideIcons["info"] = function(p, s, col)
    local z = (p.ZIndex or 1)+1
    -- circle dot (top)
    local dot = NewFrame(p, UDim2.new(0,3,0,3), UDim2.new(0,s*0.46,0,s*0.22), col, z, 2)
    -- vertical bar
    Bar(p, 2, s*0.38, s*0.46, s*0.38, col, 0, z)
end

-- ── alert-triangle ──────────────────────────────────────────────
LucideIcons["alert-triangle"] = function(p, s, col)
    local z = (p.ZIndex or 1)+1
    Bar(p, 2, s*0.28, s*0.46, s*0.25, col, 0, z)  -- vertical
    local dot = NewFrame(p, UDim2.new(0,3,0,3), UDim2.new(0,s*0.46,0,s*0.62), col, z, 2)
    -- triangle sides
    Bar(p, 2, s*0.55, s*0.12, s*0.30, col, -28, z)
    Bar(p, 2, s*0.55, s*0.73, s*0.30, col,  28, z)
    Bar(p, s*0.76, 2, s*0.12, s*0.75, col, 0, z)
end

-- ── circle-x ────────────────────────────────────────────────────
LucideIcons["circle-x"] = function(p, s, col)
    local z = (p.ZIndex or 1)+1
    -- circle (hollow, 4 arcs approximated with bars)
    local cx, cy, r = s*0.5, s*0.5, s*0.35
    for i = 0, 3 do
        local ang = math.rad(i * 90)
        local bx = cx + math.cos(ang)*r - 1
        local by = cy + math.sin(ang)*r - 1
        Bar(p, s*0.34, 2, bx - s*0.085, by, col, i*90, z)
    end
    -- x inside
    Bar(p, 2, s*0.35, s*0.32, s*0.32, col,  45, z)
    Bar(p, 2, s*0.35, s*0.32, s*0.32, col, -45, z)
end

-- ── play ────────────────────────────────────────────────────────
LucideIcons["play"] = function(p, s, col)
    local z = (p.ZIndex or 1)+1
    -- triangle: left vertical + two diagonals
    Bar(p, 2, s*0.55, s*0.25, s*0.22, col, 0,   z)
    Bar(p, 2, s*0.38, s*0.25, s*0.22, col, 30,  z)
    Bar(p, 2, s*0.38, s*0.25, s*0.56, col,-30,  z)
end

-- ── zap ─────────────────────────────────────────────────────────
LucideIcons["zap"] = function(p, s, col)
    local z = (p.ZIndex or 1)+1
    Bar(p, 2, s*0.52, s*0.50, s*0.12, col, -15, z)
    Bar(p, 2, s*0.52, s*0.30, s*0.28, col,  15, z)
    Bar(p, s*0.38, 2, s*0.22, s*0.48, col, 0, z)
end

-- ── settings / gear ─────────────────────────────────────────────
LucideIcons["settings"] = function(p, s, col)
    local z = (p.ZIndex or 1)+1
    -- centre circle
    NewFrame(p, UDim2.new(0,s*0.28,0,s*0.28),
        UDim2.new(0,s*0.36,0,s*0.36), col, z, s*0.14)
    -- 6 teeth
    for i=0,5 do
        local a = math.rad(i*60)
        local tx = s*0.5 + math.cos(a)*(s*0.38) - 1
        local ty = s*0.5 + math.sin(a)*(s*0.38) - 3
        Bar(p, 2, s*0.22, tx, ty, col, math.deg(a), z)
    end
end

-- ── sliders-horizontal ──────────────────────────────────────────
LucideIcons["sliders-horizontal"] = function(p, s, col)
    local z = (p.ZIndex or 1)+1
    local ys = {s*0.22, s*0.46, s*0.70}
    local xs = {s*0.50, s*0.25, s*0.62}
    for i,y in ipairs(ys) do
        Bar(p, s*0.72, 2, s*0.14, y, col, 0, z)
        NewFrame(p, UDim2.new(0,5,0,5), UDim2.new(0,xs[i]-2,0,y-1), col, z, 3)
    end
end

-- ── home ────────────────────────────────────────────────────────
LucideIcons["home"] = function(p, s, col)
    local z = (p.ZIndex or 1)+1
    -- roof
    Bar(p, 2, s*0.40, s*0.22, s*0.20, col, -40, z)
    Bar(p, 2, s*0.40, s*0.52, s*0.20, col,  40, z)
    -- body sides
    Bar(p, 2, s*0.32, s*0.22, s*0.50, col, 0, z)
    Bar(p, 2, s*0.32, s*0.72, s*0.50, col, 0, z)
    -- floor
    Bar(p, s*0.52, 2, s*0.22, s*0.80, col, 0, z)
    -- door
    Bar(p, s*0.16, 2, s*0.42, s*0.80, col, 0, z)
end

-- ── layers ──────────────────────────────────────────────────────
LucideIcons["layers"] = function(p, s, col)
    local z = (p.ZIndex or 1)+1
    local ys = {s*0.18, s*0.46, s*0.72}
    for _,y in ipairs(ys) do
        Bar(p, s*0.72, 2, s*0.14, y, col, 0, z)
    end
end

-- ── code-2 ──────────────────────────────────────────────────────
LucideIcons["code-2"] = function(p, s, col)
    local z = (p.ZIndex or 1)+1
    -- < chevron
    Bar(p, 2, s*0.28, s*0.18, s*0.30, col, -38, z)
    Bar(p, 2, s*0.28, s*0.18, s*0.47, col,  38, z)
    -- > chevron
    Bar(p, 2, s*0.28, s*0.65, s*0.30, col,  38, z)
    Bar(p, 2, s*0.28, s*0.65, s*0.47, col, -38, z)
    -- / slash
    Bar(p, 2, s*0.62, s*0.44, s*0.17, col,  -22, z)
end

-- ── bot ─────────────────────────────────────────────────────────
LucideIcons["bot"] = function(p, s, col)
    local z = (p.ZIndex or 1)+1
    -- head rect
    Bar(p, s*0.60, 2,    s*0.20, s*0.30, col, 0, z)
    Bar(p, s*0.60, 2,    s*0.20, s*0.65, col, 0, z)
    Bar(p, 2,    s*0.36, s*0.20, s*0.30, col, 0, z)
    Bar(p, 2,    s*0.36, s*0.78, s*0.30, col, 0, z)
    -- antenna
    Bar(p, 2, s*0.20, s*0.48, s*0.10, col, 0, z)
    NewFrame(p, UDim2.new(0,4,0,4), UDim2.new(0,s*0.46,0,s*0.06), col, z, 2)
    -- eyes
    NewFrame(p, UDim2.new(0,4,0,4), UDim2.new(0,s*0.32,0,s*0.42), col, z, 2)
    NewFrame(p, UDim2.new(0,4,0,4), UDim2.new(0,s*0.62,0,s*0.42), col, z, 2)
end

-- ── layout-dashboard ────────────────────────────────────────────
LucideIcons["layout-dashboard"] = function(p, s, col)
    local z = (p.ZIndex or 1)+1
    -- outer border
    Bar(p, s*0.72, 2,    s*0.14, s*0.15, col, 0, z)
    Bar(p, s*0.72, 2,    s*0.14, s*0.82, col, 0, z)
    Bar(p, 2,    s*0.68, s*0.14, s*0.15, col, 0, z)
    Bar(p, 2,    s*0.68, s*0.84, s*0.15, col, 0, z)
    -- inner dividers
    Bar(p, 2,    s*0.38, s*0.47, s*0.15, col, 0, z)  -- vertical
    Bar(p, s*0.72, 2,    s*0.14, s*0.54, col, 0, z)  -- horizontal
end

-- ── activity ────────────────────────────────────────────────────
LucideIcons["activity"] = function(p, s, col)
    local z = (p.ZIndex or 1)+1
    -- zig-zag pulse line
    local pts = {
        {s*0.08, s*0.50},
        {s*0.28, s*0.50},
        {s*0.38, s*0.22},
        {s*0.50, s*0.78},
        {s*0.62, s*0.36},
        {s*0.72, s*0.50},
        {s*0.92, s*0.50},
    }
    for i = 1, #pts-1 do
        local ax,ay = pts[i][1],   pts[i][2]
        local bx,by = pts[i+1][1], pts[i+1][2]
        local dx, dy = bx-ax, by-ay
        local len    = math.sqrt(dx*dx + dy*dy)
        local ang    = math.deg(math.atan2(dy, dx))
        Bar(p, len, 2, ax, ay, col, ang, z)
    end
end

-- ── trash-2 ─────────────────────────────────────────────────────
LucideIcons["trash-2"] = function(p, s, col)
    local z = (p.ZIndex or 1)+1
    -- lid handle
    Bar(p, s*0.28, 2, s*0.36, s*0.16, col, 0, z)
    -- lid
    Bar(p, s*0.62, 2, s*0.19, s*0.28, col, 0, z)
    -- body sides
    Bar(p, 2, s*0.44, s*0.22, s*0.28, col, 0, z)
    Bar(p, 2, s*0.44, s*0.76, s*0.28, col, 0, z)
    -- base
    Bar(p, s*0.58, 2, s*0.21, s*0.80, col, 0, z)
    -- inner lines
    Bar(p, 2, s*0.30, s*0.44, s*0.34, col, 0, z)
    Bar(p, 2, s*0.30, s*0.56, s*0.34, col, 0, z)
end

-- ── copy ────────────────────────────────────────────────────────
LucideIcons["copy"] = function(p, s, col)
    local z = (p.ZIndex or 1)+1
    -- back rect
    Bar(p, s*0.50, 2, s*0.32, s*0.14, col, 0, z)
    Bar(p, s*0.50, 2, s*0.32, s*0.62, col, 0, z)
    Bar(p, 2, s*0.50, s*0.32, s*0.14, col, 0, z)
    Bar(p, 2, s*0.50, s*0.80, s*0.14, col, 0, z)
    -- front rect (offset)
    Bar(p, s*0.50, 2, s*0.14, s*0.32, col, 0, z)
    Bar(p, s*0.50, 2, s*0.14, s*0.80, col, 0, z)
    Bar(p, 2, s*0.50, s*0.14, s*0.32, col, 0, z)
    Bar(p, 2, s*0.50, s*0.62, s*0.32, col, 0, z)
end

-- ── chevron-down ────────────────────────────────────────────────
LucideIcons["chevron-down"] = function(p, s, col)
    local z = (p.ZIndex or 1)+1
    Bar(p, 2, s*0.38, s*0.22, s*0.28, col,  38, z)
    Bar(p, 2, s*0.38, s*0.52, s*0.28, col, -38, z)
end

-- ── chevron-right ───────────────────────────────────────────────
LucideIcons["chevron-right"] = function(p, s, col)
    local z = (p.ZIndex or 1)+1
    Bar(p, 2, s*0.38, s*0.28, s*0.22, col, -52, z)
    Bar(p, 2, s*0.38, s*0.28, s*0.52, col,  52, z)
end

-- ── scroll-text ─────────────────────────────────────────────────
LucideIcons["scroll-text"] = function(p, s, col)
    local z = (p.ZIndex or 1)+1
    Bar(p, s*0.50, 2, s*0.26, s*0.30, col, 0, z)
    Bar(p, s*0.50, 2, s*0.26, s*0.46, col, 0, z)
    Bar(p, s*0.50, 2, s*0.26, s*0.62, col, 0, z)
    Bar(p, 2, s*0.55, s*0.76, s*0.22, col, 0, z)
    Bar(p, 2, s*0.55, s*0.22, s*0.22, col, 0, z)
    Bar(p, s*0.56, 2, s*0.22, s*0.22, col, 0, z)
    Bar(p, s*0.56, 2, s*0.22, s*0.76, col, 0, z)
end

-- ── Public API: LucideIcon ───────────────────────────────────────
local function LucideIcon(parent, name, size, col)
    size = size or 16
    col  = col  or C.TextSec

    local holder = Instance.new("Frame")
    holder.BackgroundTransparency = 1
    holder.Size   = UDim2.new(0, size, 0, size)
    holder.ZIndex = (parent.ZIndex or 1)
    holder.Parent = parent

    local draw = LucideIcons[name]
    if draw then
        draw(holder, size, col)
    else
        -- fallback: simple dot
        NewFrame(holder, UDim2.new(0, size*0.4, 0, size*0.4),
            UDim2.new(0, size*0.3, 0, size*0.3), col, holder.ZIndex+1, size*0.2)
    end
    return holder
end

-- ───────────────────────── Helpers ──────────────────────────────
local function Tw(obj, props, t, style, dir)
    TS:Create(obj, TweenInfo.new(t or 0.15,
        style or Enum.EasingStyle.Quad,
        dir   or Enum.EasingDirection.Out), props):Play()
end

local function Corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = p
    return c
end

local function Stroke(p, col, th)
    local s = Instance.new("UIStroke")
    s.Color           = col or C.Border
    s.Thickness       = th  or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent          = p
    return s
end

local function Pad(p, l, r, t, b)
    local u = Instance.new("UIPadding")
    u.PaddingLeft   = UDim.new(0, l or 8)
    u.PaddingRight  = UDim.new(0, r or l or 8)
    u.PaddingTop    = UDim.new(0, t or l or 8)
    u.PaddingBottom = UDim.new(0, b or t or l or 8)
    u.Parent = p
end

local function Lbl(parent, text, size, col, bold, xAlign, zIdx)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text           = text or ""
    l.TextColor3     = col  or C.TextPri
    l.TextSize       = size or 13
    l.Font           = bold and Enum.Font.GothamBold or Enum.Font.Gotham
    l.TextXAlignment = xAlign or Enum.TextXAlignment.Left
    l.TextTruncate   = Enum.TextTruncate.AtEnd
    if zIdx then l.ZIndex = zIdx end
    l.Parent         = parent
    return l
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

local function MakeDraggable(handle, target)
    local drag, ds, sp = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true; ds = i.Position; sp = target.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - ds
            target.Position = UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
    end)
end

-- ─── Window control button (Minimize / Maximize / Close) ────────
local function WinCtrlBtn(parent, iconName, hoverCol, z)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(0, 28, 0, 28)
    btn.BackgroundColor3 = C.Elevated
    btn.Text             = ""
    btn.AutoButtonColor  = false
    btn.ZIndex           = z or 5
    btn.Parent           = parent
    Corner(btn, 6)

    local ico = LucideIcon(btn, iconName, 14, C.TextSec)
    ico.Position   = UDim2.new(0.5, -7, 0.5, -7)
    ico.ZIndex     = (z or 5) + 1

    btn.MouseEnter:Connect(function()
        Tw(btn, { BackgroundColor3 = hoverCol or C.Border })
        -- re-colour icon bars
        for _, ch in ipairs(ico:GetDescendants()) do
            if ch:IsA("Frame") then Tw(ch, { BackgroundColor3 = C.TextPri }) end
        end
    end)
    btn.MouseLeave:Connect(function()
        Tw(btn, { BackgroundColor3 = C.Elevated })
        for _, ch in ipairs(ico:GetDescendants()) do
            if ch:IsA("Frame") then Tw(ch, { BackgroundColor3 = C.TextSec }) end
        end
    end)
    return btn
end

-- ════════════════════════════════════════════════════════════════
--   CREATE WINDOW
-- ════════════════════════════════════════════════════════════════
function DarkUI:CreateWindow(cfg)
    cfg = cfg or {}
    local title     = cfg.Title     or "DarkUI"
    local subtitle  = cfg.Subtitle  or ""
    local winIcon   = cfg.Icon      or ""
    local width     = cfg.Width     or 560
    local height    = cfg.Height    or 400
    local toggleKey = cfg.ToggleKey or Enum.KeyCode.RightShift
    local consoleEnabled = cfg.Console ~= false  -- true by default

    local sg  = GetSG()
    local win = {}

    -- ── Main frame ────────────────────────────────────────────────
    local Main = Instance.new("Frame")
    Main.Name             = "DarkUI_Window"
    Main.Size             = UDim2.new(0, width, 0, height)
    Main.Position         = UDim2.new(0.5, -width/2, 0.5, -height/2)
    Main.BackgroundColor3 = C.Bg
    Main.BorderSizePixel  = 0
    Main.ClipsDescendants = false
    Main.Parent           = sg
    Corner(Main, 10)
    Stroke(Main, C.Border, 1)

    -- Drop shadow
    local Shad = Instance.new("ImageLabel")
    Shad.AnchorPoint         = Vector2.new(0.5, 0.5)
    Shad.BackgroundTransparency = 1
    Shad.Position            = UDim2.new(0.5, 0, 0.5, 12)
    Shad.Size                = UDim2.new(1, 50, 1, 50)
    Shad.Image               = "rbxassetid://6014261993"
    Shad.ImageColor3         = Color3.new(0,0,0)
    Shad.ImageTransparency   = 0.45
    Shad.ScaleType           = Enum.ScaleType.Slice
    Shad.SliceCenter         = Rect.new(49,49,450,450)
    Shad.ZIndex              = -1
    Shad.Parent              = Main

    -- ── Title bar ─────────────────────────────────────────────────
    local TB = Instance.new("Frame")
    TB.Name             = "TitleBar"
    TB.Size             = UDim2.new(1, 0, 0, 54)
    TB.BackgroundColor3 = C.Surface
    TB.BorderSizePixel  = 0
    TB.ZIndex           = 4
    TB.Parent           = Main
    Corner(TB, 10)
    -- flatten bottom corners
    local TBF = Instance.new("Frame")
    TBF.Size             = UDim2.new(1, 0, 0, 10)
    TBF.Position         = UDim2.new(0, 0, 1, -10)
    TBF.BackgroundColor3 = C.Surface
    TBF.BorderSizePixel  = 0
    TBF.ZIndex           = 4
    TBF.Parent           = TB

    -- Accent stripe
    local Stripe = Instance.new("Frame")
    Stripe.Size             = UDim2.new(0, 3, 1, -18)
    Stripe.Position         = UDim2.new(0, 14, 0, 9)
    Stripe.BackgroundColor3 = C.Accent
    Stripe.BorderSizePixel  = 0
    Stripe.ZIndex           = 5
    Stripe.Parent           = TB
    Corner(Stripe, 2)

    -- Window icon image (optional)
    local leftX = 26
    if winIcon ~= "" then
        local wi = Instance.new("ImageLabel")
        wi.BackgroundTransparency = 1
        wi.Image      = winIcon
        wi.Size       = UDim2.new(0, 22, 0, 22)
        wi.Position   = UDim2.new(0, 26, 0.5, -11)
        wi.ScaleType  = Enum.ScaleType.Fit
        wi.ZIndex     = 5
        wi.Parent     = TB
        leftX = 54
    else
        -- Default: lucide terminal icon in title
        local ti = LucideIcon(TB, "terminal", 18, C.Accent)
        ti.Position = UDim2.new(0, 26, 0.5, -9)
        ti.ZIndex   = 5
        leftX = 52
    end

    local TitleLbl = Lbl(TB, title, 15, C.TextPri, true, nil, 5)
    TitleLbl.Size     = UDim2.new(1, -190, 0, 20)
    TitleLbl.Position = UDim2.new(0, leftX, 0, 8)

    if subtitle ~= "" then
        local SubLbl = Lbl(TB, subtitle, 11, C.TextSec, false, nil, 5)
        SubLbl.Size     = UDim2.new(1, -190, 0, 14)
        SubLbl.Position = UDim2.new(0, leftX, 0, 31)
    end

    -- Window controls: [ _ ]  [ □ ]  [ X ]
    local minimized = false
    local maximized = false
    local savedSize = UDim2.new(0, width, 0, height)
    local savedPos  = Main.Position

    local MinBtn = WinCtrlBtn(TB, "minus",      C.Warning, 5)
    MinBtn.Position = UDim2.new(1, -108, 0.5, -14)
    local MaxBtn = WinCtrlBtn(TB, "maximize-2", C.Success, 5)
    MaxBtn.Position = UDim2.new(1, -72,  0.5, -14)
    local ClsBtn = WinCtrlBtn(TB, "x",          C.Danger,  5)
    ClsBtn.Position = UDim2.new(1, -36,  0.5, -14)

    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tw(Main, { Size = UDim2.new(0, width, 0, 54) }, 0.22, Enum.EasingStyle.Quint)
        else
            Tw(Main, { Size = savedSize }, 0.22, Enum.EasingStyle.Quint)
        end
    end)

    MaxBtn.MouseButton1Click:Connect(function()
        if minimized then return end
        maximized = not maximized
        if maximized then
            savedSize = Main.Size; savedPos = Main.Position
            Tw(Main, { Size = UDim2.new(1,-20,1,-20), Position = UDim2.new(0,10,0,10) }, 0.25, Enum.EasingStyle.Quint)
        else
            Tw(Main, { Size = savedSize, Position = savedPos }, 0.25, Enum.EasingStyle.Quint)
        end
    end)

    ClsBtn.MouseButton1Click:Connect(function()
        Tw(Main, { Size = UDim2.new(0,width,0,0), BackgroundTransparency=1 }, 0.2)
        task.delay(0.22, function()
            Main:Destroy()
            local sg2 = GetSG()
            local tb2 = sg2:FindFirstChild("DarkUI_ToggleBtn")
            if tb2 then tb2:Destroy() end
        end)
    end)

    MakeDraggable(TB, Main)

    -- ── Sidebar ───────────────────────────────────────────────────
    local Sidebar = Instance.new("Frame")
    Sidebar.Size             = UDim2.new(0, 136, 1, -54)
    Sidebar.Position         = UDim2.new(0, 0, 0, 54)
    Sidebar.BackgroundColor3 = C.Surface
    Sidebar.BorderSizePixel  = 0
    Sidebar.ZIndex           = 2
    Sidebar.Parent           = Main
    Pad(Sidebar, 8)

    local SideList = Instance.new("UIListLayout")
    SideList.Padding   = UDim.new(0, 4)
    SideList.SortOrder = Enum.SortOrder.LayoutOrder
    SideList.Parent    = Sidebar

    local SideDivider = Instance.new("Frame")
    SideDivider.Size             = UDim2.new(0,1,1,-54)
    SideDivider.Position         = UDim2.new(0,136,0,54)
    SideDivider.BackgroundColor3 = C.Border
    SideDivider.BorderSizePixel  = 0
    SideDivider.Parent           = Main

    -- ── Content area ──────────────────────────────────────────────
    local Content = Instance.new("Frame")
    Content.Size                  = UDim2.new(1,-137,1,-54)
    Content.Position              = UDim2.new(0,137,0,54)
    Content.BackgroundTransparency = 1
    Content.ClipsDescendants      = true
    Content.Parent                = Main

    local activeTab = nil
    local tabPages  = {}
    local tabBtns   = {}

    local function SelectTab(name)
        for n,page in pairs(tabPages) do page.Visible = (n==name) end
        for n,btn  in pairs(tabBtns)  do
            if n==name then
                Tw(btn, { BackgroundColor3=C.Accent, BackgroundTransparency=0 })
                for _,ch in ipairs(btn:GetDescendants()) do
                    if ch:IsA("TextLabel") then Tw(ch,{TextColor3=C.TextPri}) end
                    if ch:IsA("Frame") and ch.Name~="TabBg" then Tw(ch,{BackgroundColor3=C.TextPri}) end
                end
            else
                Tw(btn, { BackgroundColor3=C.Elevated, BackgroundTransparency=1 })
                for _,ch in ipairs(btn:GetDescendants()) do
                    if ch:IsA("TextLabel") then Tw(ch,{TextColor3=C.TextSec}) end
                    if ch:IsA("Frame") and ch.Name~="TabBg" then Tw(ch,{BackgroundColor3=C.TextSec}) end
                end
            end
        end
        activeTab = name
    end

    -- ════════════════════════════════════════════════════════════
    --   AddTab
    -- ════════════════════════════════════════════════════════════
    function win:AddTab(name, iconName)
        iconName = iconName or "layers"

        local TabBtn = Instance.new("TextButton")
        TabBtn.Size                   = UDim2.new(1,0,0,34)
        TabBtn.BackgroundColor3       = C.Elevated
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text                   = ""
        TabBtn.AutoButtonColor        = false
        TabBtn.LayoutOrder            = #tabBtns + 1
        TabBtn.ZIndex                 = 3
        TabBtn.Parent                 = Sidebar
        Corner(TabBtn, 6)

        -- Lucide icon on the tab
        local tabIco = LucideIcon(TabBtn, iconName, 14, C.TextSec)
        tabIco.Position   = UDim2.new(0, 8, 0.5, -7)
        tabIco.ZIndex     = 4

        local TabLbl = Lbl(TabBtn, name, 12, C.TextSec, false, nil, 4)
        TabLbl.Size     = UDim2.new(1, -30, 1, 0)
        TabLbl.Position = UDim2.new(0, 28, 0, 0)

        -- Page (scrollable)
        local Page = Instance.new("ScrollingFrame")
        Page.Size                  = UDim2.new(1,0,1,0)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel        = 0
        Page.ScrollBarThickness     = 3
        Page.ScrollBarImageColor3   = C.Accent
        Page.CanvasSize             = UDim2.new(0,0,0,0)
        Page.AutomaticCanvasSize    = Enum.AutomaticSize.Y
        Page.Visible                = false
        Page.Parent                 = Content
        Pad(Page, 12, 12, 10, 10)

        local PL = Instance.new("UIListLayout")
        PL.Padding   = UDim.new(0,8)
        PL.SortOrder = Enum.SortOrder.LayoutOrder
        PL.Parent    = Page

        tabPages[name] = Page
        tabBtns[name]  = TabBtn

        TabBtn.MouseEnter:Connect(function()
            if activeTab ~= name then
                Tw(TabBtn, { BackgroundTransparency=0, BackgroundColor3=C.Elevated })
                Tw(TabLbl, { TextColor3=C.TextPri })
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if activeTab ~= name then
                Tw(TabBtn, { BackgroundTransparency=1 })
                Tw(TabLbl, { TextColor3=C.TextSec })
            end
        end)
        TabBtn.MouseButton1Click:Connect(function() SelectTab(name) end)
        if activeTab == nil then SelectTab(name) end

        -- ── Row factory ──────────────────────────────────────────
        local function Row(h)
            local r = Instance.new("Frame")
            r.Size             = UDim2.new(1,0,0,h or 36)
            r.BackgroundColor3 = C.Surface
            r.BorderSizePixel  = 0
            r.LayoutOrder      = 9999
            r.ZIndex           = 2
            r.Parent           = Page
            Corner(r, 6)
            Stroke(r, C.Border, 1)
            return r
        end

        local tab = {}

        -- Section
        function tab:AddSection(text, iconN)
            local sec = Instance.new("Frame")
            sec.Size                  = UDim2.new(1,0,0,26)
            sec.BackgroundTransparency = 1
            sec.LayoutOrder           = 9999
            sec.ZIndex                = 2
            sec.Parent                = Page

            if iconN then
                local sIco = LucideIcon(sec, iconN, 12, C.Accent)
                sIco.Position = UDim2.new(0,2,0.5,-6)
                sIco.ZIndex   = 3
            end

            local l = Lbl(sec, text:upper(), 10, C.TextSec, true, nil, 3)
            l.Size     = UDim2.new(1, iconN and -20 or -8, 1, 0)
            l.Position = UDim2.new(0, iconN and 18 or 8, 0, 0)

            local line = Instance.new("Frame")
            line.Size             = UDim2.new(0,0,0,1)
            line.Position         = UDim2.new(0,0,1,-1)
            line.BackgroundColor3 = C.Accent
            line.BorderSizePixel  = 0
            line.ZIndex           = 3
            line.Parent           = sec
            Corner(line, 1)
            task.delay(0.05, function()
                Tw(line, { Size=UDim2.new(1,0,0,1) }, 0.35)
            end)
        end

        -- Button
        function tab:AddButton(cfg2)
            cfg2 = cfg2 or {}
            local h   = cfg2.Description and 52 or 36
            local row = Row(h)

            local ox = 12
            if cfg2.Icon then
                local bIco = LucideIcon(row, cfg2.Icon, 16, C.Accent)
                bIco.Position = UDim2.new(0,10,0.5,-8)
                bIco.ZIndex   = 3
                ox = 32
            end

            local l = Lbl(row, cfg2.Text or "Button", 13, C.TextPri, false, nil, 3)
            l.Size     = UDim2.new(1, -ox-8, 0,18)
            l.Position = UDim2.new(0, ox, 0, cfg2.Description and 8 or 9)

            if cfg2.Description then
                local d = Lbl(row, cfg2.Description, 11, C.TextSec, false, nil, 3)
                d.Size     = UDim2.new(1,-ox-8,0,14)
                d.Position = UDim2.new(0,ox,0,30)
            end

            -- Right chevron icon
            local arr = LucideIcon(row, "chevron-right", 12, C.TextDis)
            arr.Position = UDim2.new(1,-18,0.5,-6)
            arr.ZIndex   = 3

            local btn = Instance.new("TextButton")
            btn.Size             = UDim2.new(1,0,1,0)
            btn.BackgroundTransparency = 1
            btn.Text             = ""
            btn.AutoButtonColor  = false
            btn.ZIndex           = 4
            btn.Parent           = row

            btn.MouseEnter:Connect(function()  Tw(row,{BackgroundColor3=C.Elevated}) end)
            btn.MouseLeave:Connect(function()  Tw(row,{BackgroundColor3=C.Surface})  end)
            btn.MouseButton1Down:Connect(function() Tw(row,{BackgroundColor3=C.Border}) end)
            btn.MouseButton1Up:Connect(function()   Tw(row,{BackgroundColor3=C.Elevated}) end)
            btn.MouseButton1Click:Connect(function()
                if cfg2.Callback then task.spawn(cfg2.Callback) end
            end)
            return btn
        end

        -- Toggle
        function tab:AddToggle(cfg2)
            cfg2  = cfg2 or {}
            local row   = Row(44)
            local state = cfg2.Default or false

            if cfg2.Icon then
                local ti2 = LucideIcon(row, cfg2.Icon, 14, C.Accent)
                ti2.Position = UDim2.new(0,10,0.5,-7)
                ti2.ZIndex   = 3
            end
            local ox = cfg2.Icon and 30 or 12
            local l = Lbl(row, cfg2.Text or "Toggle", 13, C.TextPri, false, nil, 3)
            l.Size     = UDim2.new(1,-80,0,18)
            l.Position = UDim2.new(0,ox,0,cfg2.Description and 6 or 13)

            if cfg2.Description then
                local d = Lbl(row, cfg2.Description, 11, C.TextSec, false, nil, 3)
                d.Size     = UDim2.new(1,-80,0,14)
                d.Position = UDim2.new(0,ox,0,26)
            end

            local Track = Instance.new("Frame")
            Track.Size             = UDim2.new(0,40,0,20)
            Track.Position         = UDim2.new(1,-52,0.5,-10)
            Track.BackgroundColor3 = state and C.Accent or C.Border
            Track.BorderSizePixel  = 0
            Track.ZIndex           = 3
            Track.Parent           = row
            Corner(Track, 10)

            local Knob = Instance.new("Frame")
            Knob.Size             = UDim2.new(0,14,0,14)
            Knob.Position         = state and UDim2.new(0,22,0.5,-7) or UDim2.new(0,4,0.5,-7)
            Knob.BackgroundColor3 = C.TextPri
            Knob.BorderSizePixel  = 0
            Knob.ZIndex           = 4
            Knob.Parent           = Track
            Corner(Knob, 7)

            local function Refresh()
                if state then
                    Tw(Track,{BackgroundColor3=C.Accent})
                    Tw(Knob, {Position=UDim2.new(0,22,0.5,-7)})
                else
                    Tw(Track,{BackgroundColor3=C.Border})
                    Tw(Knob, {Position=UDim2.new(0,4,0.5,-7)})
                end
            end

            local tb2 = Instance.new("TextButton")
            tb2.Size             = UDim2.new(1,0,1,0)
            tb2.BackgroundTransparency = 1
            tb2.Text             = ""
            tb2.AutoButtonColor  = false
            tb2.ZIndex           = 5
            tb2.Parent           = row
            tb2.MouseButton1Click:Connect(function()
                state = not state; Refresh()
                if cfg2.Callback then task.spawn(cfg2.Callback, state) end
            end)

            local ctrl = {}
            function ctrl:Set(v) state=v; Refresh() end
            function ctrl:Get() return state end
            return ctrl
        end

        -- Slider
        function tab:AddSlider(cfg2)
            cfg2  = cfg2 or {}
            local row  = Row(54)
            local min  = cfg2.Min     or 0
            local max  = cfg2.Max     or 100
            local val  = cfg2.Default or min
            local step = cfg2.Step    or 1

            local top = Instance.new("Frame")
            top.Size                  = UDim2.new(1,-24,0,20)
            top.Position              = UDim2.new(0,12,0,8)
            top.BackgroundTransparency = 1
            top.ZIndex                = 3
            top.Parent                = row

            if cfg2.Icon then
                local si = LucideIcon(top, cfg2.Icon, 14, C.Accent)
                si.Position = UDim2.new(0,0,0.5,-7)
                si.ZIndex   = 4
            end
            local ox2 = cfg2.Icon and 18 or 0
            local nl = Lbl(top, cfg2.Text or "Slider", 13, C.TextPri, false, nil, 4)
            nl.Size     = UDim2.new(1,-60-ox2,1,0)
            nl.Position = UDim2.new(0,ox2,0,0)

            local vl = Lbl(top, tostring(val)..(cfg2.Suffix or ""), 13, C.Accent, true, Enum.TextXAlignment.Right, 4)
            vl.Size     = UDim2.new(0,55,1,0)
            vl.Position = UDim2.new(1,-55,0,0)

            local Trk = Instance.new("Frame")
            Trk.Size             = UDim2.new(1,-24,0,6)
            Trk.Position         = UDim2.new(0,12,0,36)
            Trk.BackgroundColor3 = C.Border
            Trk.BorderSizePixel  = 0
            Trk.ZIndex           = 3
            Trk.Parent           = row
            Corner(Trk,3)

            local Fill = Instance.new("Frame")
            Fill.Size             = UDim2.new((val-min)/(max-min),0,1,0)
            Fill.BackgroundColor3 = C.Accent
            Fill.BorderSizePixel  = 0
            Fill.ZIndex           = 4
            Fill.Parent           = Trk
            Corner(Fill,3)

            local Handle = Instance.new("Frame")
            Handle.Size             = UDim2.new(0,14,0,14)
            Handle.AnchorPoint      = Vector2.new(0.5,0.5)
            Handle.Position         = UDim2.new((val-min)/(max-min),0,0.5,0)
            Handle.BackgroundColor3 = C.TextPri
            Handle.BorderSizePixel  = 0
            Handle.ZIndex           = 5
            Handle.Parent           = Trk
            Corner(Handle,7)
            Stroke(Handle,C.Accent,2)

            local sliding = false
            local function Update(x)
                local pct = math.clamp((x-Trk.AbsolutePosition.X)/Trk.AbsoluteSize.X,0,1)
                val = math.clamp(math.round((min+(max-min)*pct)/step)*step,min,max)
                local fp = (val-min)/(max-min)
                Fill.Size        = UDim2.new(fp,0,1,0)
                Handle.Position  = UDim2.new(fp,0,0.5,0)
                vl.Text          = tostring(val)..(cfg2.Suffix or "")
                if cfg2.Callback then task.spawn(cfg2.Callback,val) end
            end

            local TrkBtn = Instance.new("TextButton")
            TrkBtn.Size             = UDim2.new(1,0,0,26)
            TrkBtn.Position         = UDim2.new(0,0,0,-10)
            TrkBtn.BackgroundTransparency = 1
            TrkBtn.Text             = ""
            TrkBtn.AutoButtonColor  = false
            TrkBtn.ZIndex           = 6
            TrkBtn.Parent           = Trk
            TrkBtn.MouseButton1Down:Connect(function(x) sliding=true; Update(x) end)
            UIS.InputChanged:Connect(function(i)
                if sliding and i.UserInputType==Enum.UserInputType.MouseMovement then Update(i.Position.X) end
            end)
            UIS.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=false end
            end)

            local ctrl = {}
            function ctrl:Set(v)
                val=math.clamp(v,min,max)
                local fp=(val-min)/(max-min)
                Fill.Size=UDim2.new(fp,0,1,0)
                Handle.Position=UDim2.new(fp,0,0.5,0)
                vl.Text=tostring(val)..(cfg2.Suffix or "")
            end
            function ctrl:Get() return val end
            return ctrl
        end

        -- Dropdown
        function tab:AddDropdown(cfg2)
            cfg2     = cfg2 or {}
            local options  = cfg2.Options or {}
            local selected = cfg2.Default or options[1] or "Select..."
            local open     = false

            local Wrap = Instance.new("Frame")
            Wrap.Size                  = UDim2.new(1,0,0,36)
            Wrap.BackgroundTransparency = 1
            Wrap.ClipsDescendants      = false
            Wrap.LayoutOrder           = 9999
            Wrap.ZIndex                = 2
            Wrap.Parent                = Page

            local row = Instance.new("Frame")
            row.Size             = UDim2.new(1,0,0,36)
            row.BackgroundColor3 = C.Surface
            row.BorderSizePixel  = 0
            row.ZIndex           = 3
            row.Parent           = Wrap
            Corner(row,6); Stroke(row,C.Border,1)

            if cfg2.Icon then
                local di = LucideIcon(row, cfg2.Icon, 14, C.Accent)
                di.Position = UDim2.new(0,8,0.5,-7)
                di.ZIndex   = 4
            end
            local ox3 = cfg2.Icon and 28 or 12
            local nl2 = Lbl(row, cfg2.Text or "Dropdown", 13, C.TextPri, false, nil, 4)
            nl2.Size     = UDim2.new(0.45,-ox3,1,0)
            nl2.Position = UDim2.new(0,ox3,0,0)

            local selLbl = Lbl(row, selected, 13, C.Accent, false, Enum.TextXAlignment.Right, 4)
            selLbl.Size     = UDim2.new(0.5,-26,1,0)
            selLbl.Position = UDim2.new(0.5,0,0,0)

            local arrIco = LucideIcon(row, "chevron-down", 12, C.TextSec)
            arrIco.Position = UDim2.new(1,-18,0.5,-6)
            arrIco.ZIndex   = 4

            local DL = Instance.new("Frame")
            DL.Size             = UDim2.new(1,0,0,0)
            DL.Position         = UDim2.new(0,0,1,4)
            DL.BackgroundColor3 = C.Elevated
            DL.BorderSizePixel  = 0
            DL.ClipsDescendants = true
            DL.ZIndex           = 10
            DL.Visible          = false
            DL.Parent           = Wrap
            Corner(DL,6); Stroke(DL,C.Border,1)
            Pad(DL,4)

            local DLL = Instance.new("UIListLayout")
            DLL.Padding=UDim.new(0,2); DLL.Parent=DL

            local tH = #options*34+8
            for _, opt in ipairs(options) do
                local ob = Instance.new("TextButton")
                ob.Size             = UDim2.new(1,0,0,30)
                ob.BackgroundColor3 = C.Elevated
                ob.BackgroundTransparency = 1
                ob.Text             = opt
                ob.TextColor3       = C.TextSec
                ob.TextSize         = 13
                ob.Font             = Enum.Font.Gotham
                ob.AutoButtonColor  = false
                ob.ZIndex           = 11
                ob.Parent           = DL
                Corner(ob,4)
                ob.MouseEnter:Connect(function() Tw(ob,{BackgroundTransparency=0,BackgroundColor3=C.Border,TextColor3=C.TextPri}) end)
                ob.MouseLeave:Connect(function() Tw(ob,{BackgroundTransparency=1,TextColor3=C.TextSec}) end)
                ob.MouseButton1Click:Connect(function()
                    selected=opt; selLbl.Text=opt; open=false
                    Tw(DL,{Size=UDim2.new(1,0,0,0)},0.15)
                    Tw(Wrap,{Size=UDim2.new(1,0,0,36)},0.15)
                    task.delay(0.15,function() DL.Visible=false end)
                    if cfg2.Callback then task.spawn(cfg2.Callback,opt) end
                end)
            end

            local RB = Instance.new("TextButton")
            RB.Size             = UDim2.new(1,0,1,0)
            RB.BackgroundTransparency = 1
            RB.Text=""
            RB.AutoButtonColor=false
            RB.ZIndex=5
            RB.Parent=row
            RB.MouseButton1Click:Connect(function()
                open=not open
                if open then
                    DL.Visible=true
                    Tw(DL,{Size=UDim2.new(1,0,0,tH)},0.2)
                    Tw(Wrap,{Size=UDim2.new(1,0,0,36+tH+4)},0.2)
                else
                    Tw(DL,{Size=UDim2.new(1,0,0,0)},0.15)
                    Tw(Wrap,{Size=UDim2.new(1,0,0,36)},0.15)
                    task.delay(0.15,function() DL.Visible=false end)
                end
            end)

            local ctrl={}
            function ctrl:Get() return selected end
            function ctrl:Set(v) selected=v; selLbl.Text=v end
            return ctrl
        end

        -- Textbox
        function tab:AddTextbox(cfg2)
            cfg2 = cfg2 or {}
            local row = Row(44)

            if cfg2.Icon then
                local xi = LucideIcon(row, cfg2.Icon, 14, C.Accent)
                xi.Position = UDim2.new(0,8,0,8)
                xi.ZIndex   = 3
            end
            local ox4 = cfg2.Icon and 28 or 12
            local l = Lbl(row, cfg2.Text or "Input", 13, C.TextPri, false, nil, 3)
            l.Size     = UDim2.new(1,-24,0,16)
            l.Position = UDim2.new(0,ox4,0,6)

            local Box = Instance.new("TextBox")
            Box.Size             = UDim2.new(1,-24,0,18)
            Box.Position         = UDim2.new(0,12,0,24)
            Box.BackgroundTransparency = 1
            Box.Text             = cfg2.Default or ""
            Box.TextColor3       = C.TextPri
            Box.PlaceholderText  = cfg2.Placeholder or "Type here..."
            Box.PlaceholderColor3= C.TextDis
            Box.TextSize         = 13
            Box.Font             = Enum.Font.Gotham
            Box.TextXAlignment   = Enum.TextXAlignment.Left
            Box.ClearTextOnFocus = cfg2.ClearOnFocus ~= false
            Box.ZIndex           = 3
            Box.Parent           = row

            local ULine = Instance.new("Frame")
            ULine.Size             = UDim2.new(1,-24,0,1)
            ULine.Position         = UDim2.new(0,12,1,-1)
            ULine.BackgroundColor3 = C.Border
            ULine.BorderSizePixel  = 0
            ULine.ZIndex           = 3
            ULine.Parent           = row

            Box.Focused:Connect(function() Tw(ULine,{BackgroundColor3=C.Accent}) end)
            Box.FocusLost:Connect(function(enter)
                Tw(ULine,{BackgroundColor3=C.Border})
                if cfg2.Callback then task.spawn(cfg2.Callback,Box.Text,enter) end
            end)

            local ctrl={}
            function ctrl:Get() return Box.Text end
            function ctrl:Set(v) Box.Text=v end
            return ctrl
        end

        -- Label
        function tab:AddLabel(text, col2, iconN)
            local r = Instance.new("Frame")
            r.Size                  = UDim2.new(1,0,0,28)
            r.BackgroundTransparency = 1
            r.LayoutOrder           = 9999
            r.ZIndex                = 2
            r.Parent                = Page
            if iconN then
                local li = LucideIcon(r, iconN, 13, C.Accent)
                li.Position = UDim2.new(0,4,0.5,-6)
                li.ZIndex   = 3
            end
            local l = Lbl(r, text or "", 13, col2 or C.TextSec, false, nil, 3)
            l.Size     = UDim2.new(1, iconN and -22 or -8, 1, 0)
            l.Position = UDim2.new(0, iconN and 22 or 8, 0, 0)
            return l
        end

        -- Keybind
        function tab:AddKeybind(cfg2)
            cfg2    = cfg2 or {}
            local row     = Row(36)
            local current = cfg2.Default or Enum.KeyCode.Unknown
            local binding = false

            local nl3 = Lbl(row, cfg2.Text or "Keybind", 13, C.TextPri, false, nil, 3)
            nl3.Size     = UDim2.new(1,-110,1,0)
            nl3.Position = UDim2.new(0,12,0,0)

            local KB = Instance.new("TextButton")
            KB.Size             = UDim2.new(0,90,0,22)
            KB.Position         = UDim2.new(1,-100,0.5,-11)
            KB.BackgroundColor3 = C.Elevated
            KB.Text             = current.Name
            KB.TextColor3       = C.Accent
            KB.TextSize         = 12
            KB.Font             = Enum.Font.GothamBold
            KB.AutoButtonColor  = false
            KB.ZIndex           = 3
            KB.Parent           = row
            Corner(KB,4); Stroke(KB,C.Border,1)

            KB.MouseButton1Click:Connect(function() binding=true; KB.Text="..."; KB.TextColor3=C.Warning end)
            UIS.InputBegan:Connect(function(inp,gp)
                if binding and not gp and inp.UserInputType==Enum.UserInputType.Keyboard then
                    binding=false; current=inp.KeyCode
                    KB.Text=inp.KeyCode.Name; KB.TextColor3=C.Accent
                    if cfg2.Callback then task.spawn(cfg2.Callback,inp.KeyCode) end
                end
            end)

            local ctrl={}
            function ctrl:Get() return current end
            return ctrl
        end

        return tab
    end

    -- ════════════════════════════════════════════════════════════
    --   BUILT-IN OUTPUT CONSOLE TAB
    -- ════════════════════════════════════════════════════════════
    local logEntries = {}  -- { text, level }
    local consoleLabel = nil

    if consoleEnabled then
        local ConTab = Instance.new("TextButton")
        ConTab.Size                   = UDim2.new(1,0,0,34)
        ConTab.BackgroundColor3       = C.Elevated
        ConTab.BackgroundTransparency = 1
        ConTab.Text                   = ""
        ConTab.AutoButtonColor        = false
        ConTab.LayoutOrder            = 99
        ConTab.ZIndex                 = 3
        ConTab.Parent                 = Sidebar
        Corner(ConTab, 6)

        local cIco = LucideIcon(ConTab, "terminal", 14, C.TextSec)
        cIco.Position = UDim2.new(0,8,0.5,-7)
        cIco.ZIndex   = 4

        local cLbl = Lbl(ConTab, "Console", 12, C.TextSec, false, nil, 4)
        cLbl.Size     = UDim2.new(1,-30,1,0)
        cLbl.Position = UDim2.new(0,28,0,0)

        -- Console page
        local ConPage = Instance.new("Frame")
        ConPage.Size                  = UDim2.new(1,0,1,0)
        ConPage.BackgroundColor3      = C.ConsoleBg
        ConPage.BorderSizePixel       = 0
        ConPage.Visible               = false
        ConPage.ZIndex                = 2
        ConPage.Parent                = Content

        -- Console header toolbar
        local ConHeader = Instance.new("Frame")
        ConHeader.Size             = UDim2.new(1,0,0,36)
        ConHeader.BackgroundColor3 = C.Surface
        ConHeader.BorderSizePixel  = 0
        ConHeader.ZIndex           = 4
        ConHeader.Parent           = ConPage

        -- "Output" title in header
        local conTitleIco = LucideIcon(ConHeader, "scroll-text", 14, C.Accent)
        conTitleIco.Position = UDim2.new(0,10,0.5,-7)
        conTitleIco.ZIndex   = 5

        local conTitle = Lbl(ConHeader, "Output Console", 13, C.TextPri, true, nil, 5)
        conTitle.Size     = UDim2.new(1,-120,1,0)
        conTitle.Position = UDim2.new(0,30,0,0)

        -- Clear button
        local ClearBtn = Instance.new("TextButton")
        ClearBtn.Size             = UDim2.new(0,28,0,22)
        ClearBtn.Position         = UDim2.new(1,-36,0.5,-11)
        ClearBtn.BackgroundColor3 = C.Elevated
        ClearBtn.Text             = ""
        ClearBtn.AutoButtonColor  = false
        ClearBtn.ZIndex           = 5
        ClearBtn.Parent           = ConHeader
        Corner(ClearBtn,5); Stroke(ClearBtn,C.Border,1)

        local clearIco = LucideIcon(ClearBtn,"trash-2",14,C.TextSec)
        clearIco.Position = UDim2.new(0.5,-7,0.5,-7)
        clearIco.ZIndex   = 6

        ClearBtn.MouseEnter:Connect(function() Tw(ClearBtn,{BackgroundColor3=C.Danger}) end)
        ClearBtn.MouseLeave:Connect(function() Tw(ClearBtn,{BackgroundColor3=C.Elevated}) end)

        -- Copy-all button
        local CopyBtn = Instance.new("TextButton")
        CopyBtn.Size             = UDim2.new(0,28,0,22)
        CopyBtn.Position         = UDim2.new(1,-68,0.5,-11)
        CopyBtn.BackgroundColor3 = C.Elevated
        CopyBtn.Text             = ""
        CopyBtn.AutoButtonColor  = false
        CopyBtn.ZIndex           = 5
        CopyBtn.Parent           = ConHeader
        Corner(CopyBtn,5); Stroke(CopyBtn,C.Border,1)

        local copyIco = LucideIcon(CopyBtn,"copy",14,C.TextSec)
        copyIco.Position = UDim2.new(0.5,-7,0.5,-7)
        copyIco.ZIndex   = 6

        CopyBtn.MouseEnter:Connect(function() Tw(CopyBtn,{BackgroundColor3=C.Accent}) end)
        CopyBtn.MouseLeave:Connect(function() Tw(CopyBtn,{BackgroundColor3=C.Elevated}) end)

        -- Bottom line below header
        local HLine = Instance.new("Frame")
        HLine.Size             = UDim2.new(1,0,0,1)
        HLine.Position         = UDim2.new(0,0,0,36)
        HLine.BackgroundColor3 = C.Border
        HLine.BorderSizePixel  = 0
        HLine.ZIndex           = 4
        HLine.Parent           = ConPage

        -- Log scroll area
        local LogScroll = Instance.new("ScrollingFrame")
        LogScroll.Size                  = UDim2.new(1,0,1,-37-34)
        LogScroll.Position              = UDim2.new(0,0,0,37)
        LogScroll.BackgroundTransparency = 1
        LogScroll.BorderSizePixel        = 0
        LogScroll.ScrollBarThickness     = 3
        LogScroll.ScrollBarImageColor3   = C.Accent
        LogScroll.CanvasSize             = UDim2.new(0,0,0,0)
        LogScroll.AutomaticCanvasSize    = Enum.AutomaticSize.Y
        LogScroll.ZIndex                 = 3
        LogScroll.Parent                 = ConPage
        Pad(LogScroll,8,8,6,6)

        local LogList = Instance.new("UIListLayout")
        LogList.Padding   = UDim.new(0,2)
        LogList.SortOrder = Enum.SortOrder.LayoutOrder
        LogList.Parent    = LogScroll

        -- Input bar at bottom
        local InputBar = Instance.new("Frame")
        InputBar.Size             = UDim2.new(1,0,0,34)
        InputBar.Position         = UDim2.new(0,0,1,-34)
        InputBar.BackgroundColor3 = C.Surface
        InputBar.BorderSizePixel  = 0
        InputBar.ZIndex           = 4
        InputBar.Parent           = ConPage

        local ITopLine = Instance.new("Frame")
        ITopLine.Size             = UDim2.new(1,0,0,1)
        ITopLine.BackgroundColor3 = C.Border
        ITopLine.BorderSizePixel  = 0
        ITopLine.ZIndex           = 5
        ITopLine.Parent           = InputBar

        -- ">" prompt icon
        local promptIco = LucideIcon(InputBar,"chevron-right",12,C.Accent)
        promptIco.Position = UDim2.new(0,8,0.5,-6)
        promptIco.ZIndex   = 5

        local CmdBox = Instance.new("TextBox")
        CmdBox.Size             = UDim2.new(1,-52,1,0)
        CmdBox.Position         = UDim2.new(0,24,0,0)
        CmdBox.BackgroundTransparency = 1
        CmdBox.Text             = ""
        CmdBox.TextColor3       = C.TextPri
        CmdBox.PlaceholderText  = "Enter command..."
        CmdBox.PlaceholderColor3= C.TextDis
        CmdBox.TextSize         = 12
        CmdBox.Font             = Enum.Font.Code
        CmdBox.TextXAlignment   = Enum.TextXAlignment.Left
        CmdBox.ClearTextOnFocus = false
        CmdBox.ZIndex           = 5
        CmdBox.Parent           = InputBar

        local RunBtn = Instance.new("TextButton")
        RunBtn.Size             = UDim2.new(0,26,0,22)
        RunBtn.Position         = UDim2.new(1,-30,0.5,-11)
        RunBtn.BackgroundColor3 = C.Accent
        RunBtn.Text             = ""
        RunBtn.AutoButtonColor  = false
        RunBtn.ZIndex           = 5
        RunBtn.Parent           = InputBar
        Corner(RunBtn,5)

        local runIco = LucideIcon(RunBtn,"play",12,C.TextPri)
        runIco.Position = UDim2.new(0.5,-6,0.5,-6)
        runIco.ZIndex   = 6

        RunBtn.MouseEnter:Connect(function() Tw(RunBtn,{BackgroundColor3=C.AccentDim}) end)
        RunBtn.MouseLeave:Connect(function() Tw(RunBtn,{BackgroundColor3=C.Accent}) end)

        -- ── Log entry factory ──────────────────────────────────────
        local levelMeta = {
            info    = { col=C.LogInfo,    prefix="[INFO]   ", ico="info"           },
            warn    = { col=C.LogWarn,    prefix="[WARN]   ", ico="alert-triangle" },
            error   = { col=C.LogError,   prefix="[ERROR]  ", ico="circle-x"       },
            success = { col=C.LogSuccess, prefix="[OK]     ", ico="check"          },
            system  = { col=C.LogSystem,  prefix="[SYS]    ", ico="zap"            },
            print   = { col=C.LogInfo,    prefix="[PRINT]  ", ico="chevron-right"  },
        }

        local logCount = 0
        local allText  = {}

        local function AddLogEntry(text, level)
            level = level or "info"
            local meta = levelMeta[level] or levelMeta["info"]
            logCount = logCount + 1
            local idx = logCount

            -- Timestamp
            local ts = os.date and os.date("!%H:%M:%S") or tostring(tick()):sub(1,8)

            local fullText = meta.prefix .. ts .. "  " .. tostring(text)
            table.insert(allText, fullText)
            table.insert(logEntries, { text=fullText, level=level })

            local row = Instance.new("Frame")
            row.Name             = "Log_"..idx
            row.Size             = UDim2.new(1,0,0,22)
            row.BackgroundColor3 = C.ConsoleBg
            row.BorderSizePixel  = 0
            row.LayoutOrder      = idx
            row.ZIndex           = 4
            row.Parent           = LogScroll

            -- Subtle hover
            local hBtn = Instance.new("TextButton")
            hBtn.Size             = UDim2.new(1,0,1,0)
            hBtn.BackgroundTransparency = 1
            hBtn.Text             = ""
            hBtn.AutoButtonColor  = false
            hBtn.ZIndex           = 6
            hBtn.Parent           = row
            hBtn.MouseEnter:Connect(function() Tw(row,{BackgroundColor3=C.Elevated}) end)
            hBtn.MouseLeave:Connect(function() Tw(row,{BackgroundColor3=C.ConsoleBg}) end)

            -- Level icon
            local ico2 = LucideIcon(row, meta.ico, 12, meta.col)
            ico2.Position = UDim2.new(0,2,0.5,-6)
            ico2.ZIndex   = 5

            -- Text
            local entryLbl = Instance.new("TextLabel")
            entryLbl.BackgroundTransparency = 1
            entryLbl.Size             = UDim2.new(1,-20,1,0)
            entryLbl.Position         = UDim2.new(0,20,0,0)
            entryLbl.Text             = fullText
            entryLbl.TextColor3       = meta.col
            entryLbl.TextSize         = 11
            entryLbl.Font             = Enum.Font.Code
            entryLbl.TextXAlignment   = Enum.TextXAlignment.Left
            entryLbl.TextTruncate     = Enum.TextTruncate.AtEnd
            entryLbl.ZIndex           = 5
            entryLbl.Parent           = row

            -- Auto-scroll to bottom
            task.defer(function()
                LogScroll.CanvasPosition = Vector2.new(0, LogScroll.AbsoluteCanvasSize.Y)
            end)
        end

        -- Clear
        ClearBtn.MouseButton1Click:Connect(function()
            for _, ch in ipairs(LogScroll:GetChildren()) do
                if ch:IsA("Frame") then ch:Destroy() end
            end
            logEntries = {}
            allText    = {}
            logCount   = 0
            AddLogEntry("Console cleared.", "system")
        end)

        -- Copy all
        CopyBtn.MouseButton1Click:Connect(function()
            local joined = table.concat(allText, "\n")
            if setclipboard then
                setclipboard(joined)
                AddLogEntry("Copied "..#allText.." lines to clipboard.", "success")
            else
                AddLogEntry("Clipboard not available in Studio.", "warn")
            end
        end)

        -- Run command
        local function RunCommand()
            local cmd = CmdBox.Text
            if cmd == "" then return end
            AddLogEntry("> " .. cmd, "system")
            CmdBox.Text = ""
            local ok, err = pcall(function()
                local f = loadstring(cmd)
                if f then f() else
                    AddLogEntry("Syntax error in command.", "error")
                end
            end)
            if not ok then
                AddLogEntry(tostring(err), "error")
            end
        end

        RunBtn.MouseButton1Click:Connect(RunCommand)
        CmdBox.FocusLost:Connect(function(enter)
            if enter then RunCommand() end
        end)

        -- Hook print / warn / error
        local _print = print
        local _warn  = warn
        local function hookPrint(...)
            local args = {...}
            local msg  = table.concat(args, "\t")
            AddLogEntry(msg, "print")
            _print(...)  -- also send to actual Roblox console
        end
        local function hookWarn(...)
            local args = {...}
            local msg  = table.concat(args, "\t")
            AddLogEntry(msg, "warn")
            _warn(...)
        end
        print = hookPrint
        warn  = hookWarn

        -- Tab button selection
        tabPages["__console__"] = ConPage
        tabBtns["__console__"]  = ConTab

        ConTab.MouseEnter:Connect(function()
            if activeTab ~= "__console__" then
                Tw(ConTab,{BackgroundTransparency=0,BackgroundColor3=C.Elevated})
                Tw(cLbl,{TextColor3=C.TextPri})
            end
        end)
        ConTab.MouseLeave:Connect(function()
            if activeTab ~= "__console__" then
                Tw(ConTab,{BackgroundTransparency=1})
                Tw(cLbl,{TextColor3=C.TextSec})
            end
        end)
        ConTab.MouseButton1Click:Connect(function() SelectTab("__console__") end)

        -- Startup message
        task.delay(0.1, function()
            AddLogEntry("DarkUI v3.0 Console ready.", "system")
            AddLogEntry("Type commands below and press Enter or ▶ to run.", "info")
        end)

        -- Expose log to window
        function win:Log(text, level)
            AddLogEntry(text, level or "info")
        end
    end

    -- ════════════════════════════════════════════════════════════
    --   FLOATING TOGGLE BUTTON
    -- ════════════════════════════════════════════════════════════
    local ToggleBtn = Instance.new("Frame")
    ToggleBtn.Name             = "DarkUI_ToggleBtn"
    ToggleBtn.Size             = UDim2.new(0, 46, 0, 46)
    ToggleBtn.Position         = UDim2.new(0, 16, 0.5, -23)
    ToggleBtn.BackgroundColor3 = C.Surface
    ToggleBtn.BorderSizePixel  = 0
    ToggleBtn.ZIndex           = 20
    ToggleBtn.Parent           = sg
    Corner(ToggleBtn, 13)
    Stroke(ToggleBtn, C.Accent, 2)

    -- Glow
    local TBGlow = Instance.new("ImageLabel")
    TBGlow.BackgroundTransparency = 1
    TBGlow.Image      = "rbxassetid://6014261993"
    TBGlow.ImageColor3= C.Accent
    TBGlow.ImageTransparency = 0.72
    TBGlow.Size       = UDim2.new(1,18,1,18)
    TBGlow.Position   = UDim2.new(0,-9,0,-9)
    TBGlow.ScaleType  = Enum.ScaleType.Slice
    TBGlow.SliceCenter= Rect.new(49,49,450,450)
    TBGlow.ZIndex     = 19
    TBGlow.Parent     = ToggleBtn

    -- Lucide icon inside toggle (layout-dashboard = menu grid)
    local togIco = LucideIcon(ToggleBtn, "layout-dashboard", 20, C.Accent)
    togIco.Position = UDim2.new(0.5,-10,0.5,-10)
    togIco.ZIndex   = 21

    -- Make toggle button draggable
    MakeDraggable(ToggleBtn, ToggleBtn)

    local winVisible = true
    local function SetVisible(v)
        winVisible = v
        if v then
            Main.Visible = true
            Tw(Main, { Size=savedSize }, 0.25, Enum.EasingStyle.Back)
            -- swap icon to X
            for _,ch in ipairs(togIco:GetDescendants()) do
                if ch:IsA("Frame") then Tw(ch,{BackgroundColor3=C.Danger}) end
            end
            Tw(ToggleBtn,{BackgroundColor3=Color3.fromRGB(30,14,14)})
            Tw(TBGlow,{ImageColor3=C.Danger})
        else
            Tw(Main, {Size=UDim2.new(0,width,0,0)}, 0.18)
            task.delay(0.18, function() Main.Visible=false end)
            for _,ch in ipairs(togIco:GetDescendants()) do
                if ch:IsA("Frame") then Tw(ch,{BackgroundColor3=C.Accent}) end
            end
            Tw(ToggleBtn,{BackgroundColor3=C.Surface})
            Tw(TBGlow,{ImageColor3=C.Accent})
        end
    end

    local TogBtn2 = Instance.new("TextButton")
    TogBtn2.Size             = UDim2.new(1,0,1,0)
    TogBtn2.BackgroundTransparency = 1
    TogBtn2.Text             = ""
    TogBtn2.AutoButtonColor  = false
    TogBtn2.ZIndex           = 22
    TogBtn2.Parent           = ToggleBtn
    TogBtn2.MouseButton1Click:Connect(function() SetVisible(not winVisible) end)
    TogBtn2.MouseEnter:Connect(function() Tw(ToggleBtn,{Size=UDim2.new(0,50,0,50),Position=UDim2.new(ToggleBtn.Position.X.Scale,ToggleBtn.Position.X.Offset-2,ToggleBtn.Position.Y.Scale,ToggleBtn.Position.Y.Offset-2)}) end)
    TogBtn2.MouseLeave:Connect(function() Tw(ToggleBtn,{Size=UDim2.new(0,46,0,46),Position=UDim2.new(ToggleBtn.Position.X.Scale,ToggleBtn.Position.X.Offset+2,ToggleBtn.Position.Y.Scale,ToggleBtn.Position.Y.Offset+2)}) end)

    UIS.InputBegan:Connect(function(inp,gp)
        if not gp and inp.KeyCode==toggleKey then SetVisible(not winVisible) end
    end)

    -- ── Notify ────────────────────────────────────────────────────
    function win:Notify(cfg2)
        cfg2 = cfg2 or {}
        local nT  = cfg2.Title or "Notification"
        local nD  = cfg2.Description or ""
        local nDur= cfg2.Duration or 3
        local nLv = cfg2.Type or "info"
        local tC  = ({info=C.Accent,success=C.Success,warning=C.Warning,danger=C.Danger})[nLv] or C.Accent
        local nW, nH = 296, 66+(nD~="" and 18 or 0)
        local nSg = GetSG()

        local nF = Instance.new("Frame")
        nF.Size             = UDim2.new(0,nW,0,0)
        nF.Position         = UDim2.new(1,-(nW+16),1,-16-nH)
        nF.BackgroundColor3 = C.Surface
        nF.BorderSizePixel  = 0
        nF.ClipsDescendants = true
        nF.ZIndex           = 30
        nF.Parent           = nSg
        Corner(nF,8); Stroke(nF,C.Border,1)

        local bar = Instance.new("Frame")
        bar.Size             = UDim2.new(0,3,1,-16)
        bar.Position         = UDim2.new(0,10,0,8)
        bar.BackgroundColor3 = tC
        bar.BorderSizePixel  = 0
        bar.ZIndex           = 31
        bar.Parent           = nF
        Corner(bar,2)

        local nIconMap = {info="info",success="check",warning="alert-triangle",danger="circle-x"}
        local nIco = LucideIcon(nF, nIconMap[nLv] or "info", 14, tC)
        nIco.Position = UDim2.new(0,20,0,12)
        nIco.ZIndex   = 32

        local tL = Lbl(nF, nT, 13, C.TextPri, true, nil, 32)
        tL.Size     = UDim2.new(1,-38,0,16)
        tL.Position = UDim2.new(0,38,0,12)

        if nD~="" then
            local dL = Lbl(nF,nD,11,C.TextSec,false,nil,32)
            dL.Size     = UDim2.new(1,-38,0,14)
            dL.Position = UDim2.new(0,38,0,30)
        end

        local prog = Instance.new("Frame")
        prog.Size             = UDim2.new(1,0,0,2)
        prog.Position         = UDim2.new(0,0,1,-2)
        prog.BackgroundColor3 = tC
        prog.BorderSizePixel  = 0
        prog.ZIndex           = 31
        prog.Parent           = nF

        Tw(nF,{Size=UDim2.new(0,nW,0,nH)},0.25)
        task.delay(0.05,function()
            Tw(prog,{Size=UDim2.new(0,0,0,2)},nDur,Enum.EasingStyle.Linear)
        end)
        task.delay(nDur+0.05,function()
            Tw(nF,{Size=UDim2.new(0,nW,0,0)},0.2)
            task.delay(0.2,function() nF:Destroy() end)
        end)
    end

    function win:SetTitle(t) TitleLbl.Text=t end
    function win:Toggle() SetVisible(not winVisible) end
    function win:Destroy() Main:Destroy(); ToggleBtn:Destroy() end
    if not win.Log then
        function win:Log(text, level)
            -- no-op if console disabled
        end
    end

    return win
end

return DarkUI
