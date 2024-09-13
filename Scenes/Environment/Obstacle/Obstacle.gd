extends Node2D

export(NodePath) var dungeon_node_path = MiscGlobal.dungeon_node_path
onready var Dungeon = get_node(dungeon_node_path)
onready var animated_sprite:AnimatedSprite = get_node("AnimatedSprite")
export var gold_scene:PackedScene
export var food_scene:PackedScene
onready var pot_sfx = load("res://SFX/Environment/hurt4.wav")
onready var bush_sfx = load("res://SFX/Environment/dust2.wav")
onready var rock_sfx = load("res://SFX/Environment/hurt4.wav")
onready var rock_hit_sfx = load("res://SFX/Environment/rockHit.wav")
var obs_types:Dictionary = {"bush" : 0, "rock" : 1, "pot" : 2, "rock2" : 3}
var obs_type:int
var rng = RandomNumberGenerator.new()
var room_pos:Vector2 # tile pos in room
var drop_pos:Vector2 # for dropping rock
var dropping:bool = false
var drop_speed:int = 200


# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
#	if obs_type == obs_types.rock2:
#		$AnimationPlayer.play("rock2fall")


func _physics_process(delta):
	if dropping:
		if global_position.y <= drop_pos.y:
			global_position += Vector2.DOWN * drop_speed * delta
		else:
			$Hurtbox/CollisionShape2D.disabled = false
			$StaticBody2D/CollisionShape2D.disabled = false
			$Hitbox/CollisionShape2D.disabled = true
			$AnimationPlayer.play("rock2hit")
			$AudioStreamPlayer.stream = rock_hit_sfx
			$AudioStreamPlayer.play()
			dropping = false


func set_obstacle(obs_no:int):
	obs_type = obs_no
	match obs_no:
		obs_types.bush:
			animated_sprite.animation = "bush"
		obs_types.rock:
			animated_sprite.animation = "rock"
		obs_types.pot:
			animated_sprite.animation = "pot"
		obs_types.rock2:
			animated_sprite.animation = "rock2fall"
#			var anim:Animation = $AnimationPlayer.get_animation("rock2fall")
#			var track_id:int = 2
#			var key_id:int = anim.track_find_key(track_id, 0)
#			anim.track_set_key_value(track_id, key_id, position - Vector2(0, 80))
#			var key_id2:int = anim.track_find_key(track_id, 1)
#			anim.track_set_key_value(track_id, key_id2, position)
			drop_rock()


func playSFX():
	if AudioGlobal.sfx_settings:
		match obs_type:
			obs_types.bush:
				$AudioStreamPlayer.stream = bush_sfx
				#print("Bush Destroyed")
			obs_types.rock:
				$AudioStreamPlayer.stream = rock_sfx
				#print("Rock Destroyed")
			obs_types.pot:
				$AudioStreamPlayer.stream = pot_sfx
				#print("Pot Destroyed")
			obs_types.rock2:
				$AudioStreamPlayer.stream = rock_sfx
		$AudioStreamPlayer.play()


func drop_item():
	match obs_type:
		obs_types.rock:
			var k = 5
			for i in DungeonGlobal.floor_level - 1:
				k = max(1, min(k, k - 2))
			if rng.randi_range(0, k) == 0:
				var gold = gold_scene.instance()
				Dungeon.current_room.call_deferred("add_child", gold)
				gold.call_deferred("set_owner", Dungeon.current_room)
				gold.global_position = position
		obs_types.pot:
			var k = 7
			for i in DungeonGlobal.floor_level - 1:
				k = max(1, min(k, k - 2))
			if rng.randi_range(0, k) == 0:
				var food = food_scene.instance()
				Dungeon.current_room.call_deferred("add_child", food)
				food.call_deferred("set_owner", Dungeon.current_room)
				food.global_position = position
		obs_types.rock2:
			if rng.randi_range(0, 2) == 0:
				var item  = food_scene.instance()
				Dungeon.current_room.call_deferred("add_child", item)
				item.call_deferred("set_owner", Dungeon.current_room)
				item.global_position = position


func drop_rock() -> void:
	$AnimationPlayer.play("rock2fall")
	$Hurtbox/CollisionShape2D.disabled = true
	$StaticBody2D/CollisionShape2D.disabled = true
	$Hitbox/CollisionShape2D.disabled = false
	drop_pos = global_position
	global_position -= Vector2(0, 80)
	dropping = true


# called when the character takes damage
func take_damage(dmg: float, dir: Vector2, force: int) -> void:
	if obs_type == obs_types.rock2:
		$AnimationPlayer.play("rock")
	else:
		get_node("AnimationPlayer").play(animated_sprite.animation)
	Dungeon.current_room.taken_positions_floor.erase(room_pos)
	playSFX()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "rock2fall":
		print("dropped")
