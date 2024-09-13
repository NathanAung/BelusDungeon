extends Control

export var powerup_u:PackedScene


# Called when the node enters the scene tree for the first time.
func _ready():
	update_display()


# update the power ups display in the pause menu
func update_display():
	#print(PlayerGlobal.collected_power_ups)
	var slots = $GridContainer.get_children()
	
	if PlayerGlobal.collected_power_ups.size() <= 0:
		visible = false
	else:
		visible = true
		for i in slots.size():
			slots[i].visible = false
		
		for i in PlayerGlobal.collected_power_ups.size():
			slots[i].visible = true
			if PlayerGlobal.collected_power_ups[i] == PlayerGlobal.power_up_dict.extra_heart:
				slots[i].get_node("CenterContainer/Sprite").frame = 0
				slots[i].get_node("Label").text = String(PlayerGlobal.player_HP_max/4) + "/" + String(PlayerGlobal.player_HP_limit/4)
			elif PlayerGlobal.collected_power_ups[i] == PlayerGlobal.power_up_dict.weapon_slot:
				slots[i].get_node("CenterContainer/Sprite").frame = 1
				slots[i].get_node("Label").text = String(PlayerGlobal.player_WS_current) + "/" + String(PlayerGlobal.player_WS_limit)
			elif PlayerGlobal.collected_power_ups[i] == PlayerGlobal.power_up_dict.boot:
				slots[i].get_node("CenterContainer/Sprite").frame = 2
				slots[i].get_node("Label").text = String(PlayerGlobal.player_DC_current) + "/" + String(PlayerGlobal.player_DC_limit)
			elif PlayerGlobal.collected_power_ups[i] == PlayerGlobal.power_up_dict.revive:
				slots[i].get_node("CenterContainer/Sprite").frame = 3
				slots[i].get_node("Label").text = "1/1"
			elif PlayerGlobal.collected_power_ups[i] == PlayerGlobal.power_up_dict.banana:
				slots[i].get_node("CenterContainer/Sprite").frame = 4
				slots[i].get_node("Label").text = String(PlayerGlobal.player_bonus_dmg_current) + "/" + String(PlayerGlobal.player_bonus_dmg_limit)
			elif PlayerGlobal.collected_power_ups[i] == PlayerGlobal.power_up_dict.weapon_pot:
				slots[i].get_node("CenterContainer/Sprite").frame = 5
				slots[i].get_node("Label").text = String(PlayerGlobal.player_weapon_pot_current) + "/" + String(PlayerGlobal.player_weapon_pot_limit)
