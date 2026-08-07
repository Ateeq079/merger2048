extends Node

var merge_stream = preload("res://assets/audio/merge.mp3")
var swipe_stream = preload("res://assets/audio/swipe.mp3")

var bump_sound: AudioStreamPlayer
var win_sound: AudioStreamPlayer

func _ready():
	bump_sound = AudioStreamPlayer.new()
	add_child(bump_sound)
	
	win_sound = AudioStreamPlayer.new()
	add_child(win_sound)
	
	# Background music
	var bgm = AudioStreamPlayer.new()
	bgm.stream = load("res://assets/audio/Sunday_Sort.mp3")
	add_child(bgm)
	if bgm.stream:
		# AudioStreamMP3 supports loop property
		if "loop" in bgm.stream:
			bgm.stream.loop = true
		bgm.play()

func play_swipe():
	var player = AudioStreamPlayer.new()
	player.stream = swipe_stream
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)

func play_merge(value: int):
	var player = AudioStreamPlayer.new()
	player.stream = merge_stream
	# Calculate pitch: base 1.0 for value 2, increase slightly per power of 2
	var log_val = log(value) / log(2)
	player.pitch_scale = 1.0 + (log_val - 1) * 0.05
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)

func play_bump():
	# if bump_sound.stream: bump_sound.play()
	pass

func play_win():
	# if win_sound.stream: win_sound.play()
	pass
