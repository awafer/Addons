local _G = _G
local select = _G.select
local pairs = _G.pairs
local ipairs = _G.ipairs
local string = _G.string
local type = _G.type
local error = _G.error
local table = _G.table


ArkInventory.LDB = {
	Bags = ArkInventory.Lib.DataBroker:NewDataObject( string.format( "%s_%s", ArkInventory.Const.Program.Name, "Bags" ), {
		type = "data source",
		text = BLIZZARD_STORE_LOADING,
	} ),
	Money = ArkInventory.Lib.DataBroker:NewDataObject( string.format( "%s_%s", ArkInventory.Const.Program.Name, "Money" ), {
		type = "data source",
		text = BLIZZARD_STORE_LOADING,
	} ),
	Tracking_Item = ArkInventory.Lib.DataBroker:NewDataObject( string.format( "%s_%s_%s", ArkInventory.Const.Program.Name, "Tracking", "Item" ), {
		type = "data source",
		text = BLIZZARD_STORE_LOADING,
	} ),
}

local companionTable = { }



function ArkInventory.LDB.Bags:OnClick( button )
	if button == "RightButton" then
		ArkInventory.MenuLDBBagsOpen( self )
	else
		ArkInventory.Frame_Main_Toggle( ArkInventory.Const.Location.Bag )
	end
end

function ArkInventory.LDB.Bags:Update( )
	
	local icon = string.format( "|T%s:0|t", ArkInventory.Global.Location[ArkInventory.Const.Location.Bag].Texture )
	local hasText
	
	local me = ArkInventory.GetPlayerCodex( )
	local loc_id = ArkInventory.Const.Location.Bag
	
	hasText = ArkInventory.Frame_Status_Update_Empty( loc_id, me, true )
	
	if hasText then
		self.text = string.trim( string.format( "%s %s", icon, hasText ) )
	else
		self.text = icon
	end
	
end



function ArkInventory.LDB.Money:Update( )
	
	local icon = string.format( "|T%s:0|t", [[Interface\Icons\INV_Misc_Coin_02]] )
	local hasText
	
	hasText = ArkInventory.MoneyText( GetMoney( ) )
	
	if hasText then
		self.text = string.trim( hasText )
	else
		self.text = icon
	end
	
end

function ArkInventory.LDB.Money.OnTooltipShow( frame )
	ArkInventory.MoneyFrame_Tooltip( frame )
end



function ArkInventory.LDB.Tracking_Item:Update( )
	
	local icon = string.format( "|T%s:0|t", [[Interface\Icons\Ability_Tracking]] )
	local hasText
	
	local me = ArkInventory.GetPlayerCodex( )
	
	for k in ArkInventory.spairs( ArkInventory.db.option.tracking.items )  do
		
		if me.player.data.ldb.tracking.item.tracked[k] then
			
			local count = GetItemCount( k, true )
			local icon = select( 10, GetItemInfo( k ) )
			hasText = string.format( "%s  |T%s:0|t %s", hasText or "", icon or ArkInventory.Const.Texture.Missing, FormatLargeNumber( count or 0 ) )
			
		end
		
	end
	
	if hasText then
		self.text = string.trim( hasText )
	else
		self.text = icon
	end
	
end

function ArkInventory.LDB.Tracking_Item:OnClick( button )
	
	if button == "RightButton" then
		ArkInventory.MenuLDBTrackingItemOpen( self )
	end
	
end

function ArkInventory.LDB.Tracking_Item:OnTooltipShow( )
	
	self:AddLine( string.format( "%s: %s", ArkInventory.Localise["TRACKING"], ArkInventory.Localise["ITEMS"] ) )
	
	self:AddLine( " " )
	
	local me = ArkInventory.GetPlayerCodex( )
	
	for k in ArkInventory.spairs( ArkInventory.db.option.tracking.items ) do
		
		local count = GetItemCount( k, true )
		local name = GetItemInfo( k )
		
		local checked = me.player.data.ldb.tracking.item.tracked[k]
		
		if checked then
			self:AddDoubleLine( name, count, 0, 1, 0, 0, 1, 0 )
		else
			self:AddDoubleLine( name, count, 1, 1, 1, 1, 1, 1 )
		end
		
	end
	
	self:Show( )
	
end
