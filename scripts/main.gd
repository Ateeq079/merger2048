extends Node

@onready var board = $Board
@onready var hud = $HUD
@onready var menu = $Menu

func _ready():
	if menu:
		menu.start_game_requested.connect(_on_start_game)

func _on_start_game():
	if menu:
		menu.visible = false
	if board:
		board.visible = true
	if hud:
		hud.visible = true
		
	GameState.initialize()
