# Buildings

## What You Need to Know First
- Buildings are defined in `common/buildings/`
- Buildings modify a county's stats (tax, levy, development, etc.)
- Each building has a type: regular (available everywhere), special (specific holding), duchy_capital (duchy capital buildings)
- Buildings can have multiple levels, each upgrading the previous
- Localization keys follow the pattern: `building_<key>` for the name, `building_<key>_desc` for description
- **IMPORTANT**: Building localization uses the prefix `building_` NOT `building_type_` — but some special buildings use `building_type_` prefix. Check vanilla examples for the specific building type you're creating.
- Cost is in gold by default
- Buildings need the `is_enabled` / `can_construct` triggers to control availability

## Minimal Template — Regular Building

```
# common/buildings/my_buildings.txt

my_market = {
    construction_time = 365    # days

    cost_gold = 100

    # Modifiers applied to the county while this building exists
    county_modifier = {
        monthly_county_control_change_add = 0.1
        tax_mult = 0.05
    }

    # What's needed to build this
    is_enabled = {
        # Triggers checked against the county holder
        always = yes
    }
    can_construct = {
        always = yes
    }

    # AI logic
    ai_value = {
        base = 10
    }

    # Next level upgrade
    next_building = my_market_2

    type = regular  # regular, special, duchy_capital
}

my_market_2 = {
    construction_time = 730
    cost_gold = 200

    county_modifier = {
        monthly_county_control_change_add = 0.2
        tax_mult = 0.10
    }

    is_enabled = {
        always = yes
    }
    can_construct = {
        always = yes
    }

    ai_value = {
        base = 20
    }

    previous_building = my_market

    type = regular
}
```

Localization:
```
# localization/english/my_buildings_l_english.yml
l_english:
 building_my_market: "Market Square"
 building_my_market_desc: "A bustling market that improves trade."
 building_my_market_2: "Grand Market"
 building_my_market_2_desc: "An expanded market with foreign traders."
```

## Common Variants

### Duchy Capital Building
Buildings only available in duchy capitals:
```
my_duchy_building = {
    construction_time = 1095
    cost_gold = 500
    cost_prestige = 200   # Can also cost prestige

    county_modifier = {
        levy_size = 0.1
        tax_mult = 0.1
    }

    duchy_capital_county_modifier = {
        # Applied to ALL counties in the duchy, not just the capital
        development_growth_factor = 0.1
    }

    is_enabled = {
        always = yes
    }
    can_construct = {
        always = yes
    }

    type = duchy_capital

    ai_value = {
        base = 50
    }
}
```

### Special / Unique Building
Buildings tied to a specific barony (like Hagia Sophia):
```
my_special_building = {
    construction_time = 3650
    cost_gold = 1000

    county_modifier = {
        monthly_county_control_change_add = 0.3
        development_growth_factor = 0.2
    }

    character_modifier = {
        # Applied to the holder directly
        diplomacy = 2
        monthly_prestige = 0.5
    }

    is_enabled = {
        # Typically restricted to specific holdings
        barony = title:b_constantinople
    }
    can_construct = {
        always = yes
    }

    type = special

    # Special buildings often have no next_building (unique, single level)

    ai_value = {
        base = 100
    }
}
```

### Building with Terrain/Holding Type Restriction
```
my_port = {
    construction_time = 365
    cost_gold = 150

    county_modifier = {
        tax_mult = 0.1
    }

    is_enabled = {
        # Only in coastal counties
        is_coastal_county = yes
    }
    can_construct = {
        always = yes
    }

    type = regular

    ai_value = {
        base = 15
        modifier = {
            factor = 2
            is_coastal_county = yes
        }
    }
}
```

### Building with Culture/Innovation Requirement
```
my_advanced_building = {
    construction_time = 730
    cost_gold = 300

    county_modifier = {
        development_growth_factor = 0.15
    }

    is_enabled = {
        # Require a specific innovation
        culture = {
            has_innovation = innovation_battlements
        }
    }
    can_construct = {
        always = yes
    }

    type = regular

    ai_value = {
        base = 20
    }
}
```

### Graphical Background for Map
Buildings can define graphical assets for the 3D map:
```
my_castle_upgrade = {
    # ... normal building fields ...

    # Asset shown on the 3D map
    asset = {
        type = pdxmesh
        name = "building_western_castle_mesh"
        illustration = "gfx/interface/illustrations/building_types/my_castle.dds"
    }
}
```

## Map Objects
Map objects are separate from buildings but often paired with special buildings. They are defined in `gfx/map/map_object_data/`:
```
# gfx/map/map_object_data/my_building_objects.txt
# These define 3D models placed on the map

# Usually you reference existing meshes and locators
# Creating new map objects requires 3D modeling tools — out of scope for scripting
```

## Checklist
- [ ] Building defined in `common/buildings/` as `.txt` file
- [ ] All files UTF-8 BOM encoded
- [ ] `type` field set correctly (regular / special / duchy_capital)
- [ ] `cost_gold` and `construction_time` set
- [ ] `is_enabled` and `can_construct` triggers present
- [ ] `county_modifier` or `character_modifier` with valid modifiers
- [ ] `next_building` / `previous_building` chain is consistent
- [ ] Localization keys use `building_` prefix
- [ ] `ai_value` block present so AI will build it
- [ ] Icon at `gfx/interface/icons/buildings/<key>.dds` (if custom icon needed)

## Common Pitfalls
- **Wrong localization prefix**: Regular buildings use `building_<key>`, check vanilla for your specific type. Some special buildings use `building_type_<key>`.
- **Missing is_enabled**: Building won't appear in the construction list without this trigger.
- **Broken upgrade chain**: `next_building` in level 1 must match the key name of level 2, and level 2 needs `previous_building` pointing back.
- **Modifiers don't stack**: If you have both `county_modifier` and `duchy_capital_county_modifier`, they serve different purposes — county_modifier affects only the building's county, duchy_capital_county_modifier affects all counties in the duchy.
- **AI never builds**: Set `ai_value` with a reasonable base (10-100). Without it, AI ignores the building.
- **Cost too high/low for era**: Check vanilla buildings of the same era for reference costs. Early medieval buildings cost 50-200 gold, late medieval 200-600.
- **Building not showing in-game**: Check error.log for syntax errors. Verify the file is in the correct folder and has .txt extension.
- **Special building barony check**: For special buildings, make sure the barony title key exists in the game. Use `title:b_barony_name` format in is_enabled.
