extends Control

signal start_game_requested

@onready var start_btn: Button = $VBox/StartBtn
@onready var logo: TextureRect = $VBox/Logo

func _ready():
	start_btn.pressed.connect(_on_start_btn_pressed)

func _process(delta):
	# Simple pulsating effect for the logo
	if logo:
		var scale_val = 1.0 + sin(Time.get_ticks_msec() / 300.0) * 0.05
		logo.scale = Vector2(scale_val, scale_val)
		# Center the scaling
		logo.pivot_offset = logo.size / 2.0

func _on_start_btn_pressed():
	# Animate the click
	if start_btn:
		start_btn.scale = Vector2(0.9, 0.9)
	
	# Emit signal to let main.gd know to transition
	start_game_requested.emit()
