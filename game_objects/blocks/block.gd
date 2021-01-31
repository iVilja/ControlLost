tool
extends KinematicBody2D
class_name Block

signal moved

export var enabled = true setget set_enabled
export var is_draggable = true
export var draw_border = true
export var border_color = Color.black setget set_border_color
export var border_color_hovered = Color.black
export var border_color_dragging = Color.white
export var border_width = 5 setget set_border_width
export var moving_speed = 120

var initialized = false
var type_name = "normal"
var is_grouped = false

var hovered = false setget set_hovered
var is_dragging = false setget set_is_dragging
const GameManager = preload("res://core/game_manager.gd")
var game: GameManager
var pos_ids = []
var moved_pos = Vector2.ZERO setget set_moved_pos


onready var sprite = $Sprite
onready var reversed_sprite = $Reversed if has_node("Reversed") else null 
onready var original_position = position
onready var original_scale = scale


func is_player():
	return type_name == "player"


# Also update the position
func set_enabled(value):
	enabled = value
	if value:
		position = Triangle.get_nearest_point(position)
	if has_node("Boundary"):
		$Boundary.update()


func set_border_color(value):
	border_color = value
	if has_node("Boundary"):
		$Boundary.update()


func set_border_width(value):
	border_width = value
	if has_node("Boundary"):
		$Boundary.update()


func set_hovered(value):
	if hovered == value:
		return
	hovered = value
	if has_node("Boundary"):
		$Boundary.update()


func set_moved_pos(value):
	if moved_pos == value:
		return
	var ap = game.all_positions()
	for pos_id in pos_ids:
		var t = pos_id + moved_pos
		if t in ap:
			game.blocks_map.erase(pos_id + moved_pos)
	moved_pos = value
	for pos_id in pos_ids:
		var t = pos_id + moved_pos
		if t in ap:
			game.blocks_map[pos_id + moved_pos] = self


func set_is_dragging(value):
	if is_dragging == value:
		return
	is_dragging = value
	$Boundary.update()


func get_current_border_color():
	if not enabled:
		return border_color
	return border_color_dragging if is_dragging else \
		border_color_hovered if hovered and game != null and \
		game.dragging_block == null else \
		border_color


func get_polygon():
	return $TrianglePolygonShape.polygon


func _on_Boundary_draw():
	if not draw_border:
		return
	var bc = get_current_border_color()
	var vertices = get_polygon()
	var boundary = $Boundary
	var n = vertices.size()
	var center = Math.get_polygon_center(vertices)
	for i in range(n):
		vertices[i] = vertices[i].move_toward(center, border_width / 2)
		boundary.draw_circle(vertices[i], border_width / 2, bc)
	for i in range(n - 1):
		boundary.draw_line(vertices[i], vertices[i + 1], bc, border_width)
	boundary.draw_line(vertices[n - 1], vertices[0], bc, border_width)
	boundary.z_index = 1 if is_dragging or \
		hovered and game != null and game.dragging_block == null else 0


func _on_input_event(_viewport, event, _shape_idx):
	if not is_draggable or game != null and game.is_busy():
		return
	if event is InputEventMouseButton and game != null:
		if event.button_index != BUTTON_LEFT:
			return
		if event.pressed:
			game.drag(self)
		else:
			game.cancel_drag()


func _on_mouse_entered():
	self.hovered = true
	if game != null and game.dragging_block == self and game.dragging_direction == -2:
		game.dragging_direction = -1


func _on_mouse_exited():
	self.hovered = false


func restore_origin():
	moved_pos = Vector2.ZERO
	position = original_position
	scale = original_scale
	is_grouped = false
	self.enabled = true


func is_moving():
	return target_position != null


var block_speed = -1.0
func move_with_logics(di: int, speed_scale: float = 1.0):
	block_speed = speed_scale * moving_speed
	self.moved_pos += Triangle.ID_DIRECTIONS[di]
	move_to(
		position +
		Triangle.DIRECTIONS[di] * Triangle.SideLength
	)

var target_position = null
func move_to(pos: Vector2):
	game.animating[self] = true
	if block_speed < 0:
		block_speed = moving_speed
	target_position = Triangle.get_nearest_point(pos)


func update_moving(delta):
	if target_position != null:
		position = position.move_toward(target_position, delta * block_speed)
		if (position - target_position).length_squared() <= 1e-5:
			position = target_position
			target_position = null
			block_speed = -1
			if game != null:
				game.animating.erase(self)
			emit_signal("moved")


func _physics_process(delta):
	update_moving(delta)


func get_pos_ids():
	if is_grouped:
		return null
	var ret = []
	for each in pos_ids:
		ret.append(each + moved_pos)
	return ret


func get_all_blocks():
	return [self]


func _to_string():
	return "[Block (%s): %s]" % [type_name, name]


func initialize(game_):
	if initialized:
		return
	game = game_
	original_position = position
	original_scale = scale
	update_sprite()
	initialized = true


func clear_state():
	initialized = false
	is_grouped = false
	game = null
	pos_ids = []
	moved_pos = Vector2.ZERO


var showing_reversed = false
# Based on scales.
func update_sprite():
	if reversed_sprite != null:
		if showing_reversed == (scale.y > 0):
			showing_reversed = not showing_reversed
			if showing_reversed:
				sprite.visible = false
				reversed_sprite.visible = true
			else:
				sprite.visible = true
				reversed_sprite.visible = false


func check_interact(player):
	return false


signal interacted(step)
func interact(player):
	yield(get_tree(), "idle_frame")
	emit_signal("interacted", {})


func get_polygon_center():
	var ret = Vector2.ZERO
	var n = 0
	for block in get_all_blocks():
		for v in block.get_polygon():
			ret += v * block.scale + block.position
			n += 1
	return ret / n
