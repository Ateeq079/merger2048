class_name TileView
extends PanelContainer

var tile_id: int
var value: int
var theme_config: ThemeConfig

@onready var label: Label = $Label
@onready var style_box: StyleBoxFlat = StyleBoxFlat.new()

func _ready():
	add_theme_stylebox_override("panel", style_box)
	style_box.corner_radius_top_left = 12
	style_box.corner_radius_top_right = 12
	style_box.corner_radius_bottom_left = 12
	style_box.corner_radius_bottom_right = 12
	
	style_box.shadow_color = Color(0, 0, 0, 0.2)
	style_box.shadow_size = 4
	style_box.shadow_offset = Vector2(0, 4)

func setup(p_id: int, p_value: int, p_theme: ThemeConfig):
	tile_id = p_id
	value = p_value
	theme_config = p_theme
	update_visuals()

func update_value(p_value: int):
	value = p_value
	update_visuals()

func update_visuals():
	if label == null:
		return
		
	label.text = str(value)
	
	var digit_count = str(value).length()
	if digit_count <= 2:
		label.add_theme_font_size_override("font_size", theme_config.font_size_2_digit)
	elif digit_count == 3:
		label.add_theme_font_size_override("font_size", theme_config.font_size_3_digit)
	elif digit_count == 4:
		label.add_theme_font_size_override("font_size", theme_config.font_size_4_digit)
	else:
		label.add_theme_font_size_override("font_size", theme_config.font_size_5_digit)
		
	if theme_config.get("exact_tile_colors") != null and theme_config.exact_tile_colors.has(value):
		style_box.bg_color = theme_config.exact_tile_colors[value]
		
		var lum = style_box.bg_color.get_luminance()
		if lum > 0.5:
			label.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
		else:
			label.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95))
	else:
		style_box.bg_color = Color(0.8, 0.7, 0.6) # Default for very high values not in dict
		label.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
