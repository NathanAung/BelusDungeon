extends Enemy
class_name Melee1

# weapon node
onready var weapons:Node2D = get_node("Weapons")
var current_weapon:Node2D
# dust scene to spawn while running
export var dust_scene:PackedScene
var rng = RandomNumberGenerator.new()
onready var eyes_anim:AnimationPlayer = get_node("Eyes/AnimationPlayer")
# for the enemy's aim to move within a range
export var aim_variation:float = 30
var xy:float = 0
var dir_positive:bool = true

func _ready():
	rng.randomize()
	# set current weapon and cd time
	if not current_weapon:
		# spear
		if rng.randi_range(0, 3) == 0:
			current_weapon = weapons.get_child(1)
			attack_distance = 60
		# sword
		else:
			current_weapon = weapons.get_child(0)
		current_weapon.get_node("Cooldown").set_wait_time(attack_cd)


func _physics_process(delta):
	# get the direction to player
	if aim_variation > 0:
		if dir_positive:
			xy += 0.5
			if xy == aim_variation:
				dir_positive = false
		else:
			xy -= 0.5
			if xy == -aim_variation:
				dir_positive = true
			
	var player_dir: Vector2 = (Player.global_position - global_position + Vector2(xy, xy)).normalized()
	if current_weapon:
		current_weapon.move(player_dir)
	
	# attack player
	if can_attack and state_machine.state in [state_machine.states.idle, state_machine.states.chase] and global_position.distance_to(Player.global_position) < attack_distance:
		if current_weapon.cd_timer.time_left == 0 and !current_weapon.animation_player.is_playing() and !PlayerGlobal.player_dead:
			eyes_anim.play("Flash")
		else:
			attacking = false
	else:
		attacking = false
			


func drop_weapon() -> void:
	var weapon_to_drop:Node2D = current_weapon
	current_weapon = null
	weapons.call_deferred("remove_child", weapon_to_drop)
	# switch sprites
	weapon_to_drop.get_node("Node2D/AnimatedSprite").hide()
	weapon_to_drop.get_node("WeaponIcon").show()
	Dungeon.current_room.call_deferred("add_child", weapon_to_drop)
	weapon_to_drop.call_deferred("set_owner", Dungeon.current_room)
	yield(weapon_to_drop.tween, "tree_entered")
	weapon_to_drop.show()
	weapon_to_drop.interpolate_pos(global_position, global_position)


func spawn_dust() -> void:
	var dust = dust_scene.instance()
	dust.position = global_position
	get_parent().add_child(dust)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Flash":
		current_weapon.enemy_attack()
		attacking = true


# timer set to not attack immediately after spawning
func _on_SpawnTimer_timeout():
	can_attack = true
	current_weapon.show()
