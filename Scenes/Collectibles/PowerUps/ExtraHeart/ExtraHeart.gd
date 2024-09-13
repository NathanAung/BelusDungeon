extends Collectible

export(NodePath) var health_ui_node_path = "/root/Main/PlayerUI/CanvasLayer/Health"
onready var Health_UI = get_node(health_ui_node_path)


func _ready():
	item_name = "Extra Heart"
	price = 200
	auto_collect = false
	upgradable = true


# event inputs for picking up the power up
func _input(event):
	if Input.is_action_just_pressed("input_interact") and !auto_collect and player != null:
		if PlayerGlobal.player_HP_max < PlayerGlobal.player_HP_limit:
			Collect()
			player = null	# to avoid multiple collects
			queue_free()


func Collect():
	print("Collected extra Heart!")
	AudioGlobal.play_SFX(0)
	PlayerGlobal.player_HP_max = float(min(PlayerGlobal.player_HP_max + 4, PlayerGlobal.player_HP_limit))
	PlayerGlobal.player_HP_current = float(min(PlayerGlobal.player_HP_current + 4, PlayerGlobal.player_HP_max))
	Health_UI.generate_hearts()
	Health_UI.update_health()
	if !PlayerGlobal.collected_power_ups.has(PlayerGlobal.power_up_dict.extra_heart):
		PlayerGlobal.collected_power_ups.append(PlayerGlobal.power_up_dict.extra_heart)
	power_up_UI.update_display()


# Show the description when player is on the collectible
func show_description():
	if !btm_text_UI.in_use:
		if PlayerGlobal.player_HP_max < PlayerGlobal.player_HP_limit:
			btm_text_UI.bbcode_text = "[right]" + item_name + "[color=lime]" + " [Hearts: " + String(int(PlayerGlobal.player_HP_max/4)) + " > " + String(int(PlayerGlobal.player_HP_max/4 + 1)) + "]" + "[/color][/right]"
		else:
			btm_text_UI.bbcode_text = "[right]" + item_name + "[color=red]" + " [MAXED]" + "[/color][/right]"
		btm_text_UI.visible = true
		btm_text_UI.in_use = true
		using_text = true
