Ext.Require("Shared.lua")

function SetSneakingTweaksDisabled(id)
	if Settings ~= nil then
		Settings.Global.Flags.LLBARTER_SneakingTweaksDisabled.Targets[id] = true
	end
end

function SetSneakingTweaksEnabled(id)
	if Settings ~= nil then
		Settings.Global.Flags.LLBARTER_SneakingTweaksDisabled.Targets[id] = nil
	end
end

local function CalculateDiscount(party, barter, attitude)
	local PriceAttitudeCoefficient = Ext.ExtraData.PriceAttitudeCoefficient or 1.0
	local PriceBarterCoefficient = Ext.ExtraData.PriceBarterCoefficient or 1.0

	local reputationEffect = attitude * PriceAttitudeCoefficient
	local barterEffect = barter * PriceBarterCoefficient

	local PriceModDifficulty = Ext.ExtraData.PriceModClassicDifficulty or 1.0
	--TODO: Get the difficulty. We have no way to do this as of 9/8/2020
	if IsHardcoreMode() == 1 then
		PriceModDifficulty = Ext.ExtraData.PriceModHardcoreDifficulty or 1.0
	end
	PriceModDifficulty = (PriceModDifficulty - barterEffect) - reputationEffect

	--TODO: Get price tag modifiers and whatever esv::Party::GetNPCDataFor returns
	local PriceModDifficulty2 = math.max(PriceModDifficulty, 1.0)
	--local GlobalPriceModifier = GetGlobalPriceModifier()
	--local result = Ext.Round(ApplyPriceTagModifiers(party, PriceModDifficulty2))

	-- Get party -> get NPC data for party?

	return PriceModDifficulty
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

-- Ext.RegisterOsirisListener("RequestTrade", 2, "after", function(player, trader)
-- 	local data = GetBarteringData(player, trader)
-- 	Ext.PostMessageToClient(player, "LLBARTER_StoreDiscountText", Ext.JsonStringify(data))
-- end)

local function PartyIsSharingBonuses()
	for i,db in pairs(Osi.DB_IsPlayer:Get(nil)) do
		if UserGetFlag(db[1], "LLBARTER_BarterBonusActive") == 1 then
			return true
		elseif UserGetFlag(db[1], "LLBARTER_PersuasionBonusApplied") == 1 then
			return true
		end
	end
	return false
end

Ext.RegisterNetListener("LLBARTER_StartDiscountFixTimer", function(cmd, uuid)
	print(cmd, uuid)
	if uuid ~= nil and uuid ~= "" and ObjectExists(uuid) == 1 then
		Osi.ProcObjectTimerCancel(uuid, "Timers_LLBARTER_UI_FixDiscountText")
		Osi.ProcObjectTimer(uuid, "Timers_LLBARTER_UI_FixDiscountText", 50)
	else
		TimerCancel("Timers_LLBARTER_UI_FixDiscountText")
		TimerLaunch("Timers_LLBARTER_UI_FixDiscountText", 250)
	end
end)

function FixDiscountText(uuid)
	if PartyIsSharingBonuses() then
		if uuid ~= nil then
			Ext.PostMessageToClient(uuid, "LLBARTER_FixDiscountText", "")
		else
			Ext.BroadcastMessage("LLBARTER_FixDiscountText", "", nil)
		end
	else
		Ext.Print("Skipping discount fix")
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
		Ext.Print("[BarteringTweaks] Disabled treasure table for BT books.")
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