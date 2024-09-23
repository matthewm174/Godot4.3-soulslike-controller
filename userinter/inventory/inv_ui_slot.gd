extends Panel
@onready var quantity: Label = $quantity
@onready var item_display: TextureRect = $CenterContainer/ItemDisplay

signal slot_clicked(index: int, button: int)

func set_slot_data(slot: InvSlotData):
	var item_data = slot.item
	item_display.texture = item_data.texture
	tooltip_text = "%s\n%s" % [item_data.name, item_data.description]
	if slot.quantity > 0:
		quantity.text = "x%s" % slot.quantity
		quantity.show()
	else:
		quantity.hide()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT) \
	and event.is_pressed():
		slot_clicked.emit(get_index(), event.button_index)
