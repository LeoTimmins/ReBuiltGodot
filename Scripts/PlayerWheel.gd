extends Spatial

var wobble_speed = 1;
var spin_speed = 1;
var wobble_angle = PI/40;

func normalize_angle(angle: float):
	if angle > 2*PI:
		return 0;
	elif angle < 0:
		return 2*PI
	else:
		return angle;

var wobble_right = true;

func _process(delta):
	# rotate wheel
	if Input.is_action_pressed("W") || Input.is_action_pressed("S"):
		rotation.x = normalize_angle(rotation.x + spin_speed * delta);
		if wobble_right:
			rotation.z += wobble_speed * delta;
			if rotation.z >= wobble_angle:
				wobble_right = false;
		else:
			rotation.z -= wobble_speed * delta;
			if rotation.z <= -wobble_angle:
				wobble_right = true;
