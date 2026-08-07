extends RefCounted

const GridConfig = preload("res://scripts/grid_config.gd")
const GridState = preload("res://scripts/grid_state.gd")

var config: GridConfig

func _init():
	config = GridConfig.new()
	config.grid_size = Vector2i(4, 4)

func setup_grid() -> GridState:
	var state = GridState.new(config)
	return state

func assert_eq(a, b, msg: String = "") -> bool:
	if a != b:
		print("Assertion failed: ", a, " != ", b, " | ", msg)
		return false
	return true

func assert_true(a, msg: String = "") -> bool:
	if not a:
		print("Assertion failed: Expected true | ", msg)
		return false
	return true

func assert_false(a, msg: String = "") -> bool:
	if a:
		print("Assertion failed: Expected false | ", msg)
		return false
	return true

func test_single_merge() -> bool:
	var state = setup_grid()
	state.force_spawn_tile(Vector2i(0, 0), 1, 2)
	state.force_spawn_tile(Vector2i(1, 0), 2, 2)
	
	var res = state.attempt_move(Vector2i(-1, 0))
	if not assert_true(res.valid, "Move should be valid"): return false
	
	var tile = state.get_tile(Vector2i(0, 0))
	if not assert_true(tile != null, "Tile should exist at 0,0"): return false
	if not assert_eq(tile.value, 4, "Tile should have merged to 4"): return false
	if not assert_true(state.get_tile(Vector2i(1, 0)) == null, "Tile at 1,0 should be empty"): return false
	return true

func test_no_double_merge() -> bool:
	var state = setup_grid()
	# [2, 2, 4, _] sliding left should result in [4, 4, _, _], NOT [8, _, _, _]
	state.force_spawn_tile(Vector2i(0, 0), 1, 2)
	state.force_spawn_tile(Vector2i(1, 0), 2, 2)
	state.force_spawn_tile(Vector2i(2, 0), 3, 4)
	
	var res = state.attempt_move(Vector2i(-1, 0))
	if not assert_true(res.valid, "Move should be valid"): return false
	
	if not assert_eq(state.get_tile(Vector2i(0, 0)).value, 4, "First tile should be 4"): return false
	if not assert_eq(state.get_tile(Vector2i(1, 0)).value, 4, "Second tile should be 4"): return false
	if not assert_true(state.get_tile(Vector2i(2, 0)) == null, "Third slot should be empty"): return false
	return true

func test_three_in_a_row_merge() -> bool:
	var state = setup_grid()
	# [2, 2, 2, _] sliding left should result in [4, 2, _, _]
	state.force_spawn_tile(Vector2i(0, 0), 1, 2)
	state.force_spawn_tile(Vector2i(1, 0), 2, 2)
	state.force_spawn_tile(Vector2i(2, 0), 3, 2)
	
	var res = state.attempt_move(Vector2i(-1, 0))
	if not assert_true(res.valid, "Move should be valid"): return false
	
	if not assert_eq(state.get_tile(Vector2i(0, 0)).value, 4, "First tile should be 4"): return false
	if not assert_eq(state.get_tile(Vector2i(1, 0)).value, 2, "Second tile should be 2"): return false
	if not assert_true(state.get_tile(Vector2i(2, 0)) == null, "Third slot should be empty"): return false
	return true

func test_invalid_move() -> bool:
	var state = setup_grid()
	state.force_spawn_tile(Vector2i(0, 0), 1, 2)
	
	var res = state.attempt_move(Vector2i(-1, 0)) # Sliding left when already at left
	if not assert_false(res.valid, "Move should be invalid"): return false
	return true

func test_game_over() -> bool:
	var state = setup_grid()
	var v = 2
	for x in range(4):
		for y in range(4):
			state.force_spawn_tile(Vector2i(x, y), x*4+y, v)
			v = 4 if v == 2 else 2
		# Alternate rows to prevent vertical merges
		v = 4 if v == 2 else 2
		
	if not assert_true(state.is_game_over(), "Game should be over"): return false
	return true

func test_not_game_over() -> bool:
	var state = setup_grid()
	state.force_spawn_tile(Vector2i(0, 0), 1, 2)
	state.force_spawn_tile(Vector2i(1, 0), 2, 2)
	
	if not assert_false(state.is_game_over(), "Game should not be over"): return false
	return true
