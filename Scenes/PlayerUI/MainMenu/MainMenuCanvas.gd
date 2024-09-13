extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if !PlayerGlobal.in_menu:
		$Control.visible = false
		$Control/MainMenu.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "FadeIn":
		$Control/MainMenu.movable = true
	elif anim_name == "FadeOut":
		$Control/MainMenu.start_game()
