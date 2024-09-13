extends Node2D

export(NodePath) var dungeon_node_path = MiscGlobal.dungeon_node_path
onready var Dungeon = get_node(dungeon_node_path)
var rng = RandomNumberGenerator.new()
var weap_no:int = 0
var room_pos:Vector2


# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	weap_no = rng.randi_range(0, 3)
	$AnimationPlayer.play("Shine")


# instantiate a weapon
func drop_item():
	var weapon
	if PlayerGlobal.player_weapon_pot_current >= 3:
		weapon = ItemGlobal.lv3_weapons[weap_no].instance()
	elif PlayerGlobal.player_weapon_pot_current >= 2:
		weapon = ItemGlobal.lv2_weapons[weap_no].instance()
	else:
		weapon = ItemGlobal.lv1_weapons[weap_no].instance()
	weapon.on_floor = true
	weapon.position = position
	get_parent().add_child(weapon)


# called when the pot takes damage
func take_damage(dmg: float, dir: Vector2, force: int) -> void:
	$AnimationPlayer.play("Break")
	if AudioGlobal.sfx_settings:
		$AudioStreamPlayer.play()
	Dungeon.current_room.taken_positions_floor.erase(room_pos)
