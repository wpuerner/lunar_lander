extends StaticBody2D

@export var Flag: PackedScene

var rng = RandomNumberGenerator.new()

var line_2d: Line2D

# Called when the node enters the scene tree for the first time.
func _ready():
	line_2d = get_node("Line2D")
	line_2d.width = 2
	
	var radius = 200
	var planet_height_array = []
	build_planet_height_array(radius, radius, 50, 0.65, 7, planet_height_array)
	
	var points = PackedVector2Array()
	translate_heights_to_coordinates(planet_height_array, points)
	line_2d.set_points(points)
	
	create_convex_collision_shapes(points)
		
# Creating a planet
#  select a center for the planet and a radius
#  create array of height values by using midpoint displacement
#  translate each height value + angle around circle into x,y coordinates
#  paint the 2d line
#  decompose the polygon coliders so they are convex, with the bottom of the collider being the center of the circle
#  assign gravity effect pointing at the center of the circle
	
func build_planet_height_array(left: float, right: float, displacement: float, displacement_scale: float, depth: int, heights: Array):
	if (depth <= 0):
		heights.append(right)
		return
		
	var mid = left + (right - left) / 2
	mid += rng.randf_range(-1 * displacement, displacement)
	
	build_planet_height_array(left, mid, displacement * displacement_scale, displacement_scale, depth - 1, heights)
	build_planet_height_array(mid, right, displacement * displacement_scale, displacement_scale, depth - 1, heights)

func translate_heights_to_coordinates(heights: Array, points: PackedVector2Array):
	var angle_step = 2 * PI / heights.size()
	var curr_angle = 0
	for height in heights:
		points.append(Vector2(height * cos(curr_angle), height * sin(curr_angle)))
		curr_angle += angle_step
	# append the first element onto the end to avoid leaving a gap
	points.append(points[0])

func create_convex_collision_shapes(points: PackedVector2Array):
	var i_start = 0
	var i_curr = 0
	var i_mid = 1
	var i_next = 2
	
	while (i_next < points.size() + 1):
		if (i_next == points.size() or is_next_point_concave(points[i_curr], points[i_mid], points[i_next])):
			var collider_points = points.slice(i_start, i_next)
			collider_points.append(Vector2(0, 0))
			var collider = CollisionPolygon2D.new()
			add_child(collider)
			collider.set_polygon(collider_points)
			i_start = i_mid
		i_curr += 1
		i_mid += 1
		i_next += 1

func is_next_point_concave(one: Vector2, two: Vector2, next: Vector2):
	var left_vector = one - two
	var right_vector = two - next
	var angle = left_vector.angle_to(right_vector)
	return angle < 0
