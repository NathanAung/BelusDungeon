extends Hitbox

onready var shield:Node2D = get_owner()
onready var animation_player:AnimationPlayer = get_owner().get_node("AnimationPlayer")
var shield_owner:KinematicBody2D
var owner_player:bool = false


func _physics_process(delta):
	var bodies:Array = get_overlapping_bodies()
	for i in bodies.size():
		if bodies[i].is_in_group("Enemy") and owner_player:
#			if owner_player and bodies[i].is_in_group("Enemy"):
#				print("enemy overlapping")
			if bodies[i].attacking:
				#print(bodies[i].name)
				bodies[i].velocity = knockback_dir * knockback_force
				shield_owner.blocked_attack = true
				animation_player.play("Deflect")
				shield.playSFX(1)
				weapon.durability -= 1
				weapon.weapon_slots.call_deferred("update_single", weapon.get_index())
				bodies[i].attacking = false
		elif  bodies[i].name == "Player" and !owner_player:
			if bodies[i].attacking:
				if animation_player.current_animation != "Special":
					#print(bodies[i].name)
					bodies[i].velocity = knockback_dir * (knockback_force * 4)
					shield_owner.blocked_attack = true
					animation_player.play("Deflect")
					shield.playSFX(1)
					bodies[i].attacking = false


func _on_area_entered(area: Area2D) -> void:
	pass


func _on_Shield_draw():
	#$CollisionShape2D.disabled = false
	$CollisionShape2D.set_deferred("disabled", false)

func _on_Shield_hide():
	#$CollisionShape2D.disabled = true
	$CollisionShape2D.set_deferred("disabled", true)
	
