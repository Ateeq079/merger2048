class_name InputHandler
extends Node

signal swipe_detected(direction: Vector2i)

@export var min_swipe_distance: float = 40.0
@export var max_swipe_time: float = 400.0

var _swipe_start_pos: Vector2
var _swipe_start_time: float
var _is_swiping: bool = false
var input_locked: bool = false

func _input(event):
	if input_locked:
		return
		
	if event is InputEventScreenTouch or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):
		if event.is_pressed():
			_is_swiping = true
			_swipe_start_pos = event.position
			_swipe_start_time = Time.get_ticks_msec()
		elif _is_swiping:
			_is_swiping = false
			_check_swipe(event.position, Time.get_ticks_msec())
			
	elif event is InputEventKey and event.is_pressed() and not event.is_echo():
		var dir = Vector2i.ZERO
		if event.is_action_pressed("ui_up") or event.keycode == KEY_W or event.keycode == KEY_UP:
			dir = Vector2i(0, -1)
		elif event.is_action_pressed("ui_down") or event.keycode == KEY_S or event.keycode == KEY_DOWN:
			dir = Vector2i(0, 1)
		elif event.is_action_pressed("ui_left") or event.keycode == KEY_A or event.keycode == KEY_LEFT:
			dir = Vector2i(-1, 0)
		elif event.is_action_pressed("ui_right") or event.keycode == KEY_D or event.keycode == KEY_RIGHT:
			dir = Vector2i(1, 0)
			
		if dir != Vector2i.ZERO:
			swipe_detected.emit(dir)

func _check_swipe(end_pos: Vector2, end_time: float):
	if end_time - _swipe_start_time > max_swipe_time:
		return
		
	var delta = end_pos - _swipe_start_pos
	if delta.length() < min_swipe_distance:
		return
		
	var dir = Vector2i.ZERO
	if abs(delta.x) > abs(delta.y):
		dir.x = sign(delta.x)
	else:
		dir.y = sign(delta.y)
		
	swipe_detected.emit(dir)
