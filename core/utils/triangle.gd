tool
extends Node

const SideLength = 161
const TriangleSize = Vector2(SideLength, 139)

func get_nearest_point(v: Vector2):
	var j = int(round(v.y / TriangleSize.y))
	var t = (SideLength / 2) if j % 2 != 0 else 0.0
	var i = round((v.x + t) / SideLength)
	var x = i * SideLength - t
	var y = j * TriangleSize.y
	return Vector2(x, y)


func get_is_up(id: Vector2):
	var i = int(id.x)
	var j = int(id.y)
	return (i % 2 == 0) == (j % 2 == 0)


func get_center(id: Vector2):
	var i = int(id.x)
	var j = int(id.y)
	var is_up = get_is_up(id)
	return Vector2(
		i * SideLength / 2,
		j * TriangleSize.y + (74 if is_up else 37)
	)


# Coordinates of the three points
func get_triangle(id: Vector2):
	var i = int(id.x)
	var j = int(id.y)
	var is_up = get_is_up(id)
	var ret = PoolVector2Array()
	if is_up:
		ret.append(Vector2((i - 1) * SideLength / 2, (j + 1) * TriangleSize.y))
		ret.append(Vector2(i * SideLength / 2, j * TriangleSize.y))
		ret.append(Vector2((i + 1) * SideLength / 2, (j + 1) * TriangleSize.y))
	else:
		ret.append(Vector2((i - 1) * SideLength / 2, j * TriangleSize.y))
		ret.append(Vector2(i * SideLength / 2, (j + 1) * TriangleSize.y))
		ret.append(Vector2((i + 1) * SideLength / 2, j * TriangleSize.y))
	return ret


func _sign(p1: Vector2, p2: Vector2, p3: Vector2):
	return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y)


func point_in_triangle(v: Vector2, triangle):
	var d1 = _sign(v, triangle[0], triangle[1])
	var d2 = _sign(v, triangle[1], triangle[2])
	var d3 = _sign(v, triangle[2], triangle[0])
	var has_neg = d1 < 0 or d2 < 0 or d3 < 0
	var has_pos = d1 > 0 or d2 > 0 or d3 > 0
	return not (has_neg and has_pos)


func get_id(v: Vector2):
	var j = int(floor(v.y / TriangleSize.y))
	var i = int(floor(v.x / SideLength * 2))
	var id = Vector2(i, j)
	var t = get_triangle(id)
	if point_in_triangle(v, t):
		return id
	return Vector2(i + 1, j)


func get_polygon_rect(polygon):
	var x0 = 0
	var x1 = 0
	var y0 = 0
	var y1 = 0
	for v in polygon:
		if v.x < x0:
			x0 = v.x
		elif v.x > x1:
			x1 = v.x
		if v.y < y0:
			y0 = v.y
		elif v.y > y1:
			y1 = v.y
	return Rect2(x0, y0, x1 - x0, y1 - y0)


const ID_DIRECTIONS = [
	Vector2(2, 0),
	Vector2(1, 1),
	Vector2(-1, 1),
	Vector2(-2, 0),
	Vector2(-1, -1),
	Vector2(1, -1)
]
const DIRECTIONS = [
	Vector2(1, 0),
	Vector2(0.5, sqrt(3) / 2),
	Vector2(-0.5, sqrt(3) / 2),
	Vector2(-1, 0),
	Vector2(-0.5, -sqrt(3) / 2),
	Vector2(0.5, -sqrt(3) / 2)
]
func get_pathway(id: Vector2, d: Vector2):
	var is_up = get_is_up(id)
	var signx = sign(d.x)
	var signy = sign(d.y)
	var ret = []
	if signy == 0:
		ret.append(id + Vector2(signx, 0))
	elif is_up != (signy > 0):
		ret.append(id + Vector2(signx, 0))
	else:
		ret.append(id + Vector2(0, signy))
	ret.append(id + d)
	return ret


func get_direction(d: Vector2):
	var t = abs(d.y) > abs(d.x) / sqrt(3)
	if d.x > 0:
		if t:
			return 1 if d.y > 0 else 5
		else:
			return 0
	else:
		if t:
			return 2 if d.y > 0 else 4
		else:
			return 3


func get_direction_in_availables(d: Vector2, availables: Array):
	var closest = null
	var tmp = 0.0
	for v in availables:
		var t = d.dot(DIRECTIONS[v])
		if t <= 0:
			continue
		if closest == null or t > tmp:
			tmp = t
			closest = v
	return closest


func get_opposite(direction: int):
	return (direction + 3) % 6
