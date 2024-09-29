extends CharacterBody3D

signal toggle_dialogue
var dialoguelist

func player_interact() -> void:
	toggle_dialogue.emit(self)
