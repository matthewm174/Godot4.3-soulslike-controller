class_name EnemyHurtBox

extends Area3D

@export var damage := 10

func _init() -> void:
	collision_layer = 0
	collision_mask = 2

func _ready() -> void:
	connect("area_entered",  self._on_area_entered)
	
func _on_area_entered(hitbox: HitBoxWeapon)->void:
	if hitbox == null:
		return
	#as long as this function exists in owner and is an enemy
	if owner.has_method("take_damage") and owner.is_in_group("enemy"):
		owner.take_damage(hitbox.damage)
