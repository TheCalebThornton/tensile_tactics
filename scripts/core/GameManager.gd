extends Node

class_name GameManager

# Game states
enum GameState {
	MAIN_MENU,
	BATTLE_PREPARATION,
	PLAYER_TURN,
	ENEMY_TURN,
	CUTSCENE,
	GAME_OVER,
	VICTORY
}

# Current game state
var current_state: int = GameState.MAIN_MENU

# References to other managers
var battle_manager: BattleManager
var unit_manager: UnitManager
var grid_system: GridSystem
var map_loader: MapLoader
var input_controller: InputController

# Current map/level information
var current_map: String = ""
var current_level: int = 0

# Signal for state changes
signal state_changed(new_state: int)

func _ready():
	# Initialize managers
	battle_manager = $BattleManager
	unit_manager = $UnitManager
	grid_system = $GridSystem
	map_loader = $MapLoader
	input_controller = $InputController
	
	# Wait a frame to ensure all nodes are ready
	await get_tree().process_frame
	
	# Load the tutorial map
	if map_loader.load_map("res://maps/tutorial_map.json"):
		# Start the game with player turn
		change_state(GameState.PLAYER_TURN)
	else:
		print("Failed to load tutorial map")

func change_state(new_state: int) -> void:
	var old_state = current_state
	current_state = new_state
	
	# Handle state transition logic
	match new_state:
		GameState.PLAYER_TURN:
			start_player_turn()
		GameState.ENEMY_TURN:
			start_enemy_turn()
		GameState.VICTORY:
			handle_victory()
		GameState.GAME_OVER:
			handle_game_over()
	
	# Emit signal for UI and other systems
	state_changed.emit(new_state)

func start_player_turn() -> void:
	# Reset action points, movement, etc.
	unit_manager.prepare_player_units_for_turn()
	
	# Enable player input
	# Input controller handles this via signal

func start_enemy_turn() -> void:
	# AI processing for enemy units
	unit_manager.prepare_enemy_units_for_turn()
	
	# Start AI processing
	# For now, just end enemy turn immediately
	# In a real game, you'd implement AI here
	await get_tree().create_timer(1.0).timeout
	end_enemy_turn()

func end_player_turn() -> void:
	# Check if all player units have acted
	if not unit_manager.are_all_player_units_done():
		# Force end turn for remaining units
		for unit in unit_manager.player_units:
			if unit.can_move or unit.can_act:
				unit_manager.end_unit_turn(unit)
	
	change_state(GameState.ENEMY_TURN)

func end_enemy_turn() -> void:
	# Check for victory conditions
	if map_loader.check_victory_condition():
		change_state(GameState.VICTORY)
	else:
		change_state(GameState.PLAYER_TURN)

func handle_victory() -> void:
	# Save progress, show victory screen, etc.
	print("Victory!")
	
	# In a real game, you'd show a victory screen
	# For now, just restart the level after a delay
	await get_tree().create_timer(3.0).timeout
	restart_level()

func handle_game_over() -> void:
	# Show game over screen, offer restart, etc.
	print("Game Over!")
	
	# In a real game, you'd show a game over screen
	# For now, just restart the level after a delay
	await get_tree().create_timer(3.0).timeout
	restart_level()

func load_level(level_number: int) -> void:
	current_level = level_number
	
	# Load specific map based on level number
	var map_path = "res://maps/tutorial_map.json"
	
	if map_loader.load_map(map_path):
		change_state(GameState.PLAYER_TURN)
	else:
		print("Failed to load level ", level_number)

func restart_level() -> void:
	# Reload the current level
	load_level(current_level)

# Handle input for ending the player's turn
func _input(event):
	if current_state == GameState.PLAYER_TURN:
		if event.is_action_pressed("ui_end_turn"):
			end_player_turn() 
