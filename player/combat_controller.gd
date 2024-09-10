#extends Node
#
#@export var WepHandContainer: Node3D
#@export var HipContainer: Node3D
#@export var WepContainer: Node3D
##@export var animtree: AnimationTree
#@onready var animtree := $"../manne/AnimationTree"
#var upperBodyPlaybackPath = "parameters/UpperSM/playback";
#
#
#var is_in_combat = false
#
#
#func _input(event):
	#if Input.is_action_just_pressed("draw_wep"):
		#var playback = animtree.get(upperBodyPlaybackPath) as AnimationNodeStateMachinePlayback
		#if not is_in_combat:
			#is_in_combat = true
			#playback.travel("draw")
			#
		#else:
			#is_in_combat = false
			#playback.travel("sheath")
	#if is_in_combat:
		#if Input.is_action_pressed("strike_light"):
			#var playback = animtree.get(upperBodyPlaybackPath) as AnimationNodeStateMachinePlayback
			#playback.travel("lite_atk")
			#
			#
#func equipWep():
	#var parent = WepContainer.get_parent()
	#parent.remove_child(WepContainer)
	#
	#WepHandContainer.add_child(WepContainer)
	#WepContainer.position = Vector3.ZERO
	#WepContainer.rotation_degrees = Vector3.ZERO
	#
	#
#func unequipWep():
	#var parent = WepContainer.get_parent()
	#parent.remove_child(WepContainer)
	#
	#HipContainer.add_child(WepContainer)
	#WepContainer.position = Vector3.ZERO
	#WepContainer.rotation_degrees = Vector3.ZERO
	#
#
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
