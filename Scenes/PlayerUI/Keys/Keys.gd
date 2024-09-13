extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _ready():
	PlayerGlobal.connect("keys_changed", self, "update_keys")
	update_keys()

func update_keys():
	get_node("Amount").text = String(PlayerGlobal.keys_collected)
