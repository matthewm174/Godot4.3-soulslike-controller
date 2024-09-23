extends Control

const Slot = preload("res://userinter/inventory/InvSlot.tscn")
@onready var items_grid: GridContainer = $TabContainer/Items/ItemsGrid

var is_open = false

func set_inventory_data(inventory_data: InvData):
	inventory_data.inventory_updated.connect(populate_item_grid)
	populate_item_grid(inventory_data)
	
func clear_inventory_data(inventory_data: InvData):
	inventory_data.inventory_updated.disconnect(populate_item_grid)

func populate_item_grid(inventory_data: InvData) -> void:
	for child in items_grid.get_children():
		child.queue_free()

	for slot_data in inventory_data.slots:
		var slot = Slot.instantiate()
		items_grid.add_child(slot)
		
		slot.slot_clicked.connect(inventory_data.on_slot_clicked)
		
		if slot_data:
			slot.set_slot_data(slot_data)
