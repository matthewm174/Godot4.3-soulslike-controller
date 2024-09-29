extends Node3D
@onready var player_node: CharacterBody3D = $PlayerNode

@onready var inventory_interface = player_node.get_node("Inventory")
@onready var item_manager = ItemManager.new()

@onready var offender: Enemy = $Offender



const MOLTING_SWAMP = preload("res://level/molting_swamp.tscn")
var is_open
const pickup = preload("res://item/pick_up_item.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	item_manager.saveData()
	item_manager.loadData()
	
	inventory_interface.connect("inventory_accessed", close_other_ui)
	inventory_interface.connect("drop_slot_data", on_drop_slot_data)
	inventory_interface.set_player_inventory_data(player_node.inv)

	for node in get_tree().get_nodes_in_group("external_inventory"):
		node.toggle_inventory.connect(toggle_inventory_interface)

		

	#dialogue_interface.toggle_visibility()
		
func toggle_inventory_interface(external_inv_owner = null) -> void:
	inventory_interface.toggle_visibility()
	if external_inv_owner and inventory_interface.visible:
		inventory_interface.set_external_inventory(external_inv_owner)
	else:
		inventory_interface.clear_external_inventory()
		
func close_other_ui(is_inv_open: bool):
	if(is_inv_open):
		player_node.control_ui.visible = false
	else:
		player_node.control_ui.visible = true		

func on_drop_slot_data(slot_data: InvSlotData) -> void:
	var pick_up = pickup.instantiate()
	var item_map = item_manager.get_item_map()
	
	pick_up.slot_data = slot_data
	var m = item_map.items[slot_data.item.name]["item_mesh"]
	var t = item_map.items[slot_data.item.name]["texture"]
	var child_node = pick_up.get_node("PickupMesh") 
	
	if child_node:
		pick_up.remove_child(child_node)
	var x = MeshInstance3D.new()
	x.mesh = m
	var material = StandardMaterial3D.new()
	material.albedo_texture = t
	x.material_override = material
	pick_up.add_child(x)

	pick_up.position = Globals.current_player.get_drop_pos()
	
	add_child(pick_up)
