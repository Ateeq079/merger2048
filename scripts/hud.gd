class_name HUD
extends Control

@onready var score_label: Label = $VBox/BottomBar/ScoreContainer/ScoreLabel
@onready var undo_btn: Button = $VBox/TopBar/UndoBtn
@onready var best_label: Label = $VBox/BottomBar/BestContainer/BestLabel
@onready var game_over_panel: PanelContainer = $GameOverPanel
@onready var game_over_score: Label = $GameOverPanel/VBox/FinalScore
@onready var retry_btn: Button = $GameOverPanel/VBox/CenterContainer/RetryBtn
@onready var win_panel: PanelContainer = $WinPanel
@onready var keep_playing_btn: Button = $WinPanel/VBox/KeepPlayingBtn

func _ready():
	GameState.score_changed.connect(_on_score_changed)
	GameState.best_score_changed.connect(_on_best_score_changed)
	GameState.game_over.connect(_on_game_over)
	GameState.game_won.connect(_on_game_won)
	GameState.game_started.connect(_on_game_started)
	
	retry_btn.pressed.connect(_on_new_game_pressed)
	keep_playing_btn.pressed.connect(_on_keep_playing_pressed)
	if undo_btn:
		undo_btn.pressed.connect(_on_undo_pressed)
	
	game_over_panel.hide()
	win_panel.hide()
	
	_on_best_score_changed(GameState.best_score)
	_on_score_changed(GameState.current_score)

func _on_score_changed(new_score: int):
	score_label.text = str(new_score)

func _on_best_score_changed(new_score: int):
	best_label.text = str(new_score)

func _on_game_over():
	game_over_score.text = "Final Score: " + str(GameState.current_score)
	game_over_panel.show()
	game_over_panel.scale = Vector2.ZERO
	game_over_panel.pivot_offset = game_over_panel.size / 2.0
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(game_over_panel, "scale", Vector2.ONE, 0.3)

func _on_game_won():
	win_panel.show()
	win_panel.position.y = -win_panel.size.y
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(win_panel, "position:y", 100, 0.3)

func _on_game_started():
	game_over_panel.hide()
	win_panel.hide()

func _on_new_game_pressed():
	if retry_btn.is_visible_in_tree():
		AnimationJuice.button_tap(retry_btn)
	GameState.start_new_game()

func _on_keep_playing_pressed():
	AnimationJuice.button_tap(keep_playing_btn)
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(win_panel, "position:y", -win_panel.size.y, 0.3)
	tween.finished.connect(func(): win_panel.hide())
	GameState.keep_playing()

func _on_undo_pressed():
	if undo_btn.is_visible_in_tree():
		AnimationJuice.button_tap(undo_btn)
	GameState.undo_move()
