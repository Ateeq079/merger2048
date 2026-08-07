class_name AnimationJuice
extends RefCounted

static func slide(node: Control, target_pos: Vector2, duration: float = 0.12) -> Tween:
	var tween = node.create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(node, "position", target_pos, duration)
	return tween

static func spawn(node: Control, duration: float = 0.15) -> Tween:
	node.scale = Vector2.ZERO
	var tween = node.create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(node, "scale", Vector2.ONE, duration)
	return tween

static func merge_pop(node: Control, duration: float = 0.15) -> Tween:
	node.scale = Vector2.ONE
	var tween = node.create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(node, "scale", Vector2(1.15, 1.15), duration * 0.5)
	tween.tween_property(node, "scale", Vector2.ONE, duration * 0.5)
	return tween

static func bump(node: Control, direction: Vector2, duration: float = 0.1) -> Tween:
	var original_pos = node.position
	var tween = node.create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(node, "position", original_pos + direction * 10.0, duration * 0.5)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(node, "position", original_pos, duration * 0.5)
	return tween

static func shake(node: Control, duration: float = 0.1) -> Tween:
	var original_pos = node.position
	var tween = node.create_tween()
	var step = duration / 4.0
	tween.tween_property(node, "position", original_pos + Vector2(4, 2), step)
	tween.tween_property(node, "position", original_pos + Vector2(-3, -4), step)
	tween.tween_property(node, "position", original_pos + Vector2(2, 3), step)
	tween.tween_property(node, "position", original_pos, step)
	return tween

static func button_tap(node: Control, duration: float = 0.1) -> Tween:
	var tween = node.create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	node.pivot_offset = node.size / 2.0
	tween.tween_property(node, "scale", Vector2(0.9, 0.9), duration * 0.5)
	tween.tween_property(node, "scale", Vector2.ONE, duration * 0.5)
	return tween

static func particle_explosion(parent_node: Node, pos: Vector2, color: Color) -> void:
	var particles = CPUParticles2D.new()
	particles.emitting = false
	particles.one_shot = true
	particles.explosiveness = 0.9
	particles.lifetime = 0.6
	particles.amount = 25
	particles.spread = 180.0
	particles.initial_velocity_min = 150.0
	particles.initial_velocity_max = 300.0
	particles.damping_min = 200.0
	particles.damping_max = 400.0
	particles.scale_amount_min = 6.0
	particles.scale_amount_max = 12.0
	particles.color = color
	
	# Add some simple physics behavior
	particles.position = pos
	
	parent_node.add_child(particles)
	particles.emitting = true
	
	var timer = parent_node.get_tree().create_timer(1.0)
	timer.timeout.connect(particles.queue_free)
