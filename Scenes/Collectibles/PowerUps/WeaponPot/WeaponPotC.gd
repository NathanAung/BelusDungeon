extends Collectible


func _ready():
	item_name = "Weapon Pot"
	price = 150
	auto_collect = false
	upgradable = true


# event inputs for picking up the power up
func _input(event):
	if Input.is_action_just_pressed("input_interact") and !auto_collect and player != null:
		if PlayerGlobal.player_weapon_pot_current < PlayerGlobal.player_weapon_pot_limit:
			Collect()
			player = null	# to avoid multiple collects
			queue_free()


func Collect():
	print("Collected Weapon Pot!")
	AudioGlobal.play_SFX(0)
	PlayerGlobal.player_weapon_pot_current = min(PlayerGlobal.player_weapon_pot_limit, PlayerGlobal.player_weapon_pot_current + 1)
	
	if !PlayerGlobal.collected_power_ups.has(PlayerGlobal.power_up_dict.weapon_pot):
		PlayerGlobal.collected_power_ups.append(PlayerGlobal.power_up_dict.weapon_pot)
	power_up_UI.update_display()


# Show the description when player is on the collectible
func show_description():
	if !btm_text_UI.in_use:
		if PlayerGlobal.player_weapon_pot_current < PlayerGlobal.player_weapon_pot_limit:
			if PlayerGlobal.player_weapon_pot_current == 0:
				btm_text_UI.bbcode_text = "[right]" + item_name + "[color=lime]" + " [Spawns a Lv.1 weapon when unarmed.]" + "[/color][/right]"
			else:
				btm_text_UI.bbcode_text = "[right]" + item_name + "[color=lime]" + " [Spawns a Lv." + String(PlayerGlobal.player_weapon_pot_current + 1) + " weapon when unarmed.]" + "[/color][/right]"
		else:
			btm_text_UI.bbcode_text = "[right]" + item_name + "[color=red]" + " [MAXED]" + "[/color][/right]"
		btm_text_UI.visible = true
		btm_text_UI.in_use = true
		using_text = true
