extends Hitbox

var body_exited: bool = false
var direction: Vector2 = Vector2.ZERO
var arrow_speed: int = 0
var enemy_arrow:bool = true
var hit = false


func launch(initial_position: Vector2, dir: Vector2, speed: int, enemy_a: bool) -> void:
	global_position = initial_position
	direction = dir
	knockback_dir = dir
	arrow_speed = speed
	enemy_arrow = enemy_a
	rotation += dir.angle()

func playSFX():
	if AudioGlobal.sfx_settings:
		$ExplodeAudio.volume_db = -6
		$ExplodeAudio.play()

func _physics_process(delta: float) -> void:
	if not hit:
		global_position += direction * arrow_speed * delta
		
		#body exit error handling for shooting up
		#if body_exited == false and enemy_arrow == false:
		if body_exited == false:
			body_exited = true
			set_collision_mask_bit(0, true)
			if enemy_arrow:
				set_collision_mask_bit(2, true)
				set_collision_mask_bit(3, false)
			else:
				set_collision_mask_bit(2, false)
				set_collision_mask_bit(3, true)


func _on_Arrow_body_exited(body):
	if not body_exited:
		body_exited = true
		set_collision_mask_bit(0, true)
		# set collision mask depending on who shot it
		if enemy_arrow:
			set_collision_mask_bit(2, true)
			set_collision_mask_bit(3, false)
		else:
			set_collision_mask_bit(3, true)
			set_collision_mask_bit(2, false)


func _on_area_entered(area: Area2D) -> void:
	if body_exited and area.name == "Hurtbox" and not hit:
		if !enemy_arrow:
			area.get_owner().take_damage(damage + PlayerGlobal.player_bonus_dmg_current, knockback_dir, knockback_force)
		else:
			area.get_owner().take_damage(damage, knockback_dir, knockback_force)
		$AnimatedSprite.play("hit")
		playSFX()
		hit = true


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.get_animation() == "hit":
		queue_free()


func _on_Arrow_body_entered(body):
	if body.is_in_group("Walls"):
		$AnimatedSprite.play("hit")
		playSFX()
		hit = true
