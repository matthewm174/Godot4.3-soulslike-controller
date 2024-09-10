extends RigidBody3D

const PLAYER_DETECTION_RANGE = 10.0
const PLAYER_ATTACK_RANGE = 2.25
const WALK_SPEED = 2.25

var health = 100
var taunted = false
var distance_to_player = 0
var random_velocity_timer = 0.0
var random_velocity = Vector3.ZERO
var to_player_velocity = Vector3.ZERO
var around_player_velocity = Vector3.ZERO

var can_move = true
var can_hurt = false
var attack_timeout = 1.0
#var upperBodyPlaybackPath = "parameters/UpperSM/playback";
@onready var animplayer = $offender/AnimationPlayer
@onready var animtree := $offender/AnimationTree
@onready var model := $offender
@onready var uppersm = animtree.get("parameters/UpperSM/playback")
@onready var locosm = animtree.get("parameters/LocomotionSM/playback")


var timer_anim1 : Timer = Timer.new()
var timer_prejump : Timer = Timer.new()

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
		
		



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
