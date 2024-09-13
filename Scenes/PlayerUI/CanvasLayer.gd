extends CanvasLayer

signal transitioned
var in_transition:bool = false
export(NodePath) var main_menu_node_path = "/root/Main/MainMenu"
onready var main_menu_node = get_node(main_menu_node_path)


# Called when the node enters the scene tree for the first time.
func _ready():
	$ColorRect.color = Color(0, 0, 0, 255)
#	if !PlayerGlobal.in_menu:
#		show_UI()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$FPSCounter.text = "FPS: " + str(Engine.get_frames_per_second())


# true = to black, false = from black
func transition(black):
	if black:
		$AnimationPlayer.play("to_black")
	else:
		$AnimationPlayer.play("from_black")

# true = to white, false = from white
func transition_white(white):
	if white:
		$AnimationPlayer.play("to_white")
	else:
		$AnimationPlayer.play("from_white")

func transition_long() -> void:
	$AnimationPlayer.play("from_black_long")

func show_UI() -> void:
	if !PlayerGlobal.in_menu:
		get_node("MapContainer").show()
		get_node("Health").show()
		get_node("ArmorU").show()
		get_node("Gold").show()
		get_node("Keys").show()
		get_node("RoomName").show()
		get_node("Score").show()
		get_node("HighScore").show()
		get_node("WeaponSlots").show()
		$AnimationPlayer.play("ShowUI")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "to_black" or anim_name == "to_white":
		emit_signal("transitioned")
		in_transition = true
	elif anim_name == "from_black" or anim_name == "from_white" or anim_name == "from_black_long":
		in_transition = false
		if anim_name == "from_black":
			show_UI()
		elif anim_name == "from_black_long":
			main_menu_node.get_node("AnimationPlayer").play("FadeIn")
#		if !PlayerGlobal.in_menu:
#			show_UI()
