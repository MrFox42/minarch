local ADDON, _ = ...

MinArchHistDB = {}
MinArchIconDB = {}

MinArchIconDB[ARCHAEOLOGY_RACE_OTHER] = {
}

MinArchHistDB[ARCHAEOLOGY_RACE_OTHER] = {
}

if MINARCH_EXPANSION == 'Mainline' then
    -- Drustvari Artifacts
    MinArchIconDB[ARCHAEOLOGY_RACE_DRUSTVARI] = {

    }

    MinArchHistDB[ARCHAEOLOGY_RACE_DRUSTVARI] = {
        [160751] = {}, -- Dance of the Dead
        [161089] = {}, -- Restored Revenant
        [160833] = {}, -- Fetish of the Tormented Mind

        [154921] = {pqid = 51950}, -- Ceremonial Bonesaw
        [154922] = {pqid = 51951}, -- Ancient Runebound Tome
        [154923] = {pqid = 51952}, -- Disembowling Sickle
        [154924] = {pqid = 51953}, -- Jagged Blade of the Drust
        [154925] = {pqid = 51954}, -- Ritual Fetish
        [160741] = {pqid = 51955}, -- Soul Coffer
    }
    -- Zandalari Artifacts
    MinArchIconDB[ARCHAEOLOGY_RACE_ZANDALARI] = {

    }
    MinArchHistDB[ARCHAEOLOGY_RACE_ZANDALARI] = {
        [160740] = {}, -- Croak Crock
        [161080] = {}, -- Intact Direhorn Hatchling
        [160753] = {}, -- Sanguinating Totem

        [154913] = {pqid = 51926}, -- Akun'Jar Vase
        [154914] = {pqid = 51929}, -- Urn of Passage
        [154915] = {pqid = 51932}, -- Rezan Idol
        [154916] = {pqid = 51934}, -- High Apothecary's Hood
        [154917] = {pqid = 51936}, -- Bwonsamdi Voodoo Mask
        [160743] = {pqid = 51937}, -- Blowgun of the Sethra
    }
    -- Demonic Artifacts
    MinArchIconDB[ARCHAEOLOGY_RACE_DEMONIC] = {
        -- Wyrmy Tunkins item from Infernal Device project
        ["interface\\icons\\inv_archaeology_70_wyrmytunkins"] = "interface\\icons\\inv_pet_wyrmtongue",
    }
    MinArchHistDB[ARCHAEOLOGY_RACE_DEMONIC] = {
        [131743] = {qline = 330}, -- Blood of Young Mannoroth
        [131724] = {qline = 321}, -- Crystalline Eye of Undravius
        [131735] = {qline = 325}, -- Imp Generator
        [131732] = {qline = 332}, -- Purple Hills of Mac'Aree
        [136922] = {qline = 327}, -- Wyrmy Tunkins // Infernal Device

        [130920] = {pqid = 40363}, -- Houndstooth Hauberk
        [130919] = {pqid = 40362}, -- Orb of Inner Chaos
        [130918] = {pqid = 40361}, -- Malformed Abyssal
        [130917] = {pqid = 40360}, -- Flayed-Skin Chronicle
        [130916] = {pqid = 40359}, -- Imp's Cup
    }

    -- Highmountain Tauren Artifacts
    MinArchHistDB[ARCHAEOLOGY_RACE_HIGHMOUNTAIN_TAUREN] = {
        [131733] = {qline = 323}, -- Spear of Rethu
        [131734] = {qline = 333}, -- Spirit of Eche'ro
        [131736] = {qline = 329}, -- Prizerock Neckband

        [130915] = {pqid = 40358}, -- Stonewood Bow
        [130914] = {pqid = 40357}, -- Drogbar Gem-Roller
        [130913] = {pqid = 40356}, -- Hand-Smoothed Pyrestone
        [130912] = {pqid = 40355}, -- Moosebone Fish-Hook
        [130911] = {pqid = 40354}, -- Trailhead Drum
    }

    -- Highborne Artifacts
    MinArchIconDB[ARCHAEOLOGY_RACE_HIGHBORNE] = {
        -- Sciallax relic from Orb of Sciallax project quest completion
        ["interface\\icons\\inv_icon_shadowcouncilorb_purple"] = "interface\\icons\\inv_jewelcrafting_taladiterecrystal",
    }
    MinArchHistDB[ARCHAEOLOGY_RACE_HIGHBORNE] = {
        [131717] = {qline = 322}, -- Starlight Beacon
        [131740] = {qline = 324}, -- Crown Jewels of Suramar
        [131745] = {qline = 326}, -- Key of Kalyndras
        [131744] = {qline = 331}, -- Key to Nar'thalas Academy
        [134078] = {qline = 328}, -- Dark Shard of Sciallax // Orb of Sciallax gives one of 6 relics

        [130910] = {pqid = 40353}, -- Nobleman's Letter Opener
        [130909] = {pqid = 40352}, -- Pre-War Highborne Tapestry
        [130908] = {pqid = 40351}, -- Quietwine Vial
        [130907] = {pqid = 40350}, -- Inert Leystone Charm
        [130906] = {pqid = 40349}, -- Violetglass Vessel
    }
    -- Arakkoa Artifacts
    MinArchIconDB[ARCHAEOLOGY_RACE_ARAKKOA] = {
        ["interface\\icons\\ability_skyreach_empowered"] = "interface\\icons\\inv_eng_gizmo1"
    }
    MinArchHistDB[ARCHAEOLOGY_RACE_ARAKKOA] = {
        [117382] = {}, -- Beakbreaker of Terokk
        [117354] = {}, -- Ancient Nest Guardian

        [114197] = {pqid = 36771}, -- Dreamcatcher
        [114198] = {pqid = 36772}, -- Burial Urn
        [114199] = {pqid = 36773}, -- Decree Scrolls
        [114200] = {pqid = 36774}, -- Solar Orb
        [114201] = {pqid = 36775}, -- Sundial
        [114202] = {pqid = 36776}, -- Talonpriest Mask
        [114203] = {pqid = 36777}, -- Outcast Dreamcatcher
        [114204] = {pqid = 36778}, -- Apexis Crystal
        [114205] = {pqid = 36779}, -- Apexis Hieroglyph
        [114206] = {pqid = 36780}, -- Apexis Scroll
    }

    -- Draenor Clans Artifacts
    MinArchHistDB[ARCHAEOLOGY_RACE_DRAENOR] = {
        [116985] = {}, -- Headdress of the First Shaman
        [117380] = {}, -- Frostwolf Ghostpup // Ancient Frostwolf Fang

        [114171] = {pqid = 36756}, -- Ancestral Talisman
        [114163] = {pqid = 36753}, -- Barbed Fishing Hook
        [114157] = {pqid = 36750}, -- Blackrock Razor
        [114165] = {pqid = 36754}, -- Calcified Eye In a Jar // Calcified Eye in a Jar
        [114167] = {pqid = 36755}, -- Ceremonial Tattoo Needles
        [114169] = {pqid = 36757}, -- Cracked Ivory Idol
        [114177] = {pqid = 36760}, -- Doomsday Prophecy
        [114155] = {pqid = 36749}, -- Elemental Bellows
        [114141] = {pqid = 36725}, -- Fang-Scarred Frostwolf Axe
        [114173] = {pqid = 36758}, -- Flask of Blazegrease
        [114143] = {pqid = 36743}, -- Frostwolf Ancestry Scrimshaw
        [114175] = {pqid = 36759}, -- Gronn-Tooth Necklace
        [114161] = {pqid = 36752}, -- Hooked Dagger
        [114153] = {pqid = 36748}, -- Metalworker's Hammer
        [114149] = {pqid = 36746}, -- Screaming Bullroarer
        [114147] = {pqid = 36745}, -- Warsinger's Drums
        [114151] = {pqid = 36747}, -- Warsong Ceremonial Pike
        [114159] = {pqid = 36751}, -- Weighted Chopping Axe
        [114145] = {pqid = 36744}, -- Wolfskin Snowshoes
    }

    -- Ogre Artifacts
    MinArchIconDB[ARCHAEOLOGY_RACE_OGRE] = {
        ["interface\\icons\\inv_archaeology_ogres_sorcerer_king_toe_ring"] = "interface\\icons\\inv_60dungeon_neck4b",
        ["interface\\icons\\inv_archaeology_ogres_warmaul_chieftain"] = "interface\\icons\\inv_mace_2h_dreanorogre_b_02",
    }
    MinArchHistDB[ARCHAEOLOGY_RACE_OGRE] = {
        [117385] = {}, -- Sorcerer-King Toe Ring
        [117384] = {}, -- Warmaul of the Warmaul Chieftain

        [114191] = {pqid = 36767}, -- Eye of Har'gunn the Blind // pristine = Eye of Har'guun the Blind
        [114189] = {pqid = 36765}, -- Gladiator's Shield
        [114194] = {pqid = 36770}, -- Imperial Decree Stele
        [114190] = {pqid = 36766}, -- Mortar and Pestle
        [114185] = {pqid = 36763}, -- Ogre Figurine
        [114187] = {pqid = 36764}, -- Pictogram Carving
        [114193] = {pqid = 36769}, -- Rylak Riding Harness
        [114192] = {pqid = 36768}, -- Stone Dentures
        [114183] = {pqid = 36762}, -- Stone Manacles
        [114181] = {pqid = 36761}, -- Stonemaul Succession Stone
    }
end

if LE_EXPANSION_LEVEL_CURRENT >= 4 then
    -- Mantid Artifacts
    MinArchHistDB[ARCHAEOLOGY_RACE_MANTID] = {
        [95391] = {}, -- Mantid Sky Reaver
        [95392] = {}, -- Sonic Pulse Generator

        [95375] = {pqid = 32686, achievement = 8221}, -- Banner of the Mantid Empire
        [95376] = {pqid = 32687, achievement = 8223}, -- Ancient Sap Feeder
        [95377] = {pqid = 32688, achievement = 8225}, -- The Praying Mantid
        [95378] = {pqid = 32689, achievement = 8227}, -- Inert Sound Beacon
        [95379] = {pqid = 32690, achievement = 8229}, -- Remains of a Paragon
        [95380] = {pqid = 32691, achievement = 8231}, -- Mantid Lamp
        [95381] = {pqid = 32692, achievement = 8233}, -- Pollen Collector
        [95382] = {pqid = 32693, achievement = 8235}, -- Kypari Sap Container
    }

    -- Pandaren Artifacts
    MinArchHistDB[ARCHAEOLOGY_RACE_PANDAREN] = {
        [79907] = {}, -- Spear of Xuen
        [79906] = {}, -- Umbrella of Chi-Ji

        [79903]	= {pqid = 31802, achievement = 7365}, -- Apothecary Tins
        [79901] = {pqid = 31800, achievement = 7363}, -- Carved Bronze Mirror
        [79900] = {pqid = 31799, achievement = 7362}, -- Empty Keg // Empty Keg of Brewfather Xin Wo Yin
        [79902] = {pqid = 31801, achievement = 7364}, -- Gold-Inlaid Figurine // Gold-Inlaid Porcelain Funerary Figurine
        [79897] = {pqid = 31796, achievement = 7359}, -- Pandaren Game Board
        [79896] = {pqid = 31795, achievement = 7358}, -- Pandaren Tea Set
        [79904] = {pqid = 31803, achievement = 7366}, -- Pearl of Yu'lon
        [79905] = {pqid = 31804, achievement = 7367}, -- Standard of Niuzao
        [79898] = {pqid = 31797, achievement = 7360}, -- Twin Stein Set // Twin Stein Set of Brewfather Quan Tou Kuo
        [79899] = {pqid = 31798, achievement = 7361}, -- Walking Cane // Walking Cane of Brewfather Ren Yun
    }

    -- Mogu Artifacts
    MinArchHistDB[ARCHAEOLOGY_RACE_MOGU] = {
        [89611] = {}, -- Quilen Statuette
        [89614] = {}, -- Anatomical Dummy

        [79909] = {pqid = 31787, achievement = 7369}, -- Cracked Mogu Runestone
        [79913] = {pqid = 31791, achievement = 7373}, -- Edicts of the Thunder King
        [79914] = {pqid = 31792, achievement = 7374}, -- Iron Amulet
        [79908] = {pqid = 31786, achievement = 7368}, -- Manacles of Rebellion
        [79916] = {pqid = 31794, achievement = 7376}, -- Mogu Coin
        [79911] = {pqid = 31789, achievement = 7371}, -- Petrified Bone Whip
        [79910] = {pqid = 31788, achievement = 7370}, -- Terracotta Arm
        [79912] = {pqid = 31790, achievement = 7372}, -- Thunder King Insignia
        [79915] = {pqid = 31793, achievement = 7375}, -- Warlord's Branding Iron
        [79917] = {pqid = 31805, achievement = 7377}, -- Worn Monument Ledger
    } 
end

-- Dwarf Artifacts
MinArchHistDB[ARCHAEOLOGY_RACE_DWARF] = {
    [64489] = {}, -- Staff of Sorcerer-Thane Thaurissan
    [64488] = {}, -- The Innkeeper's Daughter
    [64373] = {}, -- Chalice of the Mountain King
    [64372] = {}, -- Clockwork Gnome

    [63113] = {}, -- Belt Buckle with Anvilmar Crest
    [64339] = {}, -- Bodacious Door Knocker
    [63112] = {}, -- Bone Gaming Dice
    [64340] = {}, -- Boot Heel with Scrollwork
    [63409] = {}, -- Ceramic Funeral Urn
    [64362] = {}, -- Dented Shield of Horuz Killcrow
    [66054] = {}, -- Dwarven Baby Socks
    [64342] = {}, -- Golden Chamber Pot
    [64344] = {}, -- Ironstar's Petrified Shield
    [64368] = {}, -- Mithril Chain of Angerforge
    [63414] = {}, -- Moltenfist's Jeweled Goblet
    [64337] = {}, -- Notched Sword of Tunadil the Redeemer
    [63408] = {}, -- Pewter Drinking Cup
    [64659] = {}, -- Pipe of Franclorn Forgewright
    [64487] = {}, -- Scepter of Bronzebeard
    [64367] = {}, -- Scepter of Charlga Razorflank
    [64366] = {}, -- Scorched Staff of Shadow Priest Anund
    [64483] = {}, -- Silver Kris of Korl
    [63411] = {}, -- Silver Neck Torc
    [64371] = {}, -- Skull Staff of Shadowforge
    [64485] = {}, -- Spiked Gauntlets of Anvilrage
    [63410] = {}, -- Stone Gryphon
    [64484] = {}, -- Warmaul of Burningeye
    [64343] = {}, -- Winged Helm of Corehammer
    [63111] = {}, -- Wooden Whistle
    [64486] = {}, -- Word of Empress Zoe
    [63110] = {}, -- Worn Hunting Knife
}

-- Draenei Artifacts
MinArchHistDB[ARCHAEOLOGY_RACE_DRAENEI] = {
    [64456] = {}, -- Arrival of the Naaru
    [64457] = {}, -- The Last Relic of Argus

    [64440] = {}, -- Anklet with Golden Bells
    [64453] = {}, -- Baroque Sword Scabbard
    [64442] = {}, -- Carved Harp of Exotic Wood
    [64455] = {}, -- Dignified Portrait
    [64454] = {}, -- Fine Crystal Candelabra
    [64458] = {}, -- Plated Elekk Goad
    [64444] = {}, -- Scepter of the Nathrezim
    [64443] = {}, -- Strange Silver Paperweight
}

-- Fossil Artifacts
MinArchHistDB[ARCHAEOLOGY_RACE_FOSSIL] = {
    [69764] = {}, -- Extinct Turtle Shell
    [60954] = {}, -- Fossilized Raptor
    [60955] = {}, -- Fossilized Hatchling
    [69821] = {}, -- Pterrordax Hatchling
    [69776] = {}, -- Ancient Amber

    [64355] = {}, -- Ancient Shark Jaws
    [63121] = {}, -- Beautiful Preserved Fern
    [63109] = {}, -- Black Trilobite
    [64349] = {}, -- Devilsaur Tooth
    [64385] = {}, -- Feathered Raptor Arm
    [64473] = {}, -- Imprint of a Kraken Tentacle
    [64350] = {}, -- Insect in Amber
    [64468] = {}, -- Proto-drake Skeleton
    [66056] = {}, -- Shard of Petrified Wood
    [66057] = {}, -- Strange Velvet Worm
    [63527] = {}, -- Twisted Ammonite
    [64387] = {}, -- Vicious Ancient Fish
}

-- Night Elf Artifacts
MinArchHistDB[ARCHAEOLOGY_RACE_NIGHTELF] = {
    [64646] = {}, -- Bones of Transformation
    [64643] = {}, -- Queen Azshara's Dressing Gown
    [64645] = {}, -- Tyrande's Favorite Doll
    [64651] = {}, -- Wisp Amulet
    [64361] = {}, -- Druid and Priest Statue Set
    [64358] = {}, -- Highborne Soul Mirror
    [64383] = {}, -- Kaldorei Wind Chimes

    [64647] = {}, -- Carcanet of the Hundred Magi
    [64379] = {}, -- Chest of Tiny Glass Animals
    [63407] = {}, -- Cloak Clasp with Antlers
    [63525] = {}, -- Coin from Eldre'Thalas
    [64381] = {}, -- Cracked Crystal Vial
    [64357] = {}, -- Delicate Music Box
    [63528] = {}, -- Green Dragon Ring
    [64356] = {}, -- Hairpin of Silver and Malachite
    [63129] = {}, -- Highborne Pyxis
    [63130] = {}, -- Inlaid Ivory Comb
    [64354] = {}, -- Kaldorei Amphora
    [66055] = {}, -- Necklace with Elune Pendant
    [63131] = {}, -- Scandalous Silk Nighhtgown
    [64382] = {}, -- Scepter of Xavius
    [63526] = {}, -- Shattered Glaive
    [64648] = {}, -- Silver Scroll Case
    [64378] = {}, -- String of Small Pink Pearls
    [64650] = {}, -- Umbra Crescent
}

-- Nerubian Artifacts
MinArchIconDB[ARCHAEOLOGY_RACE_NERUBIAN] = {
    -- Six-Clawed Cornice has different icon for artifact and item
    ["interface\\icons\\achievement_dungeon_azjollowercity_25man"] = "interface\\icons\\achievement_dungeon_azjollowercity"
}
MinArchHistDB[ARCHAEOLOGY_RACE_NERUBIAN] = {
    [64481] = {}, -- Blessing of the Old God
    [64482] = {}, -- Puzzle Box of Yogg-Saron

    [64474] = {}, -- Spidery Sundial
    [64479] = {}, -- Ewer of Jormungar Blood
    [64477] = {}, -- Gruesome Heart Box
    [64476] = {}, -- Infested Ruby Ring
    [64475] = {}, -- Scepter of Nezar'Azret
    [64478] = {}, -- Six-Clawed Cornice
    [64480] = {}, -- Vizier's Scrawled Streamer
}

-- Orc Artifacts
MinArchHistDB[ARCHAEOLOGY_RACE_ORC] = {
    [64644] = {}, -- Headdress of the First Shaman

    [64421] = {}, -- Fierce Wolf Figurine
    [64436] = {}, -- Fiendish Whip
    [64418] = {}, -- Gray Candle Stub
    [64417] = {}, -- Maul of Stone Guard Mur'og
    [64419] = {}, -- Rusted Steak Knife
    [64420] = {}, -- Scepter of Nekros Skullcrusher
    [64438] = {}, -- Skull Drinking Cup
    [64437] = {}, -- Tile of Glazed Clay
    [64389] = {}, -- Tiny Bronze Scorpion
}

-- Tol'vir Artifacts
MinArchIconDB[ARCHAEOLOGY_RACE_TOLVIR] = {
    -- Crawling Claw has different icon for artifact and item
    ["interface\\icons\\trade_archaeology_shriveledmonkeypaw"] = "interface\\icons\\inv_offhand_stratholme_a_02"
}
MinArchHistDB[ARCHAEOLOGY_RACE_TOLVIR] = {
    [60847] = {}, -- Crawling Claw
    [64881] = {}, -- Pendant of the Scarab Storm
    [64904] = {}, -- Ring of the Boy Emperor
    [64883] = {}, -- Scepter of Azj'Aqir
    [64885] = {}, -- Scimitar of the Sirocco
    [64880] = {}, -- Staff of Ammunae

    [64657] = {}, -- Canopic Jar
    [64652] = {}, -- Castle of Sand
    [64653] = {}, -- Cat Statue with Emerald Eyes
    [64656] = {}, -- Engraved Scimitar Hilt
    [64658] = {}, -- Sketch of a Desert Palace
    [64654] = {}, -- Soapstone Scarap Necklace
    [64655] = {}, -- Tiny Oasis Mosaic
}

-- Troll Artifacts
MinArchHistDB[ARCHAEOLOGY_RACE_TROLL] = {
    [64377] = {}, -- Zin'rokh, Destroyer of Worlds
    [69824] = {}, -- Voodoo Figurine
    [69777] = {}, -- Haunted War Drum

    [64348] = {}, -- Atal'ai Scepter
    [64346] = {}, -- Bracelet of Jade and Coins
    [63524] = {}, -- Cinnabar Bijou
    [64375] = {}, -- Drakkari Sacrificial Knife
    [63523] = {}, -- Eerie Smolderthorn Idol
    [63413] = {}, -- Feathered Gold Earring
    [63120] = {}, -- Fetish of Hir'eek
    [66058] = {}, -- Fine Bloodscalp Dinnerware
    [64347] = {}, -- Gahz'rilla Figurine
    [63412] = {}, -- Jade Asp with Ruby Eyes
    [63118] = {}, -- Lizard Foot Charm
    [64345] = {}, -- Skull-Shaped Planter
    [64374] = {}, -- Tooth with Gold Filling
    [63115] = {}, -- Zandalari Voodoo Doll
}

-- Vrykul Artifacts
MinArchHistDB[ARCHAEOLOGY_RACE_VRYKUL] = {
    [64460] = {}, -- Nifflevar Bearded Axe
    [69775] = {}, -- Vrykul Drinking Horn

    [64464] = {}, -- Fanged Cloak Pin
    [64462] = {}, -- Flint Striker
    [64459] = {}, -- Intricate Treasure Chest Key
    [64461] = {}, -- Scramseax
    [64467] = {}, -- Thorned Necklace
}
