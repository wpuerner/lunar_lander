extends RigidBody2D

var init: bool
var initial_speed: float

func _draw():
	draw_circle(Vector2(0, 0), 15.0, Color.WHITE)

# Called when the node enters the scene tree for the first time.
func _ready():
	var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	initial_speed = sqrt(gravity * get_height())

func _integrate_forces(state):
	if (!init):
		state.set_linear_velocity(Vector2(initial_speed, 0.0))
		init = true

func get_height():
	return get_viewport().size.y - position.y
