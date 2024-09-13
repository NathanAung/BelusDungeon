extends Collectible


func _ready():
	item_name = "Revive"
	price = 220
	auto_collect = false


# event inputs for picking up the power up
func _input(event):
	if Input.is_action_just_pressed("input_interact") and !auto_collect and player != null:
		if !PlayerGlobal.player_death_protection:
			Collect()
			player = null	# to avoid multiple collects
			queue_free()


func Collect():
	print("Collected Revive!")
	AudioGlobal.play_SFX(0)
	PlayerGlobal.player_death_protection = true
	if !PlayerGlobal.collected_power_ups.has(PlayerGlobal.power_up_dict.revive):
		PlayerGlobal.collected_power_ups.append(PlayerGlobal.power_up_dict.revive)
	power_up_UI.update_display()


# Show the description when player is on the collectible
func show_description():
	if !btm_text_UI.in_use:
		if !PlayerGlobal.player_death_protection:
			btm_text_UI.bbcode_text = "[right]" + item_name + "[color=lime]" + " [Revives once. Disappears after using.]" + "[/color][/right]"
		else:
			btm_text_UI.bbcode_text = "[right]" + item_name + "[color=red]" + " [MAXED]" + "[/color][/right]"
		btm_text_UI.visible = true
		btm_text_UI.in_use = true
		using_text = true
