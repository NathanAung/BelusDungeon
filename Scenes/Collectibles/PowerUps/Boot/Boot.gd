extends Collectible


func _ready():
	item_name = "Dash+"
	price = 120
	auto_collect = false
	upgradable = true


# event inputs for picking up the power up
func _input(event):
	if Input.is_action_just_pressed("input_interact") and !auto_collect and player != null:
		if PlayerGlobal.player_DC_current < PlayerGlobal.player_DC_limit:
			Collect()
			player = null	# to avoid multiple collects
			queue_free()


func Collect():
	print("Collected Boot!")
	AudioGlobal.play_SFX(0)
	PlayerGlobal.player_DC_current = int(min(PlayerGlobal.player_DC_current + 1, PlayerGlobal.player_DC_limit))
	if !PlayerGlobal.collected_power_ups.has(PlayerGlobal.power_up_dict.boot):
		PlayerGlobal.collected_power_ups.append(PlayerGlobal.power_up_dict.boot)
	power_up_UI.update_display()

# Show the description when player is on the collectible
func show_description():
	if !btm_text_UI.in_use:
		if PlayerGlobal.player_DC_current < PlayerGlobal.player_DC_limit:
			btm_text_UI.bbcode_text = "[right]" + item_name + "[color=lime]" + " [Consecutive Dashes: " + String(PlayerGlobal.player_DC_current) + " > " + String(PlayerGlobal.player_DC_current + 1) + "]" + "[/color][/right]"
		else:
			btm_text_UI.bbcode_text = "[right]" + item_name + "[color=red]" + " [MAXED]" + "[/color][/right]"
		btm_text_UI.visible = true
		btm_text_UI.in_use = true
		using_text = true
