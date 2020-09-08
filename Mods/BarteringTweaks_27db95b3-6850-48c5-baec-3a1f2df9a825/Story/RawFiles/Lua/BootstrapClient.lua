Ext.Require("Shared.lua")

local function FixDiscountText(amount)
	local ui = Ext.GetBuiltinUI("Public/Game/GUI/trade.swf")
	if ui ~= nil then
		--public function setText(param1:Number, param2:String) : *
		--this.trade_mc.mcRepContainer.attitude_txt -- is index 2
		if type(amount) == "number" then
			ui:Invoke("setText", 2, tostring(math.ceil(amount)))
		else
			ui:Invoke("setText", 2, amount)
		end
	end
end

Ext.RegisterNetListener("LLBARTER_FixDiscountText", function(cmd, amountstr)
	FixDiscountText(amountstr)
end)

Ext.RegisterListener("SessionLoaded", function()
	---@param ui UIObject
	Ext.RegisterUINameCall("overItem", function(ui, ...)
		print("Trade window type:", ui:GetTypeId(), Ext.JsonStringify({...}))
	end)
	Ext.RegisterUINameInvokeListener("setText", function(ui, ...)
		print("Trade window type:", ui:GetTypeId(), Ext.JsonStringify({...}))
	end)
end)