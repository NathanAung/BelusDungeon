extends Collectible


func _ready():
	item_name = "Strength+"
	price = 180
	auto_collect = false
	upgradable = true


# event inputs for picking up the power up
func _input(event):
	if Input.is_action_just_pressed("input_interact") and !auto_collect and player != null:
		if PlayerGlobal.player_bonus_dmg_current < PlayerGlobal.player_bonus_dmg_limit:
			Collect()
			player = null	# to avoid multiple collects
			queue_free()


func Collect():
	print("Collected Strength+!")
	AudioGlobal.play_SFX(0)
	if PlayerGlobal.player_bonus_dmg_current < 0.6:
		PlayerGlobal.player_bonus_dmg_current = min(PlayerGlobal.player_bonus_dmg_limit, PlayerGlobal.player_bonus_dmg_current + 0.6)
	else:
		PlayerGlobal.player_bonus_dmg_current = min(PlayerGlobal.player_bonus_dmg_limit, PlayerGlobal.player_bonus_dmg_current + 0.1)
	
	if !PlayerGlobal.collected_power_ups.has(PlayerGlobal.power_up_dict.banana):
		PlayerGlobal.collected_power_ups.append(PlayerGlobal.power_up_dict.banana)
	power_up_UI.update_display()


# Show the description when player is on the collectible
func show_description():
	if !btm_text_UI.in_use:
		if PlayerGlobal.player_bonus_dmg_current < PlayerGlobal.player_bonus_dmg_limit:
			if PlayerGlobal.player_bonus_dmg_current < 0.6:
				btm_text_UI.bbcode_text = "[right]" + item_name + "[color=lime]" + " [Bonus Damage: " + String(PlayerGlobal.player_bonus_dmg_current) + " > " + String(PlayerGlobal.player_bonus_dmg_current + 0.6) + "]" + "[/color][/right]"
			else:
				btm_text_UI.bbcode_text = "[right]" + item_name + "[color=lime]" + " [Bonus Damage: " + String(PlayerGlobal.player_bonus_dmg_current) + " > " + String(PlayerGlobal.player_bonus_dmg_current + 0.1) + "]" + "[/color][/right]"
		else:
			btm_text_UI.bbcode_text = "[right]" + item_name + "[color=red]" + " [MAXED]" + "[/color][/right]"
		btm_text_UI.visible = true
		btm_text_UI.in_use = true
		using_text = true
