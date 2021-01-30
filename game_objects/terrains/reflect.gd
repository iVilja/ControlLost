tool
extends "res://game_objects/terrains/terrain.gd"
class_name ReflectTerrain

# Direction: 0 for up-down, 1 for upright-downleft, 2 for upleft-downright
export var direction = 0
export var reflecting_speed = 2.0

var backing = false
var interacting_block: Node2D = null
var target_scale_y = 0.0
var speed = reflecting_speed


func _ready():
	assert(direction == 0)  # only supports up-down for now


func reflect(block, is_backing, speed_scale):
	backing = is_backing
	assert(pos_ids.size() == 1)  # only one triangle per terrain.
	game.animating[self] = true
	target_scale_y = block.scale.y * -1
	interacting_block = block
	speed = reflecting_speed * speed_scale


func interact(block):
	reflect(block, false, 1)


func go_back(step):
	var block = step["block"]
	reflect(block, true, 3)


func complete():
	var block = interacting_block
	var moved_pos = Vector2.DOWN
	if Triangle.get_is_up(pos_ids[0]):
		match direction:
			1: moved_pos = Vector2.RIGHT
			2: moved_pos = Vector2.LEFT
	else:
		match direction:
			0: moved_pos = Vector2.UP
			1: moved_pos = Vector2.LEFT
			2: moved_pos = Vector2.RIGHT
	var step = null
	if backing:
		block.moved_pos -= moved_pos
	else:
		block.moved_pos += moved_pos
		step = {
			"type": "reflect",
			"block": block,
			"terrain": self
		}
	interacting_block = null
	target_scale_y = 0.0
	game.animating.erase(self)
	emit_signal("interacted", step)


func _process(delta):
	if interacting_block == null:
		return
	var s = interacting_block.scale
	var new_y = move_toward(s.y, target_scale_y, delta * speed)
	interacting_block.scale = Vector2(s.x, new_y)
	interacting_block.update_sprite()
	if new_y == target_scale_y:
		complete()
