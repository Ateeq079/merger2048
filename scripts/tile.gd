class_name Tile
extends RefCounted

var id: int
var value: int
var just_merged: bool = false

func _init(p_id: int, p_value: int):
	id = p_id
	value = p_value
