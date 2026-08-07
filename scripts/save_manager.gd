extends Node

const SAVE_FILE_PATH = "user://savegame.json"

func _ready():
	GameState.board_changed.connect(_on_board_changed)
	GameState.score_changed.connect(_on_score_changed)

func has_save_data() -> bool:
	return FileAccess.file_exists(SAVE_FILE_PATH)

func save_game():
	var save_data = {
		"best_score": GameState.best_score,
		"current_score": GameState.current_score,
		"grid": []
	}
	
	if GameState.grid_state != null:
		var grid_size = GameState.config.grid_size
		for x in range(grid_size.x):
			var col = []
			for y in range(grid_size.y):
				var tile = GameState.grid_state.grid[x][y]
				if tile != null:
					col.append({"id": tile.id, "value": tile.value})
				else:
					col.append(null)
			save_data.grid.append(col)
			
	var json_string = JSON.stringify(save_data)
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(json_string)

func load_game():
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		return
		
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var json = JSON.new()
		var error = json.parse(content)
		if error == OK:
			var save_data = json.data
			if typeof(save_data) == TYPE_DICTIONARY:
				if save_data.has("best_score"):
					GameState.best_score = save_data.best_score
					
				if save_data.has("grid") and save_data.grid.size() > 0:
					GameState.call_deferred("start_from_save", save_data)

func _on_board_changed(_mr):
	save_game()
	
func _on_score_changed(_score):
	save_game()
