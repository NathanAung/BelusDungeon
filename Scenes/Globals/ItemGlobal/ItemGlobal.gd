extends Node2D


# Items
export var extra_heart_scene = preload("res://Scenes/Collectibles/PowerUps/ExtraHeart/ExtraHeart.tscn")
export var food_scene = preload("res://Scenes/Collectibles/Food/Food.tscn")
export var bag_scene = preload("res://Scenes/Collectibles/PowerUps/Bag/Bag.tscn")
export var boot_scene = preload("res://Scenes/Collectibles/PowerUps/Boot/Boot.tscn")
export var dp_scene = preload("res://Scenes/Collectibles/PowerUps/DeathProtection/DeathProtection.tscn")
export var banana_scene = preload("res://Scenes/Collectibles/PowerUps/PowerBanana/PowerBanana.tscn")
export var weapon_pot_scene = preload("res://Scenes/Collectibles/PowerUps/WeaponPot/WeaponPotC.tscn")
export var armor_scene = preload("res://Scenes/Collectibles/PowerUps/Armor/ArmorC.tscn")
# Lv1 Weapons
export var knife = preload("res://Scenes/Weapons/Knife/Knife.tscn")
export var lv1_sword = preload("res://Scenes/Weapons/Sword/Sword.tscn")
export var lv1_spear = preload("res://Scenes/Weapons/Spear/Spear.tscn")
export var lv1_bow = preload("res://Scenes/Weapons/Bow/Bow.tscn")
export var lv1_shield = preload("res://Scenes/Weapons/Shield/Shield.tscn")
# Lv2 Weapons
export var lv2_sword = preload("res://Scenes/Weapons/Sword/Sword2.tscn")
export var lv2_spear = preload("res://Scenes/Weapons/Spear/Spear2.tscn")
export var lv2_bow = preload("res://Scenes/Weapons/Bow/Bow2.tscn")
export var lv2_shield = preload("res://Scenes/Weapons/Shield/Shield2.tscn")
# Lv3 Weapons
export var lv3_sword = preload("res://Scenes/Weapons/Sword/Sword3.tscn")
export var lv3_spear = preload("res://Scenes/Weapons/Spear/Spear3.tscn")
export var lv3_bow = preload("res://Scenes/Weapons/Bow/Bow3.tscn")
export var lv3_shield = preload("res://Scenes/Weapons/Shield/Shield3.tscn")

onready var lv1_weapons = [lv1_sword, lv1_spear, lv1_bow, lv1_shield, knife]
onready var lv2_weapons = [lv2_sword, lv2_spear, lv2_bow, lv2_shield]
onready var lv3_weapons = [lv3_sword, lv3_spear, lv3_bow, lv3_shield]
onready var weapon_arr = [lv1_weapons, lv2_weapons, lv3_weapons]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# save the holding weapons before going to the next floor
func save_weapons():
	var player_weapons = get_node("/root/Main/Dungeon/YSort/Player/Weapons")
	if player_weapons.get_child_count() > 0:
		for i in player_weapons.get_child_count():
			if i < 1:	# don't save knife
				continue
			var weapon = player_weapons.get_child(i)
			PlayerGlobal.current_weapons.append([weapon_arr[weapon.weapon_lvl - 1][weapon.weapon_type], weapon.durability])
		PlayerGlobal.last_weapon_index = get_node(MiscGlobal.player_node_path).current_weapon.get_index()
