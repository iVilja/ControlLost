tool
extends "res://game_objects/terrains/terrain.gd"
class_name LavaTerrain


export var rescaling_time = 1.0


func _ready():
	type_name = "lava"
	auto_interactable = true
	._ready()


# :)
const A_LONG_DISTANCE = Vector2.RIGHT * 100

const RESCALING_SCALE = 0.8
func interact(block):
	if block.is_moving():
		yield(block, "moved")
	var center = block.get_polygon_center() * block.scale + block.position
	var t = NodeTransform.rescale(block, center, RESCALING_SCALE * block.scale, rescaling_time)
	game.animating[self] = true
	yield(t, "transformed")
	game.animating.erase(self)
	var step = {
		"type": "lava",
		"block": block,
		"terrain": self
	}
	block.position += A_LONG_DISTANCE * Triangle.SideLength
	block.moved_pos += A_LONG_DISTANCE
	emit_signal("interacted", step)


func go_back(step):
	var block = step["block"]
	block.position -= A_LONG_DISTANCE * Triangle.SideLength
	block.moved_pos -= A_LONG_DISTANCE
	var center = block.get_polygon_center() * block.scale + block.position
	var t = NodeTransform.rescale(block, center, block.scale / RESCALING_SCALE, rescaling_time / 3)
	game.animating[self] = t
	yield(t, "transformed")
	game.animating.erase(self)
	emit_signal("interacted", null)
