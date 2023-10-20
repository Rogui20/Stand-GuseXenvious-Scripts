util.require_natives(1676318796)

Wait = util.yield
joaat = util.joaat
Print = util.toast

local NULL <const> = 0

local CayoCopsGlobalAddr = 2657704+1+442 --463

function SplitGlobals(GlobalString)
	local String = GlobalString
	local Value = String:gsub("%[(.-)]", "+1")
	local NewValue = Value:gsub("%a", "")
	local NewValue2 = NewValue:gsub("._", "+")
	local NewValue3 = NewValue2:gsub("_", "")
	local _Text, SymbolCount = NewValue3:gsub("+", "")
	local PatternCount = "(%d+)"
	for i = 1, SymbolCount do
		PatternCount = PatternCount .. "+(%d+)"
	end
	local Global, Global2, Global3, Global4, Global5, Global6, Global7 = NewValue3:match(PatternCount)
	local GlobalNumber = 0
	if Global ~= nil then
		GlobalNumber = GlobalNumber + tonumber(Global)
	end
	if Global2 ~= nil then
		GlobalNumber = GlobalNumber + tonumber(Global2)
	end
	if Global3 ~= nil then
		GlobalNumber = GlobalNumber + tonumber(Global3)
	end
	if Global4 ~= nil then
		GlobalNumber = GlobalNumber + tonumber(Global4)
	end
	if Global5 ~= nil then
		GlobalNumber = GlobalNumber + tonumber(Global5)
	end
	if Global6 ~= nil then
		GlobalNumber = GlobalNumber + tonumber(Global6)
	end
	if Global7 ~= nil then
		GlobalNumber = GlobalNumber + tonumber(Global7)
	end
	return GlobalNumber
end

local Addr = 0
local Addr2 = 0
local Addr3 = 0
local police3_FirstAddr = 0
local police3_Addrs = {}
local polmav_Addrs = {}
local fbi2_Addrs = {}
local sheriff_Addrs = {}
local sheriff2_Addrs = {}
local predator_Addrs = {}
local copped_Addrs = {}
local sheriffped_Addrs = {}
local swatped_Addrs = {}
local CanSetModels = false
local RelPlayersBitsAddr = SplitGlobals("Global_2657704[PLAYER::PLAYER_ID() /*463*/].f_253")
local RelAddrs = {}
if NETWORK.GET_ONLINE_VERSION() == "1.67" then
	--Addr = 0x7FF66E4E63F0
	for i = 0, 29 do
		RelAddrs[i+1] = memory.script_global(RelPlayersBitsAddr + 463 * i)
	end
	Addr = memory.scan("C0 C0 00 00 0C C2 00 00 0C 42 00 00 F0 41 00 00 B4 41 00 00 0C 42")
	--Print(string.format("%X", Addr))
	--util.copy_to_clipboard(string.format("%X", Addr))
	if Addr ~= 0 then
		Addr = Addr+38
		Addr2 = memory.read_long(Addr)
		Addr3 = memory.read_long(Addr2+0x08)
		police3_FirstAddr = memory.read_long(Addr3+0xB0)
		local AddressToScan = police3_FirstAddr - 8 * 1000
		local MaxFoundAddrs = 7
		for i = 0, 2000 do
			local Value = memory.read_int(AddressToScan + 8 * i)
			if #police3_Addrs < MaxFoundAddrs then
				if Value == joaat("police3") then
					police3_Addrs[#police3_Addrs+1] = AddressToScan + 8 * i
					CanSetModels = true
				end
			end
			if #polmav_Addrs < MaxFoundAddrs then
				if Value == joaat("polmav") then
					polmav_Addrs[#polmav_Addrs+1] = AddressToScan + 8 * i
				end
			end
			if #fbi2_Addrs < MaxFoundAddrs then
				if Value == joaat("fbi2") then
					fbi2_Addrs[#fbi2_Addrs+1] = AddressToScan + 8 * i
				end
			end
			if #sheriff_Addrs < MaxFoundAddrs then
				if Value == joaat("sheriff") then
					sheriff_Addrs[#sheriff_Addrs+1] = AddressToScan + 8 * i
				end
			end
			if #sheriff2_Addrs < MaxFoundAddrs then
				if Value == joaat("sheriff2") then
					sheriff2_Addrs[#sheriff2_Addrs+1] = AddressToScan + 8 * i
				end
			end
			if #predator_Addrs < MaxFoundAddrs then
				if Value == joaat("predator") then
					predator_Addrs[#predator_Addrs+1] = AddressToScan + 8 * i
				end
			end
			if #copped_Addrs < MaxFoundAddrs then
				if Value == joaat("s_m_y_cop_01") then
					copped_Addrs[#copped_Addrs+1] = AddressToScan + 8 * i
					--Print("Found Cop")
				end
			end
			if #sheriffped_Addrs < MaxFoundAddrs then
				if Value == joaat("s_m_y_sheriff_01") then
					sheriffped_Addrs[#sheriffped_Addrs+1] = AddressToScan + 8 * i
					--Print("Found Sheriff")
				end
			end
			if #swatped_Addrs < MaxFoundAddrs then
				if Value == joaat("s_m_y_swat_01") then
					swatped_Addrs[#swatped_Addrs+1] = AddressToScan + 8 * i
					--Print("Found SWAT")
				end
			end
		end
	end
	--Print("Found Police3 Addrs "..#police3_Addrs)
	--Print("Found Polmav Addrs "..#polmav_Addrs)
	--Print("Found FBI2 Addrs "..#fbi2_Addrs)
	--Print("Found Sheriff Addrs "..#sheriff_Addrs)
	--Print("Found Sheriff2 Addrs "..#sheriff2_Addrs)
	--Print("Found Cop Addrs "..#copped_Addrs)
	--Print("Found Sheriff Addrs "..#sheriffped_Addrs)
	--Print("Found SWAT Addrs "..#swatped_Addrs)
end

local AiHateRel = "rgFM_AiHate"
local AiLikeRel = "rgFM_AiLike"
local AiLikeHateAiHateRel = "rgFM_AiLike_HateAiHate"
local AiHateAiHateRel = "rgFM_HateAiHate"
local AiHateEveryone = "rgFM_HateEveryOne"

local WeaponsForCops = {
	"weapon_appistol",
	"weapon_pistol50",
	"weapon_navyrevolver",
	"weapon_stungun_mp",
	"weapon_flaregun",
	"weapon_heavypistol",
	"weapon_raypistol",
	"weapon_gadgetpistol",
	"weapon_microsmg",
	"weapon_assaultsmg",
	"weapon_smg",
	"weapon_smg_mk2",
	"weapon_combatpdw",
	"weapon_machinepistol",
	"weapon_minismg",
	"weapon_raycarbine",
	"weapon_tecpistol",
	"weapon_pumpshotgun",
	"weapon_sawnoffshotgun",
	"weapon_assaultshotgun",
	"weapon_musket",
	"weapon_heavyshotgun",
	"weapon_dbshotgun",
	"weapon_autoshotgun",
	"weapon_combatshotgun",
	"weapon_assaultrifle",
	"weapon_assaultrifle_mk2",
	"weapon_carbinerifle",
	"weapon_carbinerifle_mk2",
	"weapon_specialcarbine",
	"weapon_specialcarbine_mk2",
	"weapon_bullpuprifle",
	"weapon_bullpuprifle_mk2",
	"weapon_compactrifle",
	"weapon_militaryrifle",
	"weapon_heavyrifle",
	"weapon_tacticalrifle",
	"weapon_mg",
	"weapon_combatmg",
	"weapon_combatmg_mk2",
	"weapon_gusenberg",
	"weapon_sniperrifle",
	"weapon_heavysniper",
	"weapon_heavysniper_mk2",
	"weapon_marksmanrifle",
	"weapon_marksmanrifle_mk2",
	"weapon_precisionrifle",
	"weapon_rpg",
	"weapon_grenadelauncher",
	"weapon_minigun",
	"weapon_firework",
	"weapon_railgun",
	"weapon_hominglauncher",
	"weapon_compactlauncher",
	"weapon_rayminigun",
	"weapon_emplauncher"
}

local GiveWeaponOptions = {
	"Force Cop Weapon",
	"Auto Give Cop Weapon",
	"Random Cop Weapon",
	"Random Cop Weapon By Chance",
	"High Chance With Explosive Guns"
}



local VehicleModels = {
	"polmav",
	"savage",
	"annihilator",
	"valkyrie",
	"hunter",
	"buzzard",
	"khanjali",
	"rhino",
	"dune3",
	"caracara",
	"speedo4",
	"squaddie",
	"winky",
	"elegy",
	"elegy2",
	"caracara2",
	"tampa3",
	"nightshark",
	"technical3",
	"technical",
	"sultan2",
	"infernus2",
	"rcbandito",
	"insurgent3",
	"riata",
	"mesa3",
	"bruiser",
	"bruiser2",
	"bruiser3",
	"barrage",
	"apc",
	"cargobob",
	"cargobob2",
	"akula",
	"seasparrow",
	"patrolboat",
	"longfin",
	"dinghy5",
	"marquis",
	"tug"
}
local PedModels = {
	"mp_m_bogdangoon",
	"u_m_y_juggernaut_01",
	"mp_m_avongoon",
	"g_m_m_cartelguards_01",
	"g_m_m_cartelguards_02",
	"s_f_y_cop_01",
	"s_m_m_movspace_01",
	"ig_englishdave_02",
	"ig_gustavo",
	"ig_helmsmanpavel",
	"u_m_y_rsranger_01",
	"s_m_y_blackops_01",
	"s_m_y_blackops_02",
	"s_m_y_blackops_03",
	"a_m_y_motox_01",
	"a_m_y_motox_02",
	"s_m_y_valet_01",
	"u_m_y_pogo_01",
	"ig_avon",
	"s_m_m_highsec_03",
	"s_m_y_westsec_02",
	"s_m_m_snowcop_01",
	"csb_bogdan",
	"csb_avon",
	"hc_gunman"
}

local SelectedVehicleModels = {"nightshark"}
local SelectedPedModels = {"mp_m_bogdangoon"}

local CopSettingsMenu = menu.list(menu.my_root(), "Cop Settings", {}, "Which settings apply to cops.")
local CopModelSettings = nil
local RandomModels = false
local HasAppliedRandomModels = false
if CanSetModels then
	CopModelSettings = menu.list(CopSettingsMenu, "Cop Model Settings", {}, "Change cop ped and vehicles models.")
	menu.list_select(CopModelSettings, "Police Helicopter", {"polmavmodel"}, "", VehicleModels, 1, function(OnChange)
		for i = 1, #polmav_Addrs do
			memory.write_int(polmav_Addrs[i], joaat(VehicleModels[OnChange]))
		end
		SelectedVehicleModels[1] = VehicleModels[OnChange]
	end)
	menu.list_select(CopModelSettings, "Police3", {"police3model"}, "", VehicleModels, 1, function(OnChange)
		for i = 1, #police3_Addrs do
			memory.write_int(police3_Addrs[i], joaat(VehicleModels[OnChange]))
		end
		SelectedVehicleModels[2] = VehicleModels[OnChange]
	end)
	menu.list_select(CopModelSettings, "FBI2", {"fbi2model"}, "", VehicleModels, 1, function(OnChange)
		for i = 1, #fbi2_Addrs do
			memory.write_int(fbi2_Addrs[i], joaat(VehicleModels[OnChange]))
		end
		SelectedVehicleModels[3] = VehicleModels[OnChange]
	end)
	menu.list_select(CopModelSettings, "Sheriff", {"sheriffmodel"}, "", VehicleModels, 1, function(OnChange)
		for i = 1, #sheriff_Addrs do
			memory.write_int(sheriff_Addrs[i], joaat(VehicleModels[OnChange]))
		end
		SelectedVehicleModels[4] = VehicleModels[OnChange]
	end)
	menu.list_select(CopModelSettings, "Sheriff2", {"sheriff2model"}, "", VehicleModels, 1, function(OnChange)
		for i = 1, #sheriff2_Addrs do
			memory.write_int(sheriff2_Addrs[i], joaat(VehicleModels[OnChange]))
		end
		SelectedVehicleModels[5] = VehicleModels[OnChange]
	end)
	menu.list_select(CopModelSettings, "Predator", {"predatorboatmodel"}, "", VehicleModels, 1, function(OnChange)
		for i = 1, #predator_Addrs do
			memory.write_int(predator_Addrs[i], joaat(VehicleModels[OnChange]))
		end
		SelectedVehicleModels[6] = VehicleModels[OnChange]
	end)
	menu.list_select(CopModelSettings, "Cop Ped", {"coppedmodel"}, "", PedModels, 1, function(OnChange)
		for i = 1, #copped_Addrs do
			memory.write_int(copped_Addrs[i], joaat(PedModels[OnChange]))
		end
		SelectedPedModels[1] = PedModels[OnChange]
	end)
	menu.list_select(CopModelSettings, "Sheriff Ped", {"sheriffpedmodel"}, "", PedModels, 1, function(OnChange)
		for i = 1, #sheriffped_Addrs do
			memory.write_int(sheriffped_Addrs[i], joaat(PedModels[OnChange]))
		end
		SelectedPedModels[2] = PedModels[OnChange]
	end)
	menu.list_select(CopModelSettings, "SWAT Ped", {"swatpedmodel"}, "", PedModels, 1, function(OnChange)
		for i = 1, #swatped_Addrs do
			memory.write_int(swatped_Addrs[i], joaat(PedModels[OnChange]))
		end
		SelectedPedModels[3] = PedModels[OnChange]
	end)
	menu.action(CopModelSettings, "Bypass Law Vehicles", {}, "To spawn cops and SWATS inside different police vehicles", function(toggle)
		local AddrDispatch = memory.scan("8b ? ? ? ? ? 41 8b f1 45 8a d0 c1 e8 1f 40 8a ea 41 84 c4 75")
		if AddrDispatch ~= 0 then
			local AddrTarget = AddrDispatch + 21
			memory.write_byte(AddrTarget, 0xEB)
		end
		local AddrSWATDispatch = memory.scan("74 ? 3b 05 ? ? ? ? 74 ? 3b 05 ? ? ? ? 75 ? ? b0 01")
		if AddrSWATDispatch ~= 0 then
			local AddrTarget = AddrSWATDispatch + 16
			memory.write_byte(AddrTarget, 0x90)
			memory.write_byte(AddrTarget + 1, 0x90)
		end
	end)
	menu.toggle(CopModelSettings, "Set Random Cop Models", {}, "", function(toggle)
		RandomModels = toggle
		if not RandomModels then
			HasAppliedRandomModels = false
		end
		if RandomModels then
			SetRandomModels()
			HasAppliedRandomModels = true
		end
	end, RandomModels)
end
local AllyCopSettingsMenu = menu.list(CopSettingsMenu, "Ally Cop Settings", {}, "Which settings apply to ally cops.")
local HostileCopSettingsMenu = menu.list(CopSettingsMenu, "Hostile Cop Settings", {}, "Which settings apply to hostile cops.")
local CopWeaponsMenu = menu.list(CopSettingsMenu, "Cop Weapon Loadout", {}, "Weapons settings for cops.")

local CopsAttackEveryone = false
menu.toggle(HostileCopSettingsMenu, "Cops Attack Everyone", {}, "If cops see a player, will start attacking.", function(toggle)
	CopsAttackEveryone = toggle
end, CopsAttackEveryone)

local MakeCopsAttackEveryone = false
menu.toggle(HostileCopSettingsMenu, "Make Cops Attack Everyone", {}, "Cops will attack the nearest player, no need to see the player to start the attack.", function(toggle)
	MakeCopsAttackEveryone = toggle
end, MakeCopsAttackEveryone)

local ZombieMode = false
menu.toggle(HostileCopSettingsMenu, "Zombie Mode", {}, "", function(toggle)
	ZombieMode = toggle
end, ZombieMode)

local SelectedForcedPedWeaponHash = 0
local CopsForcedWeaponList = menu.list_select(CopWeaponsMenu, "Forced Cop Weapon", {"forcedcopweapon"}, "Cops will be forced to use the selected weapon.", WeaponsForCops, 1, function(on_change)
	SelectedForcedPedWeaponHash = joaat(WeaponsForCops[on_change])
end)

local SelectedAutoGivePedWeaponHash = 0
local CopsAutoGiveWeaponList = menu.list_select(CopWeaponsMenu, "Auto Give Cop Weapon", {"autogivecopweapon"}, "Auto give this weapon to cops.", WeaponsForCops, 26, function(on_change)
	SelectedAutoGivePedWeaponHash = joaat(WeaponsForCops[on_change])
end)

local SelectedGiveWeaponType = 4
menu.list_select(CopWeaponsMenu, "Give Weapon Settings", {"giveweaponsettings"}, "Set how cops will get weapons.", GiveWeaponOptions, SelectedGiveWeaponType, function(on_change)
	SelectedGiveWeaponType = on_change
end)

local RandomWeaponComponents = true
menu.toggle(CopWeaponsMenu, "Random Weapon Components", {}, "", function(toggle)
	RandomWeaponComponents = toggle
end, RandomWeaponComponents)

local FlashlightForAllCopWeapons = false
menu.toggle(CopWeaponsMenu, "Flashlight For All Cop Weapons", {}, "", function(toggle)
	FlashlightForAllCopWeapons = toggle
end, FlashlightForAllCopWeapons)

local EnableWeaponSettsForCops = true
menu.toggle(CopWeaponsMenu, "Enable Weapon Settings", {}, "", function(toggle)
	EnableWeaponSettsForCops = toggle
end, EnableWeaponSettsForCops)

local AllowExplosives = false
menu.toggle(CopWeaponsMenu, "Enable Weapon Explosive Guns", {}, "", function(toggle)
	AllowExplosives = toggle
end, AllowExplosives)

local AutomaticGenCops = true
menu.toggle(CopSettingsMenu, "Automatically Generate Cops", {}, "If this is enabled, wanted level will be set to 5 stars and will set 0 stars when 50 cops is generated.", function(toggle)
	AutomaticGenCops = toggle
end, AutomaticGenCops)

local MaxCopsToEdit = 50
menu.slider(CopSettingsMenu, "Max Cops To Edit", {"maxcopstoedit"}, "Set the max amount of cops to turn into mission entity and edit.", 1, 80, MaxCopsToEdit, 1, function(on_change)
	MaxCopsToEdit = on_change
end)

local MakeCopsAsMissionEntities = true
menu.toggle(CopSettingsMenu, "Make Cops As Mission Entities", {}, "This will make the game generate more cops.", function(toggle)
	MakeCopsAsMissionEntities = toggle
end, MakeCopsAsMissionEntities)

local CopsForMission = true
menu.toggle(CopSettingsMenu, "Edit Normal Cops", {}, "Edit cops with default models.", function(toggle)
	CopsForMission = toggle
end, CopsForMission)

local CopsModelForMission = true
menu.toggle(CopSettingsMenu, "Edit Cops With Different Model", {}, "Edit some other cops with another model.", function(toggle)
	CopsModelForMission = toggle
end, CopsModelForMission)

local AddBlipsForCopsDifferentModel = true
menu.toggle(CopSettingsMenu, "Add Blip For Different Cop Ped Models", {}, "Add red blips for hostile peds or blue blips for ally peds.", function(toggle)
	AddBlipsForCopsDifferentModel = toggle
end, AddBlipsForCopsDifferentModel)

local UpgradeCopCars = true
menu.toggle(CopSettingsMenu, "Upgrade Cop Cars", {}, "Cop cars will have a random upgrade.", function(toggle)
	UpgradeCopCars = toggle
end, UpgradeCopCars)

local SetCopPassengersIntoTurretSeat = true
menu.toggle(CopSettingsMenu, "Put Cops Into Turret Seats", {}, "", function(toggle)
	SetCopPassengersIntoTurretSeat = toggle
end, SetCopPassengersIntoTurretSeat)

local OnlyEditOwnedCops = false
menu.toggle(CopSettingsMenu, "Only Edit Owned Cops", {}, "", function(toggle)
	OnlyEditOwnedCops = toggle
end, OnlyEditOwnedCops)

local RandomCopComponents = false
menu.toggle(CopSettingsMenu, "Set Cops Random Components", {}, "Outfit.", function(toggle)
	RandomCopComponents = toggle
end, RandomCopComponents)

local RandomCopModelComponents = true
menu.toggle(CopSettingsMenu, "Set Different Cops Random Components", {}, "Outfit.", function(toggle)
	RandomCopModelComponents = toggle
end, RandomCopModelComponents)

local SetNetworkID = true
menu.toggle(CopSettingsMenu, "Set a Network ID", {}, "To maintain control...", function(toggle)
	SetNetworkID = toggle
end, SetNetworkID)

local CopsFollowInVehTask = true
menu.toggle(AllyCopSettingsMenu, "All Cops In Veh Follow You", {}, "", function(toggle)
	CopsFollowInVehTask = toggle
end, CopsFollowInVehTask)

local CopsFollowTask = true
menu.toggle(AllyCopSettingsMenu, "All Cops Follow You", {}, "", function(toggle)
	CopsFollowTask = toggle
end, CopsFollowTask)

local CopsFollowAsBodyguard = true
menu.toggle(AllyCopSettingsMenu, "Cops Follow As Bodyguard", {}, "", function(toggle)
	CopsFollowAsBodyguard = toggle
end, CopsFollowAsBodyguard)

local BringFarCopsCloser = true
menu.toggle(AllyCopSettingsMenu, "Auto Bring Far Cops Back To You", {}, "", function(toggle)
	BringFarCopsCloser = toggle
end, BringFarCopsCloser)

local BringIfOutsideOfVehicle = false
menu.toggle(AllyCopSettingsMenu, "Bring If Im Outside Vehicle", {}, "", function(toggle)
	BringIfOutsideOfVehicle = toggle
end, BringIfOutsideOfVehicle)

local CopsCanAttackPlayers = false
menu.toggle(AllyCopSettingsMenu, "Cops Can Attack Players", {}, "", function(toggle)
	CopsCanAttackPlayers = toggle
end, CopsCanAttackPlayers)

local AvoidAttackingFriends = true
menu.toggle(AllyCopSettingsMenu, "Avoid Attacking Friends", {}, "Automatically will avoid attacking people of your CEO or Biker Club.", function(toggle)
	AvoidAttackingFriends = toggle
end, AvoidAttackingFriends)

local AvoidAttackSpeficPlayers = false
menu.toggle(AllyCopSettingsMenu, "Avoid Attacking Specific Players", {}, "Works with avoiding attack friends toggled.", function(toggle)
	AvoidAttackSpeficPlayers = toggle
end, AvoidAttackSpeficPlayers)

local PlayersToAvoidAttackT = {}
local PlayersToAvoidAttackMenu = menu.list(AllyCopSettingsMenu, "Which Players Avoid Attack", {}, "Select players to avoid the attack.", function()UpdatePlayersList()end, function()UpdatePlayersList()end)

local AvoidPlayerBits = 0
for i = 1, 30 do
    if PlayersToAvoidAttackT[i] == nil then
		local PlayerID = PLAYER.PLAYER_ID()
        local PlayerName = "---"
        if NETWORK.NETWORK_IS_PLAYER_ACTIVE(i-1) then
            PlayerName = PLAYER.GET_PLAYER_NAME(i-1)
        end
        PlayersToAvoidAttackT[i] = {}
        PlayersToAvoidAttackT[i].Include = PlayerID+1 == i
        PlayersToAvoidAttackT[i].MenuPTR = menu.toggle(PlayersToAvoidAttackMenu, PlayerName, {}, "", function(OnChange)
			PlayersToAvoidAttackT[i].Include = OnChange
			if PlayersToAvoidAttackT[i].Include == true then
				SetBitsToAvoidAttackPlayers(i)
			else
				SetBitsToAvoidAttackPlayers(i)
			end
		end, PlayersToAvoidAttackT[i].Include)
    end
end

function UpdatePlayersList()
    for i = 1, 30 do
        if PlayersToAvoidAttackT[i] ~= nil then
            local PlayerName = "---"
            if NETWORK.NETWORK_IS_PLAYER_ACTIVE(i-1) then
                PlayerName = PLAYER.GET_PLAYER_NAME(i-1)
            end
            menu.set_menu_name(PlayersToAvoidAttackT[i].MenuPTR, PlayerName)
        end
    end
end

function SetBitsToAvoidAttackPlayers(Bit)
	if not is_bit_set(AvoidPlayerBits, Bit) then
		AvoidPlayerBits = set_bit(AvoidPlayerBits, Bit)
	else
		AvoidPlayerBits = clear_bit(AvoidPlayerBits, Bit)
	end
end

players.on_leave(function(CallBack)
	if is_bit_set(AvoidPlayerBits, CallBack + 1) then
		AvoidPlayerBits = clear_bit(AvoidPlayerBits, CallBack + 1)
		menu.set_value(PlayersToAvoidAttackT[CallBack + 1].MenuPTR, false)
	end
end)

local AddBlipsForAllyCops = true
menu.toggle(AllyCopSettingsMenu, "Add Blip For Ally Cops", {}, "", function(toggle)
	AddBlipsForAllyCops = toggle
end, AddBlipsForAllyCops)

local RemoveCopsFromVeh = false
menu.toggle(AllyCopSettingsMenu, "Remove Cops From Vehicle", {}, "", function(toggle)
	RemoveCopsFromVeh = toggle
end, RemoveCopsFromVeh)

local PutCopsIntoPlayerVeh = false
menu.toggle(AllyCopSettingsMenu, "Put Cops Into Your Vehicle", {}, "", function(toggle)
	PutCopsIntoPlayerVeh = toggle
end, PutCopsIntoPlayerVeh)

local AllyAttacksHostiles = false
menu.toggle(AllyCopSettingsMenu, "Auto Attack Hostile Peds", {}, "", function(toggle)
	AllyAttacksHostiles = toggle
end, AllyAttacksHostiles)
local DistanceNeededToAttack = 100.0
menu.slider_float(AllyCopSettingsMenu, "Needed Range To Attack", {"autoattackrange"}, "Distance needed between peds to start the attack.", 10000, 1000000, 10000, 1000, function(OnChange)
	DistanceNeededToAttack = OnChange / 100
end)

local SetAllyPedHateToAiHate = true
menu.toggle(AllyCopSettingsMenu, "Set Ally Ped Hate To Ai Enemy", {}, "Made for missions, if ally sees a enemy ped, will attack.", function(toggle)
	SetAllyPedHateToAiHate = toggle
end, SetAllyPedHateToAiHate)

local CustomTasksMenu = menu.list(AllyCopSettingsMenu, "Custom Tasks", {}, "")
local CopsShootWhereYouShoot = false
menu.toggle(CustomTasksMenu, "Cops Shoot Where You Shoot", {}, "", function(toggle)
	CopsShootWhereYouShoot = toggle
end, CopsShootWhereYouShoot)
local CopsShootWhereYouAim = false
menu.toggle(CustomTasksMenu, "Cops Shoot Where You Aim", {}, "", function(toggle)
	CopsShootWhereYouAim = toggle
end, CopsShootWhereYouAim)
--menu.list_select(AllyCopSettingsMenu, "Cop Relationship Type", {"allycoprelationship"}, "Set if cops will be able to attack players or only npcs.", table<int, table> options, 1, function on_change)

local RenderCopCount = false
menu.toggle(menu.my_root(), "Show Cop Count HUD", {}, "", function(toggle)
	RenderCopCount = toggle
end, RenderCopCount)

local CopsAreAllies = true
menu.toggle(menu.my_root(), "Make Cops As Allies", {}, "", function(toggle)
	CopsAreAllies = toggle
end, CopsAreAllies)

local CopCustomRelMenu = menu.list(CopSettingsMenu, "Custom Relationship Settings", {}, "For DEVs.")

local KnownCustomRelationships = {
	"relRescueContactPlayer",
	"relHeadHunterPlayer"
}

local CustomRelText = "relRescueContactPlayer"

menu.list_select(CopCustomRelMenu, "Known Custom Rels", {"setknowncustomrel"}, "Known custom relationships list.", KnownCustomRelationships, 1, function(on_change)
	CustomRelText = joaat(KnownCustomRelationships[on_change])
end)

local CopsCustomRelationship = false
menu.toggle(CopCustomRelMenu, "Set Cops Custom Relationship", {}, "", function(toggle)
	CopsCustomRelationship = toggle
end, CopsCustomRelationship)

menu.text_input(CopCustomRelMenu, "Custom Relationship Name", {"copcustomrelationship"}, "Write a missing custom relationship name to set.", function(on_change)
	CustomRelText = on_change
end)
--func_18155(&(Global_1837231[5]), Global_2657704[PLAYER::PLAYER_ID() /*463*/].f_253);

local RelHashBackupAddr = SplitGlobals("Global_1837231.f_6")
local ApplyCopSettings = false
menu.toggle(menu.my_root(), "Apply Cop Settings", {}, "", function(toggle)
	ApplyCopSettings = toggle
	local CopAIMissionRelHash = -1235282855
	local EnemyAIMissionRelHash = 671184796
	local FriendlyAll = -607974925
	if not ApplyCopSettings then
		for index, peds in pairs(entities.get_all_peds_as_handles()) do
			if peds ~= PLAYER.PLAYER_PED_ID() then
				if ENTITY.IS_ENTITY_A_MISSION_ENTITY(peds) then
					local CanEditCop = false
					if OnlyEditOwnedCops then
						local PlayerID = PLAYER.PLAYER_ID()
						if get_entity_owner(peds) == PlayerID then
							CanEditCop = true
						end
					else
						CanEditCop = true
					end
					if CanEditCop then
						local DecorInt = DECORATOR.DECOR_GET_INT(peds, "Casino_Game_Info_Decorator")
						if DecorInt == 31 or DecorInt == 32 then
							util.create_thread(function ()
								local Tick = 0
								while not NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) and Tick < 1000 do
									Tick = Tick + 1
									Wait()
								end
								local NetID = NETWORK.PED_TO_NET(peds)
								if NetID ~= 0 then
									NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(NetID, PLAYER.PLAYER_ID(), false)
								end
								entities.delete_by_handle(peds)
							end)
						end
					end
				end
			end
		end
		if AutomaticGenCops then
			local PlayerID = PLAYER.PLAYER_ID()
			PLAYER.SET_PLAYER_WANTED_LEVEL(PlayerID, 0, false)
			PLAYER.SET_PLAYER_WANTED_LEVEL_NOW(PlayerID, false)
		end
		for i = 0, 30 do
			local RelTarget = joaat("rgFM_Team"..i)
			PED.SET_RELATIONSHIP_BETWEEN_GROUPS(3, joaat("rgFM_AiAmbientGangMerc[".. 0 .. "]"), RelTarget)
			PED.SET_RELATIONSHIP_BETWEEN_GROUPS(3, RelTarget, joaat("rgFM_AiAmbientGangMerc[".. 0 .. "]"))
		end
		if SetAllyPedHateToAiHate then
			if PED.DOES_RELATIONSHIP_GROUP_EXIST(FriendlyAll) then
				PED.SET_RELATIONSHIP_BETWEEN_GROUPS(3, FriendlyAll, CopAIMissionRelHash)
				--PED.SET_RELATIONSHIP_BETWEEN_GROUPS(3, CopAIMissionRelHash, FriendlyAll)
				PED.SET_RELATIONSHIP_BETWEEN_GROUPS(3, FriendlyAll, EnemyAIMissionRelHash)
				--PED.SET_RELATIONSHIP_BETWEEN_GROUPS(3, EnemyAIMissionRelHash, FriendlyAll)
			end
		end
	end
	local AiTeam1Hash = joaat("rgFM_AiPed20000")
	local SelectedTeam = -607974925
	--local FriendlyAll = AiTeam1Hash
	local DeadPeds = {}
	local BlipColorToGive = 1
	if ApplyCopSettings then
		PlayerID = PLAYER.PLAYER_ID()
		local RelHashBackup = memory.read_int(memory.script_global(RelHashBackupAddr))
		--Print(RelHashBackup)
		--if AutomaticGenCops then
		--	PLAYER.SET_DISPATCH_COPS_FOR_PLAYER(PlayerID, true)
		--	PLAYER.SET_MAX_WANTED_LEVEL(5)
		--	PLAYER.SET_PLAYER_WANTED_LEVEL(PlayerID, 5, false)
		--	PLAYER.SET_PLAYER_WANTED_LEVEL_NOW(PlayerID, false)
		--end
		local HasSetHate = false
		local FreemodeBackupHeliAddr = memory.script_local("freemode", 6916)
		local TriesTick = 0
		local TasksT = {}
		local ShootsT = {}
		while ApplyCopSettings do
			if ApplyCopSettings then
				if SetAllyPedHateToAiHate then
					if not HasSetHate then
						if PED.DOES_RELATIONSHIP_GROUP_EXIST(FriendlyAll) then
							PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, FriendlyAll, CopAIMissionRelHash)
							--PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, CopAIMissionRelHash, FriendlyAll)
							PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, FriendlyAll, EnemyAIMissionRelHash)
							--PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, EnemyAIMissionRelHash, FriendlyAll)
							HasSetHate = true
						end
					end
				end
				local PlayerPed = PLAYER.PLAYER_PED_ID()
				PlayerID = PLAYER.PLAYER_ID()
				local PlayerGroup = PLAYER.GET_PLAYER_GROUP(PlayerID)
				local PlTeamRel = 536121530
				local MissionCopCount = 0
				local PlRel = PED.GET_PED_RELATIONSHIP_GROUP_HASH(PlayerPed)
				local PlayerVeh = PED.GET_VEHICLE_PED_IS_IN(PlayerPed, false)
				local CustomRelExists = false
				local IsPlayerShooting = false
				local HitCoords = nil
				local HasHit = false
				if CopsShootWhereYouShoot then
					IsPlayerShooting = PED.IS_PED_SHOOTING(PlayerPed)
					if IsPlayerShooting then
						HitCoords = v3.new()
						HasHit = WEAPON.GET_PED_LAST_WEAPON_IMPACT_COORD(PlayerPed, HitCoords)
						if not HasHit then
							local CamRot = CAM.GET_GAMEPLAY_CAM_ROT(2)
							local FVect = CamRot:toDir()
							local PPos = ENTITY.GET_ENTITY_COORDS(PlayerPed)
							local AdjustedX = PPos.x + FVect.x * 1000
							local AdjustedY = PPos.y + FVect.y * 1000
							local AdjustedZ = PPos.z + FVect.z * 1000
							local DidHit = memory.alloc(1)
							local EndCoords = v3.new()
							local Normal = v3.new()
							local HitEntity = memory.alloc_int()
						
							local Handle = SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(
								PPos.x, PPos.y, PPos.z,
								AdjustedX, AdjustedY, AdjustedZ,
								-1,
								PlayerPed, 7
							)
							SHAPETEST.GET_SHAPE_TEST_RESULT(Handle, DidHit, EndCoords, Normal, HitEntity)
							if memory.read_byte(DidHit) ~= 0 then
								HitCoords.x = EndCoords.x
								HitCoords.y = EndCoords.y
								HitCoords.z = EndCoords.z
							else
								HitCoords.x = AdjustedX
								HitCoords.y = AdjustedY
								HitCoords.z = AdjustedZ
							end
							HasHit = true
						end
					end
				end
				if CopsShootWhereYouAim then
					if HitCoords == nil then
						local IsAiming = CAM.IS_AIM_CAM_ACTIVE()
						if IsAiming then
							HitCoords = v3.new()
							local CamRot = CAM.GET_GAMEPLAY_CAM_ROT(2)
							local FVect = CamRot:toDir()
							local PPos = CAM.GET_GAMEPLAY_CAM_COORD()
							local AdjustedX = PPos.x + FVect.x * 1000
							local AdjustedY = PPos.y + FVect.y * 1000
							local AdjustedZ = PPos.z + FVect.z * 1000
							local DidHit = memory.alloc(1)
							local EndCoords = v3.new()
							local Normal = v3.new()
							local HitEntity = memory.alloc_int()
						
							local Handle = SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(
								PPos.x, PPos.y, PPos.z,
								AdjustedX, AdjustedY, AdjustedZ,
								-1,
								PlayerPed, 7
							)
							SHAPETEST.GET_SHAPE_TEST_RESULT(Handle, DidHit, EndCoords, Normal, HitEntity)
							if memory.read_byte(DidHit) ~= 0 then
								HitCoords.x = EndCoords.x
								HitCoords.y = EndCoords.y
								HitCoords.z = EndCoords.z
							else
								HitCoords.x = AdjustedX
								HitCoords.y = AdjustedY
								HitCoords.z = AdjustedZ
							end
							HasHit = true
						end
					end
				end
				if RandomModels then
					if PLAYER.GET_PLAYER_WANTED_LEVEL(PlayerID) <= 0 then
						if not HasAppliedRandomModels then
							HasAppliedRandomModels = true
							SetRandomModels()
						end
					else
						HasAppliedRandomModels = false
					end
				end
				if CopsCustomRelationship then
					if PED.DOES_RELATIONSHIP_GROUP_EXIST(joaat(CustomRelText)) then
						CustomRelExists = true
						SelectedTeam = joaat(CustomRelText)
						if CopsAreAllies then
							BlipColorToGive = 3
						else
							BlipColorToGive = 1
						end
					end
				end
				if not CustomRelExists then
					if CopsAreAllies then
						BlipColorToGive = 3
						if not CopsCanAttackPlayers then
							if PED.DOES_RELATIONSHIP_GROUP_EXIST(FriendlyAll) then
								SelectedTeam = FriendlyAll
							else
								if PED.DOES_RELATIONSHIP_GROUP_EXIST(joaat(AiLikeHateAiHateRel)) then
									SelectedTeam = joaat(AiLikeHateAiHateRel)
								else
									SelectedTeam = PlRel
								end
							end
						else
							local CanSetRel = false
							local RelTarget = joaat("rgFM_Team"..PlayerID)
							local RelHash = joaat("rgFM_AiAmbientGangMerc[".. 0 .. "]")
							if not AvoidAttackingFriends then
								PED.SET_RELATIONSHIP_BETWEEN_GROUPS(1, RelHash, RelTarget)
								PED.SET_RELATIONSHIP_BETWEEN_GROUPS(1, RelTarget, RelHash)
							else
								if FreemodeBackupHeliAddr ~= 0 then
									if AvoidAttackSpeficPlayers then
										if not is_bit_set(AvoidPlayerBits, PlayerID+1) then
											AvoidPlayerBits = set_bit(AvoidPlayerBits, PlayerID+1)
										end
										memory.write_int(FreemodeBackupHeliAddr, AvoidPlayerBits)
									end
									if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("am_backup_heli")) == 0 then
										if TriesTick <= 0 then
											menu.trigger_commands("helibackup")
											TriesTick = 50
										else
											if TriesTick > 0 then
												TriesTick = TriesTick - 1
											end
										end
									else
										TriesTick = 0
										CanSetRel = true
									end
								end
							end
							local MyRelTeam = PED.GET_PED_RELATIONSHIP_GROUP_HASH(PlayerPed)
							if CanSetRel then
								MyRelTeam = RelHashBackup
								RelTarget = RelHashBackup
								RelHash = RelHashBackup
							end
							if MyRelTeam ~= RelTarget then
								--SelectedTeam = joaat("rgFM_AiAmbientGangMerc[".. 0 .. "]")
								SelectedTeam = MyRelTeam
							else
								SelectedTeam = RelHash
								if AvoidAttackingFriends then
									if not CanSetRel then
										if PED.GET_RELATIONSHIP_BETWEEN_GROUPS(SelectedTeam, MyRelTeam) ~= 1 then
											SelectedTeam = joaat(AiLikeHateAiHateRel)
											if PED.GET_RELATIONSHIP_BETWEEN_GROUPS(SelectedTeam, MyRelTeam) ~= 1 then
												SelectedTeam = joaat(AiLikeRel)
											end
										end
									end
								end
							end
						end
					else
						BlipColorToGive = 1
						if CopsAttackEveryone or ZombieMode then
							if PED.DOES_RELATIONSHIP_GROUP_EXIST(joaat(AiHateRel)) then
								SelectedTeam = joaat(AiHateRel)
							else
								SelectedTeam = joaat("COP")
							end
						else
							SelectedTeam = joaat("COP")
						end
					end
				end
				if not PED.DOES_RELATIONSHIP_GROUP_EXIST(FriendlyAll) then
					HasSetHate = false
				end
				for index, peds in pairs(entities.get_all_peds_as_handles()) do
					if DECORATOR.DECOR_GET_INT(peds, "Casino_Game_Info_Decorator") == 31 then
						MissionCopCount = MissionCopCount + 1
					end
				end
				if RenderCopCount then
					directx.draw_text(0.7, 0.7, "Cops "..MissionCopCount, ALIGN_CENTRE, 1.0, {r = 0, g = 255 , b = 255, a = 200}, false)
				end
				for index, peds in pairs(entities.get_all_peds_as_handles()) do
					if peds ~= PlayerPed then
						if not PED.IS_PED_A_PLAYER(peds) then
							local EntScript = ENTITY.GET_ENTITY_SCRIPT(peds, 0)
							if EntScript == "GB_HEADHUNTER" or EntScript == "GB_BIKER_RESCUE_CONTACT" then
								ENTITY.SET_ENTITY_ONLY_DAMAGED_BY_PLAYER(peds, false)
								local Veh = PED.GET_VEHICLE_PED_IS_IN(peds, false)
								if Veh ~= 0 then
									ENTITY.SET_ENTITY_ONLY_DAMAGED_BY_PLAYER(Veh, false)
								end
								if RelHashBackup ~= 0 then
									ENTITY.SET_ENTITY_CAN_BE_DAMAGED_BY_RELATIONSHIP_GROUP(peds, true, RelHashBackup)
								end
							end
							local CanEditCop = false
							if OnlyEditOwnedCops then
								if get_entity_owner(peds) == PlayerID then
									CanEditCop = true
								end
							else
								CanEditCop = true
							end
							local IsCopModel = IsCopPedModel(peds)
							local HaveCopRel = IsWithCopRel(peds)
							local CanAddBlip = false
							if not ENTITY.IS_ENTITY_A_MISSION_ENTITY(peds) then
								if CanEditCop then
									if MissionCopCount < MaxCopsToEdit then
										local CanApplyDecor = false
										local DecorApplied = false
										if CopsModelForMission then
											if IsCopModel then
												CanApplyDecor = true
											end
										end
										if CopsForMission then
											if HaveCopRel then
												CanApplyDecor = true
											end
										end
										if CanApplyDecor and MakeCopsAsMissionEntities then
											NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds)
											DECORATOR.DECOR_SET_INT(peds, "Casino_Game_Info_Decorator", 31)
											ENTITY.SET_ENTITY_AS_MISSION_ENTITY(peds, false, true)
											DecorApplied = true
											if SetNetworkID then
												local NetID = NETWORK.PED_TO_NET(peds)
												if NetID ~= 0 then
													NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(NetID, PlayerID, true)
												end
											end
										else
											if CopsForMission then
												if HaveCopRel then
													CanApplyDecor = true
												end
											end
											if CopsModelForMission then
												if IsCopModel then
													CanApplyDecor = true
												end
											end
											if CanApplyDecor then
												if not DECORATOR.DECOR_EXIST_ON(peds, "Casino_Game_Info_Decorator") then
													DecorApplied = true
													NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds)
													DECORATOR.DECOR_SET_INT(peds, "Casino_Game_Info_Decorator", 31)
												end
											end
										end
										if DecorApplied then
											NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds)
											PED.SET_PED_RELATIONSHIP_GROUP_HASH(peds, SelectedTeam)
											PED.SET_PED_FLEE_ATTRIBUTES(peds, 512, true)
											if not ZombieMode then
												if EnableWeaponSettsForCops then
													GiveCorrectWeaponsToPed(peds)
												end
												WEAPON.GIVE_WEAPON_TO_PED(peds, joaat("weapon_pistol"), 99999, false, false)
												if RandomWeaponComponents then
													Set_Weapon_Components(peds)
												end
												if IsCopModel then
													SetPedCombatAbilities(peds)
													PED.SET_PED_FIRING_PATTERN(peds, joaat("FIRING_PATTERN_FULL_AUTO"))
												end
												if CopsShootWhereYouShoot or CopsShootWhereYouAim then
													PED.SET_PED_FIRING_PATTERN(peds, joaat("FIRING_PATTERN_FULL_AUTO"))
													PED.SET_PED_CONFIG_FLAG(peds, 113, false)
												end
											else
												ENTITY.SET_ENTITY_PROOFS(peds, false, false, false, false, true, false, false, false)
												WEAPON.REMOVE_ALL_PED_WEAPONS(peds, false)
												SetPedCombatAbilities(peds)
												PED.SET_PED_SUFFERS_CRITICAL_HITS(peds, false)
												PED.SET_RAGDOLL_BLOCKING_FLAGS(peds, 1)
												SetPedHealth(peds, 400)
												WEAPON.GIVE_WEAPON_TO_PED(peds, joaat("weapon_knife"), 99999, false, false)
											end
											local Veh = PED.GET_VEHICLE_PED_IS_IN(peds, false)
											if Veh ~= 0 then
												if VEHICLE.GET_PED_IN_VEHICLE_SEAT(Veh, -1, false) == peds then
													if IsArmoredVehModel(Veh) then
														PED.SET_PED_COMBAT_ATTRIBUTES(peds, 52, true)
														PED.SET_PED_COMBAT_ATTRIBUTES(peds, 53, true)
													end
												end
											end
											local AppliedOutfit = false
											if RandomCopModelComponents then
												if IsCopModel then
													--PED.SET_PED_DEFAULT_COMPONENT_VARIATION(peds)
													--PED.SET_PED_RANDOM_COMPONENT_VARIATION(peds, 0)
													--PED.SET_PED_RANDOM_PROPS(peds)
													SetPedRandomOutfit(peds)
													AppliedOutfit = true
												end
											end
											if RandomCopComponents then
												if not AppliedOutfit then
													if HaveCopRel then
														--PED.SET_PED_DEFAULT_COMPONENT_VARIATION(peds)
														--PED.SET_PED_RANDOM_COMPONENT_VARIATION(peds, 0)
														--PED.SET_PED_RANDOM_PROPS(peds)
														SetPedRandomOutfit(peds)
													end
												end
											end
											if UpgradeCopCars then
												local Veh = PED.GET_VEHICLE_PED_IS_IN(peds, false)
												if Veh ~= 0 then
													if Veh ~= PlayerVeh then
														if SetCopPassengersIntoTurretSeat then
															local HasSetInTurretSeat = false
															if VEHICLE.GET_PED_IN_VEHICLE_SEAT(Veh, -1, false) ~= peds then
																for i = -1, 9 do
																	if not HasSetInTurretSeat then
																		if VEHICLE.IS_TURRET_SEAT(Veh, i) then
																			if VEHICLE.IS_VEHICLE_SEAT_FREE(Veh, i, true) then
																				HasSetInTurretSeat = true
																				NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds)
																				PED.SET_PED_INTO_VEHICLE(peds, Veh, i)
																			end
																		end
																	end
																end
															end
														end
														if DECORATOR.DECOR_GET_INT(Veh, "Casino_Game_Info_Decorator") ~= 31 then
															NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(Veh)
															for k = 0, 48 do
																local NumMods = entities.get_upgrade_max_value(Veh, k)
																if NumMods > 0 then
																	local Rand = math.random(0, NumMods)
																	if Rand <= -1 then
																		Rand = 0
																	end
																	entities.set_upgrade_value(Veh, k, Rand, false)
																else
																	if math.random(0, 1) == 1 then
																		entities.set_upgrade_value(Veh, k, NumMods, false)
																	end
																end
															end
															VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(Veh, math.random(0, 255), math.random(0, 255), math.random(0, 255))
															VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(Veh, math.random(0, 255), math.random(0, 255), math.random(0, 255))
															VEHICLE.SET_VEHICLE_COLOURS(Veh, math.random(0, 160), math.random(0, 160))
															DECORATOR.DECOR_SET_INT(Veh, "Casino_Game_Info_Decorator", 31)
														end
													end
												end
											end
										end
									end
									if DECORATOR.DECOR_EXIST_ON(peds, "Casino_Game_Info_Decorator") then
										if PED.GET_PED_RELATIONSHIP_GROUP_HASH(peds) ~= SelectedTeam then
											if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
												PED.SET_PED_RELATIONSHIP_GROUP_HASH(peds, SelectedTeam)
											end
										end
										if PutCopsIntoPlayerVeh then
											if PlayerVeh ~= 0 then
												for i = -1, 9 do
													if VEHICLE.IS_VEHICLE_SEAT_FREE(PlayerVeh, i, true) then
														if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
															PED.SET_PED_INTO_VEHICLE(peds, PlayerVeh, i)
														end
													end
												end
											end
										end
										if AddBlipsForAllyCops then
											if not IsCopModel then
												CanAddBlip = true
											end
										end
										if AddBlipsForCopsDifferentModel then
											if IsCopModel then
												CanAddBlip = true
											end
										end
										if CanAddBlip then
											if not HUD.DOES_PED_HAVE_AI_BLIP(peds) then
												HUD.SET_PED_HAS_AI_BLIP_WITH_COLOUR(peds, true, BlipColorToGive)
												HUD.SET_PED_AI_BLIP_HAS_CONE(peds, false)
												HUD.SET_PED_AI_BLIP_FORCED_ON(peds, true)
											end
										end
										if CopsAreAllies then
											local Veh = PED.GET_VEHICLE_PED_IS_IN(peds, false)
											local IsPedInGroup = PED.IS_PED_IN_GROUP(peds)
											if not IsPedInGroup then
												if CopsFollowAsBodyguard then
													local CanSetInGroup = true
													if Veh ~= 0 then
														local VehModel = ENTITY.GET_ENTITY_MODEL(Veh)
														local IsAPlane = VEHICLE.IS_THIS_MODEL_A_PLANE(VehModel)
														local IsAHeli = VEHICLE.IS_THIS_MODEL_A_HELI(VehModel)
														if IsAPlane or IsAHeli then
															CanSetInGroup = false
														end
													end
													if CanSetInGroup then
														if GetPedGroupSize(PlayerGroup) < 7 then
															if ENTITY.IS_ENTITY_AT_ENTITY(peds, PlayerPed, 30.0, 30.0, 30.0, false, true, false) then
																if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
																	PED.SET_PED_AS_GROUP_MEMBER(peds, PlayerGroup)
																	PED.SET_PED_NEVER_LEAVES_GROUP(peds, true)
																	PED.SET_GROUP_SEPARATION_RANGE(PlayerGroup, 9999.0)
																	PED.SET_GROUP_FORMATION_SPACING(PlayerGroup, 1.0, -1.0, -1.0)
																	PED.SET_GROUP_FORMATION(PlayerGroup, 1)
																	TASK.CLEAR_PED_TASKS(peds)
																end
															end
														end
													end
												end
											end
											IsPedInGroup = PED.IS_PED_IN_GROUP(peds)
											if CopsFollowInVehTask then
												if not PED.IS_PED_IN_COMBAT(peds, 0) then
													if Veh ~= 0 then
														if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_VEHICLE_SHOOT_AT_COORD")) == 7 then
															if VEHICLE.GET_PED_IN_VEHICLE_SEAT(Veh, -1, false) == peds then
																local VehModel = ENTITY.GET_ENTITY_MODEL(Veh)
																local IsAPlane = VEHICLE.IS_THIS_MODEL_A_PLANE(VehModel)
																local IsAHeli = VEHICLE.IS_THIS_MODEL_A_HELI(VehModel)
																if not IsAPlane and not IsAHeli then
																	if not IsPedInGroup then
																		if not ENTITY.IS_ENTITY_AT_ENTITY(peds, PlayerPed, 100.0, 100.0, 100.0, false, true, false) then
																			if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_VEHICLE_MISSION")) == 7 then
																			--if TASK.GET_ACTIVE_VEHICLE_MISSION_TYPE(Veh) ~= 4 then
																				if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
																					TASK.TASK_VEHICLE_MISSION_PED_TARGET(peds, Veh, PlayerPed, 4, 100.0, 0, 20.0, 10.0, true)
																				end
																			end
																		end
																	end
																else
																	if not ENTITY.IS_ENTITY_AT_ENTITY(peds, PlayerPed, 150.0, 150.0, 200.0, false, true, false) then
																		if IsAHeli then
																			if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_VEHICLE_MISSION")) == 7 then
																				if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
																					TASK.TASK_HELI_MISSION(peds, Veh, 0, PlayerPed, 0.0, 0.0, 50.0, 4, 100.0, 100.0, 0, 50.0, 20.0, 50.0, 0)
																				end
																			end
																		end
																		if IsAPlane then
																			if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_VEHICLE_MISSION")) == 7 then
																				if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
																					TASK.TASK_PLANE_MISSION(peds, Veh, 0, PlayerPed, 0, 0, 0, 4, 100.0, 50.0, 0.0, 50.0, 30.0, true)
																				end
																			end
																		end
																	end
																end
															end
														end
													end
												end
											end
											if CopsFollowTask then
												if Veh == 0 then
													if not IsPedInGroup then
														if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_SHOOT_AT_COORD")) == 7 then
															if ENTITY.IS_ENTITY_AT_ENTITY(peds, PlayerPed, 50.0, 50.0, 50.0, false, true, false) then
																if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_FOLLOW_TO_OFFSET_OF_ENTITY")) == 7 then
																	if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
																		TASK.TASK_FOLLOW_TO_OFFSET_OF_ENTITY(peds, PlayerPed, math.random(-10, 10), math.random(-10, 10), math.random(-10, 10), 100.0, -1, 5.0, true)
																	end
																end
															end
														end
													end
												end
											end
											if AllyAttacksHostiles then
												if not PED.IS_PED_IN_COMBAT(peds, 0) then
													TASK.TASK_COMBAT_HATED_TARGETS_AROUND_PED(peds, DistanceNeededToAttack, 0)
												end
											end
											if BringFarCopsCloser then
												local CanGo = true
												local IsInVeh = PED.IS_PED_IN_ANY_VEHICLE(PlayerPed, false)
												if BringIfOutsideOfVehicle then
													if IsInVeh then
														CanGo = false
													end
												end
												if CanGo then
													if not ENTITY.IS_ENTITY_AT_ENTITY(peds, PlayerPed, 100.0, 100.0, 100.0, false, true, false) then
														if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
															if not RemoveCopsFromVeh then
																if Veh ~= 0 then
																	if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(Veh) then
																		if VEHICLE.GET_PED_IN_VEHICLE_SEAT(Veh, -1, false) == peds then
																			local VehClass = VEHICLE.GET_VEHICLE_CLASS(Veh)
																			if VehClass ~= 15 and VehClass ~= 16 then
																				if not ENTITY.IS_ENTITY_AT_ENTITY(Veh, PlayerPed, 700.0, 700.0, 700.0, false, true, false) then
																					local FVect = nil
																					local Multiplier = 100
																					if IsInVeh then
																						FVect = ENTITY.GET_ENTITY_FORWARD_VECTOR(PlayerPed)
																						Multiplier = -100
																					else
																						local CamRot = CAM.GET_GAMEPLAY_CAM_ROT(2)
																						FVect = CamRot:toDir()
																					end
																					local PPos = ENTITY.GET_ENTITY_COORDS(PlayerPed)
																					local AdjustedX = PPos.x + FVect.x * Multiplier
																					local AdjustedY = PPos.y + FVect.y * Multiplier
																					local AdjustedZ = PPos.z + FVect.z * Multiplier
																					local DidHit = memory.alloc(1)
																					local EndCoords = v3.new()
																					local Normal = v3.new()
																					local HitEntity = memory.alloc_int()
																				
																					local Handle = SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(
																						PPos.x, PPos.y, PPos.z,
																						AdjustedX, AdjustedY, AdjustedZ,
																						-1,
																						PlayerPed, 7
																					)
																					SHAPETEST.GET_SHAPE_TEST_RESULT(Handle, DidHit, EndCoords, Normal, HitEntity)
																					if memory.read_byte(DidHit) ~= 0 then
																						if not MISC.IS_POSITION_OCCUPIED(EndCoords.x - FVect.x * 5.0, EndCoords.y - FVect.y * 5.0, (EndCoords.z - 1.0) - FVect.z * 5.0, 1.0, false, true, true, false, false, 0, true) then
																							ENTITY.SET_ENTITY_COORDS(Veh, EndCoords.x - FVect.x * 5.0, EndCoords.y - FVect.y * 5.0, (EndCoords.z - 1.0) - FVect.z * 5.0)
																						end
																					else
																						if not MISC.IS_POSITION_OCCUPIED(AdjustedX - FVect.x * 5.0, AdjustedY - FVect.y * 5.0, (AdjustedZ - 1.0) - FVect.z * 5.0, 1.0, false, true, true, false, false, 0, true) then
																							ENTITY.SET_ENTITY_COORDS(Veh, AdjustedX - FVect.x * 5.0, AdjustedY - FVect.y * 5.0, (AdjustedZ - 1.0) - FVect.z * 5.0)
																						end
																					end
																				end
																			else
																				if not ENTITY.IS_ENTITY_AT_ENTITY(Veh, PlayerPed, 700.0, 700.0, 700.0, false, true, false) then
																					local FVect = ENTITY.GET_ENTITY_FORWARD_VECTOR(peds)
																					local PPos = ENTITY.GET_ENTITY_COORDS(PlayerPed)
																					local AdjustedX = PPos.x + FVect.x * 100
																					local AdjustedY = PPos.y + FVect.y * 100
																					local AdjustedZ = PPos.z + FVect.z * 100
																					if not MISC.IS_POSITION_OCCUPIED(AdjustedX, AdjustedY, AdjustedZ + 100.0, 1.0, false, true, true, false, false, PlayerPed, true) then
																						ENTITY.SET_ENTITY_COORDS(Veh, AdjustedX, AdjustedY, AdjustedZ + 100.0)
																					end
																				end
																			end
																		end
																	end
																else
																	local FVect = nil
																	if IsInVeh then
																		FVect = ENTITY.GET_ENTITY_FORWARD_VECTOR(PlayerPed)
																	else
																		FVect = ENTITY.GET_ENTITY_FORWARD_VECTOR(peds)
																	end
																	local PPos = ENTITY.GET_ENTITY_COORDS(PlayerPed)
																	local AdjustedX = PPos.x + FVect.x * 5
																	local AdjustedY = PPos.y + FVect.y * 5
																	local AdjustedZ = PPos.z + FVect.z * 5
																	local DidHit = memory.alloc(1)
																	local EndCoords = v3.new()
																	local Normal = v3.new()
																	local HitEntity = memory.alloc_int()
																
																	local Handle = SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(
																		PPos.x, PPos.y, PPos.z,
																		AdjustedX, AdjustedY, AdjustedZ,
																		-1,
																		PlayerPed, 7
																	)
																	SHAPETEST.GET_SHAPE_TEST_RESULT(Handle, DidHit, EndCoords, Normal, HitEntity)
																	if memory.read_byte(DidHit) ~= 0 then
																		if not MISC.IS_POSITION_OCCUPIED(EndCoords.x, EndCoords.y, EndCoords.z - 1.0, 2.0, false, true, true, false, false, PlayerPed, true) then
																			ENTITY.SET_ENTITY_COORDS(peds, EndCoords.x, EndCoords.y, EndCoords.z - 1.0)
																		end
																	else
																		if not MISC.IS_POSITION_OCCUPIED(AdjustedX, AdjustedY, AdjustedZ - 1.0, 2.0, false, true, true, false, false, PlayerPed, true) then
																			ENTITY.SET_ENTITY_COORDS(peds, AdjustedX, AdjustedY, AdjustedZ - 1.0)
																		end
																	end
																end
															else
																local FVect = nil
																if IsInVeh then
																	FVect = ENTITY.GET_ENTITY_FORWARD_VECTOR(PlayerPed)
																else
																	FVect = ENTITY.GET_ENTITY_FORWARD_VECTOR(peds)
																end
																local PPos = ENTITY.GET_ENTITY_COORDS(PlayerPed)
																local MultiplierToGive = 5
																if IsInVeh then
																	MultiplierToGive = -50
																end
																local AdjustedX = PPos.x + FVect.x * MultiplierToGive
																local AdjustedY = PPos.y + FVect.y * MultiplierToGive
																local AdjustedZ = PPos.z + FVect.z * MultiplierToGive
																local DidHit = memory.alloc(1)
																local EndCoords = v3.new()
																local Normal = v3.new()
																local HitEntity = memory.alloc_int()
															
																local Handle = SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(
																	PPos.x, PPos.y, PPos.z,
																	AdjustedX, AdjustedY, AdjustedZ,
																	-1,
																	PlayerPed, 7
																)
																SHAPETEST.GET_SHAPE_TEST_RESULT(Handle, DidHit, EndCoords, Normal, HitEntity)
																if memory.read_byte(DidHit) ~= 0 then
																	if not MISC.IS_POSITION_OCCUPIED(EndCoords.x, EndCoords.y, EndCoords.z - 1.0, 2.0, false, true, true, false, false, PlayerPed, true) then
																		ENTITY.SET_ENTITY_COORDS(peds, EndCoords.x, EndCoords.y, EndCoords.z - 1.0)
																	end
																else
																	if not MISC.IS_POSITION_OCCUPIED(AdjustedX, AdjustedY, AdjustedZ - 1.0, 2.0, false, true, true, false, false, PlayerPed, true) then
																		ENTITY.SET_ENTITY_COORDS(peds, AdjustedX, AdjustedY, AdjustedZ - 1.0)
																	end
																end
															end
														end
													end
												end
											end
											if CopsShootWhereYouShoot or CopsShootWhereYouAim then
												if Veh == 0 then
													if not WEAPON.IS_PED_ARMED(peds, 4) then
														local BestWeapon = WEAPON.GET_BEST_PED_WEAPON(peds, false)
														WEAPON.SET_CURRENT_PED_WEAPON(peds, BestWeapon, true)
													end
													if HasHit then
														if HitCoords ~= nil then
															if ShootsT[peds] == nil then
																if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
																	TASK.TASK_SHOOT_AT_COORD(peds, HitCoords.x, HitCoords.y, HitCoords.z, 3000, joaat("FIRING_PATTERN_FULL_AUTO"))
																	ShootsT[peds] = 0
																end
															end
														end
													end
												else
													if HitCoords ~= nil then
														if HasHit then
															if TasksT[peds] == nil then
																if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
																	local VehWeapHash = memory.alloc(8)
																	local HaveVehWeapon = WEAPON.GET_CURRENT_PED_VEHICLE_WEAPON(peds, VehWeapHash)
																	if HaveVehWeapon then
																		TASK.TASK_VEHICLE_SHOOT_AT_COORD(peds, HitCoords.x, HitCoords.y, HitCoords.z, 20.0)
																		TasksT[peds] = 0
																	end
																end
															end
														end
													end
												end
												if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_VEHICLE_SHOOT_AT_COORD")) ~= 7 then
													if PED.IS_PED_SHOOTING(peds) then
														if TasksT[peds] ~= nil then
															TasksT[peds] = TasksT[peds] + 1
															if IsPlayerShooting then
																TasksT[peds] = 0
															end
															if TasksT[peds] > 10 then
																NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds)
																TASK.CLEAR_PED_TASKS(peds)
																TasksT[peds] = nil
															end
														end
													end
												end
											end
										else
											if CopsAttackEveryone then
												if MakeCopsAttackEveryone then
													if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_COMBAT_HATED_TARGETS_AROUND_PED")) == 7 then
														TASK.TASK_COMBAT_HATED_TARGETS_AROUND_PED(peds, 1000.0, 0)
													end
												end
											end
										end
									end
								else
									if CanAddBlip then
										if not HUD.DOES_PED_HAVE_AI_BLIP(peds) then
											HUD.SET_PED_HAS_AI_BLIP_WITH_COLOUR(peds, true, 2)
											HUD.SET_PED_AI_BLIP_HAS_CONE(peds, false)
											HUD.SET_PED_AI_BLIP_FORCED_ON(peds, true)
										end
									end
								end
								if ZombieMode then
									if not ENTITY.IS_ENTITY_AT_ENTITY(peds, PlayerPed, 100.0, 100.0, 100.0, false, true, false) then
										if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
											local PPos = ENTITY.GET_ENTITY_COORDS(PlayerPed)
											local OutPos, FoundCoords = find_right_spawn_normal(PPos.x, PPos.y, PPos.z, 40.0, 70.0)
											if FoundCoords then
												if not MISC.IS_POSITION_OCCUPIED(OutPos.x, OutPos.y, OutPos.z, 1.0, false, true, true, false, false, PlayerPed, true) then
													ENTITY.SET_ENTITY_COORDS(peds, OutPos.x, OutPos.y, OutPos.z)
													ENTITY.SET_ENTITY_HEADING(peds, math.random(0, 360))
												end
											end
										end
									end
									if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_COMBAT_HATED_TARGETS_AROUND_PED")) == 7 then
										if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
											TASK.TASK_COMBAT_HATED_TARGETS_AROUND_PED(peds, 1000.0, 0)
										end
									end
								end
							else
								local DecorInt = DECORATOR.DECOR_GET_INT(peds, "Casino_Game_Info_Decorator")
								if DecorInt == 32 then
									if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
										local NetID = NETWORK.PED_TO_NET(peds)
										if NetID ~= 0 then
											NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(NetID, PlayerID, false)
										end
										entities.delete_by_handle(peds)
									end
								end
								if DecorInt == 31 then
									if CanEditCop then
										if PED.GET_PED_RELATIONSHIP_GROUP_HASH(peds) ~= SelectedTeam then
											NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds)
											PED.SET_PED_RELATIONSHIP_GROUP_HASH(peds, SelectedTeam)
										end
										if PutCopsIntoPlayerVeh then
											if PlayerVeh ~= 0 then
												for i = -1, 9 do
													if VEHICLE.IS_VEHICLE_SEAT_FREE(PlayerVeh, i, true) then
														if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
															PED.SET_PED_INTO_VEHICLE(peds, PlayerVeh, i)
														end
													end
												end
											end
										end
									end
									if ENTITY.IS_ENTITY_DEAD(peds) then
										if DeadPeds[peds] == nil then
											util.create_thread(function()
												DeadPeds[peds] = {}
												Wait(10000)
												while not NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) do
													Wait()
												end
												local NetID = NETWORK.PED_TO_NET(peds)
												if NetID ~= 0 then
													NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(NetID, PlayerID, false)
												end
												DECORATOR.DECOR_SET_INT(peds, "Casino_Game_Info_Decorator", 32)
												entities.delete_by_handle(peds)
												DeadPeds[peds] = nil
											end)
										end
									end
									CanAddBlip = false
									if AddBlipsForAllyCops then
										if not IsCopModel then
											CanAddBlip = true
										end
									end
									if AddBlipsForCopsDifferentModel then
										if IsCopModel then
											CanAddBlip = true
										end
									end
									if CanEditCop then
										if CanAddBlip then
											if not HUD.DOES_PED_HAVE_AI_BLIP(peds) then
												NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds)
												HUD.SET_PED_HAS_AI_BLIP_WITH_COLOUR(peds, true, BlipColorToGive)
												HUD.SET_PED_AI_BLIP_HAS_CONE(peds, false)
												HUD.SET_PED_AI_BLIP_FORCED_ON(peds, true)
											end
										end
									else
										if CanAddBlip then
											if not HUD.DOES_PED_HAVE_AI_BLIP(peds) then
												HUD.SET_PED_HAS_AI_BLIP_WITH_COLOUR(peds, true, 2)
												HUD.SET_PED_AI_BLIP_HAS_CONE(peds, false)
												HUD.SET_PED_AI_BLIP_FORCED_ON(peds, true)
											end
										end
									end
									if CopsAreAllies then
										if CanEditCop then
											local Veh = PED.GET_VEHICLE_PED_IS_IN(peds, false)
											local IsPedInGroup = PED.IS_PED_IN_GROUP(peds)
											if not IsPedInGroup then
												if CopsFollowAsBodyguard then
													local CanSetInGroup = true
													if Veh ~= 0 then
														local VehModel = ENTITY.GET_ENTITY_MODEL(Veh)
														local IsAPlane = VEHICLE.IS_THIS_MODEL_A_PLANE(VehModel)
														local IsAHeli = VEHICLE.IS_THIS_MODEL_A_HELI(VehModel)
														if IsAPlane or IsAHeli then
															CanSetInGroup = false
														end
													end
													if CanSetInGroup then
														if GetPedGroupSize(PlayerGroup) < 7 then
															if ENTITY.IS_ENTITY_AT_ENTITY(peds, PlayerPed, 30.0, 30.0, 30.0, false, true, false) then
																if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
																	PED.SET_PED_AS_GROUP_MEMBER(peds, PlayerGroup)
																	PED.SET_PED_NEVER_LEAVES_GROUP(peds, true)
																	PED.SET_GROUP_SEPARATION_RANGE(PlayerGroup, 9999.0)
																	PED.SET_GROUP_FORMATION_SPACING(PlayerGroup, 1.0, -1.0, -1.0)
																	PED.SET_GROUP_FORMATION(PlayerGroup, 1)
																	TASK.CLEAR_PED_TASKS(peds)
																end
															end
														end
													end
												end
											end
											IsPedInGroup = PED.IS_PED_IN_GROUP(peds)
											if CopsFollowInVehTask then
												if not PED.IS_PED_IN_COMBAT(peds, 0) then
													if Veh ~= 0 then
														if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_VEHICLE_SHOOT_AT_COORD")) == 7 then
															if VEHICLE.GET_PED_IN_VEHICLE_SEAT(Veh, -1, false) == peds then
																local VehModel = ENTITY.GET_ENTITY_MODEL(Veh)
																local IsAPlane = VEHICLE.IS_THIS_MODEL_A_PLANE(VehModel)
																local IsAHeli = VEHICLE.IS_THIS_MODEL_A_HELI(VehModel)
																if not IsAPlane and not IsAHeli then
																	if not IsPedInGroup then
																		if not ENTITY.IS_ENTITY_AT_ENTITY(peds, PlayerPed, 100.0, 100.0, 100.0, false, true, false) then
																			if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_VEHICLE_MISSION")) == 7 then
																			--if TASK.GET_ACTIVE_VEHICLE_MISSION_TYPE(Veh) ~= 4 then
																				if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
																					TASK.TASK_VEHICLE_MISSION_PED_TARGET(peds, Veh, PlayerPed, 4, 100.0, 0, 20.0, 10.0, true)
																				end
																			end
																		end
																	end
																else
																	if not ENTITY.IS_ENTITY_AT_ENTITY(peds, PlayerPed, 150.0, 150.0, 200.0, false, true, false) then
																		if IsAHeli then
																			if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_VEHICLE_MISSION")) == 7 then
																				if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
																					TASK.TASK_HELI_MISSION(peds, Veh, 0, PlayerPed, 0.0, 0.0, 50.0, 4, 100.0, 100.0, 0, 50.0, 20.0, 50.0, 0)
																				end
																			end
																		end
																		if IsAPlane then
																			if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_VEHICLE_MISSION")) == 7 then
																				if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
																					TASK.TASK_PLANE_MISSION(peds, Veh, 0, PlayerPed, 0, 0, 0, 4, 100.0, 50.0, 0.0, 50.0, 30.0, true)
																				end
																			end
																		end
																	end
																end
															end
														end
													end
												end
											end
											if CopsFollowTask then
												if Veh == 0 then
													if not IsPedInGroup then
														if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_SHOOT_AT_COORD")) == 7 then
															if ENTITY.IS_ENTITY_AT_ENTITY(peds, PlayerPed, 50.0, 50.0, 50.0, false, true, false) then
																if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_FOLLOW_TO_OFFSET_OF_ENTITY")) == 7 then
																	if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
																		TASK.TASK_FOLLOW_TO_OFFSET_OF_ENTITY(peds, PlayerPed, math.random(-10, 10), math.random(-10, 10), math.random(-10, 10), 100.0, -1, 5.0, true)
																	end
																end
															end
														end
													end
												end
											end
											if AllyAttacksHostiles then
												if not PED.IS_PED_IN_COMBAT(peds, 0) then
													TASK.TASK_COMBAT_HATED_TARGETS_AROUND_PED(peds, DistanceNeededToAttack, 0)
												end
											end
											if BringFarCopsCloser then
												local CanGo = true
												local IsInVeh = PED.IS_PED_IN_ANY_VEHICLE(PlayerPed, false)
												if BringIfOutsideOfVehicle then
													if IsInVeh then
														CanGo = false
													end
												end
												if CanGo then
													if not ENTITY.IS_ENTITY_AT_ENTITY(peds, PlayerPed, 100.0, 100.0, 100.0, false, true, false) then
														if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
															if not RemoveCopsFromVeh then
																if Veh ~= 0 then
																	if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(Veh) then
																		if VEHICLE.GET_PED_IN_VEHICLE_SEAT(Veh, -1, false) == peds then
																			local VehClass = VEHICLE.GET_VEHICLE_CLASS(Veh)
																			if VehClass ~= 15 and VehClass ~= 16 then
																				if not ENTITY.IS_ENTITY_AT_ENTITY(Veh, PlayerPed, 700.0, 700.0, 700.0, false, true, false) then
																					local FVect = nil
																					local Multiplier = 100
																					if IsInVeh then
																						FVect = ENTITY.GET_ENTITY_FORWARD_VECTOR(PlayerPed)
																						Multiplier = -100
																					else
																						local CamRot = CAM.GET_GAMEPLAY_CAM_ROT(2)
																						FVect = CamRot:toDir()
																					end
																					local PPos = ENTITY.GET_ENTITY_COORDS(PlayerPed)
																					local AdjustedX = PPos.x + FVect.x * Multiplier
																					local AdjustedY = PPos.y + FVect.y * Multiplier
																					local AdjustedZ = PPos.z + FVect.z * Multiplier
																					local DidHit = memory.alloc(1)
																					local EndCoords = v3.new()
																					local Normal = v3.new()
																					local HitEntity = memory.alloc_int()
																				
																					local Handle = SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(
																						PPos.x, PPos.y, PPos.z,
																						AdjustedX, AdjustedY, AdjustedZ,
																						-1,
																						PlayerPed, 7
																					)
																					SHAPETEST.GET_SHAPE_TEST_RESULT(Handle, DidHit, EndCoords, Normal, HitEntity)
																					if memory.read_byte(DidHit) ~= 0 then
																						if not MISC.IS_POSITION_OCCUPIED(EndCoords.x - FVect.x * 5.0, EndCoords.y - FVect.y * 5.0, (EndCoords.z - 1.0) - FVect.z * 5.0, 2.0, false, true, true, false, false, 0, true) then
																							ENTITY.SET_ENTITY_COORDS(Veh, EndCoords.x - FVect.x * 5.0, EndCoords.y - FVect.y * 5.0, (EndCoords.z - 1.0) - FVect.z * 5.0)
																						end
																					else
																						if not MISC.IS_POSITION_OCCUPIED(AdjustedX - FVect.x * 5.0, AdjustedY - FVect.y * 5.0, (AdjustedZ - 1.0) - FVect.z * 5.0, 2.0, false, true, true, false, false, 0, true) then
																							ENTITY.SET_ENTITY_COORDS(Veh, AdjustedX - FVect.x * 5.0, AdjustedY - FVect.y * 5.0, (AdjustedZ - 1.0) - FVect.z * 5.0)
																						end
																					end
																				end
																			else
																				if not ENTITY.IS_ENTITY_AT_ENTITY(Veh, PlayerPed, 700.0, 700.0, 700.0, false, true, false) then
																					local FVect = ENTITY.GET_ENTITY_FORWARD_VECTOR(peds)
																					local PPos = ENTITY.GET_ENTITY_COORDS(PlayerPed)
																					local AdjustedX = PPos.x + FVect.x * 100
																					local AdjustedY = PPos.y + FVect.y * 100
																					local AdjustedZ = PPos.z + FVect.z * 100
																					if not MISC.IS_POSITION_OCCUPIED(AdjustedX, AdjustedY, AdjustedZ + 100.0, 1.0, false, true, true, false, false, PlayerPed, true) then
																						ENTITY.SET_ENTITY_COORDS(Veh, AdjustedX, AdjustedY, AdjustedZ + 100.0)
																					end
																				end
																			end
																		end
																	end
																else
																	local FVect = nil
																	if IsInVeh then
																		FVect = ENTITY.GET_ENTITY_FORWARD_VECTOR(PlayerPed)
																	else
																		FVect = ENTITY.GET_ENTITY_FORWARD_VECTOR(peds)
																	end
																	local PPos = ENTITY.GET_ENTITY_COORDS(PlayerPed)
																	local MultiplierToGive = 5
																	if IsInVeh then
																		MultiplierToGive = -50
																	end
																	local AdjustedX = PPos.x + FVect.x * MultiplierToGive
																	local AdjustedY = PPos.y + FVect.y * MultiplierToGive
																	local AdjustedZ = PPos.z + FVect.z * MultiplierToGive
																	local DidHit = memory.alloc(1)
																	local EndCoords = v3.new()
																	local Normal = v3.new()
																	local HitEntity = memory.alloc_int()
																
																	local Handle = SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(
																		PPos.x, PPos.y, PPos.z,
																		AdjustedX, AdjustedY, AdjustedZ,
																		-1,
																		PlayerPed, 7
																	)
																	SHAPETEST.GET_SHAPE_TEST_RESULT(Handle, DidHit, EndCoords, Normal, HitEntity)
																	if memory.read_byte(DidHit) ~= 0 then
																		if not MISC.IS_POSITION_OCCUPIED(EndCoords.x, EndCoords.y, EndCoords.z - 1.0, 2.0, false, true, true, false, false, PlayerPed, true) then
																			ENTITY.SET_ENTITY_COORDS(peds, EndCoords.x, EndCoords.y, EndCoords.z - 1.0)
																		end
																	else
																		if not MISC.IS_POSITION_OCCUPIED(AdjustedX, AdjustedY, AdjustedZ - 1.0, 2.0, false, true, true, false, false, PlayerPed, true) then
																			ENTITY.SET_ENTITY_COORDS(peds, AdjustedX, AdjustedY, AdjustedZ - 1.0)
																		end
																	end
																end
															else
																local FVect = nil
																if IsInVeh then
																	FVect = ENTITY.GET_ENTITY_FORWARD_VECTOR(PlayerPed)
																else
																	FVect = ENTITY.GET_ENTITY_FORWARD_VECTOR(peds)
																end
																local PPos = ENTITY.GET_ENTITY_COORDS(PlayerPed)
																local AdjustedX = PPos.x + FVect.x * 5
																local AdjustedY = PPos.y + FVect.y * 5
																local AdjustedZ = PPos.z + FVect.z * 5
																local DidHit = memory.alloc(1)
																local EndCoords = v3.new()
																local Normal = v3.new()
																local HitEntity = memory.alloc_int()
															
																local Handle = SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(
																	PPos.x, PPos.y, PPos.z,
																	AdjustedX, AdjustedY, AdjustedZ,
																	-1,
																	PlayerPed, 7
																)
																SHAPETEST.GET_SHAPE_TEST_RESULT(Handle, DidHit, EndCoords, Normal, HitEntity)
																if memory.read_byte(DidHit) ~= 0 then
																	if not MISC.IS_POSITION_OCCUPIED(EndCoords.x, EndCoords.y, EndCoords.z - 1.0, 2.0, false, true, true, false, false, PlayerPed, true) then
																		ENTITY.SET_ENTITY_COORDS(peds, EndCoords.x, EndCoords.y, EndCoords.z - 1.0)
																	end
																else
																	if not MISC.IS_POSITION_OCCUPIED(AdjustedX, AdjustedY, AdjustedZ - 1.0, 2.0, false, true, true, false, false, PlayerPed, true) then
																		ENTITY.SET_ENTITY_COORDS(peds, AdjustedX, AdjustedY, AdjustedZ - 1.0)
																	end
																end
															end
														end
													end
												end
											end
											if CopsShootWhereYouShoot or CopsShootWhereYouAim then
												if Veh == 0 then
													if not WEAPON.IS_PED_ARMED(peds, 4) then
														local BestWeapon = WEAPON.GET_BEST_PED_WEAPON(peds, false)
														WEAPON.SET_CURRENT_PED_WEAPON(peds, BestWeapon, true)
													end
													if HasHit then
														if HitCoords ~= nil then
															if ShootsT[peds] == nil then
																if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
																	TASK.TASK_SHOOT_AT_COORD(peds, HitCoords.x, HitCoords.y, HitCoords.z, 3000, joaat("FIRING_PATTERN_FULL_AUTO"))
																	ShootsT[peds] = 0
																end
															end
														end
													end
												else
													if HitCoords ~= nil then
														if HasHit then
															if TasksT[peds] == nil then
																if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
																	local VehWeapHash = memory.alloc(8)
																	local HaveVehWeapon = WEAPON.GET_CURRENT_PED_VEHICLE_WEAPON(peds, VehWeapHash)
																	if HaveVehWeapon then
																		TASK.TASK_VEHICLE_SHOOT_AT_COORD(peds, HitCoords.x, HitCoords.y, HitCoords.z, 20.0)
																		TasksT[peds] = 0
																	end
																end
															end
														end
													end
												end
												if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_VEHICLE_SHOOT_AT_COORD")) ~= 7 then
													if PED.IS_PED_SHOOTING(peds) then
														if TasksT[peds] ~= nil then
															TasksT[peds] = TasksT[peds] + 1
															if IsPlayerShooting then
																TasksT[peds] = 0
															end
															if TasksT[peds] > 10 then
																NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds)
																TASK.CLEAR_PED_TASKS(peds)
																TasksT[peds] = nil
															end
														end
													end
												end
											end
										end
									else
										if CanEditCop then
											if CopsAttackEveryone then
												if MakeCopsAttackEveryone then
													if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_COMBAT_HATED_TARGETS_AROUND_PED")) == 7 then
														TASK.TASK_COMBAT_HATED_TARGETS_AROUND_PED(peds, 1000.0, 0)
													end
												end
											end
											if ZombieMode then
												if not ENTITY.IS_ENTITY_AT_ENTITY(peds, PlayerPed, 100.0, 100.0, 100.0, false, true, false) then
													if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
														local PPos = ENTITY.GET_ENTITY_COORDS(PlayerPed)
														local OutPos, FoundCoords = find_right_spawn_normal(PPos.x, PPos.y, PPos.z, 40.0, 70.0)
														if FoundCoords then
															if not MISC.IS_POSITION_OCCUPIED(OutPos.x, OutPos.y, OutPos.z, 1.0, false, true, true, false, false, PlayerPed, true) then
																ENTITY.SET_ENTITY_COORDS(peds, OutPos.x, OutPos.y, OutPos.z)
																ENTITY.SET_ENTITY_HEADING(peds, math.random(0, 360))
															end
														end
													end
												end
												if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_COMBAT_HATED_TARGETS_AROUND_PED")) == 7 then
													if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
														TASK.TASK_COMBAT_HATED_TARGETS_AROUND_PED(peds, 1000.0, 0)
													end
												end
											end
										end
									end
								end
							end
							if ShootsT[peds] ~= nil then
								ShootsT[peds] = ShootsT[peds] + 1
								if PED.IS_PED_SHOOTING(peds) or ShootsT[peds] > 100 then
									ShootsT[peds] = nil
								end
							end
						end
					end
				end
				if ApplyCopSettings then
					if AutomaticGenCops then
						if MissionCopCount >= MaxCopsToEdit then
							PLAYER.SET_PLAYER_WANTED_LEVEL(PlayerID, 0, false)
							PLAYER.SET_PLAYER_WANTED_LEVEL_NOW(PlayerID, false)
						else
							PLAYER.SET_DISPATCH_COPS_FOR_PLAYER(PlayerID, true)
							PLAYER.SET_MAX_WANTED_LEVEL(5)
							PLAYER.SET_PLAYER_WANTED_LEVEL(PlayerID, 5, false)
							PLAYER.SET_PLAYER_WANTED_LEVEL_NOW(PlayerID, false)
						end
					end
				end
			end
			Wait()
		end
	end
end)

menu.toggle_loop(menu.my_root(), "Enable Cops In Cayo Perico", {}, "", function(toggle)
	local PlayerId = PLAYER.PLAYER_ID()
	local Addr = memory.script_global(CayoCopsGlobalAddr + 463 * PlayerId)
	local Value = memory.read_int(Addr)
	if is_bit_set(Value, 1) then
		memory.write_int(Addr, clear_bit(Value, 1))
	end
end)

local OnlyShowCopBlips = false
menu.toggle(menu.my_root(), "Only Show Cop Blips", {}, "", function(toggle)
	OnlyShowCopBlips = toggle
	while OnlyShowCopBlips do
		Wait()
		local PlayerPed = PLAYER.PLAYER_PED_ID()
		local MissionCopCount = 0
		for index, peds in pairs(entities.get_all_peds_as_handles()) do
			if peds ~= PlayerPed then
				if not PED.IS_PED_A_PLAYER(peds) then
					local DecorInt = DECORATOR.DECOR_GET_INT(peds, "Casino_Game_Info_Decorator")
					if DecorInt == 31 then
						MissionCopCount = MissionCopCount + 1
						if not HUD.DOES_PED_HAVE_AI_BLIP(peds) then
							HUD.SET_PED_HAS_AI_BLIP_WITH_COLOUR(peds, true, 2)
							HUD.SET_PED_AI_BLIP_HAS_CONE(peds, false)
							HUD.SET_PED_AI_BLIP_FORCED_ON(peds, true)
						end
					end
				end
			end
		end
		if RenderCopCount then
			directx.draw_text(0.7, 0.7, "Cops "..MissionCopCount, ALIGN_CENTRE, 1.0, {r = 0, g = 255 , b = 255, a = 200}, false)
		end
	end
end, OnlyShowCopBlips)

function is_bit_set(value, bit)
    bit = bit - 1
    return (value & (1 << bit)) ~= 0
end

function clear_bit(value, bit)
    bit = bit - 1;
    return value & ~(1 << bit)
end

function set_bit(value, bit)
    bit = bit - 1;
    return value | 1 << bit
end

local WeaponsLevel1 = {
	"weapon_pistol50",
	"weapon_heavypistol",
	"weapon_microsmg",
	"weapon_minismg",
	"weapon_tecpistol"
}

local WeaponsLevel2 = {
	"weapon_appistol",
	"weapon_gadgetpistol",
	"weapon_assaultsmg",
	"weapon_smg",
	"weapon_smg_mk2",
	"weapon_machinepistol",
	"weapon_pumpshotgun"
}

local WeaponsLevel3 = {
	"weapon_navyrevolver",
	"weapon_combatpdw",
	"weapon_sawnoffshotgun",
	"weapon_assaultshotgun",
	"weapon_heavyshotgun",
	"weapon_dbshotgun",
	"weapon_autoshotgun",
	"weapon_combatshotgun",
	"weapon_carbinerifle",
	"weapon_carbinerifle_mk2",
	"weapon_specialcarbine",
	"weapon_specialcarbine_mk2",
	"weapon_bullpuprifle",
	"weapon_bullpuprifle_mk2",
	"weapon_compactrifle",
	"weapon_militaryrifle",
	"weapon_heavyrifle",
	"weapon_tacticalrifle",
	"weapon_gusenberg"
}

local WeaponsLevel4 = {
	"weapon_mg",
	"weapon_combatmg",
	"weapon_combatmg_mk2",
}

local WeaponsLevel5 = {
	"weapon_sniperrifle",
	"weapon_heavysniper",
	"weapon_heavysniper_mk2",
	"weapon_marksmanrifle",
	"weapon_marksmanrifle_mk2",
	"weapon_precisionrifle",
}

local WeaponsLevel6 = {
	"weapon_rpg",
	"weapon_grenadelauncher",
	"weapon_minigun",
	"weapon_firework",
	"weapon_railgun",
	"weapon_hominglauncher",
	"weapon_compactlauncher",
	"weapon_emplauncher"
}

function GiveCorrectWeaponsToPed(Ped)
	if EnableWeaponSettsForCops then
		if SelectedGiveWeaponType == 1 then
			WEAPON.REMOVE_ALL_PED_WEAPONS(Ped, true)
			WEAPON.GIVE_WEAPON_TO_PED(Ped, SelectedForcedPedWeaponHash, 99999, false, true)
		end
		if SelectedGiveWeaponType == 2 then
			WEAPON.GIVE_WEAPON_TO_PED(Ped, SelectedAutoGivePedWeaponHash, 99999, false, true)
		end
		if SelectedGiveWeaponType == 3 then
			WEAPON.REMOVE_ALL_PED_WEAPONS(Ped, true)
			local RandomWeapHash = joaat(WeaponsForCops[math.random(#WeaponsForCops)])
			WEAPON.GIVE_WEAPON_TO_PED(Ped, RandomWeapHash, 99999, false, true)
		end
		if SelectedGiveWeaponType == 4 then
			local ChosenWeaponHash = 0
			local RandomChance = math.random(0, 120)
			if RandomChance <= 20 then
				ChosenWeaponHash = joaat(WeaponsLevel1[math.random(#WeaponsLevel1)])
			end
			if RandomChance > 20 and RandomChance <= 40 then
				ChosenWeaponHash = joaat(WeaponsLevel2[math.random(#WeaponsLevel2)])
			end
			if RandomChance > 40 and RandomChance <= 60 then
				ChosenWeaponHash = joaat(WeaponsLevel3[math.random(#WeaponsLevel3)])
			end
			if RandomChance > 60 and RandomChance <= 80 then
				ChosenWeaponHash = joaat(WeaponsLevel4[math.random(#WeaponsLevel4)])
			end
			if RandomChance > 80 and RandomChance <= 100 then
				ChosenWeaponHash = joaat(WeaponsLevel5[math.random(#WeaponsLevel5)])
			end
			if AllowExplosives then
				if RandomChance > 100 and RandomChance <= 120 then
					ChosenWeaponHash = joaat(WeaponsLevel6[math.random(#WeaponsLevel6)])
				end
			else
				if RandomChance > 100 then
					ChosenWeaponHash = joaat(WeaponsLevel5[math.random(#WeaponsLevel5)])
				end
			end
			WEAPON.GIVE_WEAPON_TO_PED(Ped, ChosenWeaponHash, 99999, false, true)
		end
		if SelectedGiveWeaponType == 5 then
			local ChosenWeaponHash = 0
			local RandomChance = math.random(0, 120)
			if RandomChance <= 40 then
				local RandomLevel = math.random(1, 5)
				if RandomLevel == 1 then
					ChosenWeaponHash = joaat(WeaponsLevel1[math.random(#WeaponsLevel1)])
				end
				if RandomLevel == 2 then
					ChosenWeaponHash = joaat(WeaponsLevel2[math.random(#WeaponsLevel2)])
				end
				if RandomLevel == 3 then
					ChosenWeaponHash = joaat(WeaponsLevel3[math.random(#WeaponsLevel3)])
				end
				if RandomLevel == 4 then
					ChosenWeaponHash = joaat(WeaponsLevel4[math.random(#WeaponsLevel4)])
				end
				if RandomLevel == 5 then
					ChosenWeaponHash = joaat(WeaponsLevel5[math.random(#WeaponsLevel5)])
				end
			end
			if RandomChance > 40 and RandomChance <= 120 then
				ChosenWeaponHash = joaat(WeaponsLevel6[math.random(#WeaponsLevel6)])
			end
			WEAPON.GIVE_WEAPON_TO_PED(Ped, ChosenWeaponHash, 99999, false, true)
		end
	end
end

function IsWithCopRel(Ped)
	local RelHash = PED.GET_PED_RELATIONSHIP_GROUP_HASH(Ped)
	if RelHash == joaat("COP") or RelHash == joaat("ARMY") then
		return true
	end
	return false
end

function IsCopPedModel(Ped)
	local PedModel = ENTITY.GET_ENTITY_MODEL(Ped)
	for i = 1, #SelectedPedModels do
		if SelectedPedModels[i] ~= nil then
			if PedModel == joaat(SelectedPedModels[i]) then
				return true
			end
		end
	end
	return false
end

local ModelsToSet = {
	"tampa3",
	"savage",
	"nightshark",
	"khanjali",
	"buzzard",
	"menacer",
	"annihilator"
}
function IsArmoredVehModel(Veh)
	local VehModel = ENTITY.GET_ENTITY_MODEL(Veh)
	for i = 1, #ModelsToSet do
		if VehModel == joaat(ModelsToSet[i]) then
			return true
		end
	end
	return false
end

local MiscMenu = menu.list(menu.my_root(), "Misc Features", {}, "")

menu.action(MiscMenu, "Fill Pop", {}, "", function(toggle)
	PED.INSTANTLY_FILL_PED_POPULATION()
end)

menu.toggle_loop(MiscMenu, "Network Door", {}, "Some doors you aim will be able to open by other players.", function(toggle)
	local PlayerId = PLAYER.PLAYER_ID()
	if PLAYER.IS_PLAYER_FREE_AIMING(PlayerId) then
		local Entity = get_entity_player_is_aiming_at(PlayerId)
		if Entity ~= nil then
			--request_control_once(Entity)
			local Pos = ENTITY.GET_ENTITY_COORDS(Entity)
			local ModelHash = ENTITY.GET_ENTITY_MODEL(Entity)
			local DoorHash = memory.alloc(8)
			local Found = OBJECT.DOOR_SYSTEM_FIND_EXISTING_DOOR(Pos.x, Pos.y, Pos.z, ModelHash, DoorHash)
			if Found then
				OBJECT.DOOR_SYSTEM_SET_DOOR_STATE(memory.read_int(DoorHash), 0, true, false)
			end
		end
	end
end)

menu.toggle_loop(MiscMenu, "Set Aimed Entity Invincible", {}, "", function(toggle)
	local PlayerId = PLAYER.PLAYER_ID()
	if PLAYER.IS_PLAYER_FREE_AIMING(PlayerId) then
		local Entity = get_entity_player_is_aiming_at(PlayerId)
		if Entity ~= nil then
			NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(Entity)
			ENTITY.SET_ENTITY_INVINCIBLE(Entity, true)
		end
	end
end)

local CollectAll = false
menu.toggle(MiscMenu, "B Battle Collect All 8 Crates", {""}, "", function(toggle)
	CollectAll = toggle
	while CollectAll do
		Wait()
		local pickups = entities.get_all_pickups_as_handles()
		for index, crates in ipairs(pickups) do
			if ENTITY.GET_ENTITY_SCRIPT(crates, 0) == "fm_content_business_battles"
			and not ENTITY.IS_ENTITY_ATTACHED_TO_ANY_PED(crates) then
                NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(crates)
				ENTITY.ATTACH_ENTITY_TO_ENTITY(crates, PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PLAYER.PLAYER_ID()), 0, 0, 0, 0, 0, 0, 0, 0, true, true, false, 0, true)
				--OBJECT.ATTACH_PORTABLE_PICKUP_TO_PED(crates, PLAYER.PLAYER_PED_ID())
			end
		end
	end
end)

menu.toggle_loop(MiscMenu, "Kill List Veh Valkyrie", {""}, "", function(toggle)
	local HostSet = false
	local ChosenVehModel = joaat("tampa3")
	if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("am_kill_list")) > 0 then
		if not HostSet then
			NETWORK.NETWORK_REQUEST_TO_BE_HOST_OF_THIS_SCRIPT()
			HostSet = true
		end
		memory.write_int(memory.script_local("am_kill_list", 94+27), ChosenVehModel)
		local VehNetID = memory.read_int(memory.script_local("am_kill_list", 94+7+1))
		local VehHandle = 0
		util.spoof_script("am_kill_list", function()
			if not NETWORK.NETWORK_IS_HOST_OF_THIS_SCRIPT() then
				NETWORK.NETWORK_REQUEST_TO_BE_HOST_OF_THIS_SCRIPT()
			end
			if VehNetID > 0 then
				VehHandle = NETWORK.NET_TO_VEH(VehNetID)
			end
		end)
		if VehHandle > 0 then
			if ENTITY.GET_ENTITY_MODEL(VehHandle) == ChosenVehModel then
				memory.write_int(memory.script_local("am_kill_list", 94+27), joaat("buzzard"))
			end
		end
	else
		HostSet = false
	end
end)

menu.action(MiscMenu, "Start Kill List", {}, "", function(toggle)
	if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("am_kill_list")) > 0 then
		memory.write_int(memory.script_local("am_kill_list", 94+413), -4144)
		util.spoof_script("am_kill_list", function()
			if not NETWORK.NETWORK_IS_HOST_OF_THIS_SCRIPT() then
				NETWORK.NETWORK_REQUEST_TO_BE_HOST_OF_THIS_SCRIPT()
			end
		end)
	end
end)

menu.action(MiscMenu, "Bring Fortified Boxville", {}, "", function(toggle)
	for index, vehs in pairs(entities.get_all_vehicles_as_handles()) do
		if ENTITY.GET_ENTITY_SCRIPT(vehs, 0) == "GB_FORTIFIED" then
			if ENTITY.GET_ENTITY_MODEL(vehs) == joaat("boxville5") then
				local PlCoords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
				NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(vehs)
				ENTITY.SET_ENTITY_COORDS(vehs, PlCoords.x, PlCoords.y, PlCoords.z)
			end
		end
	end
end)

menu.toggle_loop(MiscMenu, "GB_FORTIFIED Spam Enemies", {}, "", function(toggle)
	if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("gb_fortified")) > 0 then
		memory.write_int(memory.script_local("gb_fortified", 1082+331-26), 3)
		memory.write_int(memory.script_local("gb_fortified", 1082+331-7), 1)
		util.spoof_script("gb_fortified", function()
			if not NETWORK.NETWORK_IS_HOST_OF_THIS_SCRIPT() then
				NETWORK.NETWORK_REQUEST_TO_BE_HOST_OF_THIS_SCRIPT()
			end
		end)
	end
end)

local FreezeVehSpawnCoords = false
menu.toggle(MiscMenu, "Personal Vehicle Spawn Here", {}, "When enabled, the personal vehicle will only spawn where your character was when enabled this feature.", function(toggle)
	FreezeVehSpawnCoords = toggle
	local PlayerCoords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
	while FreezeVehSpawnCoords do
		memory.write_float(memory.script_global(2635560+683), PlayerCoords.x)
		memory.write_float(memory.script_global(2635560+683+1), PlayerCoords.y)
		memory.write_float(memory.script_global(2635560+683+2), PlayerCoords.z)
		Wait()
	end
end)

--util.copy_to_clipboard(string.format("%X", memory.script_global(SplitGlobals("Global_2635560.f_683"))))

menu.toggle_loop(MiscMenu, "Business Battles Chaos", {""}, "Enemies will rush and respawn.", function(toggle)
	if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("fm_content_business_battles")) > 0 then
		util.spoof_script("fm_content_business_battles", function()
			if not NETWORK.NETWORK_IS_HOST_OF_THIS_SCRIPT() then
				NETWORK.NETWORK_REQUEST_TO_BE_HOST_OF_THIS_SCRIPT()
			end
		end)
		for i = 0, 29 do
			memory.write_int(memory.script_local("fm_content_business_battles", (215+129+1+2) + 21 * i), 1024)
			memory.write_float(memory.script_local("fm_content_business_battles", (215+129+1+21) + 21 * i), -1)
		end
	end
end)

menu.toggle_loop(MiscMenu, "Cargo Plane Takedown", {""}, "am_plane_takedown", function(toggle)
	if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("am_plane_takedown")) > 0 then
		util.spoof_script("am_plane_takedown", function()
			if not NETWORK.NETWORK_IS_HOST_OF_THIS_SCRIPT() then
				NETWORK.NETWORK_REQUEST_TO_BE_HOST_OF_THIS_SCRIPT()
			end
		end)
		for i = 0, 29 do
			memory.write_int(memory.script_local("am_plane_takedown", 86+4), joaat("cargoplane"))
		end
	end
end)

menu.action(MiscMenu, "Cargo Plane Takedown Blip", {""}, "am_plane_takedown", function(toggle)
	for index, vehs in pairs(entities.get_all_vehicles_as_handles()) do
		if ENTITY.GET_ENTITY_SCRIPT(vehs, 0) == "AM_PLANE_TAKEDOWN" then
			local Ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehs, -1, false)
			if Ped ~= 0 then
				HUD.SET_PED_HAS_AI_BLIP_WITH_COLOUR(Ped, true, 1)
				HUD.SET_PED_AI_BLIP_HAS_CONE(Ped, false)
				HUD.SET_PED_AI_BLIP_FORCED_ON(Ped, true)
			end
		end
	end
end)

menu.action(MiscMenu, "Solo Tutorial Session", {}, "", function(toggle)
	if NETWORK.NETWORK_IS_IN_TUTORIAL_SESSION() then
		NETWORK.NETWORK_END_TUTORIAL_SESSION()
	else
		NETWORK.NETWORK_START_SOLO_TUTORIAL_SESSION()
	end
end)

--[[
menu.action(MiscMenu, "am_plane_takedown Kill Script", {""}, "am_plane_takedown", function(toggle)
	MISC.TERMINATE_ALL_SCRIPTS_WITH_THIS_NAME("am_plane_takedown")
end)
]]
--util.copy_to_clipboard(string.format("%X", memory.script_local("fm_content_business_battles", (215+129+1+20) + 21 * 0)))

local StartMissionMenu = menu.list(menu.my_root(), "Missions", {}, "")

local NextIndexGlobal = 609
local StartMissionGlobal = 1895156+1+10+32

local BikerMissions = menu.list(StartMissionMenu, "Biker Missions", {}, "")
menu.action(BikerMissions, "Joust", {}, "Start this mission.", function(toggle)
	local PlayerID = PLAYER.PLAYER_ID()
	memory.write_int(memory.script_global(StartMissionGlobal + NextIndexGlobal * PlayerID), 179)
end)

menu.action(BikerMissions, "Unload Weapons", {}, "Start this mission.", function(toggle)
	local PlayerID = PLAYER.PLAYER_ID()
	memory.write_int(memory.script_global(StartMissionGlobal + NextIndexGlobal * PlayerID), 180)
end)

menu.action(BikerMissions, "Bad Deal", {}, "Start this mission.", function(toggle)
	local PlayerID = PLAYER.PLAYER_ID()
	memory.write_int(memory.script_global(StartMissionGlobal + NextIndexGlobal * PlayerID), 182)
end)

menu.action(BikerMissions, "Rescue Contact", {}, "Start this mission.", function(toggle)
	local PlayerID = PLAYER.PLAYER_ID()
	memory.write_int(memory.script_global(StartMissionGlobal + NextIndexGlobal * PlayerID), 183)
end)

menu.action(BikerMissions, "Drive-by Assassin", {}, "Start this mission.", function(toggle)
	local PlayerID = PLAYER.PLAYER_ID()
	memory.write_int(memory.script_global(StartMissionGlobal + NextIndexGlobal * PlayerID), 193)
end)

menu.action(BikerMissions, "Rippin It Up", {}, "Start this mission.", function(toggle)
	local PlayerID = PLAYER.PLAYER_ID()
	memory.write_int(memory.script_global(StartMissionGlobal + NextIndexGlobal * PlayerID), 194)
end)

menu.action(BikerMissions, "Free Prisoner", {}, "Start this mission.", function(toggle)
	local PlayerID = PLAYER.PLAYER_ID()
	memory.write_int(memory.script_global(StartMissionGlobal + NextIndexGlobal * PlayerID), 197)
end)

menu.action(BikerMissions, "Safe Cracker", {}, "Start this mission.", function(toggle)
	local PlayerID = PLAYER.PLAYER_ID()
	memory.write_int(memory.script_global(StartMissionGlobal + NextIndexGlobal * PlayerID), 198)
end)

menu.action(BikerMissions, "Steal Bikes", {}, "Start this mission.", function(toggle)
	local PlayerID = PLAYER.PLAYER_ID()
	memory.write_int(memory.script_global(StartMissionGlobal + NextIndexGlobal * PlayerID), 195)
end)

menu.action(BikerMissions, "Search And Destroy", {}, "Start this mission.", function(toggle)
	local PlayerID = PLAYER.PLAYER_ID()
	memory.write_int(memory.script_global(StartMissionGlobal + NextIndexGlobal * PlayerID), 199)
end)

menu.action(BikerMissions, "Destroy Vans", {}, "Start this mission.", function(toggle)
	local PlayerID = PLAYER.PLAYER_ID()
	memory.write_int(memory.script_global(StartMissionGlobal + NextIndexGlobal * PlayerID), 207)
end)

menu.action(BikerMissions, "Burn Assets", {}, "Start this mission.", function(toggle)
	local PlayerID = PLAYER.PLAYER_ID()
	memory.write_int(memory.script_global(StartMissionGlobal + NextIndexGlobal * PlayerID), 208)
end)

menu.action(BikerMissions, "Wheelie Rider", {}, "Start this mission.", function(toggle)
	local PlayerID = PLAYER.PLAYER_ID()
	memory.write_int(memory.script_global(StartMissionGlobal + NextIndexGlobal * PlayerID), 210)
end)

local DevMenu = menu.list(menu.my_root(), "DEV Tools", {}, "")

menu.action(DevMenu, "Bypass Law Vehicles", {}, "To spawn cops and SWATS inside different police vehicles", function(toggle)
	local AddrDispatch = memory.scan("8b ? ? ? ? ? 41 8b f1 45 8a d0 c1 e8 1f 40 8a ea 41 84 c4 75")
	if AddrDispatch ~= 0 then
		local AddrTarget = AddrDispatch + 21
		memory.write_byte(AddrTarget, 0xEB)
	end
	local AddrSWATDispatch = memory.scan("74 ? 3b 05 ? ? ? ? 74 ? 3b 05 ? ? ? ? 75 ? ? b0 01")
	if AddrSWATDispatch ~= 0 then
		local AddrTarget = AddrSWATDispatch + 16
		memory.write_byte(AddrTarget, 0x90)
		memory.write_byte(AddrTarget + 1, 0x90)
	end
end)

menu.action(DevMenu, "Get Group Size", {}, "", function(toggle)
	Print(GetPedGroupSize(PLAYER.GET_PLAYER_GROUP(PLAYER.PLAYER_ID())))
end)

menu.action(DevMenu, "Relationship Hash", {}, "", function(toggle)
	local PlayerID = PLAYER.PLAYER_ID()
	local RelTarget = joaat("rgFM_Team"..PlayerID)
	local MyRel = PED.GET_PED_RELATIONSHIP_GROUP_HASH(PLAYER.PLAYER_PED_ID())
	Print(RelTarget .. " MyRel " .. MyRel)
end)

menu.action(DevMenu, "Addr Test", {}, "", function(toggle)
	local Addr = 0x7FF66E4E63F0
	local Addr2 = memory.read_long(Addr)
	local Addr3 = memory.read_long(Addr2+0x08)
	local Addr4 = memory.read_long(Addr3+0xB0)
	local FormatedString = string.format("%02X", Addr4)
	util.copy_to_clipboard(FormatedString)
	Print(FormatedString)
end)

menu.action(DevMenu, "Addr Get", {}, "", function(toggle)
	local Addr = memory.scan("? 89 5c ? ? ? 89 6c ? ? ? 89 74 ? ? 57")
	local FormatedString = string.format("%02X", Addr)
	util.copy_to_clipboard(FormatedString)
	Print(FormatedString)
end)

menu.action(DevMenu, "Rel Test", {}, "", function(toggle)
	local Addr = memory.script_global(SplitGlobals("Global_1837231.f_6"))
	local Value = memory.read_int(Addr)
	local RelHash = PED.GET_PED_RELATIONSHIP_GROUP_HASH(PLAYER.PLAYER_PED_ID())
	local RelBG = PED.GET_RELATIONSHIP_BETWEEN_GROUPS(RelHash, Value)
	Print(RelBG)
end)


function DoesValueExistInTable2(T, Value)
	for index, values in pairs(T) do
		if Value == values.OldVehicle then return true end
	end
	return false
end

function DoesValueExistInTable3(T, Value)
	for index, values in pairs(T) do
		if index == Value then return true end
	end
	return false
end

--Credit to Wiri for these functions
function get_entity_player_is_aiming_at(player)
	if not PLAYER.IS_PLAYER_FREE_AIMING(player) then
		return NULL
	end
	local entity, pEntity = NULL, memory.alloc_int()
	if PLAYER.GET_ENTITY_PLAYER_IS_FREE_AIMING_AT(player, pEntity) then
		entity = memory.read_int(pEntity)
	end
	if entity ~= NULL and ENTITY.IS_ENTITY_A_PED(entity) and PED.IS_PED_IN_ANY_VEHICLE(entity, false) then
		entity = PED.GET_VEHICLE_PED_IS_IN(entity, false)
	end
	return entity
end

function GetPedGroupSize(Group)
	local HasLeader, SizePtr = memory.alloc(1), memory.alloc(1)
	PED.GET_GROUP_SIZE(Group, HasLeader, SizePtr)
	return memory.read_int(SizePtr)
end

---@param entity Entity
function set_entity_as_no_longer_needed(entity)
	if not ENTITY.DOES_ENTITY_EXIST(entity) then return end
	local pHandle = memory.alloc_int()
	memory.write_int(pHandle, entity)
	ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(pHandle)
end

function SetPedCombatAbilities(ped)
	PED.SET_PED_COMBAT_ATTRIBUTES(ped, 5, true)
	PED.SET_PED_COMBAT_ATTRIBUTES(ped, 1, true)
	PED.SET_PED_COMBAT_ATTRIBUTES(ped, 3, true)
	PED.SET_PED_COMBAT_ATTRIBUTES(ped, 13, true)
	PED.SET_PED_COMBAT_ATTRIBUTES(ped, 21, true)
	PED.SET_PED_COMBAT_ATTRIBUTES(ped, 38, true)
	PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true)
	PED.SET_PED_COMBAT_ATTRIBUTES(ped, 443, true)
	--PED.SET_PED_COMBAT_MOVEMENT(ped, 2)
	--PED.SET_PED_COMBAT_ABILITY(ped, 2) 
	PED.SET_PED_COMBAT_RANGE(ped, 2)
	PED.SET_PED_SEEING_RANGE(ped, 900.0)
	PED.SET_PED_TARGET_LOSS_RESPONSE(ped, 1)
	PED.SET_PED_HIGHLY_PERCEPTIVE(ped, true)
	PED.SET_PED_VISUAL_FIELD_PERIPHERAL_RANGE(ped, 400.0)
	PED.SET_COMBAT_FLOAT(ped, 10, 400.0)
end

function Random_Weapon_Components(ped, weaponHash, componentHash, setColor, AlwaysSet)
	if WEAPON.HAS_PED_GOT_WEAPON(ped, weaponHash, false) then
		local randomComponent = math.random(0, 1)
		if AlwaysSet ~= nil then
			if AlwaysSet then
				randomComponent = 1
			end
		end
		if randomComponent == 1 then
			WEAPON.GIVE_WEAPON_COMPONENT_TO_PED(ped, weaponHash, componentHash)
		end
		if setColor then
			WEAPON.SET_PED_WEAPON_TINT_INDEX(ped, weaponHash, math.random(0, 7))
		end
	end
end

function Set_Weapon_Components(ped)
	Random_Weapon_Components(ped, joaat("weapon_appistol"), joaat("COMPONENT_APPISTOL_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_appistol"), joaat("COMPONENT_AT_PI_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_appistol"), joaat("COMPONENT_AT_PI_SUPP"), false)
	Random_Weapon_Components(ped, joaat("weapon_appistol"), joaat("COMPONENT_APPISTOL_VARMOD_SECURITY"), false)

	Random_Weapon_Components(ped, joaat("weapon_pistol50"), joaat("COMPONENT_PISTOL50_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_pistol50"), joaat("COMPONENT_AT_PI_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_pistol50"), joaat("COMPONENT_AT_AR_SUPP_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_pistol50"), joaat("COMPONENT_PISTOL50_VARMOD_LUXE"), false)
	
	Random_Weapon_Components(ped, joaat("weapon_heavypistol"), joaat("COMPONENT_HEAVYPISTOL_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_heavypistol"), joaat("COMPONENT_AT_PI_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_heavypistol"), joaat("COMPONENT_AT_PI_SUPP"), false)
	Random_Weapon_Components(ped, joaat("weapon_heavypistol"), joaat("COMPONENT_HEAVYPISTOL_VARMOD_LUXE"), false)

	Random_Weapon_Components(ped, joaat("weapon_microsmg"), joaat("COMPONENT_MICROSMG_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_microsmg"), joaat("COMPONENT_AT_PI_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_microsmg"), joaat("COMPONENT_AT_SCOPE_MACRO"), false)
	Random_Weapon_Components(ped, joaat("weapon_microsmg"), joaat("COMPONENT_AT_AR_SUPP_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_microsmg"), joaat("COMPONENT_MICROSMG_VARMOD_FRN"), false)

	Random_Weapon_Components(ped, joaat("weapon_combatpdw"), joaat("COMPONENT_COMBATPDW_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_combatpdw"), joaat("COMPONENT_AT_AR_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_combatpdw"), joaat("COMPONENT_AT_AR_AFGRIP"), false)
	Random_Weapon_Components(ped, joaat("weapon_combatpdw"), joaat("COMPONENT_AT_SCOPE_SMALL"), false)

	Random_Weapon_Components(ped, joaat("weapon_machinepistol"), joaat("COMPONENT_MACHINEPISTOL_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_machinepistol"), joaat("COMPONENT_AT_PI_SUPP"), false)

	Random_Weapon_Components(ped, joaat("weapon_minismg"), joaat("COMPONENT_MINISMG_CLIP_02"), true)
	
	Random_Weapon_Components(ped, joaat("weapon_tecpistol"), joaat("COMPONENT_TECPISTOL_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_tecpistol"), joaat("COMPONENT_AT_AR_SUPP_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_tecpistol"), joaat("COMPONENT_AT_SCOPE_MACRO"), false)

	Random_Weapon_Components(ped, joaat("weapon_pumpshotgun"), joaat("COMPONENT_AT_AR_FLSH"), true, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_pumpshotgun"), joaat("COMPONENT_AT_SR_SUPP"), false)
	Random_Weapon_Components(ped, joaat("weapon_pumpshotgun"), joaat("COMPONENT_PUMPSHOTGUN_VARMOD_XM3"), false)

	Random_Weapon_Components(ped, joaat("weapon_combatshotgun"), joaat("COMPONENT_AT_AR_FLSH"), true, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_combatshotgun"), joaat("COMPONENT_AT_AR_SUPP"), false)

	Random_Weapon_Components(ped, joaat("weapon_assaultrifle"), joaat("COMPONENT_ASSAULTRIFLE_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_assaultrifle"), joaat("COMPONENT_ASSAULTRIFLE_CLIP_03"), false)
	Random_Weapon_Components(ped, joaat("weapon_assaultrifle"), joaat("COMPONENT_AT_AR_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_assaultrifle"), joaat("COMPONENT_AT_SCOPE_MACRO"), false)
	Random_Weapon_Components(ped, joaat("weapon_assaultrifle"), joaat("COMPONENT_AT_AR_SUPP_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_assaultrifle"), joaat("COMPONENT_AT_AR_AFGRIP"), false)
	Random_Weapon_Components(ped, joaat("weapon_assaultrifle"), joaat("COMPONENT_ASSAULTRIFLE_VARMOD_LUXE"), false)

	Random_Weapon_Components(ped, joaat("weapon_bullpuprifle"), joaat("COMPONENT_BULLPUPRIFLE_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_bullpuprifle"), joaat("COMPONENT_AT_AR_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_bullpuprifle"), joaat("COMPONENT_AT_SCOPE_SMALL"), false)
	Random_Weapon_Components(ped, joaat("weapon_bullpuprifle"), joaat("COMPONENT_AT_AR_SUPP"), false)
	Random_Weapon_Components(ped, joaat("weapon_bullpuprifle"), joaat("COMPONENT_AT_AR_AFGRIP"), false)
	Random_Weapon_Components(ped, joaat("weapon_bullpuprifle"), joaat("COMPONENT_BULLPUPRIFLE_VARMOD_LOW"), false)

	Random_Weapon_Components(ped, joaat("weapon_bullpuprifle_mk2"), joaat("COMPONENT_AT_SCOPE_MACRO_02_MK2"), true)
	Random_Weapon_Components(ped, joaat("weapon_bullpuprifle_mk2"), joaat("COMPONENT_AT_SCOPE_SMALL_MK2"), false)
	Random_Weapon_Components(ped, joaat("weapon_bullpuprifle_mk2"), joaat("COMPONENT_BULLPUPRIFLE_MK2_CLIP_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_bullpuprifle_mk2"), joaat("COMPONENT_AT_AR_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_bullpuprifle_mk2"), joaat("COMPONENT_AT_SIGHTS"), false)
	Random_Weapon_Components(ped, joaat("weapon_bullpuprifle_mk2"), joaat("COMPONENT_AT_BP_BARREL_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_bullpuprifle_mk2"), joaat("COMPONENT_AT_AR_SUPP"), false)
	Random_Weapon_Components(ped, joaat("weapon_bullpuprifle_mk2"), joaat("COMPONENT_AT_MUZZLE_07"), false)
	Random_Weapon_Components(ped, joaat("weapon_bullpuprifle_mk2"), joaat("COMPONENT_AT_AR_AFGRIP_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_bullpuprifle_mk2"), joaat("COMPONENT_BULLPUPRIFLE_MK2_CAMO"), false)
	Random_Weapon_Components(ped, joaat("weapon_bullpuprifle_mk2"), joaat("COMPONENT_BULLPUPRIFLE_MK2_CAMO_05"), false)

	Random_Weapon_Components(ped, joaat("weapon_compactrifle"), joaat("COMPONENT_COMPACTRIFLE_CLIP_02"), true)

	Random_Weapon_Components(ped, joaat("weapon_heavyrifle"), joaat("COMPONENT_HEAVYRIFLE_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_heavyrifle"), joaat("COMPONENT_HEAVYRIFLE_SIGHT_01"), false)
	Random_Weapon_Components(ped, joaat("weapon_heavyrifle"), joaat("COMPONENT_AT_SCOPE_MEDIUM"), false)
	Random_Weapon_Components(ped, joaat("weapon_heavyrifle"), joaat("COMPONENT_AT_AR_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_heavyrifle"), joaat("COMPONENT_AT_AR_SUPP"), false)
	Random_Weapon_Components(ped, joaat("weapon_heavyrifle"), joaat("COMPONENT_AT_AR_AFGRIP"), false)
	Random_Weapon_Components(ped, joaat("weapon_heavyrifle"), joaat("COMPONENT_HEAVYRIFLE_CAMO1"), false)

	Random_Weapon_Components(ped, joaat("weapon_mg"), joaat("COMPONENT_MG_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_mg"), joaat("COMPONENT_AT_SCOPE_SMALL_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_mg"), joaat("COMPONENT_MG_VARMOD_LOWRIDER"), false)
	
	Random_Weapon_Components(ped, joaat("weapon_sniperrifle"), joaat("COMPONENT_AT_AR_SUPP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_sniperrifle"), joaat("COMPONENT_AT_SCOPE_MAX"), false)
	Random_Weapon_Components(ped, joaat("weapon_sniperrifle"), joaat("COMPONENT_AT_SCOPE_LARGE"), false)
	Random_Weapon_Components(ped, joaat("weapon_sniperrifle"), joaat("COMPONENT_SNIPERRIFLE_VARMOD_LUXE"), false)

	Random_Weapon_Components(ped, joaat("weapon_heavysniper"), joaat("COMPONENT_AT_SCOPE_LARGE"), true)
	Random_Weapon_Components(ped, joaat("weapon_heavysniper"), joaat("COMPONENT_AT_SCOPE_MAX"), false)

	Random_Weapon_Components(ped, joaat("weapon_marksmanrifle"), joaat("COMPONENT_MARKSMANRIFLE_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_marksmanrifle"), joaat("COMPONENT_AT_AR_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_marksmanrifle"), joaat("COMPONENT_AT_SCOPE_LARGE_FIXED_ZOOM"), false)
	Random_Weapon_Components(ped, joaat("weapon_marksmanrifle"), joaat("COMPONENT_AT_AR_SUPP"), false)
	Random_Weapon_Components(ped, joaat("weapon_marksmanrifle"), joaat("COMPONENT_AT_AR_AFGRIP"), false)
	Random_Weapon_Components(ped, joaat("weapon_marksmanrifle"), joaat("COMPONENT_MARKSMANRIFLE_VARMOD_LUXE"), false)

	Random_Weapon_Components(ped, joaat("weapon_marksmanrifle_mk2"), joaat("COMPONENT_MARKSMANRIFLE_MK2_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_marksmanrifle_mk2"), joaat("COMPONENT_AT_AR_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_marksmanrifle_mk2"), joaat("COMPONENT_AT_SCOPE_LARGE_FIXED_ZOOM_MK2"), false)
	Random_Weapon_Components(ped, joaat("weapon_marksmanrifle_mk2"), joaat("COMPONENT_AT_SIGHTS"), false)
	Random_Weapon_Components(ped, joaat("weapon_marksmanrifle_mk2"), joaat("COMPONENT_AT_AR_SUPP"), false)
	Random_Weapon_Components(ped, joaat("weapon_marksmanrifle_mk2"), joaat("COMPONENT_AT_MUZZLE_07"), false)
	Random_Weapon_Components(ped, joaat("weapon_marksmanrifle_mk2"), joaat("COMPONENT_AT_AR_AFGRIP_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_marksmanrifle_mk2"), joaat("COMPONENT_AT_MRFL_BARREL_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_marksmanrifle_mk2"), joaat("COMPONENT_MARKSMANRIFLE_MK2_CAMO"), false)
	Random_Weapon_Components(ped, joaat("weapon_marksmanrifle_mk2"), joaat("COMPONENT_MARKSMANRIFLE_MK2_CAMO_07"), false)

	Random_Weapon_Components(ped, joaat("weapon_tacticalrifle"), joaat("COMPONENT_AT_AR_FLSH_REH"), true, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_tacticalrifle"), joaat("COMPONENT_TACTICALRIFLE_CLIP_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_tacticalrifle"), joaat("COMPONENT_AT_AR_SUPP_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_tacticalrifle"), joaat("COMPONENT_AT_AR_AFGRIP"), false)

	Random_Weapon_Components(ped, joaat("weapon_smg"), joaat("COMPONENT_SMG_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_smg"), joaat("COMPONENT_AT_AR_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_smg"), joaat("COMPONENT_AT_SCOPE_MACRO"), false)

	Random_Weapon_Components(ped, joaat("weapon_assaultsmg"), joaat("COMPONENT_ASSAULTSMG_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_assaultsmg"), joaat("COMPONENT_AT_AR_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_assaultsmg"), joaat("COMPONENT_AT_SCOPE_MACRO"), false)
	Random_Weapon_Components(ped, joaat("weapon_assaultsmg"), joaat("COMPONENT_AT_AR_SUPP_02"), false)

	Random_Weapon_Components(ped, joaat("weapon_assaultshotgun"), joaat("COMPONENT_ASSAULTSHOTGUN_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_assaultshotgun"), joaat("COMPONENT_AT_AR_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_assaultshotgun"), joaat("COMPONENT_AT_AR_SUPP"), false)
	Random_Weapon_Components(ped, joaat("weapon_assaultshotgun"), joaat("COMPONENT_AT_AR_AFGRIP"), false)

	Random_Weapon_Components(ped, joaat("weapon_carbinerifle"), joaat("COMPONENT_CARBINERIFLE_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_carbinerifle"), joaat("COMPONENT_AT_AR_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_carbinerifle"), joaat("COMPONENT_AT_RAILCOVER_01"), false)
	Random_Weapon_Components(ped, joaat("weapon_carbinerifle"), joaat("COMPONENT_AT_SCOPE_MEDIUM"), false)
	Random_Weapon_Components(ped, joaat("weapon_carbinerifle"), joaat("COMPONENT_AT_AR_SUPP"), false)
	Random_Weapon_Components(ped, joaat("weapon_carbinerifle"), joaat("COMPONENT_AT_AR_AFGRIP"), false)

	Random_Weapon_Components(ped, joaat("weapon_carbinerifle_mk2"), joaat("COMPONENT_CARBINERIFLE_MK2_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_carbinerifle_mk2"), joaat("COMPONENT_AT_AR_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_carbinerifle_mk2"), joaat("COMPONENT_AT_SIGHTS"), false)
	Random_Weapon_Components(ped, joaat("weapon_carbinerifle_mk2"), joaat("COMPONENT_AT_MUZZLE_07"), false)
	Random_Weapon_Components(ped, joaat("weapon_carbinerifle_mk2"), joaat("COMPONENT_AT_AR_SUPP"), false)
	Random_Weapon_Components(ped, joaat("weapon_carbinerifle_mk2"), joaat("COMPONENT_AT_CR_BARREL_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_carbinerifle_mk2"), joaat("COMPONENT_CARBINERIFLE_MK2_CAMO"), false)

	Random_Weapon_Components(ped, joaat("weapon_combatmg"), joaat("COMPONENT_COMBATMG_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_combatmg"), joaat("COMPONENT_AT_SCOPE_MEDIUM"), false)
	Random_Weapon_Components(ped, joaat("weapon_combatmg"), joaat("COMPONENT_AT_AR_AFGRIP"), false)

	Random_Weapon_Components(ped, joaat("weapon_combatmg_mk2"), joaat("COMPONENT_COMBATMG_MK2_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_combatmg_mk2"), joaat("COMPONENT_AT_SCOPE_SMALL_MK2"), false)
	Random_Weapon_Components(ped, joaat("weapon_combatmg_mk2"), joaat("COMPONENT_AT_MUZZLE_07"), false)
	Random_Weapon_Components(ped, joaat("weapon_combatmg_mk2"), joaat("COMPONENT_AT_AR_AFGRIP_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_combatmg_mk2"), joaat("COMPONENT_AT_MG_BARREL_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_combatmg_mk2"), joaat("COMPONENT_COMBATMG_MK2_CAMO"), false)

	Random_Weapon_Components(ped, joaat("weapon_specialcarbine_mk2"), joaat("COMPONENT_SPECIALCARBINE_MK2_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_specialcarbine_mk2"), joaat("COMPONENT_AT_AR_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_specialcarbine_mk2"), joaat("COMPONENT_AT_SCOPE_MEDIUM_MK2"), false)
	Random_Weapon_Components(ped, joaat("weapon_specialcarbine_mk2"), joaat("COMPONENT_AT_MUZZLE_07"), false)
	Random_Weapon_Components(ped, joaat("weapon_specialcarbine_mk2"), joaat("COMPONENT_AT_AR_AFGRIP_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_specialcarbine_mk2"), joaat("COMPONENT_AT_SC_BARREL_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_specialcarbine_mk2"), joaat("COMPONENT_SPECIALCARBINE_MK2_CAMO_04"), false)

	Random_Weapon_Components(ped, joaat("weapon_pumpshotgun_mk2"), joaat("COMPONENT_PUMPSHOTGUN_MK2_CLIP_EXPLOSIVE"), true)
	Random_Weapon_Components(ped, joaat("weapon_pumpshotgun_mk2"), joaat("COMPONENT_AT_SCOPE_SMALL_MK2"), false)
	Random_Weapon_Components(ped, joaat("weapon_pumpshotgun_mk2"), joaat("COMPONENT_AT_AR_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_pumpshotgun_mk2"), joaat("COMPONENT_AT_SR_SUPP_03"), false)
	Random_Weapon_Components(ped, joaat("weapon_pumpshotgun_mk2"), joaat("COMPONENT_AT_MUZZLE_08"), false)
	Random_Weapon_Components(ped, joaat("weapon_pumpshotgun_mk2"), joaat("COMPONENT_PUMPSHOTGUN_MK2_CAMO_02"), false)

	Random_Weapon_Components(ped, joaat("weapon_smg_mk2"), joaat("COMPONENT_SMG_MK2_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_smg_mk2"), joaat("COMPONENT_AT_AR_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_smg_mk2"), joaat("COMPONENT_AT_SIGHTS_SMG"), false)
	Random_Weapon_Components(ped, joaat("weapon_smg_mk2"), joaat("COMPONENT_AT_PI_SUPP"), false)
	Random_Weapon_Components(ped, joaat("weapon_smg_mk2"), joaat("COMPONENT_AT_MUZZLE_03"), false)
	Random_Weapon_Components(ped, joaat("weapon_smg_mk2"), joaat("COMPONENT_AT_SB_BARREL_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_smg_mk2"), joaat("COMPONENT_SMG_MK2_CAMO_03"), false)

	Random_Weapon_Components(ped, joaat("weapon_assaultrifle_mk2"), joaat("COMPONENT_ASSAULTRIFLE_MK2_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_assaultrifle_mk2"), joaat("COMPONENT_AT_AR_AFGRIP_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_assaultrifle_mk2"), joaat("COMPONENT_AT_AR_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_assaultrifle_mk2"), joaat("COMPONENT_AT_SIGHTS"), false)
	Random_Weapon_Components(ped, joaat("weapon_assaultrifle_mk2"), joaat("COMPONENT_AT_MUZZLE_03"), false)
	Random_Weapon_Components(ped, joaat("weapon_assaultrifle_mk2"), joaat("COMPONENT_AT_AR_BARREL_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_assaultrifle_mk2"), joaat("COMPONENT_ASSAULTRIFLE_MK2_CAMO"), false)

	Random_Weapon_Components(ped, joaat("weapon_militaryrifle"), joaat("COMPONENT_MILITARYRIFLE_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_militaryrifle"), joaat("COMPONENT_AT_AR_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_militaryrifle"), joaat("COMPONENT_MILITARYRIFLE_SIGHT_01"), false)
	Random_Weapon_Components(ped, joaat("weapon_militaryrifle"), joaat("COMPONENT_AT_AR_SUPP"), false)

	Random_Weapon_Components(ped, joaat("weapon_specialcarbine"), joaat("COMPONENT_SPECIALCARBINE_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_specialcarbine"), joaat("COMPONENT_AT_AR_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_specialcarbine"), joaat("COMPONENT_AT_SCOPE_MEDIUM"), false)
	Random_Weapon_Components(ped, joaat("weapon_specialcarbine"), joaat("COMPONENT_AT_AR_SUPP_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_specialcarbine"), joaat("COMPONENT_AT_AR_AFGRIP"), false)

	Random_Weapon_Components(ped, joaat("weapon_heavyshotgun"), joaat("COMPONENT_HEAVYSHOTGUN_CLIP_03"), true)
	Random_Weapon_Components(ped, joaat("weapon_heavyshotgun"), joaat("COMPONENT_AT_AR_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_heavyshotgun"), joaat("COMPONENT_AT_AR_SUPP_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_heavyshotgun"), joaat("COMPONENT_AT_AR_AFGRIP"), false)

	Random_Weapon_Components(ped, joaat("weapon_heavysniper_mk2"), joaat("COMPONENT_HEAVYSNIPER_MK2_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_heavysniper_mk2"), joaat("COMPONENT_AT_SCOPE_MAX"), false)
	Random_Weapon_Components(ped, joaat("weapon_heavysniper_mk2"), joaat("COMPONENT_AT_SR_SUPP_03"), false)
	Random_Weapon_Components(ped, joaat("weapon_heavysniper_mk2"), joaat("COMPONENT_AT_SR_BARREL_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_heavysniper_mk2"), joaat("COMPONENT_HEAVYSNIPER_MK2_CAMO_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_heavysniper_mk2"), joaat("COMPONENT_HEAVYSNIPER_MK2_CAMO_03"), false)

	Random_Weapon_Components(ped, joaat("weapon_gusenberg"), joaat("COMPONENT_GUSENBERG_CLIP_02"), true)

	Random_Weapon_Components(ped, joaat("weapon_pistol"), joaat("COMPONENT_PISTOL_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_pistol"), joaat("COMPONENT_AT_PI_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_pistol"), joaat("COMPONENT_AT_PI_SUPP_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_pistol"), joaat("COMPONENT_PISTOL_VARMOD_LUXE"), false)
end

---@param entity Entity
---@return integer address
function get_net_obj(entity)
	local pEntity = entities.handle_to_pointer(entity)
	return pEntity ~= NULL and memory.read_long(pEntity + 0xD0) or NULL
end


---@param entity Entity
---@return Player owner
function get_entity_owner(entity)
	local net_obj = get_net_obj(entity)
	return net_obj ~= NULL and memory.read_byte(net_obj + 0x49) or -1
end

function find_right_spawn_vehicle(posX, posY, posZ, minDist, maxDist)
	local outpos = v3.new()
	local outheading = memory.alloc(4)
	local foundCoord = PATHFIND.GET_CLOSEST_VEHICLE_NODE_WITH_HEADING(posX + (math.random() < 0.5 and math.random(-maxDist, -minDist) or math.random(minDist, maxDist)), posY + (math.random() < 0.5 and math.random(-maxDist, -minDist) or math.random(minDist, maxDist)), posZ, outpos, outheading, 0, 3, 0)
	return outpos, memory.read_float(outheading), foundCoord
end

function find_right_spawn_normal(posX, posY, posZ, minDist, maxDist)
	local outpos = v3.new()
	local foundCoord = PATHFIND.GET_SAFE_COORD_FOR_PED(posX + (math.random() < 0.5 and math.random(-maxDist, -minDist) or math.random(minDist, maxDist)), posY + (math.random() < 0.5 and math.random(-maxDist, -minDist) or math.random(minDist, maxDist)), posZ, false, outpos, 16)
	return outpos, foundCoord
end

function SetPedHealth(ped, Health)
	PED.SET_PED_MAX_HEALTH(ped, Health)
	ENTITY.SET_ENTITY_MAX_HEALTH(ped, Health)
	ENTITY.SET_ENTITY_HEALTH(ped, Health)
end

util.on_stop(function()
	if CanSetModels then
		for i = 1, #police3_Addrs do
			memory.write_int(police3_Addrs[i], joaat("police3"))
		end
		for i = 1, #sheriff_Addrs do
			memory.write_int(sheriff_Addrs[i], joaat("sheriff"))
		end
		for i = 1, #polmav_Addrs do
			memory.write_int(polmav_Addrs[i], joaat("polmav"))
		end
		for i = 1, #sheriff2_Addrs do
			memory.write_int(sheriff2_Addrs[i], joaat("sheriff2"))
		end
		for i = 1, #fbi2_Addrs do
			memory.write_int(fbi2_Addrs[i], joaat("fbi2"))
		end
		for i = 1, #predator_Addrs do
			memory.write_int(predator_Addrs[i], joaat("predator"))
		end
		for i = 1, #copped_Addrs do
			memory.write_int(copped_Addrs[i], joaat("s_m_y_cop_01"))
		end
		for i = 1, #sheriffped_Addrs do
			memory.write_int(sheriffped_Addrs[i], joaat("s_m_y_sheriff_01"))
		end
		for i = 1, #swatped_Addrs do
			memory.write_int(swatped_Addrs[i], joaat("s_m_y_swat_01"))
		end
	end
end)

local VehicleModelsRandom = {
	"polmav",
	"savage",
	"annihilator",
	"valkyrie",
	"hunter",
	"buzzard",
	"khanjali",
	"rhino",
	"dune3",
	"caracara",
	"speedo4",
	"squaddie",
	"winky",
	"elegy",
	"elegy2",
	"caracara2",
	"tampa3",
	"nightshark",
	"technical3",
	"technical",
	"sultan2",
	"infernus2",
	"rcbandito",
	"insurgent3",
	"riata",
	"mesa3",
	"bruiser",
	"bruiser2",
	"bruiser3",
	"barrage",
	"apc",
	"cargobob",
	"cargobob2",
	"akula",
	"seasparrow"
}

function SetRandomModels()
	local RandomPolice3 = VehicleModelsRandom[math.random(#VehicleModelsRandom)]
	local RandomSheriff = VehicleModelsRandom[math.random(#VehicleModelsRandom)]
	local RandomPolmav = VehicleModelsRandom[math.random(#VehicleModelsRandom)]
	local RandomSheriff2 = VehicleModelsRandom[math.random(#VehicleModelsRandom)]
	local RandomFBI2 = VehicleModelsRandom[math.random(#VehicleModelsRandom)]
	local RandomCopPed = PedModels[math.random(#PedModels)]
	local RandomSheriffPed = PedModels[math.random(#PedModels)]
	local RandomSWATPed = PedModels[math.random(#PedModels)]
	for i = 1, #police3_Addrs do
		memory.write_int(police3_Addrs[i], joaat(RandomPolice3))
	end
	for i = 1, #sheriff_Addrs do
		memory.write_int(sheriff_Addrs[i], joaat(RandomSheriff))
	end
	for i = 1, #polmav_Addrs do
		memory.write_int(polmav_Addrs[i], joaat(RandomPolmav))
	end
	for i = 1, #sheriff2_Addrs do
		memory.write_int(sheriff2_Addrs[i], joaat(RandomSheriff2))
	end
	for i = 1, #fbi2_Addrs do
		memory.write_int(fbi2_Addrs[i], joaat(RandomFBI2))
	end
	for i = 1, #copped_Addrs do
		memory.write_int(copped_Addrs[i], joaat(RandomCopPed))
	end
	for i = 1, #sheriffped_Addrs do
		memory.write_int(sheriffped_Addrs[i], joaat(RandomSheriffPed))
	end
	for i = 1, #swatped_Addrs do
		memory.write_int(swatped_Addrs[i], joaat(RandomSWATPed))
	end
	SelectedPedModels[1] = RandomCopPed
	SelectedPedModels[2] = RandomSheriffPed
	SelectedPedModels[3] = RandomSWATPed
end

function SetPedRandomOutfit(Ped)
	for i = 1, 11 do
		local Drawables = PED.GET_NUMBER_OF_PED_DRAWABLE_VARIATIONS(Ped, i)
		if Drawables > 0 then
			Drawables = Drawables - 1
			local RandomDrawable = math.random(0, Drawables)
			local Textures = PED.GET_NUMBER_OF_PED_TEXTURE_VARIATIONS(Ped, i, RandomDrawable)
			if Textures > 0 then
				Textures = Textures-1
				local RandomTexture = math.random(0, Textures)
				if PED.IS_PED_COMPONENT_VARIATION_VALID(Ped, i, RandomDrawable, RandomTexture) then
					PED.SET_PED_COMPONENT_VARIATION(Ped, i, RandomDrawable, RandomTexture, -1)
				end
			end
		end
	end
	for i = 0, 8 do
		local Drawables = PED.GET_NUMBER_OF_PED_PROP_DRAWABLE_VARIATIONS(Ped, i)
		if Drawables > 0 then
			Drawables = Drawables - 1
			local RandomDrawable = math.random(0, Drawables)
			local Textures = PED.GET_NUMBER_OF_PED_PROP_TEXTURE_VARIATIONS(Ped, i, RandomDrawable)
			if Textures > 0 then
				Textures = Textures-1
				PED.SET_PED_PROP_INDEX(Ped, i, RandomDrawable, math.random(0, Textures), false)
			end
		end
	end
end

util.create_tick_handler(function()
	return true
end)
