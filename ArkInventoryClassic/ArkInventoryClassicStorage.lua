local _G = _G
local select = _G.select
local pairs = _G.pairs
local ipairs = _G.ipairs
local string = _G.string
local type = _G.type
local error = _G.error
local table = _G.table

local ArkInventoryScanCleanupList = { }

function ArkInventory.EraseSavedData( player_id, loc_id, silent )

	-- /run ArkInventory.EraseSavedData( )
	
	--ArkInventory.Output( "EraseSavedData( ", player_id, ", ", loc_id, ", ", silent, " )" )
	
	local rescan
	
	-- erase item/tooltip cache
	ArkInventory.Table.Clean( ArkInventory.Global.Cache.ItemCountTooltip, nil, true )
	ArkInventory.Table.Clean( ArkInventory.Global.Cache.ItemCountRaw, nil, true )
	
	local info = ArkInventory.GetPlayerInfo( )
	local a = ArkInventory.PlayerIDAccount( )
	
	-- erase data
	for pk, pv in pairs( ArkInventory.db.player.data ) do
		
		if ( not player_id ) or ( pk == player_id ) then
			
			for lk, lv in pairs( pv.location ) do
				
				if ( loc_id == nil ) or ( lk == loc_id ) then
					
					ArkInventory.Frame_Main_Hide( lk )
					
					lv.slot_count = 0
					
					for bk, bv in pairs( lv.bag ) do
						ArkInventory.Table.Clean( bv )
						bv.status = ArkInventory.Const.Bag.Status.Unknown
						bv.type = ArkInventory.Const.Slot.Type.Unknown
						bv.count = 0
						bv.empty = 0
						table.wipe( bv.slot )
					end
					
					--ArkInventory.OutputWarning( "EraseSavedData - .Recalculate" )
					ArkInventory.Frame_Main_DrawStatus( lk, ArkInventory.Const.Window.Draw.Recalculate )
					
					if ArkInventory.Global.Location[lk] and not silent then
						ArkInventory.Output( "Saved ", string.lower( ArkInventory.Global.Location[lk].Name ), " data for ", pk, " has been erased" )
					end
					
					if pk == a then
						rescan = true
					end
					
				end
				
			end
			
			if pk == info.player_id then
				rescan = true
			else
				if ( loc_id == nil ) then
					table.wipe( pv.info )
				end
			end
			
		end
		
	end
	
	if rescan then
		-- current player, or account, was wiped, need to rescan
		ArkInventory.PlayerInfoSet( )
		ArkInventory.ScanLocation( )
	end
	
end


function ArkInventory.PlayerInfoSet( )
	
	--ArkInventory.Output( "PlayerInfoSet" )
	
	local n = UnitName( "player" )
	local r = GetRealmName( )
	local id = ArkInventory.PlayerIDSelf( )
	
	local player = ArkInventory.db.player.data[id].info
	
	player.guid = UnitGUID( "player" ) or player.guid
	player.name = n
	player.realm = r
	player.player_id = id
	player.isplayer = true
	
	local faction, faction_local = UnitFactionGroup( "player" )
	player.faction = faction or player.faction
	player.faction_local = faction_local or player.faction_local
	if player.faction_local == "" then
		player.faction_local = FACTION_STANDING_LABEL4
	end
	
	-- WARNING, most of this stuff is not available upon first login, even when the mod gets to OnEnabled (ui reloads are fine), and some are not available on logout
	
	local class_local, class = UnitClass( "player" )
	player.class_local = class_local or player.class_local
	player.class = class or player.class
	
	player.level = UnitLevel( "player" ) or player.level or 1
	
	local race_local, race = UnitRace( "player" )
	player.race_local = race_local or player.race_local
	player.race = race or player.race
	
	player.gender = UnitSex( "player" ) or player.gender
	
	local m = GetMoney( ) or player.money
	if m > 0 then  -- returns 0 on logout so dont wipe the current value
		player.money = m
	end
	
	-- ACCOUNT
	local id = ArkInventory.PlayerIDAccount( )
	local account = ArkInventory.db.player.data[id].info
	
	account.name = ArkInventory.Localise["LOCATION_ACCOUNT"]
	account.realm = player.realm
	account.player_id = id
	account.faction = ""
	account.faction_local = ""
	account.class = "ACCOUNT"
	account.class_local = ArkInventory.Localise["LOCATION_ACCOUNT"]
	account.level = account.level or 1
	
	-- VAULT
	local gname, grank_text, grank, grealm = GetGuildInfo( "player" )
	--ArkInventory.Output( "IsInGuild=[", IsInGuild( ), "], g=[", gn, "], r=[", grealm, "]" )
	
	if not gname then
		
		if IsInGuild( ) then
			--ArkInventory.OutputWarning( "you are in a guild but no guild name was found, keep previous data" )
		else
			player.guild_id = nil
		end
		
	else
		
		player.guild_id = string.format( "%s%s%s%s", ArkInventory.Const.GuildTag, gname, ArkInventory.Const.PlayerIDSep, grealm or r )
		
	end
	
	
	return player
	
end

function ArkInventory.PlayerIDSelf( )
	return string.format( "%s%s%s", UnitName( "player" ), ArkInventory.Const.PlayerIDSep, GetRealmName( ) )
end

function ArkInventory.PlayerIDAccount( )
	local a = "!ACCOUNT"
	return string.format( "%s%s%s", a, ArkInventory.Const.PlayerIDSep, a )
end

function ArkInventory:EVENT_ARKINV_STORAGE( event, arg1, arg2, arg3, arg4 )
	
	-- not used yet
	
	--ArkInventory.Output( event, "( ", arg1, ", ", arg2, ", ", arg3, ", ", arg4, " )" )
	
	if arg1 == ArkInventory.Const.Event.ItemUpdate then
		
		
		ArkInventory:SendMessage( "EVENT_ARKINV_CHANGER_UPDATE_BUCKET", arg2 )
		
	elseif arg1 == ArkInventory.Const.Event.BagUpdate then
		
		--ArkInventory.Output( "BAG_UPDATE( ", arg2, ", [", arg4, "] )" )
		ArkInventory.Frame_Main_Generate( arg2, arg4 )
		
		--ArkInventory:SendMessage( "EVENT_ARKINV_CHANGER_UPDATE_BUCKET", arg2 )
		
	else
		
		error( string.format( "code failure: unknown storage event [%s]", arg1 ) )
		
	end
	
end


function ArkInventory:EVENT_ARKINV_PLAYER_ENTER( initialLogin, reloadingUI )

	--ArkInventory.Output( "EVENT_ARKINV_PLAYER_ENTER" )
	
	ArkInventory.PlayerInfoSet( )
	
end

function ArkInventory:EVENT_ARKINV_PLAYER_LEAVE( )

	--ArkInventory.Output( "EVENT_ARKINV_PLAYER_LEAVE" )
	
	ArkInventory.Frame_Main_Hide( )
	
	ArkInventory.PlayerInfoSet( )
	
	ArkInventory.ScanAuctionExpire( )
	
	local player_id = ArkInventory.PlayerIDSelf( )
	
	for loc_id, loc_data in pairs( ArkInventory.Global.Location ) do
		if not ArkInventory.LocationIsSaved( loc_id ) then
			ArkInventory.EraseSavedData( player_id, loc_id, true )
		end
	end
	
end

function ArkInventory:EVENT_ARKINV_PLAYER_MONEY_BUCKET( bucket )
	
	--ArkInventory.Output( "PLAYER_MONEY_BUCKET[ ", bucket, " ]" )
	
	if ArkInventory.db.option.junk.sell and not ArkInventory.Global.Junk.run then
		
		if ArkInventory.db.option.junk.notify and ( ArkInventory.Global.Junk.sold > 0 or ArkInventory.Global.Junk.destroyed > 0 ) then
			
			--ArkInventory.Output( "end amount ", GetMoney( ) )
			ArkInventory.Global.Junk.money = GetMoney( ) - ArkInventory.Global.Junk.money
			--ArkInventory.Output( "difference ", ArkInventory.Global.Junk.money )
			--ArkInventory.Output( "sold ", ArkInventory.Global.Junk.sold )
			--ArkInventory.Output( "destroyed ", ArkInventory.Global.Junk.destroyed )
			
			if ArkInventory.Global.Junk.sold > 0 and ArkInventory.Global.Junk.money > 0 then
				ArkInventory.Output( string.format( ArkInventory.Localise["CONFIG_JUNK_SELL_NOTIFY_SOLD"], ArkInventory.MoneyText( ArkInventory.Global.Junk.money, true ) ) )
			end
			
			if ArkInventory.Global.Junk.destroyed > 0 then
				ArkInventory.Output( string.format( ArkInventory.Localise["CONFIG_JUNK_SELL_NOTIFY_DESTROYED"], ArkInventory.Global.Junk.destroyed ) )
			end
			
		end
		
		ArkInventory.Global.Junk.sold = 0
		ArkInventory.Global.Junk.destroyed = 0
		ArkInventory.Global.Junk.money = 0
		
	end
	
	
	ArkInventory.PlayerInfoSet( )
	
	-- set saved money amount here as well
	local info = ArkInventory.GetPlayerInfo( )
	info.money = GetMoney( )
	
	ArkInventory.LDB.Money:Update( )
	
end

function ArkInventory:EVENT_ARKINV_PLAYER_MONEY( ... )
	
	local event = ...
--	ArkInventory.Output( "[", event, "]" )
	
	ArkInventory:SendMessage( "EVENT_ARKINV_PLAYER_MONEY_BUCKET", event )
	
end

function ArkInventory:EVENT_ARKINV_PLAYER_SKILLS( ... )

--	local event = ...
--	ArkInventory.Output( "[", event, "]" )
	
	--ArkInventory.ScanProfessions( )
	
end

function ArkInventory:EVENT_ARKINV_COMBAT_ENTER( ... )
	
--	local event = ...
--	ArkInventory.Output( "[", event, "]" )
	
	ArkInventory.Global.Mode.Combat = true
	
	if ArkInventory.db.option.auto.close.combat then
		ArkInventory.Frame_Main_Hide( )
	end
	
end

function ArkInventory:EVENT_ARKINV_COMBAT_LEAVE( ... )
	
--	local event = ...
--	ArkInventory.Output( "[", event, "]" )
	
	ArkInventory.Global.Mode.Combat = false
	
	for loc_id in pairs( ArkInventory.Global.LeaveCombatRun ) do
		
		ArkInventory.Global.LeaveCombatRun[loc_id] = nil
		
		ArkInventory.ScanLocation( loc_id )
		
	end
	
	ArkInventory:EVENT_ARKINV_TOOLTIP_REBUILD_QUEUE_UPDATE( "START" )
	
	for loc_id, loc_data in pairs( ArkInventory.Global.Location ) do
		if loc_data.canView then
			
			if loc_data.tainted then
				
				--ArkInventory.Output( "tainted ", loc_id )
				--ArkInventory.OutputWarning( "EVENT_ARKINV_COMBAT_LEAVE - .Recalculate" )
				ArkInventory.Frame_Main_Generate( loc_id, ArkInventory.Const.Window.Draw.Recalculate )
				
			else
				
				local me = ArkInventory.GetPlayerCodex( loc_id )
				if me.style.slot.cooldown.show and not me.style.slot.cooldown.combat  then
					--ArkInventory.Output( "cooldown ", loc_id )
					ArkInventory.Frame_Main_Generate( loc_id, ArkInventory.Const.Window.Draw.Refresh )
				end
				
			end
			
		end
	end
	
end

function ArkInventory:EVENT_ARKINV_LOCATION_SCANNED_BUCKET( bucket )
	
	--ArkInventory.Output( "EVENT_ARKINV_LOCATION_SCANNED_BUCKET( ", bucket, " )" )
	
	--ArkInventory.Output( ArkInventoryScanCleanupList )
	
	for loc_id in pairs( bucket ) do
	
		-- cleanup changed items
		
		--ArkInventory.RestackResume( loc_id )
		
		ArkInventory.Frame_Main_Generate( loc_id )
		
	end
	
	
	
	for search_id, ld in pairs( ArkInventoryScanCleanupList ) do
		for loc_id in pairs( ld ) do
			
			if ArkInventory.Table.Elements( ArkInventory.Global.Location[loc_id].scanning.r ) == 0 and ArkInventory.Table.Elements( ArkInventory.Global.Location[loc_id].scanning.q ) == 0 then
				
				ld[loc_id] = nil
				
				local player_id = ArkInventory.PlayerIDSelf( )
				ArkInventory.ObjectCacheCountClear( search_id, player_id, loc_id )
				
				if ArkInventory.Table.Elements( ld ) == 0 then
					ArkInventoryScanCleanupList[search_id] = nil
				end
				
			end
			
		end
	end

	
	ArkInventory.LDB.Bags:Update( )
	ArkInventory.LDB.Tracking_Item:Update( )
	
end

function ArkInventory:EVENT_ARKINV_BAG_UPDATE_BUCKET( bucket )
	
	--ArkInventory.Output( "BAG BUCKET [", bucket, "]" )
	
	-- bucket[blizzard_id] = true
	
	
	local loc = { }
	
	for blizzard_id in pairs( bucket ) do
		local loc_id = ArkInventory.BlizzardBagIdToInternalId( blizzard_id )
		loc[loc_id] = true
	end
	
	if loc[ArkInventory.Const.Location.Bag] then
		-- re-scan empty bag slots as when you move a bag from one bag slot into an empty bag slot no event is triggered for the empty slot
		for _, blizzard_id in pairs( ArkInventory.Global.Location[ArkInventory.Const.Location.Bag].Bags ) do
			if GetContainerNumSlots( blizzard_id ) == 0 then
				bucket[blizzard_id] = true
			end
		end
	end
	
	for loc_id in pairs( loc ) do
		if ArkInventory.Global.Location[loc_id].canView then
			
			-- instant sorting enabled?
			local me = ArkInventory.GetPlayerCodex( loc_id )
			if me.style.sort.when == ArkInventory.Const.SortWhen.Instant then
				--ArkInventory.OutputWarning( "EVENT_ARKINV_BAG_UPDATE_BUCKET - .Recalculate" )
				ArkInventory.Frame_Main_DrawStatus( loc_id, ArkInventory.Const.Window.Draw.Recalculate )
			end
			
		end
	end
	
	ArkInventory.Scan( bucket )
	
end

function ArkInventory:EVENT_ARKINV_BAG_UPDATE( ... )
	
	local event, arg1 = ...
--	ArkInventory.Output( "[", event, "] [", arg1, "]" )
	
	ArkInventory:SendMessage( "EVENT_ARKINV_BAG_UPDATE_BUCKET", arg1 )
	
end

function ArkInventory:EVENT_ARKINV_BAG_LOCK( ... )
	
	local event, arg1, arg2 = ...
	--ArkInventory.Output( "[", event, "] [", arg1, "/", arg2, "]" )
	
	if not arg2 then
		
		-- player bag lock
		ArkInventory.Frame_Changer_Update( ArkInventory.Const.Location.Bag )
		
	else
		
		if arg1 == BANK_CONTAINER then
			
			local count = GetContainerNumSlots( BANK_CONTAINER )
			
			if arg2 <= count then
				-- bank item lock
				local loc_id, bag_id = ArkInventory.BlizzardBagIdToInternalId( arg1 )
				ArkInventory.Frame_Item_Update( loc_id, bag_id, arg2 )
			else
				-- bank bag lock
				ArkInventory.Frame_Changer_Update( ArkInventory.Const.Location.Bank )
			end
			
		else
			
			-- player item lock
			local loc_id, bag_id = ArkInventory.BlizzardBagIdToInternalId( arg1 )
			ArkInventory.Frame_Item_Update( loc_id, bag_id, arg2 )
			
		end
		
	end
	
end

function ArkInventory:EVENT_ARKINV_CHANGER_UPDATE_BUCKET( bucket )
	
	--ArkInventory.Output( "[EVENT_ARKINV_CHANGER_UPDATE_BUCKET] [", bucket, "]" )
	
	-- bucket = table in the format loc_id_id=true so we need to loop through them
	
	for k in pairs( bucket ) do
		ArkInventory.Frame_Changer_Update( k )
	end
	
end

function ArkInventory:EVENT_ARKINV_TALENT_CHANGED( ... )
	
--	local event, arg1, arg2 = ...
--	ArkInventory.Output( event, "( ", arg1, ", ", arg2 )
	
--	hyperlinks include a specid which changes when you change specs
--	making every item a different item at the full hyperlink level
--	and that screws up direct comparisons as the items are now all different
	
--	this is here as a reminder that this will happen so be careful when comparing full hyperlinks/itemstrings
--	use the internal custom h2 links where possible instead
	
end

function ArkInventory:EVENT_ARKINV_BANK_ENTER( ... )
	
--	local event = ...
--	ArkInventory.Output( "[", event, "]" )
	
	local loc_id = ArkInventory.Const.Location.Bank
	
	ArkInventory.Global.Mode.Bank = true
	
	ArkInventory.ScanLocation( loc_id )
	
	ArkInventory.Frame_Main_DrawStatus( loc_id, ArkInventory.Const.Window.Draw.Refresh )
	
	if ArkInventory.LocationIsControlled( loc_id ) then
		ArkInventory.Frame_Main_Show( loc_id )
	end
	
	if ArkInventory.db.option.auto.open.bank and ArkInventory.LocationIsControlled( ArkInventory.Const.Location.Bag ) then
		ArkInventory.Frame_Main_Show( ArkInventory.Const.Location.Bag )
	end
	
end

function ArkInventory:EVENT_ARKINV_BANK_LEAVE_BUCKET( bucket )
	
--	ArkInventory.Output( "[EVENT_ARKINV_BANK_LEAVE_BUCKET] [", bucket, "]" )
	
	local loc_id = ArkInventory.Const.Location.Bank
	
	ArkInventory.Global.Mode.Bank = false
	ArkInventory.Global.Location[loc_id].isOffline = true
	
	ArkInventory.Frame_Main_DrawStatus( loc_id, ArkInventory.Const.Window.Draw.Refresh )
	
	if ArkInventory.LocationIsControlled( loc_id ) then
		ArkInventory.Frame_Main_Hide( loc_id )
	end
	
	if ArkInventory.db.option.auto.close.bank and ArkInventory.LocationIsControlled( ArkInventory.Const.Location.Bag ) then
		ArkInventory.Frame_Main_Hide( ArkInventory.Const.Location.Bag )
	end
	
	if not ArkInventory.LocationIsSaved( loc_id ) then
		local me = ArkInventory.GetPlayerCodex( )
		ArkInventory.EraseSavedData( me.player.data.info.player_id, loc_id, not me.profile.location[loc_id].notify )
	end
	
end

function ArkInventory:EVENT_ARKINV_BANK_LEAVE( ... )
	
	local event = ...
--	ArkInventory.Output( "[", event, "]" )
	
	ArkInventory:SendMessage( "EVENT_ARKINV_BANK_LEAVE_BUCKET", event )
	
end

function ArkInventory:EVENT_ARKINV_BANK_UPDATE( ... )
	
	local event, arg1 = ...
--	ArkInventory.Output( "[", event, "] [", arg1, "]" )

	-- player changed a bank bag or item
	
	local count = GetContainerNumSlots( BANK_CONTAINER )
	
	if arg1 <= count then
		-- item was changed
		ArkInventory:EVENT_ARKINV_BAG_UPDATE( event, BANK_CONTAINER )
	else
		-- bag was changed
		ArkInventory:EVENT_ARKINV_BAG_UPDATE( event, arg1 - count + NUM_BAG_SLOTS )
	end
	
end

function ArkInventory:EVENT_ARKINV_BANK_SLOT( ... )
	
--	local event = ...
--	ArkInventory.Output( "[", event, "]" )
	
	-- player just purchased a bank bag slot, re-scan and force a reload
	
	ArkInventory.ScanLocation( ArkInventory.Const.Location.Bank )
	ArkInventory.Frame_Main_Generate( ArkInventory.Const.Location.Bank, ArkInventory.Const.Window.Draw.Refresh )
	
end

function ArkInventory:EVENT_ARKINV_BANK_TAB( ... )
	
	local event = ...
--	ArkInventory.Output( "[", event, "]" )
	
end


function ArkInventory:EVENT_ARKINV_INVENTORY_CHANGE_BUCKET( )
	
	--ArkInventory.Output( "EVENT_ARKINV_INVENTORY_CHANGE_BUCKET" )
	
	local loc_id = ArkInventory.Const.Location.Wearing
	
	ArkInventory.ScanLocation( loc_id )
	
end

function ArkInventory:EVENT_ARKINV_INVENTORY_CHANGE( event, arg1, arg2 )
	
	--ArkInventory.Output( "EVENT_ARKINV_INVENTORY_CHANGE( ", arg1, ", ", arg2, " ) " )

	if arg1 == "player" then
		ArkInventory:SendMessage( "EVENT_ARKINV_INVENTORY_CHANGE_BUCKET" )
	end
	
end


function ArkInventory:EVENT_ARKINV_MAIL_ENTER( event, ... )
	
	--ArkInventory.Output( "MAIL_ENTER( ", event, " )" )
	
	ArkInventory.Global.Mode.Mail = true
	
end

function ArkInventory:EVENT_ARKINV_MAIL_LEAVE( )
	
	--ArkInventory.Output( "MAIL_LEAVE" )
	
	ArkInventory:SendMessage( "EVENT_ARKINV_MAIL_LEAVE_BUCKET" )
	
end

function ArkInventory:EVENT_ARKINV_MAIL_LEAVE_BUCKET( )
	
	--ArkInventory.Output( "MAIL_LEAVE_BUCKET" )
	
	ArkInventory.Global.Mode.Mail = false
	
	if not ArkInventory:IsEnabled( ) then return end
	
	
	local loc_id = ArkInventory.Const.Location.Mail
	
	if ArkInventory.db.option.auto.close.mail and ArkInventory.LocationIsControlled( ArkInventory.Const.Location.Bag ) then
		ArkInventory.Frame_Main_Hide( ArkInventory.Const.Location.Bag )
	end
	
	if not ArkInventory.LocationIsSaved( loc_id ) then
		local codex = ArkInventory.GetPlayerCodex( )
		ArkInventory.EraseSavedData( codex.player.data.info.player_id, loc_id, not codex.profile.location[loc_id].notify )
	end
	
end

function ArkInventory:EVENT_ARKINV_MAIL_UPDATE_BUCKET( )
	
	--ArkInventory.Output( "MAIL_UPDATE_BUCKET" )
	
	ArkInventory.ScanMailInbox( )
	
end

function ArkInventory:EVENT_ARKINV_MAIL_UPDATE_MASSIVE_BUCKET( )
	
	--ArkInventory.Output( "MAIL_UPDATE_BUCKET" )
	
	ArkInventory.ScanMailInbox( true )
	
end

function ArkInventory:EVENT_ARKINV_MAIL_UPDATE( event )

	--ArkInventory.Output( "MAIL_UPDATE( ", event, " )" )
	
	ArkInventory:SendMessage( "EVENT_ARKINV_MAIL_UPDATE_BUCKET" )
	
end


function ArkInventory:EVENT_ARKINV_MAIL_SEND_SUCCESS( )
	
	--ArkInventory.Output( "MAIL_SEND_SUCCESS( ", ArkInventory.Global.Cache.SentMail, " )" )
	
	ArkInventory.ScanMailSentData( )
	
end

function ArkInventory.HookMailSend( ... )
	
	--ArkInventory.Output( "HookMailSend( )" )
	
	if not ArkInventory:IsEnabled( ) then return end
	
	local loc_id = ArkInventory.Const.Location.Mail
	
	if not ArkInventory.LocationIsMonitored( loc_id ) then return end
	
	table.wipe( ArkInventory.Global.Cache.SentMail )
	
	local recipient, subject, body = ...
	local n, r = strsplit( "-", recipient )
	r = r or GetRealmName( )
	
	local player_id = string.format( "%s%s%s", n, ArkInventory.Const.PlayerIDSep, r )
	if ArkInventory.db.player.data[player_id].info.player_id ~= player_id then
		return
	end
	
	-- known character, store sent mail data
	
	ArkInventory.Global.Cache.SentMail.to = player_id
	local info = ArkInventory.GetPlayerInfo( )
	ArkInventory.Global.Cache.SentMail.from = info.player_id
	ArkInventory.Global.Cache.SentMail.age = ArkInventory.TimeAsMinutes( )
	
	local name, texture, _, count
	for x = 1, ATTACHMENTS_MAX_SEND do
		
		name, texture, _, count = GetSendMailItem( x )
		if name then
			ArkInventory.Global.Cache.SentMail[x] = { n = name, c = count, h = GetSendMailItemLink( x ) }
		end
		
	end
	
end

function ArkInventory.HookMailReturn( index )
	
	--ArkInventory.Output( "HookMailReturn( ", index, " )" )
	
	if not ArkInventory:IsEnabled( ) then return end
	
	local loc_id = ArkInventory.Const.Location.Mail
	
	if not ArkInventory.LocationIsMonitored( loc_id ) then return end
	
	table.wipe( ArkInventory.Global.Cache.SentMail )
	
	local _, _, recipient = GetInboxHeaderInfo( index )
	
	local n, r = strsplit( "-", recipient )
	r = r or GetRealmName( )
	
	local player_id = string.format( "%s%s%s", n, ArkInventory.Const.PlayerIDSep, r )
	if ArkInventory.db.player.data[player_id].info.player_id ~= player_id then
		return
	end
	
	-- known character, store sent mail data
	ArkInventory.Global.Cache.SentMail.to = player_id
	local info = ArkInventory.GetPlayerInfo( )
	ArkInventory.Global.Cache.SentMail.from = info.player_id
	ArkInventory.Global.Cache.SentMail.age = ArkInventory.TimeAsMinutes( )
	
	local name, texture, _, count
	for x = 1, ATTACHMENTS_MAX_RECEIVE do
		
		name, texture, _, count = GetInboxItem( index, x )
		if name then
			ArkInventory.Global.Cache.SentMail[x] = { n = name, c = count, h = GetInboxItemLink( index, x ) }
		end
		
	end
	
	ArkInventory.ScanMailSentData( )
	
end

function ArkInventory:EVENT_ARKINV_TRADE_ENTER( event )

	--ArkInventory.Output( "[", event, "]" )
	
	if ArkInventory.db.option.auto.open.trade and ArkInventory.LocationIsControlled( ArkInventory.Const.Location.Bag ) then
		ArkInventory.Frame_Main_Show( ArkInventory.Const.Location.Bag )
	end
	
end

function ArkInventory:EVENT_ARKINV_TRADE_LEAVE( event )

	--ArkInventory.Output( "[", event, "]" )
	
	if ArkInventory.db.option.auto.close.trade and ArkInventory.LocationIsControlled( ArkInventory.Const.Location.Bag ) then
		ArkInventory.Frame_Main_Hide( ArkInventory.Const.Location.Bag )
	end
	
end


function ArkInventory:EVENT_ARKINV_AUCTION_ENTER( event )
	
	--ArkInventory.Output( "[", event, "]" )
	
	ArkInventory.Global.Mode.Auction = true
	
	if ArkInventory.db.option.auto.open.auction and ArkInventory.LocationIsControlled( ArkInventory.Const.Location.Bag ) then
		ArkInventory.Frame_Main_Show( ArkInventory.Const.Location.Bag )
	end
	
end

function ArkInventory:EVENT_ARKINV_AUCTION_LEAVE_BUCKET( )
	
	--ArkInventory.Output( "[EVENT_ARKINV_AUCTION_LEAVE_BUCKET]" )
	
	if ArkInventory.db.option.auto.close.auction and ArkInventory.LocationIsControlled( ArkInventory.Const.Location.Bag ) then
		ArkInventory.Frame_Main_Hide( ArkInventory.Const.Location.Bag )
	end
	
	ArkInventory.Global.Mode.Auction = false
	
end

function ArkInventory:EVENT_ARKINV_AUCTION_LEAVE( event )
	
	--ArkInventory.Output( "[", event, "]" )
	
	ArkInventory:SendMessage( "EVENT_ARKINV_AUCTION_LEAVE_BUCKET" )
	
end

function ArkInventory:EVENT_ARKINV_AUCTION_UPDATE_BUCKET( )
	
	--ArkInventory.Output( "[EVENT_ARKINV_AUCTION_UPDATE_BUCKET]" )
	
	ArkInventory.ScanAuction( )
	
end

function ArkInventory:EVENT_ARKINV_AUCTION_UPDATE( )
	
	--ArkInventory.Output( "EVENT_ARKINV_AUCTION_UPDATE" )
	
	ArkInventory:SendMessage( "EVENT_ARKINV_AUCTION_UPDATE_BUCKET" )
	
end

function ArkInventory:EVENT_ARKINV_AUCTION_UPDATE_MASSIVE_BUCKET( )
	
	--ArkInventory.Output( "[EVENT_ARKINV_AUCTION_UPDATE_MASSIVE_BUCKET]" )
	
	ArkInventory.ScanAuction( true )
	
end

function ArkInventory:EVENT_ARKINV_MERCHANT_ENTER( event, ... )
	
	--ArkInventory.Output( "[", event, "]" )
	
	ArkInventory.Global.Mode.Merchant = true
	
end

function ArkInventory:EVENT_ARKINV_MERCHANT_LEAVE_BUCKET( )
	
	--ArkInventory.Output( "[EVENT_ARKINV_MERCHANT_LEAVE_BUCKET]" )
	
	ArkInventory.Global.Mode.Merchant = false
	
	if ArkInventory.db.option.auto.close.merchant and ArkInventory.LocationIsControlled( ArkInventory.Const.Location.Bag ) then
		ArkInventory.Frame_Main_Hide( ArkInventory.Const.Location.Bag )
	end
	
end

function ArkInventory:EVENT_ARKINV_MERCHANT_LEAVE( event )
	
	--ArkInventory.Output( "[", event, "]" )
	
	ArkInventory:SendMessage( "EVENT_ARKINV_MERCHANT_LEAVE_BUCKET" )
	
end

function ArkInventory:EVENT_ARKINV_BAG_UPDATE_COOLDOWN_BUCKET( argtbl )
	
	--ArkInventory.Output( "[EVENT_ARKINV_BAG_UPDATE_COOLDOWN_BUCKET]", argtbl )
	
	-- excessively triggered by unlreated things, be very careful what you do here or it will cause lag spikes
	
	for loc_id in pairs( argtbl ) do
		
		if loc_id and ArkInventory.Global.Location[loc_id] and not ArkInventory.Global.Location[loc_id].isOffline then
			
			local codex = ArkInventory.GetPlayerCodex( loc_id )
			if codex.style.slot.cooldown.show then
				
				if not ArkInventory.Global.Mode.Combat or codex.style.slot.cooldown.combat then
					
					for bag_id in pairs( ArkInventory.Global.Location[loc_id].Bags ) do
						
						--ArkInventory.Output( loc_id, ".", bag_id )
						
						for slot_id = 1, ArkInventory.Global.Location[loc_id].maxSlot[bag_id] or 0 do
							
							--ArkInventory.Output( loc_id, ".", bag_id, ".", slot_id )
							local framename, frame = ArkInventory.ContainerItemNameGet( loc_id, bag_id, slot_id )	
							ArkInventory.Frame_Item_Update_Cooldown( frame )
							
						end
						
					end
					
				end
				
			end
			
		end
		
	end
	
end

function ArkInventory:EVENT_ARKINV_BAG_UPDATE_COOLDOWN( ... )
	
	-- this thing is triggered constantly from the most trivial crap that has nothing to do with bags or items
	-- unfortunately its the only way to get an item cooldown event start so were stuck with it
	
	local event, arg1, arg2, arg3, arg4 = ...
--	ArkInventory.Output( "[", event, "] [", arg1, "] [", arg2, "] [", arg3, "] [", arg4, "]" )
	
	local loc_id = ArkInventory.Const.Location.Bag
	
	if arg1 then
		loc_id = ArkInventory.BlizzardBagIdToInternalId( arg1 )
	end
	
	ArkInventory:SendMessage( "EVENT_ARKINV_BAG_UPDATE_COOLDOWN_BUCKET", loc_id )
	
end

function ArkInventory:EVENT_ARKINV_BAG_UPDATE_DELAYED( ... )
	
	local event, arg1, arg2, arg3, arg4 = ...
	ArkInventory.Output( "[", event, "] [", arg1, "] [", arg2, "] [", arg3, "] [", arg4, "]" )
	
end

function ArkInventory:EVENT_ARKINV_QUEST_UPDATE_BUCKET( argtbl )
	--ArkInventory.Output( "[EVENT_ARKINV_QUEST_UPDATE_BUCKET]" )
	ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Refresh )
end

function ArkInventory:EVENT_ARKINV_QUEST_UPDATE( ... )
	--local event = ...
	--ArkInventory.Output( "[", event, "]" )
	ArkInventory:SendMessage( "EVENT_ARKINV_QUEST_UPDATE_BUCKET" )
end

function ArkInventory:EVENT_ARKINV_CVAR_UPDATE( ... )
	
	local event, arg1, arg2 = ...
	--ArkInventory.Output( "[", event, "] [", arg1, " = ", arg2, "]" )
	
	if arg1 == "USE_COLORBLIND_MODE" then
		ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Refresh )
		ArkInventory.LDB.Money:Update( )
	end
	
end

function ArkInventory:EVENT_ARKINV_ZONE_CHANGED_BUCKET( argtbl )
	--ArkInventory.Output( "[EVENT_ARKINV_ZONE_CHANGED_BUCKET] [", argtbl, "]" )
end

function ArkInventory:EVENT_ARKINV_ZONE_CHANGED( ... )
	--local event = ...
	--ArkInventory.Output( "[", event, "]" )
	ArkInventory:SendMessage( "EVENT_ARKINV_ZONE_CHANGED_BUCKET", 1 )
end

function ArkInventory:EVENT_ARKINV_BAG_RESCAN_BUCKET( argtbl )
	
	--ArkInventory.Output( "[EVENT_ARKINV_BAG_RESCAN_BUCKET] [", argtbl, "]" )
	
	-- argtbl = table in the format blizzard_id=true so we need to loop through them
	
	for blizzard_id in pairs( argtbl ) do
		local loc_id, bag_id = ArkInventory.BlizzardBagIdToInternalId( blizzard_id )
		ArkInventory.OutputThread( "RESCAN [", blizzard_id, "] [", loc_id, ".", bag_id, "]"  )
		ArkInventory.Scan( blizzard_id )
		--ArkInventory.Frame_Main_Generate( loc_id, ArkInventory.Const.Window.Draw.Recalculate )
	end
	
end

function ArkInventory.InternalIdToBlizzardBagId( loc_id, bag_id )
	
	-- converts internal location+bag codes into blizzard bag ids
	
	assert( loc_id ~= nil, "code failure: loc_id is nil" )
	assert( bag_id ~= nil, "code failure: bag_id is nil" )
	
	local blizzard_id = ArkInventory.Global.Location[loc_id].Bags[bag_id]
	if blizzard_id == nil then
		ArkInventory.OutputError( "code failure: ArkInventory.Global.Location[", loc_id, "].Bags[", bag_id, "] is nil" )
		error( "code failure" )
	end
	
	return blizzard_id
	
end

function ArkInventory.BlizzardBagIdToInternalId( blizzard_id )
	
	-- converts blizzard bag codes into storage location+bag ids
	
	assert( blizzard_id ~= nil, "code failure: blizard_id is nil" )
	
	if ArkInventory.Global.Cache.BlizzardBagIdToInternalId[blizzard_id] then
		return ArkInventory.Global.Cache.BlizzardBagIdToInternalId[blizzard_id].loc_id, ArkInventory.Global.Cache.BlizzardBagIdToInternalId[blizzard_id].bag_id
	else
		ArkInventory.OutputError( "unknown blizzard bag id - ", blizzard_id )
		--error( "code failure" )
	end
	
end

function ArkInventory.BagType( blizzard_id )
	
	assert( blizzard_id ~= nil, "code failure: blizzard_id is nil" )
	
	if blizzard_id == BACKPACK_CONTAINER then
		return ArkInventory.Const.Slot.Type.Bag
	elseif blizzard_id == BANK_CONTAINER then
		return ArkInventory.Const.Slot.Type.Bag
	end
	
	local loc_id, bag_id = ArkInventory.BlizzardBagIdToInternalId( blizzard_id )
	
	if loc_id == nil then
		return ArkInventory.Const.Slot.Type.Unknown
	elseif loc_id == ArkInventory.Const.Location.Mail then
		return ArkInventory.Const.Slot.Type.Mail
	elseif loc_id == ArkInventory.Const.Location.Wearing then
		return ArkInventory.Const.Slot.Type.Wearing
	elseif loc_id == ArkInventory.Const.Location.Auction then
		return ArkInventory.Const.Slot.Type.Auction
	end
	
	
	if ArkInventory.Global.Location[loc_id].isOffline then
		
		local codex = ArkInventory.GetLocationCodex( loc_id )
		return codex.player.data.location[loc_id].bag[bag_id].type
		
	else
		
		local h = GetInventoryItemLink( "player", ContainerIDToInventoryID( blizzard_id ) )
		
		if h and h ~= "" then
			
			local info = ArkInventory.ObjectInfoArray( h )
			local t = info.itemtypeid
			local s = info.itemsubtypeid
			
			--ArkInventory.Output( "bag[", blizzard_id, "], type[", t, "], sub[", s, "], h=", h )
			
			if t == ArkInventory.Const.ItemClass.CONTAINER then
				
				if s == ArkInventory.Const.ItemClass.CONTAINER_BAG then
					return ArkInventory.Const.Slot.Type.Bag
				elseif s == ArkInventory.Const.ItemClass.CONTAINER_ENCHANTING then
					return ArkInventory.Const.Slot.Type.Enchanting
				elseif s == ArkInventory.Const.ItemClass.CONTAINER_ENGINEERING then
					return ArkInventory.Const.Slot.Type.Engineering
				elseif s == ArkInventory.Const.ItemClass.CONTAINER_GEM then
					return ArkInventory.Const.Slot.Type.Gem
				elseif s == ArkInventory.Const.ItemClass.CONTAINER_HERB then
					return ArkInventory.Const.Slot.Type.Herb
				elseif s == ArkInventory.Const.ItemClass.CONTAINER_LEATHERWORKING then
					return ArkInventory.Const.Slot.Type.Leatherworking
				elseif s == ArkInventory.Const.ItemClass.CONTAINER_MINING then
					return ArkInventory.Const.Slot.Type.Mining
				elseif s == ArkInventory.Const.ItemClass.CONTAINER_FISHING then
					return ArkInventory.Const.Slot.Type.Tackle
				elseif s == ArkInventory.Const.ItemClass.CONTAINER_COOKING then
					return ArkInventory.Const.Slot.Type.Cooking
				end
				
			elseif t == ArkInventory.Const.ItemClass.CONTAINER_RANGED then
				
				if s == ArkInventory.Const.ItemClass.CONTAINER_RANGED_QUIVER then
					return ArkInventory.Const.Slot.Type.Arrow
				elseif s == ArkInventory.Const.ItemClass.CONTAINER_RANGED_AMMO then
					return ArkInventory.Const.Slot.Type.Bullet
				end

			end
			
			return ArkInventory.Const.Slot.Type.Unknown
			
		else
			
			-- empty bag slots
			return ArkInventory.Const.Slot.Type.Bag
			
		end
	
	end
	
	ArkInventory.OutputWarning( "Unknown Type: [", ArkInventory.Global.Location[loc_id].Name, "] id[", blizzard_id, "]=[empty]" )
	return ArkInventory.Const.Slot.Type.Unknown
	
end

function ArkInventory.ScanLocation( arg1 )
	
	--ArkInventory.Output( "ScanLocation( ", arg1, " )" )
	
	if not ArkInventory:IsEnabled( ) then return end
	
	for loc_id, loc_data in pairs( ArkInventory.Global.Location ) do
		if arg1 == nil or arg1 == loc_id then
			local bucket = { }
			for bag_id, blizzard_id in pairs( loc_data.Bags ) do
				bucket[blizzard_id] = true
			end
			ArkInventory.Scan( bucket )
		end
	end
	
end

function ArkInventory.Scan( bucket )
	
	local bucket = bucket
	if type( bucket ) ~= "table" then
		bucket = { [bucket] = 1 }
	end
	
	--ArkInventory.Output( "Scan( ", bucket, " )" )
	
	local processed = { }
	
	for blizzard_id in pairs( bucket ) do
		
		--local t1 = GetTime( )
		
		local loc_id, bag_id = ArkInventory.BlizzardBagIdToInternalId( blizzard_id )
		
		if loc_id == nil then
			
			--ArkInventory.OutputWarning( "aborted scan of bag ", blizzard_id, ", not an ", ArkInventory.Const.Program.Name, " controlled bag" )
			
		else
			
			if ArkInventory.ScanStateGetRun( loc_id, bag_id ) or ArkInventory.ScanStateGetQueue( loc_id, bag_id ) then
				
				-- already being scanned, or already queued, so queue for rescan when complete
				
				ArkInventory.ScanStateSetQueue( loc_id, bag_id )
				ArkInventory:EVENT_ARKINV_BAG_UPDATE( "AI_REQUEUE_BUSY", blizzard_id )
				
			else
				
				if loc_id == ArkInventory.Const.Location.Bag or loc_id == ArkInventory.Const.Location.Bank then
					ArkInventory.ScanBag( blizzard_id )
				elseif loc_id == ArkInventory.Const.Location.Wearing then
					if not processed[loc_id] then
						ArkInventory.ScanWearing( )
					end
				elseif loc_id == ArkInventory.Const.Location.Mail then
					if not processed[loc_id] then
						ArkInventory.ScanMailInbox( )
					end
				elseif loc_id == ArkInventory.Const.Location.Auction then
					if not processed[loc_id] then
						ArkInventory.ScanAuction( )
					end
				else
					error( string.format( "code failure: uncoded location [%s] for bag [%s] [%s]", loc_id, bag_id, blizzard_id ) )
				end
				
				--t1 = GetTime( ) - t1
				--ArkInventory.Output( "scan location[" , loc_id, ".", blizzard_id, "] in ", string.format( "%0.3f", t1 ) )
				
				processed[loc_id] = true
				
			end
			
		end
		
	end
	
end

function ArkInventory.ScanStateInit( loc_id, bag_id )
	if not ArkInventory.Global.Location[loc_id].scanning then
		ArkInventory.Global.Location[loc_id].scanning = { r={ }, q={ } }
	end
end

function ArkInventory.ScanStateGetRun( loc_id, bag_id )
	ArkInventory.ScanStateInit( loc_id, bag_id )
	return ArkInventory.Global.Location[loc_id].scanning.r[bag_id]
end

function ArkInventory.ScanStateSetRun( loc_id, bag_id )
	ArkInventory.ScanStateInit( loc_id, bag_id )
	ArkInventory.Global.Location[loc_id].scanning.r[bag_id] = 1
	ArkInventory.Global.Location[loc_id].scanning.q[bag_id] = nil
end

function ArkInventory.ScanStateSetClear( loc_id, bag_id )
	ArkInventory.ScanStateInit( loc_id, bag_id )
	ArkInventory.Global.Location[loc_id].scanning.r[bag_id] = nil
	--local blizzard_id = ArkInventory.InternalIdToBlizzardBagId( loc_id, bag_id )
	--ArkInventory:SendMessage( "EVENT_ARKINV_LOCATION_SCANNED_BUCKET", loc_id )
end

function ArkInventory.ScanStateGetQueue( loc_id, bag_id )
	ArkInventory.ScanStateInit( loc_id, bag_id )
	return ArkInventory.Global.Location[loc_id].scanning.q[bag_id]
end

function ArkInventory.ScanStateSetQueue( loc_id, bag_id )
	ArkInventory.ScanStateInit( loc_id, bag_id )
	ArkInventory.Global.Location[loc_id].scanning.q[bag_id] = 1
end


local function helper_ItemBindingStatus( tooltip )
	
	for _, v in pairs( ArkInventory.Const.Bindings.Account ) do
		if v and ArkInventory.TooltipContains( tooltip, v, false, false, false, true ) then
			return ArkInventory.Const.Bind.Account
		end
	end
	
	for _, v in pairs( ArkInventory.Const.Bindings.Pickup ) do
		if v and ArkInventory.TooltipContains( tooltip, v, false, false, false, true ) then
			return ArkInventory.Const.Bind.Pickup
		end
	end
	
	for _, v in pairs( ArkInventory.Const.Bindings.Equip ) do
		if v and ArkInventory.TooltipContains( tooltip, v, false, false, false, true ) then
			return ArkInventory.Const.Bind.Equip
		end
	end
	
	for _, v in pairs( ArkInventory.Const.Bindings.Use ) do
		if v and ArkInventory.TooltipContains( tooltip, v, false, false, false, true ) then
			return ArkInventory.Const.Bind.Use
		end
	end
	
	return ArkInventory.Const.Bind.Never
	
end

function ArkInventory.ScanBag( blizzard_id )
	
	--ArkInventory.Output( "ScanBag( ", blizzard_id, " ) START" )
	
	local loc_id, bag_id = ArkInventory.BlizzardBagIdToInternalId( blizzard_id )
	
	if not loc_id then
		--ArkInventory.OutputWarning( "aborted scan of bag [", blizzard_id, "], unknown bag id" )
		return
	else
		--ArkInventory.Output( "found bag id [", blizzard_id, "] in location ", loc_id, " [", ArkInventory.Global.Location[loc_id].Name, "]" )
	end
	
	if not ArkInventory.LocationIsMonitored( loc_id ) then
		--ArkInventory.Output( "aborted scan of bag id [", blizzard_id, "], location ", loc_id, " [", ArkInventory.Global.Location[loc_id].Name, "] is not being monitored" )
		return
	end
	
	
	local thread_id = string.format( ArkInventory.Global.Thread.Format.Scan, loc_id, bag_id )
	
	if not ArkInventory.Global.Thread.Use then
		local tz = debugprofilestop( )
		ArkInventory.OutputThread( thread_id, " start" )
		ArkInventory.ScanBag_Threaded( blizzard_id, loc_id, bag_id, thread_id )
		tz = debugprofilestop( ) - tz
		ArkInventory.OutputThread( string.format( "%s took %0.0fms", thread_id, tz ) )
		return
	end
	
	local tf = function( )
		ArkInventory.ScanStateSetRun( loc_id, bag_id )
		ArkInventory.ScanBag_Threaded( blizzard_id, loc_id, bag_id, thread_id )
		ArkInventory.ScanStateSetClear( loc_id, bag_id )
	end
	
	ArkInventory.ThreadStart( thread_id, tf )
	
	--ArkInventory.Output( "ScanBag( ", blizzard_id, " ) END" )
	
end

function ArkInventory.ScanBag_Threaded( blizzard_id, loc_id, bag_id, thread_id )
	
	--ArkInventory.Output( "ScanBag_Threaded( ", blizzard_id, " ) START" )
	
	ArkInventory.ThreadYield_Scan( thread_id )
	
	local player = ArkInventory.GetPlayerStorage( nil, loc_id )
	local count = 0
	local empty = 0
	local texture = nil
	local status = ArkInventory.Const.Bag.Status.Unknown
	local h = nil
	local rarity = LE_ITEM_QUALITY_POOR
	
	if loc_id == ArkInventory.Const.Location.Bag then
		
		count = GetContainerNumSlots( blizzard_id )
		
		if blizzard_id == BACKPACK_CONTAINER then
			
			if not count or count == 0 then
				if ArkInventory.db.option.bugfix.zerosizebag.alert then
					ArkInventory.OutputWarning( "Aborted scan of bag ", blizzard_id, ", location ", loc_id, " [", ArkInventory.Global.Location[loc_id].Name, "] size returned was ", count, ", rescan has been scheduled for 5 seconds.  This warning can be disabled in the config menu" )
				end
				ArkInventory:SendMessage( "EVENT_ARKINV_BAG_RESCAN_BUCKET", blizzard_id )
				return
			end
			
			texture = ArkInventory.Global.Location[loc_id].Texture
			status = ArkInventory.Const.Bag.Status.Active
			
		else
			
			h = GetInventoryItemLink( "player", ContainerIDToInventoryID( blizzard_id ) )
			
			if not h then
				
				texture = ArkInventory.Const.Texture.Empty.Bag
				status = ArkInventory.Const.Bag.Status.Empty
				
			else
				
				if not count or count == 0 then
					if ArkInventory.db.option.bugfix.zerosizebag.alert then
						ArkInventory.OutputWarning( "Aborted scan of bag ", blizzard_id, ", location ", loc_id, " [", ArkInventory.Global.Location[loc_id].Name, "] size returned was ", count, ", rescan has been scheduled for 5 seconds.  This warning can be disabled in the config menu" )
					end
					ArkInventory:SendMessage( "EVENT_ARKINV_BAG_RESCAN_BUCKET", blizzard_id )
					return
				end
				
				status = ArkInventory.Const.Bag.Status.Active
				
				local info = ArkInventory.ObjectInfoArray( h )
				texture = info.texture
				rarity = info.q
				
			end
			
		end
		
	end
	
	if loc_id == ArkInventory.Const.Location.Bank then
		
		count = GetContainerNumSlots( blizzard_id )
		
		if ArkInventory.Global.Mode.Bank == true then
			
			if blizzard_id == BANK_CONTAINER then
				
				if not count or count == 0 then
					if ArkInventory.db.option.bugfix.zerosizebag.alert then
						ArkInventory.OutputWarning( "Aborted scan of bag ", blizzard_id, ", location ", loc_id, " [", ArkInventory.Global.Location[loc_id].Name, "] size returned was ", count, ", rescan has been scheduled for 5 seconds.  This warning can be disabled in the config menu" )
					end
					ArkInventory:SendMessage( "EVENT_ARKINV_BAG_RESCAN_BUCKET", blizzard_id )
					return
				end
				
				texture = ArkInventory.Global.Location[loc_id].Texture
				status = ArkInventory.Const.Bag.Status.Active
				
			else
				
				if blizzard_id - NUM_BAG_SLOTS > GetNumBankSlots( ) then
				
					texture = ArkInventory.Const.Texture.Empty.Bag
					status = ArkInventory.Const.Bag.Status.Purchase
					
				else
					
					h = GetInventoryItemLink( "player", ContainerIDToInventoryID( blizzard_id ) )
					
					if not h then
						
						texture = ArkInventory.Const.Texture.Empty.Bag
						status = ArkInventory.Const.Bag.Status.Empty
						
					else
						
						if not count or count == 0 then
							if ArkInventory.db.option.bugfix.zerosizebag.alert then
								ArkInventory.OutputWarning( "Aborted scan of bag ", blizzard_id, ", location ", loc_id, " [", ArkInventory.Global.Location[loc_id].Name, "] size returned was ", count, ", rescan has been scheduled for 5 seconds.  This warning can be disabled in the config menu" )
							end
							ArkInventory:SendMessage( "EVENT_ARKINV_BAG_RESCAN_BUCKET", blizzard_id )
							return
						end
						
						status = ArkInventory.Const.Bag.Status.Active
						
						local info = ArkInventory.ObjectInfoArray( h )
						texture = info.texture
						rarity = info.q
						
					end
					
				end
	
			end
		
		else
			
			--ArkInventory.OutputWarning( "aborted scan of bag id [", blizzard_id, "], not at bank" )
			return
			
		end
		
	end
	
	local bag = player.data.location[loc_id].bag[bag_id]
	
	bag.loc_id = loc_id
	bag.bag_id = bag_id
	
	local old_bag_type = bag.type
	local old_bag_count = bag.count
	local old_bag_link = bag.h
	local old_bag_status = bag.status
	
	bag.type = ArkInventory.BagType( blizzard_id )
	bag.count = count
	bag.h = h
	bag.status = status
	bag.texture = texture
	bag.empty = empty
	bag.q = rarity
	
	if old_bag_type ~= bag.type or old_bag_count ~= bag.count or ArkInventory.ObjectIDCount( old_bag_link ) ~= ArkInventory.ObjectIDCount( bag.h ) or old_bag_status ~= bag.status then
		--ArkInventory.OutputWarning( "ScanBag_Threaded - .Recalculate" )
		ArkInventory.Frame_Main_DrawStatus( loc_id, ArkInventory.Const.Window.Draw.Recalculate )
	end
	
	for slot_id = 1, bag.count do
		
		if not bag.slot[slot_id] then
			bag.slot[slot_id] = {
				loc_id = loc_id,
				bag_id = bag_id,
				slot_id = slot_id,
			}
		end
		
		local i = bag.slot[slot_id]
		
		local texture, count, locked, rarity, readable, lootable, h, filtered, novalue, itemID = GetContainerItemInfo(  blizzard_id, slot_id )
		local sb = ArkInventory.Const.Bind.Never
		local empty_slot = true
		
		if h then
			
			ArkInventory.TooltipSetItem( ArkInventory.Global.Tooltip.Scan, blizzard_id, slot_id )
			
			if not ArkInventory.TooltipIsReady( ArkInventory.Global.Tooltip.Scan ) then
				--ArkInventory.OutputWarning( "tooltips not ready, queuing bag ", bag_id, " (", blizzard_id, ") for rescan" )
				ArkInventory:SendMessage( "EVENT_ARKINV_BAG_RESCAN_BUCKET", blizzard_id )
			end
			
			sb = helper_ItemBindingStatus( ArkInventory.Global.Tooltip.Scan )
			rarity = ArkInventory.ObjectInfoQuality( h )
			
		else
			
			rarity = LE_ITEM_QUALITY_POOR
			
			count = 1
			bag.empty = bag.empty + 1
			
		end
		
		--local isNewItem = C_NewItems.IsNewItem( blizzard_id, slot_id )
		local changed_item, changed_type = ArkInventory.ScanChanged( i, h, sb, count )
		
		i.h = h
		i.sb = sb
		i.q = rarity
		i.r = ( not not readable ) or nil
		i.count = count
		
		--ArkInventory.Output( loc_id, ".", bag_id, ".", slot_id, " = ", { i } )
		
		if changed_item then
			
			if i.h then
				i.age = ArkInventory.TimeAsMinutes( )
			else
				i.age = nil
			end
			
			--ArkInventory.ItemCategoryGet( i )
			
			ArkInventory.Frame_Item_Update( loc_id, bag_id, slot_id )
			
			ArkInventory:SendMessage( "EVENT_ARKINV_CHANGER_UPDATE_BUCKET", loc_id )
			
		end
		
	end
	
	ArkInventory.ScanCleanup( player, loc_id, bag_id, bag )
	
	if bag.type == ArkInventory.Const.Slot.Type.Unknown and bag.status == ArkInventory.Const.Bag.Status.Active then
		
		if ArkInventory.TranslationsLoaded and ArkInventory.db.option.message.bag.unknown then
			-- print the warning only after the translations are loaded (and the user wants to see them)
			ArkInventory.OutputWarning( "bag [", blizzard_id, "] [", loc_id, ".", bag_id, "] [", ArkInventory.Global.Location[loc_id].Name, "] type is unknown, queuing for rescan" )
		end
		
		ArkInventory:SendMessage( "EVENT_ARKINV_BAG_RESCAN_BUCKET", blizzard_id )
		
	end
	
	--ArkInventory.Output( "ScanBag_Threaded( ", blizzard_id, " ) END" )
	
end

function ArkInventory.ScanWearing( )

	--ArkInventory.Output( GREEN_FONT_COLOR_CODE, "ScanWearing( ) start" )
	
	local blizzard_id = ArkInventory.Const.Offset.Wearing + 1
	local loc_id, bag_id = ArkInventory.BlizzardBagIdToInternalId( blizzard_id )
	
	if not ArkInventory.LocationIsMonitored( loc_id ) then
		--ArkInventory.Output( RED_FONT_COLOR_CODE, "aborted scan of bag id [", blizzard_id, "], location ", loc_id, " [", ArkInventory.Global.Location[loc_id].Name, "] is not being monitored" )
		return
	end

	--ArkInventory.Output( GREEN_FONT_COLOR_CODE, "scaning: ", ArkInventory.Global.Location[loc_id].Name, " [", loc_id, ".", bag_id, "] - [", blizzard_id, "]" )
	
	local player = ArkInventory.GetPlayerStorage( nil, loc_id )
	
	local bag = player.data.location[loc_id].bag[bag_id]
	
	bag.loc_id = loc_id
	bag.bag_id = bag_id
	
	bag.count = 0
	bag.empty = 0
	bag.type = ArkInventory.Const.Slot.Type.Wearing
	bag.status = ArkInventory.Const.Bag.Status.Active
	
	for slot_id, v in ipairs( ArkInventory.Const.InventorySlotName ) do
	
		bag.count = bag.count + 1
		
		if not bag.slot[slot_id] then
			bag.slot[slot_id] = { }
		end
		
		local i = bag.slot[slot_id]
		
		local inv_id = GetInventorySlotInfo( v )
		local h = GetInventoryItemLink( "player", inv_id )
		local sb = ArkInventory.Const.Bind.Never
		local count = 1
		
		if h then
		
			ArkInventory.TooltipSetInventoryItem( ArkInventory.Global.Tooltip.Scan, inv_id )
			
			if not ArkInventory.TooltipIsReady( ArkInventory.Global.Tooltip.Scan ) then
				--ArkInventory.OutputWarning( "tooltips not ready, queuing bag ", bag_id, " (", blizzard_id, ") for rescan" )
				ArkInventory:SendMessage( "EVENT_ARKINV_BAG_RESCAN_BUCKET", blizzard_id )
			end
			
			sb = helper_ItemBindingStatus( ArkInventory.Global.Tooltip.Scan )
			
		else
		
			bag.empty = bag.empty + 1
			
		end

		
		local changed_item = ArkInventory.ScanChanged( i, h, sb, count )
		
		i.loc_id = loc_id
		i.bag_id = bag_id
		i.slot_id = slot_id
			
		i.h = h
		i.count = count
		i.sb = sb
		i.q = ArkInventory.ObjectInfoQuality( h )
		
		if changed_item then
		
			if i.h then
				i.age = ArkInventory.TimeAsMinutes( )
			else
				i.age = nil
			end
		
			ArkInventory.Frame_Item_Update( loc_id, bag_id, slot_id )
			
			ArkInventory:SendMessage( "EVENT_ARKINV_CHANGER_UPDATE_BUCKET", loc_id )
			
		end
		
	end
	
	ArkInventory.ScanCleanup( player, loc_id, bag_id, bag )
	
end

function ArkInventory.ScanMailInbox( )
	
	-- mailbox can be scanned from anywhere, just uses data from when it was last opened but dont bother unless its actually open
	if ArkInventory.Global.Mode.Mail == false then
		--ArkInventory.Output( RED_FONT_COLOR_CODE, "aborted scan of mailbox, not at mailbox" )
		return
	end
	
	local blizzard_id = ArkInventory.Const.Offset.Mail + 1
	local loc_id, bag_id = ArkInventory.BlizzardBagIdToInternalId( blizzard_id )
	
	if not ArkInventory.LocationIsMonitored( loc_id ) then
		--ArkInventory.Output( RED_FONT_COLOR_CODE, "aborted scan of bag id [", blizzard_id, "], location ", loc_id, " [", ArkInventory.Global.Location[loc_id].Name, "] is not being monitored" )
		return
	end
	
	local thread_id = string.format( ArkInventory.Global.Thread.Format.Scan, loc_id, bag_id )
	
	if not ArkInventory.Global.Thread.Use then
		local tz = debugprofilestop( )
		ArkInventory.OutputThread( thread_id, " start" )
		ArkInventory.ScanMailInbox_Threaded( blizzard_id, loc_id, bag_id, thread_id )
		tz = debugprofilestop( ) - tz
		ArkInventory.OutputThread( string.format( "%s took %0.0fms", thread_id, tz ) )
		return
	end
	
	local tf = function( )
		ArkInventory.ScanStateSetRun( loc_id, bag_id )
		ArkInventory.ScanMailInbox_Threaded( blizzard_id, loc_id, bag_id, thread_id )
		ArkInventory.ScanStateSetClear( loc_id, bag_id )
	end
	
	ArkInventory.ThreadStart( thread_id, tf )
	
end

function ArkInventory.ScanMailInbox_Threaded( blizzard_id, loc_id, bag_id, thread_id )
	
	ArkInventory.ThreadYield_Scan( thread_id )
	
	--ArkInventory.Output( GREEN_FONT_COLOR_CODE, "scaning: ", ArkInventory.Global.Location[loc_id].Name, " [", loc_id, ".", bag_id, "] - [", blizzard_id, "]" )
	
	local player = ArkInventory.GetPlayerStorage( nil, loc_id )
	
	local bag = player.data.location[loc_id].bag[bag_id]
	
	bag.loc_id = loc_id
	bag.bag_id = bag_id
	
	bag.count = 0
	bag.empty = 0
	bag.type = ArkInventory.Const.Slot.Type.Mail
	bag.status = ArkInventory.Const.Bag.Status.Active
	
	local slot_id = 0
	
	for index = 1, GetInboxNumItems( ) do
	
		--ArkInventory.Output( "scanning message ", index )
		
		--ArkInventory.Output( { GetInboxHeaderInfo( index ) } )
		local packageTexture, stationaryTexture, sender, subject, money, CoD, daysLeft, itemCount, wasRead, wasReturned, saved, canReply, GM = GetInboxHeaderInfo( index )
		
		if money > 0 then
			
			slot_id = slot_id + 1
			
			if not bag.slot[slot_id] then
				bag.slot[slot_id] = {
					loc_id = loc_id,
					bag_id = bag_id,
					slot_id = slot_id,
				}
			end
			
			local i = bag.slot[slot_id]
			
			local h = string.format( "copper:0:%s", money )
			local sb = ArkInventory.Const.Bind.Never
			local count = money
			
			bag.count = bag.count + 1
			
			local changed_item = ArkInventory.ScanChanged( i, h, sb, count )
			
			i.h = h
			i.sb = sb
			i.count = 0
			i.q = 0
			
			i.msg_id = index
			i.att_id = nil
			i.money = count
			i.texture = GetCoinIcon( count )
			
			if changed_item then
				
				if i.h then
					i.age = ArkInventory.TimeAsMinutes( )
				else
					i.age = nil
				end
				
				ArkInventory.Frame_Item_Update( loc_id, bag_id, slot_id )
				
				ArkInventory:SendMessage( "EVENT_ARKINV_CHANGER_UPDATE_BUCKET", loc_id )
				
			end
			
		end
		
		if itemCount then
		
			--if ( daysLeft >= 1 ) then
--			daysLeft = string.format( "%s%s%s%s", GREEN_FONT_COLOR_CODE, string.format( DAYS_ABBR, floor(daysLeft) ), " ", FONT_COLOR_CODE_CLOSE )
			--else
--			daysLeft = string.format( "%s%s%s", RED_FONT_COLOR_CODE, SecondsToTime( floor( daysLeft * 24 * 60 * 60 ) ), FONT_COLOR_CODE_CLOSE )
			--end
		
			--local expires_d = floor( daysLeft )
			--local expires_s = ( daysLeft - floor( daysLeft ) ) * 24 * 60* 60
			--local purge = not not ( wasReturned ) or ( not canReply )
		
			--ArkInventory.Output( "message ", index, " has item(s)" )
			
			for x = 1, ATTACHMENTS_MAX_RECEIVE do
				
				local name, itemid, texture, count = GetInboxItem( index, x )
				
				if name then
					
					--ArkInventory.Output( "message ", index, ", attachment ", x, " = ", name, " x ", count, " / (", { GetInboxItemLink( index, x ) }, ")" )
					
					slot_id = slot_id + 1
					
					if not bag.slot[slot_id] then
						bag.slot[slot_id] = {
							loc_id = loc_id,
							bag_id = bag_id,
							slot_id = slot_id,
						}
					end
					
					local i = bag.slot[slot_id]
					
					local h = GetInboxItemLink( index, x )
					local hasCooldown, speciesID, level, breedQuality, maxHealth, power, speed, name = ArkInventory.TooltipSetGuildMailboxItem( ArkInventory.Global.Tooltip.Scan, index, x )
					
					local sb = helper_ItemBindingStatus( ArkInventory.Global.Tooltip.Scan )
					
					if h then
						bag.count = bag.count + 1
					end
					
					local changed_item = ArkInventory.ScanChanged( i, h, sb, count )
					
					i.h = h
					i.sb = sb
					i.count = count
					i.q = ArkInventory.ObjectInfoQuality( h )
					
					i.msg_id = index
					i.att_id = x
					i.money = nil
					i.texture = nil
					
					if changed_item then
						
						if i.h then
							i.age = ArkInventory.TimeAsMinutes( )
						else
							i.age = nil
						end
						
						ArkInventory.Frame_Item_Update( loc_id, bag_id, slot_id )
						
						ArkInventory:SendMessage( "EVENT_ARKINV_CHANGER_UPDATE_BUCKET", loc_id )
						
					end
					
				end
				
			end
		
		end
		
	end
	
	if slot_id == 0 then
		
		for k = 1, 1 do
			
			slot_id = slot_id + 1
			bag.count = bag.count + 1
			
			if not bag.slot[slot_id] then
				bag.slot[slot_id] = {
					loc_id = loc_id,
					bag_id = bag_id,
					slot_id = slot_id,
				}
			end
			
			local i = bag.slot[slot_id]
			
			local h = nil
			local sb = ArkInventory.Const.Bind.Never
			local count = nil
			
			bag.empty = bag.empty + 1
			
			local changed_item = ArkInventory.ScanChanged( i, h, sb, count )
			
			i.h = h
			i.sb = sb
			i.age = nil
			i.count = count
			i.texture = nil
			i.q = 0
			
			if changed_item then
				
				ArkInventory.Frame_Item_Update( loc_id, bag_id, slot_id )
				
				ArkInventory:SendMessage( "EVENT_ARKINV_CHANGER_UPDATE_BUCKET", loc_id )
				
			end
			
		end
		
	end
	
	ArkInventory.ScanCleanup( player, loc_id, bag_id, bag )
	
	
	-- clear cached mail sent from other known characters
	blizzard_id = ArkInventory.Const.Offset.Mail + 2
	loc_id, bag_id = ArkInventory.BlizzardBagIdToInternalId( blizzard_id )
	
	bag = player.data.location[loc_id].bag[bag_id]
	
	bag.loc_id = loc_id
	bag.bag_id = bag_id
	
	bag.count = 0
	bag.empty = 0
	bag.type = ArkInventory.Const.Slot.Type.Mail
	bag.status = ArkInventory.Const.Bag.Status.Active
	
	ArkInventory.ScanCleanup( player, loc_id, bag_id, bag )
	
end

function ArkInventory.ScanMailSentData( )
	
	local blizzard_id = ArkInventory.Const.Offset.Mail + 2
	local loc_id, bag_id = ArkInventory.BlizzardBagIdToInternalId( blizzard_id )
	
	--ArkInventory.Output( GREEN_FONT_COLOR_CODE, "scaning: ", ArkInventory.Global.Location[loc_id].Name, " [", loc_id, ".", bag_id, "] - [", blizzard_id, "]" )
	
	local player = ArkInventory.GetPlayerStorage( ArkInventory.Global.Cache.SentMail.to, loc_id )
	if not player.data.info.player_id then
		return
	end
	
	local bag = player.data.location[loc_id].bag[bag_id]
	
	bag.loc_id = loc_id
	bag.bag_id = bag_id
	
	bag.empty = 0
	bag.type = ArkInventory.Const.Slot.Type.Mail
	bag.status = ArkInventory.Const.Bag.Status.Active
	
	local slot_id = bag.count
	
	for x = 1, ATTACHMENTS_MAX do
		
		if ArkInventory.Global.Cache.SentMail[x] then
		
			slot_id = slot_id + 1
			bag.count = slot_id
			
			if not bag.slot[slot_id] then
				bag.slot[slot_id] = {
					loc_id = loc_id,
					bag_id = bag_id,
					slot_id = slot_id,
				}
			end
			
			local i = bag.slot[slot_id]
			
			local h = ArkInventory.Global.Cache.SentMail[x].h
			local sb = ArkInventory.Const.Bind.Never
			local count = ArkInventory.Global.Cache.SentMail[x].c
			
			local changed_item = ArkInventory.ScanChanged( i, h, sb, count )
			
			i.h = h
			i.sb = sb
			i.age = ArkInventory.Global.Cache.SentMail[x].age
			i.count = count
			i.q = ArkInventory.ObjectInfoQuality( h )
			i.sdr = ArkInventory.Global.Cache.SentMail[x].from
				
			if changed_item then
				
				ArkInventory.Frame_Item_Update( loc_id, bag_id, slot_id )
				
				ArkInventory:SendMessage( "EVENT_ARKINV_CHANGER_UPDATE_BUCKET", loc_id )
				
			end
			
		end
		
	end
	
	ArkInventory.ScanCleanup( player, loc_id, bag_id, bag )
	
end


function ArkInventory.ScanAuction( massive )
	
	if ArkInventory.Global.Mode.Auction == false then
		--ArkInventory.Output( RED_FONT_COLOR_CODE, "aborted scan of auction house, not at auction house" )
		return
	end
	
	local blizzard_id = ArkInventory.Const.Offset.Auction + 1
	local loc_id, bag_id = ArkInventory.BlizzardBagIdToInternalId( blizzard_id )
	
	if not ArkInventory.LocationIsMonitored( loc_id ) then
		--ArkInventory.Output( RED_FONT_COLOR_CODE, "aborted scan of bag id [", blizzard_id, "], location ", loc_id, " [", ArkInventory.Global.Location[loc_id].Name, "] is not being monitored" )
		return
	end
	
	local thread_id = string.format( ArkInventory.Global.Thread.Format.Scan, loc_id, bag_id )
	
	if not ArkInventory.Global.Thread.Use then
		local tz = debugprofilestop( )
		ArkInventory.OutputThread( thread_id, " start" )
		ArkInventory.ScanAuction_Threaded( blizzard_id, loc_id, bag_id, thread_id, massive )
		tz = debugprofilestop( ) - tz
		ArkInventory.OutputThread( string.format( "%s took %0.0fms", thread_id, tz ) )
		return
	end
	
	local tf = function( )
		ArkInventory.ScanStateSetRun( loc_id, bag_id )
		ArkInventory.ScanAuction_Threaded( blizzard_id, loc_id, bag_id, thread_id, massive )
		ArkInventory.ScanStateSetClear( loc_id, bag_id )
	end
	
	ArkInventory.ThreadStart( thread_id, tf )
	
end

function ArkInventory.ScanAuction_Threaded( blizzard_id, loc_id, bag_id, thread_id, massive )
	
	ArkInventory.ThreadYield_Scan( thread_id )
	
	--ArkInventory.Output( GREEN_FONT_COLOR_CODE, "scaning: ", ArkInventory.Global.Location[loc_id].Name, " [", loc_id, ".", bag_id, "] - [", blizzard_id, "]" )
	
	local player = ArkInventory.GetPlayerStorage( nil, loc_id )
	
	local bag = player.data.location[loc_id].bag[bag_id]
	
	bag.loc_id = loc_id
	bag.bag_id = bag_id
	
	local auctions = select( 2, GetNumAuctionItems( "owner" ) )
	
	if auctions > 100 and not massive then
		ArkInventory:SendMessage( "EVENT_ARKINV_AUCTION_UPDATE_MASSIVE_BUCKET" )
		return
	end
	
	bag.count = auctions
	bag.empty = 0
	bag.type = ArkInventory.Const.Slot.Type.Auction
	bag.status = ArkInventory.Const.Bag.Status.Active
	
	for slot_id = 1, bag.count do
		
		if not bag.slot[slot_id] then
			bag.slot[slot_id] = {
				loc_id = loc_id,
				bag_id = bag_id,
				slot_id = slot_id,
			}
		end
		
		local i = bag.slot[slot_id]
		
		--ArkInventory.Output( "scanning auction ", slot_id, " of ", bag.count )
		
		local h = GetAuctionItemLink( "owner", slot_id )
		local name, texture, count, rarity, canUse, level, minBid, minIncrement, buyoutPrice, bidAmount, highestBidder, owner, sold = GetAuctionItemInfo( "owner", slot_id )
		local duration = GetAuctionItemTimeLeft( "owner", slot_id )
		local sb = ArkInventory.Const.Bind.Never
		
		--ArkInventory.Output( "auction ", slot_id, " / ", h, " / ", sold )
		
		if not h or sold == 1 then
			count = 1
			bag.empty = bag.empty + 1
			h = nil
			duration = nil
		end
		
		--ArkInventory.Output( "auction ", slot_id, " = ", h, " x ", count )
		
		local changed_item = ArkInventory.ScanChanged( i, h, sb, count )
		
		i.h = h
		i.count = count
		i.sb = sb
		i.q = ArkInventory.ObjectInfoQuality( h )
		
		if changed_item then
			
			if i.h then
				i.age = ArkInventory.TimeAsMinutes( )
			else
				i.age = nil
			end

			if duration == 1 then
				-- Short (less than 30 minutes)
				i.expires = ( i.age or 0 ) + 30
			elseif duration == 2 then
				-- Medium (30 minutes to 2 hours)
				i.expires = ( i.age or 0 ) + 2 * 60
			elseif duration == 3 then
				-- Long (2 hours to 12 hours)
				i.expires = ( i.age or 0 ) + 12 * 60
			elseif duration == 4 then
				-- Very Long (more than 12 hours)
				i.expires = ( i.age or 0 ) + 48 * 60
			end
			
			ArkInventory.Frame_Item_Update( loc_id, bag_id, slot_id )
			
			ArkInventory:SendMessage( "EVENT_ARKINV_CHANGER_UPDATE_BUCKET", loc_id )
			
		end
		
	end
	
	ArkInventory.ScanCleanup( player, loc_id, bag_id, bag )
	
end

function ArkInventory.ScanAuctionExpire( )
	
	local blizzard_id = ArkInventory.Const.Offset.Auction + 1
	local loc_id, bag_id = ArkInventory.BlizzardBagIdToInternalId( blizzard_id )
	
	local current_time = ArkInventory.TimeAsMinutes( )
	
	local player = ArkInventory.GetPlayerStorage( nil, loc_id )
	
	local bag = player.data.location[loc_id].bag[bag_id]
	
	
	bag.loc_id = loc_id
	bag.bag_id = bag_id
	
	local search_id
	
	for slot_id = 1, bag.count do
		
		local i = bag.slot[slot_id]
		
		if i.h then
			
			if ( i.expires and ( i.expires < current_time ) ) or ( i.age and ( i.age + 48 * 60 < current_time ) ) then
				
				search_id = ArkInventory.ObjectIDCount( i.h )
				ArkInventory.ObjectCacheCountClear( search_id )
				
				table.wipe( i )
				
				i.loc_id = loc_id
				i.bag_id = bag_id
				i.slot_id = slot_id
				
				i.count = 1
				bag.empty = bag.empty + 1
				
			end
			
		end
		
	end
	
	--ArkInventory.OutputWarning( "ScanAuctionExpire - .Recalculate" )
	ArkInventory.Frame_Main_DrawStatus( loc_id, ArkInventory.Const.Window.Draw.Recalculate )
	
end

function ArkInventory.ScanProfessions( )
	
	--ArkInventory.Output( "ScanProfessions" )
	
	local p = { GetProfessions( ) }
	--ArkInventory.Output( "skills = [", p, "]" )
	
	local info = ArkInventory.GetPlayerInfo( )
	info.skills = info.skills or { }
	
	for index = 1, ArkInventory.Const.Skills.Primary + ArkInventory.Const.Skills.Secondary do
		
		if p[index] then
			--local name, texture, rank, maxRank, numSpells, spelloffset, skillLine, rankModifier = GetProfessionInfo( p[index] )
			--ArkInventory.Output( "skill [", index, "] = [", skillLine, "] [", name, "]" )
			local skillLine = select( 7, GetProfessionInfo( p[index] ) )
			info.skills[index] = skillLine
		else
			info.skills[index] = nil
			--ArkInventory.Output( "skill [", index, "] = [", skillLine, "] [", name, "]" )
		end
		
	end
	
	ArkInventory.Table.Clean( ArkInventory.db.cache.default )
	
	--ArkInventory.Frame_Main_DrawStatus( nil, ArkInventory.Const.Window.Draw.Resort )
	
end


function ArkInventory.ScanChanged( old, h, sb, count )
	
	--ArkInventory.Output( "scanchanged: ", old.loc_id, ".", old.bag_id, ".", old.slot_id, " - ", h, " ", count )
	
	-- check for slot changes
	
	-- return item has changed, new status
	
	-- item counts are now reset here if required
	
	-- do not use the full hyperlink, pull out the itemstring part and check against that, theres a bug where the name isnt always included in the hyperlink
	
	if not h then
		
		-- slot is empty
		
		if old.h then
			
			-- previous item was removed
			ArkInventory.ScanCleanupCountAdd( old.h, old.loc_id )
			
			--ArkInventory.Output( "scanchanged: ", old.loc_id, ".", old.bag_id, ".", old.slot_id, " - ", old.h, " - item removed" )
			return true, ArkInventory.Const.Slot.New.No
			
		end
		
	else
		
		-- slot has an item
		
		if not old.h then
			
			-- item added to previously empty slot
			ArkInventory.ScanCleanupCountAdd( h, old.loc_id )
			
			--ArkInventory.Output( "scanchanged: ", old.loc_id, ".", old.bag_id, ".", old.slot_id, " - ", h, " - item added" )
			return true, ArkInventory.Const.Slot.New.Yes
			
		end
		
		if ArkInventory.ObjectInfoItemString( h ) ~= ArkInventory.ObjectInfoItemString( old.h ) then
			
			-- different item
			ArkInventory.ScanCleanupCountAdd( old.h, old.loc_id )
			ArkInventory.ScanCleanupCountAdd( h, old.loc_id )
			
			--ArkInventory.Output( "scanchanged: ", old.loc_id, ".", old.bag_id, ".", old.slot_id, " - ", old.h, " / ", h, " - item changed" )
			return true, ArkInventory.Const.Slot.New.Yes
			
		end
		
		if sb ~= old.sb then
			
			-- soulbound changed
			--ArkInventory.Output( "scanchanged: ", old.loc_id, ".", old.bag_id, ".", old.slot_id, " - ", old.h, " - soulbound was ", old.sb, " now ", sb )
			return true, ArkInventory.Const.Slot.New.Yes
			
		end
		
		if count and old.count and count ~= old.count then
			
			-- same item, previously existed, count has changed
			ArkInventory.ScanCleanupCountAdd( old.h, old.loc_id )
			
			if count > old.count then
				--ArkInventory.Output( "scanchanged: ", old.loc_id, ".", old.bag_id, ".", old.slot_id, " - ", old.h, " - count increased" )
				return true, ArkInventory.Const.Slot.New.Inc
			else
				--ArkInventory.Output( "scanchanged: ", old.loc_id, ".", old.bag_id, ".", old.slot_id, " - ", old.h, " - count decreased" )
				return true, ArkInventory.Const.Slot.New.Dec
			end
			
		end
		
	end

end

function ArkInventory.ScanCleanupCountAdd( h, loc_id )
	
	if not h or not loc_id then return end
	
	local cid = ArkInventory.ObjectIDCount( h )
	if not ArkInventoryScanCleanupList[cid] then
		ArkInventoryScanCleanupList[cid] = { }
	end
	
	ArkInventoryScanCleanupList[cid][loc_id] = true
	
end

function ArkInventory.ScanCleanup( player, loc_id, bag_id, bag, thread_id )
	
	local num_slots = #bag.slot
	--ArkInventory.Output( "cleanup: loc=", loc_id, ", bag=", bag_id, ", count=", num_slots, " / ", bag.count )
	
	-- remove unwanted slots
	if num_slots > bag.count then
		for slot_id = bag.count + 1, num_slots do
			
			if bag.slot[slot_id] and bag.slot[slot_id].h then
				ArkInventory.ScanCleanupCountAdd( bag.slot[slot_id].h, loc_id )
			end
			
			--ArkInventory.Output( "wiped bag ", bag_id, " slot ", slot_id )
			table.wipe( bag.slot[slot_id] )
			bag.slot[slot_id] = nil
			
		end
	end
	
	-- recalculate total slots
	player.data.location[loc_id].slot_count = ArkInventory.Table.Sum( player.data.location[loc_id].bag, function( a ) return a.count end )
	
	ArkInventory:SendMessage( "EVENT_ARKINV_LOCATION_SCANNED_BUCKET", loc_id )
	
end


function ArkInventory.ObjectInfoName( h )
	local info = ArkInventory.ObjectInfoArray( h )
	return info.name or "!"
end

function ArkInventory.ObjectInfoTexture( h )
	local info = ArkInventory.ObjectInfoArray( h )
	return info.texture
end

function ArkInventory.ObjectInfoQuality( h )
	local info = ArkInventory.ObjectInfoArray( h )
	return info.q or 1
end

function ArkInventory.ObjectInfoVendorPrice( h )
	local info = ArkInventory.ObjectInfoArray( h )
	return info.vendorprice or -1
end

function ArkInventory.ObjectInfoArray( h, i )
	
	local info = { }
	info.osd = ArkInventory.ObjectStringDecode( h, i )
	info.class = info.osd.class
	info.id = info.osd.id
	
	info.h = info.osd.h
	info.name = ""
	info.q = 1
	info.ilvl = -2
	info.uselevel = -2
	info.itemtype = ArkInventory.Localise["UNKNOWN"]
	info.itemsubtype = ArkInventory.Localise["UNKNOWN"]
	info.stacksize = 1
	info.equiploc = ""
	info.texture = ArkInventory.Const.Texture.Missing
	info.vendorprice = -1
	info.itemtypeid = -2
	info.itemsubtypeid = -2
	
	info.slottype = ArkInventory.Const.Slot.Type.Unknown
	if i then
		local blizzard_id = ArkInventory.InternalIdToBlizzardBagId( i.loc_id, i.bag_id )
		info.slottype = ArkInventory.BagType( blizzard_id )
	end
	
	if info.class == "item" then
		
		info.info = { GetItemInfo( info.osd.h ) }
		
--[[
		[01] = itemName
		[02] = itemLink
		[03] = itemRarity
		[04] = itemLevel
		[05] = itemMinLevel
		[06] = itemType
		[07] = itemSubType
		[08] = itemStackCount
		[09] = itemEquipLoc
		[10] = itemTexture
		[11] = sellPrice
		[12] = itemTypeId
		[13] = itemSubTypeId
		[14] = bindType (base binding, not actual)
			[00] = none
			[01] = on pickup
			[02] = on equip
			[03] = on use
			[04] = quest
		[15] = expansionId (254 for classic client)
		[16] = itemSetId
		[17] = isCraftingReagent
]]--
		
		-- broken in 7.1 for artifacts
		-- info.h = info.info[2] or info.h
		
		info.name = info.info[1] or info.name
		if not info.name or info.name == "" then
			info.name = string.match( info.info[2] or h, "%[(.+)%]" ) or ""
		end
		
		info.q = info.info[3] or info.q
		
		info.ilvl = info.info[4] or info.ilvl
		
--		if info.id == 128872 then
--			ArkInventory.Output( "[ ", string.gsub( string.gsub( info.info[2], "\124", " " ), ":", " : " ), " ]" )
--			ArkInventory.Output( "[ ", string.gsub( string.gsub( info.osd.h, "\124", " " ), ":", " : " ), " ]" )
--			ArkInventory.Output( "[ ", string.gsub( string.gsub( info.h, "\124", " " ), ":", " : " ), " ]" )
--		end
		
		info.uselevel = info.info[5] or info.uselevel
		info.itemtype = info.info[6] or info.itemtype
		info.itemsubtype = info.info[7] or info.itemsubtype
		info.stacksize = info.info[8] or info.stacksize
		info.equiploc = info.info[9] or info.equiploc
		
		if not info.info[10] or info.info[10] == "" then
			info.texture = GetItemIcon( h ) or info.texture
		else
			info.texture = info.info[10]
		end
		
		info.vendorprice = info.info[11] or info.vendorprice
		info.itemtypeid = info.info[12] or info.itemtypeid
		info.itemsubtypeid = info.info[13] or info.itemsubtypeid
		
		info.craft = info.info[17] or info.craft
		
		if info.osd.upgradeid > 0 or info.osd.bonusids then
			
			-- upgradable or has bonusId that may not adjust the itemlevel return value (eg 615/timewarped), so get item level from tooltip
			
			--ArkInventory.TooltipSetHyperlink( ArkInventory.Global.Tooltip.Scan, info.h )
			ArkInventory.TooltipSetHyperlink( ArkInventory.Global.Tooltip.Scan, info.h )
			local _, _, ilvl = ArkInventory.TooltipFind( ArkInventory.Global.Tooltip.Scan, ArkInventory.Localise["WOW_TOOLTIP_ITEM_LEVEL"], false, true, true, 4, true )
			
			info.ilvl = tonumber( ilvl ) or info.ilvl
			
--			if info.ilvl ~= info.info[4] then
--				ArkInventory.Output( h, " [", info.info[4], "] [", ilvl, "] [", info.osd.upgradeid, "] ", info.osd.bonusids )
--			end
			
		end
		
		if info.itemsubtypeid == ArkInventory.Const.ItemClass.GEM_ARTIFACT_RELIC then
			
			local _, _, ilvl = ArkInventory.TooltipFind( ArkInventory.Global.Tooltip.Scan, ArkInventory.Localise["WOW_TOOLTIP_RELIC_LEVEL"], false, true, true, 0, true )
			
			info.ilvl = tonumber( ilvl ) or info.ilvl
			
		end
		
	elseif info.class == "keystone" then

--[[
h = "|cffa335ee|Hkeystone:138019:234:2:0:0:0:0|h[Keystone: Return to Karazhan: Upper (2)]|h|r"
h = "|cffa335ee|Hkeystone:138019:227:2:0:0:0:0|h[Keystone: Return to Karazhan: Lower (2)]|h|r"
h = "|cffa335ee|Hkeystone:138019:200:2:0:0:0:0|h[Keystone: Halls of Valor (2)]|h|r"
h = "|cffa335ee|Hkeystone:138019:199:2:0:0:0:0|h[Keystone: Black Rook Hold (2)]|h|r"
h = "|cffa335ee|Hkeystone:138019:207:2:0:0:0:0|h[Keystone: Vault of the Wardens (2)]|h|r"
h = "|cffa335ee|Hkeystone:138019:239:2:0:0:0:0|h[Keystone: Seat of the Triumvirate (2)]|h|r"
h = "|cffa335ee|Hkeystone:138019:210:2:0:0:0:0|h[Keystone: Court of Stars (2)]|h|r"
h = "|cffa335ee|Hkeystone:138019:233:2:0:0:0:0|h[Keystone: Cathedral of Eternal Night (2)]|h|r"
h = "|cffa335ee|Hkeystone:138019:198:2:0:0:0:0|h[Keystone: Darkheart Thicket (2)]|h|r"
]]--

		--ArkInventory.Output( string.gsub( h, "\124", "*" ) )
		
		info.info = { GetItemInfo( info.osd.id ) }
		
		info.name = info.osd.name or info.info[1] or info.name
		if not info.name or info.name == "" then
			info.name = string.match( info.h, "|h%[(.+)%]|h" ) or info.name
		end
		
		info.q = info.info[3] or info.q
		
		info.ilvl = info.osd.level or info.ilvl
		
		info.itemtype = info.info[6] or info.itemtype
		info.itemsubtype = info.info[7] or info.itemsubtype
		
		if not info.info[10] or info.info[10] == "" then
			info.texture = GetItemIcon( h ) or info.texture
		else
			info.texture = info.info[10]
		end
		
		info.itemtypeid = info.info[12] or info.itemtypeid
		info.itemsubtypeid = info.info[13] or info.itemsubtypeid
		
	elseif info.class == "spell" then
		
		info.info = { GetSpellInfo( info.id ) }
		
		info.h = GetSpellLink( info.id )
		
		info.name = info.info[1]
		if not info.name or info.name == "" then
			info.name = string.match( info.h, "|h%[(.+)%]|h" ) or info.name
		end
		
		info.q = 1
		info.texture = info.info[3] or info.texture
		
	elseif info.class == "empty" then
		
		info.texture = ""
		info.itemtypeid = ArkInventory.Const.ItemClass.EMPTY
		info.itemsubtypeid = info.slottype
		
	end
	
--	if not info.name or info.name == "" then
--		info.name = string.format( "%s - %s - %s", ArkInventory.Localise["UNKNOWN"], info.class, info.id )
--	end
	
	return info
	
end

function ArkInventory.ObjectInfoItemString( h )
	local osd = ArkInventory.ObjectStringDecode( h )
	return osd.h
end


local cacheObjectStringDecode = { }
function ArkInventory.ObjectStringDecode( h, i )
	
	-- avg 0.000190 / 0.000150
	local hr = string.trim( h or "" )
	
	if cacheObjectStringDecode[hr] then
		-- first cache check based on raw hyperlink
		return cacheObjectStringDecode[hr]
	end
	
	--ArkInventory.Output( "uncached hr = [", string.gsub( hr, "\124", "*" ), "]" )
	
	if hr == "" and i then
		--ArkInventory.Output( "osd empty = [", hr, "] [", i, "]" )
		-- get hyperlink from i
		if i.h then
			hr = i.h
		else
			--ArkInventory.ObjectIDCategory( i )
			local blizzard_id = ArkInventory.InternalIdToBlizzardBagId( i.loc_id, i.bag_id )
			local bt = ArkInventory.BagType( blizzard_id )
			hr = string.format( "empty:0:%s", bt )
		end
	end
	
	local hc = string.match( hr, "|H(.-)|h" ) or string.match( hr, "^([a-z]-:.+)" ) or "empty:0:0"
	
	if cacheObjectStringDecode[hc] then
		-- second cache check based on cleaned hyperlink
		return cacheObjectStringDecode[hc]
	end
	
	--ArkInventory.Output( "uncached hc = [", hc, "]" )
	
	local osd = { strsplit( ":", hc ) }
	cacheObjectStringDecode[hc] = osd
	--ArkInventory.Output( "caching hc = [", hc, "]" )
	
	if hr ~= "" then
		--ArkInventory.Output( "caching hr = [", string.gsub( hr, "\124", "*" ), "]" )
		cacheObjectStringDecode[hr] = osd
	end
	
	local c = #osd
	if c < 15 then
		c = 15
	end
	
	for x = 2, c do
		if not osd[x] or osd[x] == "" then
			osd[x] = 0
		else
			osd[x] = tonumber( osd[x] ) or osd[x]
			--ArkInventory.Output( x, " = [", osd[x], "]" )
		end
	end
	
	osd.name = string.match( hr, "|h%[(.-)]|h" ) or ""
	osd.h = hc
	osd.class = osd[1]
	osd.id = osd[2]
	
	osd.keyIDCount = string.format( "%s:%s", osd.class, osd.id )
	
	
	if osd.class == "item" then
		
		--[[
			[01]class
			[02]item
			[03]enchantid
			[04]gem1
			[05]gem2
			[06]gem3
			[07]gem4
			[08]suffixid
			[09]uniqueid
			[10]linklevel
			[11]specid
			[12]upgradetypeid
				4 = pandaria x/4
				512 = timewarped
			[13]sourceid
			[14]numbonusids
			[..]bonusids
			[15]upgradevalue
			
			relic weapons
			[16]numrelicids1
			[..]relicids1
			[17]numrelicids2
			[..]relicids2
			[18]numrelicids3
			[..]relicids3
			
		]]--
		
		osd.enchantid = osd[3]
		osd.gemid = { osd[4], osd[5], osd[6], osd[7] }
		
		osd.suffixid = osd[8]
		if osd[8] < 0 then
			osd.suffixfactor = bit.band( osd[9], 65535 )
		end
		
		osd.uniqueid = osd[9]
		
		osd.linklevel = osd[10]
		osd[10] = 0 -- pointless for a unique h2
		
		osd.specid = osd[11]
		osd[11] = 0 -- must be zero'd or there will be a different h2 depending on which spec you were in at the time
		
		osd.upgradeid = osd[12]
		
		osd.sourceid = osd[13]
		osd[13] = 0 -- pointless for a unique h2
		
		local pos = 14
		
		-- bonus id set
		if osd[pos] and osd[pos] > 0 then
			osd.bonusids = { }
			for x = pos + 1, pos + osd[pos] do
				osd.bonusids[osd[x]] = true
			end
		end
		pos = pos + 1 + osd[pos]
		
		-- upgrade level
		if not osd[pos] then
			osd[pos] = 0
		end
		osd.upgradelevel = osd[pos]
		pos = pos + 1
		
		-- everything up to here should exist in the itemstring
		-- after this, seems to be specific to the item type
		
		if pos <= c then
			-- record start position of custom values
			osd.custom = pos
		end
		
		-- build a h2 internal hyperlink for comparison purposes
		osd.h2 = osd[3]
		for k = 4, pos - 1 do
			osd.h2 = string.format( "%s:%s", osd.h2, osd[k] or 0 )
		end
		
	elseif osd.class == "keystone" then
		
		-- keystone:138019:239:2:0:0:0:0
		--[[
			[01]class
			[02]itemid
			[03]instance
			[04]level
			[05]status (2=active, ?=depleted)
			[06]affix1
			[07]affix2
			[08]affix3
			[09]affix4
		]]--
		
		osd.keyIDCount = string.format( "item:%s", osd.id )
		
		osd.instance = osd[3]
		osd.level = osd[4]
		osd.status = osd[5]
		
		-- affix ids
		for x = 6, 9 do
			if osd[x] ~= 0 then
				if not osd.bonusids then
					osd.bonusids = { }
				end
				osd.bonusids[osd[x]] = true
			end
		end
		
	elseif osd.class == "spell" then
		
		--[[
			[01]class
			[02]spellId
			[03]glyphId
			[04]???
		]]--
		
		osd.glyphid = osd[3]
		
	elseif osd.class == "copper" then
		
		--[[
			[01]class
			[02]not used (always 0)
			[03]amount
		--]]
		
		osd.amount = osd[3]
		
	elseif osd.class == "empty" then
		
		--[[
			[01]class
			[02]not used (always 0)
			[03]bag type
		--]]
		
		osd.bagtype = osd[3]
		
	end
	
	return osd
	
end

local cacheObjectIDCount = { }
function ArkInventory.ObjectIDCount( h, i )
	-- avg 0.000189 / 0.000151
	local hr = string.trim( h or "" )
	
	if cacheObjectIDCount[hr] then
		return cacheObjectIDCount[hr]
	end
	
	local osd = ArkInventory.ObjectStringDecode( hr, i )
	
	local v = nil
	
	if osd.class == "keystone" then
		v = string.format( "item:%s", osd.id )
	else
		v = string.format( "%s:%s", osd.class, osd.id )
	end
	
	if hr ~= "" then
		cacheObjectIDCount[hr] = v
	end
	
	return v
	
end

function ArkInventory.GetItemQualityColor( rarity )
	
	local rarity = rarity or -1
	
	if ( rarity == -1 ) then
		return NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, string.sub( NORMAL_FONT_COLOR_CODE, 3 ), NORMAL_FONT_COLOR_CODE
	else
		local r, g, b, c = GetItemQualityColor( rarity )
		return r, g, b, c, string.format( "|c%s", c )
	end
	
end

function ArkInventory.InventoryIDGet( loc_id, bag_id )
	
	local blizzard_id = ArkInventory.InternalIdToBlizzardBagId( loc_id, bag_id )
	
	if blizzard_id == nil then
		return nil
	end
	
	if loc_id == ArkInventory.Const.Location.Bag and bag_id > 1 then
		
		return ContainerIDToInventoryID( blizzard_id )
		
	elseif loc_id == ArkInventory.Const.Location.Bank then
		
		if bag_id > 1 then
			
			return ContainerIDToInventoryID( blizzard_id )
			
		end
		
	end
	
end

function ArkInventory.ObjectIDCategory( i, isRule )
	
	-- if you change these values then you need to upgrade the savedvariable data as well
	
	local soulbound = ArkInventory.Const.Bind.Never
	if i.sb == ArkInventory.Const.Bind.Pickup or i.sb == ArkInventory.Const.Bind.Account then
		soulbound = 1
	end
	
	local info = ArkInventory.ObjectInfoArray( i.h )
	local osd = info.osd
	local r
	
	if osd.class == "item" then
		r = string.format( "%s:%i:%i", osd.class, osd.id, soulbound )
		if isRule and info.equiploc ~= "" then
			-- equipable items get an expanded rule id
			r = string.format( "%s:%s", r, osd.h2 )
		end
	elseif osd.class == "empty" then
		local blizzard_id = ArkInventory.InternalIdToBlizzardBagId( i.loc_id, i.bag_id )
		soulbound = ArkInventory.BagType( blizzard_id ) -- allows for unique codes per bag type
		r = string.format( "%s:%i:%i", osd.class, osd.id, soulbound )
	elseif osd.class == "spell" or osd.class == "copper" then
		r = string.format( "%s:%i", osd.class, osd.id )
	elseif osd.class == "keystone" then
		r = string.format( "%s:%i:%i", osd.class, osd.instance, soulbound )
	else
		ArkInventory.OutputWarning( "uncoded object class [", i.h, "] = [", osd.class, "]" )
		r = string.format( "%s:%i", osd.class, osd.id )
	end
	
	local codex = ArkInventory.GetLocationCodex( i.loc_id )
	local cr = string.format( "%i:%s", codex.catset_id, r )
	
	return cr, r, codex
	
end

function ArkInventory.ObjectIDRule( i )
	-- not saved, cached only, can be changed at any time
	--local codex = ArkInventory.GetLocationCodex( i.loc_id )
	local id, _, codex = ArkInventory.ObjectIDCategory( i, true )
	local rid = string.format( "%i:%i:%i:%s", i.loc_id or 0, i.bag_id or 0, i.sb or ArkInventory.Const.Bind.Never, ArkInventory.ObjectIDCategory( i, true ) )
	return rid, id, codex
end

function ArkInventory.ObjectCacheTooltipClear( )
	wipe( ArkInventory.Global.Cache.ItemCountTooltip )
end

function ArkInventory.ObjectCacheCountClear( search_id, player_id, loc_id, skipAltCheck )
	
	--ArkInventory.Output( "ObjectCacheCountClear( ", search_id, ", ", player_id, ", ", loc_id, " )" )
	
	local info = ArkInventory.GetPlayerInfo( )
	
	if player_id and ArkInventory.Global.Location[loc_id].isAccount then
		-- swap player to account
		player_id = ArkInventory.PlayerIDAccount( )
	end
	
	if search_id then
		
		-- clear the tooltip cache
		
--		if ArkInventory.Global.Cache.ItemCountTooltip[search_id] then
--			ArkInventory.Global.Cache.ItemCountTooltip[search_id].rebuild = true
--		end
		
--		ArkInventory.TooltipRebuildQueueAdd( search_id )
		
	end
	
	if search_id and player_id and loc_id then
		
		--ArkInventory.Output( "clear( ", search_id, ", ", player_id, ", ", loc_id, " )" )
		
		-- clear the raw data only for the specific location
		if ArkInventory.Global.Cache.ItemCountRaw[search_id] then
			if ArkInventory.Global.Cache.ItemCountRaw[search_id][player_id] then
				--ArkInventory.Output( ArkInventory.Global.Cache.ItemCountRaw[search_id][player_id].location[loc_id] )
				ArkInventory.Global.Cache.ItemCountRaw[search_id][player_id].location[loc_id] = nil
			end
		end
		
		return
		
	end
	
	if search_id and player_id then
		
		-- reset count for a specific item for a specific player
		--ArkInventory.Output( "ObjectCacheCountClear( ", search_id, ", ", player_id )
		
		-- clear the raw data
		
		if ArkInventory.Global.Cache.ItemCountRaw[search_id] then
			ArkInventory.Global.Cache.ItemCountRaw[search_id][player_id] = nil
		end
		
		return
		
	end
	
	if search_id and not player_id then
		
		-- reset count for a specific item for all players
		
		ArkInventory.Global.Cache.ItemCountRaw[search_id] = nil
		
		return
		
	end
	
	if not search_id and not player_id then
		
		--ArkInventory.Output( "wipe all item count data" )
		
		wipe( ArkInventory.Global.Cache.ItemCountTooltip )
		
		wipe( ArkInventory.Global.Cache.ItemCountRaw )
		
		return
		
	end
	
end

function ArkInventory.ObjectCountGetRaw( search_id, thread_id )
	
	--ArkInventory.Output( "ObjectCountGetRaw( ", search_id , " )" )
	
	local changed = false
	
	if not ArkInventory.Global.Cache.ItemCountRaw[search_id] then
		ArkInventory.Global.Cache.ItemCountRaw[search_id] = { }
		changed = true
	end
	
	local d = ArkInventory.Global.Cache.ItemCountRaw[search_id]
	
	local bc, lc, ls, k
	
	for pid, pd in pairs( ArkInventory.db.player.data ) do
		
		if pd.info.name then
			
			if not d[pid] then
				d[pid] = { location = { }, extra = { }, realm = pd.info.realm, faction = pd.info.faction, class = pd.info.class }
				changed = true
			end
			
			d[pid].total = 0
			d[pid].entries = 0
			
			local extra = d[pid].extra
			
			for loc_id, loc_data in pairs( ArkInventory.Global.Location ) do
				
				if not d[pid].location[loc_id] then
					
					-- rebuild missing location data
					
					changed = true
					local ld = pd.location[loc_id]
					
					--ArkInventory.Output( "scanning [", pid, "] [", loc_id, "] [", search_id, "]" )
					lc = 0
					ls = 0
					k = false
					
					for b in pairs( loc_data.Bags ) do
						
						if thread_id then
							ArkInventory.ThreadYield( thread_id )
						end
						
						bc = 0
						
						local bd = ld.bag[b]
						
						k = false
						
						if bd.h and search_id == ArkInventory.ObjectIDCount( bd.h ) then
							--ArkInventory.Output( "found bag [", b, "] equipped" )
							lc = lc + 1
							k = true
						end
						
						for sn, sd in pairs( bd.slot ) do
							
							if sd and sd.h then
								
								-- primary match
								local oit = ArkInventory.ObjectIDCount( sd.h )
								local matches = ( search_id == oit ) and search_id
								
								if matches then
									
									--ArkInventory.Output( pid, " has ", sd.count, " x ", sd.h, " in loc[", loc_id, "], bag [", b, "] slot [", sn, "]" )
									lc = lc + sd.count
									bc = bc + sd.count
									ls = ls + 1
									k = true
									
								end
								
							end
							
						end
						
					end
					
					d[pid].location[loc_id] = { ["c"] = lc, ["s"] = ls }
					
					--ArkInventory.Output( "ItemCountRaw[", search_id, "][", pid, "].location[", loc_id, "] = ", d[pid].location[loc_id] )
					
				end
				
				d[pid].total = d[pid].total + d[pid].location[loc_id].c
				
				if d[pid].location[loc_id].c > 0 then
					d[pid].entries = d[pid].entries + 1
				end
				
			end
			
		end
		
	end
	
	return d, changed
	
end

function ArkInventory.ScanMonitor( blizzard_id )
	
	local loc_id, bag_id = ArkInventory.BlizzardBagIdToInternalId( blizzard_id )
	
	if not ArkInventory.Global.Location[loc_id].scanning then
		ArkInventory.Global.Location[loc_id].scanning = { }
	end
	
	if ArkInventory.Global.Location[loc_id].scanning[bag_id] then
		
	else
		
	end
	
end
