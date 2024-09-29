extends CharacterBody3D



@export var WepHandContainer: Node3D
@export var HipContainer: Node3D
@export var WepContainer: Node3D
@export var inv: InvData
@onready var interaction_ray: RayCast3D = $manne/Armature/GeneralSkeleton/InteractionRay

@onready var control_ui: CanvasLayer = $ControlUI/CanvasLayer	


@onready var animplayer = $manne/AnimationPlayer
@onready var t_piv := $TwistPiv #$TwistPiv
@onready var p_piv := $TwistPiv/PitchPiv #$TwistPiv/PitchPiv
@onready var animtree := $manne/AnimationTree
@onready var camera := $TwistPiv/PitchPiv/Camera3D
#@onready var camera := $SubViewportContainer/SubViewport/TwistPiv/PitchPiv/Camera3D
@onready var model := $manne

#var locosm = animtree["parameters/LocomotionSM"]
@onready var uppersm = animtree.get("parameters/UpperSM/playback")
@onready var locosm = animtree.get("parameters/LocomotionSM/playback")
@onready var offhand = animtree.get("parameters/Offhand/playback")
@onready var uppertimescale = animtree.get("parameters/uppertime/scale")

#physics
const GRAVITY = 12.5
const MAX_SPEED = 5.75
const SPRINT_SPEED = 2
const VIEW_SPEED = 7
const MOUSE_SENSITIVITY = 0.3
const JOY_SENSITIVITY = 7.5
const ROLL_STRENGTH = 0.6
const ROLL_STRENGTH_SIDEWAYS = 0.25
const jump_vel = 80

#cam variables
var mouse_sens := 0.001
var twist := 0.0
var pitch := 0.0
var yaw = 0.0

#player vars
var health = 100
var mana = 100
var stamina = 100

#action controls
var can_control = true
var is_rolling = false
var is_blocking = false
var is_jumping = false
var is_dead = false
var is_staggered = false
var is_parried_or_poise_broken
var is_drawing = false
var is_attacking = false

var view_direction = Vector3.ZERO
var direction := Vector3.ZERO
var roll_force = Vector3.ZERO
var direction_input
var lock_on_active
var lock_on_target
var is_in_combat = false
var movement_threshold := .1
var stagger_time : Timer = Timer.new()
var poise_broken_time : Timer = Timer.new()
var timer_anim1 : Timer = Timer.new()
var drawing_time : Timer = Timer.new()
var attack_time : Timer = Timer.new()
var rolling_time : Timer = Timer.new()


#var timer_prejump : Timer = Timer.new()

signal on_update_health
signal on_update_stamina
signal on_update_mana
signal on_block
signal on_player_attack
signal on_parry
signal on_cast

func _init():
	Globals.current_player = self
	

func collect_item(item):
	inv.insert(item)

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
	
func handle_input() -> void:
	if can_control:
		locosm.travel("move")
		animtree.set("parameters/LocomotionSM/move/blend_position", direction_input)
		if not is_drawing and not is_attacking and not is_rolling and not is_jumping and not is_parried_or_poise_broken:
			if Input.is_action_just_pressed("move_back") \
			or Input.is_action_just_pressed("move_forward") or Input.is_action_just_pressed("move_left") or Input.is_action_pressed("move_right"):
				uppersm.travel("run")
			if Input.is_action_just_released("move_back") \
			or Input.is_action_just_released("move_forward") or Input.is_action_just_released("move_left") or Input.is_action_just_released("move_right"):
				uppersm.travel("idle")
			if Input.is_action_just_pressed("move_roll"):
				player_roll()
			if Input.is_action_just_pressed("move_jump"):
				player_jump()
			if Input.is_action_just_pressed("draw_wep"):
				play_draw_wep()
			if Input.is_action_just_pressed("strike_light"):
				player_strike_light()
			if Input.is_action_just_pressed("block"):
				player_block()
			if Input.is_action_just_released("block"):
				player_block_release()
			if Input.is_action_just_pressed("parry"):
				player_parry()
			if Input.is_action_just_pressed("use_item"):
				player_use_quick_item()
			if Input.is_action_just_pressed("interact"):
				interact()

# thing character can do
func player_parry():
	animtree.set("parameters/offhandBlen/blend_amount", 1);
	is_blocking = false
	offhand.travel("parry")
func player_use_quick_item():
	timer_anim1.start()
	animtree.set("parameters/bodyBlend/blend_amount", 1);
	uppersm.travel("consume")
	can_control = false

func player_block_release():
	animtree.set("parameters/bodyBlend/blend_amount", 1);
	is_blocking = false
	offhand.travel("idle")

func player_block():
	animtree.set("parameters/offhandBlen/blend_amount", 1);
	is_blocking = true
	offhand.travel("block")

func player_strike_light():
	uppertimescale = 5
	animtree.set("parameters/bodyBlend/blend_amount", 1);
	uppersm.travel("lite_atk")
	emit_signal("on_player_attack")
	is_attacking = true
	can_control = false

	attack_time.start()

func player_jump():
	velocity.y = jump_vel
	animtree.set("parameters/bodyBlend/blend_amount", 0);
	locosm.travel("jump")

func player_roll():
	if stamina > 20:
		animtree.set("parameters/bodyBlend/blend_amount", 0);
		locosm.travel("roll")
		stamina -= 20
		velocity += 2.0 * view_direction.normalized() 
		animtree.set("parameters/LocomotionSM/roll/blend_position", direction_input)
		is_rolling = true
		can_control = false
		rolling_time.start()
	
func player_death():
	animtree.set("parameters/bodyBlend/blend_amount", 0);
	locosm.travel("death")
	print("DEATH!")
	can_control = false
	is_dead = true

func play_draw_wep():
	uppertimescale = 3
	animtree.set("parameters/bodyBlend/blend_amount", 1);
	if not is_in_combat:
		
		uppersm.travel("draw")
		is_in_combat = true
		can_control = false
		is_drawing = true
		drawing_time.start()
	else:
		uppersm.travel("sheath")
		is_in_combat = false
		can_control = false
		is_drawing = true
		drawing_time.start()
	
func interact() -> void:
	if interaction_ray.is_colliding():
		interaction_ray.get_collider().player_interact()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	view_direction = t_piv.global_transform.basis.z
	#general anim timer if i dont feel the need for flexible timing
	add_child(timer_anim1)
	timer_anim1.one_shot = false
	timer_anim1.autostart = false
	timer_anim1.wait_time = 0.7
	timer_anim1.timeout.connect(func():
		is_rolling = false
		can_control = true
		)
	#drawing wep
	add_child(drawing_time)
	drawing_time.one_shot = false
	drawing_time.autostart = false
	drawing_time.wait_time = 1.0
	drawing_time.timeout.connect(func():
		is_drawing = false
		can_control = true
		uppertimescale = 1
		)
	#poise ended
	add_child(poise_broken_time)
	poise_broken_time.one_shot = false
	poise_broken_time.autostart = false
	poise_broken_time.wait_time = 1.4
	poise_broken_time.timeout.connect(func():
		can_control = true
		is_parried_or_poise_broken = false
		)
	add_child(attack_time)
	attack_time.one_shot = false
	attack_time.autostart = false
	attack_time.wait_time = .5
	attack_time.timeout.connect(func():
		is_attacking = false
		can_control = true
		uppertimescale = 1
		)
	add_child(rolling_time)
	rolling_time.one_shot = false
	rolling_time.autostart = false
	rolling_time.wait_time = 1.0
	rolling_time.timeout.connect(func():
		is_rolling = false
		can_control = true
		)


func get_drop_pos() -> Vector3:
	var d = 	Globals.current_player.global_transform.basis.z
	return Globals.current_player.global_position + d
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			yaw = fmod(yaw - event.relative.x * MOUSE_SENSITIVITY, 360)
			pitch = max(min(pitch - event.relative.y * MOUSE_SENSITIVITY, 50), -30)
			t_piv.rotation_degrees = Vector3(pitch, yaw, 0)




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	handle_input()
	if $FloorSensor.is_colliding():
		is_jumping = false
		can_control = true
		
	else:
		is_jumping = true
		can_control = false
	
	if is_dead:
		return
	emit_signal("on_update_health", health)
	emit_signal("on_update_stamina", stamina)
	emit_signal("on_update_mana", mana)
	direction = Vector3.ZERO
	direction_input = Vector2.ZERO
	direction_input.y -= Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	direction_input.x -= Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
	direction -= t_piv.global_transform.basis.z * direction_input.y - t_piv.global_transform.basis.x * direction_input.x
	direction.y = 0.0

	if direction != Vector3.ZERO:
		direction = direction.normalized()
		view_direction = lerp(view_direction, direction, delta * VIEW_SPEED)
		$direction.look_at(global_transform.origin - velocity * 2.0, Vector3.UP)
		velocity = velocity.lerp(direction * (MAX_SPEED + SPRINT_SPEED * int(Input.is_action_pressed("sprint"))), delta * VIEW_SPEED)
		if !lock_on_active:
			model.global_transform.basis = \
			model.global_transform.basis.slerp( \
			model.global_transform.looking_at(global_transform.origin - view_direction * 2.0, Vector3.UP).basis, delta * VIEW_SPEED)
	else:
		velocity = velocity.lerp(Vector3.ZERO, delta * 5.0)

	camera.transform = camera.transform.looking_at(Vector3.ZERO, Vector3.UP)
	velocity.y -= GRAVITY * delta * 5
	velocity.y = clamp(velocity.y, -GRAVITY, GRAVITY)
	move_and_slide()

	if is_rolling:
		velocity += 0.9 * view_direction.normalized() 
	

			
func take_damage(damage: int) -> void:
	if is_blocking:
		stamina -= damage
		if stamina <= 0:
			is_parried_or_poise_broken = true
		if is_parried_or_poise_broken:
			uppersm.travel("parried")
			locosm.travel("parried")
			offhand.travel("parried")
			poise_broken_time.start()
		if health > 0:
			health -= damage/2
			print("DAMAGE TAKEN!")
			animtree.set("parameters/bodyBlend/blend_amount", 1);
			offhand.travel("blocked")
			can_control = false
			timer_anim1.start()
		else:
			player_death()
	else:
		if health > 0:
			health -= damage
			print("DAMAGE TAKEN!")
			animtree.set("parameters/bodyBlend/blend_amount", 1);
			uppersm.travel("hurt")
			timer_anim1.start()
			can_control = false
		else:
			player_death()
		
