--Author Manaleaf - Sargeras
--Core Calcs for Stat Weights

function LFLT_A.Calc()
	--Returns the UnitID of a raid member with the given name (works off server)
	function getUnit(name)
		--Manual Override for Replay System
		if LFLT_T.manualOverride.getUnit then
			return LFLT_T.manualOverride.getUnit
		end
		local destUnit
		local grpCount = GetNumGroupMembers()
		if UnitInRaid("player") then
			for i = 1, grpCount  do
				local name2,realm2 = UnitName("raid"..i)
				if realm2 then name2 = name2 .. "-" .. realm2 end
				
				if name2 == name then
					destUnit = "raid" .. i
					break
				end
			end   
		elseif UnitInParty("player") then
			for i = 1, grpCount  do
				local name2,realm2 = UnitName("party"..i)
				if realm2 then name2 = name2 .. "-" .. realm2 end
				
				if name2 == name then
					destUnit = "party" .. i
					break
				end
			end 
		elseif UnitName("player") == name then
			destUnit = "player" 
		end
		return destUnit
	end
	
	--Returns the current number of Player casted hots on the unit
	function LFLT.hotCounter(destUnit)
		--Manual Override for Replay System
		if LFLT_T.manualOverride.hotCounter then
			return LFLT_T.manualOverride.hotCounter
		end
		local hCount = 0 
		if not UnitExists(destUnit) then
			return -1 --Failure Flag
		end
		for k,v in ipairs(LFLT_T.hotList) do
			if UnitBuff(destUnit, GetSpellInfo(v), nil, "PLAYER") then hCount = hCount + 1 end 
		end
		return hCount
	end

	--Clears the current healing and stat values	
	function LFLT.clearStats()
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
	end
	
	--Clears the Current and Total healing and stat values	
	function LFLT.clearAllStats()
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
	end
		
	----------------------------------------DO NOT LET RECORDS IN TRANSITION SET LEECH MODE
	function LFLT_T.transitionRecords(stats)
		--only one iteration of this function/break recursive calls if there are no records in transition
		if LFLT_T.activeTransition == true or #LFLT_T.recordsInTransition == 0 then return end
		print("record in transition called")
		local ttab = {} --transition table
		for i,record in ipairs(LFLT_T.recordsInTransition) do
			ttab[i] = {}
			for k,v in ipairs(record) do
				ttab[i].k =  v
			end
			tremove(LFLT_T.recordsInTransition, i)
		end
		--Allow other iterations of this function after reading and clearing table.
		LFLT_T.activeTransition = false
		for k,v in ipairs(ttab) do
			--21 possible arguments of a "COMBAT_LOG_EVENT_UNFILTERED" event.
			LFLT_T.statCalc(stats, 	v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9], v[10], v[11], 
									v[12], v[13], v[14], v[15], v[16], v[17], v[18], v[19], v[20], v[21])
		end
		LFLT_T.transitionRecords(stats)
	end
		
	--Stores Spell info into the active record 
	function LFLT_T.recordInsert(heal, sName, sType, hCount)
		--Manual Override for Replay System
		if LFLT_T.manualOverride.recordInsert then return end
		if not LFLT.sessionRecords.active then LFLT_T.updateStats() end
		local log = LFLT.sessionRecords.active.spells	
		if log[sName] then
			if log[sName].heal[hCount] then
				log[sName].heal[hCount] = log[sName].heal[hCount] + heal
			else 
				log[sName].heal[hCount] = heal
			end
		else 
			log[sName] = {}
			log[sName]["heal"] = {}
			log[sName]["heal"][hCount] = heal
			log[sName]["sType"] = sType
		end
	end  
	
	--[[Returns player stats 
	@return
	1)intellect
	2)mastery
	3)haste
	4)crit
	5)versatility
	6)leech
	7)haste modifier
	8)bonus critical healing output
	]]
	function LFLT_T.getStats()
		local hstRatingPerc = 1 + (GetCombatRating(20) / LFLT_T.HSTRATINGCONV) --Haste percent from rating
		local hstPercentage = 1 + UnitSpellHaste("player") / 100
		--outputs
		local int = LFLT_T.round(GetSpellBonusDamage(4), -8)
		local mst = LFLT_T.round(1 + GetMasteryEffect() / 100, -8)
		local hst = LFLT_T.round(hstPercentage, -8)
		local crt = LFLT_T.round(1 + GetCritChance() / 100, -8)
		local vrs = LFLT_T.round(
						1 	+ (GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) 
						+ GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)) / 100
						, -8)
		local lch = LFLT_T.round(1 + GetCombatRatingBonus(17), -8)
		local hstMod = LFLT_T.round(hstPercentage / hstRatingPerc, -8) --Multiplicative modifier for haste
		--Crit Effect Multiplier
		local critBonusOutput = LFLT_T.baseCritBonusOutput
		if IsEquippedItem("Drape of Shame") then 
			critBonusOutput = LFLT_T.round(LFLT_T.critBonusOutput * 1.05, -8)
		else
			critBonusOutput = LFLT_T.round(LFLT_T.critBonusOutput, -8)
		end
		return int,mst,hst,crt,vrs,lch,hstMod,critBonusOutput
	end
	
	
	--[[Iterate through all lines of text for arg1 a tooltip
	Sums values into arg2
	Table should have an existing lower case index for all stats it wants to reading
	ie: A table without a key of "intellect" will not have intellect from the tooltip summed into it.
	indexes should only be the first word of the stat's name ie: Critical Strike => key="critical"
	]]
	function LFLT_T.tipStatParse(tip, stats, link)
		local lineText, strStatName, strStatNum	--String Parse vars
		local frameName = LFLT_F.scanner_TooltipObj.name .."TextLeft"
		
		tip:SetOwner(UIParent,"ANCHOR_NONE")
		tip:SetHyperlink(link)
		lineText = _G[frameName .. 1]:GetText()

		if not lineText or lineText ==  "Retrieving item information" then
			return false
		end
		for lineNum=1, tip:NumLines() do
			strStatNum = 0
			strStatName = ""
			lineText = _G[frameName .. lineNum]:GetText();
			if lineText and string.len(lineText) > 0 then
				--Remove Enchanted Prefixes in line text
				if string.sub(lineText, 1,10) == "Enchanted:" then
					lineText = string.gsub(lineText, "Enchanted: ", "")
					if string.lower(string.sub(lineText, 1,27)) == "mark of the trained soldier" then
						strStatName = "mastery"
						strStatNum = 600
					end
				end
				--If Text line is typical item stat line
				if string.sub(lineText, 1,1) == "+" then
					_, strStatNum, strStatName = strsplit("+ ", lineText)
					strStatName = string.lower(strStatName)
					strStatNum,_ = string.gsub(strStatNum, ",", "")
					strStatNum = tonumber(strStatNum)
				end
				if strStatName and stats[strStatName] then
					stats[strStatName] = stats[strStatName] + strStatNum
				end
			end
		end
		return true
	end
	
	--Returns to sum of all stats from gear (includes gems and enchants)
	--@return1 intellect, @return2 mastery, @return3 haste @return4 critical strike, @return5 versatility, @return6 leech
	function LFLT_T.getGearStats(stats, gearSlots, attempt)
		local function parseTip(slot, tip, stats)
			local link = GetInventoryItemLink("player",slot)
			if link then 
				if not LFLT_T.tipStatParse(tip, stats, link) then
					return false
				end 			
				local _, gem1Link = GetItemGem(link, 1)
				local _, gem2Link = GetItemGem(link, 2)
				local _, gem3Link = GetItemGem(link, 3)
				if gem1Link and not (LFLT_T.tipStatParse(tip, stats, gem1Link)) then
					return false
				end
				if gem2Link and not (LFLT_T.tipStatParse(tip, stats, gem2Link)) then
					return false
				end
				if gem3Link and not (LFLT_T.tipStatParse(tip, stats, gem3Link)) then
					return false
				end
				return true
			end
			return true
		end
		
		if not attempt then attempt = 1 end
		if not gearSlots then gearSlots = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17} end
		if not stats then stats = {
				intellect 	= 0,
				mastery 	= 0,
				haste 		= 0,
				critical 	= 0,
				versatility = 0,
				leech		= 0,
			}
		end
		
		local tip = _G[LFLT_F.scanner_TooltipObj.name]
		local slot
		local slotPos = 1
		local passes = 1
		local ttlSlots = #gearSlots
		while passes <= ttlSlots do
			passes = passes + 1
			slot = gearSlots[slotPos]
			if parseTip(slot, tip, stats) then
				tremove(gearSlots, slotPos)
			else 
				slotPos = slotPos + 1
			end
		end
		
		if #gearSlots > 0 then
			if attempt > 10 then
				return false 
			else
				--Recursive Calls will pass false back to each caller until it reaches original caller.
				if LFLT_T.getGearStats(stats, gearSlots, attempt + 1) then
					return true
				else
					return false
				end
			end
		end
		--[[print("><><><><><><><><><><><><><><><><><><><><><><")
		print("int:",stats.intellect * 1.05 + LFLT_T.baseInt * 1.05)
		print("mst:",stats.mastery)
		print("hst:",stats.haste)
		print("crt:",stats.critical)
		print("vrs:",stats.versatility)
		print("lch:",stats.leech)
		print("><><><><><><><><><><><><><><><><><><><><><><")]]
		return true
	end
	
	--Sets player primary stat bonus (caused by wearing appropriate geartype for class) 
	function LFLT_T.setIntArmorBonus()
		local armorSlots = {1,3,5,6,7,8,9,10} --Armor Slot Number 
		local link, armorType
		local mismatch = false
		for k,v in pairs(armorSlots) do
			link = GetInventoryItemLink("player",v)
			if not link then 
				mismatch = true
				break
			end
			armorType,_ = select(7,GetItemInfo(link));
			if not armorType then 
				C_Timer.After(0.5, LFLT_T.setIntArmorBonus)
				return
			end
			if string.lower(armorType) ~= "leather" then
				mismatch = true
				break
			end
		end
		if mismatch == false then 
			LFLT_T.intArmorBonus = 1.05
		else
			LFLT_T.intArmorBonus = 1
		end
	end
	
	
	--[[Updates Character Stats
	Table LFLT.sessionRecords stores a list of the player's stats
	Table spellRecords is a Subtable which stores stats about healing 
		done by spells while player has a specific set of stats
	While function is invoked statCalc entries cannot be added to a table.
		They will be stored in a temp table and passed into the new active LFLT.sessionRecords
	]]  
	function LFLT_T.updateStats()
		LFLT.sessionRecords.active = nil
	
		curStats = {}
		curStats.int, curStats.mst, curStats.hst, 
		curStats.crt, curStats.vrs, curStats.lch, 
		curStats.hstMod, curStats.critBonusOutput = LFLT_T.getStats()
		
		--find matching record
		for _,record  in ipairs(LFLT.sessionRecords) do
			if curStats.int == record.int
			and curStats.mst == record.mst
			and curStats.hst == record.hst
			and curStats.crt == record.crt
			and curStats.vrs == record.vrs
			and curStats.lch == record.lch
			and curStats.hstMod == record.hstMod
			and curStats.critBonusOutput == record.critBonusOutput then
				LFLT.sessionRecords.active = record
				break
			end
		end
		
		--Could not find matching record, creating new one
		if not LFLT.sessionRecords.active then
			local tablePos = #LFLT.sessionRecords + 1
			LFLT.sessionRecords[tablePos] = {
				int = curStats.int,
				mst = curStats.mst,
				hst = curStats.hst,
				crt = curStats.crt,
				vrs = curStats.vrs,
				lch = curStats.lch,
				hstMod = curStats.hstMod,
				critBonusOutput = curStats.critBonusOutput,
				spells = {},
			}
			LFLT.sessionRecords.active = LFLT.sessionRecords[tablePos]
		end
		LFLT_T.setIntArmorBonus()
		LFLT_T.transitionRecords(curStats)
	end
		
	--Core Calcs for Leaflet
	--@param stats: Overrides player stats in case of delayed calculation (due to stat change)
	function LFLT_T.statCalc(stats, ...)
		--[[print(	"Spell Type:", select(2, ...),
				"\nPGUID:", select(4, ...),
				"\nTGUID:", select(9, ...),
				"\nSpell Name:", select(13, ...),
				"\nHeal:", select(15, ...),
				"\nOverheal:", select(16, ...),
				"\nCrtFlag:", select(18, ...))
				
		1 nil, 
		2 healData.sType, 		--spell name
		3 nil, 
		4 UnitGUID("player"),  --Player GUID
		5 nil, 
	    6 nil, 
		7 nil, 
		8 nil, 
		9 nil, 					--Target UnitID (left nil)
		10 nil, 
		11 nil, 
		12 nil,
		13 spellName,			--spell name
		14 nil,
		15 math.max(adjDirHeal, adjHotHeal), 		 --heal amount 
		16 0, 					--Overheal
		17 nil,
		18 false)				--Crit Flag (always left false
		]]		
		
		--Return if casting unit is not player[4] or if overheal is detected[16]
		if select(4, ...) ~= UnitGUID("player") or select(16, ... ) ~= 0 then return end
		
		--If using current player stats and current player stats are unavilable due to stat change
		if not stats then
			if not LFLT.sessionRecords.active then
				local record = ""
				local newRecordPos = #LFLT_T.recordsInTransition +1
				LFLT_T.recordsInTransition[newRecordPos] = {}
				for i=1,select("#", ...) do
						LFLT_T.recordsInTransition[newRecordPos][i] = select(i, ...)
				end
				return
			else
			--if using current player stats
				stats = {}
				stats.int = LFLT.sessionRecords.active.int
				stats.hst = LFLT.sessionRecords.active.hst 
				stats.mst = LFLT.sessionRecords.active.mst
				stats.crt = LFLT.sessionRecords.active.crt
				stats.vrs = LFLT.sessionRecords.active.vrs
				stats.lch = LFLT.sessionRecords.active.lch
				stats.hstMod = LFLT.sessionRecords.active.hstMod
				stats.critBonusOutput = LFLT.sessionRecords.active.critBonusOutput
			end
		end
		local sType 		= select(2, ...)			--spell type
		local destUnit 		= getUnit(select(9, ...))	--Target UnitID
		local sName 		= select(13, ...)			--spell name
		
		local hstFlag, sklFlag, lchFlag
		--Hot Spells (haste effected)
		if sType == "SPELL_PERIODIC_HEAL" then	
			--LFLT_T.leechHaste[destUnit] = true
			if sName == LFLT_T.spells.rejuvenation
			or sName == LFLT_T.spells.germination
			or sName == LFLT_T.spells.lifebloom
			or sName == LFLT_T.spells.wildgrowth
			or sName == LFLT_T.spells.springblossoms
			or sName == LFLT_T.spells.cultivation
			or sName == LFLT_T.spells.cenarionward
			or sName == LFLT_T.spells.regrowth .. "Hot"
				then hstFlag = true 
			elseif sName == LFLT_T.spells.regrowth
				then hstFlag = true
				sName = LFLT_T.spells.regrowth .. "Hot"
			end
			
			
			--Direct Healing Spells (Mostly not Haste Effected)   
		elseif sType == "SPELL_HEAL" then 
			if sName == LFLT_T.spells.leech then
				--hstFlag = LFLT_T.leechHaste[destUnit]
				--LFLT_T.leechHaste[destUnit] = nil
				--lchFlag = true
				
			elseif sName == LFLT_T.spells.efflorescence then 
				hstFlag = true
				--LFLT_T.leechHaste[destUnit] = true
				
			elseif sName == LFLT_T.spells.regrowth then 
				sklFlag = 1
				hstFlag = false
				--LFLT_T.leechHaste[destUnit] = true
				
			elseif sName == LFLT_T.spells.livingseed then
				sklFlag = 2
				hstFlag = false
				--LFLT_T.leechHaste[destUnit] = false
				
			elseif sName == LFLT_T.spells.swiftmend
			or sName == LFLT_T.spells.healingtouch
			or sName == LFLT_T.spells.lifebloom
			or sName == LFLT_T.spells.dreamwalker
			then 
				hstFlag = false 
				--LFLT_T.leechHaste[destUnit] = true
			
			elseif sName == LFLT_T.spells.tranquility 
			and LFLT.option.ignoreTranquilityEnable then
				hstFlag = false 
			end
		end
	
		--If hstFlag == nil, 
		--healing was not done by a spell in the above listing. 
		--ie: Ysera's gift is uneffected by secondaries		
		if hstFlag ~= nil then 
	
			local heal 	= select(15, ...)	--heal amount (including overheal)
			local crtFlag = select(18, ...)	--Crit Flag
			--Mastery Percentage
			local hCount = LFLT.hotCounter(destUnit)
			if hCount == -1 then return end
			local mst = 1 + ((stats.mst - 1) * hCount)
			
			--Get Base Heal
			if crtFlag == true then
				heal = heal / (2 * stats.critBonusOutput)
			end
			
			local crt
			--Crit Percentage (Bonus)
			if sklFlag == 1 then 
				if overHeal ~= 0 then return end
				crt = (stats.crt +  LFLT_T.REGROWTHBASECRT) * stats.critBonusOutput
			else  
				crt = stats.crt * stats.critBonusOutput
			end
			
			--Spell Coeff.
			local HPCT, intHPC, mstHPC, hstHPC, crtHPC, vrsHPC, intHPT, mstHPT, hstHPT, crtHPT, vrsHPT, lchHPC, lchHPT
			--Heal Per Cast Time 
			
			----Haste Calc
			if hstFlag then
				hstHPC = (heal / stats.hst) * (stats.hstMod / LFLT_T.HSTRATINGCONV)
				hstHPT = (heal / (stats.hst^2)) * stats.hstMod * (LFLT_T.HSTRATINGCONV + stats.hst) / LFLT_T.HSTRATINGCONVSPCVAL
			else
				hstHPC = 0
				hstHPT = (heal / stats.hst) * (stats.hstMod / LFLT_T.HSTRATINGCONV)
			end
			
			----HPC: Mastery Calc
			mstHPC = heal / mst * (hCount / LFLT_T.MSTRATINGCONV )	
			----HPC: Crit Calc
			crtHPC = heal / crt * (stats.critBonusOutput / LFLT_T.CRTRATINGCONV)
			----HPC: Versatility Calc
			vrsHPC = heal / (stats.vrs * LFLT_T.VRSRATINGCONV)
			----HPC: Intellect Calc
			intHPC = heal / stats.int * LFLT_T.intArmorBonus 
						
			----HPCT: Mastery Calc
			mstHPT = mstHPC * stats.hst
			----HPCT: Crit Calc
			crtHPT = crtHPC * stats.hst
			----HPCT: Versatility Calc
			vrsHPT = vrsHPC * stats.hst
			----HPCT: Intellect Calc
			intHPT = intHPC * stats.hst
			
			----Leech Calc
			--[[if lchFlag then
				lchHPC = heal / (stats.lch * LFLT_T.LCHRATINGCONV)
				lchHPT = lchHPC * stats.hst
				LFLT_T.score.cur_lch_hpc = LFLT_T.score.cur_lch_hpc + lchHPC
				LFLT_T.score.cur_lch_hpt = LFLT_T.score.cur_lch_hpt + lchHPT
			end]]
			--allocate
			--HPC:Current Encounter Healing Score Allocation
			LFLT_T.score.cur_int_hpc = LFLT_T.score.cur_int_hpc + intHPC
			LFLT_T.score.cur_mst_hpc = LFLT_T.score.cur_mst_hpc + mstHPC
			LFLT_T.score.cur_hst_hpc = LFLT_T.score.cur_hst_hpc + hstHPC
			LFLT_T.score.cur_crt_hpc = LFLT_T.score.cur_crt_hpc + crtHPC
			LFLT_T.score.cur_vrs_hpc = LFLT_T.score.cur_vrs_hpc + vrsHPC

			--HPC:Total Healing Score Allocation
			LFLT_T.score.ttl_int_hpc = LFLT_T.score.ttl_int_hpc + intHPC
			LFLT_T.score.ttl_mst_hpc = LFLT_T.score.ttl_mst_hpc + mstHPC
			LFLT_T.score.ttl_hst_hpc = LFLT_T.score.ttl_hst_hpc + hstHPC
			LFLT_T.score.ttl_crt_hpc = LFLT_T.score.ttl_crt_hpc + crtHPC
			LFLT_T.score.ttl_vrs_hpc = LFLT_T.score.ttl_vrs_hpc + vrsHPC

			--HPCT:Current Encounter Healing Score Allocation
			LFLT_T.score.cur_int_hpt = LFLT_T.score.cur_int_hpt + intHPT
			LFLT_T.score.cur_mst_hpt = LFLT_T.score.cur_mst_hpt + mstHPT
			LFLT_T.score.cur_hst_hpt = LFLT_T.score.cur_hst_hpt + hstHPT
			LFLT_T.score.cur_crt_hpt = LFLT_T.score.cur_crt_hpt + crtHPT
			LFLT_T.score.cur_vrs_hpt = LFLT_T.score.cur_vrs_hpt + vrsHPT

			--HPCT:Total Healing Score Allocation
			LFLT_T.score.ttl_int_hpt = LFLT_T.score.ttl_int_hpt + intHPT
			LFLT_T.score.ttl_mst_hpt = LFLT_T.score.ttl_mst_hpt + mstHPT
			LFLT_T.score.ttl_hst_hpt = LFLT_T.score.ttl_hst_hpt + hstHPT
			LFLT_T.score.ttl_crt_hpt = LFLT_T.score.ttl_crt_hpt + crtHPT
			LFLT_T.score.ttl_vrs_hpt = LFLT_T.score.ttl_vrs_hpt + vrsHPT
			
			LFLT_T.updateDisplay(1)
			LFLT_T.recordInsert(heal, sName, sType, hCount)
		end  
	end
end
