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

local function CalculateDiscount(barter, attitude)
	--TODO
	local aCo = Ext.ExtraData.PriceAttitudeCoefficient or 1.0
	local bCo = Ext.ExtraData.PriceBarterCoefficient or 1.0

	local repEffect = attitude * aCo
	local barterEffet = barter * bCo

	local priceModDiff = Ext.ExtraData.PriceModClassicDifficulty or 1.0
	priceModDiff = (priceModDiff - barterEffet) - repEffect
	-- Get party -> get NPC data for party?

	return priceModDiff
end

local function GetBarteringData(player, trader)
	local barter = Ext.GetCharacter(player).Stats.Barter
	local attitude = CharacterGetAttitudeTowardsPlayer(trader, player)
	local discount = CalculateDiscount(barter, attitude)

	local data = {
		Player = GetUUID(player),
		Trader = GetUUID(trader),
		TraderName = Ext.GetCharacter(trader).DisplayName,
		Barter = barter,
		Attitude = attitude,
		Discount = discount
	}

	return data
end

Ext.RegisterOsirisListener("RequestTrade", 2, "after", function(player, trader)
	local data = GetBarteringData(player, trader)
	Ext.PostMessageToClient(player, "LLBARTER_StoreDiscountText", Ext.JsonStringify(data))
end)

Ext.RegisterListener("LLBARTER_StartDiscountFixTimer", function(cmd, uuid)
	if uuid ~= nil then
		Osi.ProcObjectTimerCancel(uuid, "Timers_LLBARTER_UI_FixDiscountText")
		Osi.ProcObjectTimer(uuid, "Timers_LLBARTER_UI_FixDiscountText", 50)
	else
		TimerCancel("Timers_LLBARTER_UI_FixDiscountText")
		TimerLaunch("Timers_LLBARTER_UI_FixDiscountText", 50)
	end
end)

function FixDiscountText(uuid)
	if uuid ~= nil then
		Ext.PostMessageToClient(uuid, "LLBARTER_FixDiscountText", "")
	else
		Ext.BroadcastMessage("LLBARTER_FixDiscountText", "", nil)
	end
end

function ClearOldGlobalSettings()
	local b,result = xpcall(function()
		Osi.DB_LeaderLib_ModApi_GlobalSettings_Register_GlobalFlag:Delete("27db95b3-6850-48c5-baec-3a1f2df9a825", nil)
		Osi.DB_LeaderLib_ModApi_GlobalSettings_Register_GlobalFlag:Delete("27db95b3-6850-48c5-baec-3a1f2df9a825", nil, nil)
		Osi.DB_LeaderLib_GlobalSettings_GlobalFlags:Delete("27db95b3-6850-48c5-baec-3a1f2df9a825", nil, nil)
	end, debug.traceback)
	if not b then
		Ext.PrintError("[BarteringTweaks:ClearOldGlobalSettings] Error:")
		Ext.PrintError(result)
	end
end

local defaultDropCount = {{Chance=1,Amount=1}}

---@type StatTreasureSubTable
local EnabledBooksSubtables = {
	{
		Amounts = {1},
		DropCounts = defaultDropCount,
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
		DropCounts = defaultDropCount,
		Categories = {
			{
				Frequency = 1,
				TreasureCategory = "I_BOOK_LLBARTER_SettingsBook",
				Unique = 1
			}
		},
		TotalCount = 1,
		TotalFrequency = 2
	}
}

function DisableBookTreasure()
	local stat = Ext.GetTreasureTable("ST_BarteringTweaks_Books")
	if stat ~= nil then
		stat.SubTables = {
			{
				Amounts = {1},
				DropCounts = defaultDropCount,
				Categories = {
					{
						Frequency = 1,
						TreasureCategory = "Gold",
					},
				},
				TotalCount = 1,
				TotalFrequency = 1
			},
		}
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