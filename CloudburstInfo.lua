local ADDON, CloudburstInfo = ...

Settings = {}

-- return readable number

local function ReadableNumber(num, places)
  local ret
  local placeValue = ("%%.%df"):format(places or 0)
  if not num then
    return 0
  elseif num >= 1e12 then
    ret = placeValue:format(num / 1e12) .. "t" -- trillion
  elseif num >= 1e9 then
    ret = placeValue:format(num / 1e9) .. "b" -- billion
  elseif num >= 1e6 then
    ret = placeValue:format(num / 1e6) .. "m" -- million
  elseif num >= 1e3 then
    ret = placeValue:format(num / 1e3) .. "k" -- thousand
  else
    ret = num -- hundreds
  end
  return ret
end

-------------------
-- options frame --
-------------------

local options = CreateFrame("Frame", "cbiOptions", InterfaceOptionsFramePanelContainer)

options.name = GetAddOnMetadata(ADDON, "Title")
options.version = GetAddOnMetadata(ADDON, "Version")

InterfaceOptions_AddCategory(options)

options:Hide()

options:SetScript("OnShow", function()
  -- options frame
  local LeftSide = CreateFrame("Frame", "LeftSide", options)
  LeftSide:SetHeight(options:GetHeight())
  LeftSide:SetWidth(options:GetWidth())
  LeftSide:SetPoint("TOPLEFT", options, "TOPLEFT")

  -- options title
  local optionsTitle = options:CreateFontString("OptionsTitle", "ARTWORK", "GameFontNormalLarge")
  optionsTitle:SetPoint("TOPLEFT", LeftSide, 16, -16)
  optionsTitle:SetText("Options")

  -- short numbers option
  local shortNumbers = CreateFrame("CheckButton", "ShortNumbers", LeftSide, "InterfaceOptionsCheckButtonTemplate")
  shortNumbers:SetPoint("TOPLEFT", optionsTitle, "BOTTOMLEFT", 0, -18)
  shortNumbers.Text:SetText("Short Numbers")
  shortNumbers:SetScript("OnClick", function(this)
    if this:GetChecked() then
      Settings.ShortNumbers = true
    else
      Settings.ShortNumbers = false
    end
  end)

  if Settings.ShortNumbers == true then
    shortNumbers:SetChecked(true)
  end

  -- addon title and version number
  local addonTitle = options:CreateFontString("$parentTitle", "ARTWORK", "GameFontNormalLarge")
  addonTitle:SetPoint("BOTTOMRIGHT", -16, 16)
  addonTitle:SetText(options.name..' '..options.version)

end)

--------------------------
-- cloudburstinfo frame --
--------------------------

local healingFrame = CreateFrame("Frame", "cbiFrame", UIParent)

healingFrame:SetPoint("CENTER", 0, 0)
healingFrame:SetWidth(80)
healingFrame:SetHeight(22)
healingFrame:EnableMouse(true)
healingFrame:SetMovable(true)
healingFrame:SetUserPlaced(true)
healingFrame:RegisterForDrag("LeftButton")

healingFrame:SetScript("OnEvent", function(self, event, ...)
  if type(Settings)~="table" then
    Settings = {}
  elseif Settings.Xpos then
    healingFrame:ClearAllPoints()
    text:SetPoint("CENTER", Settings.Xpos, Settings.Ypos)
  end
end)

healingFrame:SetScript("OnDragStart", function(self)
  if IsShiftKeyDown() then
    self:StartMoving()
  end
end)

healingFrame:SetScript("OnDragStop", function(self)
  healingFrame:StopMovingOrSizing()
  Settings.Xpos = self:GetLeft()
  Settings.Ypos = self:GetBottom()
end)

local text = healingFrame:CreateFontString(nil, "OVERLAY")
text:SetFont("Fonts\\ARIALN.ttf", 18)
text:SetTextColor(0, 171, 255, 1)
text:SetPoint("CENTER", 0, 0)

healingFrame:RegisterEvent("UNIT_AURA")

local function UpdateText(self, event)
  if UnitBuff("player", "Cloudburst Totem") then
    local value = select(17, UnitBuff("player", "Cloudburst Totem"))
    if value <= 0 then
      text:SetText(nil)
    elseif Settings.ShortNumbers == true then
      local readableValue = ReadableNumber(value, 2)
      text:SetText(readableValue)
    else
      text:SetText(value)
    end
  else
    text:SetText(nil)
  end
end

healingFrame:SetScript("OnEvent", UpdateText)
