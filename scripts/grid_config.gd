class_name GridConfig
extends Resource

@export var grid_size: Vector2i = Vector2i(4, 4)
@export var win_value: int = 2048
@export var spawn_weights: Dictionary = {
	2: 0.9,
	4: 0.1
}
@export var merge_score_multiplier: float = 1.0
