extends StaticBody2D

@export var Flag: PackedScene

var rng = RandomNumberGenerator.new()
var offset_multiplier = 0.5

var line_2d: Line2D

# Called when the node enters the scene tree for the first time.
func _ready():
	line_2d = get_node("Line2D")
	line_2d.width = 2
	
	var screen_midy = get_viewport().size.y * 2 / 3
	var screen_endx = get_viewport().size.x
	
	var points = PackedVector2Array()
	points.append(Vector2(0, screen_midy))
	build_map_points(Vector2(0, screen_midy), Vector2(screen_endx, screen_midy), 500, 7, points)
	
	var landing_pad_width = 10  # n points
	var starting_index = rng.randi_range(points.size() / 5, points.size() * 4 / 5)
	
	var left_points = points.slice(0, starting_index)
	var right_points = points.slice(starting_index, points.size())
	var landing_pad_points = right_points.slice(0, landing_pad_width)
	var landing_pad_y = landing_pad_points[0].y
	for i in range(landing_pad_points.size()):
		landing_pad_points[i].y = landing_pad_y

	right_points.resize(right_points.size() - landing_pad_width)
	var landing_pad_width_px = landing_pad_points[-1].x - landing_pad_points[0].x
	for i in range(right_points.size()):
		right_points[i].x += landing_pad_width_px

	var final_points = PackedVector2Array()
	final_points.append_array(left_points)
	final_points.append_array(landing_pad_points.slice(0, -1))
	final_points.append_array(right_points)
	
	Globals.landing_pad_points = landing_pad_points
	
	line_2d.set_points(final_points)
	
	create_convex_collision_shapes(final_points)
	
	var landing_zone = get_node("LandingZone")
	landing_zone.set_position(Vector2(landing_pad_points[0].x + landing_pad_width_px / 2, landing_pad_points[0].y - landing_pad_width_px / 2))
	
	var landing_zone_marker = get_node("LandingZone")
	
func create_convex_collision_shapes(points: PackedVector2Array):
	var i_start = 0
	var i_curr = 0
	var i_mid = 1
	var i_next = 2
	
	while (i_next < points.size() + 1):
		if (i_next == points.size() or is_next_point_concave(points[i_curr], points[i_mid], points[i_next])):
			var collider_points = points.slice(i_start, i_next)
			collider_points.append(Vector2(collider_points[-1].x, get_viewport().size.y))
			collider_points.append(Vector2(collider_points[0].x, get_viewport().size.y))
			var collider = CollisionPolygon2D.new()
			add_child(collider)
			collider.set_polygon(collider_points)
			i_start = i_mid
		i_curr += 1
		i_mid += 1
		i_next += 1
		
func is_next_point_concave(one: Vector2, two: Vector2, next: Vector2):
	var slope = (two.y - one.y) / (two.x - one.x)
	var height = one.y + (slope * (next.x - one.x))
	var result = next.y < height
	print(one, two, next, result)
	return result

func build_map_points(left: Vector2, right: Vector2, offset: int, depth: int, points: PackedVector2Array):
	if (depth <= 0):
		points.append(right)
		return
	
	var mid_x = left.x + (right.x - left.x) / 2
	var mid_y = left.y + (right.y - left.y) / 2
	var new_mid_y = mid_y + rng.randf_range(-1 * offset, offset)
	if new_mid_y < 100:
		new_mid_y = 200 + rng.randf_range(-50, 50)
	elif new_mid_y > get_viewport().size.y - 50:
		new_mid_y = get_viewport().size.y - 100 + rng.randf_range(-50, 50)
	
	var mid = Vector2(mid_x, new_mid_y)
	
	build_map_points(left, mid, offset * offset_multiplier, depth - 1, points)
	build_map_points(mid, right, offset * offset_multiplier, depth - 1, points)
