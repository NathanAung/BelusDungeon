extends Collectible


func Collect():
	#print("Collected ", value, " Gold!")
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.gold)
	PlayerGlobal.player_Gold_current = int(min(PlayerGlobal.player_Gold_current + value, PlayerGlobal.player_Gold_limit))
