tool
extends Node

const TriangleSize = Vector2(128, 111)


func get_nearest_point(v: Vector2):
	var j = int(round(v.y / TriangleSize.y))
	var t = (TriangleSize.x / 2) if j % 2 != 0 else 0.0
	var i = round((v.x + t) / TriangleSize.x)
	var x = i * TriangleSize.x - t
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
		i * TriangleSize.x / 2,
		j * TriangleSize.y + (74 if is_up else 37)
	)


# Coordinates of the three points
func get_triangle(id: Vector2):
	var i = int(id.x)
	var j = int(id.y)
	var is_up = get_is_up(id)
	var ret = PoolVector2Array()
	if is_up:
		ret.append(Vector2((i - 1) * TriangleSize.x / 2, (j + 1) * TriangleSize.y))
		ret.append(Vector2(i * TriangleSize.x / 2, j * TriangleSize.y))
		ret.append(Vector2((i + 1) * TriangleSize.x / 2, (j + 1) * TriangleSize.y))
	else:
		ret.append(Vector2((i - 1) * TriangleSize.x / 2, j * TriangleSize.y))
		ret.append(Vector2(i * TriangleSize.x / 2, (j + 1) * TriangleSize.y))
		ret.append(Vector2((i + 1) * TriangleSize.x / 2, j * TriangleSize.y))
	return ret


func _sign(p1: Vector2, p2: Vector2, p3: Vector2):
	return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y)


func point_in_triangle(v: Vector2, tri: PoolVector2Array):
	var d1 = _sign(v, tri[0], tri[1])
	var d2 = _sign(v, tri[1], tri[2])
	var d3 = _sign(v, tri[2], tri[0])
	var has_neg = d1 < 0 or d2 < 0 or d3 < 0
	var has_pos = d1 > 0 or d2 > 0 or d3 > 0
	return not (has_neg and has_pos)


func get_id(v: Vector2):
	var j = int(floor(v.y / TriangleSize.y))
	var i = int(floor(v.x / TriangleSize.x * 2))
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
