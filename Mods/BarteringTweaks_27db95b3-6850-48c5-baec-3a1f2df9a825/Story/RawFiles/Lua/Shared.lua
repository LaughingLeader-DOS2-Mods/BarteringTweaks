Ext.RegisterListener("StatsLoaded", function()
    --Kalavinkas_Combat_Enhanced_e844229e-b744-4294-9102-a7362a926f71
    if Ext.IsModLoaded("e844229e-b744-4294-9102-a7362a926f71") then
		Ext.Print("[BarteringTweaks] Divinity Unleashed detected. Changing the Pet Pal book's description.")
		--Original:
		--6d71b1e0-4150-47fe-bc77-83d9b3efcb77
		Ext.StatSetAttribute("BOOK_LLBARTER_PetPalTalentBook", "RootTemplate", "f31d4498-59a5-4f04-ba96-89a750111ed7")
	end
end)

---@type ModSettings
Settings = nil
-- LeaderLib
if Ext.IsModLoaded("7e737d2f-31d2-4751-963f-be6ccc59cd0c") then
	Ext.RegisterListener("SessionLoaded", function()
		local LeaderLib = Mods.LeaderLib
		local Classes = LeaderLib.Classes
	
		---@type ModSettings
		Settings = Mods.LeaderLib.CreateModSettings("27db95b3-6850-48c5-baec-3a1f2df9a825")
		Settings.Global:AddLocalizedFlags({
			"LLBARTER_BarterSharingDisabled",
			"LLBARTER_PersuasionDialogSharingEnabled",
			"LLBARTER_AttitudeSharingEnabled",
			"LLBARTER_PetPalTagModeDisabled",
			"LLBARTER_SneakingTweaksEnabled",
			"LLBARTER_PreventTraderBooksEnabled",
		})
		Settings.Global:AddLocalizedFlag("LLBARTER_SneakingTweaksDisabled", "User", false)

		Settings.GetMenuOrder = function()
			return {{
				Entries = {
					"LLBARTER_BarterSharingDisabled",
					"LLBARTER_PersuasionDialogSharingEnabled",
					"LLBARTER_AttitudeSharingEnabled",
					"LLBARTER_PreventTraderBooksEnabled",
					"LLBARTER_PetPalTagModeDisabled",
					"LLBARTER_SneakingTweaksEnabled",
					"LLBARTER_SneakingTweaksDisabled",
				}
			}}
		end
	end)
end