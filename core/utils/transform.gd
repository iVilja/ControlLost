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
var ended = false


func fade_in(node: CanvasItem, time = 1.0):
	if is_busy():
		return
	var p = self.duplicate()
	node.add_child(p)
	return p._fade(node, time, false)


func fade_out(node: CanvasItem, time = 1.0):
	if is_busy():
		return
	if not node.visible or node.modulate.a == 0.0:
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


func stop_fading():
	var node = target
	node.modulate = color_target
	if is_fading_out:
		node.visible = false
	fading_elapsed = -1
	target = null
	ended = true
	queue_free()
	emit_signal("transformed", node)
	


func update_fading(delta):
	if fading_elapsed < 0:
		return
	var node = target
	fading_elapsed += delta
	if fading_elapsed >= fading_time:
		stop_fading()
		return
	var t = fading_elapsed / fading_time
	target.modulate = color_start.linear_interpolate(color_target, t)


var rescaling_elapsed = -1.0
var rescaling_time = 0.0
var rescaling_center = Vector2()
var rescaling_start = Vector2()
var scale_start = Vector2()
var scale_target = Vector2()
func rescale(node: CanvasItem, center, target_scale, time):
	target = node
	rescaling_center = center
	rescaling_start = node.position
	scale_start = node.scale
	scale_target = target_scale
	rescaling_elapsed = 0.0
	rescaling_time = time
	return self


func stop_rescaling():
	var node = target
	rescaling_elapsed = -1.0
	node.scale = scale_target
	node.position = scale_target / scale_start * (rescaling_start - rescaling_center) + rescaling_center
	target = null
	emit_signal("transformed", node)


func update_rescaling(delta):
	if rescaling_elapsed < 0:
		return
	var node = target
	rescaling_elapsed += delta
	if rescaling_elapsed >= rescaling_time:
		stop_rescaling()
		return
	var t = rescaling_elapsed / rescaling_time
	node.scale = scale_start.linear_interpolate(scale_target, t)
	node.position = node.scale / scale_start * (rescaling_start - rescaling_center) + rescaling_center


func _process(delta):
	update_fading(delta)
	update_rescaling(delta)
