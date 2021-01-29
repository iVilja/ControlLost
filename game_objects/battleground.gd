tool
extends Area2D

class_name Battleground

const GameManager = preload("res://core/game_manager.gd")
var game: GameManager = null
const Block = preload("res://game_objects/block.gd")
const Terrain = preload("res://game_objects/terrain.gd")


func is_up(row: int) -> bool:
	return row % 2 == 1


func initialize(game_, area):
	game = game_
	var rect = Triangle.get_polygon_rect(area.polygon)
	var start = Triangle.get_id(rect.position)
	var end = Triangle.get_id(rect.end)
	var s = get_world_2d().direct_space_state
	for i in range(start.x, end.x + 1):
		for j in range(start.y, end.y + 1):
			var id = Vector2(i, j)
			for each in s.intersect_point(
				Triangle.get_center(id) + position,
				32, [], 2147483647, true, true
			):
				var c = each.collider
				if c is Block:
					c.pos_ids.append(id)
					c.game = game
					game.blocks[id] = c
				elif c is Terrain:
					c.pos_ids.append(id)
					c.game = game
					game.terrains[id] = c
				elif each.collider == self:
					if not game.terrains.has(id):
						game.terrains[id] = null
