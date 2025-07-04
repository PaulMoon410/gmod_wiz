# Wizard NPC - Advanced AI Edition

A sophisticated Garry's Mod addon featuring an intelligent wizard NPC with advanced AI capabilities, spell-casting, and learning systems.

## 🧙‍♂️ Features

### Advanced AI System
- **Intelligent Decision Making**: Wizards analyze situations and choose optimal spells
- **Learning System**: Adapts spell usage based on effectiveness over time
- **Memory System**: Remembers enemies and their threat levels
- **Tactical Positioning**: Uses cover, kiting, and strategic movement
- **Personality Types**: 4 distinct AI personalities with unique behaviors

### Spell System
- **Fireball**: Explosive projectile with area damage and burn effects
- **Lightning**: Instant-hit electrical attack with area effect
- **Heal**: Self-healing magic with smart usage
- **Teleport**: Tactical repositioning and escape ability

### AI Personalities
1. **Aggressive**: Close-range fighter, low retreat threshold, prefers offensive spells
2. **Defensive**: Long-range combatant, uses cover, prefers defensive spells  
3. **Balanced**: Well-rounded approach, adapts to situations
4. **Chaotic**: Unpredictable behavior, random spell selection and movement

### Smart Combat Features
- **Target Prediction**: Leads moving targets for better accuracy
- **Threat Assessment**: Prioritizes dangerous enemies
- **Cover Usage**: Finds and uses environmental cover
- **Kiting Behavior**: Maintains optimal combat distance
- **Multi-target Awareness**: Handles multiple enemies intelligently

## 🎮 Installation

1. Download the addon files
2. Extract to your `garrysmod/addons/` folder
3. Restart Garry's Mod or reload the map
4. The wizard NPC will appear in your Entities tab

## 🔧 Admin Commands

### Spawning Commands
- `wizard_spawn <personality>` - Spawn a wizard with specific personality
  - Available personalities: `aggressive`, `defensive`, `balanced`, `chaotic`
  - Example: `wizard_spawn aggressive`

### Management Commands  
- `wizard_info` - Get detailed information about a wizard (look at one first)
- `wizard_removeall` - Remove all wizard NPCs from the map
- `wizard_debug` - Toggle AI debug mode for development

### Usage Examples
```
wizard_spawn chaotic     # Spawns unpredictable wizard
wizard_spawn defensive   # Spawns cautious, cover-using wizard
wizard_info             # Shows wizard stats and AI state
```

## ⚙️ Configuration

Edit `lua/autorun/wizard_config.lua` to customize:

### Basic Settings
- Health, mana, movement speeds
- Spell damage and mana costs
- Combat ranges and cooldowns

### AI Behavior
- Learning system parameters
- Memory and threat assessment
- Tactical behavior settings
- Personality system weights

### Performance Options
- AI update intervals
- Memory cleanup settings
- Particle effect density
- Maximum wizard count

## 🧠 AI System Details

### Learning Mechanism
The wizard tracks:
- Spell hit rates and effectiveness
- Enemy damage patterns
- Successful tactical decisions
- Environmental factors

This data influences future spell selection and tactical choices.

### Memory System
Wizards remember:
- Previously encountered enemies
- Damage dealt and received
- Enemy movement patterns
- Threat levels over time

### Tactical AI
Advanced positioning includes:
- **Cover Seeking**: Finds walls and obstacles for protection
- **Kiting**: Maintains optimal distance from fast enemies  
- **Flanking**: Attempts to get better angles on targets
- **Retreat Planning**: Strategic withdrawal when outmatched

## 🎯 Balancing

The AI is designed to be challenging but fair:
- Mana limitations prevent spell spam
- Cooldowns create strategic timing
- Learning system starts neutral and adapts
- Personality types provide variety without being overpowered

## 🔨 Technical Details

### File Structure
```
lua/
├── autorun/
│   └── wizard_config.lua        # Configuration settings
├── entities/
│   ├── npc_wizard/              # Main wizard NPC
│   │   ├── init.lua            # Server-side AI logic
│   │   ├── cl_init.lua         # Client-side rendering
│   │   └── shared.lua          # Shared properties
│   └── ent_wizard_fireball/     # Fireball projectile
└── effects/                     # Visual effects
    ├── wizard_aura/
    ├── wizard_lightning/
    ├── wizard_heal/
    ├── wizard_death/
    ├── wizard_teleport_in/
    └── wizard_teleport_out/
```

### Performance Considerations
- Optimized Think() functions with appropriate intervals
- Memory cleanup prevents data accumulation
- Particle effects scale with server performance
- AI complexity reduces when players are distant

## 🐛 Troubleshooting

### Common Issues
1. **Wizards not spawning**: Check console for Lua errors
2. **Poor performance**: Reduce particle density in config
3. **AI not working**: Ensure all files are properly placed
4. **Spell effects missing**: Verify effects folder is complete

### Debug Mode
Use `wizard_debug` command to enable detailed AI logging and visual indicators.

## 🔄 Compatibility

- Compatible with most GMod gamemodes
- Works with other NPC mods
- Faction system allows integration with warfare mods
- No external dependencies required

## 📊 AI Statistics

The learning system tracks:
- Spell effectiveness percentages
- Enemy encounter history  
- Tactical decision success rates
- Personality behavior patterns

Access this data using the `wizard_info` command on spawned wizards.

## 🎨 Customization

### Adding New Personalities
Edit the personality system in `wizard_config.lua` to create custom AI behavior patterns.

### Modifying Spells
Adjust spell parameters, add new effects, or create entirely new spell types.

### Visual Customization
Replace models, textures, and particle effects to match your server theme.

## 📝 License

Free to use and modify for Garry's Mod servers. Credit appreciated but not required.

## 🤝 Contributing

Suggestions and improvements welcome! The AI system is designed to be expandable and modular.

---

*Created for Garry's Mod - Bringing intelligent magic to your sandbox experience!*
