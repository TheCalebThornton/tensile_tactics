# Tensile Tactics
2D Godot Tactical RPG

## Description
Tensile Tactics is a tactical role-playing game. Players lead a band of warriors through tactical turn-based battles while exploring a rich, fantasy-inspired world.

## Features
- Turn-based tactical combat system
- Characters and classes
- Series of levels (maps) with increasing difficulty
- Character progression
- Player map creation (import / export)

## Current Implementation
The current implementation includes:

- Basic grid-based movement system
- Unit classes (Warrior, Archer, Mage, Healer, Cavalry, Flier)
- Turn-based combat mechanics
- Terrain types with movement costs
- Simple AI for enemy units
- Map loading from JSON files
- Basic UI for unit information and combat

### Controls
- Arrow keys: Move cursor
- Enter/Space: Select unit or confirm action
- Escape: Cancel action
- E: End turn

## Architecture
The game is structured with the following components:

### Core Systems
- **GameManager**: Controls game state, turns, and overall flow
- **BattleManager**: Handles combat calculations and battle events
- **GridSystem**: Manages the tactical grid, movement ranges, and pathfinding
- **UnitManager**: Tracks all units on the battlefield
- **InputController**: Handles player input and cursor movement
- **MapLoader**: Loads and initializes maps from data files

### Entities
- **Unit**: Base class for all characters with common properties
- **Terrain**: Different tile types affecting movement and combat

### UI Components
- **BattleUI**: Combat interface showing unit stats and actions
- **GridCursor**: Visual cursor for selecting grid positions

### Data Management
- **MapData**: Stores map layouts and scenarios

## Getting Started
### Prerequisites
- Godot Engine 4.x
- Git (for version control)

### Installation
1. Clone the repository:
   ```
   git clone https://github.com/yourusername/tensile_tactics.git
   ```
2. Open the project in Godot Engine
3. Run the project using F5 or the "Play" button

## Development Status
🚧 Currently in early development

## Roadmap
- Implement complete battle mechanics
- Add more unit types and abilities
- Create a campaign with multiple maps
- Add character progression and equipment
- Implement save/load functionality
- Add sound effects and music
- Improve visuals with proper sprites and animations

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. 