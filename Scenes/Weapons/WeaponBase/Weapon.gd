extends Node2D

class_name Weapon

export(int) var weapon_type:int = 0
export(int) var weapon_lvl:int = 1
export(int) var durability:int = 5
export(bool) var permanent:bool = false
export(float) var original_cd:float = 1
export(bool) var on_floor:bool = false
var colliding_body:KinematicBody2D
var weapon_owner:KinematicBody2D
export(bool) var owner_player:bool = false
onready var animation_player:AnimationPlayer = get_node("AnimationPlayer")
onready var hitbox:Area2D = get_node("Node2D/AnimatedSprite/Hitbox")
onready var cd_timer:Timer = get_node("Cooldown")
onready var player_detector:Area2D = get_node("PlayerDetector")
onready var tween:Tween = get_node("Tween")
export var weapon_icon:Texture
# weapon slots node in the UI
export(NodePath) var weapon_slots_node_path = "/root/Main/PlayerUI/CanvasLayer/WeaponSlots"
onready var weapon_slots = get_node(weapon_slots_node_path)
# bottom text node from UI
export(NodePath) var btm_text_node_path = "/root/Main/PlayerUI/CanvasLayer/BottomText"
onready var btm_text_UI = get_node(btm_text_node_path)
var using_text:bool = false
# sfx
var atkSFX = preload("res://SFX/Character/attack.wav")
# for sale
var in_shop:bool = false
export var item_name:String = "Weapon"
export var price:int = 30

func _ready():
	if not on_floor:
		get_node("WeaponIcon").hide()
		get_node("Node2D/AnimatedSprite").show()
		player_detector.set_collision_mask_bit(0, false)
		player_detector.set_collision_mask_bit(1, false)
		player_detector.set_collision_mask_bit(2, false)
		$AttackAudio.stream = atkSFX


# attack inputs when player is holding the weapon
func get_input() -> void:
	if Input.is_action_just_pressed("input_attack") and not animation_player.is_playing() and cd_timer.time_left == 0:
		animation_player.play("Attack")
#		if AudioGlobal.sfx_settings:
#			playSFX(0)
		weapon_owner.attacking = true
		cd_timer.start()


# event inputs for picking up the weapon
func _input(event):
	if Input.is_action_just_pressed("input_interact") and on_floor and colliding_body != null:
		if colliding_body.weapons.get_child_count() < PlayerGlobal.player_WS_current:
			pick_up(colliding_body)
		else:
			print("inventory full")


func enemy_attack() -> void:
	if not animation_player.is_playing() and cd_timer.time_left == 0:
		animation_player.play("Attack")
		#playSFX(0)
		cd_timer.start()


func enemy_special_attack() -> void:
	animation_player.play("Cancel")
	animation_player.play("Special")


# move and flip the weapon according to the rotation direction
func move(rotate_dir: Vector2) -> void:
	if not animation_player.is_playing():
		rotation = rotate_dir.angle()
		hitbox.knockback_dir = rotate_dir
		if scale.y == 1 and rotate_dir.x < 0:
			scale.y = -1
			position.x = -5
		if scale.y == -1 and rotate_dir.x > 0:
			scale.y = 1
			position.x = 5


# check if the weapon is in the middle of doing something
func is_busy() -> bool:
	if animation_player.is_playing():
		return true
	return false


func cancel_attack() -> void:
	animation_player.play("Cancel")
	if owner_player:
		weapon_owner.attacking = false


func pick_up(collecting_body) -> void:
	player_detector.set_collision_mask_bit(0, false)
	player_detector.set_collision_mask_bit(1, false)
	player_detector.set_collision_mask_bit(2, false)
	hitbox.set_collision_mask_bit(2, false)
	hitbox.set_collision_mask_bit(3, true)
	on_floor = false
	collecting_body.pick_up_weapon(self)
	position = Vector2(5,-8)
	cd_timer.set_wait_time(original_cd)
	weapon_owner = collecting_body
	#print("Weapon owner is ", weapon_owner.name)
	owner_player = true
	colliding_body = null
	if weapon_lvl == 2:
		hitbox.damage = 1.5
	$AttackAudio.stream = atkSFX


func drop() -> void:
	print("dropped ", name)
	weapon_owner = null
	owner_player = false


func _on_PlayerDetector_body_entered(body: KinematicBody2D):
	if body != null:
		if body.name == "Player":
			colliding_body = body
			show_description()
	else:
		var __ = tween.stop_all()
		assert(__)
		player_detector.set_collision_mask_bit(2, true)
		on_floor = true


func _on_PlayerDetector_body_exited(body):
	if body != null:
		if body.name == "Player":
			colliding_body = null
			hide_description()


# for interpolating the weapon positions when the player drops it
func interpolate_pos(initial_pos:Vector2, final_pos:Vector2) -> void:
	#print("interpolating", initial_pos, final_pos)
	var __ = tween.interpolate_property(self, "global_position", initial_pos, final_pos, 0.8, Tween.TRANS_QUART, Tween.EASE_OUT)
	assert(__)
	__ = tween.start()
	assert(__)
	# collide with environment
	player_detector.set_collision_mask_bit(0, true)
	player_detector.set_collision_mask_bit(1, true)
	on_floor = true
	$AttackAudio.stream = null


func _on_Tween_tween_completed(object: Object, key: NodePath):
	# collide with player
	player_detector.set_collision_mask_bit(2, true)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Attack" and owner_player:
		weapon_owner.attacking = false
	elif anim_name == "Special":
		weapon_owner.can_attack = true
		weapon_owner.attacking = false
		weapon_owner.special_attacking = false
		weapon_owner.no_attack_cancel = false
		weapon_owner.call_deferred("enable_hurtbox")


func playSFX(sfx) -> void:
	if AudioGlobal.sfx_settings:
		match sfx:
			0:
				$AttackAudio.stream = atkSFX
				$AttackAudio.volume_db = -6
				$AttackAudio.play()


# Show the name when player is on the collectible
func show_description():
	if !btm_text_UI.in_use:
		btm_text_UI.bbcode_text = "[right]" + item_name + "[/right]" 
		btm_text_UI.visible = true
		btm_text_UI.in_use = true
		using_text = true


func hide_description():
	if using_text:
		btm_text_UI.visible = false
		btm_text_UI.in_use = false
		using_text = false
