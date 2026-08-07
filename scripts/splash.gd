extends Control

var next_scene_path: String = "res://scenes/main.tscn"
var loading_status: int = 0
var progress: Array = []
var time_elapsed: float = 0.0
const MINIMUM_SPLASH_TIME: float = 2.0

@onready var dots = [
	$LoadingContainer/Dot1,
	$LoadingContainer/Dot2,
	$LoadingContainer/Dot3
]

func _ready() -> void:
	# Start loading main scene in the background
	ResourceLoader.load_threaded_request(next_scene_path)

func _process(delta: float) -> void:
	time_elapsed += delta
	
	# Animate dots using sine wave
	for i in range(dots.size()):
		var dot = dots[i]
		dot.modulate.a = 0.3 + 0.7 * abs(sin(time_elapsed * 4.0 - i * 0.8))
	
	loading_status = ResourceLoader.load_threaded_get_status(next_scene_path, progress)
	
	if loading_status == ResourceLoader.THREAD_LOAD_LOADED and time_elapsed >= MINIMUM_SPLASH_TIME:
		set_process(false)
		var packed_scene = ResourceLoader.load_threaded_get(next_scene_path)
		get_tree().change_scene_to_packed(packed_scene)
	elif loading_status == ResourceLoader.THREAD_LOAD_FAILED or loading_status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		print("Failed to load main scene!")
		set_process(false)
