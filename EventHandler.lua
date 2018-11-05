--Author Manaleaf - Sargeras
--Event handling for Leaflet

function LFLT_A.EventHandler()
	--Sets Encounter data to be printed to file.
	function LFLT.saveSession(mode, eID, eName) 
		LFLT_T.updateStats()
		LFLT_T.historyEntryNum = #LFLT.history + 1
		--Clear leech haste registry
		LFLT_T.leechHaste = {}
			
		local talentCode = ""
		for i = 1, GetMaxTalentTier() do
			local k = 1
			while true do
				local _, name, _, selected, _ = GetTalentInfo(i,k,1)
				if not name then
					k = 0
					break
				end
				k = k + 1
				if selected then
					talentCode = talentCode .. "1"
				else
					talentCode = talentCode .. "0"
				end
			end
		end
		
		--Create new Session in History.
		LFLT.history[LFLT_T.historyEntryNum]= {  
			--Raid Specific Entries
			encounter 	= eName,
			encounterid = eID,
			outcome 	= mode,
			--General Entries
			playername	= UnitName("player"),
			dungeonmode = LFLT.dungeonInfo["difficulty"],
			mapID 		= LFLT.dungeonInfo["mapID"],
			dName 		= LFLT.dungeonInfo["name"],
			groupSize 	= LFLT.dungeonInfo["groupSize"],
			talents 	= talentCode,
			int 		= LFLT.sessionRecords.active.int,
			mst 		= LFLT.sessionRecords.active.mst,
			hst 		= LFLT.sessionRecords.active.hst,
			crt 		= LFLT.sessionRecords.active.crt,
			vrs 		= LFLT.sessionRecords.active.vrs,
			hstMod 		= LFLT.sessionRecords.active.hstMod,
			lch 		= LFLT.sessionRecords.active.lch,
			cur_int_hpc = LFLT_T.score.cur_int_hpc,
			cur_int_hpt = LFLT_T.score.cur_int_hpt,
			cur_mst_hpc = LFLT_T.score.cur_mst_hpc,
			cur_mst_hpt = LFLT_T.score.cur_mst_hpt,
			cur_hst_hpc = LFLT_T.score.cur_hst_hpc,
			cur_hst_hpt = LFLT_T.score.cur_hst_hpt,
			cur_crt_hpc = LFLT_T.score.cur_crt_hpc,
			cur_crt_hpt = LFLT_T.score.cur_crt_hpt,
			cur_vrs_hpc = LFLT_T.score.cur_vrs_hpc,
			cur_vrs_hpt = LFLT_T.score.cur_vrs_hpt,
			cur_lch_hpc = LFLT_T.score.cur_lch_hpc,
			cur_lch_hpt = LFLT_T.score.cur_lch_hpt,
			critBonusOutput = LFLT_T.critBonusOutput,
			records = {},
			date = {},
			
		}
		
		local stats = {
			intellect = 0,
			mastery = 0,
			haste = 0,
			critical = 0,
			versatility = 0,
			leech = 0,
		}
		LFLT_T.getGearStats(stats)
		
		LFLT.history[LFLT_T.historyEntryNum].eq_int = stats.intellect
		LFLT.history[LFLT_T.historyEntryNum].eq_mst = stats.mastery
		LFLT.history[LFLT_T.historyEntryNum].eq_hst = stats.haste
		LFLT.history[LFLT_T.historyEntryNum].eq_crt = stats.critical
		LFLT.history[LFLT_T.historyEntryNum].eq_vrs = stats.versatility
		LFLT.history[LFLT_T.historyEntryNum].eq_lch = stats.leech
		
		if not LFLT.history[LFLT_T.historyEntryNum].eq_int then
			LFLT_T.entryWaitingOnGameLoad = LFLT_T.historyEntryNum
			function LFLT_T.retryGearStats(attempt) 
				if not attempt then attempt = 1 end
				local entry = LFLT.history[LFLT_T.entryWaitingOnGameLoad]
				local eq_int, eq_mst, eq_hst, eq_crt, eq_vrs, eq_lch = LFLT_T.getGearStats()
				if eq_int then
					entry.eq_int = eq_int
					entry.eq_mst = eq_mst
					entry.eq_hst = eq_hst
					entry.eq_crt = eq_crt
					entry.eq_vrs = eq_vrs
					entry.eq_lch = eq_lch
				else 
					if attempt > 5 then
						print("Leaflet: Could Not Save History Entry", LFLT_T.entryWaitingOnGameLoad, "\n>>Unable to Parse Equipment Stats.")
						LFLT.history[LFLT_T.entryWaitingOnGameLoad] = nil
						LFLT_T.entryWaitingOnGameLoad = nil
					else
						C_Timer.After(2.5, LFLT_T.retryGearStats, attempt + 1)
					end
				end
			end
			C_Timer.After(2.5, LFLT_T.retryGearStats)
		end	
			
					
		for k,v in pairs(date("*t")) do
			LFLT.history[LFLT_T.historyEntryNum].date[k] = v
		end
		
		local hours   = floor((GetTime() - LFLT.dungeonInfo["StartTime"]) / 3600)
		local minutes = floor((GetTime() - LFLT.dungeonInfo["StartTime"]) / 60 % 60)
		local seconds = floor((GetTime() - LFLT.dungeonInfo["StartTime"]) % 60)
					
		local startHour,startMin
		local endHour 	= LFLT.history[LFLT_T.historyEntryNum].date["hour"]
		local endMin 	= LFLT.history[LFLT_T.historyEntryNum].date["min"]
		if endMin < (minutes + 1) then
			if endHour == 0 then 
				endHour = 23
			else 
				endHour = endHour - 1
			end
			startMin = endMin + 60 - (minutes + 1)
		else
			startMin = endMin - (minutes + 1)
		end
		startHour = endHour - hours
		
		LFLT.history[LFLT_T.historyEntryNum].startMin = startMin
		LFLT.history[LFLT_T.historyEntryNum].startHour = startHour
		
		--Takes a minute after exiting dungeon nonmythic for session to save
		if mode == 3 then
			minutes = minutes - 1
		end
		
		if hours > 99 then
			LFLT.history[LFLT_T.historyEntryNum].duration = tostring(string.format("%02.f", 99))
															.. ":" .. 
															tostring(string.format("%02.f", minutes))
															.. ":" .. 
															tostring(string.format("%02.f",seconds))
		elseif hours > 0 then 
			LFLT.history[LFLT_T.historyEntryNum].duration = tostring(string.format("%02.f", hours))
															.. ":" .. 
															tostring(string.format("%02.f", minutes))
															.. ":" .. 
															tostring(string.format("%02.f",seconds))
		else					
			LFLT.history[LFLT_T.historyEntryNum].duration = tostring(string.format("%02.f", minutes))
															.. ":" .. 
															tostring(string.format("%02.f",seconds))
		end	
		
		for recNum,record in ipairs(LFLT.sessionRecords) do 
			LFLT.history[LFLT_T.historyEntryNum].records[recNum] = {}
			for tableVar,tableVal in pairs(record) do
				LFLT.history[LFLT_T.historyEntryNum].records[recNum][tableVar] = tableVal
			end
		end
		LFLT.sessionRecords = {} --Clear Session Records
		LFLT_T.updateHistoryPage()	
	end	
	
	--Checks player location
	--Returns 	1 for Raid
	--			2 for Mythic Dungeon
	--			3 for Non-mythic Dungeon 
	--			0 for non-instance
	function LFLT_T.instanceCheck()
		local location, instanceType, difficulty,_,_,_,_, mapID  = GetInstanceInfo()
		if location == "Eastern Kingdoms" 
		or location == "Kalimdor" 
		or location == "Northrend"
		or location == "Outland"
		or location == "Draenor"
		or location == "Broken Isles"
		or LFLT.dungeonInfo["mapID"] ~= mapID then
			return 0
		elseif instanceType == "party" then
			if difficulty == 23 and LFLT.enabled["mythicdungeon"] then
				return 2
			elseif LFLT.enabled["dungeonnonmythic"] then
				return 3
			end
		elseif instanceType == "raid" and LFLT.enabled["raid"] then
				return 1
		end
		return 0
	end		
	
	--Begins a session
	local function startSession(sType) 
		LFLT.sessionRecords = {}
		LFLT_T.updateStats()
		LFLT.session = sType
		LFLT_T.updateDisplayVisibility()
		LFLT.clearStats()
		local name, _, Difficulty, _, _, _, _, mapID = GetInstanceInfo()
		LFLT.dungeonInfo["mapID"] = mapID
		LFLT.dungeonInfo["name"] = name
		LFLT.dungeonInfo["difficulty"] = Difficulty
		LFLT.dungeonInfo["StartTime"] = GetTime()
		LFLT.dungeonInfo["groupSize"] = GetNumGroupMembers()
	end
	
	function LFLT_T.discardSession()
		LFLT.session = "none"
		LFLT_T.updateDisplayVisibility()
		LFLT.dungeonInfo = {}
	end
	
	--Checks after 1 minute if player has reentered dungeon, if so, session continues
	local function playerExitedDungeon()
		--Player has disabled dungeon nonmythic during dungeon
		if LFLT.session == "dungeonnonmythic" then 
			if ( math.abs(LFLT.encStartTimer - GetTime())) > 300 then --Player must be in dungeon for more than 5 minutes to count as a session
				C_Timer.After(60, function() 
					if LFLT_T.instanceCheck() == 0 then 
						LFLT_T.discardSession() 
					end
				end)
			else C_Timer.After(60, function() 
					if LFLT_T.instanceCheck() == 0 then 
						LFLT.saveSession(3) 
						LFLT.session = "none"
						LFLT.dungeonInfo = {}
					end
				end)
			end
		elseif LFLT.session == "mythicdungeon" then
			C_Timer.After(60, function() 
				if LFLT_T.instanceCheck() == 0 then 
					LFLT_T.discardSession() 
				end
			end)
		end
	end
	--Sets and unsets which keyboard modifier keys are being pressed down.
	local function setModifierState(mod, state)
		LFLT_T.modifierState[mod] = state
	end
	
	--Addon Event handling
	function LFLT.eventHandler(self, event, ...)
		if event == "COMBAT_LOG_EVENT_UNFILTERED" and 
			LFLT.session ~= "none" then
			LFLT_T.statCalc(nil, ...)
			
		elseif event == "UNIT_STATS" or event == "COMBAT_RATING_UPDATE" and session ~= "none" then      
			LFLT_T.updateStats()
			
		elseif event == "MODIFIER_STATE_CHANGED" then
			setModifierState(...)
			
		elseif event == "PLAYER_REGEN_DISABLED" then
			LFLT_T.inCombat = true
			if _G[LFLT_F.configFrameObj.name]:IsShown() then
				_G[LFLT_F.configFrameObj.name]:Hide()
			end
			LFLT_T.updateDisplayVisibility()
			
		elseif event == "PLAYER_REGEN_ENABLED" then
			LFLT_T.inCombat = false
			LFLT_T.updateDisplayVisibility()
			
		elseif event == "PLAYER_ENTERING_WORLD" then
			--Login Tasks
			if LFLT_T.playerLoggingIn then
				LFLT_T.playerLoggingIn = false
			end
			local instance = LFLT_T.instanceCheck()
			--Player in a Raid
			if instance == 1 then
				startSession("none")
			--Player in Mythic Dungeon
			elseif instance == 2 then
				startSession("mythicdungeon")
			--Player in Non-Mythic Dungeon
			elseif instance == 3 then
				startSession("dungeonnonmythic")
			--Player in open world or non-enabled 				
			elseif 	instance == 0 then
				if LFLT.session == "dungeonnonmythic" 
				or LFLT.session == "mythicdungeon" then
					playerExitedDungeon()
				else
					LFLT_T.discardSession()
				end
			end		
			LFLT_T.updateDisplay(2)
			
		elseif event == "ENCOUNTER_START" and LFLT.session == "none" then
			startSession("raid")
			
		elseif event == "ENCOUNTER_END" and LFLT.session == "raid" then 
			local eID, eName, _, _, outcome = ...
			LFLT.saveSession(outcome, eID, eName) 
			LFLT.session = "none"
			LFLT_T.updateDisplayVisibility()

		elseif event == "CHALLENGE_MODE_START" then
			startSession("mythicdungeon")
			
		elseif event == "CHALLENGE_MODE_COMPLETED" 
			or event == "CHALLENGE_MODE_RESET" then
			--and LFLT.session == "mythicdungeon" then 
			LFLT.saveSession(3)			
			
		elseif event == "PLAYER_LOGOUT" then
			LFLT_T.saveDisplayPosition()	
		end
	end
	
	local eventframe = CreateFrame("FRAME", "LFLT_T.EVENT_Frame", UIParent)
	--RegisterEvents to displayframe
	eventframe:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	eventframe:RegisterEvent("ENCOUNTER_START")
	eventframe:RegisterEvent("ENCOUNTER_END")
	eventframe:RegisterEvent("COMBAT_RATING_UPDATE")
	eventframe:RegisterEvent("UNIT_STATS")
	eventframe:RegisterEvent("PLAYER_ENTERING_WORLD")
	eventframe:RegisterEvent("PLAYER_LOGOUT")
	eventframe:RegisterEvent("PLAYER_REGEN_DISABLED")
	eventframe:RegisterEvent("PLAYER_REGEN_ENABLED")
	eventframe:RegisterEvent("PLAYER_TALENT_UPDATE")
	eventframe:RegisterEvent("MODIFIER_STATE_CHANGED")
	eventframe:RegisterEvent("CHALLENGE_MODE_START")
	eventframe:RegisterEvent("CHALLENGE_MODE_COMPLETED")
	eventframe:RegisterEvent("CHALLENGE_MODE_RESET")
	
	
	eventframe:SetScript("OnEvent", LFLT.eventHandler);
	
	--Slash Command Declaration
	SLASH_ll1 = "/ll"
	SlashCmdList["ll"] = function(msg, editbox)
		if strlower(msg) == "lock" then
			if LFLT.option.lock then
				LFLT.option.lock = false
			else
				LFLT.option.lock = true
			end
			LFLT_T.setDisplayLock()
		elseif strlower(msg) == "reset" then
			LFLT.clearAllStats()
			LFLT_T.updateDisplay()
			print("Leaflet: Stats have been reset")
		elseif strlower(msg) == "toggle" then
			if _G[LFLT_F.displayFrameObj.name]:IsVisible() then
				_G[LFLT_F.displayFrameObj.name]:Hide()
				LFLT.option.displayToggle = false
				print("Leaflet: Hiding Display")
			else 
				_G[LFLT_F.displayFrameObj.name]:Show()
				LFLT.option.displayToggle = true
				LFLT_T.updateDisplay()
				print("Leaflet: Showing Display")
			end
		elseif strlower(msg) == "help" then
			print("Leaflet Commands:"
					.. "\n     \'/ll\'         -Open config" 
					.. "\n     \'/ll lock\'    -Locks the display" 
					.. "\n     \'/ll toggle\'  -Toggle display" 
					.. "\n     \'/ll reset\'   -Reset \'Total\' Stat Weights" )
		else
			if LFLT.option.configToggle then
				if LFLT_T.inCombat then
					print("Cannot Open Menu in combat.")
				else
					_G[LFLT_F.configFrameObj.name]:Hide()
				end
			else
				_G[LFLT_F.configFrameObj.name]:Show()
			end
		end
	end			
end