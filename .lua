local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Lib = {}
Lib.Flags = {}
Lib.ThemeBindings = {}
Lib.Refreshers = {}
Lib.AllToggles = {}
Lib.ThemeAlpha = {}

local function new(class, props)
    local inst = Instance.new(class)
    local parent = props.Parent
    props.Parent = nil
    for k, v in pairs(props) do
        inst[k] = v
    end
    inst.Parent = parent
    return inst
end

local function corner(parent, radius)
    return new("UICorner", { CornerRadius = UDim.new(0, radius or 10), Parent = parent })
end

local function bind(obj, prop, key, transProp, baseTrans)
    table.insert(Lib.ThemeBindings, {
        obj = obj, prop = prop, key = key,
        transProp = transProp, baseTrans = baseTrans or 0,
    })
end

function Lib:ApplyTheme()
    local th = self.Theme
    th.ToggleOn = th.Accent
    th.SliderKnob = th.Accent:Lerp(Color3.fromRGB(0, 0, 0), 0.15):Lerp(Color3.fromRGB(0, 200, 255), 0.2)
    th.SliderFill = th.Accent:Lerp(Color3.fromRGB(0, 0, 0), 0.2)
    for _, b in ipairs(self.ThemeBindings) do
        b.obj[b.prop] = th[b.key]
        if b.transProp then
            b.obj[b.transProp] = math.clamp(b.baseTrans + (Lib.ThemeAlpha[b.key] or 0), 0, 1)
        end
    end
    for _, fn in ipairs(self.Refreshers) do
        fn()
    end
    for _, t in ipairs(self.AllToggles) do
        t:Refresh()
    end
end

Lib.Theme = {
    Accent = Color3.fromRGB(0, 120, 255),
    Glow = Color3.fromRGB(0, 170, 255),
    Background = Color3.fromRGB(22, 22, 25),
    ContentColor = Color3.fromRGB(11, 11, 14),
    Second = Color3.fromRGB(18, 18, 21),
    CardColor = Color3.fromRGB(17, 19, 26),
    Text = Color3.fromRGB(235, 235, 240),
    SubText = Color3.fromRGB(145, 145, 155),
    GlowColor = Color3.fromRGB(45, 45, 50),
    TabHighlightColor = Color3.fromRGB(22, 42, 78),
    SidebarTransparency = 0.01,
    ContentTransparency = 0.001,
    HeaderTransparency = 0.2,
    HeaderHeight = 44,
    Radius = 10,
    Font = Enum.Font.GothamBold,
    TitleSize = 28,
    TitleColor = Color3.fromRGB(255, 255, 255),
    TitleY = 16,
    SectionFont = Enum.Font.GothamMedium,
    SectionSize = 11,
    TabFont = Enum.Font.GothamBold,
    TabSize = 15,
    UITransparency = 0.005,
    TabHighlight = 0.65,
    TabRadius = 4,
    TabExtra = 6,
    TabShift = 0,
    ToggleOn = Color3.fromRGB(0, 120, 255),
    ToggleOnPill = Color3.fromRGB(18, 28, 46),
    ToggleOff = Color3.fromRGB(52, 52, 58),
    ToggleOffKnob = Color3.fromRGB(255, 255, 255),
    SliderKnob = Color3.fromRGB(0, 132, 255),
    SliderFill = Color3.fromRGB(0, 96, 204),
    GroupFont = Enum.Font.GothamMedium,
    GroupSize = 11,
    CardTransparency = 0.15,
    CardRadius = 6,
    DividerTransparency = 0.75,
    RowDividerTransparency = 0.75,
    GlowPad = 12,
    NotifyDuration = 4,
}

local notifyCounter = 0
function Lib:Notify(cfg)
    if type(cfg) == "string" then
        cfg = { Text = cfg }
    end
    cfg = cfg or {}
    local host = self._NotifyHost
    if not host then return end
    local th = self.Theme
    notifyCounter += 1

    local accent = cfg.Accent or th.Accent
    local bg = accent:Lerp(Color3.fromRGB(0, 0, 0), 0.78)
    local title = (type(cfg.Title) == "string") and cfg.Title or ""
    local body = (type(cfg.Text) == "string") and cfg.Text or ""
    local duration = tonumber(cfg.Duration) or th.NotifyDuration or 4

    local textWidth = 224
    local titleH = title ~= "" and 18 or 0
    local bodyH = 0
    if body ~= "" then
        local ok, size = pcall(function()
            return TextService:GetTextSize(body, 12, th.TabFont, Vector2.new(textWidth, 10000))
        end)
        bodyH = (ok and size) and math.ceil(size.Y) or 16
    end
    local contentH = titleH + bodyH + ((titleH > 0 and bodyH > 0) and 4 or 0)
    local h = math.max(44, 12 + contentH + 14)

    local notif = new("CanvasGroup", {
        Name = "Notify",
        Size = UDim2.new(1, 0, 0, h),
        BackgroundColor3 = bg,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        GroupTransparency = 1,
        LayoutOrder = -notifyCounter,
        ZIndex = 60,
        Parent = host,
    })
    corner(notif, 8)

    new("TextLabel", {
        Text = "luau",
        Font = th.Font,
        TextSize = 20,
        TextColor3 = th.Glow,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 9, 0.5, -1),
        Size = UDim2.fromOffset(40, 30),
        BackgroundTransparency = 1,
        ZIndex = 2,
        Parent = notif,
    })
    new("TextLabel", {
        Text = "luau",
        Font = th.Font,
        TextSize = 20,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 10, 0.5, 0),
        Size = UDim2.fromOffset(40, 30),
        BackgroundTransparency = 1,
        ZIndex = 3,
        Parent = notif,
    })

    local textX = UDim2.new(0, 56, 0, 10)
    local textSize = UDim2.new(1, -66, 0, titleH)

    if title ~= "" and body == "" then
        textX = UDim2.new(0, 56, 0.5, -9)
    elseif title == "" and body ~= "" then
        textX = UDim2.new(0, 56, 0, 10)
        textSize = UDim2.new(1, -66, 0, bodyH)
    end

    if title ~= "" then
        new("TextLabel", {
            Text = title,
            Font = th.TabFont,
            TextSize = 14,
            TextColor3 = th.Text,
            BackgroundTransparency = 1,
            Position = textX,
            Size = textSize,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 3,
            Parent = notif,
        })
    end

    if body ~= "" then
        new("TextLabel", {
            Text = body,
            Font = th.TabFont,
            TextSize = 12,
            TextColor3 = th.SubText,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 56, title ~= "" and 0 or 0, title ~= "" and 32 or 10),
            Size = UDim2.new(1, -66, 0, bodyH),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            ZIndex = 3,
            Parent = notif,
        })
    end

    local barTrack = new("Frame", {
        Position = UDim2.new(0, 10, 1, -5),
        Size = UDim2.new(1, -20, 0, 2),
        BackgroundColor3 = th.SubText,
        BackgroundTransparency = 0.85,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = notif,
    })
    corner(barTrack, 1)

    local barFill = new("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
        ZIndex = 4,
        Parent = barTrack,
    })
    corner(barFill, 1)

    TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        GroupTransparency = 0,
    }):Play()

    local expire = TweenService:Create(barFill, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 1, 1, 0),
    })
    expire.Completed:Once(function()
        local fade = TweenService:Create(notif, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            GroupTransparency = 1,
        })
        fade.Completed:Once(function()
            notif:Destroy()
        end)
        fade:Play()
    end)
    expire:Play()
end

function Lib:Window(cfg)
    cfg = cfg or {}
    local theme = self.Theme
    local size = cfg.Size or UDim2.fromOffset(740, 500)
    local OFFSET_X, OFFSET_Y = 30, 20
    local PAD = theme.GlowPad
    local R = theme.Radius

    local animSpeed = 1
    local uiScaleValue = 1
    local uiToggleKey = cfg.ToggleKey or Enum.KeyCode.Insert
    local uiKeyListening = false
    local uiKeybindRow = nil
    local scaleDropdown = nil
    local syncSettings
    local wmSetElements
    local wmSetVisible

    local function T(d)
        return TweenInfo.new(d / animSpeed, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    end
    local function T2(d)
        return TweenInfo.new(d / animSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    end

    local userName = cfg.DisplayName or player.DisplayName
    local avatarId = cfg.AvatarId or player.UserId
    local tillDate = cfg.TillDate or "24.09.26"

    local gui = new("ScreenGui", {
        Name = cfg.Name or "CustomUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = playerGui,
    })

    local notifyHost = new("Frame", {
        Name = "NotifyHost",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -16, 0, 8),
        Size = UDim2.new(0, 300, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 60,
        Parent = gui,
    })
    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = notifyHost,
    })
    self._NotifyHost = notifyHost

    local glow = new("CanvasGroup", {
        Name = "WindowGlow",
        Size = UDim2.fromOffset(size.X.Offset + PAD * 2, size.Y.Offset + PAD * 2),
        Position = UDim2.new(0.5, -size.X.Offset / 2 + OFFSET_X - PAD, 0.5, -size.Y.Offset / 2 + OFFSET_Y - PAD),
        BackgroundTransparency = 1,
        GroupTransparency = 0,
        BorderSizePixel = 0,
        ZIndex = 0,
        Parent = gui,
    })

    for p = 1, PAD do
        local layer = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(size.X.Offset + p * 2, size.Y.Offset + p * 2),
            BackgroundColor3 = theme.GlowColor,
            BackgroundTransparency = 0.91 + (p - 1) * 0.008,
            BorderSizePixel = 0,
            Parent = glow,
        })
        corner(layer, R + p)
        bind(layer, "BackgroundColor3", "GlowColor")
    end

    local main = new("CanvasGroup", {
        Size = size,
        Position = UDim2.new(0.5, -size.X.Offset / 2 + OFFSET_X, 0.5, -size.Y.Offset / 2 + OFFSET_Y),
        BackgroundColor3 = theme.Background,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Active = true,
        GroupTransparency = theme.UITransparency,
        ZIndex = 1,
        Parent = gui,
    })
    corner(main, R)

    local mainScale = new("UIScale", { Parent = main })
    local glowScale = new("UIScale", { Parent = glow })

    local mainStroke = new("UIStroke", {
        Color = theme.GlowColor,
        Thickness = 1,
        Transparency = 0.6,
        Parent = main,
    })
    bind(mainStroke, "Color", "GlowColor", "Transparency", 0.6)

    local sidebar = new("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0.25, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = theme.Second,
        BackgroundTransparency = theme.SidebarTransparency,
        BorderSizePixel = 0,
        ZIndex = 1,
        Parent = main,
    })
    corner(sidebar, R)
    bind(sidebar, "BackgroundColor3", "Second", "BackgroundTransparency", theme.SidebarTransparency)

    local sidebarEdge = new("Frame", {
        Size = UDim2.new(0, R, 1, 0),
        Position = UDim2.new(1, -R, 0, 0),
        BackgroundColor3 = theme.Second,
        BackgroundTransparency = theme.SidebarTransparency,
        BorderSizePixel = 0,
        ZIndex = 1,
        Parent = sidebar,
    })
    bind(sidebarEdge, "BackgroundColor3", "Second", "BackgroundTransparency", theme.SidebarTransparency)

    local sidebarList = new("ScrollingFrame", {
        Name = "SidebarList",
        Size = UDim2.new(1, -34, 1, -100),
        Position = UDim2.new(0, 20, 0, 80),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageTransparency = 0.4,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ClipsDescendants = false,
        ZIndex = 2,
        Parent = sidebar,
    })

    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 3),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = sidebarList,
    })

    local titleShadow = new("TextLabel", {
        Name = "TitleShadow",
        Size = UDim2.new(0.25, 0, 0, 36),
        Position = UDim2.new(0, 0, 0, theme.TitleY - 1),
        BackgroundTransparency = 1,
        Text = cfg.Title or "LUAUSENSE",
        Font = theme.Font,
        TextSize = theme.TitleSize,
        TextColor3 = theme.Glow,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 3,
        Parent = main,
    })
    bind(titleShadow, "TextColor3", "Glow")

    local title = new("TextLabel", {
        Name = "Title",
        Size = UDim2.new(0.25, 0, 0, 36),
        Position = UDim2.new(0, 0, 0, theme.TitleY),
        BackgroundTransparency = 1,
        Text = cfg.Title or "LUAUSENSE",
        Font = theme.Font,
        TextSize = theme.TitleSize,
        TextColor3 = theme.Text,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 4,
        Parent = main,
    })
    bind(title, "TextColor3", "Text")

    local bottomDivider = new("Frame", {
        Name = "BottomDivider",
        Size = UDim2.new(0.25, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -60),
        BackgroundColor3 = theme.SubText,
        BackgroundTransparency = theme.DividerTransparency,
        BorderSizePixel = 0,
        ZIndex = 4,
        Parent = main,
    })
    bind(bottomDivider, "BackgroundColor3", "SubText")

    local profile = new("Frame", {
        Name = "Profile",
        Size = UDim2.new(0.25, 0, 0, 50),
        Position = UDim2.new(0, 0, 1, -54),
        BackgroundTransparency = 1,
        ZIndex = 4,
        Parent = main,
    })

    local avatar = new("ImageLabel", {
        Name = "Avatar",
        Size = UDim2.fromOffset(46, 46),
        Position = UDim2.new(0, 10, 0, 2),
        BackgroundTransparency = 1,
        Image = "rbxthumb://type=AvatarHeadShot&id=" .. avatarId .. "&w=150&h=150",
        ZIndex = 4,
        Parent = profile,
    })
    corner(avatar, 23)

    local nick = new("TextLabel", {
        Name = "Nick",
        Size = UDim2.new(1, -70, 0, 15),
        Position = UDim2.new(0, 62, 0, 9),
        BackgroundTransparency = 1,
        Text = userName,
        Font = theme.TabFont,
        TextSize = 14,
        TextColor3 = theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 4,
        Parent = profile,
    })
    bind(nick, "TextColor3", "Text")

    new("TextLabel", {
        Name = "Till",
        Size = UDim2.new(1, -70, 0, 12),
        Position = UDim2.new(0, 62, 0, 27),
        BackgroundTransparency = 1,
        RichText = true,
        Text = '<font color="#8C8C96">Till:</font> <font color="#00AAFF">' .. tillDate .. '</font>',
        Font = theme.TabFont,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
        Parent = profile,
    })

    local content = new("Frame", {
        Name = "Content",
        Size = UDim2.new(0.75, 1, 1, 0),
        Position = UDim2.new(0.25, -1, 0, 0),
        BackgroundColor3 = theme.ContentColor,
        BackgroundTransparency = theme.ContentTransparency,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = main,
    })
    corner(content, R)
    bind(content, "BackgroundColor3", "ContentColor", "BackgroundTransparency", theme.ContentTransparency)

    local contentEdge = new("Frame", {
        Size = UDim2.new(0, R + 1, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = theme.ContentColor,
        BackgroundTransparency = theme.ContentTransparency,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = content,
    })
    bind(contentEdge, "BackgroundColor3", "ContentColor", "BackgroundTransparency", theme.ContentTransparency)

    local header = new("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, theme.HeaderHeight),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = theme.ContentColor,
        BackgroundTransparency = theme.HeaderTransparency,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = content,
    })
    bind(header, "BackgroundColor3", "ContentColor", "BackgroundTransparency", theme.HeaderTransparency)

    local headerDivider = new("Frame", {
        Name = "HeaderDivider",
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = theme.SubText,
        BackgroundTransparency = theme.DividerTransparency,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = header,
    })
    bind(headerDivider, "BackgroundColor3", "SubText")

    local function addShadow(target)
        local shadow = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.new(1, 6, 1, 6),
            BackgroundColor3 = theme.GlowColor,
            BackgroundTransparency = 0.75,
            BorderSizePixel = 0,
            ZIndex = 1,
            Parent = target,
        })
        corner(shadow, 6)
        bind(shadow, "BackgroundColor3", "GlowColor")
        return shadow
    end

    local function addAccentGlow(target, radius)
        for i = 1, 2 do
            local layer = new("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.new(1, i * 4, 1, i * 4),
                BackgroundColor3 = theme.Glow,
                BackgroundTransparency = 0.78 + i * 0.07,
                BorderSizePixel = 0,
                ZIndex = 0,
                Parent = target,
            })
            corner(layer, (radius or 10) + i * 2)
            bind(layer, "BackgroundColor3", "Glow")
        end
    end

    local function addArrow(parent)
        local holder = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(1, -16, 0.5, 0),
            Size = UDim2.fromOffset(10, 10),
            BackgroundTransparency = 1,
            ZIndex = 9,
            Parent = parent,
        })
        local left = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.3, 0.55),
            Size = UDim2.fromOffset(2, 7),
            Rotation = -45,
            BackgroundColor3 = theme.SubText,
            BorderSizePixel = 0,
            ZIndex = 9,
            Parent = holder,
        })
        local right = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.7, 0.55),
            Size = UDim2.fromOffset(2, 7),
            Rotation = 45,
            BackgroundColor3 = theme.SubText,
            BorderSizePixel = 0,
            ZIndex = 9,
            Parent = holder,
        })
        return holder, left, right
    end

    local function pulseShadow(shadow)
        if not shadow then return end
        TweenService:Create(shadow, T2(0.2), { BackgroundTransparency = 0.45 }):Play()
    end

    local function calmShadow(shadow)
        if not shadow then return end
        TweenService:Create(shadow, T2(0.2), { BackgroundTransparency = 0.75 }):Play()
    end

    local openPopup = nil
    local popupUpdaters = {}
    local popupOwners = {}
    local popupShadows = {}
    local function registerPopup(popup, updater, owner, shadow)
        popupUpdaters[popup] = updater
        popupOwners[popup] = owner
        popupShadows[popup] = shadow
    end

    local function closePopup()
        if openPopup then
            openPopup.Visible = false
            calmShadow(popupShadows[openPopup])
            openPopup = nil
        end
    end

    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        if not openPopup then return end
        local mouse = input.Position
        local abs, asize = openPopup.AbsolutePosition, openPopup.AbsoluteSize
        local inside = mouse.X >= abs.X and mouse.X <= abs.X + asize.X
            and mouse.Y >= abs.Y and mouse.Y <= abs.Y + asize.Y
        if inside then return end
        local owner = popupOwners[openPopup]
        if owner then
            local oabs, osize = owner.AbsolutePosition, owner.AbsoluteSize
            local inOwner = mouse.X >= oabs.X and mouse.X <= oabs.X + osize.X
                and mouse.Y >= oabs.Y and mouse.Y <= oabs.Y + osize.Y
            if inOwner then return end
        end
        openPopup.Visible = false
        calmShadow(popupShadows[openPopup])
        openPopup = nil
    end)

    local function openPopupEx(popup)
        if openPopup and openPopup ~= popup then
            openPopup.Visible = false
            calmShadow(popupShadows[openPopup])
        end
        popup.Visible = true
        openPopup = popup
        pulseShadow(popupShadows[popup])
    end

    local function closePopupEx(popup)
        popup.Visible = false
        calmShadow(popupShadows[popup])
        if openPopup == popup then openPopup = nil end
    end

    local function makeDropdownRow(parent, order, cfg2)
        cfg2 = cfg2 or {}
        local name = cfg2.Name or "Dropdown"
        local items = cfg2.Items
        if type(items) ~= "table" then
            items = {}
        end
        local selected = cfg2.Default or items[1] or ""
        local callback = cfg2.Callback or function() end

        local row = new("Frame", {
            Name = name,
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundTransparency = 1,
            LayoutOrder = order,
            ZIndex = 7,
            Parent = parent,
        })

        local nameLabel = new("TextLabel", {
            Size = UDim2.new(0.32, -6, 1, 0),
            BackgroundTransparency = 1,
            Text = name,
            Font = theme.GroupFont,
            TextSize = 13,
            TextColor3 = theme.SubText,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 7,
            Parent = row,
        })

        local hovered = false
        local function refreshNameColor()
            TweenService:Create(nameLabel, TweenInfo.new(0.15), {
                TextColor3 = hovered and theme.Text or theme.SubText,
            }):Play()
        end
        table.insert(Lib.Refreshers, refreshNameColor)

        local box = new("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.new(0.68, -8, 0, 24),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Text = "",
            ZIndex = 8,
            Parent = row,
        })

        addShadow(box)

        local boxFill = new("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = theme.Second,
            BackgroundTransparency = 0.3,
            BorderSizePixel = 0,
            ZIndex = 8,
            Parent = box,
        })
        corner(boxFill, 4)
        bind(boxFill, "BackgroundColor3", "Second")
        new("UIStroke", {
            Color = theme.SubText, Thickness = 1, Transparency = 0.75, Parent = boxFill,
        })

        local valueLabel = new("TextLabel", {
            Size = UDim2.new(1, -32, 1, 0),
            Position = UDim2.new(0, 8, 0, 0),
            BackgroundTransparency = 1,
            Font = theme.GroupFont,
            TextSize = 13,
            TextColor3 = theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 9,
            Parent = box,
        })
        bind(valueLabel, "TextColor3", "Text")

        local arrowHolder, arrowL, arrowR = addArrow(box)

        local popup = new("Frame", {
            Name = name .. "Dropdown",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Visible = false,
            ZIndex = 200,
            Parent = gui,
        })

        local popupShadow = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = theme.GlowColor,
            BackgroundTransparency = 0.75,
            BorderSizePixel = 0,
            ZIndex = 200,
            Parent = popup,
        })
        corner(popupShadow, 9)
        bind(popupShadow, "BackgroundColor3", "GlowColor")

        local popupCard = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            BackgroundColor3 = theme.ContentColor,
            BackgroundTransparency = 0.02,
            BorderSizePixel = 0,
            ZIndex = 201,
            Parent = popup,
        })
        corner(popupCard, 6)
        bind(popupCard, "BackgroundColor3", "ContentColor")
        new("UIStroke", {
            Color = theme.SubText, Thickness = 1, Transparency = 0.6, Parent = popupCard,
        })
        new("UIListLayout", {
            Padding = UDim.new(0, 2),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = popupCard,
        })
        new("UIPadding", {
            PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 2),
            PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 2),
            Parent = popupCard,
        })

        local itemButtons = {}

        local function applySelected(itemName)
            valueLabel.Text = itemName
            for k, b in ipairs(itemButtons) do
                b.TextColor3 = (items[k] == itemName) and theme.Accent or theme.Text
            end
        end

        for i, itemName in ipairs(items) do
            local btn = new("TextButton", {
                Size = UDim2.new(1, -4, 0, 22),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                AutoButtonColor = false,
                Text = itemName,
                Font = theme.GroupFont,
                TextSize = 13,
                TextColor3 = (itemName == selected) and theme.Accent or theme.Text,
                TextXAlignment = Enum.TextXAlignment.Center,
                LayoutOrder = i,
                ZIndex = 202,
                Parent = popupCard,
            })
            corner(btn, 4)

            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, T2(0.1), {
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.9,
                }):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, T2(0.1), { BackgroundTransparency = 1 }):Play()
            end)
            btn.MouseButton1Click:Connect(function()
                selected = itemName
                applySelected(selected)
                closePopupEx(popup)
                TweenService:Create(arrowHolder, T2(0.15), { Rotation = 0 }):Play()
                callback(selected)
            end)
            itemButtons[i] = btn
        end

        applySelected(selected)

        local function reposition()
            local w = math.max(170, math.floor(box.AbsoluteSize.X))
            local h = #items * 24 + 8
            popup.Size = UDim2.fromOffset(w + 6, h + 6)
            popupCard.Size = UDim2.fromOffset(w, h)
            local abs = box.AbsolutePosition
            local px = math.clamp(abs.X - 3, 4, math.max(4, gui.AbsoluteSize.X - w - 10))
            popup.Position = UDim2.fromOffset(px, abs.Y + box.AbsoluteSize.Y + 1)
        end
        registerPopup(popup, reposition, box, popupShadow)

        box.MouseButton1Click:Connect(function()
            if openPopup == popup then
                closePopupEx(popup)
                TweenService:Create(arrowHolder, T2(0.15), { Rotation = 0 }):Play()
                return
            end
            reposition()
            openPopupEx(popup)
            TweenService:Create(arrowHolder, T2(0.15), { Rotation = 180 }):Play()
        end)

        table.insert(Lib.Refreshers, function()
            applySelected(selected)
            arrowL.BackgroundColor3 = theme.SubText
            arrowR.BackgroundColor3 = theme.SubText
        end)

        row.MouseEnter:Connect(function()
            hovered = true
            refreshNameColor()
        end)
        row.MouseLeave:Connect(function()
            hovered = false
            refreshNameColor()
        end)

        local dd = {}
        function dd:Get() return selected end
        function dd:Set(itemName)
            for _, n in ipairs(items) do
                if n == itemName then
                    selected = itemName
                    applySelected(selected)
                    callback(selected)
                    return true
                end
            end
            return false
        end
        return dd
    end

    local saveBtn = new("TextButton", {
        Name = "Save",
        Position = UDim2.new(0, 16, 0.5, -14),
        Size = UDim2.fromOffset(74, 28),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        ZIndex = 5,
        Parent = header,
    })

    addShadow(saveBtn)

    local saveFill = new("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = theme.Second,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        ZIndex = 5,
        Parent = saveBtn,
    })
    corner(saveFill, 4)
    bind(saveFill, "BackgroundColor3", "Second")
    new("UIStroke", {
        Color = theme.SubText,
        Thickness = 1,
        Transparency = 0.55,
        Parent = saveFill,
    })

    local saveLabel = new("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "Save",
        Font = theme.TabFont,
        TextSize = 13,
        TextColor3 = theme.Text,
        ZIndex = 6,
        Parent = saveBtn,
    })
    bind(saveLabel, "TextColor3", "Text")

    saveBtn.MouseEnter:Connect(function()
        TweenService:Create(saveFill, T2(0.12), { BackgroundTransparency = 0.15 }):Play()
    end)
    saveBtn.MouseLeave:Connect(function()
        TweenService:Create(saveFill, T2(0.12), { BackgroundTransparency = 0.4 }):Play()
    end)
    saveBtn.MouseButton1Click:Connect(function()
        if cfg.OnSave then cfg.OnSave() end
    end)

    local gearBtn = new("TextButton", {
        Name = "Settings",
        Position = UDim2.new(1, -44, 0.5, -15),
        Size = UDim2.fromOffset(30, 30),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        ZIndex = 5,
        Parent = header,
    })

    local gearParts = {}
    local gearHolder = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(20, 20),
        BackgroundTransparency = 1,
        ZIndex = 6,
        Parent = gearBtn,
    })
    for i = 0, 3 do
        local tooth = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(3, 18),
            Rotation = i * 45,
            BackgroundColor3 = theme.Text,
            BackgroundTransparency = 0.25,
            BorderSizePixel = 0,
            ZIndex = 6,
            Parent = gearHolder,
        })
        table.insert(gearParts, tooth)
    end
    local gearBody = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(14, 14),
        BackgroundColor3 = theme.Text,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        ZIndex = 7,
        Parent = gearHolder,
    })
    corner(gearBody, 7)
    table.insert(gearParts, gearBody)
    local gearHole = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(6, 6),
        BackgroundColor3 = theme.ContentColor,
        BackgroundTransparency = theme.HeaderTransparency,
        BorderSizePixel = 0,
        ZIndex = 8,
        Parent = gearHolder,
    })
    bind(gearHole, "BackgroundColor3", "ContentColor")

    gearBtn.MouseEnter:Connect(function()
        for _, p in ipairs(gearParts) do
            TweenService:Create(p, T2(0.12), { BackgroundColor3 = theme.Accent, BackgroundTransparency = 0 }):Play()
        end
    end)
    gearBtn.MouseLeave:Connect(function()
        for _, p in ipairs(gearParts) do
            TweenService:Create(p, T2(0.12), { BackgroundColor3 = theme.Text, BackgroundTransparency = 0.25 }):Play()
        end
    end)

    local settingsPanel = new("CanvasGroup", {
        Name = "SettingsPanel",
        Size = UDim2.fromOffset(260, 400),
        BackgroundColor3 = theme.ContentColor,
        BackgroundTransparency = 0.02,
        BorderSizePixel = 0,
        Visible = false,
        GroupTransparency = 0,
        ZIndex = 6,
        Parent = gui,
    })
    corner(settingsPanel, R)
    bind(settingsPanel, "BackgroundColor3", "ContentColor")
    local settingsScale = new("UIScale", { Parent = settingsPanel })
    local settingsStroke = new("UIStroke", {
        Color = theme.GlowColor,
        Thickness = 1,
        Transparency = 0.6,
        Parent = settingsPanel,
    })
    bind(settingsStroke, "Color", "GlowColor", "Transparency", 0.6)

    local settingsTitle = new("TextLabel", {
        Size = UDim2.new(1, -28, 0, 30),
        Position = UDim2.new(0, 14, 0, 8),
        BackgroundTransparency = 1,
        Text = "Settings",
        Font = theme.Font,
        TextSize = 15,
        TextColor3 = theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 7,
        Parent = settingsPanel,
    })
    bind(settingsTitle, "TextColor3", "Text")

    local settingsScroll = new("ScrollingFrame", {
        Position = UDim2.new(0, 14, 0, 40),
        Size = UDim2.new(1, -28, 1, -50),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 7,
        Parent = settingsPanel,
    })
    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = settingsScroll,
    })

    local sOrder = 0
    local function sNext()
        sOrder += 1
        return sOrder
    end

    local function settingsDivider()
        local d = new("Frame", {
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = theme.SubText,
            BackgroundTransparency = theme.DividerTransparency,
            BorderSizePixel = 0,
            LayoutOrder = sNext(),
            ZIndex = 7,
            Parent = settingsScroll,
        })
        bind(d, "BackgroundColor3", "SubText")
    end

    local function settingsLabel(text)
        local l = new("TextLabel", {
            Size = UDim2.new(1, 0, 0, 16),
            BackgroundTransparency = 1,
            Text = text,
            Font = theme.GroupFont,
            TextSize = theme.GroupSize,
            TextColor3 = theme.SubText,
            TextTransparency = 0.2,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = sNext(),
            ZIndex = 7,
            Parent = settingsScroll,
        })
        bind(l, "TextColor3", "SubText")
    end

    local function makeSliderRow(parent, order, cfg2)
        cfg2 = cfg2 or {}
        local minv = cfg2.Min or 0
        local maxv = cfg2.Max or 100
        local value = math.clamp(cfg2.Default or minv, minv, maxv)
        local callback = cfg2.Callback or function() end
        local format = cfg2.Format or function(v) return tostring(math.floor(v + 0.5)) end
        local parse = cfg2.Parse

        local row = new("Frame", {
            Name = cfg2.Name or "Slider",
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundTransparency = 1,
            LayoutOrder = order,
            ZIndex = 7,
            Parent = parent,
        })

        local nameLabel = new("TextLabel", {
            Size = UDim2.new(0.34, -6, 1, 0),
            BackgroundTransparency = 1,
            Text = cfg2.Name or "Slider",
            Font = theme.GroupFont,
            TextSize = 13,
            TextColor3 = theme.SubText,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 7,
            Parent = row,
        })

        local hovered = false
        local function refreshNameColor()
            TweenService:Create(nameLabel, TweenInfo.new(0.15), {
                TextColor3 = hovered and theme.Text or theme.SubText,
            }):Play()
        end
        table.insert(Lib.Refreshers, refreshNameColor)

        local track = new("TextButton", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0.34, 8, 0.5, 0),
            Size = UDim2.new(0.66, -62, 0, 5),
            BackgroundColor3 = theme.ToggleOff,
            BackgroundTransparency = 0.35,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Text = "",
            ZIndex = 7,
            Parent = row,
        })
        corner(track, 3)

        local fillBar = new("Frame", {
            Size = UDim2.fromScale(0, 1),
            BackgroundColor3 = theme.SliderFill,
            BorderSizePixel = 0,
            ZIndex = 8,
            Parent = track,
        })
        corner(fillBar, 3)
        bind(fillBar, "BackgroundColor3", "SliderFill")

        local knob = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.fromOffset(12, 12),
            BackgroundTransparency = 1,
            ZIndex = 9,
            Parent = track,
        })

        for i = 1, 2 do
            local g = new("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.new(1, i * 4, 1, i * 4),
                BackgroundColor3 = theme.Glow,
                BackgroundTransparency = 0.78 + i * 0.07,
                BorderSizePixel = 0,
                ZIndex = 9,
                Parent = knob,
            })
            corner(g, 7 + i)
            bind(g, "BackgroundColor3", "Glow")
        end

        local circle = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = theme.SliderKnob,
            BorderSizePixel = 0,
            ZIndex = 10,
            Parent = knob,
        })
        corner(circle, 6)
        bind(circle, "BackgroundColor3", "SliderKnob")
        local knobStroke = new("UIStroke", {
            Color = theme.Glow,
            Thickness = 1,
            Transparency = 0.5,
            Parent = circle,
        })
        bind(knobStroke, "Color", "Glow")

        local knobScale = new("UIScale", { Parent = knob, Scale = 1 })

        local input = new("TextBox", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.fromOffset(48, 22),
            BackgroundColor3 = theme.Second,
            BackgroundTransparency = 0.3,
            Text = format(value),
            Font = theme.GroupFont,
            TextSize = 13,
            TextColor3 = theme.Text,
            TextXAlignment = Enum.TextXAlignment.Center,
            ClearTextOnFocus = false,
            ZIndex = 8,
            Parent = row,
        })
        corner(input, 4)
        new("UIStroke", {
            Color = theme.SubText, Thickness = 1, Transparency = 0.75, Parent = input,
        })
        bind(input, "BackgroundColor3", "Second")
        bind(input, "TextColor3", "Text")

        local function setValue(v, fire, smooth)
            value = math.clamp(v, minv, maxv)
            local rel = (value - minv) / (maxv - minv)
            if smooth then
                TweenService:Create(fillBar, T(0.3), { Size = UDim2.fromScale(rel, 1) }):Play()
                TweenService:Create(knob, T(0.3), { Position = UDim2.new(rel, 0, 0.5, 0) }):Play()
            else
                fillBar.Size = UDim2.fromScale(rel, 1)
                knob.Position = UDim2.new(rel, 0, 0.5, 0)
            end
            input.Text = format(value)
            if fire then callback(value) end
        end

        input.FocusLost:Connect(function(enter)
            if not enter then
                input.Text = format(value)
                return
            end
            local num = tonumber((input.Text:gsub("[^%d%.%-]", "")))
            if num and parse then
                num = parse(num)
            end
            if num then
                setValue(num, true, true)
            else
                input.Text = format(value)
            end
        end)

        local dragging = false
        local function updateFromX(x)
            local rel = (x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1)
            setValue(minv + (maxv - minv) * math.clamp(rel, 0, 1), true, false)
        end

        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                TweenService:Create(knobScale, T2(0.1), { Scale = 1.3 }):Play()
                updateFromX(input.Position.X)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch) then
                updateFromX(input.Position.X)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                if dragging then
                    dragging = false
                    TweenService:Create(knobScale, T2(0.15), { Scale = 1 }):Play()
                end
            end
        end)

        row.MouseEnter:Connect(function()
            hovered = true
            refreshNameColor()
        end)
        row.MouseLeave:Connect(function()
            hovered = false
            refreshNameColor()
        end)

        setValue(value, false, false)

        local slider = {}
        function slider:Get() return value end
        function slider:Set(v) setValue(v, false, true) end
        return slider
    end

    local function makeKeybindRow(parent, order, cfg2)
        cfg2 = cfg2 or {}
        local name = cfg2.Name or "Keybind"
        local current = cfg2.Default
        local onChanged = cfg2.Callback or function() end

        local row = new("Frame", {
            Name = name,
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundTransparency = 1,
            LayoutOrder = order,
            ZIndex = 7,
            Parent = parent,
        })

        local nameLabel = new("TextLabel", {
            Size = UDim2.new(0.34, -6, 1, 0),
            BackgroundTransparency = 1,
            Text = name,
            Font = theme.GroupFont,
            TextSize = 13,
            TextColor3 = theme.SubText,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 7,
            Parent = row,
        })

        local hovered = false
        local function refreshNameColor()
            TweenService:Create(nameLabel, TweenInfo.new(0.15), {
                TextColor3 = hovered and theme.Text or theme.SubText,
            }):Play()
        end
        table.insert(Lib.Refreshers, refreshNameColor)

        local keyButton = new("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -2, 0.5, 0),
            Size = UDim2.fromOffset(84, 22),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Text = "",
            ZIndex = 8,
            Parent = row,
        })

        addShadow(keyButton)

        local keyFill = new("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = theme.Second,
            BackgroundTransparency = 0.3,
            BorderSizePixel = 0,
            ZIndex = 8,
            Parent = keyButton,
        })
        corner(keyFill, 4)
        bind(keyFill, "BackgroundColor3", "Second")
        new("UIStroke", {
            Color = theme.SubText, Thickness = 1, Transparency = 0.75, Parent = keyFill,
        })

        local keyLabel = new("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = current and current.Name or "-",
            Font = theme.GroupFont,
            TextSize = 13,
            TextColor3 = theme.Text,
            ZIndex = 9,
            Parent = keyButton,
        })
        bind(keyLabel, "TextColor3", "Text")

        keyButton.MouseButton1Click:Connect(function()
            keyLabel.Text = "..."
            uiKeyListening = true
            local conn
            conn = UserInputService.InputBegan:Connect(function(input, processed)
                if processed then return end
                if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                conn:Disconnect()
                uiKeyListening = false
                local kc = input.KeyCode
                if kc ~= Enum.KeyCode.Escape and kc ~= Enum.KeyCode.Unknown then
                    current = kc
                    keyLabel.Text = kc.Name
                    onChanged(kc)
                else
                    keyLabel.Text = current and current.Name or "-"
                end
            end)
        end)

        row.MouseEnter:Connect(function()
            hovered = true
            refreshNameColor()
        end)
        row.MouseLeave:Connect(function()
            hovered = false
            refreshNameColor()
        end)

        local keybindRow = {}
        function keybindRow:Get() return current end
        function keybindRow:Set(kc)
            if typeof(kc) == "EnumItem" then
                current = kc
                keyLabel.Text = kc.Name
                onChanged(kc)
            end
        end
        return keybindRow
    end

    local function makeColorPickerRow(parent, order, cfg2)
        cfg2 = cfg2 or {}
        local name = cfg2.Name or "Color"
        local callback = cfg2.Callback or function() end
        local current = cfg2.Default or Color3.fromRGB(255, 255, 255)
        local alpha = cfg2.DefaultAlpha or 0
        local h, s, v = current:ToHSV()

        local row = new("TextButton", {
            Name = name,
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundTransparency = 1,
            AutoButtonColor = false,
            Text = "",
            LayoutOrder = order,
            ZIndex = 7,
            Parent = parent,
        })

        local nameLabel = new("TextLabel", {
            Size = UDim2.new(1, -40, 1, 0),
            BackgroundTransparency = 1,
            Text = name,
            Font = theme.GroupFont,
            TextSize = 13,
            TextColor3 = theme.SubText,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 7,
            Parent = row,
        })

        local hovered = false
        local function refreshNameColor()
            TweenService:Create(nameLabel, TweenInfo.new(0.15), {
                TextColor3 = hovered and theme.Text or theme.SubText,
            }):Play()
        end
        table.insert(Lib.Refreshers, refreshNameColor)

        local swatch = new("TextButton", {
            Size = UDim2.fromOffset(20, 20),
            Position = UDim2.new(1, -22, 0.5, -10),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Text = "",
            ZIndex = 7,
            Parent = row,
        })

        addAccentGlow(swatch, 10)

        local swatchFill = new("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = current,
            BackgroundTransparency = alpha,
            BorderSizePixel = 0,
            ZIndex = 7,
            Parent = swatch,
        })
        corner(swatchFill, 10)
        new("UIStroke", {
            Color = theme.SubText, Thickness = 1, Transparency = 0.6, Parent = swatchFill,
        })

        local popup = new("Frame", {
            Name = name .. "Picker",
            Size = UDim2.fromOffset(180, 140),
            BackgroundColor3 = theme.ContentColor,
            BackgroundTransparency = 0.02,
            BorderSizePixel = 0,
            Visible = false,
            ZIndex = 200,
            Parent = gui,
        })
        corner(popup, 6)
        bind(popup, "BackgroundColor3", "ContentColor")
        local popupShadow = addShadow(popup)
        new("UIStroke", {
            Color = theme.SubText, Thickness = 1, Transparency = 0.6, Parent = popup,
        })

        local svBox = new("TextButton", {
            Size = UDim2.new(1, -20, 0, 90),
            Position = UDim2.new(0, 10, 0, 10),
            BackgroundColor3 = Color3.fromHSV(h, 1, 1),
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Text = "",
            ZIndex = 201,
            Parent = popup,
        })
        corner(svBox, 4)

        local whiteOverlay = new("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            ZIndex = 202,
            Parent = svBox,
        })
        new("UIGradient", {
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 1),
            }),
            Parent = whiteOverlay,
        })

        local blackOverlay = new("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            ZIndex = 203,
            Parent = svBox,
        })
        new("UIGradient", {
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(1, 0),
            }),
            Rotation = 90,
            Parent = blackOverlay,
        })

        local svKnob = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.fromOffset(8, 8),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            ZIndex = 204,
            Parent = svBox,
        })
        corner(svKnob, 4)
        new("UIStroke", { Color = Color3.fromRGB(0, 0, 0), Thickness = 1, Transparency = 0.4, Parent = svKnob })

        local hueBar = new("TextButton", {
            Size = UDim2.new(1, -20, 0, 12),
            Position = UDim2.new(0, 10, 0, 112),
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Text = "",
            ZIndex = 201,
            Parent = popup,
        })
        corner(hueBar, 4)
        new("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
            }),
            Parent = hueBar,
        })

        local hueKnob = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.fromOffset(4, 16),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            ZIndex = 204,
            Parent = hueBar,
        })
        corner(hueKnob, 2)

        local hintLabel = new("TextLabel", {
            Size = UDim2.new(1, -20, 0, 14),
            Position = UDim2.new(0, 10, 1, -18),
            BackgroundTransparency = 1,
            Text = "scroll to change opacity",
            Font = theme.GroupFont,
            TextSize = 10,
            TextColor3 = theme.SubText,
            TextTransparency = 0.35,
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex = 201,
            Parent = popup,
        })
        bind(hintLabel, "TextColor3", "SubText")

        local function apply()
            local c = Color3.fromHSV(h, s, v)
            current = c
            swatchFill.BackgroundColor3 = c
            swatchFill.BackgroundTransparency = alpha
            svKnob.Position = UDim2.new(s, 0, 1 - v, 0)
            hueKnob.Position = UDim2.new(h, 0, 0.5, 0)
            callback(c, alpha)
        end

        local svDrag, hueDrag = false, false
        local function updateSV(pos)
            local relX = (pos.X - svBox.AbsolutePosition.X) / math.max(svBox.AbsoluteSize.X, 1)
            local relY = (pos.Y - svBox.AbsolutePosition.Y) / math.max(svBox.AbsoluteSize.Y, 1)
            s = math.clamp(relX, 0, 1)
            v = 1 - math.clamp(relY, 0, 1)
            apply()
        end
        local function updateHue(pos)
            h = math.clamp((pos.X - hueBar.AbsolutePosition.X) / math.max(hueBar.AbsoluteSize.X, 1), 0, 1)
            svBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            apply()
        end

        svBox.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                svDrag = true
                updateSV(input.Position)
            end
        end)
        hueBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                hueDrag = true
                updateHue(input.Position)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if not (svDrag or hueDrag) then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch then
                if svDrag then updateSV(input.Position) end
                if hueDrag then updateHue(input.Position) end
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                if svDrag or hueDrag then
                    svDrag, hueDrag = false, false
                end
            end
        end)

        swatch.MouseWheelForward:Connect(function()
            alpha = math.clamp(alpha - 0.05, 0, 1)
            apply()
        end)
        swatch.MouseWheelBackward:Connect(function()
            alpha = math.clamp(alpha + 0.05, 0, 1)
            apply()
        end)

        local function reposition()
            local abs = swatch.AbsolutePosition
            local px = math.clamp(abs.X - 150, 4, math.max(4, gui.AbsoluteSize.X - 190))
            popup.Position = UDim2.fromOffset(px, abs.Y + 28)
        end
        registerPopup(popup, reposition, swatch, popupShadow)

        swatch.MouseButton1Click:Connect(function()
            if openPopup == popup then
                closePopupEx(popup)
                return
            end
            reposition()
            openPopupEx(popup)
        end)

        row.MouseEnter:Connect(function()
            hovered = true
            refreshNameColor()
        end)
        row.MouseLeave:Connect(function()
            hovered = false
            refreshNameColor()
        end)

        local picker = {}
        function picker:Get() return current, alpha end
        function picker:Set(c, a)
            if typeof(c) == "Color3" then
                h, s, v = c:ToHSV()
                svBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            end
            if type(a) == "number" then
                alpha = math.clamp(a, 0, 1)
            end
            apply()
        end
        return picker
    end

    local function makeMultiDropdownRow(parent, order, cfg2)
        cfg2 = cfg2 or {}
        local name = cfg2.Name or "Multi"
        local items = cfg2.Items
        if type(items) ~= "table" then
            items = {}
        end
        local callback = cfg2.Callback or function() end
        local selected = {}
        for _, v in ipairs(cfg2.Default or {}) do
            selected[v] = true
        end

        local row = new("Frame", {
            Name = name,
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundTransparency = 1,
            LayoutOrder = order,
            ZIndex = 7,
            Parent = parent,
        })

        local nameLabel = new("TextLabel", {
            Size = UDim2.new(0.32, -6, 1, 0),
            BackgroundTransparency = 1,
            Text = name,
            Font = theme.GroupFont,
            TextSize = 13,
            TextColor3 = theme.SubText,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 7,
            Parent = row,
        })

        local hovered = false
        local function refreshNameColor()
            TweenService:Create(nameLabel, TweenInfo.new(0.15), {
                TextColor3 = hovered and theme.Text or theme.SubText,
            }):Play()
        end
        table.insert(Lib.Refreshers, refreshNameColor)

        local box = new("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.new(0.68, -8, 0, 24),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Text = "",
            ZIndex = 8,
            Parent = row,
        })

        addShadow(box)

        local boxFill = new("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = theme.Second,
            BackgroundTransparency = 0.3,
            BorderSizePixel = 0,
            ZIndex = 8,
            Parent = box,
        })
        corner(boxFill, 4)
        bind(boxFill, "BackgroundColor3", "Second")
        new("UIStroke", {
            Color = theme.SubText, Thickness = 1, Transparency = 0.75, Parent = boxFill,
        })

        local valueLabel = new("TextLabel", {
            Size = UDim2.new(1, -32, 1, 0),
            Position = UDim2.new(0, 8, 0, 0),
            BackgroundTransparency = 1,
            Font = theme.GroupFont,
            TextSize = 13,
            TextColor3 = theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 9,
            Parent = box,
        })
        bind(valueLabel, "TextColor3", "Text")

        local arrowHolder, arrowL, arrowR = addArrow(box)

        local popup = new("Frame", {
            Name = name .. "Multi",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Visible = false,
            ZIndex = 200,
            Parent = gui,
        })

        local popupShadow = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = theme.GlowColor,
            BackgroundTransparency = 0.75,
            BorderSizePixel = 0,
            ZIndex = 200,
            Parent = popup,
        })
        corner(popupShadow, 9)
        bind(popupShadow, "BackgroundColor3", "GlowColor")

        local popupCard = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            BackgroundColor3 = theme.ContentColor,
            BackgroundTransparency = 0.02,
            BorderSizePixel = 0,
            ZIndex = 201,
            Parent = popup,
        })
        corner(popupCard, 6)
        bind(popupCard, "BackgroundColor3", "ContentColor")
        new("UIStroke", {
            Color = theme.SubText, Thickness = 1, Transparency = 0.6, Parent = popupCard,
        })
        new("UIListLayout", {
            Padding = UDim.new(0, 2),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = popupCard,
        })
        new("UIPadding", {
            PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 2),
            PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 2),
            Parent = popupCard,
        })

        local itemButtons = {}

        local function updateValue()
            local parts = {}
            for _, item in ipairs(items) do
                if selected[item] then
                    table.insert(parts, item)
                end
            end
            if #parts == 0 then
                valueLabel.Text = "None"
                valueLabel.TextColor3 = theme.SubText
            else
                valueLabel.Text = table.concat(parts, ", ")
                valueLabel.TextColor3 = theme.Text
            end
        end

        local function setButtonState(i, itemName)
            if itemButtons[i] then
                itemButtons[i].TextColor3 = selected[itemName] and theme.Text or theme.SubText
            end
        end

        for i, itemName in ipairs(items) do
            local btn = new("TextButton", {
                Size = UDim2.new(1, -4, 0, 22),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                AutoButtonColor = false,
                Text = itemName,
                Font = theme.GroupFont,
                TextSize = 13,
                TextColor3 = selected[itemName] and theme.Text or theme.SubText,
                TextXAlignment = Enum.TextXAlignment.Center,
                LayoutOrder = i,
                ZIndex = 202,
                Parent = popupCard,
            })
            corner(btn, 4)

            local check = new("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 5, 0.5, 0),
                Size = UDim2.fromOffset(12, 12),
                BackgroundTransparency = 1,
                Visible = selected[itemName] == true,
                ZIndex = 203,
                Parent = btn,
            })
            local c1 = new("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.3, 0.62),
                Size = UDim2.fromOffset(1.5, 5),
                Rotation = -45,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                ZIndex = 204,
                Parent = check,
            })
            local c2 = new("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.68, 0.4),
                Size = UDim2.fromOffset(1.5, 10),
                Rotation = 45,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                ZIndex = 204,
                Parent = check,
            })

            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, T2(0.1), {
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.9,
                }):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, T2(0.1), { BackgroundTransparency = 1 }):Play()
            end)
            btn.MouseButton1Click:Connect(function()
                if selected[itemName] then
                    selected[itemName] = nil
                else
                    selected[itemName] = true
                end
                btn.TextColor3 = selected[itemName] and theme.Text or theme.SubText
                check.Visible = selected[itemName] == true
                updateValue()
                local list = {}
                for _, item in ipairs(items) do
                    if selected[item] then
                        table.insert(list, item)
                    end
                end
                callback(list)
            end)
            itemButtons[i] = btn
        end

        updateValue()

        local function reposition()
            local w = math.max(170, math.floor(box.AbsoluteSize.X))
            local h = #items * 24 + 8
            popup.Size = UDim2.fromOffset(w + 6, h + 6)
            popupCard.Size = UDim2.fromOffset(w, h)
            local abs = box.AbsolutePosition
            local px = math.clamp(abs.X - 3, 4, math.max(4, gui.AbsoluteSize.X - w - 10))
            popup.Position = UDim2.fromOffset(px, abs.Y + box.AbsoluteSize.Y + 1)
        end
        registerPopup(popup, reposition, box, popupShadow)

        box.MouseButton1Click:Connect(function()
            if openPopup == popup then
                closePopupEx(popup)
                TweenService:Create(arrowHolder, T2(0.15), { Rotation = 0 }):Play()
                return
            end
            reposition()
            openPopupEx(popup)
            TweenService:Create(arrowHolder, T2(0.15), { Rotation = 180 }):Play()
        end)

        table.insert(Lib.Refreshers, function()
            for i, itemName in ipairs(items) do
                setButtonState(i, itemName)
            end
            arrowL.BackgroundColor3 = theme.SubText
            arrowR.BackgroundColor3 = theme.SubText
            updateValue()
        end)

        row.MouseEnter:Connect(function()
            hovered = true
            refreshNameColor()
        end)
        row.MouseLeave:Connect(function()
            hovered = false
            refreshNameColor()
        end)

        local multi = {}
        function multi:Get()
            local list = {}
            for _, item in ipairs(items) do
                if selected[item] then
                    table.insert(list, item)
                end
            end
            return list
        end
        function multi:Set(list)
            selected = {}
            for _, want in ipairs(list) do
                for _, item in ipairs(items) do
                    if item == want then
                        selected[item] = true
                    end
                end
            end
            for i, itemName in ipairs(items) do
                setButtonState(i, itemName)
            end
            updateValue()
        end
        return multi
    end

    scaleDropdown = makeDropdownRow(settingsScroll, sNext(), {
        Name = "UI Scale",
        Flag = "__ui_scale",
        Items = { "100%", "125%", "150%", "175%", "200%" },
        Default = "100%",
        Callback = function(selected)
            uiScaleValue = (tonumber(selected:match("%d+")) or 100) / 100
            TweenService:Create(mainScale, T(0.35), { Scale = uiScaleValue }):Play()
            TweenService:Create(glowScale, T(0.35), { Scale = uiScaleValue }):Play()
            TweenService:Create(settingsScale, T(0.35), { Scale = uiScaleValue }):Play()
            syncSettings()
            if cfg.OnScaleChange then cfg.OnScaleChange(uiScaleValue) end
        end,
    })
    settingsDivider()
    settingsLabel("THEME")
    local themeKeys = {
        { Name = "Accent", Key = "Accent" },
        { Name = "Background", Key = "ContentColor" },
        { Name = "Sidebar", Key = "Second" },
        { Name = "Cards", Key = "CardColor" },
        { Name = "Text", Key = "Text" },
        { Name = "Sub Text", Key = "SubText" },
        { Name = "Shadows", Key = "GlowColor" },
        { Name = "Tab Highlight", Key = "TabHighlightColor" },
    }
    for i, item in ipairs(themeKeys) do
        makeColorPickerRow(settingsScroll, sNext(), {
            Name = item.Name,
            Default = theme[item.Key],
            Callback = function(c, a)
                theme[item.Key] = c
                Lib.ThemeAlpha[item.Key] = a or 0
                Lib:ApplyTheme()
            end,
        })
        if i < #themeKeys then
            settingsDivider()
        end
    end
    settingsDivider()
    settingsLabel("INTERFACE")
    uiKeybindRow = makeKeybindRow(settingsScroll, sNext(), {
        Name = "UI Keybind",
        Default = uiToggleKey,
        Callback = function(kc)
            uiToggleKey = kc
            if cfg.OnKeybindChange then cfg.OnKeybindChange(kc) end
        end,
    })
    makeSliderRow(settingsScroll, sNext(), {
        Name = "Animation Speed",
        Flag = "__anim_speed",
        Min = 0.25, Max = 3, Default = 1,
        Format = function(v) return math.floor(v * 100 + 0.5) .. "%" end,
        Parse = function(n) return n / 100 end,
        Callback = function(v)
            animSpeed = v
        end,
    })

    local function makeSettingsToggle(parent, order, cfg2)
        cfg2 = cfg2 or {}
        local name = cfg2.Name or "Toggle"
        local state = cfg2.Default == true
        local callback = cfg2.Callback or function() end

        local row = new("TextButton", {
            Name = name,
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundTransparency = 1,
            AutoButtonColor = false,
            Text = "",
            LayoutOrder = order,
            ZIndex = 7,
            Parent = parent,
        })

        local nameLabel = new("TextLabel", {
            Size = UDim2.new(1, -54, 1, 0),
            BackgroundTransparency = 1,
            Text = name,
            Font = theme.GroupFont,
            TextSize = 13,
            TextColor3 = theme.SubText,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 7,
            Parent = row,
        })

        local hovered = false
        local function refreshNameColor()
            TweenService:Create(nameLabel, TweenInfo.new(0.15), {
                TextColor3 = (hovered or state) and theme.Text or theme.SubText,
            }):Play()
        end
        table.insert(Lib.Refreshers, refreshNameColor)

        local pill = new("Frame", {
            Size = UDim2.fromOffset(30, 16),
            Position = UDim2.new(1, -32, 0.5, -8),
            BackgroundColor3 = state and theme.ToggleOnPill or theme.ToggleOff,
            BorderSizePixel = 0,
            ZIndex = 7,
            Parent = row,
        })
        corner(pill, 8)

        local knob = new("Frame", {
            Size = UDim2.fromOffset(16, 16),
            Position = state and UDim2.fromOffset(14, 0) or UDim2.fromOffset(0, 0),
            BackgroundColor3 = state and theme.ToggleOn or theme.ToggleOffKnob,
            BorderSizePixel = 0,
            ZIndex = 8,
            Parent = pill,
        })
        corner(knob, 8)

        local function updateVisual(instant)
            local targetPos = state and UDim2.fromOffset(14, 0) or UDim2.fromOffset(0, 0)
            local targetPill = state and theme.ToggleOnPill or theme.ToggleOff
            local targetKnob = state and theme.ToggleOn or theme.ToggleOffKnob
            refreshNameColor()
            if instant then
                knob.Position = targetPos
                knob.BackgroundColor3 = targetKnob
                pill.BackgroundColor3 = targetPill
            else
                TweenService:Create(knob, T2(0.15), { Position = targetPos, BackgroundColor3 = targetKnob }):Play()
                TweenService:Create(pill, T2(0.15), { BackgroundColor3 = targetPill }):Play()
            end
        end

        row.MouseButton1Click:Connect(function()
            state = not state
            updateVisual(false)
            callback(state)
        end)
        row.MouseEnter:Connect(function()
            hovered = true
            refreshNameColor()
        end)
        row.MouseLeave:Connect(function()
            hovered = false
            refreshNameColor()
        end)

        updateVisual(true)

        local t = {}
        function t:Get() return state end
        function t:Set(v)
            state = v == true
            updateVisual(true)
            callback(state)
        end
        return t
    end

    settingsDivider()
    settingsLabel("WATERMARK")
    makeSettingsToggle(settingsScroll, sNext(), {
        Name = "Enabled",
        Default = true,
        Callback = function(v)
            wmSetVisible(v)
        end,
    })
    makeMultiDropdownRow(settingsScroll, sNext(), {
        Name = "Elements",
        Items = { "FPS", "Ping", "Username", "Time" },
        Default = { "FPS", "Ping", "Username", "Time" },
        Callback = function(list)
            wmSetElements(list)
        end,
    })

    function syncSettings()
        settingsPanel.Position = UDim2.new(
            main.Position.X.Scale,
            main.Position.X.Offset + size.X.Offset * uiScaleValue + 16,
            main.Position.Y.Scale,
            main.Position.Y.Offset
        )
    end
    syncSettings()

    local settingsOpen = false
    local function setSettings(state)
        if settingsOpen == state then return end
        settingsOpen = state
        if state then
            syncSettings()
            settingsPanel.Visible = true
            settingsPanel.GroupTransparency = 1
            TweenService:Create(settingsPanel, T(0.25), { GroupTransparency = 0 }):Play()
        else
            closePopup()
            local tw = TweenService:Create(settingsPanel, T(0.25), { GroupTransparency = 1 })
            tw.Completed:Once(function()
                if not settingsOpen then settingsPanel.Visible = false end
            end)
            tw:Play()
        end
    end

    gearBtn.MouseButton1Click:Connect(function()
        setSettings(not settingsOpen)
    end)

    local isOpen = true

    local function setOpen(state)
        if isOpen == state then return end
        isOpen = state

        if isOpen then
            main.Visible = true
            glow.Visible = true
            main.GroupTransparency = 1
            glow.GroupTransparency = 1
            TweenService:Create(main, T(0.3), { GroupTransparency = theme.UITransparency }):Play()
            TweenService:Create(glow, T(0.3), { GroupTransparency = 0 }):Play()
        else
            setSettings(false)
            TweenService:Create(main, T(0.25), { GroupTransparency = 1 }):Play()
            TweenService:Create(glow, T(0.25), { GroupTransparency = 1 }):Play()
            task.delay(0.25 / animSpeed, function()
                if not isOpen then
                    main.Visible = false
                    glow.Visible = false
                end
            end)
        end
    end

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if uiKeyListening then return end
        if input.KeyCode == uiToggleKey then
            setOpen(not isOpen)
        end
    end)


    local wmElements = {
        FPS = true,
        Ping = true,
        Username = true,
        Time = true,
    }
    if type(cfg.Watermark) == "table" then
        for _, key in ipairs({ "FPS", "Ping", "Username", "Time" }) do
            if cfg.Watermark[key] ~= nil then
                wmElements[key] = cfg.Watermark[key] == true
            end
        end
    end

    local wmVisible = true
    if type(cfg.Watermark) == "table" and cfg.Watermark.Enabled ~= nil then
        wmVisible = cfg.Watermark.Enabled == true
    end

    local wmFrame = new("Frame", {
        Name = "Watermark",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -14, 0, 12),
        Size = UDim2.fromOffset(0, 30),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = theme.ContentColor,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Active = true,
        ZIndex = 55,
        Parent = gui,
    })
    corner(wmFrame, 6)
    bind(wmFrame, "BackgroundColor3", "ContentColor", "BackgroundTransparency", 0.15)
    wmFrame.Visible = wmVisible
    new("UIGradient", {
        Rotation = 90,
        Color = ColorSequence.new(Color3.fromRGB(255, 255, 255)),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.45, 0.28),
            NumberSequenceKeypoint.new(1, 0.12),
        }),
        Parent = wmFrame,
    })
    local wmStroke = new("UIStroke", {
        Color = theme.SubText,
        Thickness = 1,
        Transparency = 0.7,
        Parent = wmFrame,
    })
    bind(wmStroke, "Color", "SubText")

    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = wmFrame,
    })
    new("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        Parent = wmFrame,
    })

    local wmLogoHolder = new("Frame", {
        Name = "Logo",
        Size = UDim2.fromOffset(26, 30),
        BackgroundTransparency = 1,
        ZIndex = 56,
        LayoutOrder = 1,
        Parent = wmFrame,
    })
    local wmLogoShadow = new("TextLabel", {
        Text = "luau",
        Font = theme.Font,
        TextSize = 16,
        TextColor3 = theme.Glow,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, -1),
        Size = UDim2.fromScale(1, 1),
        ZIndex = 56,
        Parent = wmLogoHolder,
    })
    bind(wmLogoShadow, "TextColor3", "Glow")
    local wmLogo = new("TextLabel", {
        Text = "luau",
        Font = theme.Font,
        TextSize = 16,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 1, 0.5, 0),
        Size = UDim2.fromScale(1, 1),
        ZIndex = 57,
        Parent = wmLogoHolder,
    })

    local function wmMakeDivider(order)
        return new("Frame", {
            Size = UDim2.new(0, 1, 0, 14),
            BackgroundColor3 = theme.SubText,
            BackgroundTransparency = 0.6,
            BorderSizePixel = 0,
            ZIndex = 56,
            LayoutOrder = order,
            Parent = wmFrame,
        })
    end

    local function wmMakeLabel(order)
        return new("TextLabel", {
            Font = theme.TabFont,
            TextSize = 13,
            TextColor3 = theme.Text,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 56,
            LayoutOrder = order,
            Parent = wmFrame,
        })
    end

    local wmDivFps = wmMakeDivider(2)
    local wmFpsLabel = wmMakeLabel(3)
    bind(wmFpsLabel, "TextColor3", "Text")
    local wmDivPing = wmMakeDivider(4)
    local wmPingLabel = wmMakeLabel(5)
    bind(wmPingLabel, "TextColor3", "Text")
    local wmDivUser = wmMakeDivider(6)
    local wmUserLabel = wmMakeLabel(7)
    bind(wmUserLabel, "TextColor3", "Text")
    local wmDivTime = wmMakeDivider(8)
    local wmTimeLabel = wmMakeLabel(9)
    bind(wmTimeLabel, "TextColor3", "Text")

    local wmFPS = 0
    local wmPing = 0

    local function refreshWatermark()
        wmFpsLabel.Text = tostring(math.floor(wmFPS + 0.5)) .. " FPS"
        wmPingLabel.Text = tostring(math.floor(wmPing + 0.5)) .. " ms"
        wmUserLabel.Text = userName
        wmTimeLabel.Text = os.date("%H:%M:%S")

        wmFpsLabel.Visible = wmElements.FPS == true
        wmPingLabel.Visible = wmElements.Ping == true
        wmUserLabel.Visible = wmElements.Username == true
        wmTimeLabel.Visible = wmElements.Time == true

        wmDivFps.Visible = wmElements.FPS == true
        wmDivPing.Visible = (wmElements.FPS == true) and (wmElements.Ping == true)
        wmDivUser.Visible = (wmElements.FPS == true or wmElements.Ping == true) and (wmElements.Username == true)
        wmDivTime.Visible = (wmElements.FPS == true or wmElements.Ping == true or wmElements.Username == true)
            and (wmElements.Time == true)
    end

    wmSetElements = function(list)
        for key in pairs(wmElements) do
            wmElements[key] = false
        end
        if type(list) == "table" then
            for _, name in ipairs(list) do
                if wmElements[name] ~= nil then
                    wmElements[name] = true
                end
            end
        end
        refreshWatermark()
    end

    wmSetVisible = function(v)
        wmVisible = v == true
        wmFrame.Visible = wmVisible
    end

    local function wmUpdatePing()
        pcall(function()
            local stats = game:GetService("Stats")
            local function findPingItem(container)
                for _, child in ipairs(container:GetChildren()) do
                    if child.Name:lower():find("ping") and child.GetValue then
                        return child
                    end
                    if #child:GetChildren() > 0 then
                        local found = findPingItem(child)
                        if found then
                            return found
                        end
                    end
                end
                return nil
            end
            local item = findPingItem(stats)
            if item then
                local v = item:GetValue()
                if type(v) == "number" then
                    wmPing = v
                end
            end
        end)
    end

    local wmFrames = 0
    RunService.RenderStepped:Connect(function()
        wmFrames += 1
    end)

    task.spawn(function()
        while wmFrame.Parent do
            task.wait(1)
            wmFPS = wmFrames
            wmFrames = 0
            wmUpdatePing()
            refreshWatermark()
        end
    end)

    refreshWatermark()

    local wmDragging = false
    local wmDragStart, wmStartPos

    wmFrame.InputBegan:Connect(function(input)
        if not isOpen then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            wmDragging = true
            wmDragStart = input.Position
            wmStartPos = wmFrame.Position
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            wmDragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not wmDragging or not isOpen then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - wmDragStart
            local wmW = wmFrame.AbsoluteSize.X
            local wmH = wmFrame.AbsoluteSize.Y
            local guiW = gui.AbsoluteSize.X
            local guiH = gui.AbsoluteSize.Y
            local minX = math.min(-(guiW - wmW - 6), -6)
            local offX = math.clamp(wmStartPos.X.Offset + delta.X, minX, -6)
            local offY = math.clamp(wmStartPos.Y.Offset + delta.Y, 4, math.max(4, guiH - wmH - 4))
            wmFrame.Position = UDim2.new(1, offX, 0, offY)
        end
    end)

    local dragging = false
    local dragStart, startPos

    main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
            glow.Position = UDim2.new(
                main.Position.X.Scale, main.Position.X.Offset - PAD,
                main.Position.Y.Scale, main.Position.Y.Offset - PAD
            )
            syncSettings()
            if openPopup and popupUpdaters[openPopup] then
                popupUpdaters[openPopup]()
            end
        end
    end)

    local keybinds = {}

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        local kc = input.KeyCode
        if kc == Enum.KeyCode.Unknown then return end
        for _, b in ipairs(keybinds) do
            if b.key == kc then
                if b.mode == "Hold" then
                    b.toggle:Set(true)
                else
                    b.toggle:Set(not b.toggle:Get())
                end
            end
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        local kc = input.KeyCode
        for _, b in ipairs(keybinds) do
            if b.key == kc and b.mode == "Hold" then
                b.toggle:Set(false)
            end
        end
    end)


    local kbRoot = new("Frame", {
        Name = "KeybindList",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -14, 0, 52),
        Size = UDim2.fromOffset(170, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Active = true,
        Visible = false,
        ZIndex = 55,
        Parent = gui,
    })
    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = kbRoot,
    })

    local kbBox = new("Frame", {
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundColor3 = Color3.fromRGB(9, 12, 26),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ZIndex = 56,
        LayoutOrder = 1,
        Parent = kbRoot,
    })
    corner(kbBox, 6)
    local kbShadow = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 4, 1, 4),
        BackgroundColor3 = Color3.fromRGB(12, 20, 48),
        BackgroundTransparency = 0.78,
        BorderSizePixel = 0,
        ZIndex = 55,
        Parent = kbBox,
    })
    corner(kbShadow, 8)
    new("UIStroke", {
        Color = Color3.fromRGB(32, 40, 72),
        Thickness = 1,
        Transparency = 0.35,
        Parent = kbBox,
    })

    new("ImageLabel", {
        Name = "Icon",
        Image = "rbxassetid://102976018150012",
        Size = UDim2.fromOffset(14, 14),
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 8, 0.5, 0),
        BackgroundTransparency = 1,
        ZIndex = 57,
        Parent = kbBox,
    })
    new("TextLabel", {
        Text = "Keybinds",
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = theme.Text,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 28, 0, 0),
        Size = UDim2.new(1, -36, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 57,
        Parent = kbBox,
    })

    local kbRows = new("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex = 56,
        LayoutOrder = 2,
        Parent = kbRoot,
    })
    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = kbRows,
    })

    local function refreshKeybindList()
        for _, child in ipairs(kbRows:GetChildren()) do
            if not child:IsA("UIListLayout") then
                child:Destroy()
            end
        end
        local count = 0
        for _, b in ipairs(keybinds) do
            local active = false
            if b.key and b.toggle.Get then
                active = b.toggle.Get() == true
            end
            if active then
                count += 1
                local row = new("Frame", {
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    ZIndex = 57,
                    LayoutOrder = count,
                    Parent = kbRows,
                })
                new("TextLabel", {
                    Text = b.toggle.Name or "Toggle",
                    Font = Enum.Font.GothamMedium,
                    TextSize = 12,
                    TextColor3 = theme.Text,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 8, 0, 0),
                    Size = UDim2.new(1, -64, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 58,
                    Parent = row,
                })
                new("TextLabel", {
                    Text = "[" .. b.key.Name .. "]",
                    Font = Enum.Font.GothamMedium,
                    TextSize = 12,
                    TextColor3 = theme.SubText,
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -8, 0.5, 0),
                    Size = UDim2.fromOffset(0, 18),
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    ZIndex = 58,
                    Parent = row,
                })
            end
        end
        kbRoot.Visible = count > 0
    end

    Lib.KeybindListRefresh = refreshKeybindList

    local kbDragging = false
    local kbDragStart, kbStartPos

    kbRoot.InputBegan:Connect(function(input)
        if not isOpen then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            kbDragging = true
            kbDragStart = input.Position
            kbStartPos = kbRoot.Position
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            kbDragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not kbDragging or not isOpen then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - kbDragStart
            local kbW = kbRoot.AbsoluteSize.X
            local kbH = kbRoot.AbsoluteSize.Y
            local guiW = gui.AbsoluteSize.X
            local guiH = gui.AbsoluteSize.Y
            local minX = math.min(-(guiW - kbW - 6), -6)
            local offX = math.clamp(kbStartPos.X.Offset + delta.X, minX, -6)
            local offY = math.clamp(kbStartPos.Y.Offset + delta.Y, 4, math.max(4, guiH - kbH - 4))
            kbRoot.Position = UDim2.new(1, offX, 0, offY)
        end
    end)

    local layoutOrder = 0
    local currentButton = nil
    local currentPageFrame = nil
    local currentPageName = nil

    local function switchTab(button, page, pageName)
        if currentButton == button then return end

        if currentPageFrame then
            currentPageFrame.Visible = false
        end
        if currentButton then
            local hl = currentButton:FindFirstChild("TabHighlight")
            TweenService:Create(currentButton, T(0.3), { TextTransparency = 0.4 }):Play()
            if hl then
                TweenService:Create(hl, T(0.3), { BackgroundTransparency = 1 }):Play()
            else
                TweenService:Create(currentButton, T(0.3), { BackgroundTransparency = 1 }):Play()
            end
        end

        currentButton = button
        currentPageName = pageName
        currentPageFrame = page
        page.Visible = true
        page.GroupTransparency = 1
        TweenService:Create(page, T(0.25), { GroupTransparency = 0 }):Play()
        local target = math.clamp(theme.TabHighlight + (Lib.ThemeAlpha.TabHighlightColor or 0), 0, 1)
        TweenService:Create(button, T(0.3), { TextTransparency = 0 }):Play()
        local hl = button:FindFirstChild("TabHighlight")
        if hl then
            TweenService:Create(hl, T(0.3), { BackgroundTransparency = target }):Play()
        else
            TweenService:Create(button, T(0.3), { BackgroundTransparency = target }):Play()
        end
    end

    table.insert(Lib.Refreshers, function()
        if currentButton then
            local hl = currentButton:FindFirstChild("TabHighlight")
            local target = math.clamp(theme.TabHighlight + (Lib.ThemeAlpha.TabHighlightColor or 0), 0, 1)
            if hl then
                hl.BackgroundColor3 = theme.TabHighlightColor
                hl.BackgroundTransparency = target
            else
                currentButton.BackgroundColor3 = theme.TabHighlightColor
                currentButton.BackgroundTransparency = target
            end
        end
    end)

    local window = {
        Gui = gui,
        Main = main,
        Glow = glow,
        Title = title,
        Sidebar = sidebar,
        Content = content,
        Header = header,
        Notify = function(_, nCfg)
            Lib:Notify(nCfg)
        end,
        Settings = {
            Scale = scaleDropdown,
            Keybind = uiKeybindRow,
            Panel = settingsPanel,
        },
        Watermark = {
            Frame = wmFrame,
            Set = function(_, list)
                wmSetElements(list)
            end,
            SetVisible = function(_, v)
                wmSetVisible(v)
            end,
            GetVisible = function()
                return wmVisible
            end,
            Get = function()
                local list = {}
                for key, on in pairs(wmElements) do
                    if on then
                        table.insert(list, key)
                    end
                end
                return list
            end,
        },
    }

    function window:Section(name)
        layoutOrder += 1

        local secLabel = new("TextLabel", {
            Name = name,
            Text = name,
            Font = theme.SectionFont,
            TextSize = theme.SectionSize,
            TextColor3 = theme.SubText,
            TextTransparency = 0.25,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            LayoutOrder = layoutOrder,
            Parent = sidebarList,
        })
        bind(secLabel, "TextColor3", "SubText")

        local section = {}

        function section:Tab(tabName, iconId)
            layoutOrder += 1

            local button = new("TextButton", {
                Name = tabName,
                Text = tabName,
                Font = Enum.Font.GothamMedium,
                TextSize = theme.TabSize,
                TextColor3 = theme.Text,
                TextTransparency = 0.4,
                TextXAlignment = iconId and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center,
                BackgroundColor3 = theme.TabHighlightColor,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                AutoButtonColor = false,
                Size = UDim2.new(1, theme.TabExtra, 0, 26),
                LayoutOrder = layoutOrder,
                Parent = sidebarList,
            })
            bind(button, "TextColor3", "Text")
            corner(button, theme.TabRadius)

            if iconId then
                new("UIPadding", { PaddingLeft = UDim.new(0, 10), Parent = button })
                new("ImageLabel", {
                    Name = "Icon",
                    Image = "rbxassetid://" .. tostring(iconId),
                    Size = UDim2.fromOffset(14, 14),
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(0, -4, 0.5, 0),
                    BackgroundTransparency = 1,
                    ZIndex = 2,
                    Parent = button,
                })
                local hl = new("Frame", {
                    Name = "TabHighlight",
                    Position = UDim2.new(0, -20, 0, 0),
                    Size = UDim2.new(1, 20 + theme.TabExtra, 1, 0),
                    BackgroundColor3 = theme.TabHighlightColor,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ZIndex = 1,
                    Parent = button,
                })
                corner(hl, theme.TabRadius)
                bind(hl, "BackgroundColor3", "TabHighlightColor")
            end

            local page = new("CanvasGroup", {
                Name = tabName,
                Size = UDim2.new(1, 0, 1, -theme.HeaderHeight),
                Position = UDim2.new(0, 0, 0, theme.HeaderHeight),
                BackgroundTransparency = 1,
                GroupTransparency = 0,
                Visible = false,
                Parent = content,
            })

            new("UIPadding", {
                PaddingTop = UDim.new(0, 16),
                PaddingBottom = UDim.new(0, 16),
                PaddingLeft = UDim.new(0, 20),
                PaddingRight = UDim.new(0, 20),
                Parent = page,
            })

            local columns = {}
            local colCount = {}
            for i = 1, 2 do
                local col = new("Frame", {
                    Name = "Column" .. i,
                    Position = UDim2.new((i - 1) * 0.5, i == 1 and 0 or 8, 0, 0),
                    Size = UDim2.new(0.5, -8, 1, 0),
                    BackgroundTransparency = 1,
                    Parent = page,
                })
                new("UIListLayout", {
                    FillDirection = Enum.FillDirection.Vertical,
                    Padding = UDim.new(0, 4),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = col,
                })
                columns[i] = col
            end

            local groupCounter = 0
            local function nextColumn(override)
                if override then
                    return columns[math.clamp(override, 1, 2)], override
                end
                groupCounter += 1
                local idx = ((groupCounter - 1) % 2) + 1
                return columns[idx], idx
            end

            local function orderIn(colIdx)
                colCount[colIdx] = (colCount[colIdx] or 0) + 1
                return colCount[colIdx]
            end

            local function makeToggle(parent, order, cfg2)
                cfg2 = cfg2 or {}
                local name = cfg2.Name or "Toggle"
                local callback = cfg2.Callback or function() end
                local state = cfg2.Default == true

                local row = new("TextButton", {
                    Name = name,
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundTransparency = 1,
                    AutoButtonColor = false,
                    Text = "",
                    LayoutOrder = order,
                    Parent = parent,
                })

                local nameLabel = new("TextLabel", {
                    Size = UDim2.new(1, -54, 1, 0),
                    BackgroundTransparency = 1,
                    Text = name,
                    Font = theme.GroupFont,
                    TextSize = 13,
                    TextColor3 = theme.SubText,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = row,
                })

                local hovered = false
                local function refreshNameColor()
                    TweenService:Create(nameLabel, TweenInfo.new(0.15), {
                        TextColor3 = (hovered or state) and theme.Text or theme.SubText,
                    }):Play()
                end
                table.insert(Lib.Refreshers, refreshNameColor)

                local pill = new("Frame", {
                    Size = UDim2.fromOffset(30, 16),
                    Position = UDim2.new(1, -32, 0.5, -8),
                    BackgroundColor3 = state and theme.ToggleOnPill or theme.ToggleOff,
                    BorderSizePixel = 0,
                    ClipsDescendants = false,
                    Parent = row,
                })
                corner(pill, 8)

                local knob = new("Frame", {
                    Size = UDim2.fromOffset(16, 16),
                    Position = state and UDim2.fromOffset(14, 0) or UDim2.fromOffset(0, 0),
                    BackgroundColor3 = state and theme.ToggleOn or theme.ToggleOffKnob,
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    Parent = pill,
                })
                corner(knob, 8)

                local toggle = {}
                toggle.Name = name
                toggle.Flag = cfg2.Flag

                local bindKey, bindMode = nil, "Toggle"
                local bindMenu, bindMenuShadow, keyLabel, modeToggleBtn, modeHoldBtn

                local function updateKeybind()
                    for i = #keybinds, 1, -1 do
                        if keybinds[i].toggle == toggle then
                            table.remove(keybinds, i)
                        end
                    end
                    if bindKey then
                        table.insert(keybinds, { toggle = toggle, key = bindKey, mode = bindMode })
                    end
                    if Lib.KeybindListRefresh then
                        Lib.KeybindListRefresh()
                    end
                end

                local function refreshModeButtons()
                    local on = bindMode == "Toggle"
                    modeToggleBtn.BackgroundColor3 = on and theme.Accent or theme.Second
                    modeToggleBtn.BackgroundTransparency = on and 0.2 or 0.4
                    modeToggleBtn.TextColor3 = on and Color3.fromRGB(255, 255, 255) or theme.SubText
                    modeHoldBtn.BackgroundColor3 = (not on) and theme.Accent or theme.Second
                    modeHoldBtn.BackgroundTransparency = (not on) and 0.2 or 0.4
                    modeHoldBtn.TextColor3 = (not on) and Color3.fromRGB(255, 255, 255) or theme.SubText
                end

                local function repositionMenu()
                    local abs = row.AbsolutePosition
                    bindMenu.Position = UDim2.fromOffset(
                        math.clamp(abs.X + row.AbsoluteSize.X - 196, 4, math.max(4, gui.AbsoluteSize.X - 200)),
                        math.clamp(abs.Y + row.AbsoluteSize.Y + 4, 4, math.max(4, gui.AbsoluteSize.Y - 88))
                    )
                end

                local function buildBindMenu()
                    bindMenu = new("Frame", {
                        Name = name .. "Bind",
                        Size = UDim2.fromOffset(196, 84),
                        BackgroundColor3 = theme.ContentColor,
                        BackgroundTransparency = 0.02,
                        BorderSizePixel = 0,
                        Visible = false,
                        ZIndex = 210,
                        Parent = gui,
                    })
                    corner(bindMenu, 6)
                    bind(bindMenu, "BackgroundColor3", "ContentColor")
                    bindMenuShadow = addShadow(bindMenu)
                    new("UIStroke", {
                        Color = theme.SubText, Thickness = 1, Transparency = 0.6, Parent = bindMenu,
                    })

                    local keyText = new("TextLabel", {
                        Text = "Key",
                        Font = theme.GroupFont,
                        TextSize = 13,
                        TextColor3 = theme.Text,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 9),
                        Size = UDim2.fromOffset(60, 22),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 211,
                        Parent = bindMenu,
                    })
                    bind(keyText, "TextColor3", "Text")

                    local keyButton = new("TextButton", {
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, -12, 0, 9),
                        Size = UDim2.fromOffset(84, 22),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        AutoButtonColor = false,
                        Text = "",
                        ZIndex = 211,
                        Parent = bindMenu,
                    })

                    addShadow(keyButton)

                    local keyFill = new("Frame", {
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundColor3 = theme.Second,
                        BackgroundTransparency = 0.3,
                        BorderSizePixel = 0,
                        ZIndex = 211,
                        Parent = keyButton,
                    })
                    corner(keyFill, 4)
                    bind(keyFill, "BackgroundColor3", "Second")
                    new("UIStroke", {
                        Color = theme.SubText, Thickness = 1, Transparency = 0.75, Parent = keyFill,
                    })

                    keyLabel = new("TextLabel", {
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Text = bindKey and bindKey.Name or "-",
                        Font = theme.GroupFont,
                        TextSize = 13,
                        TextColor3 = theme.Text,
                        ZIndex = 212,
                        Parent = keyButton,
                    })
                    bind(keyLabel, "TextColor3", "Text")

                    local menuDivider = new("Frame", {
                        Position = UDim2.new(0, 10, 0, 40),
                        Size = UDim2.new(1, -20, 0, 1),
                        BackgroundColor3 = theme.SubText,
                        BackgroundTransparency = theme.RowDividerTransparency,
                        BorderSizePixel = 0,
                        ZIndex = 211,
                        Parent = bindMenu,
                    })
                    bind(menuDivider, "BackgroundColor3", "SubText")

                    local modeText = new("TextLabel", {
                        Text = "Mode",
                        Font = theme.GroupFont,
                        TextSize = 13,
                        TextColor3 = theme.Text,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 50),
                        Size = UDim2.fromOffset(60, 22),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 211,
                        Parent = bindMenu,
                    })
                    bind(modeText, "TextColor3", "Text")

                    modeHoldBtn = new("TextButton", {
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, -12, 0, 50),
                        Size = UDim2.fromOffset(44, 22),
                        BackgroundColor3 = theme.Second,
                        BackgroundTransparency = 0.4,
                        BorderSizePixel = 0,
                        AutoButtonColor = false,
                        Text = "Hold",
                        Font = theme.GroupFont,
                        TextSize = 13,
                        TextColor3 = theme.SubText,
                        ZIndex = 211,
                        Parent = bindMenu,
                    })
                    corner(modeHoldBtn, 4)
                    new("UIStroke", {
                        Color = theme.SubText, Thickness = 1, Transparency = 0.75, Parent = modeHoldBtn,
                    })

                    modeToggleBtn = new("TextButton", {
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, -62, 0, 50),
                        Size = UDim2.fromOffset(44, 22),
                        BackgroundColor3 = theme.Accent,
                        BackgroundTransparency = 0.2,
                        BorderSizePixel = 0,
                        AutoButtonColor = false,
                        Text = "Toggle",
                        Font = theme.GroupFont,
                        TextSize = 13,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        ZIndex = 211,
                        Parent = bindMenu,
                    })
                    corner(modeToggleBtn, 4)
                    new("UIStroke", {
                        Color = theme.SubText, Thickness = 1, Transparency = 0.75, Parent = modeToggleBtn,
                    })

                    modeToggleBtn.MouseButton1Click:Connect(function()
                        bindMode = "Toggle"
                        refreshModeButtons()
                        updateKeybind()
                    end)
                    modeHoldBtn.MouseButton1Click:Connect(function()
                        bindMode = "Hold"
                        refreshModeButtons()
                        updateKeybind()
                    end)

                    keyButton.MouseButton1Click:Connect(function()
                        keyLabel.Text = "..."
                        local conn
                        conn = UserInputService.InputBegan:Connect(function(input, processed)
                            if processed then return end
                            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                            conn:Disconnect()
                            local kc = input.KeyCode
                            if kc == Enum.KeyCode.Escape or kc == Enum.KeyCode.Unknown then
                                keyLabel.Text = bindKey and bindKey.Name or "-"
                            else
                                bindKey = kc
                                keyLabel.Text = kc.Name
                                updateKeybind()
                            end
                        end)
                    end)

                    refreshModeButtons()
                    registerPopup(bindMenu, repositionMenu, row, bindMenuShadow)
                end

                row.MouseButton2Click:Connect(function()
                    if not bindMenu then buildBindMenu() end
                    if openPopup == bindMenu then
                        closePopupEx(bindMenu)
                        return
                    end
                    repositionMenu()
                    openPopupEx(bindMenu)
                end)

                local function updateVisual(instant)
                    local targetPos = state and UDim2.fromOffset(14, 0) or UDim2.fromOffset(0, 0)
                    local targetPill = state and theme.ToggleOnPill or theme.ToggleOff
                    local targetKnob = state and theme.ToggleOn or theme.ToggleOffKnob
                    refreshNameColor()
                    if instant then
                        knob.Position = targetPos
                        knob.BackgroundColor3 = targetKnob
                        pill.BackgroundColor3 = targetPill
                    else
                        TweenService:Create(knob, T2(0.15), { Position = targetPos, BackgroundColor3 = targetKnob }):Play()
                        TweenService:Create(pill, T2(0.15), { BackgroundColor3 = targetPill }):Play()
                    end
                end

                function toggle:Set(value)
                    state = value == true
                    updateVisual(false)
                    callback(state)
                    if Lib.KeybindListRefresh then
                        Lib.KeybindListRefresh()
                    end
                end

                function toggle:Get()
                    return state
                end

                function toggle:SetBind(kc, mode)
                    bindKey = kc
                    bindMode = mode or "Toggle"
                    if keyLabel then
                        keyLabel.Text = bindKey and bindKey.Name or "-"
                    end
                    updateKeybind()
                end

                function toggle:GetBind()
                    return bindKey, bindMode
                end

                toggle.Refresh = function()
                    updateVisual(true)
                end

                row.MouseButton1Click:Connect(function()
                    toggle:Set(not state)
                end)

                row.MouseEnter:Connect(function()
                    hovered = true
                    refreshNameColor()
                end)
                row.MouseLeave:Connect(function()
                    hovered = false
                    refreshNameColor()
                end)

                updateVisual(true)

                if cfg2.Flag then
                    Lib.Flags[cfg2.Flag] = toggle
                end
                table.insert(Lib.AllToggles, toggle)

                return toggle
            end

            button.MouseButton1Click:Connect(function()
                switchTab(button, page, tabName)
            end)

            if not currentPageName then
                currentButton = button
                currentPageName = tabName
                currentPageFrame = page
                page.Visible = true
                page.GroupTransparency = 0
                button.TextTransparency = 0
                local hlInit = button:FindFirstChild("TabHighlight")
                local initTarget = math.clamp(theme.TabHighlight + (Lib.ThemeAlpha.TabHighlightColor or 0), 0, 1)
                if hlInit then
                    hlInit.BackgroundTransparency = initTarget
                else
                    button.BackgroundTransparency = initTarget
                end
            end

            local tab = {
                Button = button,
                Page = page,
            }

            function tab:AddGroup(name, colOverride)
                local col, colIdx = nextColumn(colOverride)

                local groupLabel = new("TextLabel", {
                    Name = name or "Group",
                    Text = name or "Group",
                    Font = theme.GroupFont,
                    TextSize = theme.GroupSize,
                    TextColor3 = theme.SubText,
                    TextTransparency = 0.2,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    LayoutOrder = orderIn(colIdx),
                    Parent = col,
                })
                bind(groupLabel, "TextColor3", "SubText")

                local card = new("Frame", {
                    Name = (name or "Group") .. "Card",
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = theme.CardColor,
                    BackgroundTransparency = theme.CardTransparency,
                    BorderSizePixel = 0,
                    LayoutOrder = orderIn(colIdx),
                    Parent = col,
                })
                corner(card, theme.CardRadius)
                bind(card, "BackgroundColor3", "CardColor", "BackgroundTransparency", theme.CardTransparency)

                new("UIListLayout", {
                    FillDirection = Enum.FillDirection.Vertical,
                    Padding = UDim.new(0, 2),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = card,
                })
                new("UIPadding", {
                    PaddingTop = UDim.new(0, 4),
                    PaddingBottom = UDim.new(0, 4),
                    PaddingLeft = UDim.new(0, 12),
                    PaddingRight = UDim.new(0, 12),
                    Parent = card,
                })

                local elementOrder = 0
                local function nextSlot()
                    elementOrder += 1
                    if elementOrder > 1 then
                        local d = new("Frame", {
                            Name = "Divider",
                            Size = UDim2.new(1, 0, 0, 1),
                            BackgroundColor3 = theme.SubText,
                            BackgroundTransparency = theme.RowDividerTransparency,
                            BorderSizePixel = 0,
                            LayoutOrder = elementOrder * 10 - 5,
                            Parent = card,
                        })
                        bind(d, "BackgroundColor3", "SubText")
                    end
                    return elementOrder * 10
                end

                local group = {}

                function group:AddToggle(cfg2)
                    return makeToggle(card, nextSlot(), cfg2)
                end

                function group:AddSlider(cfg2)
                    return makeSliderRow(card, nextSlot(), cfg2)
                end

                function group:AddColorPicker(cfg2)
                    return makeColorPickerRow(card, nextSlot(), cfg2)
                end

                function group:AddMultiDropdown(cfg2)
                    return makeMultiDropdownRow(card, nextSlot(), cfg2)
                end

                function group:AddDropdown(cfg2)
                    return makeDropdownRow(card, nextSlot(), cfg2)
                end

                return group
            end

            function tab:AddToggle(cfg2)
                local col, colIdx = nextColumn()
                return makeToggle(col, orderIn(colIdx) * 10, cfg2)
            end

            function tab:GetPage()
                return page
            end

            return tab
        end

        return section
    end

    task.delay(0.4, function()
        Lib:Notify({
            Title = "welcome back :3",
            Duration = theme.NotifyDuration,
        })
    end)

    return window
end

local win = Lib:Window({
    Title = "LUAUSENSE",
    Size = UDim2.fromOffset(740, 500),
    ToggleKey = Enum.KeyCode.Insert,
    TillDate = "24.09.26",
    Watermark = {
        Enabled = true,
        FPS = true,
        Ping = true,
        Username = true,
        Time = true,
    },
    OnSave = function() end,
    OnScaleChange = function(scale) end,
    OnKeybindChange = function(kc) end,
})

local TabConfig = {
    { Name = "test",        Icon = "139650104834071" },
    { Name = "Aim Assist",  Icon = "10088146939" },
    { Name = "Players",     Icon = "11577689639" },
    { Name = "Chams",       Icon = "16149111731" },
    { Name = "Items",       Icon = "109065124754087" },
    { Name = "Visuals",     Icon = "7035631382" },
    { Name = "World",       Icon = "106546587226077" },
    { Name = "View",        Icon = "102976018150012" },
    { Name = "Indicators",  Icon = "131271826879872" },
    { Name = "Misc",        Icon = "18979524646" },
    { Name = "Inventory",   Icon = "98992199615101" },
    { Name = "Configs",     Icon = "101596398409097" },
}

local testSection = win:Section("test")

local createdTabs = {}
for _, tabDef in ipairs(TabConfig) do
    createdTabs[tabDef.Name] = testSection:Tab(tabDef.Name, tabDef.Icon)
end

local testTab = createdTabs["test"]

local mainGroup = testTab:AddGroup("Main")
mainGroup:AddDropdown({
    Name = "Weapon",
    Flag = "Weapon",
    Items = { "Global", "AWP", "SSG" },
    Default = "Global",
    Callback = function(selected) end,
})
mainGroup:AddToggle({
    Name = "Enabled",
    Flag = "Enabled",
    Default = false,
    Callback = function(v) end,
})
mainGroup:AddToggle({
    Name = "Silent Aim",
    Flag = "SilentAim",
    Callback = function(v) end,
})
mainGroup:AddSlider({
    Name = "Hit Chance",
    Flag = "HitChance",
    Min = 0, Max = 100, Default = 70,
    Format = function(v) return math.floor(v + 0.5) .. "%" end,
    Callback = function(v) end,
})
mainGroup:AddColorPicker({
    Name = "Tracer Color",
    Flag = "TracerColor",
    Default = Color3.fromRGB(0, 255, 128),
    Callback = function(c, a) end,
})

local otherGroup = testTab:AddGroup("Other")
otherGroup:AddToggle({
    Name = "History",
    Flag = "History",
})
otherGroup:AddToggle({
    Name = "Delay Shot",
    Flag = "DelayShot",
})
otherGroup:AddSlider({
    Name = "Field Of View",
    Flag = "FOV",
    Min = 0, Max = 90, Default = 30,
    Format = function(v) return string.format("%.1f", v) end,
    Callback = function(v) end,
})
otherGroup:AddColorPicker({
    Name = "Box Color",
    Flag = "BoxColor",
    Default = Color3.fromRGB(255, 170, 0),
    Callback = function(c, a) end,
})
otherGroup:AddMultiDropdown({
    Name = "Auto Stop",
    Flag = "AutoStop",
    Items = { "Early", "In Air", "Between Shoots" },
    Default = { "Early" },
    Callback = function(list) end,
})

win:Notify({
    Title = "UI Loaded",
    Text = "All systems are ready",
    Duration = 4,
})
