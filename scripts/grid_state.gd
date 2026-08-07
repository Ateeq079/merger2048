class_name GridState
extends RefCounted

const GridConfig = preload("res://scripts/grid_config.gd")
const Tile = preload("res://scripts/tile.gd")

var config: GridConfig
var grid: Array[Array]
var _next_tile_id: int = 1

func _init(p_config: GridConfig):
	config = p_config
	_init_grid()

func _init_grid() -> void:
	grid.clear()
	for x in range(config.grid_size.x):
		var col: Array[Tile] = []
		for y in range(config.grid_size.y):
			col.append(null)
		grid.append(col)

func get_tile(pos: Vector2i) -> Tile:
	if pos.x >= 0 and pos.x < config.grid_size.x and pos.y >= 0 and pos.y < config.grid_size.y:
		return grid[pos.x][pos.y]
	return null

func set_tile(pos: Vector2i, tile: Tile) -> void:
	if pos.x >= 0 and pos.x < config.grid_size.x and pos.y >= 0 and pos.y < config.grid_size.y:
		grid[pos.x][pos.y] = tile

func get_empty_cells() -> Array[Vector2i]:
	var empty_cells: Array[Vector2i] = []
	for x in range(config.grid_size.x):
		for y in range(config.grid_size.y):
			if grid[x][y] == null:
				empty_cells.append(Vector2i(x, y))
	return empty_cells

func spawn_random_tile() -> Tile:
	var empty_cells = get_empty_cells()
	if empty_cells.is_empty():
		return null
		
	var target_cell = empty_cells[randi() % empty_cells.size()]
	var value = 2
	var rand_val = randf()
	if config.spawn_weights.has(4) and rand_val < config.spawn_weights[4]:
		value = 4
		
	var tile = Tile.new(_next_tile_id, value)
	_next_tile_id += 1
	set_tile(target_cell, tile)
	return tile

func force_spawn_tile(pos: Vector2i, id: int, value: int) -> void:
	var tile = Tile.new(id, value)
	set_tile(pos, tile)
	if id >= _next_tile_id:
		_next_tile_id = id + 1

func attempt_move(direction: Vector2i) -> Dictionary:
	var move_result = {
		"valid": false,
		"score_increase": 0,
		"movements": [], # {id: int, from: Vector2i, to: Vector2i}
		"merges": [] # {survivor_id: int, destroyed_id: int, to: Vector2i, new_value: int}
	}
	
	for x in range(config.grid_size.x):
		for y in range(config.grid_size.y):
			if grid[x][y] != null:
				grid[x][y].just_merged = false
				
	var x_range = range(config.grid_size.x)
	var y_range = range(config.grid_size.y)
	
	if direction.x > 0:
		x_range.reverse()
	if direction.y > 0:
		y_range.reverse()
		
	for x in x_range:
		for y in y_range:
			var current_pos = Vector2i(x, y)
			var tile = get_tile(current_pos)
			
			if tile == null:
				continue
				
			var target_pos = current_pos
			var test_pos = current_pos + direction
			
			while test_pos.x >= 0 and test_pos.x < config.grid_size.x and test_pos.y >= 0 and test_pos.y < config.grid_size.y:
				var test_tile = get_tile(test_pos)
				if test_tile == null:
					target_pos = test_pos
					test_pos += direction
				elif test_tile.value == tile.value and not test_tile.just_merged:
					target_pos = test_pos
					break
				else:
					break
					
			if target_pos != current_pos:
				var target_tile = get_tile(target_pos)
				
				if target_tile == null:
					set_tile(target_pos, tile)
					set_tile(current_pos, null)
					move_result.valid = true
					move_result.movements.append({"id": tile.id, "from": current_pos, "to": target_pos})
				elif target_tile.value == tile.value:
					target_tile.value *= 2
					target_tile.just_merged = true
					set_tile(current_pos, null)
					move_result.valid = true
					move_result.score_increase += int(target_tile.value * config.merge_score_multiplier)
					move_result.movements.append({"id": tile.id, "from": current_pos, "to": target_pos})
					move_result.merges.append({
						"survivor_id": target_tile.id,
						"destroyed_id": tile.id,
						"to": target_pos,
						"new_value": target_tile.value
					})
					
	return move_result

func is_game_over() -> bool:
	if not get_empty_cells().is_empty():
		return false
		
	for x in range(config.grid_size.x):
		for y in range(config.grid_size.y):
			var tile = grid[x][y]
			var dirs = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
			for dir in dirs:
				var neighbor = get_tile(Vector2i(x, y) + dir)
				if neighbor != null and neighbor.value == tile.value:
					return false
	return true

func has_won() -> bool:
	for x in range(config.grid_size.x):
		for y in range(config.grid_size.y):
			if grid[x][y] != null and grid[x][y].value >= config.win_value:
				return true
	return false

func get_state() -> Dictionary:
	var tiles_data = []
	for x in range(config.grid_size.x):
		for y in range(config.grid_size.y):
			if grid[x][y] != null:
				tiles_data.append({
					"x": x, "y": y,
					"id": grid[x][y].id,
					"value": grid[x][y].value
				})
	return {
		"next_tile_id": _next_tile_id,
		"tiles": tiles_data
	}

func restore_state(state: Dictionary) -> void:
	_init_grid()
	_next_tile_id = state.next_tile_id
	for t_data in state.tiles:
		force_spawn_tile(Vector2i(t_data.x, t_data.y), t_data.id, t_data.value)
