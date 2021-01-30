 tool
extends Area2D

class_name Battleground

const GameManager = preload("res://core/game_manager.gd")
var game: GameManager = null
const Block = preload("res://game_objects/blocks/block.gd")
const Terrain = preload("res://game_objects/terrains/terrain.gd")


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
				if c.game != null and c.game != game:
					continue
				if c is Block:
					c.pos_ids.append(id)
					c.game = game
					if not (c in game.blocks):
						if c.is_draggable:
							game.blocks.insert(0, c)
						else:
							game.blocks.append(c)
					game.blocks_map[id] = c
				elif c is Terrain:
					c.pos_ids.append(id)
					c.game = game
					if not (c in game.terrains):
						game.terrains.append(c)
					game.terrains_map[id] = c
				elif each.collider == self:
					if not (id in game.terrains_map):
						game.terrains_map[id] = null
	game.initialize()
