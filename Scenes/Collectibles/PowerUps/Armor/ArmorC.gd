extends Collectible

export(NodePath) var armor_ui_node_path = "/root/Main/PlayerUI/CanvasLayer/ArmorU"
onready var Armor_UI = get_node(armor_ui_node_path)
var armor_level:int = 1 setget set_armor
var armor_points:int = 2
var armor_name:String = "Bronze"

func _ready():
	auto_collect = false
	upgradable = true


func Collect():
	print("Collected ", item_name,"!")
	AudioGlobal.play_SFX(0)
	PlayerGlobal.player_armor_level = armor_level
	PlayerGlobal.player_armor_current = armor_points
	PlayerGlobal.player_armor_max = armor_points
	player.armor.animation = armor_name
	player.armor.visible = true
	Armor_UI.visible = true
	Armor_UI.generate_armor_ui()
	Armor_UI.update_armor_ui()


# event inputs for picking up the power up
func _input(event):
	if Input.is_action_just_pressed("input_interact") and !auto_collect and player != null:
		#if PlayerGlobal.player_armor_current <= armor_points:
		Collect()
		player = null	# to avoid multiple collects
		queue_free()


# Show the description when player is on the collectible
func show_description():
	if !btm_text_UI.in_use:
		if PlayerGlobal.player_armor_current <= armor_points:
			btm_text_UI.bbcode_text = "[right]" + item_name + "[color=lime]" + " [Armor: " + String(PlayerGlobal.player_armor_current) + " > " + String(armor_points) + "]" + "[/color][/right]"
		else:
			btm_text_UI.bbcode_text = "[right]" + item_name + "[color=red]" + " [Armor: " + String(PlayerGlobal.player_armor_current) + " > " + String(armor_points) + "]" + "[/color][/right]"
		btm_text_UI.visible = true
		btm_text_UI.in_use = true
		using_text = true


func set_armor(lvl):
	armor_level = lvl
	match lvl:
		1:
			item_name = "Bronze Armor"
			price = 60
			armor_points = 2
			armor_name = "Bronze"
			$Sprite.frame = 0
		2:
			item_name = "Silver Armor"
			price = 120
			armor_points = 4
			armor_name = "Silver"
			$Sprite.frame = 1
		3:
			item_name = "Gold Armor"
			price = 180
			armor_points = 6
			armor_name = "Gold"
			$Sprite.frame = 2
