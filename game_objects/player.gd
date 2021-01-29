tool
extends "res://game_objects/block.gd"


export (bool)var is_up setget set_is_up
export (Texture)var sprite_up setget set_sprite_up
export (Texture)var sprite_down setget set_sprite_down


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
