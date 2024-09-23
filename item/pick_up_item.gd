extends RigidBody3D
@onready var pickup_mesh: MeshInstance3D = $PickupMesh

@export var slot_data: InvSlotData

func _ready() -> void:
	pass

func _on_pick_up_area_body_entered(body: Node3D) -> void:
	print("pickup entered")

	if body.inv.pick_up_slot_data(slot_data):
		queue_free()
