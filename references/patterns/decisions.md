# Creating Decisions — Practical Recipe

## What You Need to Know First
Decisions are optional actions available to the player (and optionally AI) through the decision panel. They require a script file in `common/decisions/` and localization entries.
> Reference docs: references/wiki/wiki_pages/Decisions_modding.md

## Minimal Template

### common/decisions/my_decisions.txt
```
my_first_decision = {
	picture = {
		reference = "gfx/interface/illustrations/decisions/decision_misc.dds"
	}

	desc = my_first_decision_desc
	selection_tooltip = my_first_decision_tooltip

	is_shown = {
		is_ruler = yes
	}

	is_valid = {
		gold >= 100
	}

	cost = {
		gold = 100
	}

	effect = {
		add_prestige = 200
	}

	ai_check_interval = 0
}
```

### localization/english/my_decisions_l_english.yml
```
l_english:
 my_first_decision: "My First Decision"
 my_first_decision_desc: "Description shown when you open it."
 my_first_decision_tooltip: "Tooltip shown when hovering over it."
 my_first_decision_confirm: "Confirm"
```

## Annotated Vanilla Example
<!-- TODO: Add a real vanilla example. Run:
grep -rn "is_shown" $CK3_GAME_PATH/common/decisions/ | head -5
and annotate the simplest result. -->

## Common Variants

### Major decision (with confirmation event)
```
my_major_decision = {
	picture = {
		reference = "gfx/interface/illustrations/decisions/decision_realm.dds"
	}
	decision_group_type = major

	is_shown = {
		is_ruler = yes
		highest_held_title_tier >= tier_kingdom
	}

	is_valid_showing_failures_only = {
		is_available_adult = yes
		is_at_war = no
	}

	is_valid = {
		prestige_level >= 3
		gold >= 500
	}

	cost = {
		gold = 500
		prestige = 1000
	}

	effect = {
		trigger_event = my_mod.1000
		add_character_modifier = {
			modifier = my_decision_cooldown
			years = 10
		}
	}

	ai_check_interval = 120
	ai_potential = {
		highest_held_title_tier >= tier_kingdom
	}
	ai_will_do = {
		base = 50
		modifier = {
			factor = 2
			gold >= 1000
		}
	}
}
```

### Decision with cooldown
```
my_repeatable_decision = {
	# ...
	cooldown = { years = 5 }
	# ...
}
```

### Decision with AI logic (using weight modifiers)
```
ai_will_do = {
	base = 100
	modifier = {
		factor = 0
		is_ai = no
	}
	modifier = {
		factor = 2
		gold >= 500
	}
	modifier = {
		factor = 0.5
		is_at_war = yes
	}
}
```

## Checklist
- [ ] Decision file in `common/decisions/` with `.txt` extension
- [ ] 4 localization keys: `decision_name`, `_desc`, `_tooltip`, `_confirm`
- [ ] Localization file encoded as UTF-8 BOM
- [ ] `is_shown` block (when to display the decision)
- [ ] `effect` block (what happens when taken)
- [ ] `ai_check_interval` set (0 = AI never considers it)
- [ ] Test with console: `effect remove_decision_cooldown = my_decision` to reset cooldown

## Common Pitfalls
- **AI never takes the decision**: `ai_check_interval` is set to 0 (default). Set it to a positive number (in months). Also ensure `ai_potential` and `ai_will_do` are configured
- **Decision doesn't show up**: Check `is_shown` conditions. The decision only appears for characters who meet ALL conditions
- **Missing localization**: Need all 4 keys. Default keys use the decision name as the base
- **Cost not deducted**: If you handle cost in an event, use `minimum_cost` instead of `cost`. The `minimum_cost` block checks the character can afford it but doesn't deduct
- **`is_valid` vs `is_valid_showing_failures_only`**: Both must be true to take the decision. `is_valid_showing_failures_only` only shows failed conditions in the tooltip, good for obvious requirements like `is_available_adult`

## Widget Patterns

Decisions can have custom widget selection UIs:
```
my_decision = {
    # ... other fields ...

    widget = {
        gui = "decision_view_widget_generic_list"
        controller = decision_option_list_controller

        item = {
            is_valid = { always = yes }
            current_description = my_decision_option_desc
            localization_values = {
                VALUE = scope:value
            }
            effect = {
                # Applied when this option is selected
            }
        }
    }
}
```

## ai_goal

AI decision-making enhancement. The `ai_goal` block makes the AI actively work TOWARD meeting `is_valid` conditions:
```
my_decision = {
    ai_check_interval = 36  # months

    ai_potential = {
        # Lightweight filter — checked BEFORE ai_will_do
        is_adult = yes
        is_landed = yes
    }

    ai_will_do = {
        base = 0

        modifier = {
            add = 100
            gold >= 500
        }

        # ai_goal weights make AI actively work TOWARD meeting is_valid conditions
        ai_goal = {
            gold >= 300
            weight = 50
        }
    }
}
```

## Dynamic Descriptions for Decisions

Similar to events, decisions support dynamic desc using `first_valid` and `triggered_desc`:
```
my_decision = {
    desc = {
        first_valid = {
            triggered_desc = {
                trigger = { is_ruler = yes }
                desc = my_decision_desc_ruler
            }
            desc = my_decision_desc_default
        }
    }
}
```
