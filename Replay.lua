--Author Manaleaf - Sargeras
--History Replay Calcs for Leaflet


function LFLT_A.Replay()
	
	--Compares heal totals using a different set of stats which generated the heal.
	function LFLT_T.healCompare(heal, spellName, spellType, replayStats, recordStats, hCount)
		--Spell CoEff.
		local sce
		
		local recordStats_int = LFLT_T.round(recordStats.int ,-5)
		local recordStats_crt = LFLT_T.round(recordStats.crt ,-5)
		local recordStats_hst = LFLT_T.round(recordStats.hst ,-5)
		local recordStats_vrs = LFLT_T.round(recordStats.vrs ,-5)
		local recordStats_mst = LFLT_T.round(recordStats.mst ,-5)
		local recordStats_critBonusOutput = LFLT_T.round(recordStats.critBonusOutput ,-5)
		
		local replayStats_int = LFLT_T.round(replayStats.int ,-5)
		local replayStats_crt = LFLT_T.round(replayStats.crt ,-5)
		local replayStats_hst = LFLT_T.round(replayStats.hst ,-5)
		local replayStats_vrs = LFLT_T.round(replayStats.vrs ,-5)
		local replayStats_mst = LFLT_T.round(replayStats.mst ,-5)
		local replayStats_critBonusOutput = LFLT_T.round(replayStats.critBonusOutput ,-5)
		
		--[[if recordStats_int ~= replayStats_int then print("Mismatch int: ", recordStats_int - replayStats_int, recordStats_int, replayStats_int) end
		if recordStats_crt ~= replayStats_crt then print("Mismatch crt: ", recordStats_crt - replayStats_crt, recordStats_crt, replayStats_crt) end
		if recordStats_hst ~= replayStats_hst then print("Mismatch hst: ", recordStats_hst - replayStats_hst, recordStats_hst, replayStats_hst) end
		if recordStats_vrs ~= replayStats_vrs then print("Mismatch vrs: ", recordStats_vrs - replayStats_vrs, recordStats_vrs, replayStats_vrs) end
		if recordStats_mst ~= replayStats_mst then print("Mismatch mst: ", recordStats_mst - replayStats_mst, recordStats_mst, replayStats_mst) end
		if recordStats_critBonusOutput ~= replayStats_critBonusOutput then 
			print("Mismatch CBO: ", recordStats_critBonusOutput - replayStats_critBonusOutput, recordStats_critBonusOutput, replayStats_critBonusOutput)
		end]]
		--Hots or Efflo
		if spellType == "SPELL_PERIODIC_HEAL"
			or (spellName == LFLT_T.spells.efflorescence) then
			sce = heal / 	( recordStats_int 
							* (1 + (recordStats_mst - 1) * hCount)
							* (recordStats_crt * recordStats_critBonusOutput)
							* recordStats_vrs
							* recordStats_hst)
			
			return 	(sce * replayStats_int 
						* (1 + (replayStats_mst - 1) * hCount) 
						* (replayStats_crt * replayStats_critBonusOutput)
						* replayStats_vrs
						* replayStats_hst)
		
		--Direct Heals
		elseif spellType == "SPELL_HEAL" then
			if spellName == LFLT_T.spells.efflorescence then 
				replayStats_critBonusOutput = replayStats_critBonusOutput + LFLT_T.REGROWTHBASECRT
			end
			sce = heal / 	( recordStats_int 
							* (1 + (recordStats_mst - 1) * hCount)
							* (recordStats_crt * replayStats_critBonusOutput)
							* recordStats_vrs)

			return  (sce * replayStats_int 
						* (1 + (replayStats_mst - 1) * hCount) 
						* (replayStats_crt * replayStats_critBonusOutput)
						* replayStats_vrs)
		end
	end

		--Backup Display Data
	local function backUpDisplayData()
		LFLT_T.backup.cur_int_hpc = LFLT_T.score.cur_int_hpc
		LFLT_T.backup.cur_int_hpt = LFLT_T.score.cur_int_hpt
		LFLT_T.backup.cur_mst_hpc = LFLT_T.score.cur_mst_hpc
		LFLT_T.backup.cur_mst_hpt = LFLT_T.score.cur_mst_hpt
		LFLT_T.backup.cur_hst_hpc = LFLT_T.score.cur_hst_hpc
		LFLT_T.backup.cur_hst_hpt = LFLT_T.score.cur_hst_hpt
		LFLT_T.backup.cur_crt_hpc = LFLT_T.score.cur_crt_hpc
		LFLT_T.backup.cur_crt_hpt = LFLT_T.score.cur_crt_hpt
		LFLT_T.backup.cur_vrs_hpc = LFLT_T.score.cur_vrs_hpc
		LFLT_T.backup.cur_vrs_hpt = LFLT_T.score.cur_vrs_hpt
		LFLT_T.backup.cur_lch_hpc = LFLT_T.score.cur_lch_hpc
		LFLT_T.backup.cur_lch_hpt = LFLT_T.score.cur_lch_hpt
		LFLT_T.backup.ttl_int_hpc = LFLT_T.score.ttl_int_hpc
		LFLT_T.backup.ttl_int_hpt = LFLT_T.score.ttl_int_hpt
		LFLT_T.backup.ttl_mst_hpc = LFLT_T.score.ttl_mst_hpc
		LFLT_T.backup.ttl_mst_hpt = LFLT_T.score.ttl_mst_hpt
		LFLT_T.backup.ttl_hst_hpc = LFLT_T.score.ttl_hst_hpc
		LFLT_T.backup.ttl_hst_hpt = LFLT_T.score.ttl_hst_hpt
		LFLT_T.backup.ttl_crt_hpc = LFLT_T.score.ttl_crt_hpc
		LFLT_T.backup.ttl_crt_hpt = LFLT_T.score.ttl_crt_hpt
		LFLT_T.backup.ttl_vrs_hpc = LFLT_T.score.ttl_vrs_hpc
		LFLT_T.backup.ttl_vrs_hpt = LFLT_T.score.ttl_vrs_hpt
		LFLT_T.backup.ttl_lch_hpc = LFLT_T.score.ttl_lch_hpc
		LFLT_T.backup.ttl_lch_hpt = LFLT_T.score.ttl_lch_hpt
	end
	
	--Restore Display Data from Backup
	local function retrieveDisplayDataBackup()
		LFLT_T.score.cur_int_hpc = LFLT_T.backup.cur_int_hpc 
		LFLT_T.score.cur_int_hpt = LFLT_T.backup.cur_int_hpt 
		LFLT_T.score.cur_mst_hpc = LFLT_T.backup.cur_mst_hpc 
		LFLT_T.score.cur_mst_hpt = LFLT_T.backup.cur_mst_hpt 
		LFLT_T.score.cur_hst_hpc = LFLT_T.backup.cur_hst_hpc 
		LFLT_T.score.cur_hst_hpt = LFLT_T.backup.cur_hst_hpt 
		LFLT_T.score.cur_crt_hpc = LFLT_T.backup.cur_crt_hpc 
		LFLT_T.score.cur_crt_hpt = LFLT_T.backup.cur_crt_hpt 
		LFLT_T.score.cur_vrs_hpc = LFLT_T.backup.cur_vrs_hpc 
		LFLT_T.score.cur_vrs_hpt = LFLT_T.backup.cur_vrs_hpt 
		LFLT_T.score.cur_lch_hpc = LFLT_T.backup.cur_lch_hpc 
		LFLT_T.score.cur_lch_hpt = LFLT_T.backup.cur_lch_hpt 
		LFLT_T.score.ttl_int_hpc = LFLT_T.backup.ttl_int_hpc 
		LFLT_T.score.ttl_int_hpt = LFLT_T.backup.ttl_int_hpt 
		LFLT_T.score.ttl_mst_hpc = LFLT_T.backup.ttl_mst_hpc 
		LFLT_T.score.ttl_mst_hpt = LFLT_T.backup.ttl_mst_hpt 
		LFLT_T.score.ttl_hst_hpc = LFLT_T.backup.ttl_hst_hpc 
		LFLT_T.score.ttl_hst_hpt = LFLT_T.backup.ttl_hst_hpt 
		LFLT_T.score.ttl_crt_hpc = LFLT_T.backup.ttl_crt_hpc 
		LFLT_T.score.ttl_crt_hpt = LFLT_T.backup.ttl_crt_hpt 
		LFLT_T.score.ttl_vrs_hpc = LFLT_T.backup.ttl_vrs_hpc 
		LFLT_T.score.ttl_vrs_hpt = LFLT_T.backup.ttl_vrs_hpt 
		LFLT_T.score.ttl_lch_hpc = LFLT_T.backup.ttl_lch_hpc 
		LFLT_T.score.ttl_lch_hpt = LFLT_T.backup.ttl_lch_hpt 
	end
	
	function LFLT_T.abortReplay(call)
		local message = ""
		if call == 1 then
			message = "Cannot run replays\nduring an\nActive Session."
		elseif call == 2 then
			message = "Replay Aborted:\nSession Started\nDuring Replay."
		else 
			message = "Replay Aborted"
		end
		LFLT_T.replayInProgress = false
		_G[LFLT_F.replayResultPercentFrameTextObj.name]:SetText(message)
		retrieveDisplayDataBackup()
		LFLT_T.manualOverride.updateDisplay = false
		LFLT_T.updateDisplay(2)
		_G[LFLT_F.replayButton.name]:Enable()
		LFLT_T.popupMessage(message, "Okay", function() end)
		if coroutine.status(LFLT_T.replayThread) == "running" then coroutine.yield(LFLT_T.replayThread) end
		return
	end
	
	--Replays selected history entry using player's current gear using the entry's record
	function LFLT_T.replayCalc(eq_int, eq_mst, eq_hst, eq_crt, eq_vrs, eq_lch)
		local entryList = LFLT_T.getSelectedHistoryButtons()
		if #entryList > 0 then
			--Check for Interrupt due to session start
			if LFLT.session ~= "none" then LFLT_T.abortReplay(2); return end
			LFLT_T.manualOverride.updateDisplay = true
			backUpDisplayData()
			LFLT.clearAllStats()
			
			local adjHeal
			local adjHealSum 			= 0 
			local recHealSum 	 		= 0 	
			
			local cur_int_hpc, cur_mst_hpc, cur_hst_hpc, cur_crt_hpc, cur_vrs_hpc
			local cur_hst_hpt, cur_hst_com, ttl_hst_com
			local maxCurHeal, selectedCurMax
			--local cur_lch_hpc
					
			local statWeights 	= {int = {}, mst = {}, hst_hpc = {}, hst_hpt = {}, hst_com = {}, crt = {}, vrs = {}} 
			local statWeightAverages 	= {}
			local healPercChange 		= {}
			local healPercChangeAverage 
			local replayStats			= {}
			
			for _,entry in ipairs(entryList) do				--A History Entry
				for _, record in ipairs(entry.records) do	--A Record in the History Entry
					--Check for Interrupt due to session start 
					if LFLT.session ~= "none" then LFLT_T.abortReplay(1) return end
					replayStats = {
						["int"] = record.int + (eq_int - entry.eq_int), 
						["mst"] = record.mst + (eq_mst - entry.eq_mst)/LFLT_T.MSTRATINGCONV, 
						["hst"] = record.hst + (eq_hst - entry.eq_hst)/LFLT_T.HSTRATINGCONV, 
						["crt"] = record.crt + (eq_crt - entry.eq_crt)/LFLT_T.CRTRATINGCONV, 
						["vrs"] = record.vrs + (eq_vrs - entry.eq_vrs)/LFLT_T.VRSRATINGCONV, 
						["critBonusOutput"] = record.critBonusOutput + (LFLT_T.critBonusOutput - entry.critBonusOutput),
						["hstMod"] = record.hstMod,
					} 
					--Calcs for spells in records
					--[[print("|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||")
					if (eq_int - entry.eq_int) ~= 0 then print(">>>>int>>>>",eq_int - entry.eq_int, eq_int, entry.eq_int) end
					if (eq_mst - entry.eq_mst) ~= 0 then print(">>>>mst>>>>",(eq_mst - entry.eq_mst)/LFLT_T.MSTRATINGCONV,(eq_mst - entry.eq_mst), eq_mst, entry.eq_mst) end
					if (eq_hst - entry.eq_hst) ~= 0 then print(">>>>hst>>>>",(eq_hst - entry.eq_hst)/LFLT_T.HSTRATINGCONV,(eq_hst - entry.eq_hst), eq_hst, entry.eq_hst) end
					if (eq_crt - entry.eq_crt) ~= 0 then print(">>>>crt>>>>",(eq_crt - entry.eq_crt)/LFLT_T.CRTRATINGCONV,(eq_crt - entry.eq_crt), eq_crt, entry.eq_crt) end
					if (eq_vrs - entry.eq_vrs) ~= 0 then print(">>>>vrs>>>>",(eq_vrs - entry.eq_vrs)/LFLT_T.VRSRATINGCONV,(eq_vrs - entry.eq_vrs), eq_vrs, entry.eq_vrs) end
					]]
					--Overrides 
					---getUnit will always return player as unit
					--disables recordInsert
					LFLT_T.manualOverride.getUnit 	= "player"
					LFLT_T.manualOverride.recordInsert = true
					for spellName,healData in pairs(record.spells) do
						for hCount, heal in pairs(healData.heal) do	
							adjHeal = LFLT_T.healCompare(heal, spellName, healData.sType, replayStats, record, hCount)
							adjHealSum 	= adjHealSum + adjHeal
							recHealSum 	= recHealSum + heal
							LFLT_T.manualOverride.hotCounter = hCount
							--Manual Entries for statCalc
							LFLT_T.statCalc(replayStats, nil, healData.sType, nil, UnitGUID("player"), nil, 
									 nil, nil, nil, nil, nil, 
									 nil, nil, spellName, nil, adjHeal, 
									 0, nil, false)

							LFLT_T.leechHaste = {}
						end
					end
				end
				--Deactivate Manual Overrides
				LFLT_T.manualOverride.hotCounter = nil
				LFLT_T.manualOverride.getUnit	= nil
				LFLT_T.manualOverride.recordInsert = nil
				tinsert(healPercChange, adjHealSum / recHealSum)
				adjHealSum 			= 0	
				recHealSum 			= 0 	
								
				local maxCurHeal, selectedCurMax = LFLT.maxButNotZero(0.001,	LFLT_T.score.cur_int_hpc, LFLT_T.score.cur_mst_hpc, 
																		LFLT_T.score.cur_hst_hpc, LFLT_T.score.cur_crt_hpc, 
																		LFLT_T.score.cur_vrs_hpc) 

				--HPC:Current Encounter Healing Score Allocation
				cur_int_hpc = LFLT_T.score.cur_int_hpc / maxCurHeal
				cur_mst_hpc = LFLT_T.score.cur_mst_hpc / maxCurHeal
				cur_hst_hpc = LFLT_T.score.cur_hst_hpc / maxCurHeal
				cur_crt_hpc = LFLT_T.score.cur_crt_hpc / maxCurHeal
				cur_vrs_hpc = LFLT_T.score.cur_vrs_hpc / maxCurHeal
				--cur_lch_hpc = LFLT_T.score.cur_lch_hpc / maxCurHeal
				
				maxCurHeal,_ = select(selectedCurMax, 0.001, 	LFLT_T.score.cur_int_hpt, LFLT_T.score.cur_mst_hpt, LFLT_T.score.cur_hst_hpt, 
																LFLT_T.score.cur_crt_hpt, LFLT_T.score.cur_vrs_hpt) 

				--HPCT:Current Encounter Healing Score Allocation
				cur_hst_hpt = LFLT_T.score.cur_hst_hpt / maxCurHeal
				--Composite Haaste
				cur_hst_com = cur_hst_hpc * (1 - LFLT.hasteCompositeRatio) + cur_hst_hpt * LFLT.hasteCompositeRatio
				
				tinsert(statWeights.int, cur_int_hpc)
				tinsert(statWeights.mst, cur_mst_hpc)
				tinsert(statWeights.hst_hpc, cur_hst_hpc)
				tinsert(statWeights.hst_hpt, cur_hst_hpt)
				tinsert(statWeights.hst_com, cur_hst_com)
				tinsert(statWeights.crt, cur_crt_hpc)
				tinsert(statWeights.vrs, cur_vrs_hpc)
			end
			--Final Averages
			for k,v in pairs(statWeights) do
				statWeightAverages[k] = LFLT_T.getTableAverage(v)
			end
			healPercChangeAverage = LFLT_T.getTableAverage(healPercChange)
			healPercChangeAverage = LFLT_T.roundToDecimal((healPercChangeAverage - 1 ) * 100, 1)
			local statFormat = "\n%12s: "
			local dataFormat = "\n%-5." .. tostring(LFLT.option.displayPrecision) .. "f"
			local outString1, outData1, outString2 
			local polarity = ""
			local hstText1, hstCurDataText1 = "",""
			local hstText2, hstCurDataText2 = "",""
			--Haste Display
			if LFLT.enabledHaste.cast.enabled then
				hstText1		= string.format(statFormat, "Haste[C]")
				hstCurDataText1 = string.format(dataFormat, statWeightAverages.hst_hpc)
			end
			if LFLT.enabledHaste.casttime.enabled then
				hstText2 		= string.format(statFormat, "Haste[T]")
				hstCurDataText2 = string.format(dataFormat, 
								statWeightAverages.hst_hpc * (1-LFLT.hasteCompositeRatio)
								+ statWeightAverages.hst_hpt * LFLT.hasteCompositeRatio)
			end

			outString1 = string.format("%12s: " .. statFormat .. "%s" ..  "%s" .. statFormat .. statFormat,
						"Intellect", "Crit", hstText1, hstText2, "Mastery", "Versatility")
			outData1 = string.format("%-5." .. tostring(LFLT.option.displayPrecision) .. "f" .. dataFormat .. "%s" ..  "%s" ..  dataFormat .. dataFormat,
						statWeightAverages.int,
						statWeightAverages.crt, 
						hstCurDataText1, hstCurDataText2,
						statWeightAverages.mst,
						statWeightAverages.vrs)
			if healPercChangeAverage > 0 then
				polarity = "+"
			end
			outString2 = "Difference\n" .. polarity .. healPercChangeAverage .. "%\nHealing"
			
			_G[LFLT_F.replayResultWeightFrameTextObjLeft.name]:SetText(outString1)
			_G[LFLT_F.replayResultWeightFrameTextObjRight.name]:SetText(outData1)
			_G[LFLT_F.replayResultPercentFrameTextObj.name]:SetText(outString2)
			_G[LFLT_F.replayFrameWeightTextObjCenter.name]:SetText("")
		else
			print("Leaflet: Please Select an Entry.")
			_G[LFLT_F.replayResultWeightFrameTextObjLeft.name]:SetText(LFLT_F.replayResultWeightFrameTextObjLeft.text)
			_G[LFLT_F.replayResultWeightFrameTextObjRight.name]:SetText("")
			_G[LFLT_F.replayResultPercentFrameTextObj.name]:SetText("Please Select an Entry")
			_G[LFLT_F.replayFrameWeightTextObjCenter.name]:SetText("Replay Stat Weights")
			return
		end
		retrieveDisplayDataBackup()
		LFLT_T.manualOverride.updateDisplay = false
		LFLT_T.updateDisplay(2)
		LFLT_T.replayInProgress = false
		_G[LFLT_F.replayButton.name]:Enable()
	end
	
	--[[
	initiates replay system
	Intended as running thread
	@return1 intellect, 
	@return2 mastery, 
	@return3 haste 
	@return4 critical strike, 
	@return5 versatility, 
	@return6 leech
	]]
	function LFLT_T.replay(stats, attempt, armGearSlots, wpGearSlots)
		local maxAttempts = 20
		if not armGearSlots then 
			armGearSlots = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,} 
		end
		--Force Weapon Tooltip load, parse weapon tooltip last to help prevent incorrect tooltip load by blizzard
		GetInventoryItemLink("player",16)
		if not wpGearSlots then 
			wpGearSlots = {16,17,} 
		end
		if not attempt then attempt = 1 end
		if not stats then 
			stats = {
				intellect = 0,
				mastery = 0,
				haste = 0,
				critical = 0,
				versatility = 0,
				leech = 0,
			}
		end
		if attempt > maxAttempts then
				LFLT_T.replayInProgress = false
				popupMessage(FLT_T.popupMsg["replayparsefailed"], "Okay", function() end)
				return
		end
		local link, gem1Link, gem2Link, gem3Link
		if #armGearSlots > 0 and not LFLT_T.getGearStats(stats, armGearSlots) then
			C_Timer.After(0.5, function() 
						LFLT_T.replayThread = coroutine.create(LFLT_T.replay, stats, attempt + 1, armGearSlots, wpGearSlots) 
						coroutine.resume(LFLT_T.replayThread)
						end)
			return
		elseif #wpGearSlots > 0 then
			--If artifact Weapon is equipped
			if IsEquippedItem(LFLT_T.RESTODRUIDARTIFACTWEAPONID) == true then
				--Check if Relic slots have been loaded by game-client
				link = GetInventoryItemLink("player", LFLT_T.WEAPONITEMSLOT)
				if link and (not GetItemGem(link, 1) or not GetItemGem(link, 2) or not GetItemGem(link, 3)) and not LFLT_T.replayRelicWarningIssued then
					LFLT_T.replayRelicWarningIssued = true
					LFLT_T.popupMessage(LFLT_T.popupMsg["relicmissing"], 
										"Cancel Replay", function() 
															LFLT_T.replayRelicWarningIssued = false
															LFLT_T.abortReplay()
														end, 
										"Finish Replay", function() coroutine.resume(LFLT_T.replayThread) end)
					if coroutine.status(LFLT_T.replayThread) == "running" then coroutine.yield(LFLT_T.replayThread) end
				else
				end
				if not LFLT_T.getGearStats(stats, wpGearSlots) then
					C_Timer.After(0.5, function() 
						LFLT_T.replayThread = coroutine.create(LFLT_T.replay, stats, attempt + 1, armGearSlots, wpGearSlots) 
						coroutine.resume(LFLT_T.replayThread)
						end)
					return
				end
			end	
		end
		local message = "Dear Tester: These are your ratings from gear, gems and echants:"
							.. "\nIntellect: " .. tostring(math.floor(stats.intellect * 1.05 + LFLT_T.baseInt * 1.05))
							.. "\nMastery: " .. tostring(stats.mastery)
							.. "\nHaste: " .. tostring(stats.haste)
							.. "\nCrit: " .. tostring(stats.critical)
							.. "\nVersatility: " .. tostring(stats.versatility)
		LFLT_T.popupMessage(message, "okay", function() end)
		LFLT_T.replayThread = coroutine.create(LFLT_T.replayCalc)
		coroutine.resume(LFLT_T.replayThread,stats.intellect,stats.mastery,stats.haste,stats.critical,stats.versatility,stats.leech)
	end
		
		

end