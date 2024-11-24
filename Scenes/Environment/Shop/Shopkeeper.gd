extends StaticBody2D

export var pedestal_scene = preload("res://Scenes/Environment/Shop/Pedestal.tscn")
var rng = RandomNumberGenerator.new()
# parent room
onready var room = get_parent()
# three pedestal positions
var three_pos = [Vector2(DungeonGlobal.room_width/2 - 60, DungeonGlobal.room_height/2 + 40),
	Vector2(DungeonGlobal.room_width/2, DungeonGlobal.room_height/2 + 40),
	Vector2(DungeonGlobal.room_width/2 + 60, DungeonGlobal.room_height/2 + 40)]

var item_dict = {"extra_heart":0, "health":1, "weapon_slot":2, "weapon":3, "boot":4, "revive":5, "banana":6, "weapon_pot":7, "armor":8}
# despawn when sold maximum number of items
var items_sold:int = 0
var despawned:bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	$AnimatedSprite.play("Idle")
	_set_up_shop()


func _set_up_shop():
	var placed_items = []
	for i in 3:
		var pedestal = pedestal_scene.instance()
		
		var item_no = rng.randi_range(0, item_dict.size() - 1)
		
		#item_no = 7		#debug
		
		while placed_items.has(item_no):
			item_no = rng.randi_range(0, item_dict.size() - 1)
		#item_no = 7		#debug
		placed_items.append(item_no)
		match item_no:
			item_dict.extra_heart:
				pedestal.shop_item = ItemGlobal.extra_heart_scene.instance()
			item_dict.health:
				pedestal.shop_item = ItemGlobal.food_scene.instance()
				pedestal.shop_item.set_collectible(4)
			item_dict.weapon_slot:
				pedestal.shop_item = ItemGlobal.bag_scene.instance()
			item_dict.boot:
				pedestal.shop_item = ItemGlobal.boot_scene.instance()
			item_dict.revive:
				pedestal.shop_item = ItemGlobal.dp_scene.instance()
			item_dict.banana:
				pedestal.shop_item = ItemGlobal.banana_scene.instance()
			item_dict.weapon_pot:
				pedestal.shop_item = ItemGlobal.weapon_pot_scene.instance()
			item_dict.weapon:
				var weap_no = rng.randi_range(0, 3)
#				if DungeonGlobal.current_floor >= 3:
#					if rng.randi_range(0,1) == 0:
#						pedestal.shop_item = ItemGlobal.lv3_weapons[weap_no].instance()
#					else:
#						pedestal.shop_item = ItemGlobal.lv2_weapons[weap_no].instance()
#				elif DungeonGlobal.current_floor == 2:
#					if rng.randi_range(0,1) == 0:
#						pedestal.shop_item = ItemGlobal.lv2_weapons[weap_no].instance()
#					else:
#						pedestal.shop_item = ItemGlobal.lv1_weapons[weap_no].instance()
#				else:
#					if rng.randi_range(0,3) == 0:
#						pedestal.shop_item = ItemGlobal.lv2_weapons[weap_no].instance()
#					else:
#						pedestal.shop_item = ItemGlobal.lv1_weapons[weap_no].instance()
				if rng.randi_range(0,2) == 0:
					pedestal.shop_item = ItemGlobal.lv3_weapons[weap_no].instance()
				else:
					pedestal.shop_item = ItemGlobal.lv2_weapons[weap_no].instance()
					
				pedestal.shop_item.on_floor = true
			item_dict.armor:
				var armor_lvl = 1
				if rng.randi_range(0, 5) == 0:
					armor_lvl = 3
				elif rng.randi_range(0, 2) == 0:
					armor_lvl = 2
				#armor_lvl = 1		#debug
				pedestal.shop_item = ItemGlobal.armor_scene.instance()
				pedestal.shop_item.set_armor(armor_lvl)
		
		pedestal.shop_item.position = three_pos[i]
		pedestal.shop_item.in_shop = true
		pedestal.position = three_pos[i]
		pedestal.shopkeeper = self
		room.add_child(pedestal)
		room.add_child(pedestal.shop_item)


func sell_item():
	items_sold += 1
	if items_sold >= 3 and !despawned:
		if AudioGlobal.sfx_settings:
			$AudioStreamPlayer2D.play()
		$AnimatedSprite.play("Despawn")
		$CollisionShape2D.disabled = true
		despawned = true
