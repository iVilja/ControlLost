extends Node2D


var hovered = false
var is_dragging = false
var dragging_start = Vector2()
onready var block = $Block
onready var start_position = block.position
onready var target_position = $Goal.position
onready var title = $Title/AnimatedSprite



func _on_Block_mouse_exited():
	hovered = false


func _on_Block_mouse_entered():
	hovered = true


func _on_Block_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		dragging_start = block.get_global_mouse_position()
		title.play("animated")
		is_dragging = true


var border_width = 6
func _on_Boundary_draw():
	var bc = Color("fefefe") if is_dragging else \
		Color("96a6ba") if hovered else Color("252525")
	var vertices = $Block/TrianglePolygonShape.polygon
	var boundary = $Block/Boundary
	var n = vertices.size()
	var center = Math.get_polygon_center(vertices)
	for i in range(n):
		vertices[i] = vertices[i].move_toward(center, border_width / 2)
		boundary.draw_circle(vertices[i], border_width / 2, bc)
	for i in range(n - 1):
		boundary.draw_line(vertices[i], vertices[i + 1], bc, border_width)
	boundary.draw_line(vertices[n - 1], vertices[0], bc, border_width)


const start_sfx = preload("res://resources/audio/sfx/start.wav")
func _process(delta):
	$Block/Boundary.update()
	if is_dragging:
		if not Input.is_mouse_button_pressed(BUTTON_LEFT):
			is_dragging = false
			if (block.position - target_position).length_squared() < 1e-5:
				SFX.audio_manager.play(start_sfx)
				Global.goto_scene("res://scenes/opening.tscn")
				return
			block.position = start_position
			player.volume_db = -30.0
			title.play("idle")
			return
		var direction = (target_position - start_position).normalized()
		var to_move = (block.get_global_mouse_position() - dragging_start).dot(direction)
		player.volume_db = move_toward(-30.0, 0.0, to_move / (target_position.x - start_position.x) * 30)
		block.position = start_position if to_move <= 0 else \
			start_position.move_toward(target_position, to_move)
		

const noise = preload("res://resources/audio/sfx/start_noise.wav")
onready var player = $AudioStreamPlayer
func play_background_noise():
	player.volume_db = -30.0
	player.stream = noise
	player.play()


const ZH_FONT = preload("res://resources/fonts/start-zh.tres")
func _ready():
	if Global.is_chinese():
		$Label.add_font_override("font", ZH_FONT)
	play_background_noise()
