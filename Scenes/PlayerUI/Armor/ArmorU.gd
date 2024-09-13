extends HBoxContainer

export var armor_scene:PackedScene
var last_ap = 0


# Called when the node enters the scene tree for the first time.
#func _ready():
#	generate_armor_ui()
#	update_armor_ui()


func generate_armor_ui():
	for n in get_children():
		remove_child(n)
		n.queue_free()
	for i in PlayerGlobal.player_armor_max/2:
		var armor = armor_scene.instance()
		add_child(armor)
		armor.get_node("AnimationPlayer").play("Gain")


func update_armor_ui():
	var ap = PlayerGlobal.player_armor_current
	for i in self.get_child_count():
		if ap >= 2:
			get_child(i).get_node("Sprite").frame = 2
			ap -= 2
		elif ap == 1:
			if PlayerGlobal.player_armor_current < last_ap:
				get_child(i).get_node("AnimationPlayer").play("Hurt")
			get_child(i).get_node("Sprite").frame = 1
			ap -= 1
		else:
			get_child(i).get_node("Sprite").frame = 0
	last_ap = PlayerGlobal.player_armor_current
