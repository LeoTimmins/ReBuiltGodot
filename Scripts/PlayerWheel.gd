extends Spatial

func normalize_angle(angle: float):
	if angle > 2*PI:
		return 0;
	elif angle < 0:
		return 2*PI
	else:
		return angle;

var wheel_wobble_right = true;

func _process(delta):
	# rotate wheel
	var input_vector = Input.get_vector("ui_left", "ui_right", "ui_down", "ui_up").normalized();
	rotation.x = normalize_angle(rotation.x + input_vector.y * delta);
	if wheel_wobble_right:
		rotation.z += input_vector.y / 40;
		if rotation.z >= PI/40:
			wheel_wobble_right = false;
	else:
		rotation.z -= input_vector.y / 40;
		if rotation.z <= -PI/40:
			wheel_wobble_right = true;
