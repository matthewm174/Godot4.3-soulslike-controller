extends Area3D

@export var dialogue_res: DialogueResource
@export var dialogue_start: String = "start"

func player_interact() ->  void:
	DialogueManager.show_example_dialogue_balloon(dialogue_res, dialogue_start)
