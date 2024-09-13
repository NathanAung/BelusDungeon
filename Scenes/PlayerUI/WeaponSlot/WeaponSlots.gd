extends HBoxContainer


export var slot_scene:PackedScene
export(NodePath) var player_weapons_node_path = "/root/Main/Dungeon/YSort/Player/Weapons"
onready var weapons:Node2D = get_node(player_weapons_node_path)
var last_weapon_no = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_slots()


# generate the slots according to player's max weapons
func generate_slots():
	for n in get_children():
		remove_child(n)
		n.queue_free()
	for i in PlayerGlobal.player_WS_current:
		var slot = slot_scene.instance()
		slot.get_node("Node2D/SlotNo").text = String(i + 1)
		add_child(slot)


# update all of the slots
func update_all():
	for i in PlayerGlobal.player_WS_current:
		if i < weapons.get_child_count():
			get_child(i).get_node("WeaponIcon").texture = weapons.get_child(i).weapon_icon
			if weapons.get_child(i).permanent:
				get_child(i).get_node("Node2D/Durability").text = " "
			else:
				get_child(i).get_node("Node2D/Durability").text = String(weapons.get_child(i).durability)
		else:
			get_child(i).get_node("WeaponIcon").texture = null
			get_child(i).get_node("Node2D/Durability").text = " "


# update the durability of a single slot
func update_single(weapon_no:int):
	for i in PlayerGlobal.player_WS_current:
		# null is check here for error handling
		if i == weapon_no and weapons.get_child(i) != null:
			get_child(i).get_node("Node2D/Durability").text = String(weapons.get_child(i).durability)


# switch the background of the player's selected weapon
func switch_weapon(weapon_no:int):
	last_weapon_no = weapon_no
	for i in PlayerGlobal.player_WS_current:
		if i == weapon_no:
			get_child(i).get_node("Background").frame = 1
		else:
			get_child(i).get_node("Background").frame = 0
