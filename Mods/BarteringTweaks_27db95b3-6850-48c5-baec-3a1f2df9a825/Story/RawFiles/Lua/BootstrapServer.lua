Ext.Require("Shared.lua")

---@type ModSettings
local settings = nil
-- LeaderLib
if Ext.IsModLoaded("7e737d2f-31d2-4751-963f-be6ccc59cd0c") then
	Ext.RegisterListener("SessionLoaded", function()
		local LeaderLib = Mods.LeaderLib
		local Classes = LeaderLib.Classes
	
		---@type ModSettings
		local ModSettings = Classes.ModSettingsClasses.ModSettings
		settings = ModSettings:Create("27db95b3-6850-48c5-baec-3a1f2df9a825")
		settings.Global:AddFlags({
			"LLBARTER_BarterSharingDisabled",
			"LLBARTER_PersuasionDialogSharingEnabled",
			"LLBARTER_AttitudeSharingEnabled",
			"LLBARTER_PetPalTagModeDisabled",
			"LLBARTER_SneakingTweaksEnabled",
			"LLBARTER_PreventTraderBooksEnabled",
		})
		settings.Global:AddFlag("LLBARTER_SneakingTweaksDisabled", "User", false)
		LeaderLib.SettingsManager.AddSettings(settings)
	end)

end

function SetSneakingTweaksDisabled(id)
	if settings ~= nil then
		settings.Global.Flags.LLBARTER_SneakingTweaksDisabled.Targets[id] = true
	end
end

function SetSneakingTweaksEnabled(id)
	if settings ~= nil then
		settings.Global.Flags.LLBARTER_SneakingTweaksDisabled.Targets[id] = nil
	end
end


function FixDiscountText(uuid, amount)
	Ext.PostMessageToClient(uuid, "LLBARTER_FixDiscountText", amount)
end

function ClearOldGlobalSettings()
	Osi.DB_LeaderLib_ModApi_GlobalSettings_Register_GlobalFlag:Delete("27db95b3-6850-48c5-baec-3a1f2df9a825", nil)
	Osi.DB_LeaderLib_ModApi_GlobalSettings_Register_GlobalFlag:Delete("27db95b3-6850-48c5-baec-3a1f2df9a825", nil, nil)
	Osi.DB_LeaderLib_GlobalSettings_GlobalFlags:Delete("27db95b3-6850-48c5-baec-3a1f2df9a825", nil, nil)
end

---@type StatTreasureSubTable
local EnabledBooksSubtables = {
	{
		Amounts = {1},
		DropCounts = {1},
		Categories = {
			{
				Frequency = 1,
				TreasureCategory = "I_BOOK_LLBARTER_PetPalTalentBook",
				Unique = 1
			},
		},
		TotalCount = 1,
		TotalFrequency = 1
	},
	{
		Amounts = {1},
		DropCounts = {1},
		Categories = {
			{
				Frequency = 1,
				TreasureCategory = "I_BOOK_LLBARTER_SettingsBook",
				Unique = 1
			}
		},
		TotalCount = 1,
		TotalFrequency = 1
	}
}

function DisableBookTreasure()
	local stat = Ext.GetTreasureTable("ST_BarteringTweaks_Books")
	if stat ~= nil then
		stat.SubTables = nil
		print(stat, stat.SubTables, stat.Name)
		Ext.UpdateTreasureTable(stat)
	end
end

function EnableBookTreasure()
	local stat = Ext.GetTreasureTable("ST_BarteringTweaks_Books")
	if stat ~= nil then
		stat.SubTables = EnabledBooksSubtables
		Ext.UpdateTreasureTable(stat)
	end
end

Ext.RegisterOsirisListener("GameStarted", 2, "after", function(region, editorMode)
	if GlobalGetFlag("LLBARTER_PreventTraderBooksEnabled") == 1 then
		DisableBookTreasure()
	else
		--EnableBookTreasure()
	end
end)