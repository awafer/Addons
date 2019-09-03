local _G = _G
local select = _G.select
local pairs = _G.pairs
local ipairs = _G.ipairs
local string = _G.string
local type = _G.type
local error = _G.error
local table = _G.table


local function helper_CategoryRenumber( cat_old, cat_new )
	
	-- fix hard coded item assignments
	
	if ArkInventory.acedb.global.option.cateset then
		for k, v in pairs( ArkInventory.acedb.global.option.cateset.data ) do
			for k2, v2 in pairs( v.category.assign ) do
				if v2 == cat_old then
					v.category.assign[k2] = cat_new
				end
			end
		end
	end
	
end

local function helper_SystemCleanupPreLoad( ARKINVDBCLASSIC )
	
	if ARKINVDBCLASSIC and ARKINVDBCLASSIC.global and ARKINVDBCLASSIC.global.option then
		
		-- delete system entries so that they get pulled from defaults again, plus it clears anything that may have been left hanging around
		
		-- profiles (not the ace ones)
		if ARKINVDBCLASSIC.global.option.profile and ARKINVDBCLASSIC.global.option.profile.data  then
			for k, v in pairs( ARKINVDBCLASSIC.global.option.profile.data ) do
				v.wipeonreload = nil
				if k >= 9000 then
					ARKINVDBCLASSIC.global.option.profile.data[k] = nil
				end
			end
		end
		
		-- designs
		if ARKINVDBCLASSIC.global.option.design and ARKINVDBCLASSIC.global.option.design.data then
			for k, v in pairs( ARKINVDBCLASSIC.global.option.design.data ) do
				v.wipeonreload = nil
				if k >= 9000 then
					ARKINVDBCLASSIC.global.option.design.data[k] = nil
				end
			end
		end
		
		-- categorysets
		if ARKINVDBCLASSIC.global.option.catset and ARKINVDBCLASSIC.global.option.catset.data then
			for k, v in pairs( ARKINVDBCLASSIC.global.option.catset.data ) do
				v.wipeonreload = nil
				if k >= 9000 then
					ARKINVDBCLASSIC.global.option.catset.data[k] = nil
				end
			end
		end
		
		-- sort methods
		if ARKINVDBCLASSIC.global.option.sort and ARKINVDBCLASSIC.global.option.sort.method and ARKINVDBCLASSIC.global.option.sort.method.data then
			for k, v in pairs( ARKINVDBCLASSIC.global.option.sort.method.data ) do
				v.wipeonreload = nil
				if k >= 9000 then
					ARKINVDBCLASSIC.global.option.sort.method.data[k] = nil
				end
			end
		end
		
		-- system categories
		if ARKINVDBCLASSIC.global.option.category then
			ARKINVDBCLASSIC.global.option.category[ArkInventory.Const.Category.Type.System] = nil
		end
		
	end
	
end

function ArkInventory.DatabaseUpgradePreLoad( )
	
	ARKINVDBCLASSIC = ARKINVDBCLASSIC or { }
	
	if ArkInventory.Const.Program.Version >= 3.0227 then
		-- erase old factionrealm data
		if ARKINVDBCLASSIC.factionrealm then
			ARKINVDBCLASSIC.factionrealm = nil
		end
	end
	
	
	if ArkInventory.Const.Program.Version >= 30334 then
		
		ARKINVDBCLASSIC.global = ARKINVDBCLASSIC.global or { }
		ARKINVDBCLASSIC.global.player = ARKINVDBCLASSIC.global.player or { }
		ARKINVDBCLASSIC.global.player.data = ARKINVDBCLASSIC.global.player.data or { }
		
		if ARKINVDBCLASSIC.global.option and ARKINVDBCLASSIC.global.option.sort and ARKINVDBCLASSIC.global.option.sort.data then
			ARKINVDBCLASSIC.global.option.sort.method = { }
			ARKINVDBCLASSIC.global.option.sort.method.data = ARKINVDBCLASSIC.global.option.sort.data
			ARKINVDBCLASSIC.global.option.sort.data = nil
		end
		
		if ARKINVDBCLASSIC.realm then
			-- move realm into global
			
			for r, v1 in pairs( ARKINVDBCLASSIC.realm ) do
				
				if v1.player and v1.player.data then
					
					for n, v2 in pairs( v1.player.data ) do
						
						if string.sub( n, 1, 1 ) ~= "!" then
							
							local k = string.format( "%s%s%s", n, ArkInventory.Const.PlayerIDSep, r )
							ARKINVDBCLASSIC.global.player.data[k] = v2
							ARKINVDBCLASSIC.global.player.data[k].location = nil
							ARKINVDBCLASSIC.global.player.data[k].version = v1.player.version or ArkInventory.Const.Program.Version
							
							ARKINVDBCLASSIC.global.player.data[k].info = { }
							
							local i = ARKINVDBCLASSIC.global.player.data[k].info
							i.player_id = k
							i.guild_id = nil
							if i.guild then
								i.guild_id = string.format( "%s%s%s%s", ArkInventory.Const.GuildTag, i.guild, ArkInventory.Const.PlayerIDSep, r )
							end
							i.guild = nil
							
						end
						
					end
					
				end
				
			end
		
			ARKINVDBCLASSIC.realm = nil
		
		end
		
		if ARKINVDBCLASSIC.char then
			-- move char into global
			
			for k, v in pairs( ARKINVDBCLASSIC.char ) do
				
				ARKINVDBCLASSIC.global.player.data[k] = ARKINVDBCLASSIC.global.player.data[k] or { }
				
				if v.option and v.option.ldb then
					ARKINVDBCLASSIC.global.player.data[k].ldb = v.option.ldb
					ARKINVDBCLASSIC.global.player.data[k].ldb.version = v.option.version
				end
				
				ARKINVDBCLASSIC.global.player.data[k].ldb = ARKINVDBCLASSIC.global.player.data[k].ldb or { }
				ARKINVDBCLASSIC.global.player.data[k].ldb.version = ARKINVDBCLASSIC.global.player.data[k].ldb.version or ArkInventory.Const.Program.Version
				
			end
			
			ARKINVDBCLASSIC.char = nil
			
		end
		
	end
	
	
	helper_SystemCleanupPreLoad( ARKINVDBCLASSIC )
	
end


local function helper_UpgradeProfile( profile, profile_name )
	
	local upgrade_version
	
	if not profile.option then
		profile.option = { }
	end
	
	if not profile.option.version then
		profile.option.version = ArkInventory.Const.Program.Version
	end
	
	if profile.option.version >= 30699 then
		return
	end
	
	
	upgrade_version = 3.00
	if profile.option.version < upgrade_version then
	
		ArkInventory.Output( string.format( ArkInventory.Localise["UPGRADE_PROFILE"], profile_name, upgrade_version ) )
		
		if profile.option.category then
			for k, v in pairs( profile.option.category ) do
				if type( v ) == "number" then
					profile.option.category[k] = ArkInventory.CategoryCodeJoin( ArkInventory.Const.Category.Type.System, abs( v ) )
				end
			end
		end
		
		if profile.option.location then
			
			local t
			for _, loc in pairs( profile.option.location ) do
			
				t = { }
				
				if loc.category then
					
					for k, v in pairs( loc.category ) do
						if type( k ) == "number" then
							if k < 0 then
								local id = ArkInventory.CategoryCodeJoin( ArkInventory.Const.Category.Type.System, abs( k ) )
								t[id] = v
							else
								local id = ArkInventory.CategoryCodeJoin( ArkInventory.Const.Category.Type.Rule, k )
								t[id] = v
							end
							loc.category[k] = nil
						end
					end
					
					for k, v in pairs( t ) do
						loc.category[k] = v
					end
					
				end
				
			end
			
		end
		
		
		profile.option.version = upgrade_version
		
	end

	
	upgrade_version = 3.0201
	if profile.option.version < upgrade_version then
		
		ArkInventory.Output( string.format( ArkInventory.Localise["UPGRADE_PROFILE"], profile_name, upgrade_version ) )
		
		-- fix categories, need to add class
		if profile.option.category then
			
			local t = { }
			
			for k, v in pairs( profile.option.category ) do
				
				local sb, id = strsplit( ":", k )
				id = tonumber( id ) or 0
				sb = tonumber( sb ) or 0
				if sb > 20 then
					local z = sb
					sb = id
					id = z
				end
				
				local class = "item"
				if id == 0 then
					class = "empty"
				end
				
				local cid = string.format( "%s:%s:%s", class, id, sb )
				--ArkInventory.OutputDebug( "k=[", k, "], id=[", id, "], sb=[", sb, "], cid=[", cid, "] / [", v, "]" )
				t[cid] = v
				
			end
			
			profile.option.category = t
			
		end
		
		
		profile.option.version = upgrade_version
		
	end
	
	
	upgrade_version = 3.0230
	if profile.option.version < upgrade_version then
		
		ArkInventory.Output( string.format( ArkInventory.Localise["UPGRADE_PROFILE"], profile_name, upgrade_version ) )
		
		ArkInventory.OutputWarning( "The sort order for each location has been reset to bag/slot as it couldnt be automatically transferred. You will need to create an equivalent sort method (via the config menu) to what you had and apply that to each location" )
		
		if profile.option.location then
			
			for _, v in pairs( profile.option.location ) do
				
				if v.window then
				
					if v.window.border then
						v.window.border.style = ArkInventory.Const.Texture.BorderDefault
						v.window.border.size = nil
						v.window.border.offset = nil
						v.window.border.scale = 1
						v.window.border.file = nil
					end
					
					if v.window.colour then
					
						if v.window.colour.border then
							v.window.border = v.window.border or { }
							v.window.border.colour = v.window.border.colour or { }
							v.window.border.colour.r = v.window.colour.border.r or v.window.border.colour.r
							v.window.border.colour.g = v.window.colour.border.g or v.window.border.colour.g
							v.window.border.colour.b = v.window.colour.border.b or v.window.border.colour.b
							v.window.colour.border = nil
						end
						
						if v.window.colour.background then
							v.window.background = v.window.background or { }
							v.window.background.colour = v.window.background.colour or { }
							v.window.background.colour.r = v.window.colour.background.r or v.window.background.colour.r
							v.window.background.colour.g = v.window.colour.background.g or v.window.background.colour.g
							v.window.background.colour.b = v.window.colour.background.b or v.window.background.colour.b
							v.window.background.colour.a = v.window.colour.background.a or v.window.background.colour.a
							v.window.colour.background = nil
						end
						
						if v.window.colour.baghighlight then
							v.changer = v.changer or { }
							v.changer.highlight = v.changer.highlight or { }
							v.changer.highlight.colour = v.changer.highlight.colour or { }
							v.changer.highlight.colour.r = v.window.colour.baghighlight.r or v.changer.highlight.colour.r
							v.changer.highlight.colour.g = v.window.colour.baghighlight.g or v.changer.highlight.colour.g
							v.changer.highlight.colour.b = v.window.colour.baghighlight.b or v.changer.highlight.colour.b
							v.window.colour.baghighlight = nil
						end
					
					end
					
					v.window.colour = nil
					
				end
				
				if v.bar then
					
					if v.bar.name and v.bar.name.label then
						for id, label in pairs( v.bar.name.label ) do
							v.bar.data = v.bar.data or { }
							v.bar.data[id] = v.bar.data[id] or { }
							v.bar.data[id].label = label
						end
						v.bar.name.label = nil
					end
					
					if v.bar.border then
						v.bar.border.style = ArkInventory.Const.Texture.BorderDefault
						v.bar.border.size = nil
						v.bar.border.offset = nil
						v.bar.border.scale = 1
						v.bar.border.file = nil
					end
				
					if v.bar.colour then
						
						if v.bar.colour.border then
							v.bar.border = v.bar.border or { }
							v.bar.border.colour = v.bar.border.colour or { }
							v.bar.border.colour.r = v.bar.colour.border.r or v.bar.border.colour.r
							v.bar.border.colour.g = v.bar.colour.border.g or v.bar.border.colour.g
							v.bar.border.colour.b = v.bar.colour.border.b or v.bar.border.colour.b
							v.bar.colour.border = nil
						end
						
						if v.bar.colour.background then
							v.bar.background = v.bar.background or { }
							v.bar.background.colour = v.bar.background.colour or { }
							v.bar.background.colour.r =  v.bar.colour.background.r or v.bar.background.colour.r
							v.bar.background.colour.g = v.bar.colour.background.g or v.bar.background.colour.g
							v.bar.background.colour.b = v.bar.colour.background.b or v.bar.background.colour.b
							v.bar.background.colour.a = v.bar.colour.background.a or v.bar.background.colour.a
							v.bar.colour.background = nil
						end
					
					end
					
					v.bar.colour = nil
					
				end
				
				if v.slot then
				
					if v.slot.border then
						v.slot.border.style = ArkInventory.Const.Texture.BorderDefault
						v.slot.border.size = nil
						v.slot.border.offset = nil
						v.slot.border.scale = 1
						v.slot.border.file = nil
					end
				
					if v.slot.empty then
						v.slot.empty.colour = nil
						v.slot.empty.display = nil
						v.slot.empty.show = nil
					end
				
				end
				
				v.sortorder = nil
				
				if v.sort then
					wipe( v.sort )
				end
				
			end
			
		end
		
		if profile.option.ui then
			
			if profile.option.ui.search then
				
				if profile.option.ui.search.border then
					profile.option.ui.search.border.style = ArkInventory.Const.Texture.BorderDefault
					profile.option.ui.search.border.size = nil
					profile.option.ui.search.border.offset = nil
					profile.option.ui.search.border.scale = 1
					profile.option.ui.search.border.file = nil
				end
				
				if profile.option.ui.search.colour then
					
					if profile.option.ui.search.colour.border then
						profile.option.ui.search.border = profile.option.ui.search.border or { }
						profile.option.ui.search.border.colour = profile.option.ui.search.border.colour or { }
						profile.option.ui.search.border.colour.r = profile.option.ui.search.colour.border.r or profile.option.ui.search.border.colour.r
						profile.option.ui.search.border.colour.g = profile.option.ui.search.colour.border.g or profile.option.ui.search.border.colour.g
						profile.option.ui.search.border.colour.b = profile.option.ui.search.colour.border.b or profile.option.ui.search.border.colour.b
						profile.option.ui.search.colour.border = nil
					end
					
					if profile.option.ui.search.colour.background then
						profile.option.ui.search.background = profile.option.ui.search.background or { }
						profile.option.ui.search.background.colour = profile.option.ui.search.background.colour or { }
						profile.option.ui.search.background.colour.r = profile.option.ui.search.colour.background.r or profile.option.ui.search.background.colour.r
						profile.option.ui.search.background.colour.g = profile.option.ui.search.colour.background.g or profile.option.ui.search.background.colour.g
						profile.option.ui.search.background.colour.b = profile.option.ui.search.colour.background.b or profile.option.ui.search.background.colour.b
						profile.option.ui.search.background.colour.a = profile.option.ui.search.colour.background.a or profile.option.ui.search.background.colour.a
						profile.option.ui.search.colour.background = nil
					end
					
				end
				
			end
		
			if profile.option.ui.rules then
			
				if profile.option.ui.rules.border then
					profile.option.ui.rules.border.style = ArkInventory.Const.Texture.BorderDefault
					profile.option.ui.rules.border.size = nil
					profile.option.ui.rules.border.offset = nil
					profile.option.ui.rules.border.scale = 1
					profile.option.ui.rules.border.file = nil
				end
				
				if profile.option.ui.rules.colour then
					
					if profile.option.ui.rules.colour.border then
						profile.option.ui.rules.border = profile.option.ui.rules.border or { }
						profile.option.ui.rules.border.colour = profile.option.ui.rules.border.colour or { }
						profile.option.ui.rules.border.colour.r = profile.option.ui.rules.colour.border.r or profile.option.ui.rules.border.colour.r
						profile.option.ui.rules.border.colour.g = profile.option.ui.rules.colour.border.g or profile.option.ui.rules.border.colour.g
						profile.option.ui.rules.border.colour.b = profile.option.ui.rules.colour.border.b or profile.option.ui.rules.border.colour.b
						profile.option.ui.rules.colour.border = nil
					end
				
					if profile.option.ui.rules.colour.background then
						profile.option.ui.rules.background = profile.option.ui.rules.background or { }
						profile.option.ui.rules.background.colour = profile.option.ui.rules.background.colour or { }
						profile.option.ui.rules.background.colour.r = profile.option.ui.rules.colour.background.r or profile.option.ui.rules.background.colour.r
						profile.option.ui.rules.background.colour.g = profile.option.ui.rules.colour.background.g or profile.option.ui.rules.background.colour.g
						profile.option.ui.rules.background.colour.b = profile.option.ui.rules.colour.background.b or profile.option.ui.rules.background.colour.b
						profile.option.ui.rules.background.colour.a = profile.option.ui.rules.colour.background.a or profile.option.ui.rules.background.colour.a
						profile.option.ui.rules.colour.background = nil
					end
					
				end
				
			end
			
		end
		
		ArkInventory.OutputWarning( "The border styles for each location have been reset to Blizzard Tooltip (default), the colour was able to be kept though" )
		
		
		profile.option.version = upgrade_version
		
	end
	
	
	upgrade_version = 3.0240
	if profile.option.version < upgrade_version then
		
		ArkInventory.Output( string.format( ArkInventory.Localise["UPGRADE_PROFILE"], profile_name, upgrade_version ) )
		
		if profile.option.location then
			
			for _, loc in pairs( profile.option.location ) do
				
				if loc.framehide then
					
					loc.title = loc.title or { }
					loc.title.hide = not not loc.framehide.header
					
					loc.search = loc.search or { }
					loc.search.hide = not not loc.framehide.search
					
					loc.status = loc.status or { }
					loc.status.hide = not not loc.framehide.status
					
					loc.changer = loc.changer or { }
					loc.changer.hide = not not loc.framehide.changer
					
					loc.framehide = nil
					
				end
				
			end
			
		end
		
		
		profile.option.version = upgrade_version
		
	end
	
	
	upgrade_version = 3.0260
	if profile.option.version < upgrade_version then
		
		ArkInventory.Output( string.format( ArkInventory.Localise["UPGRADE_PROFILE"], profile_name, upgrade_version ) )
		
		if profile.option.location then
			
			for k, v in pairs( profile.option.location ) do
				if v.anchor and v.anchor[k] then
					
					profile.option.anchor = profile.option.anchor or { }
					profile.option.anchor[k] = profile.option.anchor[k] or { }
					
					profile.option.anchor[k].point = v.anchor[k].point
					profile.option.anchor[k].locked = v.anchor[k].locked
					profile.option.anchor[k].t = v.anchor[k].t
					profile.option.anchor[k].b = v.anchor[k].b
					profile.option.anchor[k].l = v.anchor[k].l
					profile.option.anchor[k].r = v.anchor[k].r
					
				end
				v.anchor = nil
			end
			
		end
		
		
		profile.option.version = upgrade_version
		
	end
	
	
	upgrade_version = 3.0271
	if profile.option.version < upgrade_version then
		
		ArkInventory.Output( string.format( ArkInventory.Localise["UPGRADE_PROFILE"], profile_name, upgrade_version ) )
		
		if profile.option.location then
			for k, v in pairs( profile.option.location ) do
				if v.slot and v.slot.new and v.slot.new.cutoff then
					v.slot.new.cutoff = v.slot.new.cutoff * 60
				end
			end
		end
		
		
		profile.option.version = upgrade_version
		
	end
	
	
	upgrade_version = 30404
	if profile.option.version < upgrade_version then
		
		ArkInventory.Output( string.format( ArkInventory.Localise["UPGRADE_PROFILE"], profile_name, upgrade_version ) )
		
		if profile.option.location then
			for k, v in pairs( profile.option.location ) do
				if v.sort then
					v.sort.method = v.sort.default or v.sort.method or 9999
					v.sort.default = nil
				end
			end
		end
		
		
		profile.option.version = upgrade_version
		
	end
	
	
	upgrade_version = 30409
	if profile.option.version < upgrade_version then
		
		ArkInventory.Output( string.format( ArkInventory.Localise["UPGRADE_PROFILE"], profile_name, upgrade_version ) )
		
		if profile.option.location then
			for k, v in pairs( profile.option.location ) do
				if v.slot and v.slot.empty then
					if type( v.slot.empty.first ) == "boolean" then
						if v.slot.empty.first then
							v.slot.empty.first = 1
						else
							v.slot.empty.first = 0
						end
					end
				end
			end
		end
		
		
		profile.option.version = upgrade_version
		
	end
	
	
	upgrade_version = 30420
	if profile.option.version < upgrade_version then
		
		ArkInventory.Output( string.format( ArkInventory.Localise["UPGRADE_PROFILE"], profile_name, upgrade_version ) )
		
		if profile.option.location then
			
			for k, v in pairs( profile.option.location ) do
				
				if v.slot and v.slot.new and v.slot.new.show then
					
					v.slot.age = v.slot.age or { }
					
					v.slot.age.show = v.slot.new.show
					v.slot.new.show = nil
					
					v.slot.age.cutoff = v.slot.new.cutoff
					v.slot.new.cutoff = 2
					
					if v.slot.new.colour then
						v.slot.age.colour = v.slot.age.colour or { }
						v.slot.age.colour.r = v.slot.new.colour.r
						v.slot.age.colour.g = v.slot.new.colour.g
						v.slot.age.colour.b = v.slot.new.colour.b
						v.slot.new.colour = nil
					end
				
				end
				
			end
			
		end
		
		
		profile.option.version = upgrade_version
		
	end
	
	
	upgrade_version = 30602 -- LEGION VERSION WITH DATA LAYOUT CHANGES, ANYTHING BEFORE THIS IS SAFE TO UPGRADE DIRECTLY TO 30700
	if profile.option.version < upgrade_version then
		
		upgrade_version = 30700
		
		ArkInventory.Output( string.format( ArkInventory.Localise["UPGRADE_PROFILE"], profile_name, upgrade_version ) )
		
		-- 30602 changes
		
		-- copy the acedb profile data as is to the new global profile storage
		local id, newprofile = ArkInventory.ConfigInternalProfileAdd( profile_name )
		if id then
			
			local catset_id
			local design_id = { }
			
			for k1, v1 in pairs( ARKINVDBCLASSIC.profileKeys ) do
				if v1 == profile_name then
					local player = ArkInventory.GetPlayerStorage( k1 )
					player.data.profile = id
				end
			end
			
			-- transfer category set data out of profile
			if profile.option.category or profile.option.rule then
				
				local id, data = ArkInventory.ConfigInternalCategorysetAdd( profile_name )
				
				if id then
					
					if profile.option.category then
						ArkInventory.Table.Merge( profile.option.category, data.category.assign )
					end
					profile.option.category = nil
					
					if profile.option.rule then
						ArkInventory.Table.Merge( profile.option.rule, data.category.active[ArkInventory.Const.Category.Type.Rule] )
					end
					profile.option.rule = nil
					
					for k, v in pairs( ArkInventory.acedb.global.option.category[ArkInventory.Const.Category.Type.Custom].data ) do
						if v.used ~= "N" then
							data.category.active[ArkInventory.Const.Category.Type.Custom][k] = true
						end
					end
					
					catset_id = id
					
				end
				
			end
			
			
			if profile.option.anchor then
				for k, v in pairs( profile.option.anchor ) do
					newprofile.location[k].anchor.point = v.point
					newprofile.location[k].anchor.locked = v.locked
					newprofile.location[k].anchor.t = v.t
					newprofile.location[k].anchor.b = v.b
					newprofile.location[k].anchor.l = v.l
					newprofile.location[k].anchor.r = v.r
				end
				profile.option.anchor = nil
			end
			
			
			if profile.option.location then
				
				for loc_id, loc_data in pairs( profile.option.location ) do
					if ArkInventory.Global.Location[loc_id] and ArkInventory.Global.Location[loc_id].canView then
						
						local n = string.format( "%s - %s", profile_name, ArkInventory.Global.Location[loc_id].Name or loc_id )
						
						loc_data.layout = nil
						loc_data.theme = nil
						
						if loc_data.bar and loc_data.bar.data then
							for k, v in pairs( loc_data.bar.data ) do
								if v.sortorder then
									if not v.sort then
										v.sort = { }
									end
									v.sort.method = v.sortorder
									v.sortorder = nil
								end
							end
						end
						
						-- move style/layout data to designs
						local id, design = ArkInventory.ConfigInternalDesignAdd( "transfer" )
						if id then
							
							--ArkInventory.Output( "transferring profile data to style/layout ", n )
							
							ArkInventory.Table.Merge( loc_data, design )
							
							design.used = "Y"
							design.name = string.trim( n )
							
							design_id[loc_id] = id
							
						end
					end
					
				end
				
				profile.option.location = nil
				
			end
			
			for loc_id, loc_data in pairs( ArkInventory.Global.Location ) do
				if loc_data.canView then
					local id = ( profile.option.use and profile.option.use[loc_id] ) or loc_id
					newprofile.location[loc_id].style = design_id[id] or 1000
					newprofile.location[loc_id].layout = design_id[id] or 1000
					newprofile.location[loc_id].catset = catset_id or 1000
				end
			end
			
		end
		
		table.wipe( profile.option )
		
		
		profile.option.version = upgrade_version
		
		return
	
	end
	
	
	
	-- ANYTING ELSE FROM THE PTR/BETA, THE MESSY UPGRADE PATH - THIS IS WHY BACKUPS ARE A GOOD IDEA
	
	upgrade_version = 30604
	if profile.option.version < upgrade_version then
		
		ArkInventory.Output( string.format( ArkInventory.Localise["UPGRADE_PROFILE"], profile_name, upgrade_version ) )
		
		local player = ArkInventory.PlayerDataGet( )
		
		if profile.option.category or profile.option.rule then
			
			local id, data = ArkInventory.ConfigInternalCategorysetAdd( ArkInventory.db:GetCurrentProfile( ) )
			
			if id then
				
				catset = id
				
				if profile.option.category then
					ArkInventory.Table.Merge( profile.option.category, data.category.assign )
				end
				profile.option.category = nil
				
				if profile.option.rule then
					ArkInventory.Table.Merge( profile.option.rule, data.category.active[ArkInventory.Const.Category.Type.Rule] )
				end
				profile.option.rule = nil
				
				for k, v in pairs( ArkInventory.db.global.option.category[ArkInventory.Const.Category.Type.Custom].data ) do
					if v.used ~= "N" then
						data.category.active[ArkInventory.Const.Category.Type.Custom][k] = true
					end
				end
				
			end
			
		end
		
		if profile.option.layout then
				for k, v in pairs( profile.option.layout ) do
				player.option[k].layout = v
			end
		end
		
		if profile.option.style then
			for k, v in pairs( profile.option.style ) do
				player.option[k].style = v
			end
		end
		
		if profile.option.catset then
			for k, v in pairs( profile.option.catset ) do
				player.option[k].catset = v
			end
		end
		
		profile.option.font = nil
		profile.option.frameStrata = nil
		
		
		profile.option.version = upgrade_version
		
	end
	
	
	-- ACEDB PROFILES NO LONGER USED
	-- AFTER THIS POINT EVERYTHING IS GLOBAL
	-- PROFILES UNDER 30700 WILL BE FIXED IN GLOBALS
	
end


function ArkInventory.DatabaseUpgradePostLoad( )
	
	--ArkInventory.Output( LIGHTYELLOW_FONT_COLOR_CODE, "DatabaseUpgradePostLoad" )
	
	local upgrade_version
	
	
	if not ArkInventory.acedb.global.option.version or ArkInventory.acedb.global.option.version == 0 then
		ArkInventory.acedb.global.option.version = ArkInventory.Const.Program.Version
	end
	
	if not ArkInventory.acedb.global.player.version or ArkInventory.acedb.global.player.version == 0 then
		ArkInventory.acedb.global.player.version = ArkInventory.Const.Program.Version
	end
	
	
	
--[[
	upgrade_version = 10000
	if ArkInventory.acedb.global.option.version < upgrade_version then
		
		-- cleanup leftover ace profiles from savedvariables as they are no longer used
		if ArkInventory.acedb.profiles then
			table.wipe( ArkInventory.acedb.profiles )
		end
		
		if ArkInventory.acedb.profileKeys then
			table.wipe( ArkInventory.acedb.profileKeys )
			-- these will come back over time but will be back to "Default"
		end
		
		
		ArkInventory.acedb.global.option.version = upgrade_version
		
	end
]]--
	
	
	
	
	
	-- check sort keys
	ArkInventory.ConfigInternalSortMethodCheck( )
	
	
	-- check for character rename and move old data to new name
	local info = ArkInventory.GetPlayerInfo( )
	info.renamecheck = true
	for k, v in pairs( ArkInventory.acedb.global.player.data ) do
		if info.guid and info.guid == v.info.guid and not v.info.renamecheck then
			ArkInventory.acedb.global.player.data[info.player_id] = ArkInventory.Table.Copy( v )
			ArkInventory.Output( "character was renamed from ", v.info.name, " to ", info.name, ", data has been transferred" )
			ArkInventory.acedb.global.player.data[v.info.player_id] = ArkInventory.Table.Copy( ArkInventory.acedb.global.player.data[""] )
			break
		end
	end
	info.renamecheck = nil
	
	
	
	-- set versions to current mod version
	ArkInventory.acedb.global.version = ArkInventory.Const.Program.Version
	ArkInventory.acedb.global.option.version = ArkInventory.Const.Program.Version
	ArkInventory.acedb.global.player.version = ArkInventory.Const.Program.Version
	ArkInventory.acedb.global.cache.version = ArkInventory.Const.Program.Version
	
	ArkInventory.CodexReset( )
	
end
