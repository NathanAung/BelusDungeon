extends Node2D


var _save:SaveGame


# Called when the node enters the scene tree for the first time.
func _ready():
	_create_or_load_save()


func _create_or_load_save() -> void:
	if SaveGame.save_exists():
		_save = SaveGame.load_savegame()
		print("Save detected. High score: ", _save.high_score, " Best time: ", _save.best_time)
	else:
		_save = SaveGame.new()
		_save.write_savegame()
		print("New save file created.")
	PlayerGlobal.player_score_highest = _save.high_score
	PlayerGlobal.play_time_best = _save.best_time


# saved in game over script
func save_game() -> void:
	_save.high_score = PlayerGlobal.player_score_highest
	_save.best_time = PlayerGlobal.play_time_best
	#_save.best_time = 0
	_save.write_savegame()
	print("saved", _save.high_score)
