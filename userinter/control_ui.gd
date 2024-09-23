extends Control

var is_open = true
var selected_item
var selected_item_description
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.current_player.connect("on_update_health",  self.update_health)
	Globals.current_player.connect("on_update_stamina",  self.update_stamina)
	Globals.current_player.connect("on_update_mana",  self.update_mana)

func open():
	$CanvasLayer.visible = true
	is_open = true

func close():
	$CanvasLayer.visible = false
	is_open = false



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("inventory"):
		if is_open:
			close()
		else:
			open()

func update_health(value):
	$CanvasLayer/PlayerStats/VBoxContainer/health.value = float(value)
func update_stamina(value):
	$CanvasLayer/PlayerStats/VBoxContainer/stamina.value = float(value)
func update_mana(value):
	$CanvasLayer/PlayerStats/VBoxContainer/mana.value = float(value)
