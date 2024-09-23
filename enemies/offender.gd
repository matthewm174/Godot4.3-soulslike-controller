extends RigidBody3D

const PLAYER_DETECTION_RANGE = 10.0
const PLAYER_ATTACK_RANGE = .9
const WALK_SPEED = 2.25

var health = 100
var stamina = 100
var taunted = false
var distance_to_player = 0
var random_velocity_timer = 0.0
var random_velocity = Vector3.ZERO
var to_player_velocity = Vector3.ZERO
var around_player_velocity = Vector3.ZERO
var is_blocking = false
var can_move = true
var can_hurt = false
var attack_timeout = 1.0
#var upperBodyPlaybackPath = "parameters/UpperSM/playback";
@onready var animplayer = $offender/AnimationPlayer
@onready var animtree := $offender/AnimationTree
@onready var model := $offender
@onready var uppersm = animtree.get("parameters/UpperSM/playback")
@onready var locosm = animtree.get("parameters/LocomotionSM/playback")
@onready var offhandsm = animtree.get("parameters/Offhand/playback")
var direction_input := Vector2.ZERO



var timer_anim1 : Timer = Timer.new()
var timer_prejump : Timer = Timer.new()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !can_move: return
	distance_to_player = Globals.current_player.global_transform.origin.distance_to(global_transform.origin)
	
	
	random_velocity_timer -= delta
	if random_velocity_timer <= 0.0:
		random_velocity_timer = 3.5
		if randf_range(0, 20) < 15:
			random_velocity = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)) * WALK_SPEED
	random_velocity = lerp(random_velocity, Vector3.ZERO, 0.01 * delta)
	# if Player is inside detection range
	if distance_to_player < PLAYER_DETECTION_RANGE:
		# taunt trigger
		if !taunted:
			set_action("walk")
			taunted = true
		# look at player
		var target = Globals.current_player.global_transform.origin
		look_at(2 * global_transform.origin - Globals.current_player.global_transform.origin, Vector3.UP)
		#model.global_transform.basis = model.global_transform.basis.slerp(model.global_transform.looking_at(target, Vector3.UP).basis, 5.0 * delta)
		if distance_to_player > PLAYER_ATTACK_RANGE:
			global_transform.origin = global_transform.origin.move_toward( target, delta)

		else:
			to_player_velocity = lerp(to_player_velocity, Vector3.ZERO, 5.0 * delta)
			# Circle around player
			if randf_range(0, 20) < 5:
				around_player_velocity -= model.global_transform.basis.x * sin(Time.get_ticks_msec()) * WALK_SPEED * 0.5
			# randomly attack
			set_action("block")
			attack_timeout -= delta
			if attack_timeout <= 0.0:
				attack_timeout = randf_range(0.5, 3.0)
				set_action("attack")
		
		linear_velocity = to_player_velocity + around_player_velocity
	else:
		set_action("idle")
		taunted = false
		linear_velocity = random_velocity
		look_at(global_transform.origin + linear_velocity * 2.0, Vector3.UP)
		
	linear_velocity.y = (1.0 - int($FloorSensor.is_colliding())) * -5

	
func set_action(index):
	match index:
		"walk":
			direction_input.x = 0
			direction_input.y = .5
			animtree.set("parameters/LocomotionSM/move/blend_position", direction_input)
			locosm.travel("move")
		"attack":
			emit_signal("on_attack")
			uppersm.travel("lite_atk")
		"block":
			offhandsm.travel("block")
			is_blocking = true
		"idle":
			direction_input.x = 0
			direction_input.y = 0
			animtree.set("parameters/LocomotionSM/move/blend_position", direction_input)
			locosm.travel("move")
			

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(timer_anim1)
	timer_anim1.one_shot = false
	timer_anim1.autostart = false
	timer_anim1.wait_time = 0.8
	timer_anim1.timeout.connect(func():
		can_move = true
		)
	add_child(timer_prejump)
	timer_prejump.one_shot = true
	timer_prejump.autostart = false
	timer_prejump.wait_time = 0.1
	timer_prejump.timeout.connect(func():
		linear_velocity.y = 10
		can_move = true
		)

func take_damage(damage: int) -> void:
	if is_blocking:
		stamina -= damage
		if health > 0:
			health -= damage/2
			print("DAMAGE TAKEN!")
			animtree.set("parameters/bodyBlend/blend_amount", 1);
			offhandsm.travel("blocked")
			timer_anim1.start()
			can_move = false
		else:
			animtree.set("parameters/bodyBlend/blend_amount", 0);
			locosm.travel("death")
			print("DEATH!")
			can_move = false
	else:
		if health > 0:
			health -= damage
			print("DAMAGE TAKEN!")
			animtree.set("parameters/bodyBlend/blend_amount", 1);
			uppersm.travel("hurt")
			timer_anim1.start()
			can_move = false
		else:
			animtree.set("parameters/bodyBlend/blend_amount", 0);
			locosm.travel("death")
			print("DEATH!")
			can_move = false
		
		
