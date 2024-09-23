extends Control
@onready var inventory: Control = $CanvasLayer/Inventory
@onready var external_inv: Control = $CanvasLayer/ExternalInv
@onready var grabbed_slot: Panel = $GrabbedSlot
var is_open = false
var grabbed_slot_data: InvSlotData
var external_inventory_owner

signal inventory_accessed(is_open: bool)

signal drop_slot_data(slot_data: InvSlotData)


func _ready() -> void:
	close()
	
func _physics_process(delta: float) -> void:
	if grabbed_slot.visible:
		grabbed_slot.global_position = get_global_mouse_position() + Vector2(5,5)
		
func set_external_inventory(_external_inv_owner):
	external_inventory_owner = _external_inv_owner
	#	external inv data
	var inventory_data = external_inventory_owner.inventory_data
	
	inventory_data.inventory_interact.connect(on_inventory_interact)
	external_inv.set_inventory_data(inventory_data)
	
	external_inv.show()
	
	
func clear_external_inventory():
	if external_inventory_owner:
		var inventory_data = external_inventory_owner.inventory_data
		
		inventory_data.inventory_interact.disconnect(on_inventory_interact)
		external_inv.clear_inventory_data(inventory_data)
		
		external_inv.hide()
		external_inventory_owner = null


func set_player_inventory_data(inv_data: InvData):
	inv_data.inventory_interact.connect(on_inventory_interact)
	inventory.set_inventory_data(inv_data)

func on_inventory_interact(inv_data: InvData, index: int, button: int)->void:
	print("%s %s %s" % [inv_data, index, button])
	
	match [grabbed_slot_data, button]:
		#if nothing grabbed, grab on lm.. etc
		[null, MOUSE_BUTTON_LEFT]:
			grabbed_slot_data = inv_data.grab_slot_data(index)
			print(grabbed_slot_data)
		[_, MOUSE_BUTTON_LEFT]:
			grabbed_slot_data = inv_data.drop_slot_data(grabbed_slot_data, index)
			print(grabbed_slot_data)
		[null, MOUSE_BUTTON_RIGHT]:
			pass
		[_, MOUSE_BUTTON_RIGHT]:
			grabbed_slot_data = inv_data.drop_single_slot_data(grabbed_slot_data, index)
			print(grabbed_slot_data)
	update_grabbed_slot()
	
func update_grabbed_slot() -> void:
	if grabbed_slot_data:
		grabbed_slot.show()
		grabbed_slot.set_slot_data(grabbed_slot_data)
	else:
		grabbed_slot.hide()
	
func open():
	$CanvasLayer.visible = true
	is_open = true
	inventory_accessed.emit(is_open)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func close():
	$CanvasLayer.visible = false
	is_open = false
	inventory_accessed.emit(is_open)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta):
	if Input.is_action_just_pressed("inventory"):
		external_inv.visible = false
		toggle_visibility()
	
func toggle_visibility():
	if is_open:
		
		close()
	else:
		open()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
	and event.is_pressed() and grabbed_slot_data:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			drop_slot_data.emit(grabbed_slot_data)
			grabbed_slot_data = null
		update_grabbed_slot()
