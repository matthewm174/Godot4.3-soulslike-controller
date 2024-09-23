class_name ItemData
extends Resource
var player_in_pickup_range = false

@export var name: String = ""
@export_multiline var description: String = ""
@export var stackable: bool = false
@export var texture: Texture
@export var item: ItemData
@export var type:String
@export var damage:int
@export var modifiers:Dictionary
@export var item_mesh: Mesh
