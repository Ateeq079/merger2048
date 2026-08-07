class_name Board
extends Control

const TileViewScene = preload("res://scenes/tile_view.tscn")

@export var cell_margin: float = 12.0
@export var tile_size: float = 100.0

var _tile_views: Dictionary = {} # tile_id -> TileView
var _theme_config: ThemeConfig
var _empty_cells_node: Control
var _tiles_container: Control
var _input_handler: InputHandler

func _ready():
	_theme_config = GameState.config.get("theme_config") if GameState.config.get("theme_config") != null else ThemeConfig.new()
	
	_empty_cells_node = Control.new()
	add_child(_empty_cells_node)
	
	_tiles_container = Control.new()
	add_child(_tiles_container)
	
	_input_handler = InputHandler.new()
	add_child(_input_handler)
	_input_handler.swipe_detected.connect(_on_swipe_detected)
	
	GameState.board_changed.connect(_on_board_changed)
	GameState.game_started.connect(_on_game_started)
	
	_draw_empty_grid()

func _draw_empty_grid():
	for child in _empty_cells_node.get_children():
		child.queue_free()
		
	var grid_size = GameState.config.grid_size
	var expected_size = Vector2(
		grid_size.x * tile_size + (grid_size.x + 1) * cell_margin,
		grid_size.y * tile_size + (grid_size.y + 1) * cell_margin
	)
	custom_minimum_size = expected_size
	size = expected_size
	set_anchors_and_offsets_preset(PRESET_CENTER)
	
	_empty_cells_node.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_tiles_container.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	
	var bg = Panel.new()
	bg.set_anchors_preset(PRESET_FULL_RECT)
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(1, 1, 1, 1) # Solid white so shader can read alpha mask
	bg_style.corner_radius_top_left = 16
	bg_style.corner_radius_top_right = 16
	bg_style.corner_radius_bottom_left = 16
	bg_style.corner_radius_bottom_right = 16
	bg_style.border_width_left = 2
	bg_style.border_width_top = 2
	bg_style.border_width_right = 2
	bg_style.border_width_bottom = 2
	bg_style.border_color = Color(1, 1, 1, 0.4) # Frosty border
	bg_style.shadow_color = Color(0, 0, 0, 0.2) # Lighter drop shadow
	bg_style.shadow_size = 12
	bg_style.shadow_offset = Vector2(0, 6)
	bg.add_theme_stylebox_override("panel", bg_style)
	
	var glass_shader = preload("res://assets/glass.gdshader")
	var glass_mat = ShaderMaterial.new()
	glass_mat.shader = glass_shader
	glass_mat.set_shader_parameter("blur_amount", 2.5)
	glass_mat.set_shader_parameter("mix_color", Color(1.0, 1.0, 1.0, 0.25))
	bg.material = glass_mat
	
	_empty_cells_node.add_child(bg)
	
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var cell = Panel.new()
			var cell_style = StyleBoxFlat.new()
			cell_style.bg_color = _theme_config.empty_cell_color
			cell_style.corner_radius_top_left = 12
			cell_style.corner_radius_top_right = 12
			cell_style.corner_radius_bottom_left = 12
			cell_style.corner_radius_bottom_right = 12
			cell.add_theme_stylebox_override("panel", cell_style)
			
			cell.size = Vector2(tile_size, tile_size)
			cell.position = _get_cell_pos(Vector2i(x, y))
			_empty_cells_node.add_child(cell)

func _get_cell_pos(grid_pos: Vector2i) -> Vector2:
	return Vector2(
		cell_margin + grid_pos.x * (tile_size + cell_margin),
		cell_margin + grid_pos.y * (tile_size + cell_margin)
	)

func _on_swipe_detected(direction: Vector2i):
	GameState.attempt_move(direction)

func _on_game_started():
	for tv in _tile_views.values():
		tv.queue_free()
	_tile_views.clear()

func _on_board_changed(move_result: Dictionary):
	_input_handler.input_locked = true
	var tweens = []
	
	if move_result.get("initial_spawn", false) or move_result.get("is_undo", false):
		for tv in _tile_views.values():
			tv.queue_free()
		_tile_views.clear()
		
		for x in range(GameState.config.grid_size.x):
			for y in range(GameState.config.grid_size.y):
				var tile = GameState.grid_state.get_tile(Vector2i(x, y))
				if tile != null:
					_spawn_tile(tile, Vector2i(x, y))
		_input_handler.input_locked = false
		return
		
	if not move_result.valid:
		var dir = Vector2.ZERO
		# Try to figure out swipe direction from input history? 
		# We can just bump the whole board slightly
		var tween = AnimationJuice.bump(self, Vector2(0, 5))
		tween.finished.connect(func(): _input_handler.input_locked = false)
		AudioManager.play_bump()
		return
		
	# 1. Animate movements
	var max_duration = 0.0
	for m in move_result.movements:
		var tv = _tile_views[m.id]
		var target_pos = _get_cell_pos(m.to)
		var tween = AnimationJuice.slide(tv, target_pos)
		tweens.append(tween)
		AudioManager.play_swipe()
		
	# 2. Wait for slides to finish, then process merges
	var slide_timer = get_tree().create_timer(0.12)
	await slide_timer.timeout
	
	for merge in move_result.merges:
		var survivor = _tile_views[merge.survivor_id]
		var destroyed = _tile_views[merge.destroyed_id]
		
		survivor.update_value(merge.new_value)
		_tiles_container.move_child(survivor, -1) # Bring to front
		
		AnimationJuice.merge_pop(survivor)
		
		_tile_views.erase(merge.destroyed_id)
		destroyed.queue_free()
		
		AudioManager.play_merge(merge.new_value)
		
		if merge.new_value >= 256:
			AnimationJuice.shake(self)
			var color = _theme_config.exact_tile_colors.get(merge.new_value, Color.WHITE)
			var center_pos = _get_cell_pos(merge.to) + Vector2(tile_size / 2.0, tile_size / 2.0)
			AnimationJuice.particle_explosion(self, center_pos, color)
			
	# 3. Spawn new tile
	if move_result.has("new_tile"):
		var nt = move_result.new_tile
		var tile_obj = Tile.new(nt.id, nt.value)
		_spawn_tile(tile_obj, nt.pos)
		
	_input_handler.input_locked = false

func _spawn_tile(tile: Tile, pos: Vector2i):
	var tv = TileViewScene.instantiate()
	_tiles_container.add_child(tv)
	tv.setup(tile.id, tile.value, _theme_config)
	tv.position = _get_cell_pos(pos)
	_tile_views[tile.id] = tv
	
	AnimationJuice.spawn(tv)
