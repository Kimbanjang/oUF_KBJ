local name, ns = ...
local cfg = ns.cfg

local channelingTicks = {
    -- Druid
    [GetSpellInfo(740)] = 4,    -- Tranquility
--  [GetSpellInfo(16914)] = 10, -- Hurricane
--  [GetSpellInfo(106996)] = 10,-- Astral Storm
    -- Mage
    [GetSpellInfo(5143)] = 5,   -- Arcane Missiles
--  [GetSpellInfo(10)] = 8,     -- Blizzard
    [GetSpellInfo(12051)] = 4,  -- Evocation
    -- Monk
    [GetSpellInfo(115175)] = 9, -- Soothing Mist
    -- Priest
    [GetSpellInfo(15407)] = 3,  -- Mind Flay
    [GetSpellInfo(48045)] = 5,  -- Mind Sear
    [GetSpellInfo(47540)] = 2,  -- Penance
    --[GetSpellInfo(64901)] = 4,    -- Hymn of Hope
    [GetSpellInfo(64843)] = 4,  -- Divine Hymn
    -- Warlock
    [GetSpellInfo(689)] = 6,    -- Drain Life
--  [GetSpellInfo(108371)] = 6, -- Harvest Life
--  [GetSpellInfo(103103)] = 3, -- Drain Soul
    [GetSpellInfo(755)] = 6,    -- Health Funnel
--  [GetSpellInfo(1949)] = 15,  -- Hellfire
    [GetSpellInfo(5740)] = 4,   -- Rain of Fire
--  [GetSpellInfo(103103)] = 3, -- Malefic Grasp
}

local ticks = {}

local setBarTicks = function(castBar, ticknum)
    if ticknum and ticknum > 0 then
        local delta = castBar:GetWidth() / ticknum
        for k = 1, ticknum do
            if not ticks[k] then
                ticks[k] = castBar:CreateTexture(nil, 'OVERLAY')
                ticks[k]:SetTexture(cfg.texture)
                ticks[k]:SetVertexColor(0.6, 0.6, 0.6)
                ticks[k]:SetWidth(1)
                ticks[k]:SetHeight(21)
            end
            ticks[k]:ClearAllPoints()
            ticks[k]:SetPoint('CENTER', castBar, 'LEFT', delta * k, 0 )
            ticks[k]:Show()
        end
    else
        for k, v in pairs(ticks) do
            v:Hide()
        end
    end
end

local OnCastbarUpdate = function(self, elapsed)
    local currentTime = GetTime()
    local _, _, _, latencyWorld = GetNetStats()
    if self.casting or self.channeling then
        local parent = self:GetParent()
        local duration = self.casting and self.duration + elapsed or self.duration - elapsed
        if (self.casting and duration >= self.max) or (self.channeling and duration <= 0) then
            self.casting = nil
            self.channeling = nil
            return
        end
        if parent.unit == 'player' then
            if self.delay ~= 0 then
                self.Time:SetFormattedText('%.1f | %.1f |cffff0000|%.1f|r', duration, self.max, self.delay )
            elseif self.Lag then
                self.Time:SetFormattedText('%.1f | %.1f', duration, self.max)
                self.Lag:SetFormattedText('%d ms', latencyWorld)
            else
                self.Time:SetFormattedText('%.1f | %.1f', duration, self.max)
            end
        else
            self.Time:SetFormattedText('%.1f | %.1f', duration, self.casting and self.max + self.delay or self.max - self.delay)
        end
        self.duration = duration
        self:SetValue(duration)
        self.Spark:SetPoint('CENTER', self, 'LEFT', (duration / self.max) * self:GetWidth(), 0)
    elseif self.fadeOut then
        self.Spark:Hide()
        local alpha = self:GetAlpha() - 0.02
        if alpha > 0 then
            self:SetAlpha(alpha)
        else
            self.fadeOut = nil
            self:Hide()
        end
    end
end

local PostCastStart = function(self, unit)
    self:SetAlpha(1.0)
    self.Spark:Show()
    self:SetStatusBarColor(unpack(self.casting and self.CastingColor or self.ChannelingColor))
    if self.casting then
        self.cast = true
    else
        self.cast = false
    end
    if unit == 'vehicle' then
        self.SafeZone:Hide()
        self.Lag:Hide()
    elseif unit == 'player' then
        if not UnitInVehicle('player') then self.SafeZone:Show() else self.SafeZone:Hide() end
        if self.casting then
            setBarTicks(self, 0)
        else
            local spell = UnitChannelInfo(unit)
            self.channelingTicks = channelingTicks[spell] or 0
            setBarTicks(self, self.channelingTicks)
        end
    end
    if unit ~= 'player' and self.interrupt and UnitCanAttack('player', unit) then
        self:SetStatusBarColor(1, 1, 1)
    end
end

local PostCastStop = function(self, unit)
    if not self.fadeOut then
        self:SetStatusBarColor(unpack(self.CompleteColor))
        self.fadeOut = true
    end
    self:SetValue(self.cast and self.max or 0)
    self:Show()
end

local PostCastFailed = function(self, event, unit)
    self:SetStatusBarColor(unpack(self.FailColor))
    self:SetValue(self.max)
    if not self.fadeOut then
        self.fadeOut = true
    end
    self:Show()
end

function castbar(self, unit)
    local cb = createStatusbar(self, cfg.texture, nil, nil, nil, 1, 1, 1, 1)        
    local cbbg = cb:CreateTexture(nil, 'BACKGROUND')
    cbbg:SetAllPoints(cb)
    cbbg:SetTexture(cfg.texture)
    cbbg:SetVertexColor(1, 1, 1, .2)
    cb.Time = fs(cb, 'OVERLAY', cfg.font, cfg.fontsize, cfg.fontflag, 1, 1, 1)
    cb.Time:SetPoint('RIGHT', cb, -2, 0)    
    cb.CastingColor = {1, 0.7, 0}
    cb.CompleteColor = {0.12, 0.86, 0.15}
    cb.FailColor = {1.0, 0.09, 0}
    cb.ChannelingColor = {0.65, 0.4, 0}
    cb.Icon = cb:CreateTexture(nil, 'ARTWORK')
    cb.Icon:SetPoint('BOTTOMRIGHT', cb, 'BOTTOMLEFT', -3, 0)
    cb.Icon:SetTexCoord(.1, .9, .1, .9)

    if self.unit == 'player' then
        cb:SetPoint(unpack(cfg.player_cb.pos))
        cb:SetSize(cfg.player_cb.width, cfg.player_cb.height)
        cb.Icon:SetSize(cfg.player_cb.height*2, cfg.player_cb.height*2)
        cb.SafeZone = cb:CreateTexture(nil, 'ARTWORK')
        cb.SafeZone:SetTexture(cfg.texture)
        cb.SafeZone:SetVertexColor(.8,.11,.15, .7)
        cb.Lag = fs(cb, 'OVERLAY', cfg.font, cfg.fontsize, cfg.fontflag, 1, 1, 1)
        cb.Lag:SetPoint('TOPRIGHT', 3, 13)
        cb.Lag:SetJustifyH('RIGHT')
    elseif self.unit == 'target' then
        cb:SetPoint(unpack(cfg.target_cb.pos))
        cb:SetSize(cfg.target_cb.width, cfg.target_cb.height)
        cb.Icon:SetSize(cfg.target_cb.height, cfg.target_cb.height)
        cb.Text = fs(cb, 'OVERLAY', cfg.krfont, 12, cfg.krfontflag, 1, 1, 1, 'LEFT')
        cb.Text:SetPoint('LEFT', cb, 2, 0)
        cb.Text:SetPoint('RIGHT', cb.Time, 'LEFT')
        cb.SafeZone = cb:CreateTexture(nil, 'ARTWORK')
        cb.SafeZone:SetTexture(cfg.texture)
        cb.SafeZone:SetVertexColor(.8,.11,.15, .7)
    elseif self.unit == 'focus' then
        cb:SetPoint(unpack(cfg.focus_cb.pos))
        cb:SetSize(cfg.focus_cb.width, cfg.focus_cb.height)
        cb.Icon:SetSize(cfg.focus_cb.height, cfg.focus_cb.height)
        cb.Text = fs(cb, 'OVERLAY', cfg.krfont, 12, cfg.krfontflag, 1, 1, 1, 'LEFT')
        cb.Text:SetPoint('LEFT', cb, 2, 0)
        cb.Text:SetPoint('RIGHT', cb.Time, 'LEFT')
        cb.SafeZone = cb:CreateTexture(nil, 'ARTWORK')
        cb.SafeZone:SetTexture(cfg.texture)
        cb.SafeZone:SetVertexColor(.8,.11,.15, .7)
    elseif self.unit == 'boss' then
        cb:SetPoint(unpack(cfg.boss_cb.pos))
        cb:SetSize(cfg.boss_cb.width, cfg.boss_cb.height)
        cb.Icon:SetSize(cfg.boss_cb.height, cfg.boss_cb.height)
        cb.Text = fs(cb, 'OVERLAY', cfg.krfont, 12, cfg.krfontflag, 1, 1, 1, 'LEFT')
        cb.Text:SetPoint('LEFT', cb, 2, 0)
        cb.Text:SetPoint('RIGHT', cb.Time, 'LEFT')
    elseif self.unit == 'arena' then
        cb:SetPoint(unpack(cfg.arena_cb.pos))
        cb:SetSize(cfg.arena_cb.width, cfg.arena_cb.height)
        cb.Icon:SetSize(cfg.arena_cb.height, cfg.arena_cb.height)
        cb.Text = fs(cb, 'OVERLAY', cfg.krfont, 12, cfg.krfontflag, 1, 1, 1, 'LEFT')
        cb.Text:SetPoint('LEFT', cb, 2, 0)
        cb.Text:SetPoint('RIGHT', cb.Time, 'LEFT')
    end
    
    cb.Spark = cb:CreateTexture(nil,'OVERLAY')
    cb.Spark:SetTexture([=[Interface\Buttons\WHITE8x8]=])
    cb.Spark:SetBlendMode('Add')
    cb.Spark:SetHeight(cb:GetHeight())
    cb.Spark:SetWidth(1)
    cb.Spark:SetVertexColor(1, 1, 1)
    
    cb.OnUpdate = OnCastbarUpdate
    cb.PostCastStart = PostCastStart
    cb.PostChannelStart = PostCastStart
    cb.PostCastStop = PostCastStop
    cb.PostChannelStop = PostCastStop
    cb.PostCastFailed = PostCastFailed
    cb.PostCastInterrupted = PostCastFailed
    cb.bg = cbbg
    cb.Backdrop = framebd(cb, cb)
    cb.IBackdrop = framebd(cb, cb.Icon)
    self.Castbar = cb
end
