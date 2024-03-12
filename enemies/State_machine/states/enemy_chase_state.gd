class_name EnemyChaseState
extends State

@export var actor: Enemy
@export var animator: AnimationPlayer
@export var vision_cast: RayCast3D
@export var nav : NavigationAgent3D

signal lost_player

func _ready() -> void:
	set_physics_process(false)

func _enter_state() -> void:
	print("entered enemy_chase_state")
	set_physics_process(true)
	# animator.play("move")

func _exit_state() -> void:
	print("exited enemy_chase_state")
	set_physics_process(false)

func _physics_process(delta) -> void:
	# rotate enemy here towards the velocity
	# this move logic can be replaced with nav_mesh stuffs this is just a proof of concept for the state machine
	var direction = Vector3()

	nav.target_position = PlayerGlobals.player.global_position
	print("player global " + str(PlayerGlobals.player.global_position
))
	direction = nav.get_next_path_position() - actor.global_position
	direction = direction.normalized()	
	print("direction " + str(direction))
	actor.velocity = actor.velocity.lerp(direction * actor.max_speed , actor.acceleration * delta)
	
	if vision_cast.is_colliding() && vision_cast.get_collider().name != "Character":
		lost_player.emit()
