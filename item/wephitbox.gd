class_name HitBoxWeapon
extends Area3D

@export var damage := 10
@onready var collisionshape = $CollisionShape3D

var timer_hitbox : Timer = Timer.new()

func _ready() -> void:
	add_child(timer_hitbox)
	timer_hitbox.one_shot = false
	timer_hitbox.autostart = false
	timer_hitbox.wait_time = 0.3
	timer_hitbox.timeout.connect(func():
		collisionshape.disabled = true
	)

func _init() -> void:
	#Globals.current_player.connect("on_attack",  self.activate_hitbox)
	collision_layer = 2
	collision_mask = 0


func activate_hitbox() -> void:
	collisionshape.disabled = false
	timer_hitbox.start()
