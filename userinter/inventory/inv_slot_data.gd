extends Resource
class_name InvSlotData

const MAX_STACK_SIZE: int = 99
@export var item: ItemData
@export_range(1, MAX_STACK_SIZE) var quantity: int = 1: set = set_quant


func can_merge_with(other_slot_data: InvSlotData) -> bool:
	return item == other_slot_data.item \
	and item.stackable \
	and quantity < MAX_STACK_SIZE

func can_fully_merge_with(other_slot_data: InvSlotData) -> bool:
	return item == other_slot_data.item \
	and item.stackable \
	and quantity + other_slot_data.quantity < MAX_STACK_SIZE

func create_single_slot_data() -> InvSlotData:
	var new_slot_data = duplicate()
	new_slot_data.quantity = 1
	quantity-=1
	return new_slot_data

func fully_merge_with(other_slot_data: InvSlotData) -> void:
	quantity+=other_slot_data.quantity

func set_quant(value: int)->void:
	quantity = value
	if quantity > 1 and not item.stackable:
		quantity = 1
		push_error("%s is not stackable."%item.name)
