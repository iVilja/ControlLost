tool
extends "res://game_objects/blocks/block.gd"
class_name Player

export (bool)var is_up setget set_is_up
export (Texture)var sprite_up setget set_sprite_up
export (Texture)var sprite_down setget set_sprite_down

var grouped_blocks = []


func _ready():
	type_name = "player"


func update_sprite():
	if has_node("Sprite"):
		$Sprite.texture = sprite_up if is_up else sprite_down


func set_sprite_up(value):
	sprite_up = value
	update_sprite()


func set_sprite_down(value):
	sprite_down = value
	update_sprite()


func set_is_up(value):
	is_up = value
	update_sprite()


func get_pos_ids():
	var ret = pos_ids.duplicate()
	for each in grouped_blocks:
		ret.append_array(each.pos_ids)
	return ret
