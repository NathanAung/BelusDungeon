extends Collectible

export(NodePath) var health_ui_node_path = "/root/Main/PlayerUI/CanvasLayer/Health"
onready var Health_UI = get_node(health_ui_node_path)


func _ready():
	item_name = "Mont Lone+"
	price = 40


func Collect():
	print("Collected ", value, " Health!")
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.gold)
	PlayerGlobal.player_HP_current = float(min(PlayerGlobal.player_HP_current + float(value), PlayerGlobal.player_HP_max))
	Health_UI.update_health()


# Show the description when player is on the collectible
func show_description():
	if !btm_text_UI.in_use and value > 1:
		btm_text_UI.bbcode_text = "[right]" + item_name + "[color=lime]" + " [Restores " + String(value) + " HP.]" + "[/color][/right]"
		btm_text_UI.visible = true
		btm_text_UI.in_use = true
		using_text = true
