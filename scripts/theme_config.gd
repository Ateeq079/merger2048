class_name ThemeConfig
extends Resource

@export var exact_tile_colors: Dictionary = {
	2: Color("#eee4da"),
	4: Color("#ede0c8"),
	8: Color("#f2b179"),
	16: Color("#6fc77b"),
	32: Color("#4fb0c6"),
	64: Color("#f36a6f"),
	128: Color("#edc22e"),
	256: Color("#7d42c3"),
	512: Color("#3b5998"),
	1024: Color("#c9363d"),
	2048: Color("#ffcc00")
}
@export var background_color: Color = Color("1e1e1e")
@export var grid_background_color: Color = Color("2d2d2d")
@export var empty_cell_color: Color = Color("383838")

@export var font_size_2_digit: int = 48
@export var font_size_3_digit: int = 42
@export var font_size_4_digit: int = 36
@export var font_size_5_digit: int = 28
