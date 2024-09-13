extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	PlayerGlobal.connect("score_changed", self, "update_score")
	update_score()


func update_score() -> void:
	text = "Score: " + String(PlayerGlobal.player_score_current)
