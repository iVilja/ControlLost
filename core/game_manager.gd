extends Node

class_name GameManager

var terrains = {}
var blocks = {}
var steps = []


func _init():
	assert(Global.current_game == null)
	Global.current_game = self


func end():
	assert(Global.current_game == self)
	Global.current_game = null


func all_positions():
	return terrains.keys()


func in_map(pos: Vector2):
	return pos in terrains


func get_terrain(pos: Vector2):
	return terrains[pos]


func get_block(pos: Vector2):
	if pos in blocks:
		return blocks[pos]
	return null


var available_directions = []

func check_movable(block, i):
	var direction = Triangle.ID_DIRECTIONS[i]
	for pos_id in block.pos_ids:
		for next in Triangle.get_pathway(pos_id, direction):
			if not in_map(next):
				return false
			var existing_block = get_block(next)
			if existing_block != null and existing_block != block:
				return false
			var terrain = get_terrain(next)
			if terrain != null and terrain.will_block(block):
				return false
	return true


const DRAGGING_THRESHOLD = 200
var dragging_block = null
var dragging_start = Vector2()
var dragging_direction = -1
var dragging_block_position = Vector2()
func drag(block):
	if dragging_block != null or not block.is_draggable:
		return
	print("Dragging ", block)
	dragging_block = block
	dragging_start = block.get_global_mouse_position()
	dragging_block_position = block.position
	dragging_direction = -1
	block.is_dragging = true
	available_directions = []
	for di in range(6):
		if check_movable(block, di):
			available_directions.append(di)
	print(available_directions)


func cancel_drag(block):
	if dragging_block != block:
		return
	print("Cancelling dragging ", block)
	dragging_block = null
	dragging_start = Vector2()
	dragging_direction = -3
	block.is_dragging = false
	available_directions = []


func move(block):
	pass


func _process(delta):
	if dragging_block != null:
		if not Input.is_mouse_button_pressed(BUTTON_LEFT):
			cancel_drag(dragging_block)
			return
		var mp = dragging_block.get_global_mouse_position() - dragging_start
		if dragging_direction == -1 and mp.length_squared() >= DRAGGING_THRESHOLD:
			var di = Triangle.get_direction(mp)
			if di in available_directions:
				dragging_direction = di
			else:
				dragging_direction = -2
		if dragging_direction >= 0:
			var to_move = mp.project(Triangle.DIRECTIONS[dragging_direction])
			dragging_block.position = dragging_block_position + to_move
