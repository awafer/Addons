local _G = _G
local select = _G.select
local pairs = _G.pairs
local ipairs = _G.ipairs
local string = _G.string
local type = _G.type
local error = _G.error
local table = _G.table


function ArkInventory.MenuMainOpen( frame )
	
	assert( frame, "code error: frame argument is missing" )

	if ArkInventory.Lib.Dewdrop:IsOpen( frame ) then
		
		ArkInventory.Lib.Dewdrop:Close( )
		
	else

		local loc_id = frame:GetParent( ):GetParent( ).ARK_Data.loc_id
		local codex = ArkInventory.GetLocationCodex( loc_id )
		
		local anchorpoints = {
			[ArkInventory.Const.Anchor.TopRight] = ArkInventory.Localise["TOPRIGHT"],
			[ArkInventory.Const.Anchor.BottomRight] = ArkInventory.Localise["BOTTOMRIGHT"],
			[ArkInventory.Const.Anchor.BottomLeft] = ArkInventory.Localise["BOTTOMLEFT"],
			[ArkInventory.Const.Anchor.TopLeft] = ArkInventory.Localise["TOPLEFT"],
		}
		
		local x, p, rp
		x = frame:GetLeft( ) + ( frame:GetRight( ) - frame:GetLeft( ) ) / 2
		if ( x >= ( GetScreenWidth( ) / 2 ) ) then
			p = "TOPRIGHT"
			rp = "TOPLEFT"
		else
			p = "TOPLEFT"
			rp = "TOPRIGHT"
		end
		
		ArkInventory.Lib.Dewdrop:Open( frame,
			"point", p,
			"relativePoint", rp,
			"children", function( level, value )
				
				if level == 1 then
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Const.Program.Name,
						"isTitle", true
					)
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Global.Version,
						"notClickable", true
					)
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["CONFIG"],
						"closeWhenClicked", true,
						"func", function( )
							ArkInventory.Frame_Config_Show( )
						end
					)
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"icon", ArkInventory.Const.Actions[ArkInventory.Const.ActionID.Refresh].Texture,
						"text", ArkInventory.Const.Actions[ArkInventory.Const.ActionID.Refresh].Name,
						"closeWhenClicked", true,
						"func", function( )
							ArkInventory.Frame_Main_Generate( loc_id, ArkInventory.Const.Window.Draw.Recalculate )
						end
					)
					
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["RELOAD"],
						"tooltipTitle", ArkInventory.Localise["RELOAD"],
						"tooltipText", ArkInventory.Localise["MENU_ACTION_RELOAD_TEXT"],
						"closeWhenClicked", true,
						"func", function( )
							ArkInventory.ItemCacheClear( )
							ArkInventory.Frame_Main_Generate( loc_id, ArkInventory.Const.Window.Draw.Recalculate )
						end
					)
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"icon", ArkInventory.Const.Actions[ArkInventory.Const.ActionID.Restack].Texture,
						"text", ArkInventory.Const.Actions[ArkInventory.Const.ActionID.Restack].Name,
						"closeWhenClicked", true,
						"func", function( )
							ArkInventory.Restack( loc_id )
						end
					)
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"icon", ArkInventory.Const.Actions[ArkInventory.Const.ActionID.Search].Texture,
						"text", ArkInventory.Const.Actions[ArkInventory.Const.ActionID.Search].Name,
						"closeWhenClicked", true,
						"func", function( )
							ArkInventory.Search.Frame_Toggle( )
						end
					)
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"icon", ArkInventory.Const.Actions[ArkInventory.Const.ActionID.Rules].Texture,
						"text", ArkInventory.Const.Actions[ArkInventory.Const.ActionID.Rules].Name,
						"closeWhenClicked", true,
						"func", function( )
							ArkInventory.Frame_Rules_Toggle( )
						end
					)
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"icon", ArkInventory.Const.Actions[ArkInventory.Const.ActionID.EditMode].Texture,
						"text", ArkInventory.Const.Actions[ArkInventory.Const.ActionID.EditMode].Name,
						"closeWhenClicked", true,
						"checked", ArkInventory.Global.Mode.Edit,
						"func", function( )
							ArkInventory.ToggleEditMode( )
						end
					)
					
				end
				
				
				ArkInventory.Lib.Dewdrop:AddLine( )
				
				ArkInventory.Lib.Dewdrop:AddLine(
					"text", ArkInventory.Localise["CLOSE_MENU"],
					"closeWhenClicked", true
				)
				
			end
			
		)
	
	end
	
end

function ArkInventory.MenuBarOpen( frame )
	
	assert( frame, "code error: frame argument is missing" )
	
	if ArkInventory.Lib.Dewdrop:IsOpen( frame ) then

		ArkInventory.Lib.Dewdrop:Close( )
		
	else

		local loc_id = frame.ARK_Data.loc_id
		local bar_id = frame.ARK_Data.bar_id
		local codex = ArkInventory.GetLocationCodex( loc_id )
		local bar_name = codex.layout.bar.data[bar_id].name.text or ""
		
		local sid_def = codex.style.sort.method or 9999
		local sid = codex.layout.bar.data[bar_id].sort.method or sid_def
		
		if ArkInventory.db.option.sort.method.data[sid].used ~= "Y" then
			--ArkInventory.OutputWarning( "bar ", bar_id, " in location ", loc_id, " is using an invalid sort method.  resetting it to default" )
			codex.layout.bar.data[bar_id].sort.method = nil
			sid = sid_def
		end
		
		--ArkInventory.Output( "sid=[", sid, "] default=[", sid_def, "]" )
		
		local x, p, rp
		x = frame:GetLeft( ) + ( frame:GetRight( ) - frame:GetLeft( ) ) / 2
		if ( x >= ( GetScreenWidth( ) / 2 ) ) then
			p = "TOPRIGHT"
			rp = "TOPLEFT"
		else
			p = "TOPLEFT"
			rp = "TOPRIGHT"
		end
	
		local category = {
			["type"] = { "SYSTEM", "CONSUMABLE", "TRADEGOODS", "SKILL", "CLASS", "EMPTY", "CUSTOM", "RULE", },
		}
		
		ArkInventory.Lib.Dewdrop:Open( frame,
			"point", p,
			"relativePoint", rp,
			"children", function( level, value )
			
				if level == 1 then
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", string.format( ArkInventory.Localise["MENU_BAR_TITLE"], bar_id ),
						"isTitle", true
					)
					
					if codex.style.window.list then
						
						ArkInventory.Lib.Dewdrop:AddLine( )
						
						local text = string.format( "%s* %s *%s", RED_FONT_COLOR_CODE, ArkInventory.Localise["LOCKED"], FONT_COLOR_CODE_CLOSE )
						local desc = ArkInventory.Localise["MENU_LOCKED_LIST_TEXT"]
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", text,
							"tooltipTitle", text,
							"tooltipText", desc
						)
						
					else
					
					if codex.layout.system then
						
						local text = string.format( "%s* %s *%s", RED_FONT_COLOR_CODE, ArkInventory.Localise["LOCKED"], FONT_COLOR_CODE_CLOSE )
						local desc = string.format( ArkInventory.Localise["MENU_LOCKED_TEXT"], ArkInventory.Localise["CONFIG_LAYOUT"], ArkInventory.Localise["CONFIG"], ArkInventory.Localise["CONTROLS"] )
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", text,
							"tooltipTitle", text,
							"tooltipText", desc
						)
					
					else
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", string.format( "%s: %s%s%s", ArkInventory.Localise["NAME"], LIGHTYELLOW_FONT_COLOR_CODE, bar_name, FONT_COLOR_CODE_CLOSE ),
						"tooltipTitle", ArkInventory.Localise["NAME"],
						"tooltipText", string.format( ArkInventory.Localise["CONFIG_DESIGN_BAR_NAME_TEXT"], bar_id ),
						"hasArrow", true,
						"hasEditBox", true,
						"editBoxText", bar_name,
						"editBoxFunc", function( v )
							bar_name = string.trim( v )
							codex.layout.bar.data[bar_id].name.text = bar_name
							ArkInventory.Frame_Bar_Paint_All( )
						end
					)
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["COLOUR"],
						"hasArrow", true,
						"value", "BAR_COLOUR"
					)
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["ACTION"],
						"hasArrow", true,
						"value", "BAR_ACTION"
					)
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["WIDTH"],
						"hasArrow", true,
						"value", "BAR_WIDTH"
					)
					
					end
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", string.format( "%s:", ArkInventory.Localise["CONFIG_SORTING_METHOD"] ),
						"isTitle", true
					)
					
					if codex.layout.system then
						
						local text = string.format( "%s* %s *%s", RED_FONT_COLOR_CODE, ArkInventory.Localise["LOCKED"], FONT_COLOR_CODE_CLOSE )
						local desc = string.format( ArkInventory.Localise["MENU_LOCKED_TEXT"], ArkInventory.Localise["CONFIG_LAYOUT"], ArkInventory.Localise["CONFIG"], ArkInventory.Localise["CONTROLS"] )
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", text,
							"tooltipTitle", text,
							"tooltipText", desc
						)
					
					else
						
						if sid ~= sid_def then
							
							ArkInventory.Lib.Dewdrop:AddLine(
								"text", string.format( "%s: %s%s%s", ArkInventory.Localise["CURRENT"], GREEN_FONT_COLOR_CODE, ArkInventory.db.option.sort.method.data[sid].name, FONT_COLOR_CODE_CLOSE ),
								"hasArrow", true,
								"value", "SORTING_METHOD"
							)
							
							--ArkInventory.Lib.Dewdrop:AddLine( )
							
							ArkInventory.Lib.Dewdrop:AddLine(
								"text", string.format( "%s: %s%s%s", ArkInventory.Localise["DEFAULT"], LIGHTYELLOW_FONT_COLOR_CODE, ArkInventory.db.option.sort.method.data[sid_def].name, FONT_COLOR_CODE_CLOSE ),
								"tooltipTitle", ArkInventory.Localise["MENU_ITEM_DEFAULT_RESET"],
								"tooltipText", string.format( ArkInventory.Localise["MENU_BAR_SORTKEY_DEFAULT_RESET_TEXT"], bar_id ),
								"closeWhenClicked", true,
								"func", function( )
									codex.layout.bar.data[bar_id].sort.method = nil
									ArkInventory.ItemSortKeyClear( loc_id )
									ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Resort )
								end
							)
							
						else
							
							ArkInventory.Lib.Dewdrop:AddLine(
								"text", string.format( "%s: %s%s%s", ArkInventory.Localise["DEFAULT"], LIGHTYELLOW_FONT_COLOR_CODE, ArkInventory.db.option.sort.method.data[sid_def].name, FONT_COLOR_CODE_CLOSE ),
								"hasArrow", true,
								"value", "SORTING_METHOD"
							)
							
						end
						
					end
					
					
					if codex.layout.system then
						
						
						
					else
						
						ArkInventory.Lib.Dewdrop:AddLine( )
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", string.format( "%s:", ArkInventory.Localise["MENU_BAR_CATEGORY_CURRENT"] ),
							"isTitle", true
						)
						
						local has_entries = false
						for _, v in ipairs( category.type ) do
							if ArkInventory.CategoryBarHasEntries( loc_id, bar_id, v ) then
								has_entries = true
								ArkInventory.Lib.Dewdrop:AddLine(
									"text", ArkInventory.Localise[string.format( "CATEGORY_%s", v )],
									"hasArrow", true,
									"value", string.format( "CATEGORY_CURRENT_%s", v )
								)
							end
						end
						
						for bag_id in pairs( ArkInventory.Global.Location[loc_id].Bags ) do
							if codex.layout.bag[bag_id].bar == bar_id then
								has_entries = true
								ArkInventory.Lib.Dewdrop:AddLine(
									"text", ArkInventory.Localise["BAG"],
									"hasArrow", true,
									"value", "BAG_CURRENT"
								)
							end
						end
						
						if not has_entries then
							ArkInventory.Lib.Dewdrop:AddLine(
								"text", ArkInventory.Localise["NONE"],
								"disabled", true
							)
						end
						
					end
					
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", string.format( "%s:", ArkInventory.Localise["MENU_BAR_CATEGORY_ASSIGN"] ),
						"isTitle", true
					)
					
					if codex.layout.system then
						
						local text = string.format( "%s* %s *%s", RED_FONT_COLOR_CODE, ArkInventory.Localise["LOCKED"], FONT_COLOR_CODE_CLOSE )
						local desc = string.format( ArkInventory.Localise["MENU_LOCKED_TEXT"], ArkInventory.Localise["CONFIG_LAYOUT"], ArkInventory.Localise["CONFIG"], ArkInventory.Localise["CONTROLS"] )
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", text,
							"tooltipTitle", text,
							"tooltipText", desc
						)
					
					else
					
					for _, v in ipairs( category.type ) do
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise[string.format( "CATEGORY_%s", v )],
							"hasArrow", true,
							"value", string.format( "CATEGORY_ASSIGN_%s", v )
						)
					end
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["BAG"],
						"hasArrow", true,
						"hidden", codex.layout.system,
						"value", "BAG_ASSIGN"
					)
					
					end
					
					if not codex.layout.system then
						
						if ArkInventory.Global.Options.CategoryMoveLocation == loc_id and ArkInventory.Global.Options.CategoryMoveSource ~= bar_id then
							
							ArkInventory.Lib.Dewdrop:AddLine( )
							
							local cat = ArkInventory.Global.Category[ArkInventory.Global.Options.CategoryMoveCategory]
							
							ArkInventory.Lib.Dewdrop:AddLine(
								"text", string.format( "%s: %s", ArkInventory.Localise["MOVE"], ArkInventory.Localise["COMPLETE"] ),
								"tooltipTitle", string.format( "%s: %s", ArkInventory.Localise["MOVE"], ArkInventory.Localise["COMPLETE"] ),
								"tooltipText", string.format( ArkInventory.Localise["MENU_BAR_CATEGORY_MOVE_COMPLETE_TEXT"], string.format( "%s%s%s", LIGHTYELLOW_FONT_COLOR_CODE, cat.fullname, FONT_COLOR_CODE_CLOSE ), ArkInventory.Global.Options.CategoryMoveSource, bar_id ),
								"closeWhenClicked", true,
								"func", function( )
									ArkInventory.CategoryLocationSet( loc_id, cat.id, bar_id )
									ArkInventory.Global.Options.CategoryMoveLocation = nil
									ArkInventory.Global.Options.CategoryMoveSource = nil
									ArkInventory.Global.Options.CategoryMoveCategory = nil
									ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Recalculate )
								end
							)
							
						end
					
					end
					
					end
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["CLOSE_MENU"],
						"closeWhenClicked", true
					)
					
				end
				
				
				if level == 2 and value then
					
					if value == "SORTING_METHOD" then
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["CONFIG_SORTING_METHOD"],
							"isTitle", true
						)
						
						ArkInventory.Lib.Dewdrop:AddLine( )
						
						local x = ArkInventory.db.option.sort.method.data
						for k, v in ArkInventory.spairs( x, function(a,b) return a < b end ) do
							
							if v.used == "Y" then
								local n = v.name
								if v.system then
									n = string.format( "* %s", n )
								end
								n = string.format( "[%04i] %s", k, n )
								ArkInventory.Lib.Dewdrop:AddLine(
									"text", n,
									"tooltipTitle", ArkInventory.Localise["CONFIG_SORTING_METHOD"],
									"tooltipText", string.format( ArkInventory.Localise["MENU_BAR_SORTKEY_TEXT"], v.name, bar_id ),
									"isRadio", true,
									"checked", k == sid,
									"disabled", k == sid,
									"closeWhenClicked", true,
									"func", function( )
										if k == sid_def then
											codex.layout.bar.data[bar_id].sort.method = nil
										else
											codex.layout.bar.data[bar_id].sort.method = k
										end
										ArkInventory.ItemSortKeyClear( loc_id )
										ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Resort )
									end
								)
							end
							
						end
						
						ArkInventory.Lib.Dewdrop:AddLine( )
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["CONFIG"],
							"closeWhenClicked", true,
							"func", function( )
								ArkInventory.Frame_Config_Show( "settings", "sortmethod" )
							end
						)
					
					end
					
					
					if strsub( value, 1, 9 ) == "CATEGORY_" then
						
						local int_type, cat_type = string.match( value, "^CATEGORY_(.+)_(.+)$" )
						
						if cat_type ~= nil then
							
							ArkInventory.Lib.Dewdrop:AddLine(
								"text", ArkInventory.Localise[string.format( "CATEGORY_%s", cat_type )],
								"isTitle", true
							)

							ArkInventory.Lib.Dewdrop:AddLine( )
							
							for _, cat in ArkInventory.spairs( ArkInventory.Global.Category, function(a,b) return ArkInventory.Global.Category[a].sort_order < ArkInventory.Global.Category[b].sort_order end ) do
								
								local t = cat.type_code
								local cat_bar, def_bar = ArkInventory.CategoryLocationGet( loc_id, cat.id )
								local icon = ""
								
								if int_type == "ASSIGN" and abs( cat_bar ) == bar_id and not def_bar then
									t = "DO_NOT_DISPLAY"
								end
								
								if int_type == "CURRENT" and ( abs( cat_bar ) ~= bar_id or def_bar ) then
									t = "DO_NOT_DISPLAY"
								end
								
								if cat_type == t then
									
									local cat_z, cat_code = ArkInventory.CategoryCodeSplit( cat.id )
									
									local c1 = ""
									
									if not def_bar then
										c1 = LIGHTYELLOW_FONT_COLOR_CODE
									end
									
									if not codex.catset.category.active[cat_z][cat_code] then
										c1 = RED_FONT_COLOR_CODE
									end
									
									if codex.catset.category.junk[cat_z][cat_code] then
										icon = [[Interface\Icons\INV_Misc_Coin_02]]
									end
									
									local n = string.format( "%s%s", c1, cat.name )
									
									local c2 = GREEN_FONT_COLOR_CODE
									if cat_bar < 0 then
										c2 = RED_FONT_COLOR_CODE
									end
									if not def_bar then
										n = string.format( "%s %s[%s]", n, c2, abs( cat_bar ) )
									end
									
									if abs( cat_bar ) ~= bar_id then
										ArkInventory.Lib.Dewdrop:AddLine(
											"text", n,
											"tooltipTitle", ArkInventory.Localise["CATEGORY"],
											"tooltipText", string.format( ArkInventory.Localise["MENU_BAR_CATEGORY_TEXT"], string.format( "%s%s%s", LIGHTYELLOW_FONT_COLOR_CODE, cat.fullname, FONT_COLOR_CODE_CLOSE ), bar_id ),
											"icon", icon,
											"hasArrow", true,
											"value", string.format( "CATEGORY_OPTION_%s", cat.id ),
											"func", function( )
												ArkInventory.CategoryLocationSet( loc_id, cat.id, bar_id )
												ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Recalculate )
											end
										)
										
									else
									
										ArkInventory.Lib.Dewdrop:AddLine(
											"text", n,
											"tooltipTitle", ArkInventory.Localise["CATEGORY"],
											"tooltipText", string.format( ArkInventory.Localise["MENU_BAR_CATEGORY_REMOVE_TEXT"], string.format( "%s%s%s", LIGHTYELLOW_FONT_COLOR_CODE, cat.fullname, FONT_COLOR_CODE_CLOSE ), cat_bar ),
											"icon", icon,
											"hasArrow", true,
											"value", string.format( "CATEGORY_OPTION_%s", cat.id ),
											"func", function( )
												ArkInventory.CategoryLocationSet( loc_id, cat.id, nil )
												ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Recalculate )
											end
										)
										
									end
									
								end
	
							end
							
						end
						
					end
					
					
					if strsub( value, 1, 4 ) == "BAG_" then
						
						local int_type = string.match( value, "^BAG_(.+)$" )
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["BAG"],
							"isTitle", true
						)
						
						ArkInventory.Lib.Dewdrop:AddLine( )
						
						for bag_id in pairs( ArkInventory.Global.Location[loc_id].Bags ) do
							
							local cat_bar = codex.layout.bag[bag_id].bar
							
							if ( int_type == "ASSIGN" and bar_id ~= cat_bar ) or ( int_type == "CURRENT" and bar_id == cat_bar ) then
								
								local n = string.format( "%s", bag_id )
								
								if cat_bar then
									n = string.format( "%s%s%s [%s]%s", LIGHTYELLOW_FONT_COLOR_CODE, n, GREEN_FONT_COLOR_CODE, cat_bar, FONT_COLOR_CODE_CLOSE )
								end
								
								ArkInventory.Lib.Dewdrop:AddLine(
									"text", n,
									"tooltipTitle", ArkInventory.Localise["BAG"],
									"tooltipText", string.format( ArkInventory.Localise["MENU_BAR_BAG_ASSIGN_TEXT"], bag_id, bar_id ),
									"hasArrow", cat_bar,
									"value", string.format( "BAG_OPTION_%s", bag_id ),
									"func", function( )
										codex.layout.bag[bag_id].bar = bar_id
										ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Recalculate )
									end
								)
								
							end
							
						end
						
					end
					
					
					if value == "BAR_COLOUR" then
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["BORDER"],
							"isTitle", true
						)
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["DEFAULT"],
							"tooltipTitle", ArkInventory.Localise["DEFAULT"],
							"tooltipText", string.format( ArkInventory.Localise["MENU_BAR_COLOUR_BORDER_DEFAULT_TEXT"], bar_id ),
							"isRadio", true,
							"checked", codex.layout.bar.data[bar_id].border.custom == 1,
							"disabled", codex.layout.bar.data[bar_id].border.custom == 1,
							"func", function( )
								codex.layout.bar.data[bar_id].border.custom = 1
								ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Restart )
							end
						)
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["CUSTOM"],
							"tooltipTitle", ArkInventory.Localise["CUSTOM"],
							"tooltipText", string.format( ArkInventory.Localise["MENU_BAR_COLOUR_BORDER_CUSTOM_TEXT"], bar_id ),
							"isRadio", true,
							"checked", codex.layout.bar.data[bar_id].border.custom == 2,
							"disabled", codex.layout.bar.data[bar_id].border.custom == 2,
							"func", function( )
								codex.layout.bar.data[bar_id].border.custom = 2
								ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Restart )
							end
						)
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["COLOUR"],
							"tooltipTitle", ArkInventory.Localise["COLOUR"],
							"tooltipText", string.format( ArkInventory.Localise["MENU_BAR_COLOUR_BORDER_TEXT"], bar_id ),
							"hasColorSwatch", true,
							"hasOpacity", true,
							"disabled", codex.layout.bar.data[bar_id].border.custom ~= 2,
							"r", codex.layout.bar.data[bar_id].border.colour.r,
							"g", codex.layout.bar.data[bar_id].border.colour.g,
							"b", codex.layout.bar.data[bar_id].border.colour.b,
							"opacity", codex.layout.bar.data[bar_id].border.colour.a,
							"colorFunc", function( r, g, b, a )
								codex.layout.bar.data[bar_id].border.colour.r = r
								codex.layout.bar.data[bar_id].border.colour.g = g
								codex.layout.bar.data[bar_id].border.colour.b = b
								codex.layout.bar.data[bar_id].border.colour.a = a
								ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Restart )
							end
						)
						
						ArkInventory.Lib.Dewdrop:AddLine( )
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["BACKGROUND"],
							"isTitle", true
						)
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["DEFAULT"],
							"tooltipTitle", ArkInventory.Localise["DEFAULT"],
							"tooltipText", string.format( ArkInventory.Localise["MENU_BAR_COLOUR_BACKGROUND_DEFAULT_TEXT"], bar_id ),
							"isRadio", true,
							"checked", codex.layout.bar.data[bar_id].background.custom == 1,
							"disabled", codex.layout.bar.data[bar_id].background.custom == 1,
							"func", function( )
								codex.layout.bar.data[bar_id].background.custom = 1
								ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Restart )
							end
						)
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["CUSTOM"],
							"tooltipTitle", ArkInventory.Localise["CUSTOM"],
							"tooltipText", string.format( ArkInventory.Localise["MENU_BAR_COLOUR_BACKGROUND_CUSTOM_TEXT"], bar_id ),
							"isRadio", true,
							"checked", codex.layout.bar.data[bar_id].background.custom == 2,
							"disabled", codex.layout.bar.data[bar_id].background.custom == 2,
							"func", function( )
								codex.layout.bar.data[bar_id].background.custom = 2
								ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Restart )
							end
						)
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["COLOUR"],
							"tooltipTitle", ArkInventory.Localise["COLOUR"],
							"tooltipText", string.format( ArkInventory.Localise["MENU_BAR_COLOUR_BACKGROUND_TEXT"], bar_id ),
							"hasColorSwatch", true,
							"hasOpacity", true,
							"disabled", codex.layout.bar.data[bar_id].background.custom ~= 2,
							"r", codex.layout.bar.data[bar_id].background.colour.r,
							"g", codex.layout.bar.data[bar_id].background.colour.g,
							"b", codex.layout.bar.data[bar_id].background.colour.b,
							"opacity", codex.layout.bar.data[bar_id].background.colour.a,
							"colorFunc", function( r, g, b, a )
								codex.layout.bar.data[bar_id].background.colour.r = r
								codex.layout.bar.data[bar_id].background.colour.g = g
								codex.layout.bar.data[bar_id].background.colour.b = b
								codex.layout.bar.data[bar_id].background.colour.a = a
								ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Restart )
							end
						)
						
						ArkInventory.Lib.Dewdrop:AddLine( )
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["NAME"],
							"isTitle", true
						)
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["DEFAULT"],
							"tooltipTitle", ArkInventory.Localise["DEFAULT"],
							"tooltipText", string.format( ArkInventory.Localise["MENU_BAR_COLOUR_NAME_DEFAULT_TEXT"], bar_id ),
							"isRadio", true,
							"checked", codex.layout.bar.data[bar_id].name.custom == 1,
							"disabled", codex.layout.bar.data[bar_id].name.custom == 1,
							"func", function( )
								codex.layout.bar.data[bar_id].name.custom = 1
								ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Restart )
							end
						)
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["CUSTOM"],
							"tooltipTitle", ArkInventory.Localise["CUSTOM"],
							"tooltipText", string.format( ArkInventory.Localise["MENU_BAR_COLOUR_NAME_CUSTOM_TEXT"], bar_id ),
							"isRadio", true,
							"checked", codex.layout.bar.data[bar_id].name.custom == 2,
							"disabled", codex.layout.bar.data[bar_id].name.custom == 2,
							"func", function( )
								codex.layout.bar.data[bar_id].name.custom = 2
								ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Restart )
							end
						)
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["COLOUR"],
							"tooltipTitle", ArkInventory.Localise["COLOUR"],
							"tooltipText", string.format( ArkInventory.Localise["MENU_BAR_COLOUR_NAME_TEXT"], bar_id ),
							"hasColorSwatch", true,
							"disabled", codex.layout.bar.data[bar_id].name.custom ~= 2,
							"r", codex.layout.bar.data[bar_id].name.colour.r,
							"g", codex.layout.bar.data[bar_id].name.colour.g,
							"b", codex.layout.bar.data[bar_id].name.colour.b,
							"colorFunc", function( r, g, b, a )
								codex.layout.bar.data[bar_id].name.colour.r = r
								codex.layout.bar.data[bar_id].name.colour.g = g
								codex.layout.bar.data[bar_id].name.colour.b = b
								ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Restart )
							end
						)
						
					end
					
					
					if value == "BAR_ACTION" then
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["ACTION"],
							"isTitle", true
						)
						
						ArkInventory.Lib.Dewdrop:AddLine( )
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["RESET"],
							"tooltipTitle", ArkInventory.Localise["RESET"],
							"tooltipText", string.format( ArkInventory.Localise["MENU_BAR_RESET_TEXT"], bar_id ),
							"closeWhenClicked", true,
							"func", function( )
								ArkInventory.Frame_Bar_Clear( loc_id, bar_id )
								ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Recalculate )
							end
						)
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["INSERT"],
							"tooltipTitle", ArkInventory.Localise["INSERT"],
							"tooltipText", string.format( ArkInventory.Localise["MENU_BAR_INSERT_TEXT"], bar_id ),
							"closeWhenClicked", true,
							"func", function( )
								ArkInventory.Frame_Bar_Insert( loc_id, bar_id )
								ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Recalculate )
							end
						)
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["DELETE"],
							"tooltipTitle", ArkInventory.Localise["DELETE"],
							"tooltipText", string.format( ArkInventory.Localise["MENU_BAR_DELETE_TEXT"], bar_id ),
							"closeWhenClicked", true,
							"func", function( )
								ArkInventory.Frame_Bar_Remove( loc_id, bar_id )
								ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Recalculate )
							end
						)
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["MOVE"],
							"tooltipTitle", ArkInventory.Localise["MOVE"],
							"tooltipText", string.format( ArkInventory.Localise["MENU_BAR_MOVE_START_TEXT"], bar_id ),
							"disabled", ArkInventory.Global.Options.BarMoveLocation == loc_id and ArkInventory.Global.Options.BarMoveSource == bar_id,
							"closeWhenClicked", true,
							"func", function( )
								ArkInventory.Global.Options.BarMoveLocation = loc_id
								ArkInventory.Global.Options.BarMoveSource = bar_id
							end
						)
						
						if ArkInventory.Global.Options.BarMoveLocation == loc_id and ArkInventory.Global.Options.BarMoveSource ~= bar_id then
							ArkInventory.Lib.Dewdrop:AddLine(
								"text", string.format( "%s: %s", ArkInventory.Localise["MOVE"], ArkInventory.Localise["COMPLETE"] ),
								"tooltipTitle", string.format( "%s: %s", ArkInventory.Localise["MOVE"], ArkInventory.Localise["COMPLETE"] ),
								"tooltipText", string.format( ArkInventory.Localise["MENU_BAR_MOVE_COMPLETE_TEXT"], ArkInventory.Global.Options.BarMoveSource ),
								"closeWhenClicked", true,
								"func", function( )
									ArkInventory.Frame_Bar_Move( loc_id, ArkInventory.Global.Options.BarMoveSource, bar_id )
									ArkInventory.Global.Options.BarMoveLocation = nil
									ArkInventory.Global.Options.BarMoveSource = nil
									ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Recalculate )
								end
							)
						end
						
					end
					
					
					if value == "BAR_WIDTH" then
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["WIDTH"],
							"isTitle", true
						)
						
						ArkInventory.Lib.Dewdrop:AddLine( )
						
						local c = codex.layout.bar.data[bar_id].width.min
						local text = c
						if not c then
							text = ArkInventory.Localise["AUTOMATIC"]
						end
						text = string.format( ArkInventory.Localise["MENU_BAR_WIDTH_MINIMUM"], ArkInventory.Localise["MINIMUM"], text )
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", text,
							"tooltipTitle", ArkInventory.Localise["MINIMUM"],
							"tooltipText", string.format( ArkInventory.Localise["MENU_BAR_WIDTH_MINIMUM_TEXT"], bar_id ),
							"hasArrow", true,
							"hasEditBox", true,
							"editBoxText", c,
							"editBoxFunc", function( v )
								local z = math.floor( tonumber( v ) or 0 )
								if z < 1 then z = nil end
								codex.layout.bar.data[bar_id].width.min = z
								ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Recalculate )
							end
						)
						
						local c = codex.layout.bar.data[bar_id].width.max
						local text = c
						if not c then
							text = ArkInventory.Localise["AUTOMATIC"]
						end
						text = string.format( ArkInventory.Localise["MENU_BAR_WIDTH_MAXIMUM"], ArkInventory.Localise["MAXIMUM"], text )
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", text,
							"tooltipTitle", ArkInventory.Localise["MAXIMUM"],
							"tooltipText", string.format( ArkInventory.Localise["MENU_BAR_WIDTH_MAXIMUM_TEXT"], bar_id ),
							"hasArrow", true,
							"hasEditBox", true,
							"editBoxText", c,
							"editBoxFunc", function( v )
								local z = math.floor( tonumber( v ) or 0 )
								if z < 1 then z = nil end
								codex.layout.bar.data[bar_id].width.max = z
								ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Recalculate )
							end
						)
					
					end
					
				end

				
				if level == 3 and value then
				
					if strsub( value, 1, 16 ) == "CATEGORY_OPTION_" then
					
						local cat_id = string.match( value, "^CATEGORY_OPTION_(.+)" )
				
						if cat_id ~= nil then
					
							local cat = ArkInventory.Global.Category[cat_id]
							local cat_z, cat_code = ArkInventory.CategoryCodeSplit( cat.id )
							
							local cat_bar, def_bar = ArkInventory.CategoryLocationGet( loc_id, cat.id )
							if cat_bar < 0 then
								cat_bar = abs( cat_bar )
							end
							
							ArkInventory.Lib.Dewdrop:AddLine(
								"text", cat.fullname,
								"isTitle", true
							)
						
							ArkInventory.Lib.Dewdrop:AddLine( )
							
							ArkInventory.Lib.Dewdrop:AddLine(
								"text", ArkInventory.Localise["ASSIGN"],
								"tooltipTitle", ArkInventory.Localise["ASSIGN"],
								"tooltipText", string.format( ArkInventory.Localise["MENU_BAR_CATEGORY_TEXT"], string.format( "%s%s%s", LIGHTYELLOW_FONT_COLOR_CODE, cat.fullname, FONT_COLOR_CODE_CLOSE ), bar_id ),
								"disabled", bar_id == cat_bar and not def_bar,
								"closeWhenClicked", true,
								"func", function( )
									ArkInventory.CategoryLocationSet( loc_id, cat.id, bar_id )
									ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Recalculate )
								end
							)
							
							ArkInventory.Lib.Dewdrop:AddLine(
								"text", ArkInventory.Localise["MOVE"],
								"tooltipTitle", ArkInventory.Localise["MOVE"],
								"tooltipText", string.format( ArkInventory.Localise["MENU_BAR_CATEGORY_MOVE_START_TEXT"], string.format( "%s%s%s", LIGHTYELLOW_FONT_COLOR_CODE, cat.fullname, FONT_COLOR_CODE_CLOSE ) ),
								"disabled", def_bar or ( ArkInventory.Global.Options.CategoryMoveLocation == loc_id and ArkInventory.Global.Options.CategoryMoveSource == cat_bar ),
								"closeWhenClicked", true,
								"func", function( )
									ArkInventory.Global.Options.CategoryMoveLocation = loc_id
									ArkInventory.Global.Options.CategoryMoveSource = cat_bar
									ArkInventory.Global.Options.CategoryMoveCategory = cat.id
								end
							)
							
							ArkInventory.Lib.Dewdrop:AddLine(
								"text", ArkInventory.Localise["REMOVE"],
								"tooltipTitle", ArkInventory.Localise["REMOVE"],
								"tooltipText", string.format( ArkInventory.Localise["MENU_BAR_CATEGORY_REMOVE_TEXT"], string.format( "%s%s%s", LIGHTYELLOW_FONT_COLOR_CODE, cat.fullname, FONT_COLOR_CODE_CLOSE ), cat_bar ),
								"disabled", def_bar,
								"func", function( )
									ArkInventory.CategoryLocationSet( loc_id, cat_id, nil )
									ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Recalculate )
								end
							)
							
							ArkInventory.Lib.Dewdrop:AddLine(
								"text", ArkInventory.Localise["HIDE"],
								"tooltipTitle", ArkInventory.Localise["HIDE"],
								"tooltipText", ArkInventory.Localise["MENU_BAR_CATEGORY_HIDDEN_TEXT"],
								"disabled", def_bar,
								"checked", ArkInventory.CategoryHiddenCheck( loc_id, cat_id ),
								"func", function( )
									ArkInventory.CategoryHiddenToggle( loc_id, cat_id )
									ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Recalculate )
								end
							)
							
							ArkInventory.Lib.Dewdrop:AddLine( )
							
							local text = string.format( "%s* %s *%s", RED_FONT_COLOR_CODE, ArkInventory.Localise["LOCKED"], FONT_COLOR_CODE_CLOSE )
							local desc = string.format( ArkInventory.Localise["MENU_LOCKED_TEXT"], ArkInventory.Localise["CONFIG_CATEGORY_SET"], ArkInventory.Localise["CONFIG"], ArkInventory.Localise["CONTROLS"] )
							
							ArkInventory.Lib.Dewdrop:AddLine(
								"hidden", not codex.catset.system,
								"text", text,
								"tooltipTitle", text,
								"tooltipText", desc
							)
							
							local text = ArkInventory.Localise["STATUS"]
							local desc = string.format( ArkInventory.Localise["MENU_BAR_CATEGORY_STATUS"], cat.fullname )
							
							if codex.catset.category.active[cat_z][cat_code] then
								text = string.format( "%s: %s%s", text, GREEN_FONT_COLOR_CODE, ArkInventory.Localise["ENABLED"] )
								if cat.type_code == "RULE" or cat.type_code == "CUSTOM" then
									desc = string.format( ArkInventory.Localise["MENU_BAR_CATEGORY_STATUS_TEXT"], desc, ArkInventory.Localise["DISABLE"] )
								end
							else
								text = string.format( "%s: %s%s", text, RED_FONT_COLOR_CODE, ArkInventory.Localise["DISABLED"] )
								if cat.type_code == "RULE" or cat.type_code == "CUSTOM" then
									desc = string.format( ArkInventory.Localise["MENU_BAR_CATEGORY_STATUS_TEXT"], desc, ArkInventory.Localise["ENABLE"] )
								end
							end
							
							ArkInventory.Lib.Dewdrop:AddLine(
								"hidden", codex.catset.system,
								"text", text,
								"tooltipTitle", text,
								"tooltipText", desc,
								"disabled", not ( cat.type_code == "RULE" or cat.type_code == "CUSTOM" ),
								"func", function( )
									codex.catset.category.active[cat_z][cat_code] = not codex.catset.category.active[cat_z][cat_code]
									ArkInventory.ItemCacheClear( )
									ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Recalculate )
								end
							)
							
							local text = ArkInventory.Localise["CONFIG_JUNK_SELL"]
							local desc = string.format( ArkInventory.Localise["CONFIG_JUNK_CATEGORY_TEXT"], cat.fullname )
							
							if codex.catset.category.junk[cat_z][cat_code] then
								text = string.format( "%s: %s%s", text, GREEN_FONT_COLOR_CODE, ArkInventory.Localise["ENABLED"] )
								if cat.type_code == "RULE" or cat.type_code == "CUSTOM" then
									desc = string.format( ArkInventory.Localise["MENU_BAR_CATEGORY_JUNK_TEXT"], desc, ArkInventory.Localise["DISABLE"] )
								end
							else
								text = string.format( "%s: %s%s", text, RED_FONT_COLOR_CODE, ArkInventory.Localise["DISABLED"] )
								if cat.type_code == "RULE" or cat.type_code == "CUSTOM" then
									desc = string.format( ArkInventory.Localise["MENU_BAR_CATEGORY_JUNK_TEXT"], desc, ArkInventory.Localise["ENABLE"] )
								end
							end
							
							ArkInventory.Lib.Dewdrop:AddLine(
								"hidden", codex.catset.system,
								"text", text,
								"tooltipTitle", text,
								"tooltipText", desc,
								"disabled", not ( cat.type_code == "RULE" or cat.type_code == "CUSTOM" ),
								"func", function( )
									codex.catset.category.junk[cat_z][cat_code] = not codex.catset.category.junk[cat_z][cat_code]
								end
							)
							
						end
						
					end

					if strsub( value, 1, 11 ) == "BAG_OPTION_" then
					
						local bag_id = tonumber( string.match( value, "^BAG_OPTION_(.+)" ) )
						
						if bag_id ~= nil then
							
							ArkInventory.Lib.Dewdrop:AddLine(
								"text", string.format( "%s > %s", ArkInventory.Localise["BAG"], bag_id ),
								"isTitle", true
							)
							
							ArkInventory.Lib.Dewdrop:AddLine( )
							
							local cv = codex.layout.bag[bag_id].bar
							
							ArkInventory.Lib.Dewdrop:AddLine(
								"text", ArkInventory.Localise["REMOVE"],
								"tooltipTitle", ArkInventory.Localise["REMOVE"],
--								"tooltipText", string.format( ArkInventory.Localise["MENU_BAR_CATEGORY_REMOVE_TEXT"], cat.fullname, bar_id ),
								"func", function( )
									codex.layout.bag[bag_id].bar = nil
									ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Recalculate )
								end
							)
							
						end
						
					end
					
				end
				
			end
			
		)
		
	end
	
end

function ArkInventory.MenuItemOpen( frame )
	
	assert( frame, "code error: frame argument is missing" )
	
	if ArkInventory.Global.Mode.Edit == false then
		return
	end
	
	if ArkInventory.Lib.Dewdrop:IsOpen( frame ) then
	
		ArkInventory.Lib.Dewdrop:Close( )
		
	else
		
		local loc_id = frame.ARK_Data.loc_id
		local bag_id = frame.ARK_Data.bag_id
		local blizzard_id = ArkInventory.InternalIdToBlizzardBagId( loc_id, bag_id )
		local slot_id = frame.ARK_Data.slot_id
		local codex = ArkInventory.GetLocationCodex( loc_id )
		local i = ArkInventory.Frame_Item_GetDB( frame )
		local info = ArkInventory.ObjectInfoArray( i.h, i )
		
		local isEmpty = false
		if not i or i.h == nil then
			isEmpty = true
		end
		
		
		local x, p, rp
		x = frame:GetLeft( ) + ( frame:GetRight( ) - frame:GetLeft( ) ) / 2
		if ( x >= ( GetScreenWidth( ) / 2 ) ) then
			p = "TOPRIGHT"
			rp = "TOPLEFT"
		else
			p = "TOPLEFT"
			rp = "TOPRIGHT"
		end
		
		local ic = select( 5, ArkInventory.GetItemQualityColor( i.q ) )
		local itemname = string.format( "%s%s%s", ic, info.name or "", FONT_COLOR_CODE_CLOSE )
		
		local cat0, cat1, cat2 = ArkInventory.ItemCategoryGet( i )
		local bar_id = abs( ArkInventory.CategoryLocationGet( loc_id, cat0 ) )
		
		local categories = { "SYSTEM", "CONSUMABLE", "TRADEGOODS", "SKILL", "CLASS", "EMPTY", "CUSTOM", }
		
		cat0 = ArkInventory.Global.Category[cat0] or cat0
		if type( cat0 ) ~= "table" then
			cat0 = { id = cat0, fullname = string.format( ArkInventory.Localise["CONFIG_OBJECT_DELETED"], ArkInventory.Localise["CONFIG_CATEGORY"], cat0 ) }
		end
		
		if cat1 then
			cat1 = ArkInventory.Global.Category[cat1] or cat1
			if type( cat1 ) ~= "table" then
				cat1 = { id = cat1, fullname = string.format( ArkInventory.Localise["CONFIG_OBJECT_DELETED"], ArkInventory.Localise["CONFIG_CATEGORY"], cat1 ) }
			end
		end
		
		cat2 = ArkInventory.Global.Category[cat2] or cat2
		if type( cat2 ) ~= "table" then
			cat2 = { id = cat2, fullname = string.format( ArkInventory.Localise["CONFIG_OBJECT_DELETED"], ArkInventory.Localise["CONFIG_CATEGORY"], cat2 ) }
		end
		
		ArkInventory.Lib.Dewdrop:Open( frame,
			"point", p,
			"relativePoint", rp,
			"children", function( level, value )
			
				if level == 1 then

					ArkInventory.Lib.Dewdrop:AddLine(
						"text", string.format( "%s:", ArkInventory.Localise["MENU_ITEM_TITLE"] ),
						"isTitle", true
					)
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", string.format( "%s: %s", ArkInventory.Localise["ITEM"], itemname )
					)
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					if cat1 then
					
						-- item has a category, that means it's been specifically assigned away from the default
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", string.format( "%s: %s%s%s", ArkInventory.Localise["CURRENT"], GREEN_FONT_COLOR_CODE, cat1.fullname, FONT_COLOR_CODE_CLOSE ),
							"notClickable", true
						)
						
						ArkInventory.Lib.Dewdrop:AddLine( )
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", string.format( "%s: %s%s%s", ArkInventory.Localise["DEFAULT"], LIGHTYELLOW_FONT_COLOR_CODE, cat2.fullname, FONT_COLOR_CODE_CLOSE ),
							"tooltipTitle", ArkInventory.Localise["MENU_ITEM_DEFAULT_RESET"],
							"tooltipText", ArkInventory.Localise["MENU_ITEM_DEFAULT_RESET_TEXT"],
							"closeWhenClicked", true,
							"func", function( )
								ArkInventory.ItemCategorySet( i, nil )
								ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Recalculate )
							end
						)
					
					else
					
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", string.format( "%s: %s%s%s", ArkInventory.Localise["DEFAULT"], LIGHTYELLOW_FONT_COLOR_CODE, cat2.fullname, FONT_COLOR_CODE_CLOSE ),
							"notClickable", true
						)
					
					end
					
					if not codex.style.window.list then
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", string.format( "%s:", ArkInventory.Localise["MENU_ITEM_ASSIGN_CHOICES"] ),
						"isTitle", true
					)
					
					if codex.catset.system then
						
						local text = string.format( "%s* %s *%s", RED_FONT_COLOR_CODE, ArkInventory.Localise["LOCKED"], FONT_COLOR_CODE_CLOSE )
						local desc = string.format( ArkInventory.Localise["MENU_LOCKED_TEXT"], ArkInventory.Localise["CONFIG_CATEGORY_SET"], ArkInventory.Localise["CONFIG"], ArkInventory.Localise["CONTROLS"] )
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", text,
							"tooltipTitle", text,
							"tooltipText", desc
						)
						
					else
						
						for _, v in ipairs( categories ) do
							ArkInventory.Lib.Dewdrop:AddLine(
								"text", ArkInventory.Localise[string.format( "CATEGORY_%s", v )],
								"disabled", isEmpty,
								"hasArrow", true,
								"value", string.format( "CATEGORY_ASSIGN_%s", v )
							)
						end
						
					end
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					if codex.layout.system then
						
						local text = string.format( "%s* %s *%s", RED_FONT_COLOR_CODE, ArkInventory.Localise["LOCKED"], FONT_COLOR_CODE_CLOSE )
						local desc = string.format( ArkInventory.Localise["MENU_LOCKED_TEXT"], ArkInventory.Localise["CONFIG_LAYOUT"], ArkInventory.Localise["CONFIG"], ArkInventory.Localise["CONTROLS"] )
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", text,
							"tooltipTitle", text,
							"tooltipText", desc
						)
					
					else
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["MOVE"],
						"tooltipTitle", ArkInventory.Localise["MOVE"],
						"tooltipText", string.format( ArkInventory.Localise["MENU_BAR_CATEGORY_MOVE_START_TEXT"], string.format( "%s%s%s", LIGHTYELLOW_FONT_COLOR_CODE, cat0.fullname, FONT_COLOR_CODE_CLOSE ) ),
						"disabled", ArkInventory.Global.Options.CategoryMoveLocation == loc_id and ArkInventory.Global.Options.CategoryMoveSource ==  bar_id,
						"closeWhenClicked", true,
						"func", function( )
							ArkInventory.Global.Options.CategoryMoveLocation = loc_id
							ArkInventory.Global.Options.CategoryMoveSource = bar_id
							ArkInventory.Global.Options.CategoryMoveCategory = cat0.id
						end
					)
					
					if ArkInventory.Global.Options.CategoryMoveLocation == loc_id and ArkInventory.Global.Options.CategoryMoveSource ~= bar_id then
						
						local cat = ArkInventory.Global.Category[ArkInventory.Global.Options.CategoryMoveCategory]
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", string.format( "%s: %s", ArkInventory.Localise["MOVE"], ArkInventory.Localise["COMPLETE"] ),
							"tooltipTitle", string.format( "%s: %s", ArkInventory.Localise["MOVE"], ArkInventory.Localise["COMPLETE"] ),
							"tooltipText", string.format( ArkInventory.Localise["MENU_BAR_CATEGORY_MOVE_COMPLETE_TEXT"], string.format( "%s%s%s", LIGHTYELLOW_FONT_COLOR_CODE, cat.fullname, FONT_COLOR_CODE_CLOSE ), ArkInventory.Global.Options.CategoryMoveSource, bar_id ),
							"closeWhenClicked", true,
							"func", function( )
								ArkInventory.CategoryLocationSet( loc_id, cat.id, bar_id )
								ArkInventory.Global.Options.CategoryMoveLocation = nil
								ArkInventory.Global.Options.CategoryMoveSource = nil
								ArkInventory.Global.Options.CategoryMoveCategory = nil
								ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Recalculate )
							end
						)
						
					end
					
					end
					
					end
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["DEBUG"],
						"hasArrow", true,
						"value", "DEBUG_INFO"
					)
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["CLOSE_MENU"],
						"closeWhenClicked", true
					)
					
				end
				
				
				if level == 2 and value then
					
					if value == "DEBUG_INFO" then
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["DEBUG"],
							"isTitle", true
						)
						
						local bagtype = ArkInventory.Const.Slot.Data[ArkInventory.BagType( blizzard_id )].type
						
						ArkInventory.Lib.Dewdrop:AddLine( )
						
						ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s (%s)", ArkInventory.Localise["LOCATION"], LIGHTYELLOW_FONT_COLOR_CODE, loc_id, ArkInventory.Global.Location[loc_id].Name ) )
						ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s (%s)", ArkInventory.Localise["BAG"], LIGHTYELLOW_FONT_COLOR_CODE, bag_id, blizzard_id ) )
						ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s (%s)", ArkInventory.Localise["SLOT"], LIGHTYELLOW_FONT_COLOR_CODE, slot_id, bagtype ) )
						--ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s", "sort key", ArkInventory.ItemSortKeyGenerate( i, bar_id ) ) )
						
						ArkInventory.Lib.Dewdrop:AddLine( )
						
						ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s", ArkInventory.Localise["CATEGORY_CLASS"], LIGHTYELLOW_FONT_COLOR_CODE, info.class ) )
						
						ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s", ArkInventory.Localise["NAME"], LIGHTYELLOW_FONT_COLOR_CODE, info.name or "" ) )
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", string.format( "%s: %s%s", ArkInventory.Localise["MENU_ITEM_DEBUG_ITEMSTRING"], LIGHTYELLOW_FONT_COLOR_CODE, info.osd.h ),
							"hasArrow", true,
							"hasEditBox", true,
							"editBoxText", info.osd.h
						)
						
						if i.h then
							
							if info.class == "item" then
								
								ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s (%s)", ITEM_SOULBOUND, LIGHTYELLOW_FONT_COLOR_CODE, i.sb, ArkInventory.Localise[string.format( "ITEM_BIND%s", i.sb or ArkInventory.Const.Bind.Never )] ) )
								
								ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s (%s)", QUALITY, LIGHTYELLOW_FONT_COLOR_CODE, info.q, _G[string.format( "ITEM_QUALITY%s_DESC", info.q )] ) )
								
								ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s", ArkInventory.Localise["MENU_ITEM_DEBUG_LVL_ITEM"], LIGHTYELLOW_FONT_COLOR_CODE, info.ilvl ) )
								ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s", ArkInventory.Localise["MENU_ITEM_DEBUG_LVL_USE"], LIGHTYELLOW_FONT_COLOR_CODE, info.uselevel ) )
								
								if info.osd.sourceid > 0 then
									ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s", ArkInventory.Localise["MENU_ITEM_DEBUG_SOURCE"], LIGHTYELLOW_FONT_COLOR_CODE, info.osd.sourceid ) )
								end
								
								if info.osd.bonusids then
									local tmp = { }
									for k in pairs( info.osd.bonusids ) do
										table.insert( tmp, k )
									end
									ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s", ArkInventory.Localise["MENU_ITEM_DEBUG_BONUS"], LIGHTYELLOW_FONT_COLOR_CODE, table.concat( tmp, ", " ) ) )
								end
								
								ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s (%s)", ArkInventory.Localise["TYPE"], LIGHTYELLOW_FONT_COLOR_CODE, info.itemtypeid, info.itemtype ) )
								ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s (%s)", ArkInventory.Localise["MENU_ITEM_DEBUG_SUBTYPE"], LIGHTYELLOW_FONT_COLOR_CODE, info.itemsubtypeid, info.itemsubtype ) )
								

								if info.equiploc ~= "" then
									local iloc = _G[info.equiploc]
									if iloc then
										ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s", ArkInventory.Localise["EQUIP"], LIGHTYELLOW_FONT_COLOR_CODE, iloc ) )
									end
								end
								
								ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s", AUCTION_STACK_SIZE, LIGHTYELLOW_FONT_COLOR_CODE, info.stacksize ) )
								ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s", ArkInventory.Localise["TEXTURE"], LIGHTYELLOW_FONT_COLOR_CODE, info.texture ) )
								
								local ifam = GetItemFamily( i.h ) or 0
								ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s", ArkInventory.Localise["MENU_ITEM_DEBUG_FAMILY"], LIGHTYELLOW_FONT_COLOR_CODE, ifam ) )
								
							end
							
						end
						
						ArkInventory.Lib.Dewdrop:AddLine( )
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", string.format( "%s: %s%s", ArkInventory.Localise["MENU_ITEM_DEBUG_AI_ID_SHORT"], LIGHTYELLOW_FONT_COLOR_CODE, info.id ),
							"hasArrow", true,
							"hasEditBox", true,
							"editBoxText", info.id
						)
						
						ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s", ArkInventory.Localise["CATEGORY"], LIGHTYELLOW_FONT_COLOR_CODE, cat0.id ) )
						
						local cid = ArkInventory.ObjectIDCategory( i )
						ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s (%s): %s%s", ArkInventory.Localise["MENU_ITEM_DEBUG_CACHE"], ArkInventory.Localise["CATEGORY"], LIGHTYELLOW_FONT_COLOR_CODE, cid ) )
						
						cid = ArkInventory.ObjectIDRule( i )
						ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s (%s): %s%s", ArkInventory.Localise["MENU_ITEM_DEBUG_CACHE"], ArkInventory.Localise["RULE"], LIGHTYELLOW_FONT_COLOR_CODE, cid ) )
						
						if i.h then
							if info.class == "item" then
								
								ArkInventory.Lib.Dewdrop:AddLine( )
								ArkInventory.Lib.Dewdrop:AddLine(
									"text", ArkInventory.Localise["MENU_ITEM_DEBUG_PT"],
									"hasArrow", true,
									"tooltipTitle", ArkInventory.Localise["MENU_ITEM_DEBUG_PT"],
									"tooltipText", ArkInventory.Localise["MENU_ITEM_DEBUG_PT_TEXT"],
									"value", "DEBUG_INFO_PT"
								)
								
							end
						end
						
					end
					
					if strsub( value, 1, 16 ) == "CATEGORY_ASSIGN_" then
						
						local k = string.match( value, "CATEGORY_ASSIGN_(.+)" )
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise[string.format( "CATEGORY_%s", k )],
							"isTitle", true
						)
						
						ArkInventory.Lib.Dewdrop:AddLine( )
					
						for _, cat in ArkInventory.spairs( ArkInventory.Global.Category, function(a,b) return ArkInventory.Global.Category[a].sort_order < ArkInventory.Global.Category[b].sort_order end ) do
				
							local t = cat.type_code
							local cat_bar, def_bar = ArkInventory.CategoryLocationGet( loc_id, cat.id )
							local icon = ""
							
							if cat.id == cat0.id then
								t = "DO_NOT_USE"
							end
							
							if k == t then
								
								local cat_z, cat_code = ArkInventory.CategoryCodeSplit( cat.id )
								
								local c1 = ""
								
								if not def_bar then
									c1 = LIGHTYELLOW_FONT_COLOR_CODE
								end
								
								if not codex.catset.category.active[cat_z][cat_code] then
									c1 = RED_FONT_COLOR_CODE
								end
								
								if codex.catset.category.junk[cat_z][cat_code] then
									icon = [[Interface\Icons\INV_Misc_Coin_02]]
								end
								
								local n = string.format( "%s%s", c1, cat.name )
								
								local c2 = GREEN_FONT_COLOR_CODE
								
								if cat_bar < 0 then
									c2 = RED_FONT_COLOR_CODE
								end
								
								if not def_bar then
									n = string.format( "%s %s[%s]", n, c2, abs( cat_bar ) )
								end
								
								ArkInventory.Lib.Dewdrop:AddLine(
									"text", n,
									"tooltipTitle", ArkInventory.Localise["MENU_ITEM_ASSIGN_THIS"],
									"tooltipText", string.format( ArkInventory.Localise["MENU_ITEM_ASSIGN_THIS_TEXT"], itemname, cat.fullname ),
									"icon", icon,
									"hasArrow", true,
									"value", string.format( "CATEGORY_CURRENT_OPTION_%s", cat.id ),
									"closeWhenClicked", true,
									"func", function( )
										ArkInventory.ItemCategorySet( i, cat.id )
										ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Recalculate )
									end
								)
							
							end
							
						end
						
						if k == "CUSTOM" then
						
							ArkInventory.Lib.Dewdrop:AddLine( )
							
							ArkInventory.Lib.Dewdrop:AddLine(
								"text", ArkInventory.Localise["MENU_ITEM_CUSTOM_NEW"],
								"closeWhenClicked", true,
								"func", function( )
									ArkInventory.Frame_Config_Show( "category_custom" )
								end
							)
							
						end
						
					end
					
				end
				
				
				if level == 3 and value then
					
					if value == "DEBUG_INFO_PT" then
					
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", string.format( "%s: ", ArkInventory.Localise["MENU_ITEM_DEBUG_PT_TITLE"] ),
							"isTitle", true
						)
						
						ArkInventory.Lib.Dewdrop:AddLine( )
						
						--local pt_set = ArkInventory.Lib.PeriodicTable:ItemSearch( i.h )
						local pt_set = ArkInventory.PTItemSearch( i.h )
						
						if not pt_set then
						
							ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s%s", LIGHTYELLOW_FONT_COLOR_CODE, ArkInventory.Localise["MENU_ITEM_DEBUG_PT_NONE"] ) )
						
						else
						
							for k, v in pairs( pt_set ) do
								ArkInventory.Lib.Dewdrop:AddLine(
									"text", v,
									"hasArrow", true,
									"hasEditBox", true,
									"editBoxText", v
								)
							end
							
						end
						
					end
				
					if strsub( value, 1, 24 ) == "CATEGORY_CURRENT_OPTION_" then
					
						local cat_id = string.match( value, "^CATEGORY_CURRENT_OPTION_(.+)" )
				
						if cat_id ~= nil then
					
							local cat = ArkInventory.Global.Category[cat_id]
							local cat_z, cat_code = ArkInventory.CategoryCodeSplit( cat.id )
							
							local cat_bar, def_bar = ArkInventory.CategoryLocationGet( loc_id, cat.id )
							if cat_bar < 0 then
								cat_bar = abs( cat_bar )
							end
							
							ArkInventory.Lib.Dewdrop:AddLine(
								"text", cat.fullname,
								"isTitle", true
							)
							
							ArkInventory.Lib.Dewdrop:AddLine( )
							
							ArkInventory.Lib.Dewdrop:AddLine(
								"text", ArkInventory.Localise["ASSIGN"],
								"tooltipTitle", ArkInventory.Localise["ASSIGN"],
								"tooltipText", string.format( ArkInventory.Localise["MENU_ITEM_ASSIGN_THIS_TEXT"], itemname, cat.fullname ),
								"disabled", bar_id == cat_bar and not def_bar,
								"closeWhenClicked", true,
								"func", function( )
									ArkInventory.ItemCategorySet( i, cat.id )
									ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Recalculate )
								end
							)
							
							ArkInventory.Lib.Dewdrop:AddLine(
								"text", ArkInventory.Localise["MOVE"],
								"tooltipTitle", ArkInventory.Localise["MOVE"],
								"tooltipText", string.format( ArkInventory.Localise["MENU_BAR_CATEGORY_MOVE_START_TEXT"], string.format( "%s%s%s", LIGHTYELLOW_FONT_COLOR_CODE, cat.fullname, FONT_COLOR_CODE_CLOSE ) ),
								"disabled", def_bar or ( ArkInventory.Global.Options.CategoryMoveLocation == loc_id and ArkInventory.Global.Options.CategoryMoveSource == cat_bar ),
								"closeWhenClicked", true,
								"func", function( )
									ArkInventory.Global.Options.CategoryMoveLocation = loc_id
									ArkInventory.Global.Options.CategoryMoveSource = cat_bar
									ArkInventory.Global.Options.CategoryMoveCategory = cat.id
								end
							)
							
							ArkInventory.Lib.Dewdrop:AddLine(
								"text", ArkInventory.Localise["REMOVE"],
								"tooltipTitle", ArkInventory.Localise["REMOVE"],
								"tooltipText", string.format( ArkInventory.Localise["MENU_BAR_CATEGORY_REMOVE_TEXT"], cat.fullname, cat_bar ),
								"disabled", def_bar,
								"func", function( )
									ArkInventory.CategoryLocationSet( loc_id, cat_id, nil )
									ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Recalculate )
								end
							)
						
							ArkInventory.Lib.Dewdrop:AddLine(
								"text", ArkInventory.Localise["HIDE"],
								"tooltipTitle", ArkInventory.Localise["HIDE"],
								"tooltipText", ArkInventory.Localise["MENU_BAR_CATEGORY_HIDDEN_TEXT"],
								"disabled", def_bar,
								"checked", ArkInventory.CategoryHiddenCheck( loc_id, cat_id ),
								"func", function( )
									ArkInventory.CategoryHiddenToggle( loc_id, cat_id )
									ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Recalculate )
								end
							)
							
							ArkInventory.Lib.Dewdrop:AddLine( )
							
							local text = ArkInventory.Localise["STATUS"]
							local desc = string.format( ArkInventory.Localise["MENU_BAR_CATEGORY_STATUS"], cat.fullname )
							
							if codex.catset.category.active[cat_z][cat_code] then
								text = string.format( "%s: %s%s", text, GREEN_FONT_COLOR_CODE, ArkInventory.Localise["ENABLED"] )
								if cat.type_code == "RULE" or cat.type_code == "CUSTOM" then
									desc = string.format( ArkInventory.Localise["MENU_BAR_CATEGORY_STATUS_TEXT"], desc, ArkInventory.Localise["DISABLE"] )
								end
							else
								text = string.format( "%s: %s%s", text, RED_FONT_COLOR_CODE, ArkInventory.Localise["DISABLED"] )
								if cat.type_code == "RULE" or cat.type_code == "CUSTOM" then
									desc = string.format( ArkInventory.Localise["MENU_BAR_CATEGORY_STATUS_TEXT"], desc, ArkInventory.Localise["ENABLE"] )
								end
							end
							
							ArkInventory.Lib.Dewdrop:AddLine(
								"hidden", codex.catset.system,
								"text", text,
								"tooltipTitle", text,
								"tooltipText", desc,
								"disabled", not ( cat.type_code == "RULE" or cat.type_code == "CUSTOM" ),
								"func", function( )
									codex.catset.category.active[cat_z][cat_code] = not codex.catset.category.active[cat_z][cat_code]
									ArkInventory.ItemCacheClear( )
									ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Recalculate )
								end
							)
							
							local text = ArkInventory.Localise["CONFIG_JUNK_SELL"]
							local desc = string.format( ArkInventory.Localise["CONFIG_JUNK_CATEGORY_TEXT"], cat.fullname )
							
							if codex.catset.category.junk[cat_z][cat_code] then
								text = string.format( "%s: %s%s", text, GREEN_FONT_COLOR_CODE, ArkInventory.Localise["ENABLED"] )
								if cat.type_code == "RULE" or cat.type_code == "CUSTOM" then
									desc = string.format( ArkInventory.Localise["MENU_BAR_CATEGORY_JUNK_TEXT"], desc, ArkInventory.Localise["DISABLE"] )
								end
							else
								text = string.format( "%s: %s%s", text, RED_FONT_COLOR_CODE, ArkInventory.Localise["DISABLED"] )
								if cat.type_code == "RULE" or cat.type_code == "CUSTOM" then
									desc = string.format( ArkInventory.Localise["MENU_BAR_CATEGORY_JUNK_TEXT"], desc, ArkInventory.Localise["ENABLE"] )
								end
							end
							
							ArkInventory.Lib.Dewdrop:AddLine(
								"hidden", codex.catset.system,
								"text", text,
								"tooltipTitle", text,
								"tooltipText", desc,
								"disabled", not ( cat.type_code == "RULE" or cat.type_code == "CUSTOM" ),
								"func", function( )
									codex.catset.category.junk[cat_z][cat_code] = not codex.catset.category.junk[cat_z][cat_code]
								end
							)
							
						end
						
					end

				end
				
			end
			
		)
		
	end
	
end


function ArkInventory.MenuBagOpen( frame )
	
	assert( frame, "code error: frame argument is missing" )
	
	if ArkInventory.Lib.Dewdrop:IsOpen( frame ) then
		
		ArkInventory.Lib.Dewdrop:Close( )
		
	else
		
		local loc_id = frame.ARK_Data.loc_id
		local bag_id = frame.ARK_Data.bag_id
		local blizzard_id = ArkInventory.InternalIdToBlizzardBagId( loc_id, bag_id )
		local codex = ArkInventory.GetLocationCodex( loc_id )
		local player_id = codex.player.data.info.player_id
		
		local i = ArkInventory.Frame_Item_GetDB( frame )
		local info = ArkInventory.ObjectInfoArray( i.h, i )
		
		local isEmpty = false
		if not ( blizzard_id == BACKPACK_CONTAINER or blizzard_id == BANK_CONTAINER ) then
			if not i or i.h == nil then
				isEmpty = true
			end
		end
		
		local bag = codex.player.data.location[loc_id].bag[bag_id]
		
		local x, p, rp
		x = frame:GetLeft( ) + ( frame:GetRight( ) - frame:GetLeft( ) ) / 2
		if ( x >= ( GetScreenWidth( ) / 2 ) ) then
			p = "BOTTOMRIGHT" -- TOPRIGHT
			rp = "TOPLEFT" -- BOTTOMLEFT
		else
			p = "BOTTOMLEFT" -- TOPLEFT
			rp = "TOPRIGHT" -- BOTTOMRIGHT
		end
		
		ArkInventory.Lib.Dewdrop:Open( frame,
			"point", p,
			"relativePoint", rp,
			"children", function( level, value )
				
				if level == 1 then
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["OPTIONS"],
						"icon", ArkInventory.Const.Actions[ArkInventory.Const.ActionID.EditMode].Texture,
						"isTitle", true
					)
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["DISPLAY"],
						"tooltipTitle", ArkInventory.Localise["DISPLAY"],
						"tooltipText", ArkInventory.Localise["MENU_BAG_SHOW_TEXT"],
						"checked", codex.player.data.option[loc_id].bag[bag_id].display,
						"closeWhenClicked", true,
						"func", function( )
							codex.player.data.option[loc_id].bag[bag_id].display = not codex.player.data.option[loc_id].bag[bag_id].display
							ArkInventory.Frame_Main_Generate( loc_id, ArkInventory.Const.Window.Draw.Recalculate )
						end
					)
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["MENU_BAG_ISOLATE"],
						"tooltipTitle", ArkInventory.Localise["MENU_BAG_ISOLATE"],
						"tooltipText", ArkInventory.Localise["MENU_BAG_ISOLATE_TEXT"],
						"closeWhenClicked", true,
						"func", function( )
							for x in pairs( ArkInventory.Global.Location[loc_id].Bags ) do
								if x == bag_id then
									codex.player.data.option[loc_id].bag[x].display = true
								else
									codex.player.data.option[loc_id].bag[x].display = false
								end
							end
							ArkInventory.Frame_Main_Generate( loc_id, ArkInventory.Const.Window.Draw.Recalculate )
						end
					)
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["MENU_BAG_SHOWALL"],
						"tooltipTitle", ArkInventory.Localise["MENU_BAG_SHOWALL"],
						"tooltipText", ArkInventory.Localise["MENU_BAG_SHOWALL_TEXT"],
						"closeWhenClicked", true,
						"func", function( )
							for x in pairs( ArkInventory.Global.Location[loc_id].Bags ) do
								codex.player.data.option[loc_id].bag[x].display = true
							end
							ArkInventory.Frame_Main_Generate( loc_id, ArkInventory.Const.Window.Draw.Recalculate )
						end
					)
					
					if not isEmpty then
						
						ArkInventory.Lib.Dewdrop:AddLine( )
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["EMPTY"],
							"tooltipTitle", ArkInventory.Localise["EMPTY"],
							"tooltipText", ArkInventory.Localise["MENU_BAG_EMPTY_TEXT"],
							"closeWhenClicked", true,
							"func", function( )
								ArkInventory.EmptyBag( loc_id, bag_id )
							end
						)
						
					end
					
					
					if not ArkInventory.Global.Mode.Edit and loc_id == ArkInventory.Const.Location.Bank and bag.status == ArkInventory.Const.Bag.Status.Purchase then
						
						local numSlots = GetNumBankSlots( )
						local cost = GetBankSlotCost( numSlots )
						
						ArkInventory.Lib.Dewdrop:AddLine( )
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", BANKSLOTPURCHASE,
							"tooltipTitle", BANK_BAG,
							"tooltipText", string.format( "%s\n\n%s %s", BANKSLOTPURCHASE_LABEL, COSTS_LABEL, ArkInventory.MoneyText( cost, true ) ),
							"closeWhenClicked", true,
							"func", function( )
								PlaySound( SOUNDKIT.IG_MAINMENU_OPTION )
								StaticPopup_Show( "CONFIRM_BUY_BANK_SLOT" )
							end
						)
						
					end
					
					if ArkInventory.Global.Mode.Edit and not isEmpty then
						
						ArkInventory.Lib.Dewdrop:AddLine( )
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["DEBUG"],
							"hasArrow", true,
							"value", "DEBUG_INFO"
						)
						
					end
					
					if loc_id == ArkInventory.Const.Location.Bag or loc_id == ArkInventory.Const.Location.Bank then
						
						if loc_id == ArkInventory.Const.Location.Bag then
							
							ArkInventory.Lib.Dewdrop:AddLine( )
							
							ArkInventory.Lib.Dewdrop:AddLine(
								"text", REVERSE_NEW_LOOT_TEXT,
								"tooltipTitle", REVERSE_NEW_LOOT_TEXT,
								"tooltipText", OPTION_TOOLTIP_REVERSE_NEW_LOOT,
								"checked", GetInsertItemsLeftToRight( ),
								"closeWhenClicked", true,
								"func", function( )
									SetInsertItemsLeftToRight( not GetInsertItemsLeftToRight( ) )
									-- its a bit slow to update so close the menu?
								end
							)
							
						end
						
						if blizzard_id > 0 then
							
							ArkInventory.Lib.Dewdrop:AddLine( )
							
							ArkInventory.Lib.Dewdrop:AddLine(
								"text", BAG_FILTER_ASSIGN_TO,
								"isTitle", true
							)
							
							for i = LE_BAG_FILTER_FLAG_EQUIPMENT, NUM_LE_BAG_FILTER_FLAGS do
								
								if ( i ~= LE_BAG_FILTER_FLAG_JUNK ) then
									
									local checked = false
									
									if loc_id == ArkInventory.Const.Location.Bag then
										
										checked = GetBagSlotFlag( blizzard_id, i )
										
									elseif loc_id == ArkInventory.Const.Location.Bank then
										
										if bag_id == 1 then
											checked = GetBankBagSlotFlag( blizzard_id - NUM_BAG_SLOTS, i )
										else
											checked = GetBagSlotFlag( blizzard_id, i )
										end
										
									end
									
								end
								
							end
							
						end
						
						ArkInventory.Lib.Dewdrop:AddLine( )
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"icon", ArkInventory.Const.Actions[ArkInventory.Const.ActionID.Restack].Texture,
							"text", ArkInventory.Const.Actions[ArkInventory.Const.ActionID.Restack].Name,
							"isTitle", true
						)
						
						local checked = false
						
						if loc_id == ArkInventory.Const.Location.Bag then
							
							if bag_id == 1 then
								checked = GetBackpackAutosortDisabled( )
							else
								checked = GetBagSlotFlag( blizzard_id, LE_BAG_FILTER_FLAG_IGNORE_CLEANUP )
							end
							
						elseif loc_id == ArkInventory.Const.Location.Bank then
							
							if bag_id == 1 then
								checked = GetBankAutosortDisabled( )
							else
								checked = GetBankBagSlotFlag( blizzard_id - NUM_BAG_SLOTS, LE_BAG_FILTER_FLAG_IGNORE_CLEANUP )
							end
							
						end
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", BAG_FILTER_IGNORE,
							"tooltipTitle", ArkInventory.Localise["RESTACK"],
							"tooltipText", BAG_FILTER_IGNORE,
							"checked", checked,
							"closeWhenClicked", true,
							"func", function( )
								
								if loc_id == ArkInventory.Const.Location.Bag then
									
									if bag_id == 1 then
										SetBackpackAutosortDisabled( not checked )
									else
										SetBagSlotFlag( blizzard_id, LE_BAG_FILTER_FLAG_IGNORE_CLEANUP, not checked )
									end
									
								elseif loc_id == ArkInventory.Const.Location.Bank then
									
									if bag_id == 1 then
										SetBankAutosortDisabled( not checked )
									else
										SetBankBagSlotFlag( blizzard_id - NUM_BAG_SLOTS, LE_BAG_FILTER_FLAG_IGNORE_CLEANUP, not checked )
									end
									
								end
								
							end
						)
						
					end
					
				end
				
				if level == 2 and value then
					
					if value == "DEBUG_INFO" then
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["DEBUG"],
							"isTitle", true
						)
							
						
						ArkInventory.Lib.Dewdrop:AddLine( )
						
						ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s", ArkInventory.Localise["NAME"], LIGHTYELLOW_FONT_COLOR_CODE, info.name ) )
						
						ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s (%s)", ArkInventory.Localise["LOCATION"], LIGHTYELLOW_FONT_COLOR_CODE, loc_id, ArkInventory.Global.Location[loc_id].Name ) )
						
						ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s", ArkInventory.Localise["CATEGORY_CLASS"], LIGHTYELLOW_FONT_COLOR_CODE, info.class ) )

						ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s (%s)", QUALITY, LIGHTYELLOW_FONT_COLOR_CODE, info.q, _G[string.format( "ITEM_QUALITY%s_DESC", info.q )] ) )
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", string.format( "%s: %s%s", ArkInventory.Localise["MENU_ITEM_DEBUG_AI_ID_SHORT"], LIGHTYELLOW_FONT_COLOR_CODE, info.id ),
							"hasArrow", true,
							"hasEditBox", true,
							"editBoxText", info.id
						)
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", string.format( "%s: %s%s (%s)", ArkInventory.Localise["TYPE"], LIGHTYELLOW_FONT_COLOR_CODE, info.itemtypeid, info.itemtype ),
							"hasArrow", true,
							"hasEditBox", true,
							"editBoxText", info.itemtypeid
						)
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", string.format( "%s: %s%s (%s)", ArkInventory.Localise["MENU_ITEM_DEBUG_SUBTYPE"], LIGHTYELLOW_FONT_COLOR_CODE, info.itemsubtypeid, info.itemsubtype ),
							"hasArrow", true,
							"hasEditBox", true,
							"editBoxText", info.itemsubtypeid
						)
						
						ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s", ArkInventory.Localise["TEXTURE"], LIGHTYELLOW_FONT_COLOR_CODE, info.texture ) )
						
						local ifam = GetItemFamily( i.h ) or 0
						ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s", ArkInventory.Localise["MENU_ITEM_DEBUG_FAMILY"], LIGHTYELLOW_FONT_COLOR_CODE, ifam ) )
						
					end

				end

			end
			
		)
		
	end
	
end


function ArkInventory.MenuSwitchLocation( frame, level, value, offset )
	
	assert( frame, "code error: frame argument is missing" )
	
	ArkInventory.Lib.Dewdrop:AddLine(
		"icon", ArkInventory.Const.Actions[ArkInventory.Const.ActionID.SwitchLocation].Texture,
		"text", ArkInventory.Const.Actions[ArkInventory.Const.ActionID.SwitchLocation].Name,
		"isTitle", true
	)
	
	ArkInventory.Lib.Dewdrop:AddLine( )
	
	if level == offset + 1 then
	
		for loc_id, loc_data in ArkInventory.spairs( ArkInventory.Global.Location ) do
			if loc_data.canView then
				ArkInventory.Lib.Dewdrop:AddLine(
					"text", loc_data.Name,
					"tooltipTitle", loc_data.Name,
					"tooltipText", string.format( ArkInventory.Localise["MENU_LOCATION_SWITCH_TEXT"], loc_data.Name ),
					"icon", loc_data.Texture,
					"closeWhenClicked", true,
					"func", function( )
						ArkInventory.Frame_Main_Toggle( loc_id )
					end
				)
			end
		end
		
	end
	
end

function ArkInventory.MenuSwitchLocationOpen( frame )

	assert( frame, "code error: frame argument is missing" )

	if ArkInventory.Lib.Dewdrop:IsOpen( frame ) then
	
		ArkInventory.Lib.Dewdrop:Close( )
	
	else

		local x, p, rp
		x = frame:GetLeft( ) + ( frame:GetRight( ) - frame:GetLeft( ) ) / 2
		if ( x >= ( GetScreenWidth( ) / 2 ) ) then
			p = "TOPRIGHT"
			rp = "BOTTOMLEFT"
		else
			p = "TOPLEFT"
			rp = "BOTTOMRIGHT"
		end
	
		ArkInventory.Lib.Dewdrop:Open( frame,
			"point", p,
			"relativePoint", rp,
			"children", function( level, value )
			
				ArkInventory.MenuSwitchLocation( frame, level, value, 0 )
				
				if level == 1 then
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["CLOSE_MENU"],
						"closeWhenClicked", true
					)
					
				end
				
			end
		)

	end
	
end

function ArkInventory.MenuSwitchCharacter( frame, level, value, offset )
	
	assert( frame, "code error: frame argument is missing" )
	
	local loc_id = frame:GetParent( ):GetParent( ).ARK_Data.loc_id
	local codex = ArkInventory.GetLocationCodex( loc_id )
	
	if level == offset + 1 then
		
		local count = 0
		local realms = { }
		
		ArkInventory.Lib.Dewdrop:AddLine(
			"icon", ArkInventory.Const.Actions[ArkInventory.Const.ActionID.SwitchCharacter].Texture,
			"text", ArkInventory.Const.Actions[ArkInventory.Const.ActionID.SwitchCharacter].Name,
			"isTitle", true
		)
		
		ArkInventory.Lib.Dewdrop:AddLine( )
		
		ArkInventory.Lib.Dewdrop:AddLine(
			"text", codex.player.data.info.realm,
			"notClickable", true
		)
		
		local show
		
		for n, tp in ArkInventory.spairs( ArkInventory.db.player.data, function( a, b ) return ( a < b ) end ) do
			
			show = true
			
			if tp.location[loc_id].slot_count == 0 then
				show = false
			elseif tp.info.realm ~= codex.player.data.info.realm then
				show = false
				realms[tp.info.realm] = true
			end
			
			if show then
				
				count = count + 1
				ArkInventory.Lib.Dewdrop:AddLine(
					"text", ArkInventory.DisplayName4( tp.info, codex.player.data.info.faction ),
					--"tooltipTitle", "",
					--"tooltipText", "",
					"hasArrow", true,
					"isRadio", true,
					"checked", codex.player.data.info.player_id == tp.info.player_id,
					"closeWhenClicked", true,
					"func", function( )
						ArkInventory.Frame_Main_Show( loc_id, tp.info.player_id )
					end,
					"value", string.format( "SWITCH_CHARACTER_ERASE_%s", tp.info.player_id )
				)
				
			end
			
		end
		
		if count == 0 then
			
			ArkInventory.Lib.Dewdrop:AddLine(
				"text", "no data availale",
				"disabled", true
			)
			
		end

		if not ArkInventory.Table.IsEmpty( realms ) then
			
			table.sort( realms )
			
			ArkInventory.Lib.Dewdrop:AddLine( )
			
			for k in ArkInventory.spairs( realms, function( a, b ) return ( a < b ) end ) do
			
				ArkInventory.Lib.Dewdrop:AddLine(
					"text", k,
					--"tooltipTitle", "",
					--"tooltipText", "",
					"hasArrow", true,
					--"isRadio", true,
					--"checked", codex.player.data.info.player_id == tp.info.player_id,
					--"notClickable", codex.player.data.info.player_id == tp.info.player_id,
					--"closeWhenClicked", true,
					"value", string.format( "SWITCH_CHARACTER_REALM_%s", k )
				)
				
			end
			
		end
		
	end
	
	
	if level > offset + 1 and value then
		
		local realm = string.match( value, "^SWITCH_CHARACTER_REALM_(.+)" )
		if realm then
			
			local count = 0
			
			for n, tp in ArkInventory.spairs( ArkInventory.db.player.data, function( a, b ) return a < b end ) do
				
				local show = true
				
				if tp.location[loc_id].slot_count == 0 or tp.info.realm ~= realm then
					show = false
				end
				
				if show then
					
					count = count + 1
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.DisplayName4( tp.info, codex.player.data.info.faction ),
						--"tooltipTitle", "",
						--"tooltipText", "",
						"hasArrow", true,
						"isRadio", true,
						"checked", codex.player.data.info.player_id == tp.info.player_id,
						--"notClickable", codex.player.data.info.player_id == tp.info.player_id,
						"closeWhenClicked", true,
						"func", function( )
							ArkInventory.Frame_Main_Show( loc_id, tp.info.player_id )
						end,
						"value", string.format( "SWITCH_CHARACTER_ERASE_%s", tp.info.player_id )
					)
					
				end
				
			end
			
			
			if count == 0 then
			
				ArkInventory.Lib.Dewdrop:AddLine(
					"text", "no data availale",
					"disabled", true
				)
				
			end
			
		end
		
		local player_id = string.match( value, "^SWITCH_CHARACTER_ERASE_(.+)" )
		if player_id then
			
			local tp = ArkInventory.GetPlayerStorage( player_id )
			
			ArkInventory.Lib.Dewdrop:AddLine(
				"text", ArkInventory.DisplayName4( tp.data.info, codex.player.data.info.faction ),
				"isTitle", true
			)
			
			ArkInventory.Lib.Dewdrop:AddLine( )
			
			ArkInventory.Lib.Dewdrop:AddLine(
				"text", string.format( ArkInventory.Localise["MENU_CHARACTER_SWITCH_ERASE"], ArkInventory.Global.Location[loc_id].Name ),
				"tooltipTitle", string.format( ArkInventory.Localise["MENU_CHARACTER_SWITCH_ERASE"], ArkInventory.Global.Location[loc_id].Name ),
				"tooltipText", string.format( "%s%s", RED_FONT_COLOR_CODE, string.format( ArkInventory.Localise["MENU_CHARACTER_SWITCH_ERASE_TEXT"], ArkInventory.Global.Location[loc_id].Name, ArkInventory.DisplayName1( tp.data.info ) ) ),
				"closeWhenClicked", true,
				"func", function( )
					ArkInventory.Frame_Main_Hide( loc_id )
					ArkInventory.EraseSavedData( tp.data.info.player_id, loc_id )
				end
			)
			
			ArkInventory.Lib.Dewdrop:AddLine(
				"text", string.format( ArkInventory.Localise["MENU_CHARACTER_SWITCH_ERASE"], ArkInventory.Localise["ALL"] ),
				"tooltipTitle", string.format( ArkInventory.Localise["MENU_CHARACTER_SWITCH_ERASE"], ArkInventory.Localise["ALL"] ),
				"tooltipText", string.format( "%s%s", RED_FONT_COLOR_CODE, string.format( ArkInventory.Localise["MENU_CHARACTER_SWITCH_ERASE_TEXT"], ArkInventory.Localise["ALL"], ArkInventory.DisplayName1( tp.data.info ) ) ),
				"closeWhenClicked", true,
				"func", function( )
					ArkInventory.Frame_Main_Hide( )
					ArkInventory.EraseSavedData( tp.data.info.player_id )
				end
			)
		
		end
		
	end

end

function ArkInventory.MenuSwitchCharacterOpen( frame )
	
	assert( frame, "code error: frame argument is missing" )
	
	if ArkInventory.Lib.Dewdrop:IsOpen( frame ) then
		
		ArkInventory.Lib.Dewdrop:Close( )
		
	else
		
		local x, p, rp
		x = frame:GetLeft( ) + ( frame:GetRight( ) - frame:GetLeft( ) ) / 2
		if ( x >= ( GetScreenWidth( ) / 2 ) ) then
			p = "TOPRIGHT"
			rp = "BOTTOMLEFT"
		else
			p = "TOPLEFT"
			rp = "BOTTOMRIGHT"
		end
		
		ArkInventory.Lib.Dewdrop:Open( frame,
			"point", p,
			"relativePoint", rp,
			"children", function( level, value )
				
				ArkInventory.MenuSwitchCharacter( frame, level, value, 0 )
				
				if level == 1 then
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["CLOSE_MENU"],
						"closeWhenClicked", true
					)
					
				end
				
			end
			
		)
		
	end
	
end

function ArkInventory.MenuLDBBagsOpen( frame )
	
	assert( frame, "code error: frame argument is missing" )
	
	local codex = ArkInventory.GetPlayerCodex( )
	
	if ArkInventory.Lib.Dewdrop:IsOpen( frame ) then
	
		ArkInventory.Lib.Dewdrop:Close( )
	
	else
		
		local x, p, rp
		x = frame:GetBottom( ) + ( frame:GetTop( ) - frame:GetBottom( ) ) / 2
		if ( x >= ( GetScreenHeight( ) / 2 ) ) then
			p = "TOPLEFT"
			rp = "BOTTOMLEFT"
		else
			p = "BOTTOMLEFT"
			rp = "TOPLEFT"
		end
		
		ArkInventory.Lib.Dewdrop:Open( frame,
			"point", p,
			"relativePoint", rp,
			"children", function( level, value )
				
				if level == 1 then
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Const.Program.Name,
						"isTitle", true
					)
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Global.Version,
						"notClickable", true
					)
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["CONFIG"],
						"closeWhenClicked", true,
						"func", function( )
							ArkInventory.Frame_Config_Show( )
						end
					)
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["MENU_ACTION"],
						"hasArrow", true,
						"value", "ACTIONS"
					)
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["MENU_LOCATION_SWITCH"],
						"hasArrow", true,
						"value", "LOCATION"
					)
						
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["FONT"],
						"hasArrow", true,
						"value", "FONT"
					)
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["LDB"],
						"hasArrow", true,
						"value", "LDB"
					)
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["CLOSE_MENU"],
						"closeWhenClicked", true
					)
					
				end
				
				
				if level == 2 and value then
				
					if value == "LOCATION" then
						ArkInventory.MenuSwitchLocation( frame, level, value, 1 )
					end
					
					if value == "FONT" then
					
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["FONT"],
							"isTitle", true
						)
						
						for _, face in pairs( ArkInventory.Lib.SharedMedia:List( "font" ) ) do
							ArkInventory.Lib.Dewdrop:AddLine(
								"text", face,
								"tooltipTitle", ArkInventory.Localise["FONT"],
								"tooltipText", string.format( ArkInventory.Localise["CONFIG_GENERAL_FONT_TEXT"], face ),
								"checked", face == ArkInventory.db.option.font.face,
								"func", function( )
									ArkInventory.db.option.font.face = face
									ArkInventory.MediaAllFontSet( face )
								end
							)
						end
						
					end
					
					if value == "ACTIONS" then
					
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["MENU_ACTION"],
							"isTitle", true
						)
						
						for k, v in pairs( ArkInventory.Const.Actions ) do
							if v.LDB then
								ArkInventory.Lib.Dewdrop:AddLine(
									"text", v.Name,
									"closeWhenClicked", true,
									"icon", v.Texture,
									"func", function( )
										v.Scripts.OnClick( nil, nil )
									end
								)
							end
						end
						
					end
					
					if value == "LDB" then
					
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["LDB"],
							"isTitle", true
						)
						
						ArkInventory.Lib.Dewdrop:AddLine( )
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["LDB_BAGS_COLOUR_USE"],
							"tooltipTitle", ArkInventory.Localise["LDB_BAGS_COLOUR_USE"],
							"tooltipText", ArkInventory.Localise["LDB_BAGS_COLOUR_USE_TEXT"],
							"checked", codex.player.data.ldb.bags.colour,
							"func", function( )
								codex.player.data.ldb.bags.colour = not codex.player.data.ldb.bags.colour
								ArkInventory.LDB.Bags:Update( )
							end
						)
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["LDB_BAGS_STYLE"],
							"tooltipTitle", ArkInventory.Localise["LDB_BAGS_STYLE"],
							"tooltipText", ArkInventory.Localise["LDB_BAGS_STYLE_TEXT"],
							"checked", codex.player.data.ldb.bags.full,
							"func", function( )
								codex.player.data.ldb.bags.full = not codex.player.data.ldb.bags.full
								ArkInventory.LDB.Bags:Update( )
							end
						)
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["LDB_BAGS_INCLUDE_TYPE"],
							"tooltipTitle", ArkInventory.Localise["LDB_BAGS_INCLUDE_TYPE"],
							"tooltipText", ArkInventory.Localise["LDB_BAGS_INCLUDE_TYPE_TEXT"],
							"checked", codex.player.data.ldb.bags.includetype,
							"func", function( )
								codex.player.data.ldb.bags.includetype = not codex.player.data.ldb.bags.includetype
								ArkInventory.LDB.Bags:Update( )
							end
						)
						
					end
					
					
				end
				
			end
			
		)
	
	end
	
end

function ArkInventory.MenuLDBTrackingItemOpen( frame )
	
	assert( frame, "code error: frame argument is missing" )
	
	local codex = ArkInventory.GetPlayerCodex( )
	
	if ArkInventory.Lib.Dewdrop:IsOpen( frame ) then
		
		ArkInventory.Lib.Dewdrop:Close( )
		
	else
		
		local x, p, rp
		x = frame:GetBottom( ) + ( frame:GetTop( ) - frame:GetBottom( ) ) / 2
		if ( x >= ( GetScreenHeight( ) / 2 ) ) then
			p = "TOPLEFT"
			rp = "BOTTOMLEFT"
		else
			p = "BOTTOMLEFT"
			rp = "TOPLEFT"
		end
		
		ArkInventory.Lib.Dewdrop:Open( frame,
			"point", p,
			"relativePoint", rp,
			"children", function( level, value )
				
				if level == 1 then
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.LDB.Tracking_Item.name,
						"isTitle", true
					)
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Global.Version,
						"notClickable", true
					)
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["CLOSE_MENU"],
						"closeWhenClicked", true
					)
					
				end
				
				
				if level == 2 and value and value > 0 then
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", string.format( "%s%s%s", RED_FONT_COLOR_CODE, ArkInventory.Localise["REMOVE"], FONT_COLOR_CODE_CLOSE ),
						"tooltipTitle", ArkInventory.Localise["REMOVE"],
						--"tooltipText", "",
						"func", function( )
							ArkInventory.db.option.tracking.items[value] = nil
							codex.player.data.ldb.tracking.item.tracked[value] = false
							ArkInventory.LDB.Tracking_Item:Update( )
						end
					)

				end
				
			end
			
		)
	
	end
	
end

function ArkInventory.MenuRestackOpen( frame )
	
	assert( frame, "code error: frame argument is missing" )

	if ArkInventory.Lib.Dewdrop:IsOpen( frame ) then
		
		ArkInventory.Lib.Dewdrop:Close( )
		
	else
		
		local x, p, rp
		x = frame:GetBottom( ) + ( frame:GetTop( ) - frame:GetBottom( ) ) / 2
		if ( x >= ( GetScreenHeight( ) / 2 ) ) then
			p = "TOPLEFT"
			rp = "BOTTOMLEFT"
		else
			p = "BOTTOMLEFT"
			rp = "TOPLEFT"
		end
	
		ArkInventory.Lib.Dewdrop:Open( frame,
			"point", p,
			"relativePoint", rp,
			"children", function( level, value )
				
				if level == 1 then
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"icon", ArkInventory.Const.Actions[ArkInventory.Const.ActionID.Restack].Texture,
						"text", ArkInventory.Const.Actions[ArkInventory.Const.ActionID.Restack].Name,
						"isTitle", true
					)
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["TYPE"],
						"hasArrow", true,
						"value", "TYPE"
					)
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["OPTIONS"],
						"hasArrow", true,
						"value", "OPTIONS"
					)
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
				elseif level == 2 then
					
					if value == "TYPE" then
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["TYPE"],
							"isTitle", true
						)
						
						ArkInventory.Lib.Dewdrop:AddLine( )
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", string.format( "%s: %s", ArkInventory.Localise["BLIZZARD"], ArkInventory.Localise["CLEANUP"] ),
							"tooltipTitle", ArkInventory.Localise["BLIZZARD"],
							"tooltipText", ArkInventory.Localise["RESTACK_TYPE"],
							"isRadio", true,
							"checked", ArkInventory.db.option.restack.blizzard,
							--"closeWhenClicked", true,
							"func", function( )
								ArkInventory.db.option.restack.blizzard = true
							end
						)
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", string.format( "%s: %s", ArkInventory.Const.Program.Name, ArkInventory.Localise["RESTACK"] ),
							"tooltipTitle", ArkInventory.Const.Program.Name,
							"tooltipText", ArkInventory.Localise["RESTACK_TYPE"],
							"isRadio", true,
							"checked", not ArkInventory.db.option.restack.blizzard,
							--"closeWhenClicked", true,
							"func", function( )
								ArkInventory.db.option.restack.blizzard = false
							end
						)
						
					end
					
					if value == "OPTIONS" then
						
						local txt = ""
						if ArkInventory.db.option.restack.blizzard then
							txt = string.format( "%s: %s", ArkInventory.Localise["BLIZZARD"], ArkInventory.Localise["CLEANUP"] )
						else
							txt = string.format( "%s: %s", ArkInventory.Const.Program.Name, ArkInventory.Localise["RESTACK"] )
						end
						txt = string.format( "%s - %s", ArkInventory.Localise["OPTIONS"], txt )
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", txt,
							"isTitle", true
						)
						
						ArkInventory.Lib.Dewdrop:AddLine( )
						
						if ArkInventory.db.option.restack.blizzard then
							
						else
							
							ArkInventory.Lib.Dewdrop:AddLine(
								"text", ArkInventory.Localise["RESTACK_TOPUP_FROM_BAGS"],
								"tooltipTitle", ArkInventory.Localise["RESTACK_TOPUP_FROM_BAGS"],
								"tooltipText", ArkInventory.Localise["RESTACK_TOPUP_FROM_BAGS_TEXT"],
								"checked", ArkInventory.db.option.restack.topup,
								--"closeWhenClicked", true,
								"func", function( )
									ArkInventory.db.option.restack.topup = not ArkInventory.db.option.restack.topup
								end
							)
							
							ArkInventory.Lib.Dewdrop:AddLine(
								"text", string.format( "%s (%s)", REAGENTBANK_DEPOSIT, ArkInventory.Localise["BANK"] ),
								"tooltipTitle", string.format( "%s (%s)", REAGENTBANK_DEPOSIT, ArkInventory.Localise["BANK"] ),
								"tooltipText", string.format( ArkInventory.Localise["RESTACK_FILL_FROM_BAGS_TEXT"], ArkInventory.Localise["BANK"], ArkInventory.Localise["BACKPACK"] ),
								"checked", ArkInventory.db.option.restack.bank,
								--"closeWhenClicked", true,
								"func", function( )
									ArkInventory.db.option.restack.bank = not ArkInventory.db.option.restack.bank
								end
							)
							
--[[
							ArkInventory.Lib.Dewdrop:AddLine(
								"text", ArkInventory.Localise["RESTACK_REFRESH_WHEN_COMPLETE"],
								"tooltipTitle", ArkInventory.Localise["RESTACK_REFRESH_WHEN_COMPLETE"],
								--"tooltipText", ArkInventory.Localise["RESTACK_REFRESH_WHEN_COMPLETE_TEXT"],
								"checked", ArkInventory.db.option.restack.refresh,
								--"closeWhenClicked", true,
								"func", function( )
									ArkInventory.db.option.restack.refresh = not ArkInventory.db.option.restack.refresh
								end
							)
]]--
							
						end
						
					end
					
				end
				
				ArkInventory.Lib.Dewdrop:AddLine( )
				
				ArkInventory.Lib.Dewdrop:AddLine(
					"text", ArkInventory.Localise["CLOSE_MENU"],
					"closeWhenClicked", true
				)
				
			end
			
		)
	
	end
	
end

function ArkInventory.MenuRefreshOpen( frame )
	
	assert( frame, "code error: frame argument is missing" )

	local loc_id = frame:GetParent( ):GetParent( ).ARK_Data.loc_id
	local codex = ArkInventory.GetLocationCodex( loc_id )
	
	if ArkInventory.Lib.Dewdrop:IsOpen( frame ) then
		
		ArkInventory.Lib.Dewdrop:Close( )
		
	else
		
		local x, p, rp
		x = frame:GetBottom( ) + ( frame:GetTop( ) - frame:GetBottom( ) ) / 2
		if ( x >= ( GetScreenHeight( ) / 2 ) ) then
			p = "TOPLEFT"
			rp = "BOTTOMLEFT"
		else
			p = "BOTTOMLEFT"
			rp = "TOPLEFT"
		end
	
		ArkInventory.Lib.Dewdrop:Open( frame,
			"point", p,
			"relativePoint", rp,
			"children", function( level, value )
				
				if level == 1 then
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"icon", ArkInventory.Const.Actions[ArkInventory.Const.ActionID.Refresh].Texture,
						"text", ArkInventory.Const.Actions[ArkInventory.Const.ActionID.Refresh].Name,
						"isTitle", true
					)
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", string.format( "%s: %s", ArkInventory.Localise["CONFIG_DESIGN_ITEM_NEW"], ArkInventory.Localise["RESET"] ),
						"tooltipTitle", ArkInventory.Localise["CONFIG_DESIGN_ITEM_NEW_RESET_TEXT"],
						"closeWhenClicked", true,
						"func", function( )
							ArkInventory.Global.NewItemResetTime = ArkInventory.TimeAsMinutes( )
							ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Recalculate )
						end
					)
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", string.format( "%s: %s", ArkInventory.Localise["ITEMS"], ArkInventory.Localise["CONFIG_DESIGN_ITEM_HIDDEN"] ),
						"tooltipTitle", ArkInventory.Localise["CONFIG_DESIGN_ITEM_HIDDEN_TEXT"],
						"closeWhenClicked", true,
						"checked", ArkInventory.Global.Options.ShowHiddenItems,
						"func", function( )
							ArkInventory.ToggleShowHiddenItems( )
						end
					)
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", string.format( "%s: %s", ArkInventory.Localise["ITEMS"], ArkInventory.Localise["MENU_ACTION_REFRESH_CLEAR_CACHE"] ),
						"tooltipTitle", ArkInventory.Localise["MENU_ACTION_REFRESH_CLEAR_CACHE_TEXT"],
						"closeWhenClicked", true,
						"func", function( )
							ArkInventory.ItemCacheClear( )
						end
					)
					
					
					
					
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["CLOSE_MENU"],
						"closeWhenClicked", true
					)
					
				end
				
			end
			
		)
	
	end
	
end
