--Author Manaleaf - Sargeras
--Initializing Vars for Leaflet

--[[SCENARIO_CRITERIA_UPDATE
	PLAYER_ENTERING_WORLD
	WORLD_STATE_TIMER_START
	WORLD_STATE_TIMER_STOP
	CHALLENGE_MODE_START
	CHALLENGE_MODE_RESET
]]
LFLT_A = {}
function LFLT_A.startup(self, event, addon)
	if addon == "Leaflet" then
		LFLT_A.Init()
		LFLT_A.GUI()
		LFLT_A.Calc()
		LFLT_A.Replay()
		LFLT_A.EventHandler()
	end
end
--addon startup
local startupFrame = CreateFrame("FRAME")
startupFrame:RegisterEvent("ADDON_LOADED")
startupFrame:SetScript("OnEvent", LFLT_A.startup)


local function reset(curVersion)
	LFLT={version = curVersion}
	C_Timer.After(5, function() print("Leaflet: This version update has Reset your Settings and history"
		.. "\nNot all Versions Updates will do this.") end)
end

function LFLT_A.Init()
	--Core Addon Saved Variable
	LFLT = LFLT or {}
	--Version
	local curVersion = "A0.05"
	LFLT.version = LFLT.version or curVersion
	if LFLT.version ~= curVersion then
		LFLT.version = curVersion
		reset(curVersion)
	end
	--Frame Objects
	LFLT_F = {}
	--Temporary Vars
	LFLT_T = {}
	--Debug: Var Printer
	LFLT_T.printTable = {}
	--Initialized Vars
	LFLT.version = LFLT.version or 1.0
	LFLT.history = LFLT.history or {}
	LFLT_T.historyPage = 1
	LFLT_T.historyEntryNum = #LFLT.history or 0 --Pay attention to this, make sure it auto updates per session.
	LFLT.historyEntryNumMax = LFLT.historyEntryNumMax or 1000
	LFLT_T.displayUpdaterActive = false
	LFLT.activeWindowCode = LFLT.activeWindowCode or 1
	LFLT.dungeonInfo = LFLT.dungeonInfo or {}
	LFLT.hasteCompositeRatio = LFLT.hasteCompositeRatio or 0 
	LFLT.session = LFLT.session or "none"
	LFLT.sessionRecords = LFLT.sessionRecords or {}
	
	LFLT_T.activeTransition = false
	LFLT_T.recordsInTransition = {}
	LFLT_T.playerLoggingIn = true 
	LFLT_T.score = LFLT_T.score or {}
	LFLT_T.backup = {}
	LFLT_T.manualOverride = {}
	LFLT_T.popupMessageFunctions = {}
	LFLT_T.manualOverride.hotCounter 	= nil
	LFLT_T.manualOverride.getUnit		= nil
	LFLT_T.manualOverride.recordInsert	= nil
	LFLT_T.manualOverride.updateDisplay = nil
	LFLT_T.entryWaitingOnGameLoad 		= nil
	LFLT_T.replayInProgress				= false
	LFLT_T.leechHaste = {}
	LFLT_T.modifierState = {}
	LFLT_T.curSelectedHistoryButton = {}
	LFLT_T.lastSelectedHistoryButton = nil
	LFLT.encStartTimer = LFLT.encStartTimer or GetTime()
	LFLT_T.talentRows = GetMaxTalentTier()
	LFLT_T.talentCols = 3
	LFLT_T.oncePerSessionAlert = {
		hideDisplayIcon = false
	}
	LFLT_T.MSTRATINGCONV = 66666.66666
	LFLT_T.CRTRATINGCONV = 40000
	LFLT_T.VRSRATINGCONV = 47500
	LFLT_T.HSTRATINGCONV = 37500
	LFLT_T.HSTRATINGCONVSPCVAL = 703125000 --Special Haste Rating Conversion Shortcut Value (HSTRATINGCONV * (HSTRATINGCONV/2))
	LFLT_T.LCHRATINGCONV = 23000		
	LFLT_T.LIVINGSEEDTRAITID = 131
	LFLT_T.REGROWTHBASECRT = 0.4
	LFLT_T.LIVINGSEEDBASEPERCENT = 0.25
	LFLT_T.hotList = 
	{	
		774,    --Rejuvenation 
		155777, --Germination
		33763,  --Lifebloom
		8936,   --Regrowth
		48438,  --Wild Growth
		207386, --Spring Blossoms
		200389, --Cultivation
		102352	--Cenarion Ward
	}     
	LFLT_T.WEAPONITEMSLOT = 16
	LFLT_T.RESTODRUIDARTIFACTWEAPONID = 128306
	--GUI Initial Values
	--Constants
	LFLT_T.vixarFont = "interface\\addons\\Leaflet\\Font\\vixar.TTF"
	LFLT_T.dateFormatExamples = {[1] = "M-D-Y", [2] = "D-M-Y", [3] = "Y-M-D"}
	LFLT_T.dungeonDifficultyNumber = {
	[1] = "Normal\nDungeon", 
	[2] = "Heroic\nDungeon", 
	[23] = "Mythic\nDungeon", 
	[8] = "Mythic\nDungeon", 
	[14] = "Normal\nRaid", 
	[15] = "Heroic\nRaid", 
	[16] = "Mythic\nRaid"
	}
	--Popup messages  
	LFLT_T.popupMsg = {
	["relicmissing"] = 	"WARNING:\nLeaflet has detected that one of your relic slots is empty."
						.. "\nYour game client may not have finished loading item tooltips."
						.. "\nIf your weapon is not missing a relic slot." 
						.. "\nPlease cancel thew replay and try again in a moment."
						.. "\n\nWhat would you like to do?",
	["replayparsefailed"] = "Unable to Parse Stats for Replay, please try again in a moment."
	}
	
	--Options
	LFLT.option = LFLT.option or {}
	LFLT.option.displayToggle = LFLT.option.displayToggle or true
	LFLT.option.configToggle = LFLT.option.configToggle or false	
	LFLT.option.lock = LFLT.option.lock or false	
	LFLT.option.timeFormat = LFLT.option.timeFormat or 0
	LFLT.option.ignoreTranquilityEnable = LFLT.option.ignoreTranquilityEnable or true
	
	--Positions
	LFLT.option.displayPos = {}
	LFLT.option.displayPos.pointOnFrame 	= LFLT.option.displayPos.pointOnFrame 	or "CENTER"
	LFLT.option.displayPos.parent 			= LFLT.option.displayPos.parent 		or "UIParent"
	LFLT.option.displayPos.pointOnParent 	= LFLT.option.displayPos.pointOnParent 	or "CENTER"
	LFLT.option.displayPos.displayXPos 		= LFLT.option.displayPos.displayXPos 	or 0
	LFLT.option.displayPos.displayYPos 		= LFLT.option.displayPos.displayYPos 	or 0
	
	LFLT.option.displayScale = LFLT.option.displayScale or 1
	LFLT.option.hideIcon = LFLT.option.hideIcon or false
	LFLT.option.displayOrientation = LFLT.option.displayOrientation or  "Horizontal"
	LFLT.option.displayPrecision = LFLT.option.displayPrecision or 2
	LFLT.option.dateFormat = LFLT.dateFormat or 1
	LFLT.option.historyScrollWheelEnabled = LFLT.option.historyScrollWheelEnabled or true
	--States
	LFLT_T.inCombat = false
	LFLT.enabled = LFLT.enabled or 
		{
			raid = {
				id = "Raid", 
				name = "Raid", 
				enabled = true
			},
			mythicdungeon = {
					id = "Mythic_Dungeon", 
					name = "Mythic Dungeons", 
					enabled = true
			},
			dungeonnonmythic = {
				id = "Dungeon_Nonmythic", 
				name = "Dungeon (non-mythic)", 
				enabled = false
			},
			incombat = {
				id = "In_Combat", 
				name = "In Combat", 
				enabled = true
			},
			outofcombat = {
				id = "Out_Of_Combat", 
				name = "Out of Combat", 
				enabled = true
			},
			bossencounter = {
				id = "Boss_Encounter", 
				name = "Raid Encounter", 
				enabled = true
			}	
		}
	LFLT.enabledSearch = LFLT.enabledSearch or 
		{
			kill = {
				id = "Kill",
				name = "Kill",
				enabled = false
			},
			wipe = {
				id = "Wipe",
				name = "Wipe",
				enabled = false
			},
			raid  = {
				id = "Raid",
				name =  "Raid",
				enabled = false
			},
			mythicdungeon = {
				id = "Mythic_Dungeon", 
				name = "Mythic Dungeon",
				enabled = false
			},
			dungeonnonmythic = {
				id = "Dungeon_Nonmythic",
				name = "Dungeon (non-mythic)", 
				enabled = false
			}
		
		}
	LFLT.enabledHaste = --LFLT.enabledHaste or 
		{
			cast = {
				id = "Haste_Cast",
				name = "Haste[Cast]",
				enabled = true
			},
			casttime = {
				id = "Haste_Time",
				name = "Haste[CastTime]",
				enabled = true
			},			
		}
	--output values
	LFLT_T.score.cur_int_hpc = 0
	LFLT_T.score.cur_int_hpt = 0
	LFLT_T.score.cur_mst_hpc = 0
	LFLT_T.score.cur_mst_hpt = 0
	LFLT_T.score.cur_hst_hpc = 0
	LFLT_T.score.cur_hst_hpt = 0
	LFLT_T.score.cur_crt_hpc = 0
	LFLT_T.score.cur_crt_hpt = 0
	LFLT_T.score.cur_vrs_hpc = 0
	LFLT_T.score.cur_vrs_hpt = 0
	LFLT_T.score.cur_lch_hpc = 0
	LFLT_T.score.cur_lch_hpt = 0
	LFLT_T.score.ttl_int_hpc = 0
	LFLT_T.score.ttl_int_hpt = 0
	LFLT_T.score.ttl_mst_hpc = 0
	LFLT_T.score.ttl_mst_hpt = 0
	LFLT_T.score.ttl_hst_hpc = 0
	LFLT_T.score.ttl_hst_hpt = 0
	LFLT_T.score.ttl_crt_hpc = 0
	LFLT_T.score.ttl_crt_hpt = 0
	LFLT_T.score.ttl_vrs_hpc = 0
	LFLT_T.score.ttl_vrs_hpt = 0
	LFLT_T.score.ttl_lch_hpc = 0
	LFLT_T.score.ttl_lch_hpt = 0
	
	--score backup
	LFLT_T.backup.cur_int_hpc = 0
	LFLT_T.backup.cur_int_hpt = 0
	LFLT_T.backup.cur_mst_hpc = 0
	LFLT_T.backup.cur_mst_hpt = 0
	LFLT_T.backup.cur_hst_hpc = 0
	LFLT_T.backup.cur_hst_hpt = 0
	LFLT_T.backup.cur_crt_hpc = 0
	LFLT_T.backup.cur_crt_hpt = 0
	LFLT_T.backup.cur_vrs_hpc = 0
	LFLT_T.backup.cur_vrs_hpt = 0
	LFLT_T.backup.cur_lch_hpc = 0
	LFLT_T.backup.cur_lch_hpt = 0
	LFLT_T.backup.ttl_int_hpc = 0
	LFLT_T.backup.ttl_int_hpt = 0
	LFLT_T.backup.ttl_mst_hpc = 0
	LFLT_T.backup.ttl_mst_hpt = 0
	LFLT_T.backup.ttl_hst_hpc = 0
	LFLT_T.backup.ttl_hst_hpt = 0
	LFLT_T.backup.ttl_crt_hpc = 0
	LFLT_T.backup.ttl_crt_hpt = 0
	LFLT_T.backup.ttl_vrs_hpc = 0
	LFLT_T.backup.ttl_vrs_hpt = 0
	LFLT_T.backup.ttl_lch_hpc = 0
	LFLT_T.backup.ttl_lch_hpt = 0

	--Setting spell names for all client versions.
	LFLT_T.spells = {
	["rejuvenation"] 	= select(1, GetSpellInfo(774)),
	["germination"] 	= select(1, GetSpellInfo(155777)),
	["lifebloom"]      	= select(1, GetSpellInfo(33763)),
	["regrowth"]       	= select(1, GetSpellInfo(8936)),
	["wildgrowth"]     	= select(1, GetSpellInfo(48438)),
	["springblossoms"] 	= select(1, GetSpellInfo(207386)),
	["cultivation"]    	= select(1, GetSpellInfo(200389)),
	["cenarionward"]   	= select(1, GetSpellInfo(102352)),
	["efflorescence"]  	= select(1, GetSpellInfo(145205)),
	["livingseed"]     	= select(1, GetSpellInfo(48500)),
	["swiftmend"]      	= select(1, GetSpellInfo(18562)),
	["healingtouch"]	= select(1, GetSpellInfo(5185)),
	["tranquility"]		= select(1, GetSpellInfo(740)),
	["dreamwalker"] 	= select(1, GetSpellInfo(189853)),
	["renewal"]			= select(1, GetSpellInfo(108238)),
	["leech"]			= select(1, GetSpellInfo(143924)),
	}
	
	LFLT_T.mstPerc = GetMasteryEffect() / 100--GetCombatRatingBonus(26) / 100 * hCount  
	LFLT_T.hstPerc = UnitSpellHaste("player") / 100
	LFLT_T.crtPerc = GetCritChance() / 100
	LFLT_T.vrsPerc = (GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)) / 100
	LFLT_T.intellect = GetSpellBonusDamage(4)
	
	--Crit Effect Mulitplier
	LFLT_T.critBonusOutput = 1		
	--Crit Effect Multiplier (from states that cannot be changed during play session
	LFLT_T.baseCritBonusOutput = 1
	LFLT_T.intArmorBonus = 1

	--Racial Stats
	LFLT_T.baseInt = 0
	LFLT_T.baseIntByRace = {
		worgen = 7328,
		tauren = 7326,
		nightelf = 7325,
		troll = 7324,
	}
	LFLT_T.baseInt = LFLT_T.baseIntByRace[string.lower(select(2, UnitRace("player")))]
	if string.lower(select(2, UnitRace("player"))) == "tauren" then
		LFLT_T.baseCritBonusOutput = LFLT_T.baseCritBonusOutput * (1.02)
	end
	
	--LFLT.talentInfo table population
	LFLT.talentInfo = {} 
	for i = 1, GetMaxTalentTier() do
		local k = 1
		while true do
			local _, name, texture, _ = GetTalentInfo(i,k,1)
			if not name then
				k = 0
				break
			end
			tinsert(LFLT.talentInfo, {["name"] = name, ["texture"] = texture})
			k = k + 1
		end
	end
	
	--[[
	Pads right side of string with third parameter. Character will have a total output length of 
	@param str - Source String
	@param len - Length of outputted string 
	@param char - Character to pad right side of string with. 
	]]
	function LFLT_T.rpad(str, len, char)
		if not char then char = ' ' end
		local outStr
		if type(str) ~= "string" then outStr = tostring(str) 
		else outStr = str end
		return outStr .. string.rep(char, len - #outStr)
	end
	
	--[[
	Pads left side of string with third parameter. Character will have a total output length of 
	@param str - Source String
	@param len - Length of outputted string 
	@param char - Character to pad right side of string with. 
	]]
	function LFLT_T.lpad(str, len, char)
		if not char then char = ' ' end
		local outStr
		if type(str) ~= "string" then outStr = tostring(str) 
		else outStr = str end
		return string.rep(char, len - #outStr) .. outStr
	end
	
	--Accessor Methods
	--Takes Dungeon Type ID number and returns dungeon type as string.
	function LFLT_T.getDungeonType(dID)
		if dID then
			local found = false
			local typeName
			for k,v in pairs(LFLT_T.dungeonDifficultyNumber) do
				if dID == k then
					found = true
					typeName = v 
					break;
				end
			end
			if found then 
				return typeName
			end
		end
		return "Unknown"
	end
	
	--Takes date table and returns date string.
	function LFLT_T.getDateFormat(curDate)
		if LFLT.dateFormat == 1 then 
			--"M-D-Y"
			return string.format("%s-%s-%s", LFLT_T.lpad(curDate.month,2,0), LFLT_T.lpad(curDate.day,2,0), curDate.year)
		elseif LFLT.dateFormat == 2 then 
			--"D-M-Y"
			return string.format("%s-%s-%s", LFLT_T.lpad(curDate.day,2,0), LFLT_T.lpad(curDate.month,2,0), curDate.year)
		end
		--"Y-M-D"
		return string.format("%s-%s-%s", curDate.year, LFLT_T.lpad(curDate.month,2,0), LFLT_T.lpad(curDate.day,2,0))
	end
	--Debug printer
	--All parameters passed to this function within 5 seconds of the original call 
	---will be printed in the order they were passed to this function.
	function LFLT_T.print(...)
		if #LFLT_T.printTable == 0 then
			C_Timer.After(5, function() 
				for k,v in ipairs(LFLT_T.printTable) do
					print(k, v)
				end
				LFLT_T.printTable = {}
			end)
		end
		local printTableElement = ""
		local argument
		for i=1,select("#", ...) do
			argument,_ = select(i, ...)
			tinsert(LFLT_T.printTable, argument)
			--printTableElement = printTableElement .. " " .. tostring(argument)
		end
		
	end

	--Function finds the lowest non-negative value in arguments
	function LFLT.maxButNotZero(...) 
		local i = 1
		local selected
		local maxVal,newNum 
		while(1) do
			newNum = select(i, ...)
			if newNum then
				if not maxVal or newNum > maxVal then 
					maxVal = newNum 
					selected = i
				end
			else 
				break; 
			end
			i = i + 1
		end
		return maxVal, selected
	end	
	
	--Returns the average of a table of numeric values
	function LFLT_T.getTableAverage(tab)
		local avg = 0
		for k,v in pairs(tab) do
			avg = avg + v
		end
		return avg / #tab
	end
	
	--Returns char in string location pos
	function LFLT_T.charAt(str, pos)
		return str:sub(pos,pos)
	end

	--Rounds number up or down at the signifigant digit
	--@param2 position of place value going left of decimal.
	function LFLT_T.round(num, signifigantDigit)
		local mult, polarizingNum
		if signifigantDigit > 0 then
			mult = 10^(signifigantDigit - 2) 
		else
			mult = 10^(signifigantDigit - 1) 
		end
		polarizingNum = num / mult % 10
		if polarizingNum >= 5 then 
			polarizingNum = 1 
		else 
			polarizingNum = 0 
		end
		mult = mult * 10
		return (math.floor(num / mult) + polarizingNum) * mult
		
	end

	--Calls LFLT_T.round but signifigant digit is towards right of decimal.
	function LFLT_T.roundToDecimal(num, signifigantDigit)
	  return LFLT_T.round(num, signifigantDigit * -1)
	end
	
	--Throwaway function
	function LFLT_T.derp()
		print("Derp")
	end

	--[[DISCONTINUED FUNCTION DO NOT ERASE PLANNING TO REVAMP LIVING SEED USING THIS FUNCTION
		return to evenhandler
			Place back in Register Event cluster
				eventframe:RegisterEvent("ARTIFACT_UPDATE")	
			place back into eventhandler function
				elseif event == "ARTIFACT_UPDATE" then
					LFLT_T.updateArtifact()
	
	--Retrieves and Sets values related to Artifact Traits
	function LFLT_T.updateArtifact()
		local hide 
		local seedsPoints = 0
		if IsEquippedItem(LFLT_T.RESTODRUIDARTIFACTWEAPONID) == true then
			if ArtifactFrame then
				if not ArtifactFrame:IsShown() then 
					SocketInventoryItem(LFLT_T.WEAPONITEMSLOT)
					hide = true
				end
				--131 is Trait: Seeds if the World Tree according to C_ArtifactUI.GetPowers()
				seedsPoints, _ = C_ArtifactUI.GetPowerInfo(LFLT_T.LIVINGSEEDTRAITID).currentRank
				if hide then HideUIPanel(ArtifactFrame) end
			else --If game has not loaded Artifact Frame yet.
				C_Timer.After(0.25, function() LFLT_T.updateArtifact() end)
				return
			end
		end
		if not seedsPoints then 
			C_Timer.After(0.25, function() LFLT_T.updateArtifact() end)
		end
	end]]
end