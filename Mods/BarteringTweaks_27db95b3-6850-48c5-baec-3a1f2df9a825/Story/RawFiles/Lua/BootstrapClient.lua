Ext.Require("Shared.lua")

local attitudeTextTemplate = "<font color=\"#FCD203\">%i</font>"
local attitudeTooltipTextTemplate = "Attitude: %i<br>Bartering: %i<br><font color=\"#40B606\">Discount: %i%%</font>"

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

local function FixDiscountText(attitude, bartering, discount)
	--"Public/Game/GUI/trade.swf"
	local ui = Ext.GetUIByType(46)
	if ui ~= nil then
		--public function setText(param1:Number, param2:String) : *
		--this.trade_mc.mcRepContainer.attitude_txt -- is index 2
		ui:Invoke("setText", 2, string.format(attitudeTextTemplate, attitude))

		-- Updating the tooltip
		local main = ui:GetRoot()
		main.trade_mc.tooltip_array[0].tooltip = string.format(attitudeTooltipTextTemplate, attitude, bartering, discount);
		--ui:Invoke("setTooltip", 0, string.format(attitudeTooltipTextTemplate, attitude, bartering, discount))
	end
end

Ext.RegisterNetListener("LLBARTER_FixDiscountText", function(cmd, datastr)
	if datastr ~= nil and datastr ~= "" then
		local nextData = Ext.JsonParse(datastr)
		if nextData ~= nil and nextData.Barter ~= nil then
			barterData = nextData
		end
	end
	if barterData ~= nil and barterData.Barter ~= nil then
		FixDiscountText(barterData.Attitude, barterData.Barter, barterData.Discount)
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
			local uuid = ""
			if barterData ~= nil and barterData.Player ~= nil then
				uuid = barterData.Player
			end
			Ext.PostMessageToServer("LLBARTER_StartDiscountFixTimer", uuid)
		end
	end)
	Ext.RegisterUINameInvokeListener(46, "addTraderTab", function(ui, ...)
		print(Ext.JsonStringify({...}))
	end)
	Ext.RegisterUINameInvokeListener(46, "addTab", function(ui, ...)
		print(Ext.JsonStringify({...}))
	end)
end)