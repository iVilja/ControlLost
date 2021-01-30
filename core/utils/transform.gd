extends Node

signal transformed(target)

func is_busy():
	return false

var target: CanvasItem = null
var fading_time = 1.0
var fading_elapsed = -1.0
var is_fading_out = false
var color_start = Color()
var color_target = Color()


func fade_in(node: CanvasItem, time):
	if is_busy():
		return
	var p = self.duplicate()
	node.add_child(p)
	return p._fade(node, time, false)


func fade_out(node: CanvasItem, time):
	if is_busy():
		return
	var p = self.duplicate()
	node.add_child(p)
	return p._fade(node, time, true)


func _fade(node: CanvasItem, time, is_out):
	target = node
	is_fading_out = is_out
	color_target = node.modulate
	color_start = color_target
	color_target.a = 0.0 if is_out else 1.0
	if not is_out:
		color_start.a = 0.0
	node.visible = true
	fading_elapsed = 0.0
	fading_time = time
	return self


func update_fading(delta):
	if fading_elapsed < 0:
		return
	var node = target
	fading_elapsed += delta
	if fading_elapsed >= fading_time:
		node.modulate = color_target
		if is_fading_out:
			node.visible = false
		fading_elapsed = -1
		target = null
		queue_free()
		emit_signal("transformed", node)
		return
	var t = fading_elapsed / fading_time
	target.modulate = color_start.linear_interpolate(color_target, t)


func _process(delta):
	update_fading(delta)
