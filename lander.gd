extends RigidBody2D

signal crashed
signal landed

var main_thruster: CPUParticles2D
var rcs_thruster_top_left: CPUParticles2D
var rcs_thruster_top_right: CPUParticles2D
var rcs_thruster_bottom_right: CPUParticles2D
var rcs_thruster_bottom_left: CPUParticles2D
var crash_particles: CPUParticles2D
var landing_detector_right: Area2D
var landing_detector_left: Area2D

var initial_speed: float

var init = false
var game_ended = false

var landing_counter = 60

var _fuel: int = 1000

func _ready():
	main_thruster = get_node("MainThruster")
	rcs_thruster_top_left = get_node("RcsThrusterTopLeft")
	rcs_thruster_top_right = get_node("RcsThrusterTopRight")
	rcs_thruster_bottom_right = get_node("RcsThrusterBottomRight")
	rcs_thruster_bottom_left = get_node("RcsThrusterBottomLeft")
	crash_particles = get_node("CrashParticles")
	landing_detector_right = get_node("LandingDetectorRight")
	landing_detector_left = get_node("LandingDetectorLeft")
	
	var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	initial_speed = sqrt(gravity * get_height())

func _integrate_forces(state):
	if (!init):
		state.set_linear_velocity(Vector2(initial_speed, 0.0))
		init = true

func _physics_process(delta):
	set_gravity_scale(calculate_effective_gravity_scale())
	
	if (game_ended): return
	
	# check if lander hit the landing hear too hard
	if ((landing_detector_right.has_overlapping_bodies()
	or landing_detector_left.has_overlapping_bodies())
	and self.linear_velocity.y > 15):
		crash()
	
	# check if the lander has landed within the landing pad successfully
	if (landing_detector_right.has_overlapping_bodies() 
	and landing_detector_left.has_overlapping_bodies() 
	and abs(self.angular_velocity) < 1 
	and abs(self.linear_velocity.x) < 1 
	and abs(self.linear_velocity.y) < 1 
	and self.position.x > Globals.landing_pad_points[0].x 
	and self.position.x < Globals.landing_pad_points[-1].x):
		game_ended = true  
		emit_signal("landed")

	var rcs_intensity = 100.0
	var thruster_intensity = 100.0
	var rcs_fuel_rate = 0.1
	var thruster_fuel_rate = 0.5

	var rotating_right = Input.is_action_pressed("ui_right") and _fuel > 0
	var rotating_left = Input.is_action_pressed("ui_left") and _fuel > 0
	var thrusting = Input.is_action_pressed("ui_accept") and _fuel > 0

	if rotating_right:
		if !rcs_thruster_top_left.emitting: rcs_thruster_top_left.set_emitting(true)
		if !rcs_thruster_bottom_right.emitting: rcs_thruster_bottom_right.set_emitting(true)
		_fuel -= rcs_fuel_rate
		apply_torque(rcs_intensity)
	else:
		if rcs_thruster_top_left.emitting: rcs_thruster_top_left.set_emitting(false)
		if rcs_thruster_bottom_right.emitting: rcs_thruster_bottom_right.set_emitting(false)
		
		
	if rotating_left:
		if !rcs_thruster_top_right.emitting: rcs_thruster_top_right.set_emitting(true)
		if !rcs_thruster_bottom_left.emitting: rcs_thruster_bottom_left.set_emitting(true)
		_fuel -= rcs_fuel_rate
		apply_torque(-rcs_intensity)
	else:
		if rcs_thruster_top_right.emitting: rcs_thruster_top_right.set_emitting(false)
		if rcs_thruster_bottom_left.emitting: rcs_thruster_bottom_left.set_emitting(false)
		
	if thrusting:
		if !main_thruster.emitting: main_thruster.set_emitting(true)
		_fuel -= thruster_fuel_rate
		var thrust_force = Vector2(0.0, -thruster_intensity).rotated(rotation)
		apply_central_force(thrust_force)
	else:
		if main_thruster.emitting: main_thruster.set_emitting(false)

func calculate_effective_gravity_scale():
	var horizontal_speed = get_linear_velocity().dot(Vector2(1.0,0.0))
	var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	return 1 - pow(horizontal_speed, 2) / (gravity * get_height())

func get_height():
	return get_viewport().size.y - position.y
	
func landed_successfully():
	if !(position.x >= Globals.landing_pad_points[0].x && position.x <= Globals.landing_pad_points[-1].x): return false
	if linear_velocity.y > 20: return false
	if rotation_degrees > 45 || rotation_degrees < -45: return false
	
	return true
	
func crash():
	crash_particles.set_emitting(true)
	emit_signal("crashed")
	game_ended = true

func _on_area_2d_body_entered(body):
	crash()
