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

var velocity = Vector3.ZERO

func _ready():
	
	#Hide Mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		var mouse_speed = event.get_relative();
		mouse_speed.normalized();
		camera_pivot.rotation.y -= mouse_speed.x / 200;
		camera_pivot.rotation.x += mouse_speed.y / 200;
		camera_pivot.rotation.x = max(min(camera_pivot.rotation.x, 0.5), -0.5);
	if event is InputEventKey:
		if Input.is_action_just_pressed("Debug_GiveMouse"):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);

var interpo_time = 0.0
var rotating = false;

func _physics_process(delta):
	
	#debugging
	#print("FPS " + String(Engine.get_frames_per_second()))
	#end of debugging


	var forward = camera.get_global_transform().basis.z;
	var direction = Vector3.ZERO
	
	#Detect Inputs and Vector math

	if Input.is_action_just_pressed("ui_left") || Input.is_action_just_pressed("ui_right") || Input.is_action_just_pressed("ui_up") || Input.is_action_just_pressed("ui_down"):
		rotating = true;
		
	if Input.is_action_pressed("ui_right"):
		direction -= forward.cross(Vector3.UP);
		if rotating == false:
			mesh.rotation.y = camera_pivot.rotation.y;
		
	if Input.is_action_pressed("ui_left"):
		direction += forward.cross(Vector3.UP);
		if rotating == false:
			mesh.rotation.y = camera_pivot.rotation.y;
		
	if Input.is_action_pressed("ui_down"):
		direction += forward;
		if rotating == false:
			mesh.rotation.y = camera_pivot.rotation.y;
		
	if Input.is_action_pressed("ui_up"):
		direction -= forward;
		if rotating == false:
			mesh.rotation.y = camera_pivot.rotation.y;
		
		#collision.rotation.y = camera_pivot.rotation.y;
	if rotating == true:
		if mesh.rotation.y == camera_pivot.rotation.y:
			rotating = false;
			interpo_time = 0.0;
		else:
			mesh.rotation = mesh.rotation.linear_interpolate(Vector3(mesh.rotation.x, camera_pivot.rotation.y, mesh.rotation.z), interpo_time);
			interpo_time += delta * 0.8;
			if interpo_time > 1.0:
				interpo_time = 1.0;
		
	if direction != Vector3.ZERO:
		direction.y = 0;
		direction = direction.normalized()

	#jumping
	if Input.is_action_just_pressed("SpaceBar") && is_on_floor():
		direction.y = 6;
		
		
	#Apply movemet and velocity calculations
	
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	velocity.y += direction.y - fall_acceleration * delta
	velocity = move_and_slide(velocity, Vector3.UP)
	
