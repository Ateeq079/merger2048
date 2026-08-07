extends Node

signal board_changed(move_result: Dictionary)
signal score_changed(new_score: int)
signal best_score_changed(new_score: int)
signal milestone_reached(value: int)
signal game_won()
signal game_over()
signal game_started()

const GridState = preload("res://scripts/grid_state.gd")
const GridConfig = preload("res://scripts/grid_config.gd")
const Tile = preload("res://scripts/tile.gd")

var grid_state: GridState
var current_score: int = 0
var best_score: int = 0
var config: GridConfig
var _won_already: bool = false
var _milestones_reached: Dictionary = {}
var history: Array[Dictionary] = []

func _ready():
	config = GridConfig.new()

func initialize():
	if SaveManager.has_save_data():
		SaveManager.load_game()
	else:
		start_new_game()

func start_from_save(save_data: Dictionary):
	grid_state = GridState.new(config)
	current_score = save_data.get("current_score", 0)
	best_score = save_data.get("best_score", 0)
	_won_already = false
	_milestones_reached.clear()
	history.clear()
	
	var grid_data = save_data.get("grid", [])
	for x in range(grid_data.size()):
		var col = grid_data[x]
		for y in range(col.size()):
			var cell = col[y]
			if cell != null:
				grid_state.force_spawn_tile(Vector2i(x, y), cell.id, cell.value)
				
	score_changed.emit(current_score)
	best_score_changed.emit(best_score)
	
	var initial_result = {
		"valid": true,
		"score_increase": 0,
		"movements": [],
		"merges": [],
		"initial_spawn": true
	}
	game_started.emit()
	board_changed.emit(initial_result)

func start_new_game():
	grid_state = GridState.new(config)
	current_score = 0
	_won_already = false
	_milestones_reached.clear()
	history.clear()
	
	score_changed.emit(current_score)
	
	grid_state.spawn_random_tile()
	grid_state.spawn_random_tile()
	
	var initial_result = {
		"valid": true,
		"score_increase": 0,
		"movements": [],
		"merges": [],
		"initial_spawn": true
	}
	
	game_started.emit()
	board_changed.emit(initial_result)

func attempt_move(direction: Vector2i):
	if grid_state == null:
		return
		
	var pre_move_state = grid_state.get_state()
	var pre_move_score = current_score
		
	var move_result = grid_state.attempt_move(direction)
	
	if move_result.valid:
		history.append({
			"grid": pre_move_state,
			"score": pre_move_score
		})
		var new_tile = grid_state.spawn_random_tile()
		if new_tile != null:
			move_result["new_tile"] = {"id": new_tile.id, "pos": get_tile_pos(new_tile), "value": new_tile.value}
			
		current_score += move_result.score_increase
		score_changed.emit(current_score)
		
		if current_score > best_score:
			best_score = current_score
			best_score_changed.emit(best_score)
			
		for merge in move_result.merges:
			if merge.new_value >= 128 and not _milestones_reached.has(merge.new_value):
				_milestones_reached[merge.new_value] = true
				milestone_reached.emit(merge.new_value)
				
		board_changed.emit(move_result)
		
		if not _won_already and grid_state.has_won():
			_won_already = true
			game_won.emit()
			
		if grid_state.is_game_over():
			game_over.emit()

func get_tile_pos(target_tile: Tile) -> Vector2i:
	for x in range(config.grid_size.x):
		for y in range(config.grid_size.y):
			if grid_state.grid[x][y] == target_tile:
				return Vector2i(x, y)
	return Vector2i(-1, -1)

func keep_playing():
	pass

func undo_move():
	if history.is_empty():
		return
		
	var last_state = history.pop_back()
	grid_state.restore_state(last_state.grid)
	current_score = last_state.score
	score_changed.emit(current_score)
	
	var result = {
		"valid": true,
		"is_undo": true
	}
	board_changed.emit(result)
