extends Label

var last_menu


# Called when the node enters the scene tree for the first time.
func _ready():
	#pause_menu = get_parent().get_node("PauseMenu")
	pass


func _input(event):
	if visible:
		# remove selection focus if the mouse is moved
		if event is InputEventMouseMotion and get_focus_owner() != null:
			var current_focus = get_focus_owner()
			#current_focus.release_focus()
			#print("focus released")
		# add focus if left or right is pressed
		elif get_focus_owner() == null:
			if event.is_action_pressed("ui_left"): 
				$ButtonMenu/NoBtn.grab_focus()
			elif event.is_action_pressed("ui_right"):
				$ButtonMenu/YesBtn.grab_focus()


func _on_QuitMenu_visibility_changed():
	if visible:
		$ButtonMenu/NoBtn.grab_focus()


func _on_NoBtn_pressed():
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
	visible = false
	last_menu.visible = true


func _on_YesBtn_pressed():
	get_tree().quit()


# SFX
func _on_YesBtn_focus_entered():
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
func _on_YesBtn_mouse_entered():
	if get_focus_owner() != null:
		get_focus_owner().release_focus()
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
func _on_NoBtn_focus_entered():
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
func _on_NoBtn_mouse_entered():
	if get_focus_owner() != null:
		get_focus_owner().release_focus()
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
