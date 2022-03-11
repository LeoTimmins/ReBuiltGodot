extends Spatial


func _input(event):
	if event is InputEventMouseMotion:
		var mouse_speed = event.get_speed();
		mouse_speed.normalized();
		rotation.x += mouse_speed.y / 10000;
