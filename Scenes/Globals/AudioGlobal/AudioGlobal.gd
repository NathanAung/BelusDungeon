extends AudioStreamPlayer

# dungeon node in main scene
export(NodePath) var dungeon_node_path = MiscGlobal.dungeon_node_path
onready var Dungeon = get_node(dungeon_node_path)
# Music
var TitleM = load("res://Music/TitleLoop.mp3")
var DungeonM = load("res://Music/Dungeon.mp3")
var HealingRoomM = load("res://Music/HealingRoom.mp3")
var ShopM = load("res://Music/Shop.mp3")
var GameOverM = load("res://Music/GameOver.mp3")
var VictoryM = load("res://Music/Victory.ogg")
var BossIntroM = load("res://Music/BossIntro.mp3")
var BossThemeM = load("res://Music/BossTheme.mp3")
var boss_intro_track:int = 8
var title_track:int = 10
var victory_track:int = 11
# SFX
var enter = load("res://SFX/Character/doorEnter.wav")
var doorClose = load("res://SFX/Environment/doorClose.wav")
var doorOpen = load("res://SFX/Environment/doorOpen.wav")
var doorLocked = load("res://SFX/Environment/doorlocked.wav")
var pause_sfx = load("res://SFX/UI/pause.wav")
var menu_sfx = load("res://SFX/UI/menu.wav")
var start_game_sfx = load("res://SFX/UI/StartGame.wav")
var SFX_type = {"gold":0, "doorEnter":1, "doorClose":2, "doorLocked":3, "doorOpen":4, "pause":5, "menu":6, "start_game":7}

export var bgm_volume_default:float = -4
var bgm_volume:float = bgm_volume_default
var bgm_volume_paused_default:float = -20
var bgm_volume_paused:float = bgm_volume_paused_default
# turning audio on/off
export var music_settings:bool = true
export var sfx_settings:bool = true
var music_off_fixed:bool = false

func _ready():
	music_on_off(music_settings, false)


# change music when the player enters a different room
func change_music(track):
	match track:
		DungeonGlobal.room_type.normal:
			if self.stream != DungeonM:
				self.stream = DungeonM
				volume_db = bgm_volume
				#if music_settings:
				self.play()
		DungeonGlobal.room_type.healing:
			self.stream = HealingRoomM
			volume_db = bgm_volume
			self.play()
		DungeonGlobal.room_type.shop:
			self.stream = ShopM
			volume_db = bgm_volume + 10
			self.play()
		boss_intro_track:
			self.stream = BossIntroM
			volume_db = bgm_volume + 5
			self.play()
		victory_track:
			self.stream = VictoryM
			volume_db = bgm_volume
			self.play()
		title_track:
			self.stream = TitleM
			volume_db = bgm_volume
			self.play()


# in-game music setting
func music_on_off(music_on, game_over):
	if music_on and !music_off_fixed:
		#playing = true
		bgm_volume = bgm_volume_default
		bgm_volume_paused = bgm_volume_paused_default
		volume_db = bgm_volume
		print("music on")
	else:
		if game_over:
			self.stream = GameOverM
			volume_db = bgm_volume + 10
			if music_settings:
				self.play()
		else:
			bgm_volume = -80
			bgm_volume_paused = -80
			volume_db = bgm_volume
			print('music off')


func play_SFX(sfx):
	if sfx_settings:
		match sfx:
			SFX_type.gold:# Gold
				$GoldSFX.volume_db = -5
				$GoldSFX.play()
			SFX_type.doorEnter:# Door Enter
				$DoorSFX.stream = enter
				$DoorSFX.volume_db = -2
				$DoorSFX.play()
			SFX_type.doorClose:# Close Door
				$DoorSFX.stream = doorClose
				$DoorSFX.volume_db = -18
				$DoorSFX.play()
			SFX_type.doorOpen:# Open Door
				$DoorSFX.stream = doorOpen
				$DoorSFX.volume_db = -22
				$DoorSFX.play()
			SFX_type.doorLocked:
				$DoorSFX.stream = doorLocked
				$DoorSFX.volume_db = 1
				$DoorSFX.play()
			SFX_type.pause:
				$UISFX.stream = pause_sfx
				$UISFX.play()
			SFX_type.menu:
				$UISFX.stream = menu_sfx
				$UISFX.play()
			SFX_type.start_game:
				$UISFX.stream = start_game_sfx
				$UISFX.play()



func _on_AudioGlobal_finished():
	if self.stream == GameOverM:
		playing = false
	elif self.stream == BossIntroM:
		self.stream = BossThemeM
		volume_db = bgm_volume + 5
		self.play()
