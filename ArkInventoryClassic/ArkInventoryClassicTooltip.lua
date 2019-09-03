local _G = _G
local select = _G.select
local pairs = _G.pairs
local ipairs = _G.ipairs
local string = _G.string
local type = _G.type
local error = _G.error
local table = _G.table


function ArkInventory.TooltipCleanText( txt )
	
	local txt = txt or ""
	
	txt = ArkInventory.StripColourCodes( txt )
	
	txt = txt:gsub( '"', "" )
	txt = txt:gsub( "'", "" )
	
	txt = string.gsub( txt, "\194\160", " " ) -- i dont remember what this is for
	
	txt = string.gsub( txt, "%s", " " )
	txt = string.gsub( txt, "|n", " " )
	txt = string.gsub( txt, "\n", " " )
	txt = string.gsub( txt, "\13", " " )
	txt = string.gsub( txt, "\10", " " )
	txt = string.gsub( txt, "  ", " " )
	
	txt = string.trim( txt )
	
	return txt
	
end

function ArkInventory.TooltipDataReset( tooltip )
	
	if tooltip then
		
		--ArkInventory.Output( tooltip:GetName( ), " has been reset" )
		
		if tooltip.ARKTTD then
			
			if not tooltip.ARKTTD.nopurge then
				wipe( tooltip.ARKTTD.onupdate )
				wipe( tooltip.ARKTTD.args )
			end
			
			tooltip.ARKTTD.nopurge = nil
			
		else
			
			tooltip.ARKTTD = { args = { }, onupdate = { } }
			
		end
		
	end
	
end

function ArkInventory.TooltipScanInit( name )
	
	local tooltip = _G[name]
	assert( tooltip, string.format( "XML Frame [%s] not found", name ) )
	
	ArkInventory.TooltipDataReset( tooltip )
	tooltip.ARKTTD.scan = true
	
	return tooltip
	
end

function ArkInventory.TooltipGetNumLines( tooltip )
	return tooltip:NumLines( ) or 0
end

function ArkInventory.TooltipSetHyperlink( tooltip, h )
	
	tooltip:ClearLines( )
	
	if h then
		
		local osd = ArkInventory.ObjectStringDecode( h )
		
		if osd.class == "item" or osd.class == "spell" or osd.class == "keystone" then
			return tooltip:SetHyperlink( h )
		else
--			ArkInventory.Output( osd.class, " = ", h )
		end
		
	end
	
end

function ArkInventory.TooltipSetBagItem( tooltip, blizzard_id, slot_id )
	
	tooltip:ClearLines( )
	
	return tooltip:SetBagItem( blizzard_id, slot_id )
	
end

function ArkInventory.TooltipSetInventoryItem( tooltip, slot )
	
	tooltip:ClearLines( )
	
	return tooltip:SetInventoryItem( "player", slot )
	
end

function ArkInventory.TooltipSetGuildMailboxItem( tooltip, index, attachment )
	
	tooltip:ClearLines( )
	
	return tooltip:SetInboxItem( index, attachment )
	
end

function ArkInventory.TooltipSetItem( tooltip, bag_id, slot_id )
	
	-- not for offline mode, only direct online scanning of the current player
	
	if bag_id == BANK_CONTAINER then
		
		return ArkInventory.TooltipSetInventoryItem( tooltip, BankButtonIDToInvSlotID( slot_id ) )
		
	else
		
		return ArkInventory.TooltipSetBagItem( tooltip, bag_id, slot_id )
		
	end
	
end


function ArkInventory.TooltipGetMoneyFrame( tooltip )
	
	return _G[string.format( "%s%s", tooltip:GetName( ), "MoneyFrame1" )]
	
end

function ArkInventory.TooltipGetItem( tooltip )
	
	local itemName, ItemLink = tooltip:GetItem( )
	return itemName, ItemLink
	
end

function ArkInventory.TooltipFindBackwards( tooltip, TextToFind, IgnoreLeft, IgnoreRight, CaseSensitive, maxDepth, BaseOnly )
	
	local TextToFind = ArkInventory.TooltipCleanText( TextToFind )
	if TextToFind == "" then
		return false
	end
	
	local IgnoreLeft = IgnoreLeft or false
	local IgnoreRight = IgnoreRight or false
	local CaseSensitive = CaseSensitive or false
	local maxDepth = maxDepth or 0
	local BaseOnly = BaseOnly or false
	
	local obj, txt
	local nextExit = false
	
	for i = ArkInventory.TooltipGetNumLines( tooltip ), 2, -1 do
		
		if nextExit then return end
		
		if maxDepth > 0 and i > maxDepth then return end
		
		obj = _G[string.format( "%s%s%s", tooltip:GetName( ), "TextLeft", i )]
		if obj and obj:IsShown( ) then
			
			txt = obj:GetText( )
			
			if BaseOnly and ( txt == "" or string.find( txt, "^\10" ) or string.find( txt, "^\n" ) or string.find( txt, "^|n" ) ) then
				nextExit = true
			end
			
			if not IgnoreLeft then
				
				txt = ArkInventory.TooltipCleanText( txt )
				
				if CaseSensitive then
					if string.find( txt, TextToFind ) then
						return string.find( txt, TextToFind )
					end
				else
					if string.find( string.lower( txt ), string.lower( TextToFind ) ) then
						return string.find( string.lower( txt ), string.lower( TextToFind ) )
					end
				end
				
			end
			
		end
		
		if not IgnoreRight then
			
			obj = _G[string.format( "%s%s%s", tooltip:GetName( ), "TextRight", i )]
			if obj and obj:IsShown( ) then
				
				txt = ArkInventory.TooltipCleanText( obj:GetText( ) )
				if txt ~= "" then
					
					if CaseSensitive then
						if string.find( txt, TextToFind ) then
							return string.find( txt, TextToFind )
						end
					else
						if string.find( string.lower( txt ), string.lower( TextToFind ) ) then
							return string.find( string.lower( txt ), string.lower( TextToFind ) )
						end
					end
					
				end
				
			end
			
		end
		
	end
	
	return
	
end

function ArkInventory.TooltipFind( tooltip, TextToFind, IgnoreLeft, IgnoreRight, CaseSensitive, maxDepth, BaseOnly )
	
	local TextToFind = ArkInventory.TooltipCleanText( TextToFind )
	if TextToFind == "" then
		return false
	end
	
	local IgnoreLeft = IgnoreLeft or false
	local IgnoreRight = IgnoreRight or false
	local CaseSensitive = CaseSensitive or false
	local maxDepth = maxDepth or 0
	local BaseOnly = BaseOnly or false
	
	local obj, txt
	
	for i = 2, ArkInventory.TooltipGetNumLines( tooltip ) do
		
		if maxDepth > 0 and i > maxDepth then return end
		
		obj = _G[string.format( "%s%s%s", tooltip:GetName( ), "TextLeft", i )]
		if obj and obj:IsShown( ) then
			
			txt = obj:GetText( )
			
			if BaseOnly and ( txt == "" or string.find( txt, "^\10" ) or string.find( txt, "^\n" ) or string.find( txt, "^|n" ) ) then
				return ArkInventory.TooltipFindBackwards( tooltip, TextToFind, IgnoreLeft, IgnoreRight, CaseSensitive, maxDepth, BaseOnly )
			end
			
			if not IgnoreLeft then
				
				txt = ArkInventory.TooltipCleanText( txt )
				
				if CaseSensitive then
					if string.find( txt, TextToFind ) then
						return string.find( txt, TextToFind )
					end
				else
					if string.find( string.lower( txt ), string.lower( TextToFind ) ) then
						return string.find( string.lower( txt ), string.lower( TextToFind ) )
					end
				end
				
			end
			
		end
		
		if not IgnoreRight then
			
			obj = _G[string.format( "%s%s%s", tooltip:GetName( ), "TextRight", i )]
			if obj and obj:IsShown( ) then
				
				txt = ArkInventory.TooltipCleanText( obj:GetText( ) )
				if txt ~= "" then
					
					--ArkInventory.Output( "R[", i, "] = [", txt, "]" )
					
					if CaseSensitive then
						if string.find( txt, TextToFind ) then
							return string.find( txt, TextToFind )
						end
					else
						if string.find( string.lower( txt ), string.lower( TextToFind ) ) then
							return string.find( string.lower( txt ), string.lower( TextToFind ) )
						end
					end
					
				end
				
			end
			
		end
		
	end
	
	return
	
end

function ArkInventory.TooltipGetLine( tooltip, i )

	if not i or i < 1 or i > ArkInventory.TooltipGetNumLines( tooltip ) then
		return
	end
	
	local obj, txt1, txt2
	
	obj = _G[string.format( "%s%s%s", tooltip:GetName( ), "TextLeft", i )]
	if obj and obj:IsShown( ) then
		txt1 = ArkInventory.TooltipCleanText( obj:GetText( ) )
	end
	
	obj = _G[string.format( "%s%s%s", tooltip:GetName( ), "TextRight", i )]
	if obj and obj:IsShown( ) then
		txt2 = ArkInventory.TooltipCleanText( obj:GetText( ) )
	end
	
	return txt1 or "", txt2 or ""
	
end
	
function ArkInventory.TooltipGetBaseStats( tooltip, activeonly )
	
	local obj, txt, ctxt
	
	local started = false
	local rv = ""
	
	for i = 2, ArkInventory.TooltipGetNumLines( tooltip ) do
		
		obj = _G[string.format( "%s%s%s", tooltip:GetName( ), "TextLeft", i )]
		if obj and obj:IsShown( ) then
			
			txt = obj:GetText( )
			ctxt = ArkInventory.TooltipCleanText( txt )
			
			local basestat = false
			if string.find( ctxt, "^%+%d+ " ) then
				--ArkInventory.Output( "1 - ", ctxt )
				basestat = true
			else
				for k, v in pairs( ArkInventory.Const.ItemStats ) do
					local searchtxt = string.format( "^%s$", v )
					if string.find( ctxt, searchtxt ) then
						--ArkInventory.Output( "2 - ", ctxt )
						basestat = true
						break
					end
				end
			end
			
			if started and ( txt == "" or string.find( txt, "^\10" ) or string.find( txt, "^\n" ) or string.find( txt, "^|n" ) or not basestat ) then
				--ArkInventory.Output( "X - ", ctxt )
				return rv
			end
			
			if basestat then
				started = true
				local r, g, b = obj:GetTextColor( )
				local c = string.format( "%02x%02x%02x", r * 255, g * 255, b * 255 )
				--ArkInventory.Output( string.format( "%02i = %s %s", i, c, txt ) )
				if not activeonly or ( activeonly and c ~= "7f7f7f" ) then
					--ArkInventory.Output( "A - ", ctxt )
					rv = rv .. " " .. ctxt
				end
			end
			
			--ArkInventory.Output( "Z - ", ctxt )
			
		end
		
	end
	
	return rv
	
	-- /run ArkInventory.TooltipGetBaseStats( GameTooltip )
	-- /run ArkInventory.TooltipGetBaseStats( GameTooltip, true )
	
end

function ArkInventory.TooltipContains( tooltip, TextToFind, IgnoreLeft, IgnoreRight, CaseSensitive, BaseOnly )
	
	if ArkInventory.TooltipFind( tooltip, TextToFind, IgnoreLeft, IgnoreRight, CaseSensitive, 0, BaseOnly ) then
		return true
	else
		return false
	end
	
end

function ArkInventory.TooltipCanUseBackwards( tooltip, ignoreknown )

	local l = { "TextLeft", "TextRight" }
	
	local n = ArkInventory.TooltipGetNumLines( tooltip )
	
	for i = n, 2, -1 do
		for _, v in pairs( l ) do
			local obj = _G[string.format( "%s%s%s", tooltip:GetName( ), v, i )]
			if obj and obj:IsShown( ) then
				
				local txt = obj:GetText( )
				
				if txt == "" or string.find( txt, "^\10" ) or string.find( txt, "^\n" ) or string.find( txt, "^|n" ) then
					return true
				end
				
				local txt = ArkInventory.TooltipCleanText( txt )
				
				local r, g, b = obj:GetTextColor( )
				local c = string.format( "%02x%02x%02x", r * 255, g * 255, b * 255 )
				if c == "fe1f1f" then
					
					if txt == ArkInventory.Localise["ALREADY_KNOWN"] then
						
						--ArkInventory.Output( "line[", i, "]=[", txt, "] backwards" )
						if not ignoreknown then
							return false
						end
					
					elseif not ( txt == ArkInventory.Localise["ITEM_NOT_DISENCHANTABLE"] or txt == ArkInventory.Localise["PREVIOUS_RANK_UNKNOWN"] or txt == ArkInventory.Localise["TOOLTIP_NOT_READY"] ) then
						
						--ArkInventory.Output( "line[", i, "]=[", txt, "] backwards" )
						return false
						
					end
					
				end

			end
		end
	end

	return true
	
end

function ArkInventory.TooltipCanUse( tooltip, ignoreknown )

	local l = { "TextLeft", "TextRight" }
	
	local n = ArkInventory.TooltipGetNumLines( tooltip )
	
	local t1 = tooltip:GetItem( )
	local line1 = _G[string.format( "%sTextLeft1", tooltip:GetName( ) )]:GetText( )
	
	for i = 2, n do
		for _, v in pairs( l ) do
			
			local obj = _G[string.format( "%s%s%s", tooltip:GetName( ), v, i )]
			if obj and obj:IsShown( ) then
				
				local txt = obj:GetText( )
				
				if txt == "" or string.find( txt, "^\10" ) or string.find( txt, "^\n" ) or string.find( txt, "^|n" ) then
					return ArkInventory.TooltipCanUseBackwards( tooltip, ignoreknown )
				end
				
				txt = ArkInventory.TooltipCleanText( txt )
				
				local r, g, b = obj:GetTextColor( )
				local c = string.format( "%02x%02x%02x", r * 255, g * 255, b * 255 )
				if c == "fe1f1f" then
					
					if txt == ArkInventory.Localise["ALREADY_KNOWN"] then
						
						--ArkInventory.Output( "line[", i, "]=[", txt, "] forwards" )
						if not ignoreknown then
							return false
						end
					
					elseif not ( txt == ArkInventory.Localise["ITEM_NOT_DISENCHANTABLE"] or txt == ArkInventory.Localise["PREVIOUS_RANK_UNKNOWN"] or txt == ArkInventory.Localise["TOOLTIP_NOT_READY"] ) then
						
						--ArkInventory.Output( "line[", i, "]=[", txt, "] forwards" )
						return false
						
					end
					
				end

			end
		end
	end

	return true
	
end

function ArkInventory.TooltipIsReady( tooltip )
	local txt = ArkInventory.TooltipGetLine( tooltip, 1 )
	if txt ~= "" and txt ~= ArkInventory.Localise["TOOLTIP_NOT_READY"] then
		return true
	end
end




function ArkInventory.HookTooltipSetAuctionItem( tooltip, ... )
	
--	checked ok - 3.08.
	
	if not tooltip then return end
	if not ArkInventory:IsEnabled( ) then return end
	if not ArkInventory.db.option.tooltip.show then return end
	if not ArkInventory.db.option.tooltip.add.count then end
	
	local fn = "SetAuctionItem"
	
	--ArkInventory.Output( "0 - ", tooltip:GetName( ), ":", fn )
	
	ArkInventory.SaveTooltipOnUpdateData( tooltip, fn, ... )
	
	local arg1, arg2 = ...

	if arg1 and arg2 then
		local h = GetAuctionItemLink( arg1, arg2 )
		ArkInventory.TooltipAddItemCount( tooltip, h )
	end
	
end

function ArkInventory.HookTooltipSetAuctionSellItem( ... )
	ArkInventory.HookTooltipSetGeneric( "SetAuctionSellItem", ... )
end

function ArkInventory.HookTooltipSetBagItem( ... )
	ArkInventory.HookTooltipSetGeneric( "SetBagItem", ... )
end

function ArkInventory.HookTooltipSetCraftItem( ... )
	ArkInventory.HookTooltipSetGeneric( "SetCraftItem", ... )
end

function ArkInventory.HookTooltipSetCraftSpell( ... )
	ArkInventory.HookTooltipSetGeneric( "SetCraftSpell", ... )
end

function ArkInventory.ReloadTooltipSetHyperlink( tooltip, ... )
	
	local arg1 = ...
	
	if arg1 then
		
		local osd = ArkInventory.ObjectStringDecode( arg1 )
		if osd.class == "item" or osd.class == "spell" or osd.class == "keystone" or osd.class == "copper" or osd.class == "empty" then
			
			-- cant set the same hyperlink twice or it will close the tooltip, so clear it first
			tooltip.ARKTTD.nopurge = true
			tooltip:ClearLines( )
			ArkInventory.ReloadTooltipSetGeneric( tooltip )
			
		end
		
	end
	
end

function ArkInventory.HookTooltipSetHyperlink( ... )
	ArkInventory.HookTooltipSetGeneric( "SetHyperlink", ... )
end

function ArkInventory.HookTooltipSetHyperlinkCompareItem( ... )
	ArkInventory.HookTooltipSetGeneric( "SetHyperlinkCompareItem", ... )
end

function ArkInventory.HookTooltipSetInboxItem( ... )
	ArkInventory.HookTooltipSetGeneric( "SetInboxItem", ... )
end

function ArkInventory.HookTooltipSetInventoryItem( ... )
	ArkInventory.HookTooltipSetGeneric( "SetInventoryItem", ... )
end

function ArkInventory.HookTooltipSetItemByID( ... )
	ArkInventory.HookTooltipSetGeneric( "SetItemByID", ... )
end

function ArkInventory.HookTooltipSetLootItem( ... )
	ArkInventory.HookTooltipSetGeneric( "SetLootItem", ... )
end

function ArkInventory.HookTooltipSetLootRollItem( ... )
	ArkInventory.HookTooltipSetGeneric( "SetLootRollItem", ... )
end

function ArkInventory.HookTooltipSetMerchantItem( ... )
	ArkInventory.HookTooltipSetGeneric( "SetMerchantItem", ... )
end

function ArkInventory.HookTooltipSetBuybackItem( ... )
	ArkInventory.HookTooltipSetGeneric( "SetBuybackItem", ... )
end

function ArkInventory.HookTooltipSetMerchantCostItem( ... )
	ArkInventory.HookTooltipSetGeneric( "SetMerchantCostItem", ... )
end

function ArkInventory.HookTooltipSetQuestItem( ... )
	ArkInventory.HookTooltipSetGeneric( "SetQuestItem", ... )
end

function ArkInventory.HookTooltipSetQuestLogItem( ... )
	ArkInventory.HookTooltipSetGeneric( "SetQuestLogItem", ... )
end

function ArkInventory.HookTooltipSetQuestLogSpecialItem( ... )
	ArkInventory.HookTooltipSetGeneric( "SetQuestLogSpecialItem", ... )
end

function ArkInventory.HookTooltipSetSendMailItem( ... )
	ArkInventory.HookTooltipSetGeneric( "SetSendMailItem", ... )
end

function ArkInventory.HookTooltipSetTradePlayerItem( ... )
	ArkInventory.HookTooltipSetGeneric( "SetTradePlayerItem", ... )
end

function ArkInventory.HookTooltipSetTradeTargetItem( ... )
	ArkInventory.HookTooltipSetGeneric( "SetTradeTargetItem", ... )
end

function ArkInventory.HookTooltipSetQuestLogRewardSpell( ... )
	ArkInventory.HookTooltipSetGeneric( "SetQuestLogRewardSpell", ... )
end

function ArkInventory.HookTooltipSetQuestRewardSpell( ... )
	ArkInventory.HookTooltipSetGeneric( "SetQuestRewardSpell", ... )
end

function ArkInventory.HookTooltipSetRecipeReagentItem( tooltip, ... )
	
--	checked ok - 3.08.09
	
	if not tooltip then return end
	if not ArkInventory:IsEnabled( ) then return end
	if not ArkInventory.db.option.tooltip.show then return end
	if not ArkInventory.db.option.tooltip.add.count then end
	
	local fn = "SetRecipeReagentItem"
	
	--ArkInventory.Output( "0 - ", tooltip:GetName( ), ":", fn )
	
	ArkInventory.SaveTooltipOnUpdateData( tooltip, fn, ... )
	
	local arg1, arg2 = ...
	
	if arg1 and arg2 then
		local h = C_TradeSkillUI.GetRecipeReagentItemLink( arg1, arg2 )
		ArkInventory.TooltipAddItemCount( tooltip, h )
	end
	
end

function ArkInventory.HookTooltipSetRecipeResultItem( tooltip, ... )
	
--	checked ok - 3.08.09
	
	if not tooltip then return end
	if not ArkInventory:IsEnabled( ) then return end
	if not ArkInventory.db.option.tooltip.show then return end
	if not ArkInventory.db.option.tooltip.add.count then end
	
	local fn = "SetRecipeResultItem"
	
	--ArkInventory.Output( "0 - ", tooltip:GetName( ), ":", fn )
	
	ArkInventory.SaveTooltipOnUpdateData( tooltip, fn, ... )
	
	local arg1 = ...
	
	if arg1 then
		local h = C_TradeSkillUI.GetRecipeItemLink( arg1 )
		ArkInventory.TooltipAddItemCount( tooltip, h )
	end

end


function ArkInventory.HookTooltipOnSetItem( ... )
	
--	checked ok - 3.08.
	
	local tooltip = ...
	
	if not tooltip then return end
	if not ArkInventory:IsEnabled( ) then return end
	if not ArkInventory.db.option.tooltip.show then return end
	
	local fn = "OnSetItem"
	
	--ArkInventory.Output( "0 - ", tooltip:GetName( ), ":", fn )
	
	ArkInventory.TooltipDataReset( tooltip )
	
end

function ArkInventory.HookTooltipOnSetSpell( ... )
	
--	checked ok - 3.08.
	
	local tooltip = ...
	
	if not tooltip then return end
	if not ArkInventory:IsEnabled( ) then return end
	if not ArkInventory.db.option.tooltip.show then return end
	
	local fn = "OnSetSpell"
	
	--ArkInventory.Output( "0 - ", tooltip:GetName( ), ":", fn )
	
	ArkInventory.TooltipDataReset( tooltip )
	
end





function ArkInventory.HookTooltipFadeOut( tooltip )
	--ArkInventory.Output( "FadeOut" )
	ArkInventory.TooltipDataReset( tooltip )
end

function ArkInventory.HookTooltipClearLines( tooltip )
	--ArkInventory.Output( "ClearLines" )
	ArkInventory.TooltipDataReset( tooltip )
end

function ArkInventory.HookTooltipSetText( tooltip )
	
	if not tooltip then return end
	if not ArkInventory:IsEnabled( ) then return end
	if not ArkInventory.db.option.tooltip.show then return end
	
--	ArkInventory.Output( "SetText" )
	ArkInventory.TooltipDataReset( tooltip )
	
end

function ArkInventory.HookTooltipOnHide( tooltip )
	
	if not tooltip then return end
	if not ArkInventory:IsEnabled( ) then return end
	if not ArkInventory.db.option.tooltip.show then return end
	
	--ArkInventory.Output( "OnHide" )
	ArkInventory.TooltipDataReset( tooltip )
	
end





function ArkInventory.TooltipGetItemOrSpell( tooltip )
	
	-- generic input, generic reload
	-- typically an item or spell has been set directly so no special handling is required
	
	if not tooltip:IsVisible( ) then
		-- dont add stuff to tooltips until after they become visible for the first time
		-- some of them just dont like it and it can stuff up the formatting
		return
	end
	
	local h
	
	if not h and tooltip["GetItem"] then
		
		local name, link = tooltip:GetItem( )
		--ArkInventory.Output( "[", name, "] = ", string.gsub( link, "\124", "\124\124" ) )
		
		-- check for broken hyperlink bug
		if name and name ~= "" then
			h = link
		end
		
	end
	
	if not h and tooltip["GetSpell"] then
		
		local name, rank, id = tooltip:GetSpell( )
		
		if id then
			h = GetSpellLink( id )
			--ArkInventory.Output( "GetSpell = ", h )
		end
		
	end
	
	if not h then return end
	
	ArkInventory.TooltipAddItemCount( tooltip, h )
	
end

function ArkInventory.ReloadTooltipSetGeneric( tooltip )
	
	local fn = tooltip.ARKTTD.onupdate.fn
	
	if fn then
		
		if tooltip[fn] then
			
			-- check for item comparison
			local compare = false
			
			if GetCVarBool( "alwaysCompareItems" ) then
				
				--ArkInventory.Output( "always compare" )
				compare = true
				
			elseif tooltip.comparing then
				
				--ArkInventory.Output( "comparing" )
				
				if IsModifiedClick( "COMPAREITEMS" ) then
					--ArkInventory.Output( "shift key still down" )
					compare = true
				else
					--ArkInventory.Output( "stop comparing" )
					tooltip.comparing = false
				end
				
			elseif IsModifiedClick( "COMPAREITEMS" ) then
				
				--ArkInventory.Output( "shift key down" )
				compare = true
				tooltip.comparing = true
				
			else
				
				if tooltip.shoppingTooltips then
					
					local shoppingTooltip1, shoppingTooltip2 = unpack( tooltip.shoppingTooltips )
					
					if shoppingTooltip1:IsShown( ) or shoppingTooltip2:IsShown( ) then
						--ArkInventory.Output( "shopping tooltips open" )
						compare = true
					end
					
				end
				
			end
			
			--ArkInventory.Output( "G9 - ", tooltip:GetName( ), ":", fn, "( ", tooltip.ARKTTD.args, " )" )
			tooltip[fn]( tooltip, unpack( tooltip.ARKTTD.args ) )
			
			-- compare if required
			if compare then
				GameTooltip_ShowCompareItem( )
			end

		else
			
			--ArkInventory.OutputError( "non fatal code issue - ", tooltip:GetName( ), " does not have a function named [", fn, "]" )
			
		end
		
	end
end

function ArkInventory.HookTooltipSetGeneric( fn, tooltip, ... )
	
	if not fn then return end
	if not tooltip then return end
	if not ArkInventory:IsEnabled( ) then return end
	if not ArkInventory.db.option.tooltip.show then return end
	if not ArkInventory.db.option.tooltip.add.count then end
	
	if tooltip.ARKTTD.scan then return end
	
	--ArkInventory.Output( "G0 - ", tooltip:GetName( ), ":", fn, "( ", arg1, ", ", arg2, ", ", arg3, ", ", arg4, " )" )
	
	ArkInventory.SaveTooltipOnUpdateData( tooltip, fn, ... )
	
	ArkInventory.TooltipGetItemOrSpell( tooltip )
	
end

function ArkInventory.SaveTooltipOnUpdateData( tooltip, fn, ... )
	
	ArkInventory.TooltipDataReset( tooltip )
	
	tooltip.ARKTTD.onupdate.fn = fn
	tooltip.ARKTTD.onupdate.timer = ArkInventory.Const.TOOLTIP_UPDATE_TIME
	
	local ac = select( '#', ... )
	for ax = 1, ac do
		tooltip.ARKTTD.args[ax] = ( select( ax, ... ) )
	end
	
end

function ArkInventory.HookTooltipOnUpdate( tooltip, elapsed )
	
	if not tooltip then return end
	
	tooltip.ARKTTD.onupdate.timer = ( tooltip.ARKTTD.onupdate.timer or ArkInventory.Const.TOOLTIP_UPDATE_TIME ) - elapsed
	if tooltip.ARKTTD.onupdate.timer > 0 then
		return
	end
	
	tooltip.ARKTTD.onupdate.timer = ArkInventory.Const.TOOLTIP_UPDATE_TIME
	
	if not ArkInventory:IsEnabled( ) then return end
	if not ArkInventory.db.option.tooltip.show then return end
	
	local owner = tooltip:GetOwner( )
	if ( not tooltip.UpdateTooltip ) and not ( owner and owner.UpdateTooltip ) then
		
		-- blizzards code runs the UpdateTooltip function of the tooltip
		-- if it doesnt have one it will check if the tooltips owner has one set and use that
		-- so dont set ours unless both are false
		
		local fn = tooltip.ARKTTD.onupdate.fn
		if fn then
			
			--ArkInventory.Output( tooltip:GetName( ), ":OnUpdate - ", fn, "( ", tooltip.ARKTTD.args, " )" )
			
			local rfn = "ReloadTooltip"..fn
			if ArkInventory[rfn] then
				ArkInventory[rfn]( tooltip, unpack( tooltip.ARKTTD.args ) )
			else
				ArkInventory.ReloadTooltipSetGeneric( tooltip )
				--ArkInventory.Output( "ArkInventory.", rfn, " does not exist" )
			end
			
		else
			
			--ArkInventory.Output( "nothing to do" )
			
		end
		
	else
		
		--ArkInventory.Output( tooltip:GetName( ), " or its owner has an onupdate" )
		
	end
	
	--ArkInventory.TooltipDataReset( tooltip )
	
end






function ArkInventory.TooltipAddEmptyLine( tooltip )
	if ArkInventory.db.option.tooltip.add.empty then
		tooltip:AddLine( " ", 1, 1, 1, 0 )
	end
end

function ArkInventory.TooltipAddItemCount( tooltip, h )
	
	if not h then return end
	if not tooltip then return end
	if not ArkInventory:IsEnabled( ) then return end
	if not ArkInventory.db.option.tooltip.show then return end
	if not ArkInventory.db.option.tooltip.add.count then return end
	
	--ArkInventory.Output( "1 - TooltipAddItemCount" )
	
	local osd = ArkInventory.ObjectStringDecode( h )
	if not ( osd.class == "item" or osd.class == "keystone" or osd.class == "spell" ) then return end
	
	local search_id = ArkInventory.ObjectIDCount( h )
	ArkInventory.TooltipRebuildQueueAdd( search_id )
	
	local ta = ArkInventory.Global.Cache.ItemCountTooltip[search_id]
	
--[[
	data = {
		empty = true|false
		class[class] = { 1=user, 2=vault, 3=account
			count = 0
			total = "string - tooltip total"
			player_id[player_id] = {
				t1 = "string - tooltip left",
				t2 = "string - tooltip right"
			}
		}
	}
]]--	
	
	if ta and not ta.empty then
		
		ArkInventory.TooltipAddEmptyLine( tooltip )
		
		local tc = ArkInventory.db.option.tooltip.colour.count
		local gap = false
		
		for class, cd in ArkInventory.spairs( ta.class ) do
			
			if cd.entries > 0 then
				
				if gap then
					ArkInventory.TooltipAddEmptyLine( tooltip )
				end
				
				for player_id, pd in ArkInventory.spairs( cd.player_id ) do
					tooltip:AddDoubleLine( pd.t1, pd.t2, tc.r, tc.g, tc.b, tc.r, tc.g, tc.b )
				end
				
				if class == 1 and cd.entries > 1 and cd.total then
					tooltip:AddLine( cd.total, tc.r, tc.g, tc.b, 0 )
				end
				
				gap = true
				
			end
			
		end
		
		tooltip:AppendText( "" )
		
		return true
		
	end
	
end

function ArkInventory.TooltipAddItemAge( tooltip, h, blizzard_id, slot_id )
	
	if type( blizzard_id ) == "number" and type( slot_id ) == "number" then
		ArkInventory.TooltipAddEmptyLine( tooltip )
		local bag_id = ArkInventory.BlizzardBagIdToInternalId( blizzard_id )
		tooltip:AddLine( tt, 1, 1, 1, 0 )
	end

end

function ArkInventory.TooltipObjectCountGet( search_id, thread_id )
	
	local tc, changed = ArkInventory.ObjectCountGetRaw( search_id, thread_id )
	
	if not changed and ArkInventory.Global.Cache.ItemCountTooltip[search_id] then
		--ArkInventory.Output( "using cached tooltip count ", search_id )
		return ArkInventory.Global.Cache.ItemCountTooltip[search_id]
	end
	
	--ArkInventory.Output( "building tooltip count ", search_id )
	
	if thread_id then
		ArkInventory.ThreadYield( thread_id )
	end
	
	ArkInventory.Global.Cache.ItemCountTooltip[search_id] = { empty = true, class = { }, count = 0 }
--[[
		empty = true|false
		count = 0
		class[class] = {
			entries = 0,
			count = 0
			player_id[player_id] = {
				t1 = "string - tooltip left",
				t2 = "string - tooltip right"
			}
		}
]]--
	
	local data = ArkInventory.Global.Cache.ItemCountTooltip[search_id]
	
	if tc == nil then
		--ArkInventory.Output( "no count data ", search_id )
		return data
	end
	
	local paint = ArkInventory.db.option.tooltip.colour.class
	local colour = paint and HIGHLIGHT_FONT_COLOR_CODE or ""
	
	local codex = ArkInventory.GetPlayerCodex( )
	local info = codex.player.data.info
	local player_id = info.player_id
	
	local just_me = ArkInventory.db.option.tooltip.me
	local my_realm = ArkInventory.db.option.tooltip.realm
	local include_crossrealm = ArkInventory.db.option.tooltip.crossrealm
	local ignore_other_faction = ArkInventory.db.option.tooltip.faction
	
	local pd = { }
	
	--ArkInventory.Output( tc["Arkayenro - Khaz'goroth"] )
	for pid, rcd in ArkInventory.spairs( tc ) do
		
		local ok = false
		
		if ( not my_realm ) or ( my_realm and rcd.realm == info.realm ) or ( my_realm and include_crossrealm and ArkInventory.IsConnectedRealm( rcd.realm, info.realm ) ) then
			ok = true
		end
		
		if ignore_other_faction and rcd.faction ~= info.faction then
			ok = false
		end
		
		if rcd.class == "ACCOUNT" then
			ok = true
		end
		
		if just_me and pid ~= player_id then
			ok = false
		end
		
		if ok then
			
			ArkInventory.GetPlayerStorage( pid, nil, pd )
			
			local class = rcd.class
			if class == "ACCOUNT" then
				class = 3
			elseif class == "GUILD" then
				class = 2
			else
				class = 1
			end
			
			if not data.class[class] then
				data.class[class] = { entries = 0, count = 0, player_id = { } }
			end
			
			if not data.class[class].player_id[pid] then
				data.class[class].player_id[pid] = { }
			end
			
			data.class[class].player_id[pid].count = rcd.total
			
			local name = ArkInventory.DisplayName3( pd.data.info, paint, codex.player.data.info )
			
			local location_entries = { }
			
			for loc_id, ld in pairs( rcd.location ) do
				
				if ld.c > 0 then
					
					data.empty = false
					
					if rcd.entries > 1 then
						location_entries[#location_entries + 1] = string.format( "%s %s%s|r", ArkInventory.Global.Location[loc_id].Name, colour, FormatLargeNumber( ld.c ) )
					else
						location_entries[#location_entries + 1] = string.format( "%s", ArkInventory.Global.Location[loc_id].Name )
					end
					
				end
				
			end
			
			if data.class[class].player_id[pid].count > 0 then
				
				local hl = ""
				if not ArkInventory.db.option.tooltip.me and pd.data.info.player_id == player_id then
					hl = ArkInventory.db.option.tooltip.highlight
				end
				
				data.class[class].entries = data.class[class].entries + 1
				
				data.class[class].player_id[pid].t1 = string.format( "%s%s|r: %s%s", hl, name, colour, FormatLargeNumber( data.class[class].player_id[pid].count ) )
				data.class[class].player_id[pid].t2 = string.format( "%s", table.concat( location_entries, ", " ) )
				
				data.class[class].count = data.class[class].count + data.class[class].player_id[pid].count
				data.count = data.count + data.class[class].count
				
			end
			
			if data.count > 0 then
				data.class[class].total = string.format( "%s: %s%s", ArkInventory.Localise["TOTAL"], colour, FormatLargeNumber( data.class[class].count ) )
				data.total = string.format( "%s: %s%s", ArkInventory.Localise["TOTAL"], colour, FormatLargeNumber( data.count ) )
			end
			
		end
		
	end
	
	return data
	
end

function ArkInventory.TooltipAddMoneyCoin( frame, amount, txt, r, g, b )
	
	if not frame or not amount then
		return
	end
	
	frame:AddDoubleLine( txt or " ", " ", r or 1, g or 1, b or 1 )
	
	local numLines = frame:NumLines( )
	if not frame.numMoneyFrames then
		frame.numMoneyFrames = 0
	end
	if not frame.shownMoneyFrames then
		frame.shownMoneyFrames = 0
	end
	
	local name = string.format( "%s%s%s", frame:GetName( ), "MoneyFrame", frame.shownMoneyFrames + 1 )
	local moneyFrame = _G[name]
	if not moneyFrame then
		frame.numMoneyFrames = frame.numMoneyFrames + 1
		moneyFrame = CreateFrame( "Frame", name, frame, "TooltipMoneyFrameTemplate" )
		name = moneyFrame:GetName( )
		ArkInventory.MoneyFrame_SetType( moneyFrame, "STATIC" )
	end
	
	moneyFrame:SetPoint( "RIGHT", string.format( "%s%s%s", frame:GetName( ), "TextRight", numLines ), "RIGHT", 15, 0 )
	
	moneyFrame:Show( )
	
	if not frame.shownMoneyFrames then
		frame.shownMoneyFrames = 1
	else
		frame.shownMoneyFrames = frame.shownMoneyFrames + 1
	end
	
	MoneyFrame_Update( moneyFrame:GetName( ), amount )
	
	local leftFrame = _G[string.format( "%s%s%s", frame:GetName( ), "TextLeft", numLines )]
	local frameWidth = leftFrame:GetWidth( ) + moneyFrame:GetWidth( ) + 40
	
	if frame:GetMinimumWidth( ) < frameWidth then
		frame:SetMinimumWidth( frameWidth )
	end
	
	frame.hasMoney = 1

end

function ArkInventory.TooltipAddMoneyText( frame, money, txt, r, g, b )
	if not money then
		return
	elseif money == 0 then
		--frame:AddDoubleLine( txt or "missing text", ITEM_UNSELLABLE, r or 1, g or 1, b or 1, 1, 1, 1 )
		frame:AddDoubleLine( txt or "missing text", ArkInventory.MoneyText( money ), r or 1, g or 1, b or 1, 1, 1, 1 )
	else
		frame:AddDoubleLine( txt or "missing text", ArkInventory.MoneyText( money ), r or 1, g or 1, b or 1, 1, 1, 1 )
	end
end


function ArkInventory.TooltipDump( tooltip )
	
	-- /run ArkInventory.TooltipDump( EmbeddedItemTooltip )
	-- /run ArkInventory.TooltipDump( GameTooltip )
	
	
	local tooltip = tooltip or ArkInventory.Global.Tooltip.Scan
	--local h = "|cffa335ee|Hkeystone:138019:234:2:0:0:0:0|h[Keystone: Return to Karazhan: Upper (2)]|h|r"
	--local h = "keystone:138019:234:2:0:0:0:0"
	--tooltip:SetHyperlink( h )
-- 
--	/run ArkInventory.TooltipDump( ArkInventory.Global.Tooltip.Scan )
--	/run ArkInventory.TooltipDump( GameTooltip )
	ArkInventory.Output( "----- ----- -----" )
	for i = 1, ArkInventory.TooltipGetNumLines( tooltip ) do
		local a, b = ArkInventory.TooltipGetLine( tooltip, i )
		ArkInventory.Output( i, " left: ", a )
		if b ~= "" then
			ArkInventory.Output( i, " right: ", b )
		end
	end
	
	if tooltip:GetParent( ) then
		ArkInventory.Output( "parent = ", tooltip:GetParent( ):GetName( ) )
	else
		ArkInventory.Output( "parent = *not set*" )
	end
	
	if tooltip:GetOwner( ) then
		ArkInventory.Output( "owner = ", tooltip:GetOwner( ):GetName( ) )
	else
		ArkInventory.Output( "owner = *not set*" )
	end
	
end

function ArkInventory.ListAllTooltips( )
	local tooltip = EnumerateFrames( )
	while tooltip do
		if tooltip:GetObjectType( ) == "GameTooltip" then
			local name = tooltip:GetName( )
			if name then
				ArkInventory.Output( name )
			end
		end
		tooltip = EnumerateFrames( tooltip )
	end
end


function ArkInventory.TooltipExtractValueSuffixCheck( level, suffix )
	
	--ArkInventory.Output( "check [", level, "] [", suffix, "]" )
	
	local level = level or 0
	if not ( level == 3 or level == 6 or level == 9 or level == 12 ) then
		return
	end
	
	local suffix = string.trim( suffix ) or ""
	if suffix == "" then
		return
	end
	
	local suffixes = ArkInventory.Localise[string.format( "WOW_ITEM_TOOLTIP_10P%dT", level )]
	if suffixes == "" then
		return
	end
	
	local check
	
	for s in string.gmatch( suffixes, "[^,]+" ) do
		
		check = string.sub( suffix, 1, string.len( s ) )
		
		
		
		if string.lower( check ) == string.lower( s ) then
			--ArkInventory.Output( "pass [", check, "] [", s, "]" )
			return true
		end
		
		--ArkInventory.Output( "fail [", check, "] [", s, "]" )
		
	end
	
end





local TooltipRebuildQueue = { }
local scanning = false

function ArkInventory.TooltipRebuildQueueAdd( search_id )
	
	if not ArkInventory.db.option.tooltip.show then return end
	if not ArkInventory.db.option.tooltip.add.count then return end
	if not search_id then return end
	
	--ArkInventory.Output( "adding ", search_id )
	TooltipRebuildQueue[search_id] = true
	
	ArkInventory:SendMessage( "EVENT_ARKINV_TOOLTIP_REBUILD_QUEUE_UPDATE_BUCKET", "START" )
	
end

local function Scan_Threaded( thread_id )
	
	--ArkInventory.Output( "rebuilding ", ArkInventory.Table.Elements( TooltipRebuildQueue ) )
	
	for search_id in pairs( TooltipRebuildQueue ) do
		
		--ArkInventory.Output( "rebuilding ", search_id )
		
		ArkInventory.TooltipObjectCountGet( search_id, thread_id )
		ArkInventory.ThreadYield( thread_id )
		
		TooltipRebuildQueue[search_id] = nil
		
	end
	
end

local function Scan( )
	
	local thread_id = ArkInventory.Global.Thread.Format.Tooltip
	
	if not ArkInventory.Global.Thread.Use then
		local tz = debugprofilestop( )
		ArkInventory.OutputThread( thread_id, " start" )
		Scan_Threaded( )
		tz = debugprofilestop( ) - tz
		ArkInventory.OutputThread( string.format( "%s took %0.0fms", thread_id, tz ) )
		return
	end
	
	local tf = function ( )
		Scan_Threaded( thread_id )
	end
	
	ArkInventory.ThreadStart( thread_id, tf )
	
end

function ArkInventory:EVENT_ARKINV_TOOLTIP_REBUILD_QUEUE_UPDATE_BUCKET( events )
	
	if not ArkInventory:IsEnabled( ) then return end
	
	if ArkInventory.Global.Mode.Combat then
		return
	end
	
	if not scanning then
		scanning = true
		Scan( )
		scanning = false
	else
		ArkInventory:SendMessage( "EVENT_ARKINV_TOOLTIP_REBUILD_QUEUE_UPDATE_BUCKET", "RESCAN" )
	end
	
end

function ArkInventory:EVENT_ARKINV_TOOLTIP_REBUILD_QUEUE_UPDATE( event )
	ArkInventory:SendMessage( "EVENT_ARKINV_TOOLTIP_REBUILD_QUEUE_UPDATE_BUCKET", event )
end
