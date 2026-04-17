extends Camera2D

func trigger_beat(delay = 0.0):
	if !Config.camera_fx or Config.reduced_motion:
		return
	
	if delay != 0.0:
		await get_tree().create_timer(delay).timeout
	var tween = get_tree().create_tween()
	tween.tween_property(self, "zoom", Vector2(1.05, 1.05), 0.07).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "zoom", Vector2(1, 1), 0.17).set_trans(Tween.TRANS_SINE)

func trigger_select():
	if !Config.camera_fx or Config.reduced_motion:
		return
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "zoom", Vector2(1.03, 1.03), 0.03).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "zoom", Vector2(1, 1), 0.1).set_trans(Tween.TRANS_SINE)
