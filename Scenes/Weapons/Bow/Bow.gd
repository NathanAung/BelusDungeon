extends Weapon

const ARROW:PackedScene = preload("res://Scenes/Weapons/Bow/Arrow.tscn")
export(NodePath) var dungeon_node_path = MiscGlobal.dungeon_node_path
onready var Dungeon = get_node(dungeon_node_path)
var enemy_bow:bool = true
export var arrow_speed:int = 500 #300
export var arrow_damage:float = 1
var arrow_dir:Vector2 = Vector2.ZERO

# played in Attack animation
func shoot():
	if durability > 0:
		var arrow:Area2D = ARROW.instance()
		Dungeon.current_room.add_child(arrow)
		arrow.damage = arrow_damage
		if weapon_lvl == 5:
			arrow.launch($Node2D/AnimatedSprite/LaunchPoint.global_position, arrow_dir, arrow_speed, enemy_bow)
		else:
			arrow.launch(global_position, arrow_dir, arrow_speed, enemy_bow)
		if not enemy_bow:
			durability -= 1
			weapon_slots.call_deferred("update_single", get_index())


# move and flip the weapon according to the rotation direction
func move(rotate_dir: Vector2) -> void:
	if not animation_player.is_playing() or animation_player.current_animation == "Special":
		arrow_dir = rotate_dir
		rotation = rotate_dir.angle()
		hitbox.knockback_dir = rotate_dir
		if scale.y == 1 and rotate_dir.x < 0:
			scale.y = -1
			position.x = -5
		if scale.y == -1 and rotate_dir.x > 0:
			scale.y = 1
			position.x = 5


func pick_up(collecting_body) -> void:
	player_detector.set_collision_mask_bit(0, false)
	player_detector.set_collision_mask_bit(1, false)
	player_detector.set_collision_mask_bit(2, false)
	enemy_bow = false
	on_floor = false
	collecting_body.pick_up_weapon(self)
	position = Vector2(5,-8)
	cd_timer.set_wait_time(original_cd)
	weapon_owner = collecting_body
	#print("Weapon owner is ", weapon_owner.name)
	owner_player = true
	colliding_body = null
	if weapon_lvl == 2:
		arrow_damage = 1.5
