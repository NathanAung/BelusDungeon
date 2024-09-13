extends Weapon

onready var animated_sprite:AnimatedSprite = get_node("Node2D/AnimatedSprite")
onready var gHurtbox:Area2D = get_node("Node2D/AnimatedSprite/GHurtbox")
onready var gHurtbox_col:CollisionShape2D = get_node("Node2D/AnimatedSprite/GHurtbox/CollisionShape2D")
onready var pHurtbox:Area2D = get_node("Node2D/AnimatedSprite/PHurtbox")
onready var pHurtbox_col:CollisionShape2D = get_node("Node2D/AnimatedSprite/PHurtbox/CollisionShape2D")
var defendSFX = preload("res://SFX/Character/defend.wav")
var owner_tank:bool = false


func _ready():
	if not on_floor:
		get_node("WeaponIcon").hide()
		get_node("Node2D/AnimatedSprite").show()
		player_detector.set_collision_mask_bit(0, false)
		player_detector.set_collision_mask_bit(1, false)
		player_detector.set_collision_mask_bit(2, false)
	else:
		gHurtbox.set_physics_process(false)


# move and flip the weapon according to the rotation direction
func move(rotate_dir: Vector2) -> void:
	if not animation_player.is_playing():
		rotation = rotate_dir.angle()
		hitbox.knockback_dir = rotate_dir
		gHurtbox.knockback_dir = rotate_dir
		pHurtbox.knockback_dir = rotate_dir
		#print(rotation)
		if rotation >= -2.5 and rotation <= -0.5:
			animated_sprite.position.x = 22
		else:
			animated_sprite.position.x = 12
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
	hitbox.set_collision_mask_bit(2, false)
	hitbox.set_collision_mask_bit(3, true)
	# guard hurtbox collisions
	gHurtbox.set_collision_layer_bit(2, true)
	gHurtbox.set_collision_layer_bit(3, false)
	gHurtbox.set_collision_mask_bit(2, false)
	gHurtbox.set_collision_mask_bit(3, true)
	# projectile hurtbox collisions
	pHurtbox.set_collision_layer_bit(2, true)
	pHurtbox.set_collision_layer_bit(3, false)
	pHurtbox.set_collision_mask_bit(2, false)
	pHurtbox.set_collision_mask_bit(3, true)
	on_floor = false
	collecting_body.pick_up_weapon(self)
	gHurtbox.set_physics_process(true)
	gHurtbox.shield_owner = collecting_body
	gHurtbox_col.disabled = false
	gHurtbox.owner_player = true
	pHurtbox.shield_owner = collecting_body
	pHurtbox_col.disabled = false
	pHurtbox.owner_player = true
	position = Vector2(5,-8)
	cd_timer.set_wait_time(original_cd)
	weapon_owner = collecting_body
	#print("Weapon owner is ", weapon_owner.name)
	owner_player = true
	colliding_body = null
	if weapon_lvl == 2:
		hitbox.damage = 1.5


func drop() -> void:
	pHurtbox.set_collision_layer_bit(2, false)
	pHurtbox.set_collision_layer_bit(3, false)
	print("dropped ", name)
	weapon_owner.attacking = false
	weapon_owner = null
	owner_player = false
	gHurtbox.set_physics_process(false)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Attack":
		if owner_player:
			weapon_owner.attacking = false
		elif owner_tank:
			weapon_owner.check_tired()
	elif anim_name == "Special":
		weapon_owner.can_attack = true
		weapon_owner.attacking = false
		weapon_owner.special_attacking = false
		print("special_attacking reset")
		weapon_owner.no_attack_cancel = false
		weapon_owner.call_deferred("enable_hurtbox")


func playSFX(sfx) -> void:
	if AudioGlobal.sfx_settings:
		match sfx:
			0:
				$AttackAudio.stream = atkSFX
				$AttackAudio.volume_db = -6
				$AttackAudio.play()
			1:
				$AttackAudio.stream = defendSFX
				$AttackAudio.play()
