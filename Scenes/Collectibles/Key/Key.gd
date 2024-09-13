extends Collectible

# room name node from UI (used to show text)
export(NodePath) var room_name_node_path = "/root/Main/PlayerUI/CanvasLayer/RoomName"
onready var room_name_UI = get_node(room_name_node_path)


func Collect():
	print("Collected Key!")
	PlayerGlobal.keys_collected += 1
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.gold)
	room_name_UI.text = "Key Collected"
	room_name_UI.get_node("AnimationPlayer").play("Drop")
	
