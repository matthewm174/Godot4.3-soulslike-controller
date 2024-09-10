extends RigidBody3D



@export var WepHandContainer: Node3D
@export var HipContainer: Node3D
@export var WepContainer: Node3D

@onready var animplayer = $manne/AnimationPlayer
@onready var t_piv := $TwistPiv
@onready var p_piv := $TwistPiv/PitchPiv
@onready var animtree := $manne/AnimationTree
@onready var camera := $TwistPiv/PitchPiv/Camera3D
@onready var model := $manne

#var locosm = animtree["parameters/LocomotionSM"]
var upperBodyPlaybackPath = "parameters/UpperSM/playback";
@onready var uppersm = animtree.get(upperBodyPlaybackPath)
@onready var locosm = animtree.get("parameters/LocomotionSM/playback")


const GRAVITY = 12.5
const MAX_SPEED = 5.75
const SPRINT_SPEED = 2
const VIEW_SPEED = 7
const MOUSE_SENSITIVITY = 0.3
const JOY_SENSITIVITY = 7.5
const ROLL_STRENGTH = 0.6
const ROLL_STRENGTH_SIDEWAYS = 0.25
const jump_vel = 10

var mouse_sens := 0.001
var twist := 0.0
var pitch := 0.0
var health = 100
var mana = 100
var stamina = 100
var yaw = 0.0
var can_control = true
var is_rolling = false
var is_jumping = false
var view_direction = Vector3.ZERO
var direction := Vector3.ZERO
var roll_force = Vector3.ZERO
var direction_input
var lock_on_active
var lock_on_target
var is_in_combat = false
var timer_anim1 : Timer = Timer.new()
var timer_prejump : Timer = Timer.new()


signal on_update_health
signal on_update_stamina
signal on_update_mana

func _init():
	Globals.current_player = self

func equipWep():
	var parent = WepContainer.get_parent()
	parent.remove_child(WepContainer)
	WepHandContainer.add_child(WepContainer)
	WepContainer.position = Vector3.ZERO
	WepContainer.rotation_degrees = Vector3.ZERO
	
	
func unequipWep():
	var parent = WepContainer.get_parent()
	parent.remove_child(WepContainer)
	HipContainer.add_child(WepContainer)
	WepContainer.position = Vector3.ZERO
	WepContainer.rotation_degrees = Vector3.ZERO
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	view_direction = t_piv.global_transform.basis.z
	add_child(timer_anim1)
	timer_anim1.one_shot = false
	timer_anim1.autostart = false
	timer_anim1.wait_time = 0.7
	timer_anim1.timeout.connect(func():
		is_rolling = false
		can_control = true
		)
	add_child(timer_prejump)
	timer_prejump.one_shot = true
	timer_prejump.autostart = false
	timer_prejump.wait_time = 1
	timer_prejump.timeout.connect(func():
		is_jumping = false
		can_control = true
		)
	animtree.set("parameters/state/transition_request", "idle")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			yaw = fmod(yaw - event.relative.x * MOUSE_SENSITIVITY, 360)
			pitch = max(min(pitch - event.relative.y * MOUSE_SENSITIVITY, 50), -30)
			t_piv.rotation_degrees = Vector3(pitch, yaw, 0)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	emit_signal("on_update_health", health)
	emit_signal("on_update_stamina", stamina)
	emit_signal("on_update_mana", mana)
	direction = Vector3.ZERO
	direction_input = Vector2.ZERO
		
	if can_control:
		direction_input.y -= Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
		direction_input.x -= Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
		direction -= t_piv.global_transform.basis.z * direction_input.y - t_piv.global_transform.basis.x * direction_input.x
		direction.y = 0.0
	#
	if direction != Vector3.ZERO:
		view_direction = lerp(view_direction, direction, delta * VIEW_SPEED)
		$direction.look_at(global_transform.origin - linear_velocity * 2.0, Vector3.UP)
		linear_velocity = lerp(linear_velocity, view_direction.normalized() * (MAX_SPEED + SPRINT_SPEED * int(Input.is_action_pressed("sprint"))), delta * VIEW_SPEED)
		if !lock_on_active:
			model.global_transform.basis = model.global_transform.basis.slerp(model.global_transform.looking_at(global_transform.origin - view_direction * 2.0, Vector3.UP).basis, delta * VIEW_SPEED)
	else:
		linear_velocity = lerp(linear_velocity, Vector3.ZERO, delta * 5.0)
	
	camera.transform = camera.transform.looking_at(Vector3.ZERO, Vector3.UP)
	#linear_velocity += roll_force
	linear_velocity.y -= GRAVITY * delta
	linear_velocity.y = clamp(linear_velocity.y, -GRAVITY, GRAVITY)



	
	
	if $FloorSensor.is_colliding():
		#animtree.set("parameters/bodyBlend/blend_amount", 0);
		locosm.travel("move")
		animtree.set("parameters/LocomotionSM/move/blend_position", direction_input)
			
		if can_control:
			if not is_rolling and not is_jumping:
			#disconnect so upper does run unless another upper command recieved
				if Input.is_action_pressed("move_roll"):
					animtree.set("parameters/bodyBlend/blend_amount", 0);
					locosm.travel("roll")
					animtree.set("parameters/LocomotionSM/roll/blend_position", direction_input)
					timer_anim1.start()
					is_rolling = true
					can_control = false
				if Input.is_action_pressed("move_jump"):
					#linear_velocity = lerp(linear_velocity, , delta * 5.0)
					linear_velocity.y = jump_vel
					linear_velocity += 10.0 * view_direction.normalized() 
					animtree.set("parameters/bodyBlend/blend_amount", 0);
					locosm.travel("jump")
					timer_prejump.start()
					is_jumping = true
					can_control = false
					
			if Input.is_action_pressed("draw_wep"):
				animtree.set("parameters/bodyBlend/blend_amount", 1);
				if not is_in_combat:
					is_in_combat = true
					uppersm.travel("draw")
					can_control = false
					timer_anim1.start()
				else:
					is_in_combat = false
					uppersm.travel("sheath")
					can_control = false
					timer_anim1.start()
			
			if Input.is_action_pressed("strike_light") and is_in_combat:
				animtree.set("parameters/bodyBlend/blend_amount", 1);
				uppersm.travel("lite_atk")
				timer_anim1.start()
				can_control = false
			if Input.is_action_pressed("block"):
				animtree.set("parameters/bodyBlend/blend_amount", 1);
				uppersm.travel("block")
			if Input.is_action_just_released("block"):
				animtree.set("parameters/bodyBlend/blend_amount", 1);
				uppersm.travel("idle")
			if Input.is_action_pressed("use_item"):
				timer_anim1.start()
				animtree.set("parameters/bodyBlend/blend_amount", 1);
				uppersm.travel("potion")
				can_control = false
			if Input.is_action_pressed("use_item"):
				timer_anim1.start()
				animtree.set("parameters/bodyBlend/blend_amount", 1);
				uppersm.travel("consume")
				can_control = false
		


#func _on_hitbox_area_entered(area: Area3D) -> void:
	#print("enemy hit")
		#
