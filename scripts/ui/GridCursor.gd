extends Node2D

class_name GridCursor

# Cursor properties
var current_position: Vector2i = Vector2i(0, 0)
var target_position: Vector2 = Vector2(0, 0)
var move_speed: float = 10.0

# References
var grid_system: GridSystem
var input_controller: InputController

# Visual properties
var cursor_color: Color = Color(1, 1, 0, 0.5)  # Yellow semi-transparent
var cursor_size: Vector2 = Vector2(64, 64)     # Should match grid cell size

func _ready():
	# Get references
	grid_system = get_node("/root/Main/GameManager/GridSystem")
	input_controller = get_node("/root/Main/GameManager/InputController")
	
	# Connect to input controller signals
	input_controller.cursor_moved.connect(_on_cursor_moved)
	
	# Set initial position
	current_position = Vector2i(0, 0)
	position = grid_system.grid_to_world(current_position)
	target_position = position

func _process(delta):
	# Smoothly move cursor to target position
	if position.distance_to(target_position) > 1.0:
		position = position.lerp(target_position, delta * move_speed)
	else:
		position = target_position

func _draw():
	# Draw cursor rectangle
	var rect = Rect2(-cursor_size.x / 2, -cursor_size.y / 2, cursor_size.x, cursor_size.y)
	draw_rect(rect, cursor_color, false, 3.0)  # 3.0 is border width
	
	# Draw diagonal lines for better visibility
	draw_line(Vector2(-cursor_size.x / 2, -cursor_size.y / 2), 
			  Vector2(cursor_size.x / 2, cursor_size.y / 2), 
			  cursor_color, 2.0)
	
	draw_line(Vector2(cursor_size.x / 2, -cursor_size.y / 2), 
			  Vector2(-cursor_size.x / 2, cursor_size.y / 2), 
			  cursor_color, 2.0)

# Handle cursor movement
func _on_cursor_moved(grid_pos: Vector2i):
	current_position = grid_pos
	target_position = grid_system.grid_to_world(grid_pos)
	queue_redraw()

# Set cursor position directly
func set_grid_position(grid_pos: Vector2i):
	current_position = grid_pos
	position = grid_system.grid_to_world(grid_pos)
	target_position = position
	queue_redraw()

# Flash the cursor (for highlighting)
func flash():
	# Simple animation to make cursor more visible
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0.2), 0.3)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1.0), 0.3) 
