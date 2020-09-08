local LeaderLib = Mods.LeaderLib
local Classes = LeaderLib.Classes

---@type ModSettings
local ModSettings = Classes.ModSettingsClasses.ModSettings
local settings = ModSettings:Create("27db95b3-6850-48c5-baec-3a1f2df9a825")
settings.Global:AddFlags({
	"LLBARTER_BarterSharingDisabled",
	"LLBARTER_PersuasionDialogSharingEnabled",
	"LLBARTER_AttitudeSharingEnabled",
	"LLBARTER_PetPalTagModeDisabled",
	"LLBARTER_SneakingTweaksEnabled",
	"LLBARTER_PreventTraderBooksEnabled",
})
settings.Global:AddFlag("LLBARTER_SneakingTweaksDisabled", "User", false)
return settings