extends Label


var options_menu


# Called when the node enters the scene tree for the first time.
func _ready():
	options_menu = get_parent().get_node("OptionsMenu")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_HTPMenu_visibility_changed():
	if visible:
		$ButtonMenu/BackBtn.grab_focus()


func _on_BackBtn_pressed():
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
	visible = false
	options_menu.visible = true


func _on_BackBtn_focus_entered():
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
func _on_BackBtn_mouse_entered():
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
