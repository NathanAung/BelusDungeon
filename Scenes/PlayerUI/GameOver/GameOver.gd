extends Label


onready var canvas = get_node("../")
# dungeon node in main scene
export(NodePath) var dungeon_node_path = MiscGlobal.dungeon_node_path
onready var Dungeon = get_node(dungeon_node_path)
var game_over:bool = false
var return_to_menu:bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if !game_over:
			return
		
		if event.scancode == KEY_SPACE:
			$AnimationPlayer.play("FadeOut")
		elif event.scancode == KEY_ESCAPE:
			return_to_menu = true
			$AnimationPlayer.play("FadeOut")


func game_over():
	canvas.transition(true)
	yield(canvas, "transitioned")
	if Dungeon.boss_defeated and AudioGlobal.music_off_fixed:
		AudioGlobal.music_off_fixed = false
		AudioGlobal.music_on_off(true, false)
	if PlayerGlobal.player_score_current > PlayerGlobal.player_score_highest:
		$FinalScore.text = "NEW HIGH SCORE: " + String(PlayerGlobal.player_score_current)
		SaveGlobal.save_game()
	else:
		$FinalScore.text = "Final Score: " + String(PlayerGlobal.player_score_current)
	$AnimationPlayer.play("FadeIn")
	AudioGlobal.music_on_off(false, true)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "FadeIn":
		$FinalScore.visible = true
		$InstructionText.visible = true
		game_over = true
	elif anim_name == "FadeOut":
		if return_to_menu:
			DungeonGlobal.restart(true)
		else:
			DungeonGlobal.restart(false)
