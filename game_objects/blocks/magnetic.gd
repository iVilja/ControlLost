tool
extends "res://game_objects/blocks/block.gd"
class_name MagneticBlock

var availables = [false, false, false]


func _ready():
	._ready()
	type_name = "magnetic"
	for each in $Activated.get_children():
		each.visible = false


func set_states():
	for i in range(3):
		$Activated.get_child(i).visible = availables[i]


func is_available():
	var o = false
	for i in range(3):
		if availables[i]:
			o = true
	return o


func clear_availables():
	for i in range(3):
		availables[i] = false


var last_checked = -1
func check_interact(player):
	if is_grouped:
		return false
	var t = game.steps.size()
	if t == last_checked:
		return false
	var main = Global.current_scene
	if not player.is_grouped and player.groupable_blocks.size() == 0:
		main.magnet.disabled = true
	var c = Triangle.get_conjacent(
		self.pos_ids[0] + self.moved_pos,
		player.pos_ids[0] + player.moved_pos
	)
	if c >= 0:
		availables[c] = true
		if main.magnet.disabled:
			SFX.play(SFX.CONSTRUCT_READY)
		main.magnet.disabled = false
	else:
		clear_availables()
	var ia = is_available()
	if ia and not (self in player.groupable_blocks):
		player.groupable_blocks[self] = true
	elif not ia and (self in player.groupable_blocks):
		player.groupable_blocks.erase(self)
	last_checked = t
	return false


func restore_original():
	clear_availables()
	.restore_original()
