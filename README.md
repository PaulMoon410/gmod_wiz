# Wizard NPC for Garry's Mod

A fully functional wizard NPC for Garry's Mod that features magical combat, spell casting, and intelligent AI behavior.

## Features

### 🧙‍♂️ Intelligent AI Behavior
- **Patrol System**: Wizards patrol around their spawn area when not in combat
- **Combat AI**: Engages enemies with magical spells and tactical positioning
- **Flee Behavior**: Retreats and attempts to heal when health is low
- **Target Prioritization**: Automatically finds and engages the closest threat

### ⚡ Spell System
- **Fireball**: Explosive projectile that deals area damage and ignites targets
- **Lightning Bolt**: Instant damage spell with electrical effects
- **Heal**: Self-healing spell used when health is low
- **Mana Management**: Each spell consumes mana which regenerates over time

### 🎮 Visual Effects
- **Particle Systems**: Custom magical effects for all spells
- **Mana Bar**: Visual mana indicator above the wizard
- **Magical Aura**: Ambient particles around the wizard
- **Death Effects**: Spectacular magical explosion on death

### ⚙️ Configurable Settings
- Health, mana, and movement speed
- Spell damage and mana costs
- AI behavior parameters
- Visual and audio effects

## Installation

1. **Download**: Download the wizard addon files
2. **Extract**: Extract the `wizard` folder to your Garry's Mod addons directory:
   ```
   Steam/steamapps/common/GarrysMod/garrysmod/addons/
   ```
3. **Restart**: Restart Garry's Mod or change maps to load the addon

## Usage

### Spawning a Wizard
1. Open the spawn menu (Q key by default)
2. Go to the **NPCs** tab
3. Look for **"Wizard"** in the NPC list
4. Click to spawn the wizard NPC

### Console Commands
```lua
-- Spawn a wizard at your crosshair position
ent_create npc_wizard

-- Remove all wizards from the map
ent_remove npc_wizard
```

## Configuration

Edit `lua/autorun/wizard_config.lua` to customize the wizard's behavior:

### Health & Combat
```lua
WizardConfig.Health = 150           -- Wizard health
WizardConfig.AttackRange = 800      -- Attack range in units
WizardConfig.FleeHealthPercent = 0.2 -- Health % to start fleeing
```

### Spells & Mana
```lua
WizardConfig.MaxMana = 100          -- Maximum mana
WizardConfig.ManaRegen = 2          -- Mana regeneration per second
WizardConfig.ManaCost = {           -- Mana cost for each spell
    fireball = 25,
    lightning = 30,
    heal = 20
}
```

### AI Behavior
```lua
WizardConfig.PatrolRadius = 400     -- Patrol area around spawn
WizardConfig.AlertRadius = 600      -- Enemy detection range
WizardConfig.SpellCooldown = 3      -- Seconds between spells
```

## Spell Details

### 🔥 Fireball
- **Damage**: 30-50 (area damage)
- **Mana Cost**: 25
- **Effect**: Explosive projectile that ignites targets
- **Range**: 800 units

### ⚡ Lightning Bolt
- **Damage**: 25-40 (instant)
- **Mana Cost**: 30
- **Effect**: Instant electrical damage
- **Range**: 800 units

### 💚 Heal
- **Healing**: 20-35 HP
- **Mana Cost**: 20
- **Effect**: Self-healing with visual effects
- **Usage**: Automatically used when health is low

## Compatibility

### Requirements
- Garry's Mod (any recent version)
- No additional dependencies required

### Mod Compatibility
- Compatible with most NPC and AI mods
- Works with custom maps and game modes
- Faction system ready for integration with other mods

## Troubleshooting

### Common Issues

**Wizard not spawning:**
- Check console for Lua errors
- Ensure all files are in the correct directories
- Restart Garry's Mod

**Missing effects:**
- Verify all effect files are present in `lua/effects/`
- Check that particle effects are enabled in game settings

**Poor performance:**
- Reduce the number of wizards on the map
- Disable particle effects in the config file

### Console Commands for Debugging
```lua
-- Check for Lua errors
lua_log_sv 1

-- Print wizard status
lua_run PrintTable(ents.FindByClass("npc_wizard"))

-- Reload the addon (server only)
lua_run include("entities/npc_wizard/init.lua")
```

## File Structure
```
wizard/
├── addon.json                          # Addon metadata
├── lua/
│   ├── entities/
│   │   ├── npc_wizard/
│   │   │   ├── init.lua                 # Server-side wizard logic
│   │   │   ├── cl_init.lua             # Client-side effects
│   │   │   └── shared.lua              # Shared entity data
│   │   └── ent_wizard_fireball/
│   │       ├── init.lua                # Fireball projectile
│   │       ├── cl_init.lua            # Fireball effects
│   │       └── shared.lua             # Shared projectile data
│   ├── effects/
│   │   ├── wizard_lightning/
│   │   ├── wizard_heal/
│   │   ├── wizard_death/
│   │   └── wizard_aura/
│   └── autorun/
│       └── wizard_config.lua           # Configuration file
└── README.md                           # This file
```

## Credits

Created for Garry's Mod community. Feel free to modify and distribute.

## License

This addon is free to use and modify. Credit is appreciated but not required.

---

**Enjoy your magical NPCs!** 🧙‍♂️✨
