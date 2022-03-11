extends KinematicBody;

var speed = 3;
# The downward acceleration when in the air, in meters per second squared.
var fall_acceleration = 9.8;

#placeholder set ammo script

var TotalAmmo = 10;
var LoadedAmmo = 5;
var MaxAmmoInMag = 15;

#set weapon type
var WeaponType = "NailGun"


#Get Child-Node ID's

export (NodePath) var raycaster_path;
onready var raycaster = get_node(raycaster_path);

export (NodePath) var ShootTimer_path;
onready var ShootTimer = get_node(ShootTimer_path);

export (NodePath) var AmmoLabel_path;
onready var AmmoLabel = get_node(AmmoLabel_path);

export (NodePath) var camera_path;
onready var camera = get_node(camera_path);

export (NodePath) var camera_pivot_path;
onready var camera_pivot = get_node(camera_pivot_path);

export (NodePath) var mesh_path;
onready var mesh = get_node(mesh_path);

export (NodePath) var collision_path;
onready var collision = get_node(collision_path);

export (NodePath) var AudioPlayer_path;
onready var AudioPlayer = get_node(AudioPlayer_path);

export (NodePath) var JumpCooldown_path;
onready var JumpCooldown = get_node(JumpCooldown_path);

var velocity = Vector3.ZERO;

func ResetAmmoText():
	AmmoLabel.text = str(LoadedAmmo) + "/" + str(TotalAmmo);

	
func _ready():
	#Hide Mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	
	#reset ammo label
	ResetAmmoText()

func _input(event):
	if event is InputEventKey:
		if Input.is_action_just_pressed("Esc"):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);

var interpo_time = 0.0;
var rotating = false;

func _physics_process(delta):	
	# Debugging
	#print("FPS " + String(Engine.get_frames_per_second()))
	#print(JumpCooldown.is_stopped())
	# End of debugging
	
	#To Do: teleport to middle of cell if falling to far down
	
	#reload
	if Input.is_action_just_pressed("R") and LoadedAmmo != MaxAmmoInMag and TotalAmmo != 0:
		#checks if there isn't enough ammo to fill magazine
		if MaxAmmoInMag - LoadedAmmo > TotalAmmo:
			LoadedAmmo += TotalAmmo;
			TotalAmmo = 0; 
		else: # standard fill magazine
			TotalAmmo -= MaxAmmoInMag - LoadedAmmo;
			LoadedAmmo = MaxAmmoInMag;
		
		
		ResetAmmoText()
		
	#raycast start (Shoot Weapon)
	if LoadedAmmo != 0 && Input.is_action_pressed("L-Mouse") and ShootTimer.is_stopped():
		if WeaponType == "NailGun":
			ShootTimer.start();
			LoadedAmmo -= 1;
			#AudioPlayer.stream("");
			AudioPlayer.play();
		
		ResetAmmoText()
		
		var collider = raycaster.get_collider();
		if collider != null:
			print(collider);
		print(raycaster.is_colliding());
		#raycaster.queue_free();

	# Directions relative to camera
	var forward = -camera.get_global_transform().basis.z;
	var right = forward.cross(Vector3.UP);
	
	# move character
	var move_direction = Vector3.ZERO;
	var input_vector = Input.get_vector("A", "D", "S", "W").normalized();
	move_direction = input_vector.x * right + input_vector.y * forward;
	move_direction.y = 0;
	
	# Detect Inputs and Vector math
	if Input.is_action_just_pressed("A") || Input.is_action_just_pressed("D") || Input.is_action_just_pressed("W") || Input.is_action_just_pressed("S"):
		rotating = true;
	elif Input.is_action_pressed("D") ||  Input.is_action_pressed("A") ||  Input.is_action_pressed("W") ||  Input.is_action_pressed("S"):
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
	if Input.is_action_just_pressed("SpaceBar") && is_on_floor() && JumpCooldown.is_stopped():
		JumpCooldown.start();
		AudioPlayer.play();
		move_direction.y = 7;
		
	#sprint
	if Input.is_action_pressed("Shift"):
		speed = 6;
	else:
		speed = 3
	
		
	#Apply movement and velocity calculations
	velocity.x = move_direction.x * speed;
	velocity.z = move_direction.z * speed;
	velocity.y += move_direction.y - fall_acceleration * delta;
	velocity = move_and_slide(velocity, Vector3.UP);
	
