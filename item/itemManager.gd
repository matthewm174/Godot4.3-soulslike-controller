extends Node
class_name ItemManager
var loadPath = "res://item/item_resources/items_map.tres"
var items_map: ItemMap = ItemMap.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	saveData()
	loadData()
	
func saveData()->void:
	var cracked_claymore:ItemData = ItemData.new()
	cracked_claymore.name = "Cracked Claymore"
	cracked_claymore.description = "This item aint great! Do better!"
	cracked_claymore.damage = 20
	cracked_claymore.type = "SLASH"
	cracked_claymore.modifiers = {}
	cracked_claymore.item_mesh = preload("res://item/weapon/crackedclay.obj")
	cracked_claymore.texture = preload("res://item/weapon/crackedclaymore_Image_0.png")
	cracked_claymore.stackable = false
	items_map.items	["Cracked Claymore"] = cracked_claymore
	var res = ResourceSaver.save(items_map, loadPath)
	
	if res != OK:
		print("ERROR SAVING ITEM FILES")
	else:
		print("SAVING ITEMS COMPLETE")
	
func loadData()->void:
	var loaded:Resource = ResourceLoader.load(loadPath)
	if loaded == null:
		print("ERROR LOADING ITEM FILES")
	else:
		items_map = loaded
		print("LOADING ITEMS COMPLETE")
		
func get_item_map()->Resource:
	
	return items_map
