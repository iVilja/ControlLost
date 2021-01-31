tool
extends Area2D
class_name Terrain

signal interacted(step)

export var enabled = true setget set_enabled
export var is_blocking = false
export var auto_interactable = false
export var activated = false setget set_activate

var type_name = "unknown"
var initialized = false
var pos_ids = []
const GameManager = preload("res://core/game_manager.gd")
var game: GameManager


func _ready():
	pass


func set_activate(value):
	if activated == value:
		return
	activated = value
	if has_node("Activated"):
		$Activated.visible = value

func initialize(game_):
	if initialized:
		return
	game = game_
	initialized = true


# Also update the position
func set_enabled(value):
	enabled = value
	if value:
		position = Triangle.get_nearest_point(position)


func will_block(_block):
	return is_blocking


func restore():
	pass


func enclose(block):
	if not block.enabled:
		return false
	var block_pos_ids = block.get_pos_ids()
	if block_pos_ids == null or block_pos_ids.size() == 0:
		return false
	for block_pos_id in block_pos_ids:
		if not (block_pos_id + block.moved_pos in pos_ids):
			return false
	return true


func check_interact(block):
	if auto_interactable:
		return enclose(block)
	return false


func interact(_block):
	emit_signal("interacted", {})
