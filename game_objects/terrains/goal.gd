extends "res://game_objects/terrains/terrain.gd"
class_name Goal


func check_interact(block):
	return block.type_name == "player" and .check_interact(block)


func interact(block):
	assert(block.type_name == "player")
	yield(get_tree(), "idle_frame")
	print("Completed!")
	emit_signal("interacted", true)
	yield(get_tree(), "idle_frame")
	game.end()
