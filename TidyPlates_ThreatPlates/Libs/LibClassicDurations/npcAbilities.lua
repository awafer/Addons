local lib = LibStub and LibStub("LibClassicDurations", true)
if not lib then return end

local Type, Version = "NPCSpellTable", 1
if lib:GetDataVersion(Type) >= Version then return end


lib.npc_spells = {
    -- MC
    [20475] = 8, -- Living Bomb


    [7057] = 300, -- Haunting Spirits
    [17013] = 1800, -- Agamaggan's Agility
    [3547] = 8, -- Enraging Memories
    [7093] = 4, -- Intimidation
    [3551] = 2, -- Skull Crack
    [25772] = 120, -- Mental Domination
    [19137] = 20, -- Slow
    [16231] = 120, -- Curse of Recklessness
    [11640] = 15, -- Renew
    [8137] = 1800, -- Silithid Pox
    [8139] = 1800, -- Fevered Fatigue
    [8602] = 10, -- Vengeance
    [7121] = 10, -- Anti-Magic Shield
    [7125] = 120, -- Toxic Saliva
    [7127] = 60, -- Wavering Will
    [8151] = 2.5, -- Surprise Attack
    [13736] = 2, -- Whirlwind
    [20806] = 4, -- Frostbolt
    [18267] = 30, -- Curse of Weakness
    [7139] = 3, -- Fel Stomp
    [8646] = 2, -- Snap Kick
    [9672] = 4, -- Frostbolt
    [512] = 20, -- Chains of Ice
    [17820] = 15, -- Veil of Shadow
    [12251] = 30, -- Virulent Poison
    [12255] = 900, -- Curse of Tuten'kash
    [3583] = 120, -- Deadly Poison
    [3584] = 120, -- Volatile Infection
    [10734] = 3, -- Hail Storm
    [3586] = 180, -- Volatile Infection
    [12279] = 600, -- Curse of Blood
    [3589] = 8, -- Deafening Screech
    [10251] = 180, -- Biletoad Infection
    [5137] = 60, -- Call of the Grave
    [21030] = 8, -- Frost Shock
    [3600] = 5, -- Earthbind
    [11820] = 10, -- Electrified Net
    [3602] = 30, -- Torch Burst
    [3603] = 15, -- Distracting Pain
    [3604] = 8, -- Tendon Rip
    [5159] = 20, -- Melt Ore
    [13884] = 180, -- Withering Poison
    [8267] = 600, -- Cursed Blood
    [3609] = 8, -- Paralyzing Poison
    [4153] = 30, -- Guile of the Raptor
    [8806] = 60, -- Poisoned Shot
    [11876] = 5, -- War Stomp
    [3105] = 600, -- Curse of Stalvan
    [8822] = 30, -- Stealth
    [3109] = 10, -- Presence of Death
    [29544] = 8, -- Intimidating Shout
    [6726] = 6, -- Silence
    [2601] = 30, -- Fire Shield III
    [5708] = 2, -- Swoop
    [29484] = 10, -- Web Spray
    [20743] = 5, -- Drain Life
    [113] = 15, -- Chains of Ice
    [9373] = 12, -- Soul Siphon
    [28776] = 30, -- Necrotic Poison
    [6742] = 30, -- Bloodlust
    [8363] = 75, -- Parasite
    [5213] = 15, -- Molten Metal
    [16711] = 300, -- Grow
    [17230] = 300, -- Infected Wound
    [3635] = 6, -- Crystal Gaze
    [3636] = 15, -- Crystalline Slumber
    [28542] = 12, -- Life Drain
    [8391] = 3, -- Ravage
    [3639] = 6, -- Improved Blocking
    [8399] = 10, -- Sleep
    [3130] = 6, -- Ice Claw
    [28531] = 5, -- Frost Aura
    [6257] = 30, -- Torch Toss
    [16612] = 1800, -- Agamaggan's Strength
    [15062] = 10, -- Shield Wall
    [15708] = 5, -- Mortal Strike
    [228] = 10, -- Polymorph: Chicken
    [3648] = 45, -- Phase Out
    [26141] = 10, -- Hamstring
    [3650] = 15, -- Sling Mud
    [7295] = 10, -- Soul Drain
    [12024] = 5, -- Net
    [6788] = 15, -- Weakened Soul
    [3143] = 3, -- Glacial Roar
    [25991] = 10, -- Poison Bolt Volley
    [3145] = 5, -- Icy Grasp
    [3146] = 30, -- Daunting Growl
    [3147] = 12, -- Rend Flesh
    [3148] = 20, -- Head Crack
    [3149] = 15, -- Furious Howl
    [3150] = 600, -- Rabies
    [3151] = 6, -- Crazed Hunger
    [22128] = 600, -- Thorns
    [19514] = 600, -- Lightning Shield
    [25771] = 60, -- Forbearance
    [23511] = 30, -- Demoralizing Shout
    [6816] = 4, -- Corrupted Strength
    [6818] = 4, -- Corrupted Intellect
    [23060] = 240, -- Battle Squawk
    [12160] = 12, -- Rejuvenation
    [3671] = 180, -- Cracking Stone
    [3672] = 180, -- Crumbling Stone
    [3673] = 180, -- Reduced to Rubble
    [22206] = 12, -- Moonfire
    [5810] = 6, -- Stone Skin
    [134] = 60, -- Fire Shield
    [16552] = 10, -- Venom Spit
    [22187] = 30, -- Power Word: Shield
    [7965] = 300, -- Cobrahn Serpent Form
    [25774] = 3, -- Mind Shatter
    [20672] = 3, -- Fade
    [7357] = 15, -- Poisonous Stab
    [22127] = 10, -- Entangling Roots
    [7289] = 120, -- Shrink
    [21369] = 4, -- Frostbolt
    [7365] = 30, -- Bottle of Poison
    [7367] = 180, -- Infected Bite
    [21307] = 7200, -- Swell of Souls
    [21188] = 2, -- Stun Bomb Attack
    [8599] = 120, -- Enrage
    [6864] = 8, -- Strength of Stone
    [6866] = 180, -- Moss Covered Hands
    [11020] = 8, -- Petrify
    [5337] = 8, -- Wither Strike
    [17207] = 2, -- Whirlwind
    [20792] = 4, -- Frostbolt
    [16712] = 300, -- Special Brew
    [20297] = 4, -- Frostbolt
    [21075] = 10, -- Damage Shield
    [19136] = 5, -- Stormbolt
    [21007] = 120, -- Curse of Weakness
    [4980] = 10, -- Quick Frost Ward
    [7399] = 4, -- Terrify
    [18812] = 2, -- Knockdown
    [12747] = 10, -- Entangling Roots
    [9275] = 21, -- Immolate
    [20822] = 4, -- Frostbolt
    [12544] = 1800, -- Frost Armor
    [20800] = 21, -- Immolate
    [1090] = 30, -- Sleep
    [20798] = 1800, -- Demon Skin
    [5884] = 12, -- Banshee Curse
    [20786] = 10, -- Destroy Karang's Banner
    [13326] = 1800, -- Arcane Intellect
    [8699] = 20, -- Unholy Frenzy
    [20667] = 30, -- Corrosive Acid Breath
    [20620] = 300, -- Aegis of Ragnaros
    [20619] = 10, -- Magic Reflection
    [8715] = 3, -- Terrifying Howl
    [6922] = 300, -- Curse of the Shadowhorn
    [10767] = 1800, -- Rising Spirit
    [7948] = 20, -- Wild Regeneration
    [21008] = 6, -- Mocking Blow
    [18972] = 20, -- Slow
    [10730] = 10, -- Pacify
    [19134] = 8, -- Intimidating Shout
    [19133] = 8, -- Frost Shock
    [8138] = 2700, -- Mirkfallon Fungus
    [18501] = 5, -- Enrage
    [6942] = 6, -- Overwhelming Stench
    [19030] = 300, -- Bear Form
    [5413] = 120, -- Noxious Catalyst
    [8260] = 4, -- Rushing Charge
    [6950] = 60, -- Faerie Fire
    [8282] = 600, -- Curse of Blood
    [8272] = 600, -- Mind Tremor
    [10831] = 5, -- Reflection Field
    [18765] = 20, -- Sweeping Strikes
    [18070] = 30, -- Earthborer Acid
    [3229] = 5, -- Quick Bloodlust
    [18545] = 20, -- Scorpid Sting
    [10851] = 15, -- Grab Weapon
    [10855] = 10, -- Lag
    [7481] = 300, -- Howling Rage
    [7483] = 300, -- Howling Rage
    [18503] = 10, -- Hex
    [7998] = 10, -- Soot Covering
    [3237] = 240, -- Curse of Thule
    [3238] = 8, -- Nimble Reflexes
    [6982] = 4, -- Gust of Wind
    [6984] = 10, -- Frost Shot
    [18266] = 15, -- Curse of Agony
    [3242] = 2, -- Ravage
    [101] = 3, -- Trip
    [4948] = 15, -- Kinelory's Bear Form
    [8016] = 1200, -- Spirit Decay
    [18159] = 900, -- Curse of the Fallen Magram
    [3247] = 15, -- Agonizing Pain
    [3248] = 6, -- Improved Blocking
    [17883] = 21, -- Immolate
    [17743] = 120, -- Peon Sleeping
    [4962] = 6, -- Encasing Webs
    [3252] = 12, -- Shred
    [17276] = 4, -- Scald
    [17227] = 120, -- Curse of Weakness
    [17213] = 900, -- Curse of Vengeance
    [3256] = 240, -- Plague Cloud
    [4974] = 120, -- Wither Touch
    [3258] = 4, -- Savage Rage
    [17205] = 1200, -- Winterfall Firewater
    [3260] = 8, -- Violent Shield Effect
    [3261] = 20, -- Ignite
    [17175] = 3600, -- Resist Arcane
    [3263] = 5, -- Touch of Ravenclaw
    [3264] = 15, -- Blood Howl
    [17146] = 18, -- Shadow Word: Pain
    [5628] = 6, -- Gnarlpine Vengeance
    [6016] = 20, -- Pierce Armor
    [16856] = 5, -- Mortal Strike
    [3269] = 8, -- Blessing of Thule
    [6533] = 10, -- Net
    [3271] = 2, -- Fatigued
    [5515] = 8, -- Savagery
    [16716] = 5, -- Launch
    [16709] = 20, -- Hex
    [7054] = 300, -- Forsaken Skills
    [8078] = 10, -- Thunderclap
    [16708] = 20, -- Hex
    [12548] = 8, -- Frost Shock
    [26143] = 10, -- Mind Flay
    [26662] = 300, -- Berserk
    [15727] = 30, -- Demoralizing Roar
    [7068] = 15, -- Veil of Shadow
    [16587] = 600, -- Dark Whispers
    [7072] = 60, -- Wild Rage
    [7074] = 5, -- Screams of the Past
    [16561] = 21, -- Regrowth
    [12097] = 20, -- Pierce Armor
    [3288] = 10, -- Moss Hide
    [8242] = 2, -- Shield Slam
    [16172] = 20, -- Head Crack
    [16170] = 30, -- Bloodlust
    [16128] = 180, -- Infected Bite
    [7090] = 300, -- Bear Form
    [15981] = 12, -- Rejuvenation
    [12551] = 10, -- Frost Shot
    [8377] = 4, -- Earthgrab
    [7098] = 180, -- Curse of Mending
    [5567] = 5, -- Miring Mud
    [7102] = 240, -- Contagion of Rot
    [15798] = 12, -- Moonfire
    [16610] = 600, -- Razorhide
    [16618] = 300, -- Spirit of the Wind
    [7621] = 10, -- Arugal's Curse
    [3815] = 45, -- Poison Cloud
    [12169] = 5, -- Shield Block
    [700] = 20, -- Sleep
    [6607] = 2, -- Lash
    [7120] = 1800, -- Proudmoore's Defense
    [15661] = 21, -- Immolate
    [7124] = 300, -- Arugal's Gift
    [15654] = 18, -- Shadow Word: Pain
    [8150] = 2.5, -- Thundercrack
    [15616] = 12, -- Flame Shock
    [13738] = 15, -- Rend
    [3826] = 3, -- Ward of Laze effect
    [9658] = 45, -- Flame Buffet
    [15588] = 10, -- Thunderclap
    [7140] = 5, -- Expose Weakness
    [6730] = 2, -- Head Butt
    [15548] = 10, -- Thunderclap
    [7657] = 30, -- Hex of Ravenclaw
    [12748] = 5, -- Frost Nova
    [5106] = 15, -- Crystal Flash
    [12245] = 300, -- Infected Spine
    [21401] = 8, -- Frost Shock
    [15531] = 8, -- Frost Nova
    [6136] = 5, -- Chilled
    [15499] = 8, -- Frost Shock
    [10732] = 10, -- Supercharge
    [7164] = 180, -- Defensive Stance
    [9616] = 20, -- Wild Regeneration
    [6146] = 15, -- Slow
    [15044] = 60, -- Frost Ward
    [15043] = 4, -- Frostbolt
    [3335] = 300, -- Dark Sludge
    [8716] = 12, -- Low Swipe
    [15039] = 12, -- Flame Shock
    [13323] = 20, -- Polymorph
    [14907] = 8, -- Frost Nova
    [14792] = 30, -- Venomhide Poison
    [14868] = 30, -- Curse of Agony
    [7020] = 15, -- Stoneform
    [14517] = 30, -- Crusader Strike
    [14515] = 15, -- Dominate Mind
    [13864] = 1800, -- Power Word: Fortitude
    [6685] = 15, -- Piercing Shot
    [13787] = 1800, -- Demon Armor
    [4134] = 10, -- Bruise
    [7713] = 6, -- Wailing Dead
    [13730] = 30, -- Demoralizing Shout
    [13585] = 600, -- Lightning Shield
    [5164] = 2, -- Knockdown
    [13445] = 15, -- Rend
    [8788] = 600, -- Lightning Shield
    [4148] = 300, -- Growl of Fortitude
    [3356] = 45, -- Flame Lash
    [22168] = 20, -- Renew
    [3358] = 40, -- Leech Poison
    [10852] = 10, -- Battle Net
    [6713] = 6, -- Disarm
    [15970] = 10, -- Sleep
    [7739] = 10, -- Inferno Shell
    [20683] = 5, -- Highlord's Justice
    [13322] = 2, -- Frostbolt
    [9080] = 10, -- Hamstring
    [6946] = 180, -- Curse of the Bleakheart
    [6957] = 180, -- Frostmane Strength
    [13443] = 15, -- Rend
    [3369] = 120, -- Potion Strength II
    [11918] = 15, -- Poison
    [11922] = 15, -- Entangling Roots
    [5115] = 6, -- Battle Command
    [7761] = 4, -- Shared Bonds
    [5208] = 60, -- Poisoned Harpoon
    [8361] = 2, -- Purity
    [8365] = 60, -- Enlarge
    [16707] = 20, -- Hex
    [11977] = 15, -- Rend
    [6751] = 12, -- Weak Poison
    [20819] = 4, -- Frostbolt
    [8385] = 3600, -- Swift Wind
    [12533] = 45, -- Acid Breath
    [8245] = 300, -- Corrosive Acid
    [7272] = 12, -- Dust Cloud
    [3385] = 4, -- Boar Charge
    [22911] = 2, -- Charge
    [6767] = 600, -- Mark of Shame
    [12040] = 30, -- Shadow Shield
    [3389] = 6, -- Ward of the Eye
    [12023] = 5, -- Web
    [6264] = 8, -- Nimble Reflexes
    [6266] = 3, -- Kodo Stomp
    [6268] = 3, -- Rushing Charge
    [5759] = 240, -- Cat Form
    [11983] = 10, -- Steam Jet
    [3396] = 30, -- Corrosive Poison
    [11980] = 120, -- Curse of Weakness
    [6278] = 60, -- Creeping Mold
    [12545] = 20, -- Spitelash
    [11974] = 30, -- Power Word: Shield
    [5262] = 10, -- Fanatic Blade
    [12557] = 8, -- Cone of Cold
    [11962] = 21, -- Immolate
    [8988] = 10, -- Silence
    [5781] = 30, -- Threatening Growl
    [11831] = 8, -- Frost Nova
    [10348] = 20, -- Tune Up
    [10651] = 120, -- Curse of the Eye
    [11445] = 60, -- Bone Armor
    [5280] = 45, -- Razor Mane
    [6304] = 3, -- Rhahk'Zor Slam
    [6306] = 30, -- Acid Splash
    [6819] = 4, -- Corrupted Stamina
    [11443] = 15, -- Cripple
    [11442] = 180, -- Withered Touch
    [3416] = 10, -- Fiend Fury
    [7484] = 300, -- Howling Rage
    [11430] = 2, -- Slam
    [3419] = 6, -- Improved Blocking
    [11428] = 2, -- Knockdown
    [11397] = 300, -- Diseased Shot
    [11264] = 10, -- Ice Blast
    [21163] = 1800, -- Polished Armor
    [246] = 10, -- Slow
    [19135] = 15, -- Avatar
    [9462] = 8, -- Mirefin Fungus
    [3427] = 300, -- Infected Wound
    [11639] = 18, -- Shadow Word: Pain
    [3429] = 600, -- Plague Mind
    [11647] = 30, -- Power Word: Shield
    [7366] = 240, -- Berserker Stance
    [12166] = 5, -- Muscle Tear
    [9775] = 60, -- Irradiated
    [8362] = 20, -- Renew
    [15244] = 8, -- Cone of Cold
    [3436] = 300, -- Wandering Plague
    [10653] = 120, -- Curse of the Eye
    [9459] = 60, -- Corrosive Ooze
    [9128] = 120, -- Battle Shout
    [6873] = 120, -- Foul Chill
    [4320] = 12, -- Trelane's Freezing Touch
    [3442] = 15, -- Enslave
    [3443] = 15, -- Enchanted Quickness
    [9438] = 8, -- Arcane Bubble
    [20828] = 8, -- Cone of Cold
    [8269] = 120, -- Enrage
    [12737] = 4, -- Frostbolt
    [12741] = 120, -- Curse of Weakness
    [9034] = 21, -- Immolate
    [8989] = 10, -- Whirlwind
    [8909] = 600, -- Unholy Shield
    [6870] = 180, -- Moss Covered Feet
    [8554] = 2, -- Drinking Barleybrew Scalder
    [184] = 60, -- Fire Shield II
    [9192] = 120, -- "Plucky" Resumes Human Form
    [8383] = 3600, -- Burning Tenacity
    [6907] = 120, -- Diseased Slime
    [6909] = 180, -- Curse of Thorns
    [7279] = 120, -- Black Sludge
    [8379] = 10, -- Disarm
    [15859] = 5, -- Dominate Mind
    [6917] = 10, -- Venom Spit
    [9735] = 1200, -- Sapta Sight
    [6921] = 6, -- Shadowhorn Charge
    [8314] = 3600, -- Rock Skin
    [7947] = 60, -- Localized Toxin
    [8285] = 2.5, -- Rampage
    [18968] = 600, -- Fire Shield
    [8281] = 10, -- Sonic Burst
    [8275] = 75, -- Poisoned Shot
    [9256] = 10, -- Deep Sleep
    [5915] = 60, -- Crazed
    [7961] = 5, -- Azrethoc's Stomp
    [8257] = 30, -- Venom Sting
    [6432] = 10, -- Smite Stomp
    [7967] = 15, -- Naralex's Nightmare
    [9791] = 20, -- Head Crack
    [5416] = 45, -- Venom Sting
    [6951] = 300, -- Decayed Strength
    [16509] = 15, -- Rend
    [8147] = 10, -- Thunderclap
    [744] = 30, -- Poison
    [5426] = 6, -- Quick Sidestep
    [8142] = 10, -- Grasping Vines
    [3485] = 15, -- Wail of Nightlash
    [745] = 10, -- Web
    [8140] = 15, -- Befuddlement
    [19128] = 2, -- Knockdown
    [8817] = 3, -- Smoke Bomb
    [3490] = 5, -- Frenzied Rage
    [7997] = 300, -- Sap Might
    [6466] = 3, -- Axe Toss
    [8040] = 15, -- Druid's Slumber
    [8014] = 1200, -- Tetanus
    [7992] = 25, -- Slowing Poison
    [13444] = 30, -- Sunder Armor
    [7964] = 4, -- Smoke Bomb
    [7901] = 300, -- Decayed Agility
    [7803] = 5, -- Thundershock
    [7764] = 1800, -- Wisdom of Agamaggan
    [7750] = 12, -- Consuming Rage
    [7656] = 30, -- Hex of Ravenclaw
    [4955] = 12, -- Fist of Stone
    [7645] = 10, -- Dominate Mind
    [11436] = 10, -- Slow
    [7290] = 10, -- Soul Siphon
    [15532] = 8, -- Frost Nova
    [8382] = 45, -- Leech Poison
    [14518] = 30, -- Crusader Strike
    [3510] = 3, -- Sloth Effect
    [11971] = 30, -- Sunder Armor
    [8398] = 8, -- Frostbolt Volley
    [8041] = 10, -- Serpent Form
    [3514] = 3, -- Sludge
    [4979] = 10, -- Quick Flame Ward
    [6817] = 4, -- Corrupted Agility
    [15572] = 30, -- Sunder Armor
    [6728] = 10, -- Enveloping Winds
    [6576] = 5, -- Intimidating Growl
    [6253] = 2, -- Backhand
    [6524] = 2, -- Ground Tremor
    [6507] = 60, -- Battle Roar
    [6435] = 3, -- Smite Slam
    [6530] = 10, -- Sling Dirt
    [16869] = 10, -- Ice Tomb
    [5219] = 8, -- Draw of Thistlenettle
    [5514] = 12, -- Darken Vision
    [12550] = 600, -- Lightning Shield
    [20989] = 10, -- Sleep
    [3019] = 15, -- Enrage
    [3424] = 120, -- Tainted Howl
    [3136] = 10, -- Frenzied Command
}

lib:SetDataVersion(Type, Version)
