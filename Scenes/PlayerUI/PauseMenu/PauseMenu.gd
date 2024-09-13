extends Label

export(NodePath) var dungeon_node_path = MiscGlobal.dungeon_node_path
onready var Dungeon = get_node(dungeon_node_path)
var paused:bool = false
var options_menu
var quit_menu
var htp_menu

func _ready():
	options_menu = get_parent().get_node("OptionsMenu")
	options_menu.last_menu = self
	quit_menu = get_parent().get_node("RTMMMenu")
	htp_menu = get_parent().get_node("HTPMenu")
	#quit_menu.last_menu = self


func _input(event):
	if PlayerGlobal.player_dead:
		return
	
	if event.is_action_pressed("pause") and !PlayerGlobal.in_menu:
		if Dungeon.can_pause:
			AudioGlobal.play_SFX(AudioGlobal.SFX_type.pause)
			# pause the game with the new pause bool
			pause_game(not get_tree().paused)
	
	if paused and visible:
		# remove selection focus if the mouse is moved
		if event is InputEventMouseMotion and get_focus_owner() != null:
			var current_focus = get_focus_owner()
			#current_focus.release_focus()
			#print("focus released")
		# add focus if up or down is pressed
		elif (event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down")) and get_focus_owner() == null:
			$ButtonMenu/OptionsBtn.grab_focus()
			#print("added focus")


# pause/unpause the game
func pause_game(pause):
	get_tree().paused = pause
	self.visible = pause
	
	if pause:
		# hover on the top option for WASD control
		$ButtonMenu/ResumeBtn.grab_focus()
		AudioGlobal.volume_db = AudioGlobal.bgm_volume_paused
	else:
		quit_menu.visible = false
		options_menu.visible = false
		htp_menu.visible = false
		AudioGlobal.volume_db = AudioGlobal.bgm_volume
	
	paused = pause


func _on_PauseMenu_visibility_changed():
	if visible:
		$ButtonMenu/ResumeBtn.grab_focus()


# menu functions
func _on_ResumeBtn_pressed():
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.pause)
	pause_game(false)

func _on_QuitBtn_pressed():
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
	visible = false
	quit_menu.visible = true

func _on_OptionsBtn_pressed():
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
	visible = false
	options_menu.visible = true


# menu SFX
func _on_ResumeBtn_focus_entered():
	# to make sure the pause sfx plays first
	if !AudioGlobal.get_node("UISFX").is_playing():
		AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
func _on_OptionsBtn_focus_entered():
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
func _on_QuitBtn_focus_entered():
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
func _on_ResumeBtn_mouse_entered():
	if get_focus_owner() != null:
		get_focus_owner().release_focus()
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
func _on_OptionsBtn_mouse_entered():
	if get_focus_owner() != null:
		get_focus_owner().release_focus()
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
func _on_QuitBtn_mouse_entered():
	if get_focus_owner() != null:
		get_focus_owner().release_focus()
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
