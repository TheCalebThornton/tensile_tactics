extends CanvasLayer

class_name BattleUI

# UI elements
@onready var unit_info_panel = $UnitInfoPanel
@onready var action_menu = $ActionMenu
@onready var combat_forecast = $CombatForecast
@onready var turn_indicator = $TurnIndicator

# References to game systems
var game_manager: GameManager
var unit_manager: UnitManager
var battle_manager: BattleManager

func _ready():
	# Get references to managers
	game_manager = get_node("/root/Main/GameManager")
	unit_manager = game_manager.unit_manager
	battle_manager = game_manager.battle_manager
	
	# Connect signals
	game_manager.state_changed.connect(_on_game_state_changed)
	unit_manager.unit_selected.connect(_on_unit_selected)
	unit_manager.unit_deselected.connect(_on_unit_deselected)
	battle_manager.combat_started.connect(_on_combat_started)
	battle_manager.combat_ended.connect(_on_combat_ended)
	
	# Hide UI elements initially
	unit_info_panel.hide()
	action_menu.hide()
	combat_forecast.hide()
	
	# Update turn indicator
	update_turn_indicator(game_manager.current_state)

# Update the turn indicator based on game state
func update_turn_indicator(state: int) -> void:
	match state:
		GameManager.GameState.PLAYER_TURN:
			turn_indicator.text = "Player Phase"
			turn_indicator.modulate = Color(0, 0.5, 1)  # Blue for player
		GameManager.GameState.ENEMY_TURN:
			turn_indicator.text = "Enemy Phase"
			turn_indicator.modulate = Color(1, 0, 0)  # Red for enemy
		_:
			turn_indicator.text = ""

# Show unit information
func show_unit_info(unit: Unit) -> void:
	unit_info_panel.show()
	
	# Update unit info panel with unit data
	var unit_info = unit_info_panel.get_node("UnitInfo")
	unit_info.get_node("Name").text = unit.unit_name
	unit_info.get_node("Class").text = Unit.UnitClass.keys()[unit.unit_class]
	unit_info.get_node("Level").text = "Lv. %d" % unit.level
	unit_info.get_node("HP").text = "HP: %d/%d" % [unit.health, unit.max_health]
	
	# Update stats
	var stats = unit_info_panel.get_node("Stats")
	stats.get_node("Attack").text = "ATK: %d" % unit.attack
	stats.get_node("Defense").text = "DEF: %d" % unit.defense
	stats.get_node("Magic").text = "MAG: %d" % unit.magic
	stats.get_node("Resistance").text = "RES: %d" % unit.resistance
	stats.get_node("Speed").text = "SPD: %d" % unit.speed
	stats.get_node("Movement").text = "MOV: %d" % unit.movement

# Hide unit information
func hide_unit_info() -> void:
	unit_info_panel.hide()

# Show action menu for a unit
func show_action_menu(unit: Unit) -> void:
	action_menu.show()
	
	# Clear existing buttons
	for child in action_menu.get_children():
		if child is Button:
			child.queue_free()
	
	# Add action buttons based on unit state
	if unit.can_act:
		var attack_button = Button.new()
		attack_button.text = "Attack"
		attack_button.pressed.connect(func(): _on_attack_pressed(unit))
		action_menu.add_child(attack_button)
		
		# Add other action buttons (items, skills, etc.)
		# ...
	
	# Always add Wait button
	var wait_button = Button.new()
	wait_button.text = "Wait"
	wait_button.pressed.connect(func(): _on_wait_pressed(unit))
	action_menu.add_child(wait_button)

# Hide action menu
func hide_action_menu() -> void:
	action_menu.hide()

# Show combat forecast between two units
func show_combat_forecast(attacker: Unit, defender: Unit) -> void:
	combat_forecast.show()
	
	# Calculate hit chance
	var hit_chance = battle_manager.calculate_hit_chance(attacker, defender) * 100
	
	# Calculate damage
	var damage = battle_manager.calculate_damage(attacker, defender)
	
	# Calculate critical chance
	var crit_chance = attacker.critical
	
	# Update attacker info
	var attacker_info = combat_forecast.get_node("AttackerInfo")
	attacker_info.get_node("Name").text = attacker.unit_name
	attacker_info.get_node("HP").text = "HP: %d/%d" % [attacker.health, attacker.max_health]
	attacker_info.get_node("Damage").text = "DMG: %d" % damage
	attacker_info.get_node("Hit").text = "HIT: %d%%" % hit_chance
	attacker_info.get_node("Crit").text = "CRIT: %d%%" % crit_chance
	
	# Check if defender can counter
	if battle_manager.can_counter_attack(attacker, defender):
		# Calculate defender's counter stats
		var counter_hit = battle_manager.calculate_hit_chance(defender, attacker) * 100
		var counter_damage = battle_manager.calculate_damage(defender, attacker)
		var counter_crit = defender.critical
		
		# Update defender info
		var defender_info = combat_forecast.get_node("DefenderInfo")
		defender_info.get_node("Name").text = defender.unit_name
		defender_info.get_node("HP").text = "HP: %d/%d" % [defender.health, defender.max_health]
		defender_info.get_node("Damage").text = "DMG: %d" % counter_damage
		defender_info.get_node("Hit").text = "HIT: %d%%" % counter_hit
		defender_info.get_node("Crit").text = "CRIT: %d%%" % counter_crit
	else:
		# Defender cannot counter
		var defender_info = combat_forecast.get_node("DefenderInfo")
		defender_info.get_node("Name").text = defender.unit_name
		defender_info.get_node("HP").text = "HP: %d/%d" % [defender.health, defender.max_health]
		defender_info.get_node("Damage").text = "DMG: --"
		defender_info.get_node("Hit").text = "HIT: --"
		defender_info.get_node("Crit").text = "CRIT: --"

# Hide combat forecast
func hide_combat_forecast() -> void:
	combat_forecast.hide()

# Handle game state changes
func _on_game_state_changed(new_state: int) -> void:
	update_turn_indicator(new_state)
	
	# Hide UI elements on state change
	hide_unit_info()
	hide_action_menu()
	hide_combat_forecast()

# Handle unit selection
func _on_unit_selected(unit: Unit) -> void:
	show_unit_info(unit)
	
	# Show action menu if it's a player unit and player's turn
	if unit.faction == Unit.Faction.PLAYER and game_manager.current_state == GameManager.GameState.PLAYER_TURN:
		show_action_menu(unit)

# Handle unit deselection
func _on_unit_deselected() -> void:
	hide_unit_info()
	hide_action_menu()
	hide_combat_forecast()

# Handle combat start
func _on_combat_started(attacker: Unit, defender: Unit) -> void:
	# Hide other UI elements during combat
	hide_action_menu()
	
	# Show combat animation or effects
	# This would be implemented with animations
	pass

# Handle combat end
func _on_combat_ended(attacker: Unit, defender: Unit, defeated: bool) -> void:
	# Update UI after combat
	if unit_manager.selected_unit:
		show_unit_info(unit_manager.selected_unit)
	
	# Show result message or animation
	# This would be implemented with animations or popups
	pass

# Handle attack button press
func _on_attack_pressed(unit: Unit) -> void:
	# Enter attack target selection mode
	# This would be implemented with input handling
	hide_action_menu()
	
	# For now, just end the unit's turn
	unit_manager.end_unit_turn(unit)

# Handle wait button press
func _on_wait_pressed(unit: Unit) -> void:
	# End the unit's turn
	unit_manager.end_unit_turn(unit)
	hide_action_menu() 
