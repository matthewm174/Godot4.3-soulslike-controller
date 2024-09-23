extends StaticBody3D

signal toggle_inventory(ext_inv_owner)

@export var inventory_data: InvData


func player_interact() -> void:
	toggle_inventory.emit(self)
