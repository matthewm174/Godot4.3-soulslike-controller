class_name HitBoxShield
extends Area3D

@export var damage := 10
@onready var collisionshape = $CollisionShape3D

var timer_hitbox : Timer = Timer.new()

var is_shield_equipped


func _ready() -> void:
	add_child(timer_hitbox)
	timer_hitbox.one_shot = false
	timer_hitbox.autostart = false
	timer_hitbox.wait_time = 0.3
	timer_hitbox.timeout.connect(func():
		collisionshape.disabled = true
	)

func _init() -> void:
	Globals.current_player.connect("on_block",  self.activate_hitbox)
	#Globals.current_player.connect("shield_equipped",  self.shield_equipped)
	collision_layer = 2
	collision_mask = 0
	pass

func activate_hitbox(value) -> void:
	if is_shield_equipped:
		collisionshape.disabled = false
		timer_hitbox.start()
	

func shield_equipped(value) -> void:
		#	turn off / on shield visibility
		is_shield_equipped = value
		get_parent().visible = value
		
