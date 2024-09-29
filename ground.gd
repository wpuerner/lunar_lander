extends StaticBody2D

@export var Flag: PackedScene

const OFFSET_MULTIPLIER = 0.5
const GROUND_WIDTH = 3000
const GROUND_BASE_HEIGHT = 500
const LANDING_PAD_WIDTH = 200
const GROUND_SEGMENT_WIDTH = 30

var rng = RandomNumberGenerator.new()

var line_2d: Line2D

# Called when the node enters the scene tree for the first time.
func _ready():
	line_2d = get_node("Line2D")
	line_2d.width = 2
	
	var points = PackedVector2Array()
	points.append(Vector2(0, GROUND_BASE_HEIGHT))
	build_map_points(Vector2(0, GROUND_BASE_HEIGHT), Vector2(GROUND_WIDTH, GROUND_BASE_HEIGHT), 500, _get_regression_depth(GROUND_WIDTH, GROUND_SEGMENT_WIDTH), points)
	
	var landing_pad_width_points = LANDING_PAD_WIDTH / GROUND_SEGMENT_WIDTH  # width in points
	var starting_index = rng.randi_range(points.size() / 5, points.size() * 4 / 5)
	
	var left_points = points.slice(0, starting_index)
	var right_points = points.slice(starting_index, points.size())
	var landing_pad_points = right_points.slice(0, landing_pad_width_points)
	var landing_pad_y = landing_pad_points[0].y
	for i in range(landing_pad_points.size()):
		landing_pad_points[i].y = landing_pad_y

	right_points.resize(right_points.size() - landing_pad_width_points)
	var landing_pad_width_points_px = landing_pad_points[-1].x - landing_pad_points[0].x
	for i in range(right_points.size()):
		right_points[i].x += landing_pad_width_points_px

	var final_points = PackedVector2Array()
	final_points.append_array(left_points)
	final_points.append_array(landing_pad_points.slice(0, -1))
	final_points.append_array(right_points)
	
	Globals.landing_pad_points = landing_pad_points
	
	line_2d.set_points(final_points)
	
	create_convex_collision_shapes(final_points)
	
	var landing_zone = get_node("LandingZone")
	landing_zone.set_position(Vector2(landing_pad_points[0].x + landing_pad_width_points_px / 2, landing_pad_points[0].y - landing_pad_width_points_px / 2))
	
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
	
	build_map_points(left, mid, offset * OFFSET_MULTIPLIER, depth - 1, points)
	build_map_points(mid, right, offset * OFFSET_MULTIPLIER, depth - 1, points)

func _get_regression_depth(total_width: int, segment_width: int):
	var i = 0
	while segment_width < total_width:
		segment_width *= 2
		i += 1
	return i
