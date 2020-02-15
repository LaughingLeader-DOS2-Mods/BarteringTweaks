
local function SessionLoading()
	Ext.Print("[LLBARTER:Bootstrap.lua] Session is loading.")
end

local ModuleLoading = function ()
	Ext.Print("[LLBARTER:Bootstrap.lua] Module is loading.")
    --Kalavinkas_Combat_Enhanced_e844229e-b744-4294-9102-a7362a926f71
    if Ext.IsModLoaded("e844229e-b744-4294-9102-a7362a926f71") then
		Ext.Print("[LLBARTER:Bootstrap.lua] Divinity Unleashed detected. Changing the Pet Pal book's description.")
		--Original:
		--6d71b1e0-4150-47fe-bc77-83d9b3efcb77
		Ext.StatSetAttribute("BOOK_LLBARTER_PetPalTalentBook", "RootTemplate", "f31d4498-59a5-4f04-ba96-89a750111ed7")
	end
end

Ext.RegisterListener("ModuleLoading", ModuleLoading)

Ext.Print("[LLBARTER:Bootstrap.lua] Finished running.")