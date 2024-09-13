extends Hitbox

onready var shield:Node2D = get_owner()
onready var animation_player:AnimationPlayer = get_owner().get_node("AnimationPlayer")
var shield_owner:KinematicBody2D
var owner_player:bool = false


func _on_area_entered(area: Area2D) -> void:
	if not weapon.on_floor:
		if area.is_in_group("Projectile"):
			if animation_player.current_animation != "Special":
				#print("projectile hit")
				shield_owner.blocked_attack = true
				animation_player.play("Deflect")
				shield.playSFX(1)
				# reduce durability if owner
				if owner_player:
					weapon.durability -= 1
					weapon.weapon_slots.call_deferred("update_single", weapon.get_index())


func _on_Shield_draw():
	#$CollisionShape2D.disabled = false
	$CollisionShape2D.set_deferred("disabled", false)

func _on_Shield_hide():
	#$CollisionShape2D.disabled = true
	$CollisionShape2D.set_deferred("disabled", true)
