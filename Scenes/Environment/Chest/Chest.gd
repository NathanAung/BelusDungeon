extends Area2D


var Player
export(NodePath) var dungeon_node_path = MiscGlobal.dungeon_node_path
onready var Dungeon = get_node(dungeon_node_path)
export(NodePath) var gold_UI_node_path = "/root/Main/PlayerUI/CanvasLayer/Gold"
onready var Gold_UI = get_node(gold_UI_node_path)
export var explosion_scene = preload("res://Scenes/Effects/Explosion/Explosion.tscn")
export var gold_scene = preload("res://Scenes/Collectibles/Gold/Gold.tscn")
export var key_scene = preload("res://Scenes/Collectibles/Key/Key.tscn")

var activated:bool = false
var rng = RandomNumberGenerator.new()

var chest_types:Dictionary = {"treasure" : 0, "key" : 1, "power_up" : 2}
var tier_1_items:Dictionary = {"food" : 0, "boot" : 1, "banana" : 2, "armor" : 3}
var tier_2_items:Dictionary = {"extra_heart" : 0, "weapon_slot" : 1, "armor" : 2}
var tier_3_items:Dictionary = {"revive" : 0, "weapon_pot" : 1, "armor" : 2}

var chest_type:int = chest_types.treasure
var parent_room:Object

var items = []
var itemNo:int = 0

func _ready():
	rng.randomize()


func _physics_process(delta):
	if Input.is_action_just_pressed("input_interact") and !activated and Player != null:
		if overlaps_body(Player):
			if AudioGlobal.sfx_settings:
				$AudioStreamPlayer.play()
			activated = true
			get_node("AnimationPlayer").play("activate")


func set_chest(type:int, room:Object):
	parent_room = room
	chest_type = type
	itemNo = rng.randi_range(3, 6)
	#itemNo = 1
	for i in itemNo:
		var item
		# insert key
		if i == 0 and chest_type == chest_types.key:
			#print("key in chest")
			item = key_scene.instance()
		# insert random power ups
		elif i == 0 and chest_type == chest_types.power_up:
			if rng.randi_range(0, 9) == 0:
				print("tier 3 item")
				var item_no = rng.randi_range(0, tier_3_items.size() - 1)
				match item_no:
					tier_3_items.revive:
						item = ItemGlobal.dp_scene.instance()
					tier_3_items.weapon_pot:
						item = ItemGlobal.weapon_pot_scene.instance()
					tier_3_items.armor:
						item = ItemGlobal.armor_scene.instance()
						item.set_armor(3)
			elif rng.randi_range(0, 3) == 0:
				print("tier 2 item")
				var item_no = rng.randi_range(0, tier_2_items.size() - 1)
				match item_no:
					tier_2_items.extra_heart:
						item = ItemGlobal.extra_heart_scene.instance()
					tier_2_items.weapon_slot:
						item = ItemGlobal.bag_scene.instance()
					tier_2_items.armor:
						item = ItemGlobal.armor_scene.instance()
						item.set_armor(2)
			else:
				print("tier 1 item")
				var item_no = rng.randi_range(0, tier_1_items.size() - 1)
				match item_no:
					tier_1_items.food:
						item = ItemGlobal.food_scene.instance()
						item.set_collectible(4)
					tier_1_items.boot:
						item = ItemGlobal.boot_scene.instance()
					tier_1_items.banana:
						item = ItemGlobal.banana_scene.instance()
					tier_1_items.armor:
						item = ItemGlobal.armor_scene.instance()
						item.set_armor(1)
			#item = ItemGlobal.bag_scene.instance() #debug
		# insert a weapon if not key or power up
		elif i == 0 and chest_type == chest_types.treasure:
			print("weapon in chest")
			var weap_no = rng.randi_range(0, ItemGlobal.lv1_weapons.size() - 2) #-2 for knife
			if DungeonGlobal.floor_level >= 3:
				if rng.randi_range(0,3) == 0:
					item = ItemGlobal.lv3_weapons[weap_no].instance()
				else:
					item = ItemGlobal.lv2_weapons[weap_no].instance()
			elif DungeonGlobal.floor_level == 2:
				if rng.randi_range(0,2) == 0:
					item = ItemGlobal.lv2_weapons[weap_no].instance()
				else:
					item = ItemGlobal.lv1_weapons[weap_no].instance()
			else:
				if rng.randi_range(0,3) == 0:
					item = ItemGlobal.lv2_weapons[weap_no].instance()
				else:
					item = ItemGlobal.lv1_weapons[weap_no].instance()
			item.on_floor = true
		else:
			#print("gold in chest")
			item = gold_scene.instance()
			if rng.randi_range(0, 1) == 0:
				item.set_collectible(10)
		parent_room.call_deferred("add_child", item)
		item.call_deferred("set_owner", parent_room)
		items.append(item)
		item.hide()


func activate():
	for i in items.size():
		items[i].global_position = global_position
		var rand_dir:Vector2 = Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized()
		items[i].interpolate_pos(items[i].global_position, items[i].global_position + rand_dir * 50)
		items[i].show()
		Player.interact_indi.playing = false
		Player.interact_indi.hide()


func _on_Chest_body_entered(body):
	if body.name == "Player":
		if Player == null:
			Player = body
		
		if !activated:
			Player.interact_indi.playing = true
			Player.interact_indi.show()


func _on_Chest_body_exited(body):
	if body.name == "Player" and !activated:
		Player.interact_indi.playing = false
		Player.interact_indi.hide()


func spawn_explosion() -> void:
	var explosion = explosion_scene.instance()
	parent_room.add_child(explosion)
	explosion.global_position = global_position + Vector2(0,20)
