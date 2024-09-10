extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#$Label_Backstab.visible = false
	#$PanelContainer_Gestures.visible = false
	#$PanelContainer_Gestures/VBoxContainer/HBoxContainer/Button_0.connect("pressed", Callable(self, "on_gesture").bind(0))
	#$PanelContainer_Gestures/VBoxContainer/HBoxContainer/Button_1.connect("pressed", Callable(self, "on_gesture").bind(1))
	Globals.current_player.connect("on_update_health",  self.update_health)
	Globals.current_player.connect("on_update_stamina",  self.update_stamina)
	Globals.current_player.connect("on_update_mana",  self.update_mana)
	#Globals.current_player.connect("on_toggle_backstab", Callable(self, "toggle_backstab"))
	#Globals.current_player.connect("on_death", Callable(self, "die"))
	
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	#if Input.is_action_just_pressed("gp_menu"):
		#$PanelContainer_Gestures.visible = !$PanelContainer_Gestures.visible
	#if $PanelContainer_Gestures.visible:
		#if Input.is_action_just_pressed("gp_dpad_l"):
			#$PanelContainer_Gestures/VBoxContainer/HBoxContainer/Button_0.emit_signal("pressed")
			#$PanelContainer_Gestures.visible = false
		#if Input.is_action_just_pressed("gp_dpad_r"):
			#$PanelContainer_Gestures/VBoxContainer/HBoxContainer/Button_1.emit_signal("pressed")
			#$PanelContainer_Gestures.visible = false

#func toggle_backstab(target, sensor_origin, enabled):
	#$Label_Backstab.visible = enabled

func update_health(value):
	$CanvasLayer/SubViewportContainer/SubViewport/PlayerStats/VBoxContainer/health.value = float(value)
func update_stamina(value):
	$CanvasLayer/SubViewportContainer/SubViewport/PlayerStats/VBoxContainer/stamina.value = float(value)
func update_mana(value):
	$CanvasLayer/SubViewportContainer/SubViewport/PlayerStats/VBoxContainer/mana.value = float(value)

#func on_gesture(index):
	#print("yes")
	#Globals.current_player.emit_signal("on_gesture", index)
#func die():
	#$DEATH/AnimationPlayer.play("default")
#func restart():
	#get_tree().reload_current_scene()
