Ext.Require("Shared.lua")

local AttitudeText = {Handle = "h23e8dcb9ge11bg473cg8530gaaf469804cb1", Text = "Attitude: [1]"}
local BarterText = {Handle = "hd009ea2cga6a2g44ddg9f9fg340baaacd497", Text = "Bartering: [1]"}
local DiscountText = {Handle = "h34d2b29fg9587g4fbdga7dege1381e5f0fbb", Text = "Discount: [1]%"}
local attitudeTextTemplate = "<font color=\"#FCD203\">%i</font>"
local attitudePositiveTooltipTextTemplate = "%s<br>%s<br><font color=\"#40B606\">%s</font>"
local attitudeNegativeTooltipTextTemplate = "%s<br>%s<br><font color=\"#FF0000\">%s</font>"

--[[
setText index:
2	The attitude number.
1	The trader's name.
0	The player's name.
]]

---@class BarterData
---@field Attitude integer
---@field Barter integer
---@field Discount integer
---@field Player string
---@field Trader string
---@field TraderName string

---@type BarterData
local barterData = {}

local function FixDiscountText(attitude, barter, discount)
	--"Public/Game/GUI/trade.swf"
	local ui = Ext.GetUIByType(46)
	if ui ~= nil then
		--public function setText(param1:Number, param2:String) : *
		--this.trade_mc.mcRepContainer.attitude_txt -- is index 2
		ui:Invoke("setText", 2, string.format(attitudeTextTemplate, attitude))

		-- Updating the tooltip
		local main = ui:GetRoot()
		local attitudeText = Ext.GetTranslatedString(AttitudeText.Handle, AttitudeText.Text):gsub("%[1%]", attitude)
		local barterText = Ext.GetTranslatedString(BarterText.Handle, BarterText.Text):gsub("%[1%]", barter)
		local discountText = Ext.GetTranslatedString(DiscountText.Handle, DiscountText.Text):gsub("%%", "%%%%"):gsub("%[1%]", discount)
		if discount > 0 then
			main.trade_mc.tooltip_array[0].tooltip = string.format(attitudePositiveTooltipTextTemplate, attitudeText, barterText, discountText)
		else
			main.trade_mc.tooltip_array[0].tooltip = string.format(attitudeNegativeTooltipTextTemplate, attitudeText, barterText, discountText)
		end
		--ui:Invoke("setTooltip", 0, string.format(attitudeTooltipTextTemplate, attitude, barter, discount))
	end
end

Ext.RegisterNetListener("LLBARTER_FixDiscountText", function(cmd, datastr)
	-- if datastr ~= nil and datastr ~= "" then
	-- 	local nextData = Ext.JsonParse(datastr)
	-- 	if nextData ~= nil and nextData.Barter ~= nil then
	-- 		barterData = nextData
	-- 	end
	-- end
	-- if barterData ~= nil and barterData.Barter ~= nil then
	-- 	FixDiscountText(barterData.Attitude, barterData.Barter, barterData.Discount)
	-- end
	local ui = Ext.GetUIByType(46)
	if ui ~= nil then
		local main = ui:GetRoot()
		local currentTab = main.trade_mc.playerTabList.m_CurrentSelection
		ui:ExternalInterfaceCall("selectedPlayerTab",currentTab.id)
		Ext.Print("Selected tab", currentTab.id)
	end
end)

Ext.RegisterNetListener("LLBARTER_StoreDiscountText", function(cmd, datastr)
	barterData = Ext.JsonParse(datastr)
end)

Ext.RegisterListener("SessionLoaded", function()
	---@param ui UIObject
	Ext.RegisterUITypeInvokeListener(46, "setTooltip", function(ui, method, index, text)
		print(method, index, text)
		if index == 0 and text ~= nil and text ~= "" then
			-- local uuid = ""
			-- if barterData ~= nil and barterData.Player ~= nil then
			-- 	uuid = barterData.Player
			-- end
			--Ext.PostMessageToServer("LLBARTER_StartDiscountFixTimer", "")
		end
	end)
	Ext.RegisterUITypeInvokeListener(46, "updateCharList", function(ui, method, ...)
		print(method, Ext.JsonStringify({...}))
		Ext.PostMessageToServer("LLBARTER_StartDiscountFixTimer", "")
	end)
	Ext.RegisterUITypeInvokeListener(46, "addTraderTab", function(ui, ...)
		print(Ext.JsonStringify({...}))
	end)
	Ext.RegisterUITypeInvokeListener(46, "addTab", function(ui, ...)
		print(Ext.JsonStringify({...}))
	end)
end)