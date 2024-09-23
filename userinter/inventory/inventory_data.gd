extends Resource

class_name InvData

signal inventory_updated(inv_data: InvData)

signal inventory_interact(inv_data: InvData, index: int, button: int)

@export var slots: Array[InvSlotData]


func drop_slot_data(grabbed_slot_data, index) -> InvSlotData:
	var slot_data = slots[index]
	
	var return_slot_data: InvSlotData
	if slot_data and slot_data.can_fully_merge_with(grabbed_slot_data):
		slot_data.fully_merge_with(grabbed_slot_data)
	else:
		slots[index] = grabbed_slot_data
		return_slot_data = slot_data
	inventory_updated.emit(self)
	return return_slot_data


func drop_single_slot_data(grabbed_slot_data: InvSlotData, index: int) -> InvSlotData:
	var slot_data = slots[index]
	
	if not slot_data:
		slots[index] = grabbed_slot_data.create_single_slot_data()
	elif slot_data.can_merge_with(grabbed_slot_data):
		slot_data.fully_merge_with(grabbed_slot_data.create_single_slot_data())
	
	inventory_updated.emit(self)
	if grabbed_slot_data.quantity > 0:
		return grabbed_slot_data
	else:
		return null


func grab_slot_data(index: int) -> InvSlotData:
	var slot_data = slots[index]
	
	if slot_data:
		slots[index] = null
		inventory_updated.emit(self)
		return slot_data
	else:
		return null

func on_slot_clicked(index: int, button: int) -> void:
	inventory_interact.emit(self, index, button)
	print("INV HIT")

func insert(item: ItemData):
	pass

func pick_up_slot_data(slot_data: InvSlotData) -> bool:
	for index in slots.size():
		if slots[index] and slots[index].can_fully_merge_with(slot_data):
			slots[index].fully_merge_with(slot_data)
			inventory_updated.emit(self)
			return true
	
	
	for index in slots.size():
		if not slots[index]:
			slots[index] = slot_data
			inventory_updated.emit(self)
			return true
	return false
