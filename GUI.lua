--Author Manaleaf - Sargeras
--GUI for Leaflet

function LFLT_A.GUI()
	
	--GUI local variables
	local auxBGTexture						= "Interface\\Addons\\Leaflet\\Media\\Images\\Aux Background"
	local auxInnerBGTexture_1x1 			= "Interface\\Addons\\Leaflet\\Media\\Images\\Aux Inner Background 1x1"
	local auxInnerBGTexture_1x2 			= "Interface\\Addons\\Leaflet\\Media\\Images\\Aux Inner Background 1x2"
	local auxInnerBGTexture_2x1 			= "Interface\\Addons\\Leaflet\\Media\\Images\\Aux Inner Background 2x1"
	local bannerTexture 					= "Interface\\addons\\Leaflet\\Media\\Images\\Leaflet Banner"
	local buttonNormalTexture 				= "Interface\\Addons\\Leaflet\\Media\\Images\\Square Button"
	local buttonPushedTexture 				= "Interface\\Addons\\Leaflet\\Media\\Images\\Square Button Pushed"
	local buttonHighlightTexture 			= "Interface\\Addons\\Leaflet\\Media\\Images\\Square Button Highlight"
	local closeButton						= "Interface\\Addons\\Leaflet\\Media\\Images\\Close Frame Button"
	local displayButton						= "Interface\\Addons\\Leaflet\\Media\\Images\\Leaf Icon"
	local defaultCheckedTexture				= "Interface\\Addons\\Leaflet\\Media\\Images\\Check"
	local checkboxBorder					= "Interface\\Addons\\Leaflet\\Media\\Images\\Checkbox Border"
	local defaultSliderThumbTexture			= "Interface\\Buttons\\UI-SliderBar-Button-Horizontal"
	local defaultBorder						= "Interface\\Addons\\Leaflet\\Media\\Images\\border"
	local defaultBackdropBGFile				= "Interface\\DialogFrame\\UI-DialogBox-Background"
	local defaultBackdropEdgeFile			= "Interface\\DialogFrame\\UI-DialogBox-Border"
	local defaultBackdrop2BGFile			= "Interface\\Addons\\Leaflet\\Media\\Images\\Green Forest"
	local historyNormalTexture				= "Interface\\Addons\\Leaflet\\Media\\Images\\Square Button Long"
	local historyPushedTexture 				= "Interface\\Addons\\Leaflet\\Media\\Images\\Square Button Pushed Long"
	local historyHighlightTexture			= "Interface\\Addons\\Leaflet\\Media\\Images\\Square Button Highlight Long"
	local leftArrowButtonNormalTexture 		= "Interface\\Addons\\Leaflet\\Media\\Images\\Button Left Arrow Unpushed"
	local leftArrowButtonHighlightTexture 	= "Interface\\Addons\\Leaflet\\Media\\Images\\Button Left Arrow Glow"
	local replayPushedTexture 				= "Interface\\Addons\\Leaflet\\Media\\Images\\Replay Button"
	local replayHighlightTexture			= "Interface\\Addons\\Leaflet\\Media\\Images\\Replay Button Highlight"
	local replayNormalTexture 				= "Interface\\Addons\\Leaflet\\Media\\Images\\Replay Button"
	local rightArrowButtonNormalTexture 	= "Interface\\Addons\\Leaflet\\Media\\Images\\Button Right Arrow Unpushed"
	local rightArrowButtonHighlightTexture 	= "Interface\\Addons\\Leaflet\\Media\\Images\\Button Right Arrow Glow"
	local talentFrameTexture 				= "Interface\\addons\\Leaflet\\Media\\Images\\Talent Frame"
	local defaultFontSize					= 12
	local items = {	--Table containing Proceedurally generated frames/options
		directory 		= {"Settings", "History", "FAQ"},
		contentType		= {	"raid", "mythicdungeon", "dungeonnonmythic"},
		location 		= {	"incombat", "bossencounter", "outofcombat"},
		historySearch 	= {	"kill", "wipe", "raid", "mythicdungeon", "dungeonnonmythic"},
		hasteDisplay	= {	"cast", "casttime"},
		precision		= {"0.123", "0.12", "0.1"},
		icon			= {"displaylock", "hideicon"},
	}
	local historyButtonNum 		= 10
	local defaultBackdrop = 	{
		bgFile = defaultBackdropBGFile,
		edgeFile = defaultBorder,
		tile = false,
		edgeSize = 10
	}	
	
	local defaultBackdrop2 = 	{
		bgFile= defaultBackdrop2BGFile,
		edgeFile= defaultBorder,
		tile = false,
		edgeSize = 10,
		insets = {left = 1, right = 1, top = 1, bottom = 1}
	}
	
	local checkboxBackdrop = 	{
		bgFile = defaultBackdropBGFile,
		edgeFile = defaultBorder,--checkboxBorder,
		tile = false,
		edgeSize = 8,
	}	
	
	--Transfers attributes of multi-level frameObj templates into a single table.
	function LFLT_T.frameObjParser(frameAttr)
		local frameObj = {}
		local templateList = {}
		local templateCount = 0
		local curTemplate
		--Iterates through all templates which reference other templates
		if frameAttr.template then 
			curTemplate = frameAttr.template
			while curTemplate do
				templateCount = templateCount + 1
				tinsert(templateList, curTemplate)
				if curTemplate.template then curTemplate = curTemplate.template
				else curTemplate = nil end
			end
		end
		--In reverse order (Futher referenced template first) copies values of each template
		for i=1,#templateList do
			local k = #templateList - i + 1
			for j,w	in pairs(templateList[k]) do
				if w == "nil" then
					frameObj[j] = nil
				else
					frameObj[j] = w
				end
			end
		end
		--Overwrite template with object attributes
		for k,v in pairs(frameAttr) do
			if v == "nil" then
				frameObj[k] = nil
			else
				frameObj[k] = v
			end
		end
		
		return frameObj
	end
	
	--Individual Frame Generator
	function LFLT_T.frameGen(frameAttr, ...)
		local frame, parent, UITemplate
		local frameObj = LFLT_T.frameObjParser(frameAttr)
		--Auxiliary attribute overwrite
		if ... then
			for k,v in pairs(...) do
				if v == "nil" then
					frameObj[k] = nil
				else
					frameObj[k] = v
				end
			end
		end
		
		--Defaults 
		if not frameObj.xOff then frameObj.xOff = 0 end
		if not frameObj.yOff then frameObj.yOff = 0 end
		if not frameObj.width then frameObj.width = 0 end
		if not frameObj.height then frameObj.height = 0 end
		if not frameObj.pointOnFrame then frameObj.pointOnFrame = "CENTER" end
		if frameObj.parent then 
			parent = _G[frameObj.parent] 
			if not parent then 
				LFLT_T.print("Attempt to create parent frame:" .. frameObj.parent .. "is not a frame.") 
			end
		else
			parent = UIParent
		end
		local fType = strupper(frameObj.fType)
		--Frame Creation
		frameObj.fType = string.upper(frameObj.fType)
		if fType == "FRAME" then 
			frame = CreateFrame("Frame", frameObj.name, parent)
		--Text
		elseif fType == "TEXT" then 
			frame = parent:CreateFontString(frameObj.name)
			--Text Defaults
			if not frameObj.fontSize then frameObj.fontSize = 18 end
			if not frameObj.fontFlags then frameObj.fontFlags = "OUTLINE" end
			frame:SetFont(frameObj.font or LFLT_T.vixarFont, frameObj.fontSize, frameObj.fontFlags)
			if frameObj.hJustify then frame:SetJustifyH(frameObj.hJustify) end
			if frameObj.vJustify then frame:SetJustifyV(frameObj.vJustify) end
			if frameObj.text then frame:SetText(frameObj.text) end
		--Button
		elseif fType == "BUTTON" then
			frame = CreateFrame("Button", frameObj.name, parent)
			if frameObj.normalTexture then --set Normal Texture
				if normalTextureMode then
					frame:SetNormalTexture(frameObj.normalTexture, frameObj.normalTextureMode)
				else
					frame:SetNormalTexture(frameObj.normalTexture)
				end
			else
				frame:SetNormalTexture(buttonNormalTexture)
			end
			if frameObj.highlightTexture then --set Highlight Texture
				if highlightTextureMode then
					frame:SetHighlightTexture(frameObj.highlightTexture, frameObj.highlightTextureMode)
				else
					frame:SetHighlightTexture(frameObj.highlightTexture)
				end
			else
				frame:SetHighlightTexture(buttonHighlightTexture)
			end
			if frameObj.pushedTexture then --set pushed Texture
				if pushedTextureMode then
					frame:SetPushedTexture(frameObj.pushedTexture, frameObj.pushedTextureMode)
				else
					frame:SetPushedTexture(frameObj.pushedTexture)
				end
			else
				frame:SetPushedTexture(buttonpushedTexture)
			end
			
			if frameObj.disabledTexture then --Set Disabled Texture
				frame:SetDisabledTexture(frameObj.disabledTexture)
			else
				if frameObj.normalTexture then
					frame:SetDisabledTexture(frameObj.normalTexture)
				else
					frame:SetDisabledTexture(buttonNormalTexture)
				end
			end 
			frame.disabledtexture = frame:GetDisabledTexture()
			frame.disabledtexture:SetDesaturated(1);
			frame.disabledtexture:SetVertexColor(0.5,0.5,0.5)
			frame:SetScript("OnClick", function() frameObj:clickFunc(frameObj, frameObj.arg1, frameObj.arg2) end) 

		--Dropdown
		elseif fType == "DROPDOWN" then
			if frameObj.noUITemplate then 
				UITemplate = frameObj.noUITemplate
			else 
				UITemplate = "UIDropDownMenuTemplate" 
			end
			frame = CreateFrame("Button", frameObj.name, parent, UITemplate)
			frame:ClearAllPoints()
			frameObj.pointSetAlready = 1
			frame:SetPoint(	frameObj.pointOnFrame, frameObj.parent, 
							frameObj.pointOnParent or frameObj.pointOnFrame, 
							frameObj.xOff, frameObj.yOff)
			--Initialize Function
			if frameObj.dropList then
				UIDropDownMenu_Initialize(frame, function(self, level)
					local info = UIDropDownMenu_CreateInfo()
					for k,v in ipairs(frameObj.dropList) do
						info = UIDropDownMenu_CreateInfo()
						info.text = v
						info.value = v
						info.func = frameObj.clickFunc
						info.arg1 = v
						info.arg2 = frame
						UIDropDownMenu_AddButton(info, level)
					end
				end)
				if frameObj.selected then
					if type(frameObj.selected) == "number" then
						UIDropDownMenu_SetSelectedID(frame, frameObj.selected)
					else
						UIDropDownMenu_SetSelectedValue(frame, frameObj.selected)
					end
				end
			end
			UIDropDownMenu_SetWidth(frame, frameObj.width);
			UIDropDownMenu_SetButtonWidth(frame, frameObj.buttonWidth or frameObj.width)
			if frameObj.hJustify then UIDropDownMenu_JustifyText(frame, frameObj.hJustify) end
		--Checkbox
		elseif fType == "CHECKBOX" then
			
			if frameObj.noUITemplate then 
				UITemplate = frameObj.noUITemplate
			else 
				UITemplate = "UICheckButtonTemplate" 
			end
			frame = CreateFrame("CheckButton", frameObj.name, parent, UITemplate)
			frame:SetScript("OnClick", function() frameObj:checkedFunc(frame, frameObj.arg1) end)
			
			if frameObj.noUITemplate then
				if frameObj.checkedTexture then
					frame:SetCheckedTexture(frameObj.checkedTexture)
				end
			end
					
		--Editbox
		elseif fType == "EDITBOX" then
			if frameObj.noUITemplate then 
				UITemplate = frameObj.noUITemplate
			else 
				UITemplate = "InputBoxTemplate" 
			end
			frame = CreateFrame("EditBox", frameObj.name, parent, UITemplate)
			if frameObj.boxAutoFocus then 
				frame:SetAutoFocus(frameObj.boxAutoFocus) 
			else 
				frame:SetAutoFocus(false)
			end
			if frameObj.boxNumeric then 
				frame:SetNumeric() 
				
			if frameObj.numeric then 
				frame:SetNumber(frameObj.numeric) end
			else
				if frameObj.text then frame:SetText(frameObj.text) end
			end
			
			if frameObj.textInset then
				frame:SetTextInsets(frameObj.textInset.left, frameObj.textInset.right, 
									frameObj.textInset.top, frameObj.textInset.bottom)
			end
			
			if not frameObj.fontSize then frameObj.fontSize = 18 end
			if not frameObj.fontFlags then frameObj.fontFlags = "OUTLINE" end
			frame:SetFont(frameObj.font or LFLT_T.vixarFont, frameObj.fontSize, frameObj.fontFlags)
			
			if frameObj.hJustify then frame:SetJustifyH(frameObj.hJustify) end
			if frameObj.vJustify then frame:SetJustifyV(frameObj.vJustify) end
			if frameObj.highlightOnClick 	then frame:SetScript("OnMouseUp", function() frame:HighlightText() end) end
			if frameObj.enterpushedFunc 	then frame:SetScript("OnEnterPressed", function() frameObj:enterpushedFunc() end) end
			if frameObj.escapepushedFunc 	then frame:SetScript("OnEscapePressed", function() frameObj:escapepushedFunc() end) end
			frame:ClearFocus()
		--Slider
		elseif fType == "SLIDER" then	
			if frameObj.noUITemplate then 
				UITemplate = frameObj.noUITemplate
			else 
				UITemplate = "OptionsSliderTemplate" 
			end
			frame = CreateFrame("Slider", frameObj.name, parent, UITemplate)
			if frameObj.orientation then
				frame:SetOrientation(frameObj.orientation) 
			else
				frame:SetOrientation("horizontal") 
			end
			
			local minVal = 1
			local maxVal = 100
			
			if frameObj.minValue then minVal = frameObj.minValue end
			if frameObj.maxValue then maxVal = frameObj.maxValue end
			frame:SetMinMaxValues(minVal,maxVal)
			
			local minText = "1"
			local maxText = "100"
			if frameObj.setMinMaxText then
				if frameObj.minText then 
					minText = frameObj.minText 
				elseif minVal then
					minText = tostring(frameObj.minValue)
				end
				if frameObj.maxText then 
					maxText = frameObj.maxText 
				elseif maxVal then
					maxText = tostring(frameObj.maxValue)
				end
			end
				
			_G[frameObj.name .. "Low"]:SetText(frameObj.minValue)
			_G[frameObj.name .. "High"]:SetText(frameObj.maxValue)
			
			if frameObj.startValue then 
				frame:SetValue(frameObj.startValue)
			else
				frame:SetVale(math.floor((maxVal - minVal)/2))
			end
			
			if frameObj.stepValue then
				frame:SetValueStep(frameObj.stepValue)
			else
				frame:SetValueStep(1)
			end
			
			if frameObj.thumbTexture then 
				frame:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
			else
				frame:SetThumbTexture(defaultSliderThumbTexture)
			end
			
			frame:SetScript("OnMouseUp", 
			function(self) 
				frameObj:clickFunc(frame:GetValue()) 
			end) 
		--tooltip
		elseif fType == "TOOLTIP" then	
			if frameObj.noUITemplate then 
				UITemplate = frameObj.noUITemplate
			else 
				UITemplate = "GameTooltipTemplate" 
			end
			frame = CreateFrame("GameToolTip", frameObj.name, parent, UITemplate)
			local wrap 
			if frameObj.wrap then wrap = true end
			if frameObj.lines then
				for i=1, frameObj.lines do
					frame:AddLine("","",1,1,1,wrap)
				end
			end
			if frameObj.doubleLines then
				for i=1, frameObj.doubleLines do
					frame:AddDoubleLine("","",1,1,1,1,1,1)
				end
			end		
		end
		--Debugg Print
		if not frame then LFLT_T.print("UNSUCCESSFUL CHECKBOX CREATION", frameObj.name) end
		--Set Point
		if frameObj.transcribe then frame:SetAllPoints(frameObj.transcribe)
		else
			if not frameObj.pointSetAlready then
				frame:SetPoint(frameObj.pointOnFrame, parent, 
				frameObj.pointOnParent or frameObj.pointOnFrame, frameObj.xOff, frameObj.yOff)
			end
			frame:SetSize(frameObj.width, frameObj.height)
			if frameObj.strata then frame:SetFrameStrata(frameObj.strata) end
			if frameObj.level then frame:SetFrameLevel(frameObj.level) end
		end
		--Texture 
		if frameObj.texture then
			local texture
			if frameObj.textureAttr then 
				texture = frame:CreateTexture(	frameObj.name .. "_Texture", 
												frameObj.textureAttr.drawLayer, 
												frameObj.textureAttr.inherits)
				texture:SetTexture(frameObj.texture, frameObj.textureAttr.tile)
				if	frameObj.textureAttr.color then 
					texture:SetTexture( frameObj.textureAttr.color.r,
										frameObj.textureAttr.color.g,
										frameObj.textureAttr.color.b,
										frameObj.textureAttr.color.a)
				end
				if frameObj.textureAttr.hMirror then --Horizontal Image Flip
					local ULx,ULy,LLx,LLy,URx,URy,LRx,LRy = texture:GetTexCoord()
					texture:SetTexCoord(URx,ULy,LRx,LLy,ULx,URy,LLx,LRy)
				end
				if frameObj.textureAttr.vMirror then --Horizontal Image Flip
					local ULx,ULy,LLx,LLy,URx,URy,LRx,LRy = texture:GetTexCoord()
					texture:SetTexCoord(ULx,LLy,LLx,ULy,URx,LRy,LRx,URy)
				end
			else
				texture = frame:CreateTexture(frameObj.name .. "_Texture")
				texture:SetTexture(frameObj.texture)
			end
			texture:SetAllPoints(frame)
		end
		if frameObj.backdrop then frame:SetBackdrop(frameObj.backdrop) end
		if frameObj.drawLayer then frame:SetDrawLayer(frameObj.drawLayer) end
		if frameObj.color then frame:SetTextColor(	frameObj.color[1], frameObj.color[2], 
													frameObj.color[3], frameObj.color[4]) end
		if frameObj.func then frameObj:func(frameObj.arg1, frameObj.arg2) end
		return frame
	end
			
	--Creates a index style set of button frames.
	local function indexGen(index, frameObj, textObj, Dimension, indexType)
		local itemNum
		local setButtonText = false
		--Item var type determines whether button text is set on button creation.
		if type(index) == "number" then
			itemNum = index
		elseif type(index) == "table" then
			itemNum = #index
			setButtonText = true
		end
		--Index Type determines positioning of buttons
		local height, width, xJump, yJump, buttonText, nameAppend
		if indexType == "TABS" then 
			height 	= frameObj.height
			width 	= Dimension / itemNum
			xJump	= width 
			yJump 	= 0 
		elseif not indexType or indexType == "INDEX" then
			height 	= Dimension / itemNum
			width 	= frameObj.width
			xJump	= 0 
			yJump 	= height
		end
		for i = 1, itemNum do
			if setButtonText then --Item type is table
				nameAppend = index[i]
				buttonText = index[i]
			else                  --Item type is number
				nameAppend = i
				buttonText = nil
			end

			LFLT_T.frameGen(frameObj, { --Create Button Frame
			name = frameObj.name .. "_" .. nameAppend, 
			["height"] = height, 
			["width"] = width,
			xOff = frameObj.xOff + (xJump * (i-1)), 
			yOff = frameObj.yOff - (yJump * (i-1)),
			arg1 = {
			selected = i,
			frameNum = itemNum
			}})
			LFLT_T.frameGen(textObj, { --Create Button Text
			name = textObj.name .. "_" .. nameAppend, 
			parent = frameObj.name .. "_" .. nameAppend,
			["height"] = height,
			["width"] = width,
			text = buttonText,
			arg1 = textObj.name .. "_" .. nameAppend,
			arg2 = frameObj.name .. "_" .. nameAppend
			})
		end
	end
		
	--Creates a row-col box style set of checkbox frames.
	local function checkBoxGen(	index, 		frameAttr, 	textObj, 	contentType, 	title, 	ttlWidth, 	
								ttlHeight, 	frameXPos, 	frameYPos, 	cols,  checkBoxIndent, backdrop)
		local frameObj = LFLT_T.frameObjParser(frameAttr)
		frameObj.template = nil
		local indent 			= checkBoxIndent or 10
		local rows 				= ceil(#index / cols)
		local height 
		local width = (ttlWidth - frameObj.width - indent * 2) / (cols)
		if rows == 1 then
			height = ttlHeight - frameObj.height - indent * 2
		else 
			height = (ttlHeight - frameObj.height - indent * 2) / (rows-1)
		end

		--Create background frame
		local bgFrame = LFLT_T.frameGen(frameObj, 
			{
			fType = "FRAME", 
			name = frameObj.name .. "_Background_Frame",
			xOff = frameXPos, yOff = frameYPos, 
			width = ttlWidth, height = ttlHeight,
			func = "nil", checkedFunc = "nil",
			["backdrop"] = backdrop or defaultBackdrop
			})
		--Create background frame title
		LFLT_T.frameGen(textObj, 
			{ 
			name = frameObj.name .. "_Background_Frame_Title", 
			parent = frameObj.name .. "_Background_Frame",
			xOff = 0, yOff = 25,  width = ttlWidth,
			parent = frameObj.name .. "_Background_Frame",
			pointOnFrame = "TOPLEFT", pointOnParent = "TOPLEFT",
			text = title, func = "nil"
			})
		--Create individual checkbox frames
		local checkboxFrame, colPos, rowPos
		for i,v in ipairs(index) do
			colPos = mod(i-1, cols) * width + indent
			rowPos = math.floor((i-1)/cols) * height * -1 - indent
			checkboxFrame = LFLT_T.frameGen(frameObj, {
			name = frameObj.name .. "_" .. contentType[v].id,
			parent = frameObj.name .. "_Background_Frame",
			xOff = colPos, yOff = rowPos, 
			strata = "High", arg1 = contentType[v]
			})
			LFLT_T.frameGen(textObj, {
			parent = frameObj.name .. "_" .. contentType[v].id,
			pointOnFrame = "LEFT", pointOnParent = "RIGHT", ["width"] = width, 
			drawLayer = "OVERLAY", text = contentType[v].name
			})
			checkboxFrame:Show()
			if contentType[v].enabled == true then
				checkboxFrame:SetChecked(true)
			else 
				checkboxFrame:SetChecked(false)
			end
		end
	end
	
	--Updates Display Frame  Text 
	--@param caller
	----1 if call is result of outside call 
	------This attempts to start update ticker
	----2 if call is from ticker or one-time-update call
	----3 if call is from ticker ending
	function LFLT_T.updateDisplay(call)
		--Manual Override for Replay System
		if LFLT_T.manualOverride.updateDisplay then return end
		if call == 1 then
			if LFLT_T.displayUpdaterActive == true then
				return
			else
				LFLT_T.displayUpdaterActive = true 
				C_Timer.NewTicker(0.25,
					function()
						LFLT_T.updateDisplay(2)
					end
				, 20)
				
				C_Timer.After(10.2, function()  
						LFLT_T.updateDisplay(3)
				end)
			end
		elseif call == 3 then
			LFLT_T.displayUpdaterActive = false
			return
		end

		local maxCurHeal, selectedCurMax = LFLT.maxButNotZero(0.001,LFLT_T.score.cur_int_hpc, LFLT_T.score.cur_mst_hpc, LFLT_T.score.cur_hst_hpc, 
																	LFLT_T.score.cur_crt_hpc, LFLT_T.score.cur_vrs_hpc) 
		local maxTtlHeal, selectedTtlMax = LFLT.maxButNotZero(0.001,LFLT_T.score.ttl_int_hpc, LFLT_T.score.ttl_mst_hpc, LFLT_T.score.ttl_hst_hpc, 
																	LFLT_T.score.ttl_crt_hpc, LFLT_T.score.ttl_vrs_hpc) 
		
		--HPC:Current Encounter Healing Score Allocation
		local cur_int_hpc = LFLT_T.score.cur_int_hpc / maxCurHeal
		local cur_mst_hpc = LFLT_T.score.cur_mst_hpc / maxCurHeal
		local cur_hst_hpc = LFLT_T.score.cur_hst_hpc / maxCurHeal
		local cur_crt_hpc = LFLT_T.score.cur_crt_hpc / maxCurHeal
		local cur_vrs_hpc = LFLT_T.score.cur_vrs_hpc / maxCurHeal
		local cur_lch_hpc = LFLT_T.score.cur_lch_hpc / maxCurHeal
		
		--HPC:Total Healing Score Allocation
		local ttl_int_hpc = LFLT_T.score.ttl_int_hpc / maxTtlHeal
		local ttl_mst_hpc = LFLT_T.score.ttl_mst_hpc / maxTtlHeal
		local ttl_hst_hpc = LFLT_T.score.ttl_hst_hpc / maxTtlHeal
		local ttl_crt_hpc = LFLT_T.score.ttl_crt_hpc / maxTtlHeal
		local ttl_vrs_hpc = LFLT_T.score.ttl_vrs_hpc / maxTtlHeal
		local ttl_lch_hpc = LFLT_T.score.ttl_lch_hpc / maxTtlHeal
		
		maxCurHeal,_ = select(selectedCurMax, 0.001, 	LFLT_T.score.cur_int_hpt, LFLT_T.score.cur_mst_hpt, LFLT_T.score.cur_hst_hpt, 
														LFLT_T.score.cur_crt_hpt, LFLT_T.score.cur_vrs_hpt) 
		maxTtlHeal,_ = select(selectedTtlMax, 0.001,	LFLT_T.score.ttl_int_hpt, LFLT_T.score.ttl_mst_hpt, LFLT_T.score.ttl_hst_hpt, 
														LFLT_T.score.ttl_crt_hpt, LFLT_T.score.ttl_vrs_hpt) 
		
		--HPCT:Current Encounter Healing Score Allocation
		local cur_hst_hpt = LFLT_T.score.cur_hst_hpt / maxCurHeal
		--HPCT:Total Healing Score Allocation 
		local ttl_hst_hpt = LFLT_T.score.ttl_hst_hpt / maxTtlHeal
		
		--Composite Haaste
		local cur_hst_com = cur_hst_hpc * (1 - LFLT.hasteCompositeRatio) + cur_hst_hpt * LFLT.hasteCompositeRatio
		local ttl_hst_com = ttl_hst_hpc * (1 - LFLT.hasteCompositeRatio) + ttl_hst_hpt * LFLT.hasteCompositeRatio
		
		if _G[LFLT_F.displayFrameIconObj.name]:IsVisible() then
			local statFormat = "\n%12s: "
			local dataFormat = "\n%-5." .. tostring(LFLT.option.displayPrecision) .. "f"
			local outString1, outString2, outData1, outData2
			local hstText1, hstCurDataText1, hstTtlDataText1 = "","",""
			local hstText2, hstCurDataText2, hstTtlDataText2 = "","",""
			--Haste Display
			if LFLT.enabledHaste.cast.enabled then
				hstText1		= string.format(statFormat, "Haste[C]")
				hstCurDataText1 = string.format(dataFormat, cur_hst_hpc)
				hstTtlDataText1 = string.format(dataFormat, ttl_hst_hpc)
			end
			if LFLT.enabledHaste.casttime.enabled then
				hstText2 		= string.format(statFormat, "Haste[T]")
				hstCurDataText2 = string.format(dataFormat, cur_hst_hpt)
				hstTtlDataText2 = string.format(dataFormat, ttl_hst_hpt)
			end
			
			outString1 = string.format(statFormat .. statFormat .. statFormat .. "%s" ..  "%s" .. statFormat .. statFormat,
						"Current", "Intellect", "Crit", hstText1, hstText2, "Mastery", "Versatility")
			outString2 = string.format(statFormat .. statFormat .. statFormat .. "%s" ..  "%s" .. statFormat .. statFormat,
						"Total", "Intellect", "Crit", hstText1, hstText2, "Mastery", "Versatility")
			outData1 = string.format("\n" .. dataFormat .. dataFormat .. "%s" ..  "%s" ..  dataFormat .. dataFormat,
						cur_int_hpc, cur_crt_hpc, 
						hstCurDataText1, hstCurDataText2,
						cur_mst_hpc, cur_vrs_hpc)
			outData2 = string.format("\n" .. dataFormat .. dataFormat .. "%s" ..  "%s" ..  dataFormat .. dataFormat,
						ttl_int_hpc, ttl_crt_hpc, 
						hstTtlDataText1, hstTtlDataText2,
						ttl_mst_hpc, ttl_vrs_hpc)
			_G[LFLT_F.displayTextObj1.name]:SetText(outString1)
			_G[LFLT_F.displayDataTextObj1.name]:SetText(outData1)
			_G[LFLT_F.displayTextObj2.name]:SetText(outString2)
			_G[LFLT_F.displayDataTextObj2.name]:SetText(outData2)
		end
	end	
	
	--Show/Hide Display Frame
	function LFLT_T.updateDisplayVisibility()
		local displayShown = _G[LFLT_F.displayFrameIconObj.name]:IsVisible()
		local frame = _G[LFLT_F.displayFrameIconObj.name]
		if not LFLT.option.displayToggle then 
			if displayShown then
				frame:Hide()
			end
		else
			if LFLT_T.inCombat then
				if LFLT.enabled["incombat"].enabled and not displayShown then
					frame:Show()
				elseif not LFLT.enabled["incombat"].enabled and displayShown then
					frame:Hide()
				end
			else --if not in combat
				if LFLT.enabled["outofcombat"].enabled and not displayShown and not LFLT_T.inCombat then
					frame:Show()
				elseif not LFLT.enabled["outofcombat"].enabled and displayShown and not LFLT_T.inCombat then
					frame:Hide()
				end
			end		
			if LFLT.session == "raid" then
				if LFLT.enabled["bossencounter"].enabled and not displayShown then
					frame:Show()
				elseif not LFLT.enabled["bossencounter"].enabled and displayShown then
					frame:Hide()
				end
			end
		end
		LFLT_T.updateDisplay()
	end
	
	--Sets Orientation of Display Text
	function LFLT_T.SetDisplayTextPos()
		local frame = _G[LFLT_F.displayFrameIconObj.name]
		_G[LFLT_F.displayTextObj1.name]:ClearAllPoints()
		_G[LFLT_F.displayDataTextObj1.name]:ClearAllPoints()
		_G[LFLT_F.displayTextObj2.name]:ClearAllPoints()
		_G[LFLT_F.displayDataTextObj2.name]:ClearAllPoints()
		_G[LFLT_F.displayTextObj3.name]:ClearAllPoints()
		if LFLT.option.displayOrientation == "Horizontal" then
			_G[LFLT_F.displayTextObj1.name]:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
			_G[LFLT_F.displayDataTextObj1.name]:SetPoint("TOPLEFT", frame, "TOPLEFT", 90, 0)
			_G[LFLT_F.displayTextObj2.name]:SetPoint("TOPLEFT", frame, "TOPLEFT", 115, 0)
			_G[LFLT_F.displayDataTextObj2.name]:SetPoint("TOPLEFT", frame, "TOPLEFT", 205, 0)
			_G[LFLT_F.displayTextObj3.name]:SetPoint("LEFT", frame, "RIGHT", -20, 10)
		elseif LFLT.option.displayOrientation == "Vertical" then
			_G[LFLT_F.displayTextObj1.name]:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
			_G[LFLT_F.displayDataTextObj1.name]:SetPoint("TOPLEFT", frame, "TOPLEFT", 90, 0)
			_G[LFLT_F.displayTextObj2.name]:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -100)
			_G[LFLT_F.displayDataTextObj2.name]:SetPoint("TOPLEFT", frame, "TOPLEFT", 90, -100)
			_G[LFLT_F.displayTextObj3.name]:SetPoint("LEFT", frame, "RIGHT", -20, 10)
		end 
		local icon = _G[LFLT_F.displayFrameIconObj.name]
		if LFLT.option.lock and LFLT.option.hideIcon and icon:GetNormalTexture() then
			icon:SetNormalTexture(nil)
			icon:EnableMouse(false)
		elseif not icon:GetNormalTexture() then
		print("CHECK")
			icon:EnableMouse(true)
			icon:SetNormalTexture(LFLT_F.displayFrameIconObj.normalTexture)
		end		
	end
	
	--Saves Display Position between play sessions
	function LFLT_T.saveDisplayPosition()
		local disPos = LFLT.option.displayPos
		disPos.pointOnFrame, disPos.parent, 
		disPos.pointOnParent, disPos.displayXPos, disPos.displayYPos,_ 
		= _G[LFLT_F.displayFrameIconObj.name]:GetPoint()
	end
	
	--Enables Drag for the display
	function LFLT_T.setDisplayLock()
		if LFLT.option.lock then
			_G[LFLT_F.displayFrameIconObj.name]:RegisterForDrag()
			print("Leaflet: Display Locked")
		else
			_G[LFLT_F.displayFrameIconObj.name]:RegisterForDrag("LeftButton")
			print("Leaflet: Display Unlocked")
		end
	end
	
	--Updates text field on History Window Buttons
	function LFLT_T.updateHistoryPage(page)	
		if page then 
			LFLT_T.historyPage = page
		else 
			page = LFLT_T.historyPage
		end
		LFLT_T.highLightHistoryButton()
		
		--Enable/Disable Page Buttons
		prevPageButton = _G[LFLT_F.prevPageButtonFrameObj.name]
		nextPageButton = _G[LFLT_F.nextPageButtonFrameObj.name]
		if prevPageButton:IsEnabled() and (page - 1) <= 0 then
			prevPageButton:Disable()
		elseif not prevPageButton:IsEnabled() and (page - 1) > 0 then
			prevPageButton:Enable()
		end
		if nextPageButton:IsEnabled() and page >= ceil(LFLT_T.historyEntryNum / historyButtonNum) then
			nextPageButton:Disable()
		elseif not nextPageButton:IsEnabled() and page < ceil(LFLT_T.historyEntryNum / historyButtonNum) then
			nextPageButton:Enable()
		end

		--Output History Entry onto Each Associated Button
		local button
		local entryNum 
		local outString1, outString2, outString3, outString4, outString5, outString6
		for i = 1, historyButtonNum do
			button = _G[LFLT_F.historyButtonFrameObj.name .. "_" .. i]
			entryNum = (LFLT_T.historyPage - 1) * historyButtonNum + i
			entry = LFLT.history[LFLT_T.historyEntryNum - entryNum + 1]
			--No Entry Found at History Index
			if not entry then
				outString1 = ""
				outString2 = ""
				outString3 = "--No Session--"
				outString4 = ""
				outString5 = ""
				outString6 = ""
				if button:IsEnabled() then button:Disable() end
				_G["LFLT_History_Button_Font" .. "_" .. i]:SetText(outString1)
				_G["LFLT_History_Button_Font" .. "_" .. i .. "_2"]:SetText(outString2)
				_G["LFLT_History_Button_Font" .. "_" .. i .. "_3"]:SetText(outString3)
				_G["LFLT_History_Button_Font" .. "_" .. i .. "_4"]:SetText(outString4)
				_G["LFLT_History_Button_Font" .. "_" .. i .. "_5"]:SetText(outString5)
				_G["LFLT_History_Button_Font" .. "_" .. i .. "_6"]:SetText(outString6)
			
			
			--Clear Incomplete Entries
			elseif not entry.date 
			or not entry.dungeonmode 
			or not entry.duration then
				local failureConditions = ""
				if not entry.date 			then failureConditions = failureConditions .. "date " 			end
				if not entry.dungeonmode	then failureConditions = failureConditions .. "dungeonmode "	end
				if not entry.duration		then failureConditions = failureConditions .. "duration " 		end
				tremove(LFLT.history, LFLT_T.historyEntryNum - entryNum + 1)
				LFLT_T.print("An incomplete Session has been deleted from your history. [" .. tostring(LFLT_T.historyEntryNum - entryNum + 1) 
							 .. "]\nMissing: " .. failureConditions) 
				i = i-1
			
			else
				if not button:IsEnabled() then button:Enable() end
				--Set Start Time
				local hours		= entry.startHour
				local mins		= entry.startMin
				local meridiem  = ""
				if LFLT.option.timeFormat == 0 then
					hours = hours + 1
					if hours > 11 then 
						hours = hours - 12
						meridiem = "pm"
					else
						meridiem = "am"
					end
					if hours == 0 then
						hours = 12
					end
				end			
				local startTimeStr = tostring(string.format("%02.f", hours))
									.. ":" .. 
									tostring(string.format("%02.f", mins))
									.. meridiem									
			
				local outcome
				if entry.outcome == 0 then
					outcome = "[WIPE]  "
				elseif entry.outcome == 1 then
					outcome = "[KILL]  "
				end
				
			
				outString1 = string.format("%+s",		entryNum)
				outString2 = string.format("%+s,\n%-s",	LFLT_T.getDateFormat(entry.date), startTimeStr)
				outString3 = string.format("%-s%-s", 	outcome or "", entry.encounter or "")
				outString4 = string.format("%+s",	 	entry.dName)
				outString5 = string.format("%+s",		LFLT_T.getDungeonType(entry.dungeonmode))
				outString6 = string.format("%+s",		entry.duration)
				_G[LFLT_F.historyButtonTextObj.name .. "_" .. i]:SetText(outString1)
				_G[LFLT_F.historyButtonTextObj.name .. "_" .. i .. "_2"]:SetText(outString2)
				_G[LFLT_F.historyButtonTextObj.name .. "_" .. i .. "_3"]:SetText(outString3)
				_G[LFLT_F.historyButtonTextObj.name .. "_" .. i .. "_4"]:SetText(outString4)
				_G[LFLT_F.historyButtonTextObj.name .. "_" .. i .. "_5"]:SetText(outString5)
				_G[LFLT_F.historyButtonTextObj.name .. "_" .. i .. "_6"]:SetText(outString6)
			end
		end
	end

	--Finds Entry number of a History Button
	--@param button the button on the page which returns the entry num
	--@param page on history that the button is located on. 
		--If nil, will use currently displayed page in history frame
	function LFLT_T.getHistoryEntryNum(button, page)
		if not page then page = LFLT_T.historyPage end
		return (page - 1) * historyButtonNum + button
	end

	--Sets pushed/unpushed button textures 
	function LFLT_T.highLightHistoryButton()
		for i = 1, historyButtonNum do
			local frame = _G[LFLT_F.historyButtonFrameObj.name .. "_" .. i]
			if LFLT_T.curSelectedHistoryButton[LFLT_T.getHistoryEntryNum(i)] then 
				frame:SetNormalTexture(LFLT_F.historyButtonFrameObj.pushedTexture)
			else
				frame:SetNormalTexture(LFLT_F.historyButtonFrameObj.normalTexture)
			end
		end
	end
	
	--Scroll Wheel handeler for Active Windows
	local function FrameScrollWheelHandler(direction)
		--History Window
		if _G["LFLT_" .. items.directory[2] .. "_Window_Frame"]:IsVisible() then 
			if LFLT.option.historyScrollWheelEnabled then
				if direction == 1 then 
					_G[LFLT_F.prevPageButtonFrameObj.name]:Click()
				else
					_G[LFLT_F.nextPageButtonFrameObj.name]:Click()
				end
			end
		end
	end

	--Returns a table of references to history entries
	function LFLT_T.getSelectedHistoryButtons()
		local entryList = {}
		local button, page, historyEntryNum
		for eNum,_ in pairs(LFLT_T.curSelectedHistoryButton) do 
			page = ceil(eNum / historyButtonNum)
			button = eNum - (page-1) * historyButtonNum
			
			historyEntryNum = LFLT_T.getHistoryEntryNum(button, page)
			tinsert(entryList, LFLT.history[historyEntryNum])
		end
		return entryList
	end
	
	--Updates Aux Text Fields with Data from Selected History Entries
	function LFLT_T.updateAuxDisplay()
		--[[.cur_hst_com
		.playername = UnitName("player")
		.groupSize = groupSize
		.dungeonmode]]
		
			local values = {
		int = {},mst = {}, hst = {}, crt = {}, vrs = {},	lch = {},
		cur_int_hpc = {}, cur_mst_hpc = {},	cur_hst_hpc = {}, cur_crt_hpc = {},	cur_vrs_hpc = {}, 
		cur_lch_hpc = {}, cur_int_hpt = {}, cur_mst_hpt = {}, cur_hst_hpt = {}, cur_crt_hpt = {},	
		cur_vrs_hpt = {}, cur_lch_hpt = {},	groupSize = {},
		}
		
		local entryList = LFLT_T.getSelectedHistoryButtons()
		if #entryList > 0 then
			local averages = {}
			local talentCodes = {}
			local hpcWeight, hptWeight, selectedCurMax, entry
			for i,entry in ipairs(entryList) do
				hpcWeight, selectedCurMax = LFLT.maxButNotZero(0.001, entry.cur_int_hpc, entry.cur_mst_hpc, entry.cur_hst_hpc, 
																		entry.cur_crt_hpc, entry.cur_vrs_hpc)
				hptWeight, _ 				 = select(selectedCurMax,0.001, entry.cur_int_hpt, entry.cur_mst_hpt, entry.cur_hst_hpt, 
																			entry.cur_crt_hpt, entry.cur_vrs_hpt)
				tinsert(values.cur_int_hpc, entry.cur_int_hpc / hpcWeight)
				tinsert(values.cur_mst_hpc, entry.cur_mst_hpc / hpcWeight)
				tinsert(values.cur_hst_hpc, entry.cur_hst_hpc / hpcWeight)
				tinsert(values.cur_hst_hpt, entry.cur_hst_hpt / hptWeight)
				tinsert(values.cur_crt_hpc, entry.cur_crt_hpc / hpcWeight)
				tinsert(values.cur_vrs_hpc, entry.cur_vrs_hpc / hpcWeight)
				--tinsert(values.cur_lch_hpc, entry.cur_lch_hpc)
				tinsert(talentCodes, entry.talents)
			end
						
			for k,v in pairs(values) do
				averages[k] = LFLT_T.getTableAverage(v)
			end
			
			local selectedTalents = {}
			for i=1,LFLT_T.talentRows * LFLT_T.talentCols do
				tinsert(selectedTalents, 0)
			end
			for k,v in pairs(talentCodes) do
				for i=1,LFLT_T.talentRows * LFLT_T.talentCols do
					selectedTalents[i] = selectedTalents[i] + tonumber(LFLT_T.charAt(v, i))
				end
			end
			for nodeNum = 1,LFLT_T.talentRows * LFLT_T.talentCols do
				if selectedTalents[nodeNum] == 0 then
					_G[LFLT_F.auxTalentFrameObj.name .. "_Talent_Texture_" .. nodeNum .. "_Texture"]:SetDesaturated(1);
					_G[LFLT_F.auxTalentFrameObj.name .. "_Talent_Texture_" .. nodeNum .. "_Texture"]:SetVertexColor(0.5,0.5,0.5);
					_G[LFLT_F.auxTalentFrameObj.name .. "_Talent_Text_" .. nodeNum]:SetText("")
				else
					_G[LFLT_F.auxTalentFrameObj.name .. "_Talent_Texture_" .. nodeNum .. "_Texture"]:SetDesaturated(false);
					_G[LFLT_F.auxTalentFrameObj.name .. "_Talent_Texture_" .. nodeNum .. "_Texture"]:SetVertexColor(1,1,1);
					if selectedTalents[nodeNum] > 1 then
						_G[LFLT_F.auxTalentFrameObj.name .. "_Talent_Text_" .. nodeNum]:SetText(selectedTalents[nodeNum])
					else 
						_G[LFLT_F.auxTalentFrameObj.name .. "_Talent_Text_" .. nodeNum]:SetText("")
					end
				end
			end

			local statFormat = "\n%12s: "
			local dataFormat = "\n%-5." .. tostring(LFLT.option.displayPrecision) .. "f"
			local outString1, outData1
			local hstText1, hstCurDataText1 = "",""
			local hstText2, hstCurDataText2 = "",""
			--Haste Display
			if LFLT.enabledHaste.cast.enabled then
				hstText1		= string.format(statFormat, "Haste[C]")
				hstCurDataText1 = string.format(dataFormat, averages.cur_hst_hpc)
			end
			if LFLT.enabledHaste.casttime.enabled then
				hstText2 		= string.format(statFormat, "Haste[T]")
				hstCurDataText2 = string.format(dataFormat, 
				averages.cur_hst_hpc * (1-LFLT.hasteCompositeRatio)
				+ averages.cur_hst_hpt * LFLT.hasteCompositeRatio )
			end
			
			outString1 = string.format("%12s: " .. statFormat .. "%s" ..  "%s"
										.. statFormat .. statFormat,
						"Intellect", "Crit", hstText1, hstText2, "Mastery", "Versatility")
			outData1 = string.format("%-5." .. tostring(LFLT.option.displayPrecision) 
									 .. "f" .. dataFormat .. "%s" ..  "%s"
									 .. dataFormat .. dataFormat,
						averages.cur_int_hpc,
						averages.cur_crt_hpc, 
						hstCurDataText1, hstCurDataText2,
						averages.cur_mst_hpc,
						averages.cur_vrs_hpc)
						
			_G[LFLT_F.auxFrameWeightTextObjLeft.name]:SetText(outString1)
			_G[LFLT_F.auxFrameWeightTextObjRight.name]:SetText(outData1)
			_G[LFLT_F.auxFrameWeightTextObjCenter.name]:SetText("")
		else
			_G[LFLT_F.auxFrameWeightTextObjLeft.name]:SetText("")
			_G[LFLT_F.auxFrameWeightTextObjRight.name]:SetText("")
			_G[LFLT_F.auxFrameWeightTextObjCenter.name]:SetText("No Session\nSelected")
			for nodeNum = 1,LFLT_T.talentRows * LFLT_T.talentCols do
				_G[LFLT_F.auxTalentFrameObj.name .. "_Talent_Texture_" .. nodeNum .. "_Texture"]:SetDesaturated(1);
				_G[LFLT_F.auxTalentFrameObj.name .. "_Talent_Texture_" .. nodeNum .. "_Texture"]:SetVertexColor(0.5,0.5,0.5);
				_G[LFLT_F.auxTalentFrameObj.name .. "_Talent_Text_" .. nodeNum]:SetText("")
			end
		end
	end	

	--Creates a popup message with button options
	--First Argument is the text display on the message Frame
	--All subsequent arguments must be passed in pairs
	--The first argument in each pair is The Button Text
	--The Second argument in each pair is the on-click function of the button.
	--Functions returns false if an even number of arguments is passed.
	function LFLT_T.popupMessage(...)
		local argc = select("#", ...)
		if argc % 2 == 0 then
			print("Error, must provide even number of arguments to LFLT_T.popupMessage" 
			.. "\nExample Arguments: Button Text1, function1, Button Text2, function2, ect...")
			return false
		end
		_G[LFLT_F.message_TextObj.name]:SetText(select(1,...))
		LFLT_T.popupMessageFunctions = {}
		local buttonText, curButton, curText
		local buttonNum	= math.floor(argc/2) 
		local buttonGap = (LFLT_F.messageFrameObj.width - 100) / buttonNum
		for i=0, buttonNum - 1 do
			buttonText = select(2 * i + 2, ...)
			LFLT_T.popupMessageFunctions[i] = select(2 * i + 3, ...)
			if not _G[LFLT_F.message_ButtonObj.name.. tostring(i + 1)] then
				
				LFLT_T.frameGen(LFLT_F.message_ButtonObj, {
					name 		= LFLT_F.message_ButtonObj.name .. tostring(i + 1), 
					width 		= buttonGap * 0.66666,
					xOff 		= 50 + buttonGap * (i + 0.166666),
					clickFunc	= function()
									LFLT_T.popupMessageFunctions[i]()
									_G[LFLT_F.messageFrameObj.name]:Hide()
								end
					})
				LFLT_T.frameGen(LFLT_F.message_Button_TextObj, {
					name 		= LFLT_F.message_Button_TextObj.name .. tostring(i + 1), 
					parent		= LFLT_F.message_ButtonObj.name .. tostring(i + 1),
					transcribe 	= true,
					text 		= buttonText,
					})
			else 
				--Modify Existing Button
				curButton = _G[LFLT_F.message_ButtonObj.name .. tostring(i + 1)]
				curButton:SetWidth(buttonGap * 0.66666)
				curButton:SetPoint(	LFLT_F.message_ButtonObj.pointOnFrame, 
									_G[LFLT_F.message_ButtonObj.parent] or UIPARENT, 
									LFLT_F.message_ButtonObj.pointOnParent or LFLT_F.message_ButtonObj.pointOnFrame, 
									50 + buttonGap * (i + 0.166666), 
									LFLT_F.message_ButtonObj.yOff or 0)
				curButton:SetScript("OnClick", 
					function() 
						LFLT_T.popupMessageFunctions[i]()
						_G[LFLT_F.messageFrameObj.name]:Hide()
					end) 
				if not curButton:IsShown() then curButton:Show() end
				--Modify Existing Button Text
				curText = _G[LFLT_F.message_Button_TextObj.name .. tostring(i + 1)]
				curText:SetAllPoints(LFLT_F.message_ButtonObj.name .. tostring(i + 1))
				curText:SetText(buttonText)
			end
		end	
		local iter = buttonNum + 1
		while iter ~= -1 do
			if _G[LFLT_F.message_ButtonObj.name.. tostring(iter)] then
				if _G[LFLT_F.message_ButtonObj.name.. tostring(iter)]:IsShown() then
					_G[LFLT_F.message_ButtonObj.name.. tostring(iter)]:Hide()
				end
				iter = iter + 1
			else	
				iter = -1
			end
		end
		_G[LFLT_F.messageFrameObj.name]:Show()
	end
	
	--Frame Attribute Table Farm
	--checkboxes Text Template
	LFLT_F.checkBox_Text_Template = {
		fType = "TEXT",
		pointOnFrame = "LEFT",
		pointOnParent = "RIGHT",
		drawLayer = "OVERLAY",
		xOff = 0,
		yOff = 0,
		height = 50,
		fontSize = 10,
		hJustify = "LEFT",
		fontFlags = "OUTLINE",
	}
	
	--Display Frame Icon
	LFLT_F.displayFrameIconObj = {
		fType = "BUTTON",
		name = "LFLT_Display_Icon_Frame",
		parent = LFLT.option.displayPos.parent,
		pointOnFrame = LFLT.option.displayPos.pointOnFrame,
		pointOnParent = LFLT.option.displayPos.pointOnParent,
		xOff = LFLT.option.displayXPos,
		yOff = LFLT.option.displayYPos,
		width = 30,
		height = 30, 
		strata = "BACKGROUND",
		level = 2,
		pushedTexture 			= displayButton,
		highlightTexture		= "",
		normalTexture 			= displayButton,
		clickFunc = function(self)
			if LFLT.option.configToggle then
				_G[LFLT_F.configFrameObj.name]:Hide()
			else
				_G[LFLT_F.configFrameObj.name]:Show()
			end
			LFLT_T.SetDisplayTextPos()
		end,
		func = function(self) 
			local f = _G[self.name]
			f:SetMovable(true)
			f:EnableMouse(true)
			f:SetScript("OnDragStart", f.StartMoving)
			f:SetScript("OnDragStop", function(self)
			f:StopMovingOrSizing()
			LFLT_T.saveDisplayPosition()
			end)
			LFLT_T.setDisplayLock()
			if LFLT.option.lock and LFLT.option.hideIcon and f:GetNormalTexture() then
				f:SetNormalTexture(nil)
				f:EnableMouse(false)
			end
		end,
	}
	
	--Display Text 1
	LFLT_F.displayTextObj1 = { 
		fType = "TEXT",
		name = "LFLT_Display_Text1",
		parent = LFLT_F.displayFrameIconObj.name,
		pointOnFrame = "TOPLEFT",
		pointOnParent = "TOPRIGHT",
		width = 90,
		height = 120, 
		drawLayer = "OVERLAY",
		fontSize = defaultFontSize, 
		hJustify = "RIGHT",
		fontFlags = "OUTLINE",
	}
	
	--Display Data Text 1
	LFLT_F.displayDataTextObj1 = { 
		template = LFLT_F.displayTextObj1,
		name = "LFLT_Display_Data_Text1",
		hJustify = "LEFT",
		width = 50,
	}
	
	--Display Text 2  
	LFLT_F.displayTextObj2 = { 
		template = LFLT_F.displayTextObj1,
		name = "LFLT_Display_Text2"
	}
	
	--Display Data Text 2
	LFLT_F.displayDataTextObj2 = { 
		template = LFLT_F.displayDataTextObj1,
		name = "LFLT_Display_Data_Text2",
	}
	
	--Display Text 3
	LFLT_F.displayTextObj3 = { 
		template = LFLT_F.displayTextObj1,
		name = "LFLT_Display_Text3",
		width = 150,
		height = 10,
		hJustify = "CENTER",
		text = string.format("Leaflet v:%s", LFLT.version),
		func = function(self) 
			LFLT_T.SetDisplayTextPos()
		end
	}
	
	--Message Frame
	LFLT_F.messageFrameObj = {
		fType = "FRAME",
		name = "LFLT_Message_Frame",
		pointOnFrame = "TOP",
		width = 600,
		height = 200, 
		xOff = 0,
		yOff = -300,
		strata = "HIGH",
		level = 5,
		backdrop = defaultBackdrop,
		func = function(self) _G[self.name]:Hide() end,
	}
	
	--Message Frame Button Template
	LFLT_F.message_ButtonObj = {
		fType = "BUTTON",
		name = "LFLT_Message_Button",
		parent = LFLT_F.messageFrameObj.name,
		pointOnFrame = "BOTTOMLEFT",
		height = 60, 
		yOff = 15,
		strata = "HIGH",
		level = 7,
		pushedTexture 			= buttonNormalTexture,
		highlightTexture		= buttonPushedTexture,
		normalTexture 			= buttonHighlightTexture,
	}
	
	--Message Frame Button Text Template
	LFLT_F.message_Button_TextObj = {
		fType = "TEXT",
		name = "LFLT_Message_Button_Text",
		parent = LFLT_F.message_ButtonObj.name,
		pointOnFrame = "BOTTOMLEFT",
		transcribe = true,
		fontSize = 14,
		drawLayer = "OVERLAY",
		hJustify = "CENTER",
		vJustify = "CENTER",
	}
	
	--Center Message Text on Message Popup
	LFLT_F.message_TextObj = {
		fType = "TEXT",
		name = "LFLT_Message_Text",
		parent = LFLT_F.messageFrameObj.name,
		pointOnFrame = "TOP",
		yOff = -10,
		height = LFLT_F.messageFrameObj.height - (LFLT_F.message_ButtonObj.height + LFLT_F.message_ButtonObj.yOff) - 20,
		width = LFLT_F.messageFrameObj.width - 50,
		fontSize = 15,
		drawLayer = "OVERLAY",
		hJustify = "CENTER",
		vJustify = "CENTER",
	}
	
	--Config Frame
	LFLT_F.configFrameObj = {
		fType = "FRAME",
		name = "LFLT_config_Frame",
		pointOnFrame = "CENTER",
		width = 750,
		height = 500, 
		xOff = 0,
		yOff = 0,
		strata = "MEDIUM",
		level = 5,
		backdrop = {
			bgFile= defaultBackdrop2BGFile ,
			edgeFile= defaultBorder,
			tile = false,
			edgeSize = 10,
			insets = {left = 1, right = 1, top = 1, bottom = 1}
		},
		func = function(self) 
			local frame = _G[self.name]
			frame:SetMovable(true)
			frame:EnableMouse(true)
			frame:SetScript("OnDragStart", frame.StartMoving)
			frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
			frame:RegisterForDrag("LeftButton")	
			tinsert(UISpecialFrames, "LFLT_config_Frame") 
			_G[LFLT_F.configFrameObj.name]:SetScript("OnHide", function() LFLT.option.configToggle = false end)
			_G[LFLT_F.configFrameObj.name]:SetScript("OnShow", function() LFLT.option.configToggle = true end)
			_G[LFLT_F.configFrameObj.name]:SetScale(1.5)
			
		end
	}
		
	--Config Close Button Frame
	LFLT_F.config_Close_ButtonObj = {
		fType = "BUTTON",
		name = "LFLT_config_Close_Button",
		parent = LFLT_F.configFrameObj.name,
		pointOnFrame = "TOPRIGHT",
		width = 30,
		height = 30, 
		xOff = -10,
		yOff = -7.5,
		strata = "MEDIUM",
		level = 7,
		pushedTexture 			= closeButton,
		highlightTexture		= "",
		normalTexture 			= closeButton,
		clickFunc = function(self)
			_G[LFLT_F.configFrameObj.name]:Hide()
		end,
	}
	--Active Window Frame
	--Includes all active windows (generated in table function)
	LFLT_F.actFrameObj = {
		fType = "FRAME",
		name = "LFLT_Active_Window_Frame",
		parent = LFLT_F.configFrameObj.name,
		pointOnFrame = "TOPLEFT",
		width = 740,
		height = 457.5, 
		xOff = 5,
		yOff = -37.5,
		strata = "MEDIUM",
		level = 10,
		backdrop = {
			bgFile = defaultBackdropBGFile,
			edgeFile = defaultBorder,
			tile = false,
			edgeSize = 10
		},
		func = function(self) 
			local frameObj = {}
			for k,v in pairs(self) do
				frameObj[k] = v
			end
			--Generates all Active Windows
			for k,v in ipairs(items.directory) do
				LFLT_T.frameGen(frameObj, {
				transcribe = self.name,
				name = "LFLT_" .. v .. "_Window_Frame",
				level = 12,
				func = "nil"
				})
			end
			--Active Frame Scroll Wheel Function
			_G[LFLT_F.configFrameObj.name]:SetScript("OnMouseWheel", function(self, direction) FrameScrollWheelHandler(direction) end)
		end
	}	
	
	--Aux Frame
	LFLT_F.auxFrameObj = {
		fType = "FRAME",
		name = "LFLT_Aux_Frame",
		parent = "LFLT_History_Window_Frame",
		pointOnFrame = "TOPLEFT",
		pointOnParent = "TOPRIGHT",
		width = 105,
		height = 300, 
		xOff = 7.5,
		yOff = 35,
		strata = "MEDIUM",
		level = 7,
		backdrop = {
			bgFile = auxBGTexture,
			edgeFile = defaultBorder,
			tile = false,
			edgeSize = 5
		}
	}	
	
	--Aux Frame Text Template
	LFLT_F.auxFrameTextObj = {
		fType = "TEXT",
		name = "LFLT_Aux_Text",
		parent = LFLT_F.auxFrameObj.name,
		pointOnFrame = "CENTER",
		width = 100,
		height = 35,
		fontSize = 10,
		drawLayer = "OVERLAY",
		hJustify = "LEFT",
		vJustify = "TOP",
		fontFlags = "OUTLINE",
	}
	
	--Aux Stat Weight Frame
	LFLT_F.auxWeightFrameObj = {
		fType = "FRAME",
		name = "LFLT_Aux_Weight_Frame",
		parent = LFLT_F.auxFrameObj.name,
		pointOnFrame = "TOP",
		pointOnParent = "TOP",
		width = 100,
		height = 90, 
		xOff = 0,
		yOff = -2.5
		,
		strata = "MEDIUM",
		level = 10,
		backdrop = {
			bgFile = auxInnerBGTexture_1x1,
			edgeFile = defaultBorder,
			tile = false,
			edgeSize = 2.5
		}
	}	
	
	--Aux Frame Stat Text
	LFLT_F.auxFrameWeightTextObjLeft = {
		template = LFLT_F.auxFrameTextObj,
		name = "LFLT_Aux_Weight_Text_Left",
		parent = LFLT_F.auxWeightFrameObj.name,
		width = 70,
		height = 90, 
		xOff = -7.5,
		yOff = 0,
		pointOnFrame = "LEFT",
		hJustify = "RIGHT",
		vJustify = "CENTER",
	}
	
	--Aux frame Weight Text Values
	LFLT_F.auxFrameWeightTextObjRight = {
		template = LFLT_F.auxFrameTextObj,
		name = "LFLT_Aux_Weight_Text_Right",
		parent = LFLT_F.auxWeightFrameObj.name,
		width = 50,
		height = 90, 
		xOff = 62.5,
		yOff = 0,
		pointOnFrame = "LEFT",
		hJustify = "LEFT",
		vJustify = "CENTER",
	}
	
	--Aux frame Weight Text Values
	LFLT_F.auxFrameWeightTextObjCenter = {
		template = LFLT_F.auxFrameTextObj,
		name = "LFLT_Aux_Weight_Text_Center",
		parent = LFLT_F.auxWeightFrameObj.name,
		width = 100,
		height = 90, 
		xOff = 0,
		yOff = 0,
		pointOnFrame = "LEFT",
		hJustify = "CENTER",
		vJustify = "CENTER",
	}
	
	--Aux Talent Display Frame
	LFLT_F.auxTalentFrameObj = {
		fType = "FRAME",
		name = "LFLT_Aux_Talent_Frame",
		parent = LFLT_F.auxFrameObj.name,
		pointOnFrame = "TOP",
		pointOnParent = "TOP",
		width = 100,
		height = 200, 
		yOff = -95,
		strata = "MEDIUM",
		level = 20,
		
		func = function(self)
			for i=1, LFLT_T.talentRows do
				--Textures for Rim around each Talent Image
				LFLT_T.frameGen(LFLT_F.auxTalentFrameObj, {
				name = LFLT_F.auxTalentFrameObj.name .. "_Texture_" .. i,
				parent = LFLT_F.auxTalentFrameObj.name,
				pointOnFrame = "TOPLEFT",
				pointOnParent = "TOPLEFT",
				height = LFLT_F.auxTalentFrameObj.height / LFLT_T.talentRows,
				width = LFLT_F.auxTalentFrameObj.width * 1.2,
				xOff = -11.25,	
				yOff = (LFLT_F.auxTalentFrameObj.height / LFLT_T.talentRows) * (i-1) * -1,
				level = 18,
				texture = talentFrameTexture,
				backdrop = "nil",
				func = "nil",
				})
				local nodeNum
				--Textures for Each Talent
				for j=1, LFLT_T.talentCols do
					nodeNum = (i-1)* LFLT_T.talentCols + j
					LFLT_T.frameGen(LFLT_F.auxTalentFrameObj, {
					name = LFLT_F.auxTalentFrameObj.name .. "_Talent_Texture_" .. nodeNum,
					parent = LFLT_F.auxTalentFrameObj.name .. "_Texture_" .. i,
					pointOnFrame = "LEFT",
					pointOnParent = "LEFT",
					height = LFLT_F.auxTalentFrameObj.height  / LFLT_T.talentRows -2.5,
					width = LFLT_F.auxTalentFrameObj.width / LFLT_T.talentCols -2.5,
					xOff = (j-1)*((LFLT_F.auxTalentFrameObj.width) / LFLT_T.talentCols - 2.5) + 15,	
					yOff = 1,
					level = 10,
					texture = LFLT.talentInfo[nodeNum].texture,
					backdrop = "nil",
					func = "nil",
					})
					LFLT_T.frameGen(LFLT_F.auxTalentFrameObj, {
					fType = "TEXT",
					name = LFLT_F.auxTalentFrameObj.name .. "_Talent_Text_" .. nodeNum,
					parent = LFLT_F.auxTalentFrameObj.name .. "_Talent_Texture_" .. nodeNum,
					pointOnFrame = "LEFT",
					pointOnParent = "LEFT",
					height = LFLT_F.auxTalentFrameObj.height  / LFLT_T.talentRows,
					width = LFLT_F.auxTalentFrameObj.width / LFLT_T.talentCols,
					xOff = 1.5,	
					yOff = -5,
					drawLayer = "OVERLAY",
					fontSize = 10,
					strata = "nil",
					level = "nil",
					backdrop = "nil",
					func = "nil",
					})
				end					
			end
		end,				
	}	
	
	--Replay Frame Frame
	LFLT_F.replayFrameObj = {
		fType = "FRAME",
		name = "LFLT_Replay_Frame",
		parent = "LFLT_History_Window_Frame",
		pointOnFrame = "TOPLEFT",
		pointOnParent = "TOPRIGHT",
		width = 105,
		height = 200, 
		xOff = 7.5, 
		yOff = -265,
		strata = "MEDIUM",
		level = 7,
		backdrop = {
			bgFile = auxBGTexture,
			edgeFile = defaultBorder,
			tile = false,
			edgeSize = 5
		}
	}
	
	--Replay Healing Percent Result Frame
	LFLT_F.replayResultPercentFrameObj = {
		fType = "FRAME",
		name = "LFLT_Replay_Result_Percent_Frame",
		parent = LFLT_F.replayFrameObj.name,
		pointOnFrame = "TOP",
		pointOnParent = "TOP",
		width = 100,
		height = 50, 
		xOff = 0,
		yOff = -2.5,
		strata = "MEDIUM",
		level = 10,
		backdrop = {
			bgFile = auxInnerBGTexture_2x1,
			edgeFile = defaultBorder,
			tile = false,
			edgeSize = 2.5
		},
	}	
	
		--Replay Stat Weight Result Frame
	LFLT_F.replayResultWeightFrameObj = {
		template = LFLT_F.replayResultPercentFrameObj,
		name = "LFLT_Replay_Result_Weight_Frame",
		height = 90, 
		yOff = -55,
		backdrop = {
			bgFile = auxInnerBGTexture_1x1,
			edgeFile = defaultBorder,
			tile = false,
			edgeSize = 2.5
		},
	}	
		
	--Aux Replay Healing Results
	LFLT_F.replayResultPercentFrameTextObj =	{
		template = LFLT_F.auxFrameTextObj,
		name = "LFLT_Replay_Result_Frame_TextObj3",
		parent = LFLT_F.replayResultPercentFrameObj.name,
		transcribe = LFLT_F.replayResultPercentFrameObj.name,
		fontSize = 14,
		text = "Replay Info",
		hJustify = "CENTER",
		drawLayer = "OVERLAY",
	}
	
	--Replay Stat Weights Display
	LFLT_F.replayResultWeightFrameTextObjLeft =	{
		template = LFLT_F.auxFrameWeightTextObjLeft,
		parent = LFLT_F.replayResultWeightFrameObj.name,
		name = "LFLT_Replay_Result_Frame_TextObj_Left",
	}
	
	--Replay Stat Weights Display
	LFLT_F.replayResultWeightFrameTextObjRight =	{
		template = LFLT_F.replayResultWeightFrameTextObjLeft,
		parent = LFLT_F.replayResultWeightFrameObj.name,
		name = "LFLT_Replay_Result_Frame_TextObj_Right",
		width = 50,
		height = 90, 
		xOff = 62.5,
		yOff = 0,
		hJustify = "LEFT",
	}
	
	--Replay Stat Weight Text Values Title
	LFLT_F.replayFrameWeightTextObjCenter = {
		template = LFLT_F.auxFrameTextObj,
		name = "LFLT_Aux_Weight_Text_Center",
		parent = LFLT_F.replayResultWeightFrameObj.name,
		width = 100,
		height = 75, 
		xOff = 0,
		yOff = 0,
		pointOnFrame = "LEFT",
		hJustify = "CENTER",
		vJustify = "CENTER",
		text = "",
	}

	--Aux Replay Button
	LFLT_F.replayButton = {
		fType = "BUTTON",
		name = "LFLF_Replay_Button",
		parent = LFLT_F.replayFrameObj.name,
		pointOnFrame = "TOP",
		pointOnParent = "TOP",
		width = 150,
		height = 75, 
		xOff = 0,
		yOff = -135,
		strata = "MEDIUM",
		level = 10,
		pushedTexture 		= replayPushedTexture,
		highlightTexture	= replayHighlightTexture,
		normalTexture 		= replayNormalTexture,
		clickFunc = function(self) 
			local threadStatus
			if not LFLT_T.replayThread then 
				LFLT_T.replayThread = coroutine.create(LFLT_T.replay) 
			
			else
				threadStatus = coroutine.status(LFLT_T.replayThread)
				--Recreate on suspended thread status in case of self-thread-termination by aborting replay
				if threadStatus == "dead" or threadStatus == "suspended" then 
					LFLT_T.replayThread = coroutine.create(LFLT_T.replay)
				end
			end
			
			if not LFLT_T.replayInProgress or threadStatus ~= "running" then
				LFLT_T.replayInProgress = true
				print("Button Activated")
				_G[LFLT_F.replayButton.name]:Disable()
				coroutine.resume(LFLT_T.replayThread)
			end
		end,
	}
	
	--Banner Texture
	LFLT_F.BannerFrameObj = {
		fType = "FRAME",
		name = "LFLT_Banner",
		parent = "LFLT_Settings_Window_Frame",
		pointOnFrame = "TOPLEFT",
		pointOnParent = "TOPLEFT",
		width = 200,
		height = 200, 
		xOff = -15,
		yOff = 15,
		strata = "MEDIUM",
		level = 14,
		texture = bannerTexture,
		textureAttr = 	{
							r = 1, g = 1, b = 1, a = 1,
							drawLayer = "OVERLAY",
							hMirror = false,
							vMirror = false,
							tile = false
						}	
	}	
			
	--Directory Frame
	LFLT_F.dirFrameObj = {
		fType = "FRAME",
		name = "LFLT_Directory_Frame",
		parent = LFLT_F.configFrameObj.name,
		pointOnFrame = "TOPLEFT",
		width = 705,
		height = 35, 
		xOff = 5,
		yOff = -5,
		strata = "MEDIUM",
		level = 10,
		backdrop = {
			bgFile = defaultBackdropBGFile,
			edgeFile = defaultBorder,
			tile = false,
			edgeSize = 10
		}
	}
	
	--Directory Buttons
	LFLT_F.directoryButtonFrameObj = {
		fType = "BUTTON",
		name = "LFLT_Directory_Button",
		parent = LFLT_F.configFrameObj.name,
		pointOnFrame = "TOPLEFT",
		pointOnParent = "TOPLEFT",
		width = 0, --handeled by gen function
		height = 30, 
		xOff = 7.5,
		yOff = -7.5,
		strata = "MEDIUM",
		level = 10,
		normalTexture 		= buttonNormalTexture,
		pushedTexture 		= buttonPushedTexture,
		highlightTexture 	= buttonHighlightTexture,
		clickFunc = function(self)
			LFLT.activeWindowCode = self.arg1.selected
			local frame
			for i = 1, self.arg1.frameNum do
				frame = _G[LFLT_F.directoryButtonFrameObj.name .. "_" ..items.directory[i]]
				if i == LFLT.activeWindowCode then
					frame:SetNormalTexture(buttonPushedTexture)
				else
					frame:SetNormalTexture(buttonNormalTexture)
				end
			end
							 
			for i,v in ipairs(items.directory) do
				if LFLT.activeWindowCode == i then
					_G["LFLT_" .. v .. "_Window_Frame"]:Show()
				else
					_G["LFLT_" .. v .. "_Window_Frame"]:Hide()
				end
			end
		end
	}
	
	--Directory Button Text
	LFLT_F.directoryButtonTextObj = {
		fType = "TEXT",
		name = "LFLT_Directory_Button_Font",
		parent = LFLT_F.directoryButtonFrameObj.name,
		pointOnFrame = "LEFT",
		pointOnParent = "LEFT",
		width = 160,
		height = 50, --handeled by gen function
		xOff = 10,
		yOff = 0,
		drawLayer = "OVERLAY",
		font = LFLT_T.vixarFont,
		fontSize = 12,
		hJustify = "CENTER",
		fontFlags = "OUTLINE",
	}
		
	--Display Orientation Dropdown
	LFLT_F.settings_DropDownObj1 = {
		fType = "DROPDOWN",
		name = "LFLT_Settings_DropDownObj1",
		parent = "LFLT_Settings_Window_Frame",
		pointOnFrame = "TOPLEFT",
		pointOnParent = "TOPLEFT",
		width = 100,
		buttonWidth = 124,
		height = 10, 
		xOff = 160,
		yOff = -25,
		strata = "MEDIUM",
		level = 14,
		hJustify = "LEFT",
		dropList = {"Horizontal", "Vertical"},
		selected = LFLT.option.displayOrientation,
		clickFunc = function(self, item, frame)
			UIDropDownMenu_SetSelectedID(frame, self:GetID())
			LFLT.option.displayOrientation = item
			LFLT_T.SetDisplayTextPos()
		end
	}
		
	--Display Orientation Dropdown Text
	LFLT_F.settings_DropDown1_TextObj = { 
		fType = "TEXT",
		name = "LFLT_Settings_DropDownObj1_Text",
		parent = LFLT_F.settings_DropDownObj1.name,
		pointOnFrame = "TOPLEFT",
		pointOnParent = "TOPLEFT",
		width = 124,
		height = 75, --handeled by frameGen function
		xOff = 15,
		yOff = 45,
		text = "Orientation:",
		drawLayer = "OVERLAY",
		fontSize = 10, ---ADD FUNCTIONALITY TO UPDATE THIS FONTSIZE WHEN FONTSIZE IS UPDATED VIA GUI
		hJustify = "LEFT",
		color = {1,1,1,1}
	}
			
	--Display Precision Dropdown
	LFLT_F.settings_DropDownObj2 = {
		template = LFLT_F.settings_DropDownObj1,
		name = "LFLT_Settings_DropDownObj2",
		xOff = 285,
		dropList = items.precision,
		selected = #items.precision - LFLT.option.displayPrecision + 1,
		clickFunc = function(self, item, frame)
			UIDropDownMenu_SetSelectedID(frame, self:GetID())
			for k,v in ipairs(LFLT_F.settings_DropDownObj2.dropList) do
				if item == v then
					LFLT.option.displayPrecision = #items.precision - k + 1
					break;
				end
			end
			LFLT_T.updateDisplay()
		end
	}
	
	--Display Precision Dropdown Text
	LFLT_F.settings_DropDown2_TextObj = {
		template = LFLT_F.settings_DropDown1_TextObj,
		name = "LFLT_Settings_DropDownObj2_Text",
		text = "Precision:",
		parent = LFLT_F.settings_DropDownObj2.name
	}
	
	--Display Scale Editbox
	LFLT_F.settings_Display_Scale_EditBox = {
		fType = "EDITBOX",
		name = "LFLT_settings_Display_Scale_Editbox",
		parent = "LFLT_Settings_Window_Frame",
		pointOnFrame = "TOP",
		pointOnParent = "TOP",
		width = 30,
		height = 40, 
		xOff = -150,
		yOff = -100,
		fontSize = 10,
		hJustify = "CENTER",
		strata = "Medium",
		level = 11,
		boxAutoFocus = false,
		boxNumeric = true,
		highlightOnClick = true,
		numeric = LFLT_T.round(LFLT.option.displayScale, -1),
		enterpushedFunc =  function(self) 
			local frame = _G[self.name]
			local slider = _G[LFLT_F.settings_Display_Scale_Slider.name]
			local boxVal = LFLT_T.round(frame:GetNumber(), -1)
			if boxVal > LFLT_F.settings_Display_Scale_Slider.maxValue then 
				boxVal = LFLT_F.settings_Display_Scale_Slider.maxValue
			end
			if boxVal < LFLT_F.settings_Display_Scale_Slider.minValue then 
				boxVal = LFLT_F.settings_Display_Scale_Slider.minValue
			end
			
			frame:SetNumber(boxVal)
			if slider:GetValue() ~= boxVal then
				slider:SetValue(boxVal)
			end
			LFLT.option.displayScale = frame:GetNumber()
			frame:ClearFocus()
			_G[LFLT_F.displayFrameIconObj.name]:SetScale(boxVal)
		end,
		escapepushedFunc = function(self)
			_G[LFLT_F.settings_Display_Scale_EditBox.name]:ClearFocus()
		end
	}
	
	--Display Scale Slider
	LFLT_F.settings_Display_Scale_Slider = {
		fType = "SLIDER",
		name = "LFLT_settings_Display_Scale_Slider",
		parent = LFLT_F.settings_Display_Scale_EditBox.name,
		pointOnFrame = "TOPRIGHT",
		pointOnParent = "BOTTOMRIGHT",
		width = 100,
		height = 15, 
		xOff = 0,
		yOff = 10,
		strata = "HIGH",
		level = 15,
		-------------------
		orientation = "horizontal",
		thumbTexture = "nil",
		minValue = .5,
		maxValue = 3,
		setMinMaxText = true,
		minText = tostring(minValue),
		maxText = tostring(maxValue),
		startValue = LFLT.option.displayScale,
		stepValue = .1,
		clickFunc = function(self, value)
			value = LFLT_T.round(value, -1)
			_G[self.name]:SetValue(value)
			_G[LFLT_F.settings_Display_Scale_EditBox.name]:SetNumber(value)
			LFLT_F.settings_Display_Scale_EditBox:enterpushedFunc()
		end,
	}
	
	--Display Scale Editbox Text
	LFLT_F.settings_Display_Scale_EditBox_TextObj = { 
		fType = "TEXT",
		name = "LFLT_settings_Display_Scale_EditBox_Text",
		parent = LFLT_F.settings_Display_Scale_EditBox.name,
		pointOnFrame = "RIGHT",
		pointOnParent = "LEFT",
		width = 150,
		height = 75, --handeled by frameGen function
		xOff = 32.5,
		yOff = 0,
		text = "Display Scale:",
		drawLayer = "OVERLAY",
		highlightOnClick = true,
		boxNumeric = true,
		numeric = LFLT.option.displayScale,
		fontSize = 10, 
		hJustify = "CENTER",
		color = {1,1,1,1}
	}
	
	--History Button
	LFLT_F.historyButtonFrameObj = {
		fType = "BUTTON",
		name = "LFLT_History_Button",
		parent = "LFLT_History_Window_Frame",
		pointOnFrame = "TOPLEFT",
		pointOnParent = "TOPLEFT",
		width = 500,
		xOff = 120,
		yOff = -55,
		strata = "MEDIUM", 
		level = 10,
		pushedTexture 		= historyPushedTexture,
		highlightTexture	= historyHighlightTexture,
		normalTexture 		= historyNormalTexture,
		disabledTexture 	= historyHighlightTexture,
		clickFunc = function(self, selected)
			local selected = self.arg1.selected
			--if control is held down
			if LFLT_T.modifierState.LCTRL == 1 or LFLT_T.modifierState.RCTRL == 1 then
				if LFLT_T.curSelectedHistoryButton[LFLT_T.getHistoryEntryNum(selected)] then
					LFLT_T.curSelectedHistoryButton[LFLT_T.getHistoryEntryNum(selected)] = nil
					--LFLT_T.lastSelectedHistoryButton = nil
				else 
					LFLT_T.curSelectedHistoryButton[LFLT_T.getHistoryEntryNum(selected)] = true
					LFLT_T.lastSelectedHistoryButton = LFLT_T.getHistoryEntryNum(selected)
				end
			--if shift is held down and control is not held down
			elseif 	(LFLT_T.modifierState.LSHIFT == 1 
					or LFLT_T.modifierState.RSHIFT == 1) 
					and LFLT_T.lastSelectedHistoryButton then
				local curSelected = LFLT_T.getHistoryEntryNum(selected)
				local order = -1 --Direction of Button Iterations (forward/Positive or Backward/Negative
				local range = curSelected - LFLT_T.lastSelectedHistoryButton
				
				if range < 1 then
					order = 1
					range = range * -1
				end								
				
				for j = 1, range do	LFLT_T.curSelectedHistoryButton[curSelected + (j-1) * order] = true end
				
				LFLT_T.lastSelectedHistoryButton = LFLT_T.getHistoryEntryNum(selected)
			--No modifier is pushed
			else
				LFLT_T.lastSelectedHistoryButton = LFLT_T.getHistoryEntryNum(selected)
				LFLT_T.curSelectedHistoryButton = {}
				LFLT_T.curSelectedHistoryButton[LFLT_T.lastSelectedHistoryButton] = true
			end
			----------------------------------------------------------------------------------------------------------------Add Aux Frame Update here
			LFLT_T.highLightHistoryButton()
			LFLT_T.updateAuxDisplay()
		end,
		--func = function() _G[LFLT_F.historyButtonFrameObj.name].highlighttexture:SetVertexColor(0.5,0.5,0.5) end,
	}
	
	--History Button Text
	LFLT_F.historyButtonTextObj = {
		fType = "TEXT",
		name = "LFLT_History_Button_Font",
		parent = "LFLT_History_Window_Frame",
		pointOnFrame = "LEFT",
		pointOnParent = "LEFT",
		width = 35,
		xOff = 5,
		yOff = 0,
		drawLayer = "OVERLAY",
		font = LFLT_T.vixarFont,
		fontSize = 8,
		fontFlags = "OUTLINE",
		arg1 = nil,
		arg2 = nil,
		func = function(self, arg1, arg2)
			--1st Text Frame <------Entry Number
			local frame = _G[self.name]
			frame:ClearAllPoints()
			frame:SetPoint( self.pointOnFrame, self.parent, self.pointOnParent,
							LFLT_F.historyButtonTextObj.xOff, LFLT_F.historyButtonTextObj.yOff)
			frame:SetSize(LFLT_F.historyButtonTextObj.width, self.height)
			LFLT_T.frameGen(self, { --Date
			name = arg1 .. "_2", 
			parent = arg2,
			xOff = 45,
			width = 50,
			func = "nil"
			})
			LFLT_T.frameGen(self, { --Encounter Name (Left Justified)
			name = arg1 .. "_3", 
			parent = arg2,
			hJustify = "LEFT",
			xOff = 100,
			width = 200,
			func = "nil"
			})
			LFLT_T.frameGen(self, { --Outcome
			name = arg1 .. "_4", 
			parent = arg2,
			xOff = 305,
			width = 105,
			hJustify = "CENTER",
			func = "nil"
			})
			LFLT_T.frameGen(self, { --Dungeonmode
			name = arg1 .. "_5", 
			parent = arg2,
			xOff = 415,
			width = 50,
			hJustify = "CENTER",
			func = "nil"
			})
			LFLT_T.frameGen(self, { --Duration
			name = arg1 .. "_6", 
			parent = arg2,
			xOff = 470,
			width = 25,
			func = "nil"
			})
		end
	}
	
	--Next Page History Button
	LFLT_F.prevPageButtonFrameObj = {
		fType = "BUTTON",
		name = "LFLT_History_NextPage_Button",
		parent = "LFLT_History_Window_Frame",
		pointOnFrame = "BOTTOMLEFT",
		pointOnParent = "BOTTOMLEFT",
		width = 30,
		height = 25, 
		xOff = 50,
		yOff = 3,
		strata = "MEDIUM",
		level = 10,
		pushedTexture 		= leftArrowButtonHighlightTexture,
		highlightTexture	= leftArrowButtonNormalTexture,
		normalTexture 		= leftArrowButtonNormalTexture,
		clickFunc = function(self)
			if LFLT_T.historyPage > 1 then
				LFLT_T.updateHistoryPage(LFLT_T.historyPage - 1)
				_G[LFLT_F.pageButtonFrameTextObj2.name]:SetText(LFLT_T.historyPage)
			end
		end,
	}
	
	--Previous Page History Button
	LFLT_F.nextPageButtonFrameObj = {
		template = LFLT_F.prevPageButtonFrameObj,
		name = "LFLT_History_PrevPage_Button",
		xOff = 120,
		pushedTexture 		= rightArrowButtonHighlightTexture,
		highlightTexture	= rightArrowButtonNormalTexture,
		normalTexture 		= rightArrowButtonNormalTexture,
		clickFunc = function(self)
			if LFLT_T.historyPage < ceil(LFLT_T.historyEntryNum / historyButtonNum) then
				LFLT_T.updateHistoryPage(LFLT_T.historyPage + 1)
				_G[LFLT_F.pageButtonFrameTextObj2.name]:SetText(LFLT_T.historyPage)
			end
		end,
	}

	--History Page Button Text
	LFLT_F.pageButtonFrameTextObj = {
		fType = "TEXT",
		name = "LFLT_History_PageButton_Text",
		parent = "LFLT_History_Window_Frame",
		pointOnFrame = "BOTTOMLEFT",
		pointOnParent = "BOTTOMLEFT",
		width = 75,
		height = 30, 
		xOff = 10,
		yOff = 0,
		drawLayer = "OVERLAY",
		fontSize = 12,
		hJustify = "LEFT",
		text = "Page:"
	}
	
	--History Page Button Text Number Display
	LFLT_F.pageButtonFrameTextObj2 = {
		template = LFLT_F.pageButtonFrameTextObj,
		name = "LFLT_History_PageButton_Text2",
		xOff = 70,
		yOff = 0,
		width = 25,
		height = 30, 
		fontSize = 9,
		hJustify = "RIGHT",
		text = string.format("%3d", LFLT_T.historyPage),
	}
	
	--History Page Button Text Number Display
	LFLT_F.pageButtonFrameTextObj3 = {
		template = LFLT_F.pageButtonFrameTextObj,
		name = "LFLT_History_PageButton_Text3",
		xOff = 95,
		yOff = 0,
		width = 25,
		height = 30, 
		fontSize = 9,
		text = string.format("/%3d", math.max(ceil(LFLT_T.historyEntryNum / historyButtonNum),1)),
	}
		
	--Search Bar Frame Editbox
	LFLT_F.settings_Search_EditBoxObj = {
		fType = "EDITBOX",
		name = "LFLT_Settings_Search_Editbox",
		parent = "LFLT_History_Window_Frame",
		pointOnFrame = "TOPLEFT",
		noUITemplate = true,
		width = 730,
		height = 20, 
		xOff = 7.5,
		yOff = -5,
		textInset = {left = 5, right = 5, top = 2.5, bottom = 2.5},
		fontSize = 8,
		hJustify = "LEFT",
		strata = "Medium",
		level = 11,
		boxAutoFocus = false,
		highlightOnClick = true,
		text = "Search",
		backdrop = defaultBackdrop,
		enterpushedFunc =  function(self) 
			local frame = _G[LFLT_F.settings_Search_EditBoxObj.name]
			frame:ClearFocus()
			frame:AddHistoryLine(frame:GetText()) 
			print("This doesn't work yet Dummy: NYI")
		end,
		escapepushedFunc = function(self)
			_G[LFLT_F.settings_Search_EditBoxObj.name]:ClearFocus()
		end,
		func = function(self)
			frame = _G[LFLT_F.settings_Search_EditBoxObj.name]
			frame:ToggleInputLanguage()
			frame:SetMaxLetters(500)
		end,
	}
	
	--Content Type checkboxes
	LFLT_F.settings_ContentEnabled_CheckBoxObj = {
		fType = "CHECKBOX",
		name = "LFLT_Settings_ContentEnabled_CheckBox",
		parent = "LFLT_Settings_Window_Frame",
		pointOnFrame = "TOPLEFT",
		height = 15,
		width = 15,
		xOff = 0,
		yOff = 0,
		strata = "MEDIUM",
		level = 13,
		noUITemplate = true,
		checkedTexture = defaultCheckedTexture,
		backdrop = checkboxBackdrop,
		checkedFunc = function(self, frame, contentType)
			if frame:GetChecked() then
				contentType.enabled = true
			else 
				contentType.enabled = false
			end			
			LFLT_T.updateDisplayVisibility()
		end
	}	
	
	--Location Enabling checkboxes
	LFLT_F.settings_LocationEnabled_CheckBoxObj = {
		template = LFLT_F.settings_ContentEnabled_CheckBoxObj,
		name = "LFLT_Settings_LocationEnabled_CheckBox",
		checkedFunc = function(self, frame, contentType)
			if frame:GetChecked() then
				contentType.enabled = true
			else 
				contentType.enabled = false
			end			
			LFLT_T.updateDisplayVisibility()
		end
	}
			
	--Haste Display checkboxes
	LFLT_F.settings_HasteDisplay_CheckBoxObj = {
		template = LFLT_F.settings_ContentEnabled_CheckBoxObj,
		name = "LFLT_Settings_HasteDisplay_CheckBox",
		parent = "LFLT_Settings_Window_Frame",
		checkedFunc = function(self, frame, contentType)
			if frame:GetChecked() then
				contentType.enabled = true
			else 
				contentType.enabled = false
			end			
			LFLT_T.updateDisplay(2)	
		end
	}
	
	--Haste Display checkboxes
	LFLT_F.settings_HasteDisplay_CheckBoxObj = {
		template = LFLT_F.settings_ContentEnabled_CheckBoxObj,
		name = "LFLT_Settings_HasteDisplay_CheckBox",
		parent = "LFLT_Settings_Window_Frame",
		checkedFunc = function(self, frame, contentType)
			if frame:GetChecked() then
				contentType.enabled = true
			else 
				contentType.enabled = false
			end			
			LFLT_T.updateDisplay(2)	
		end
	}
	
	--Tranquility Background Frame
	LFLT_F.settings_Tranquility_Enable_FrameObj = {
		fType = "FRAME",
		name = "LFLT_settings_Tranquility_Enable_Frame",
		parent = "LFLT_Settings_Window_Frame",
		pointOnFrame = "TOPLEFT",
		xOff = 10,
		yOff = -200,
		width = 150,
		height = 40,
		strata = "MEDIUM",
		level = 12,
		backdrop = defaultBackdrop,
	}
	
	--Tranquility Enable Checkbox
	LFLT_F.settings_Tranquility_Enable_CheckboxObj = {
		template = LFLT_F.settings_ContentEnabled_CheckBoxObj,
		name = "LFLT_settings_Tranquility_Enable_Checkbox",
		parent = LFLT_F.settings_Tranquility_Enable_FrameObj.name,
		pointOnFrame = "TOPLEFT",
		xOff = 10,
		yOff = -10,
		strata = "MEDIUM",
		level = 14,
		noUITemplate = true,
		checkedTexture = defaultCheckedTexture,
		backdrop = checkboxBackdrop,
		checkedFunc = function(self, frame)
			if frame:GetChecked() then
				LFLT.option.ignoreTranquilityEnable = true
			else 
				LFLT.option.ignoreTranquilityEnable = false
			end	
		end,
		func = function(self) 
			frame = _G[self.name]
			if LFLT.option.ignoreTranquilityEnable then
				frame:SetChecked(true)
			else
				frame:SetChecked(false)
			end
			frame:EnableMouse(true)
		end,
	}
	
	--Tranquility Enable Checkbox Text
	LFLT_F.settings_Tranquility_Enable_Checkbox_TextObj = {
		template = LFLT_F.checkBox_Text_Template,
		name = "LFLT_settings_Tranquility_Enable_Checkbox_Text",
		parent = LFLT_F.settings_Tranquility_Enable_CheckboxObj.name,
		text = "Ignore Tranquility",
	}
	
	--Leaf Icon Visibility Background Frame
	LFLT_F.settings_Leaflet_Icon_Enable_FrameObj = {
		fType = "FRAME",
		name = "LFLT_settings_Hide_Leaflet_Icon_Enable_Frame",
		parent = "LFLT_Settings_Window_Frame",
		pointOnFrame = "TOPRIGHT",
		xOff = -10,
		yOff = -200,
		width = 300,
		height = 40,
		strata = "MEDIUM",
		level = 12,
		backdrop = defaultBackdrop,
	}
	
	--Leaf Icon Visibility Background Frame Title
	LFLT_F.settings_Leaflet_Icon_Enable_Frame_TextObj = {
		fType = "TEXT",
		name = "LFLT_settings_Hide_Leaflet_Icon_Enable_Frame_Title",
		parent = LFLT_F.settings_Leaflet_Icon_Enable_FrameObj.name,
		pointOnFrame = "LEFT",
		pointOnParent = "TOPLEFT",
		xOff = 0,
		yOff = 0,
		width = 125,
		height = 40,
		fontSize = 10,
		hJustify = "LEFT",
		text = "Display Icon",
	}
	
	--Lock Display Checkbox
	LFLT_F.settings_Lock_Display_Enable_CheckboxObj = {
		template = LFLT_F.settings_ContentEnabled_CheckBoxObj,
		name = "LFLT_settings_Lock_Display_Enable_Checkbox",
		parent = LFLT_F.settings_Leaflet_Icon_Enable_FrameObj.name,
		pointOnFrame = "TOPLEFT",
		xOff = 10,
		yOff = -10,
		strata = "MEDIUM",
		level = 14,
		checkedFunc = function(self, frame)
			local dependentFrame = _G[LFLT_F.settings_Hide_Leaflet_Icon_Enable_CheckboxObj.name]
			local dependentText  = _G[LFLT_F.settings_Hide_Leaflet_Icon_Enable_Checkbox_TextObj.name]
			if frame:GetChecked() then
				LFLT.option.lock = true
				dependentFrame:Enable()
				dependentText:SetVertexColor(1,1,1)
				if LFLT_T.oncePerSessionAlert.hideDisplayIcon then
					print("Leaflet: Type '/ll' to bring up Leaflet Config.\n'/ll help' for a list of commands.")
					LFLT_T.oncePerSessionAlert.hideDisplayIcon = true
				end
			else 
				LFLT.option.lock = false
				dependentFrame:Disable()
				dependentText:SetVertexColor(0.5,0.5,0.5)
			end	
			LFLT_T.setDisplayLock()
			LFLT_T.SetDisplayTextPos()
		end,
		func = function(self) 
			frame = _G[self.name]
			if LFLT.option.lock then
				frame:SetChecked(true)
			else
				frame:SetChecked(false)
			end
		end,
	}
	
	--Hide Leaflet Icon Checkbox Text
	LFLT_F.settings_Lock_Display_Enable_Checkbox_TextObj = {
		template = LFLT_F.checkBox_Text_Template,
		name = "LFLT_settings_Lock_Display_Enable_Checkbox_Text",
		parent = LFLT_F.settings_Lock_Display_Enable_CheckboxObj.name,
		text = "Lock Display",
	}
	
	--Hide Leaflet Icon Checkbox
	LFLT_F.settings_Hide_Leaflet_Icon_Enable_CheckboxObj = {
		template = LFLT_F.settings_ContentEnabled_CheckBoxObj,
		name = "LFLT_settings_Hide_Leaflet_Icon_Enable_Checkbox",
		parent = LFLT_F.settings_Leaflet_Icon_Enable_FrameObj.name,
		pointOnFrame = "TOPLEFT",
		xOff = 150,
		yOff = -10,
		strata = "MEDIUM",
		level = 14,
		noUITemplate = true,
		checkedTexture = defaultCheckedTexture,
		backdrop = checkboxBackdrop,
		checkedFunc = function(self, frame)
			if frame:GetChecked() then
				LFLT.option.hideIcon = true
				
				if not LFLT_T.oncePerSessionAlert.hideDisplayIcon then
					LFLT_T.oncePerSessionAlert.hideDisplayIcon = true
					print("Leaflet: Type '/ll' to bring up Leaflet Config.\n'/ll help' for a list of commands.")
				end
			else 
				LFLT.option.hideIcon = false
			end	
			LFLT_T.SetDisplayTextPos()
		end,
		func = function(self) 
			frame = _G[self.name]
			parentCheckBox = _G[LFLT_F.settings_Lock_Display_Enable_CheckboxObj.name]
			if parentCheckBox:GetChecked() then
				if LFLT.option.hideIcon then
					frame:SetChecked(true)
				else
					frame:SetChecked(false)
				end
			else
				frame:SetChecked(false)
				frame:Disable()
			end
		end,
	}
		
	--Hide Leaflet Icon Checkbox Text
	LFLT_F.settings_Hide_Leaflet_Icon_Enable_Checkbox_TextObj = {
		template = LFLT_F.settings_Lock_Display_Enable_Checkbox_TextObj,
		name = "LFLT_settings_Hide_Leaflet_Icon_Enable_Checkbox_Text",
		parent = LFLT_F.settings_Hide_Leaflet_Icon_Enable_CheckboxObj.name,
		text = "Hide Icon",
		func = function(self)
			frame = _G[self.name]
			parentCheckBox = _G[LFLT_F.settings_Lock_Display_Enable_CheckboxObj.name]
			if not parentCheckBox:GetChecked() then
				frame:SetVertexColor(0.5,0.5,0.5)
			end
		end
	}
	
	--Composite Haste Ratio
	LFLT_F.settings_Haste_EditBox = {
		fType = "EDITBOX",
		name = "LFLT_Settings_Haste_Editbox",
		parent = LFLT_F.settings_HasteDisplay_CheckBoxObj.name .. "_Background_Frame",
		pointOnFrame = "BOTTOM",
		pointOnParent = "BOTTOM",
		width = 40,
		height = 40, 
		xOff = -50,
		yOff = 10,
		fontSize = 8,
		hJustify = "RIGHT",
		strata = "MEDIUM",
		level = 16,
		boxAutoFocus = false,
		boxNumeric = true,
		highlightOnClick = true,
		numeric = LFLT_T.round(LFLT.hasteCompositeRatio * 100, 1),
		textInset = {top = 0, bottom = 0, left = -5, right = 15},
		enterpushedFunc =  function(self) 
			local frame = _G[self.name]
			local boxVal = LFLT_T.round(frame:GetNumber(),1)
			if boxVal < LFLT_F.settings_Haste_Slider.minValue then 
				boxVal = LFLT_F.settings_Haste_Slider.minValue
			end
			if boxVal > LFLT_F.settings_Haste_Slider.maxValue then 
				boxVal = LFLT_F.settings_Haste_Slider.maxValue
			end
			if _G[LFLT_F.settings_Haste_Slider.name]:GetValue() ~= boxVal then
				_G[LFLT_F.settings_Haste_Slider.name]:SetValue(boxVal)
			end
			LFLT.hasteCompositeRatio = boxVal / 100
			frame:SetNumber(boxVal)
			frame:ClearFocus()
		end,
		escapepushedFunc = function(self)
			_G[LFLT_F.settings_Haste_EditBox.name]:ClearFocus()
		end
	}
	
	--Slider for Composite Haste Ratio
	LFLT_F.settings_Haste_Slider = {
		fType = "SLIDER",
		name = "LFLT_settings_Haste_Slider",
		parent = LFLT_F.settings_Haste_EditBox.name,
		pointOnFrame = "LEFT",
		pointOnParent = "RIGHT",
		width = 100,
		height = 15, 
		xOff = 10,
		yOff = 0,
		strata = "HIGH",
		level = 15,
		-------------------
		orientation = "horizontal",
		thumbTexture = "nil",
		minValue = 0,
		maxValue = 100,
		setMinMaxText = true,
		minText = "",
		maxText = "",
		startValue = LFLT_T.round(LFLT.hasteCompositeRatio, 1),
		stepValue = 1,
		clickFunc = function(self, value)
		
			_G[LFLT_F.settings_Haste_EditBox.name]:SetNumber(value)
			LFLT_F.settings_Haste_EditBox:enterpushedFunc()
		end,
	}
	
	--Editbox for Composite Haste
	LFLT_F.settings_Haste_EditBox_TextObj = { 
		fType = "TEXT",
		name = "LFLT_settings_Display_Scale_EditBox_Text",
		parent = LFLT_F.settings_Haste_EditBox.name,
		pointOnFrame = "RIGHT",
		pointOnParent = "LEFT",
		width = 150,
		height = 75, --handeled by frameGen function
		xOff = -3,
		yOff = 0,
		text = "Ratio:",
		drawLayer = "OVERLAY",
		highlightOnClick = true,
		boxNumeric = true,
		numeric = LFLT.hasteCompositeRatio,
		fontSize = 10, 
		hJustify = "RIGHT",
		color = {1,1,1,1}
	}
	
	--Percent Sign on Composite Haste Editbox
	LFLT_F.settings_Haste_EditBox_TextObj2 = { 
		template = LFLT_F.settings_Haste_EditBox_TextObj,
		name = "LFLT_settings_Display_Scale_EditBox_Text",
		pointOnFrame = "LEFT",
		pointOnParent = "RIGHT",
		width = 15,
		height = 10, --handeled by frameGen function
		xOff = -15,
		yOff = 0,
		text = "%",
		hJustify = "LEFT",
		vJustify = "BOTTOM",
	}
	
	--Search Filter checkboxes
	LFLT_F.settings_SearchFilter_CheckBoxObj = {
		template = LFLT_F.settings_ContentEnabled_CheckBoxObj,
		name = "LFLT_settings_SearchFilter_CheckBox",
		parent = "LFLT_History_Window_Frame",
		checkedFunc = function(self, frame, contentType)
			if frame:GetChecked() then
				contentType.enabled = true
			else 
				contentType.enabled = false
			end			
			-------------------------------Search Filter Update Function here
		end
	}
	
	--Scanner Tooltip
	LFLT_F.scanner_TooltipObj = {
		fType = "TOOLTIP",
		name = "LFLT_Scanner_Tooltip",
		width = 500,
		height = 500,
		doubleLines = 30,
		func = function(self) 
			frame = _G[self.name] 
			frame:SetOwner(UIParent,"ANCHOR_NONE")
			frame:SetAlpha(1)
		end,
	}

	--frameGen Calls
	----Display
	LFLT_T.frameGen(LFLT_F.displayFrameIconObj)
	LFLT_T.frameGen(LFLT_F.displayTextObj1)
	LFLT_T.frameGen(LFLT_F.displayDataTextObj1)
	LFLT_T.frameGen(LFLT_F.displayTextObj2)
	LFLT_T.frameGen(LFLT_F.displayDataTextObj2)
	LFLT_T.frameGen(LFLT_F.displayTextObj3)
	--Message Popup
	LFLT_T.frameGen(LFLT_F.messageFrameObj)
	LFLT_T.frameGen(LFLT_F.message_TextObj)
	--Config
	LFLT_T.frameGen(LFLT_F.configFrameObj)
	LFLT_T.frameGen(LFLT_F.config_Close_ButtonObj)
	LFLT_T.frameGen(LFLT_F.dirFrameObj)
	LFLT_T.frameGen(LFLT_F.actFrameObj)
	LFLT_T.frameGen(LFLT_F.auxFrameObj)
	LFLT_T.frameGen(LFLT_F.BannerFrameObj)
	--Settings
	LFLT_T.frameGen(LFLT_F.settings_DropDownObj1)
	LFLT_T.frameGen(LFLT_F.settings_DropDown1_TextObj)
	LFLT_T.frameGen(LFLT_F.settings_DropDownObj2)
	LFLT_T.frameGen(LFLT_F.settings_DropDown2_TextObj)
	LFLT_T.frameGen(LFLT_F.settings_Display_Scale_EditBox)
	LFLT_T.frameGen(LFLT_F.settings_Display_Scale_EditBox_TextObj)
	LFLT_T.frameGen(LFLT_F.settings_Display_Scale_Slider)
	LFLT_T.frameGen(LFLT_F.settings_Tranquility_Enable_FrameObj)
	LFLT_T.frameGen(LFLT_F.settings_Tranquility_Enable_CheckboxObj)
	LFLT_T.frameGen(LFLT_F.settings_Tranquility_Enable_Checkbox_TextObj)
	LFLT_T.frameGen(LFLT_F.settings_Search_EditBoxObj)
	LFLT_T.frameGen(LFLT_F.settings_Leaflet_Icon_Enable_FrameObj)
	LFLT_T.frameGen(LFLT_F.settings_Leaflet_Icon_Enable_Frame_TextObj)
	LFLT_T.frameGen(LFLT_F.settings_Lock_Display_Enable_CheckboxObj)
	LFLT_T.frameGen(LFLT_F.settings_Lock_Display_Enable_Checkbox_TextObj)
	LFLT_T.frameGen(LFLT_F.settings_Hide_Leaflet_Icon_Enable_CheckboxObj)
	LFLT_T.frameGen(LFLT_F.settings_Hide_Leaflet_Icon_Enable_Checkbox_TextObj)

	--Aux
	LFLT_T.frameGen(LFLT_F.actFrameObj)
	LFLT_T.frameGen(LFLT_F.auxWeightFrameObj)
	LFLT_T.frameGen(LFLT_F.auxFrameWeightTextObjLeft)
	LFLT_T.frameGen(LFLT_F.auxFrameWeightTextObjRight)	
	LFLT_T.frameGen(LFLT_F.auxFrameWeightTextObjCenter)
	--Replay Frame
	LFLT_T.frameGen(LFLT_F.replayFrameObj)
	LFLT_T.frameGen(LFLT_F.auxTalentFrameObj)
	LFLT_T.frameGen(LFLT_F.replayResultWeightFrameObj)
	LFLT_T.frameGen(LFLT_F.replayResultPercentFrameObj)
	LFLT_T.frameGen(LFLT_F.replayResultWeightFrameTextObjLeft)
	LFLT_T.frameGen(LFLT_F.replayResultWeightFrameTextObjRight)
	LFLT_T.frameGen(LFLT_F.replayFrameWeightTextObjCenter)
	LFLT_T.frameGen(LFLT_F.replayResultPercentFrameTextObj)
	LFLT_T.frameGen(LFLT_F.replayButton)
	----Directory and History Buttons
	indexGen(items.directory, 	LFLT_F.directoryButtonFrameObj, 	LFLT_F.directoryButtonTextObj,	700, "TABS")
	indexGen(historyButtonNum,	LFLT_F.historyButtonFrameObj,		LFLT_F.historyButtonTextObj, 	350)
	LFLT_T.frameGen(LFLT_F.nextPageButtonFrameObj)
	LFLT_T.frameGen(LFLT_F.prevPageButtonFrameObj)
	LFLT_T.frameGen(LFLT_F.pageButtonFrameTextObj)
	LFLT_T.frameGen(LFLT_F.pageButtonFrameTextObj2)
	LFLT_T.frameGen(LFLT_F.pageButtonFrameTextObj3)
	----Setting Checkboxs
	checkBoxGen(items.contentType, 
				LFLT_F.settings_ContentEnabled_CheckBoxObj, 
				LFLT_F.checkBox_Text_Template,
				LFLT.enabled, "Tracked Content:", 300, 50, 10, -340, 2, 5, defaultBackdrop)
	checkBoxGen(items.location, 
				LFLT_F.settings_LocationEnabled_CheckBoxObj, 
				LFLT_F.checkBox_Text_Template, 	
				LFLT.enabled, "Show Display during:", 300, 50, 430, -250, 2, 5, defaultBackdrop)
	checkBoxGen(items.hasteDisplay, 
				LFLT_F.settings_HasteDisplay_CheckBoxObj, 
				LFLT_F.checkBox_Text_Template, 	
				LFLT.enabledHaste, "Haste Display:", 300, 80, 10, -250, 2, 5, defaultBackdrop)
	LFLT_T.frameGen(LFLT_F.settings_Haste_EditBox)
	LFLT_T.frameGen(LFLT_F.settings_Haste_Slider)
	LFLT_T.frameGen(LFLT_F.settings_Haste_EditBox_TextObj)
	LFLT_T.frameGen(LFLT_F.settings_Haste_EditBox_TextObj2)
	checkBoxGen(items.historySearch, 
				LFLT_F.settings_SearchFilter_CheckBoxObj, 
				LFLT_F.checkBox_Text_Template, 	
				LFLT.enabledSearch, "", 740, 35, 2.5, -22.5, 5, 5, {})
	--Scanner Tooltip
	LFLT_T.frameGen(LFLT_F.scanner_TooltipObj)
	
	--Startup State Function calls
	LFLT_T.updateHistoryPage()
	LFLT_T.SetDisplayTextPos()
	LFLT_T.updateDisplay(2)
	LFLT_T.updateDisplayVisibility()
	LFLT_T.updateAuxDisplay()
	_G[LFLT_F.displayFrameIconObj.name]:SetScale(LFLT.option.displayScale)
	--Clicks initial directory button.
	_G[LFLT_F.directoryButtonFrameObj.name .. "_" ..items.directory[LFLT.activeWindowCode]]:Click()
	
	--Set Config Hide/Show stat on load.
	if not LFLT.option.configToggle then 
		_G[LFLT_F.configFrameObj.name]:Hide()
	end
			
	--Implement aux frame display on history window button press
	--Implement search for date on history
	--Implement checkbox for LFLT.option.historyScrollWheelEnabled
end