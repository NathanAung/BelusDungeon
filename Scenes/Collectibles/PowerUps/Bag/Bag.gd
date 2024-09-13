extends Collectible

export(NodePath) var weapon_slots_node_path = "/root/Main/PlayerUI/CanvasLayer/WeaponSlots"
onready var weapon_slots = get_node(weapon_slots_node_path)


func _ready():
	item_name = "Weapon Slot"
	price = 150
	auto_collect = false
	upgradable = true


# event inputs for picking up the power up
func _input(event):
	if Input.is_action_just_pressed("input_interact") and !auto_collect and player != null:
		if PlayerGlobal.player_WS_current < PlayerGlobal.player_WS_limit:
			Collect()
			player = null	# to avoid multiple collects
			queue_free()


func Collect():
	print("Collected weapon slot!")
	AudioGlobal.play_SFX(0)
	PlayerGlobal.player_WS_current = int(min(PlayerGlobal.player_WS_current + 1, PlayerGlobal.player_WS_limit))
	weapon_slots.generate_slots()
	weapon_slots.update_all()
	weapon_slots.switch_weapon(weapon_slots.last_weapon_no)
	if !PlayerGlobal.collected_power_ups.has(PlayerGlobal.power_up_dict.weapon_slot):
		PlayerGlobal.collected_power_ups.append(PlayerGlobal.power_up_dict.weapon_slot)
	power_up_UI.update_display()


# Show the description when player is on the collectible
func show_description():
	if !btm_text_UI.in_use:
		if PlayerGlobal.player_WS_current < PlayerGlobal.player_WS_limit:
			btm_text_UI.bbcode_text = "[right]" + item_name + "[color=lime]" + " [Weapon Slots: " + String(PlayerGlobal.player_WS_current) + " > " + String(PlayerGlobal.player_WS_current + 1) + "]" + "[/color][/right]"
		else:
			btm_text_UI.bbcode_text = "[right]" + item_name + "[color=red]" + " [MAXED]" + "[/color][/right]"
		btm_text_UI.visible = true
		btm_text_UI.in_use = true
		using_text = true
