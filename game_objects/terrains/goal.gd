tool
extends "res://game_objects/terrains/terrain.gd"
class_name Goal


func initialize(game):
	if initialized:
		return
	.initialize(game)
	initialized = false
	game.connect("game_over", self, "on_game_over")
	initialized = true


func check_interact(block):
	return block.type_name == "player" and .check_interact(block)


func interact(block):
	assert(block.type_name == "player")
	yield(get_tree(), "idle_frame")
	print("Completed!")
	emit_signal("interacted", null)
	yield(get_tree(), "idle_frame")
	game.end()


func on_game_over():
	NodeTransform.fade_out($AnimatedSprite, 1.0)
