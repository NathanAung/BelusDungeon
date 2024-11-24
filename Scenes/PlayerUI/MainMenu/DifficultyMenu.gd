extends Label

var main_menu

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	main_menu = get_parent().get_node("MainMenu")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_DifficultyMenu_visibility_changed():
	if visible:
		$ButtonMenu/NormalBtn.grab_focus()


func _on_NormalBtn_pressed():
	visible = false
	MiscGlobal.game_difficulty = 0
	PlayerGlobal.set_difficulty()
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.start_game)
	get_node("../..").get_node("AnimationPlayer").play("FadeOut")


func _on_EasyBtn_pressed():
	visible = false
	MiscGlobal.game_difficulty = 1
	PlayerGlobal.set_difficulty()
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.start_game)
	get_node("../..").get_node("AnimationPlayer").play("FadeOut")


func _on_BackBtn_pressed():
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
	visible = false
	main_menu.visible = true


func _on_NormalBtn_focus_entered():
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
func _on_NormalBtn_mouse_entered():
	if get_focus_owner() != null:
		get_focus_owner().release_focus()
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
func _on_EasyBtn_focus_entered():
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
func _on_EasyBtn_mouse_entered():
	if get_focus_owner() != null:
		get_focus_owner().release_focus()
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
func _on_BackBtn_focus_entered():
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
func _on_BackBtn_mouse_entered():
	if get_focus_owner() != null:
		get_focus_owner().release_focus()
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
