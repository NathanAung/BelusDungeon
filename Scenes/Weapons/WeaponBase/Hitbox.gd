extends Area2D
class_name Hitbox

export(float) var damage: float = 1
var knockback_dir: Vector2 = Vector2.ZERO
export(int) var knockback_force: int = 300
export var weapon_hitbox:bool = true
onready var weapon: Node2D = get_node("../../..")
onready var collision_shape: CollisionShape2D = get_node("CollisionShape2D")


func _init():
	# connect body entered signal to self
	#connect("body_entered", self, "_on_body_entered")
	connect("area_entered", self, "_on_area_entered")


func _ready():
	# make sure there is a collision shape
	assert(collision_shape != null)


#func _on_body_entered(body: PhysicsBody2D) -> void:
#	# make the colliding body take damage
#	body.take_damage(damage, knockback_dir, knockback_force)
#	pass

func _on_area_entered(area: Area2D) -> void:
	if area.name == "Hurtbox":
		collision_shape.set_deferred("disabled", true)
		# player attack
		if area.get_owner().is_in_group("Enemy"):
			# make the colliding body take damage
			area.get_owner().take_damage(damage + PlayerGlobal.player_bonus_dmg_current, knockback_dir, knockback_force)
			# reduce weapon durability
			if !weapon.permanent:
				weapon.durability -= 1
				weapon.weapon_slots.call_deferred("update_single", weapon.get_index())
		else:
			area.get_owner().take_damage(damage, knockback_dir, knockback_force)
	# hitting shield
	elif area.name == "GHurtbox":
		collision_shape.set_deferred("disabled", true)
		if weapon_hitbox:
			if weapon.owner_player and !weapon.permanent:
				weapon.durability -= 1
				weapon.weapon_slots.call_deferred("update_single", weapon.get_index())
