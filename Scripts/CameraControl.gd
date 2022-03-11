extends Camera

func normalize_angle(angle: float):
	if angle > 2*PI:
		return 0;
	elif angle < 0:
		return 2*PI;
	else:
		return angle;
		
func _input(event):
	if event is InputEventMouseMotion:
		var mouse_speed = event.get_relative();
		get_parent().rotation.y = normalize_angle(get_parent().rotation.y - mouse_speed.x / 200);
		get_parent().rotation.x = max(min(get_parent().rotation.x + mouse_speed.y / 200, 0.5), -0.5);
