
class_name SaveGame
extends Resource


const SAVE_GAME_BASE_PATH := "user://save"
export var high_score := 0
export var best_time:float = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func write_savegame() -> void:
	ResourceSaver.save(get_save_path(), self)


static func get_save_path() -> String:
	var extension := ".tres" if OS.is_debug_build() else ".res"
	return SAVE_GAME_BASE_PATH + extension


static func save_exists() -> bool:
	return ResourceLoader.exists(get_save_path())


static func load_savegame() -> Resource:
	var save_path := get_save_path()
	return ResourceLoader.load(save_path, "", true)
