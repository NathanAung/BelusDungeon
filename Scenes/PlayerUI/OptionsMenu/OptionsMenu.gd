extends Label

var last_menu
var HTP_menu


# Called when the node enters the scene tree for the first time.
func _ready():
	HTP_menu = get_parent().get_node("HTPMenu")
	pass


func _input(event):
	if visible:
		# remove selection focus if the mouse is moved
		if event is InputEventMouseMotion and get_focus_owner() != null:
			var current_focus = get_focus_owner()
			#current_focus.release_focus()
			#print("focus released")
		# add focus if up or down is pressed
		elif get_focus_owner() == null:
			if event.is_action_pressed("ui_up"): 
				$ButtonMenu/Option2/SFXToggleBtn.grab_focus()
			elif event.is_action_pressed("ui_down"):
				$ButtonMenu/BackBtn.grab_focus()


func _on_OptionsMenu_visibility_changed():
	if visible:
		$ButtonMenu/Option1/MusicToggleBtn.grab_focus()
		# update audio settings
		if AudioGlobal.music_settings:
			$ButtonMenu/Option1/MusicToggleBtn.text = "ON"
		else:
			$ButtonMenu/Option1/MusicToggleBtn.text = "OFF"
		
		if AudioGlobal.sfx_settings:
			$ButtonMenu/Option2/SFXToggleBtn.text = "ON"
		else:
			$ButtonMenu/Option2/SFXToggleBtn.text = "OFF"


func _on_MusicToggleBtn_pressed():
	if AudioGlobal.music_settings:
		$ButtonMenu/Option1/MusicToggleBtn.text = "OFF"
		AudioGlobal.music_on_off(false, false)
		AudioGlobal.music_settings = false
		AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
	else:
		$ButtonMenu/Option1/MusicToggleBtn.text = "ON"
		AudioGlobal.music_on_off(true, false)
		if !PlayerGlobal.in_menu:
			AudioGlobal.volume_db = AudioGlobal.bgm_volume_paused
		AudioGlobal.music_settings = true
		AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)


func _on_SFXToggleBtn_pressed():
	if AudioGlobal.sfx_settings:
		$ButtonMenu/Option2/SFXToggleBtn.text = "OFF"
		AudioGlobal.sfx_settings = false
	else:
		$ButtonMenu/Option2/SFXToggleBtn.text = "ON"
		AudioGlobal.sfx_settings = true
		AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)


func _on_HowToPlay_pressed():
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
	visible = false
	HTP_menu.visible = true


func _on_BackBtn_pressed():
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
	visible = false
	last_menu.visible = true


# SFX
func _on_MusicToggleBtn_focus_entered():
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
func _on_MusicToggleBtn_mouse_entered():
	if get_focus_owner() != null:
		get_focus_owner().release_focus()
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
func _on_SFXToggleBtn_focus_entered():
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
func _on_SFXToggleBtn_mouse_entered():
	if get_focus_owner() != null:
		get_focus_owner().release_focus()
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
func _on_BackBtn_focus_entered():
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
func _on_BackBtn_mouse_entered():
	if get_focus_owner() != null:
		get_focus_owner().release_focus()
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
func _on_HowToPlay_focus_entered():
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
func _on_HowToPlay_mouse_entered():
	if get_focus_owner() != null:
		get_focus_owner().release_focus()
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)

