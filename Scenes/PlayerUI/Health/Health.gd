extends HBoxContainer

export var heart_scene:PackedScene
# HP from last update
var last_hp = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	generate_hearts()
	update_health()


func generate_hearts():
	for n in get_children():
		remove_child(n)
		n.queue_free()
	for i in PlayerGlobal.player_HP_max/4:
		var heart = heart_scene.instance()
		add_child(heart)
		heart.get_node("AnimationPlayer").play("Heal")


func update_health():
	var hp = PlayerGlobal.player_HP_current
	for i in self.get_child_count():
		if hp >= 4:
			if ((last_hp >= 4 and hp == 4) or last_hp < 4) and PlayerGlobal.player_HP_current > last_hp:
				get_child(i).get_node("AnimationPlayer").play("Heal")
			get_child(i).get_node("Sprite").frame = 4
			hp -= 4
		elif hp == 3:
			if PlayerGlobal.player_HP_current > last_hp:
				get_child(i).get_node("AnimationPlayer").play("Heal")
			elif PlayerGlobal.player_HP_current < last_hp:
				get_child(i).get_node("AnimationPlayer").play("Hurt")
			get_child(i).get_node("Sprite").frame = 3
			hp -= 3
		elif hp == 2:
			if PlayerGlobal.player_HP_current > last_hp:
				get_child(i).get_node("AnimationPlayer").play("Heal")
			elif PlayerGlobal.player_HP_current < last_hp:
				get_child(i).get_node("AnimationPlayer").play("Hurt")
			get_child(i).get_node("Sprite").frame = 2
			hp -= 2
		elif hp == 1:
			if PlayerGlobal.player_HP_current > last_hp:
				get_child(i).get_node("AnimationPlayer").play("Heal")
			elif PlayerGlobal.player_HP_current < last_hp:
				get_child(i).get_node("AnimationPlayer").play("Hurt")
			get_child(i).get_node("Sprite").frame = 1
			hp -= 1
		else:
			get_child(i).get_node("Sprite").frame = 0
	last_hp = PlayerGlobal.player_HP_current
