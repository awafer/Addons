local _G = _G
local select = _G.select
local pairs = _G.pairs
local ipairs = _G.ipairs
local string = _G.string
local type = _G.type
local error = _G.error
local table = _G.table

ArkInventory.Lib.StaticDialog:Register( "DESIGN_EXPORT", {
	
	text = ArkInventory.Localise["EXPORT"],
	hide_on_escape = true,
	exclusive = true,
	
	buttons = {
		{
			text = ArkInventory.Localise["CANCEL"],
		},
	},
	
	editboxes = {
		{
			auto_focus = true,
			width = 200,
			on_enter_pressed = function( self, data )
				ArkInventory.Lib.StaticDialog:Dismiss( "DESIGN_EXPORT" )
			end,
			on_escape_pressed = function( self, data )
				ArkInventory.Lib.StaticDialog:Dismiss( "DESIGN_EXPORT" )
			end,
		},
	},
	
	on_show = function( self, data )
		self.editboxes[1]:SetText( self.data or "" )
	end,
	
} )

ArkInventory.Lib.StaticDialog:Register( "DESIGN_IMPORT", {
	
	text = ArkInventory.Localise["IMPORT"],
	hide_on_escape = true,
	exclusive = true,
	
	buttons = {
		{
			text = ArkInventory.Localise["OKAY"],
			on_click = function( self )
				ArkInventory.ConfigInternalDesignImport( self:GetText( ) )
				ArkInventory.Lib.StaticDialog:Dismiss( "DESIGN_IMPORT" )
			end,
		},
		{
			text = ArkInventory.Localise["CANCEL"],
		},
	},
	
	editboxes = {
		{
			
			auto_focus = true,
			width = 200,
			
			on_enter_pressed = function( self, data )
				ArkInventory.ConfigInternalDesignImport( self:GetText( ) )
				ArkInventory.Lib.StaticDialog:Dismiss( "DESIGN_IMPORT" )
			end,
			
			on_escape_pressed = function( self, data )
				ArkInventory.Lib.StaticDialog:Dismiss( "DESIGN_IMPORT" )
			end,
		},
	},
	
	on_show = function( self, data )
		self.editboxes[1]:SetText( "" )
	end,
	
} )

