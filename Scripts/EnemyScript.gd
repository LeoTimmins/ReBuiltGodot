extends KinematicBody

var EnemyHealth = 100

func _physics_process(delta):
	if EnemyHealth <= 0:
		print("I am Dead")
