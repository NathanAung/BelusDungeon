extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _ready():
	PlayerGlobal.connect("gold_changed", self, "update_gold")
	update_gold()

func update_gold():
	get_node("Amount").text = String(PlayerGlobal.player_Gold_current)
