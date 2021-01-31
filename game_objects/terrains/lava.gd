tool
extends "res://game_objects/terrains/terrain.gd"
class_name LavaTerrain


export var rescaling_time = 1.5


func _ready():
	type_name = "lava"
	auto_interactable = true
	._ready()


# :)
const A_LONG_DISTANCE = Vector2.RIGHT * 100

const RESCALING_SCALE = 0.6
func interact(block):
	if block.is_moving():
		yield(block, "moved")
	if SFX.LAVA in SFX.keeping_players:
		SFX.keeping_players[SFX.LAVA].volume_db += 15.0
	var center = block.get_polygon_center()
	var t = NodeTransform.rescale(block, center, RESCALING_SCALE * block.scale, rescaling_time)
	game.animating[self] = true
	yield(t, "transformed")
	if SFX.LAVA in SFX.keeping_players:
		SFX.keeping_players[SFX.LAVA].volume_db -= 15.0
	game.animating.erase(self)
	var step = {
		"type": "lava",
		"block": block,
		"terrain": self,
		"center": center
	}
	block.position += A_LONG_DISTANCE * Triangle.SideLength
	block.moved_pos += A_LONG_DISTANCE
	block.enabled = false
	emit_signal("interacted", step)


func go_back(step):
	var block = step["block"]
	block.position -= A_LONG_DISTANCE * Triangle.SideLength
	block.moved_pos -= A_LONG_DISTANCE
	var center = step["center"]
	var t = NodeTransform.rescale(block, center, block.scale / RESCALING_SCALE, rescaling_time / 3)
	game.animating[self] = t
	yield(t, "transformed")
	block.enabled = true
	game.animating.erase(self)
	emit_signal("interacted", null)
