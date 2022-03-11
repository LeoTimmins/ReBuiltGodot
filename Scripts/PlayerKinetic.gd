extends KinematicBody

var speed = 3
# The downward acceleration when in the air, in meters per second squared.
var fall_acceleration = 9.8


export (NodePath) var camera_path
onready var camera = get_node(camera_path)

export (NodePath) var camera_pivot_path
onready var camera_pivot = get_node(camera_pivot_path)

export (NodePath) var mesh_path
onready var mesh = get_node(mesh_path)

export (NodePath) var collision_path
onready var collision = get_node(collision_path)

export (NodePath) var wheel_path
onready var wheel = get_node(wheel_path)

var velocity = Vector3.ZERO

func normalize_angle(angle: float):
	if angle > 2*PI:
		return 0;
	elif angle < 0:
		return 2*PI
	else:
		return angle;
	
func _ready():
	#Hide Mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		var mouse_speed = event.get_relative();
		mouse_speed.normalized();
		camera_pivot.rotation.y -= mouse_speed.x / 200;
		camera_pivot.rotation.y = normalize_angle(camera_pivot.rotation.y);
		camera_pivot.rotation.x += mouse_speed.y / 200;
		camera_pivot.rotation.x = max(min(camera_pivot.rotation.x, 0.5), -0.5);
	if event is InputEventKey:
		if Input.is_action_just_pressed("Debug_GiveMouse"):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);

var interpo_time = 0.0;
var rotating = false;

var wheel_wobble_right = true;

func _physics_process(delta):	
	# Debugging
	#print("FPS " + String(Engine.get_frames_per_second()))
	print(wheel.rotation);
	# End of debugging

	# Directions relative to camera
	var forward = -camera.get_global_transform().basis.z;
	var right = forward.cross(Vector3.UP);
	
	var move_direction = Vector3.ZERO
	var input_vector = Input.get_vector("ui_left", "ui_right", "ui_down", "ui_up");
	input_vector.normalized();
	move_direction = input_vector.x * right + input_vector.y * forward;
	move_direction.y = 0;
	wheel.rotation.x += input_vector.y;
	wheel.rotation.x = normalize_angle(wheel.rotation.x);
	if wheel_wobble_right:
		wheel.rotation.z += input_vector.y / 40;
		if wheel.rotation.z >= PI/40:
			wheel_wobble_right = false;
	else:
		wheel.rotation.z -= input_vector.y / 40;
		if wheel.rotation.z <= -PI/40:
			wheel_wobble_right = true;
	
	# Detect Inputs and Vector math
	if Input.is_action_just_pressed("ui_left") || Input.is_action_just_pressed("ui_right") || Input.is_action_just_pressed("ui_up") || Input.is_action_just_pressed("ui_down"):
		rotating = true;
		
	if Input.is_action_pressed("ui_right") ||  Input.is_action_pressed("ui_left") ||  Input.is_action_pressed("ui_up") ||  Input.is_action_pressed("ui_down"):
		if rotating == false:
			mesh.rotation.y = camera_pivot.rotation.y;
			collision.rotation.y = camera_pivot.rotation.y;
	
	if rotating == true:
		if mesh.rotation.y == camera_pivot.rotation.y:
			rotating = false;
			interpo_time = 0.0;
		else:
			mesh.rotation = mesh.rotation.linear_interpolate(Vector3(mesh.rotation.x, camera_pivot.rotation.y, mesh.rotation.z), interpo_time);
			collision.rotation = mesh.rotation;
			interpo_time += delta * 0.8;
			if interpo_time > 1.0:
				interpo_time = 1.0;

	# Jumping
	if Input.is_action_just_pressed("SpaceBar") && is_on_floor():
		move_direction.y = 8;
		
	#Apply movement and velocity calculations
	velocity.x = move_direction.x * speed
	velocity.z = move_direction.z * speed
	velocity.y += move_direction.y - fall_acceleration * delta
	velocity = move_and_slide(velocity, Vector3.UP)
	
