extends Node

var audio_manager = null
var current_scene = null
var current_game = null

var loading_stage = null


func _ready():
	randomize()
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)


func goto_scene(path):
	call_deferred("_deferred_goto_scene", path)


func _deferred_goto_scene(path):
	var t = NodeTransform.fade_out(current_scene, 2.0)
	yield(t, "transformed")
	current_scene.queue_free()
	var s = ResourceLoader.load(path)
	current_scene = s.instance()
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)


func load_scripts(file_name):
	var file = File.new()
	if not file.file_exists(file_name):
		return null
	file.open(file_name, file.READ)
	var ret = []
	while not file.eof_reached():
		var csv = file.get_csv_line()
		ret.append(csv)
	file.close()
	return ret
