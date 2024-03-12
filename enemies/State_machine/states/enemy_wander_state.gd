class_name EnemyWanderState
extends State

@export var actor : Enemy
@export var animator : AnimationPlayer
@export var vision_cast : RayCast3D

signal found_player

func _ready():
	set_physics_process(false)

func _enter_state() -> void:
	print("entered enemy_wander_state")
	set_physics_process(true)
	# animator.play("move")
	if actor.velocity == Vector3.ZERO:
		actor.velocity = Vector3.RIGHT.rotated(Vector3.UP,randf_range(0, TAU)) * actor.max_speed

func _exit_state() -> void:
	print("exited enemy_wander_state")
	set_physics_process(false)


func _physics_process(delta):
	# rotate enemy here towards the velocity
	# var collision = actor.move_and_collide(actor.velocity * delta)
	# if collision:
	# 	var bounce_velocity = actor.velocity.bounce(collision.get_normal())
	# 	actor.velocity = bounce_velocity
	if vision_cast.is_colliding() && vision_cast.get_collider().name == "Character":
		print("we saw the player")
		found_player.emit()
