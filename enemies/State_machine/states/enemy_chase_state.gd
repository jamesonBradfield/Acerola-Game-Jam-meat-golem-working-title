class_name EnemyChaseState
extends State

@export var actor: Enemy
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
	actor.animator.stop()
	set_physics_process(false)

func _physics_process(delta) -> void:
	actor.look_at(PlayerGlobals.player.global_position)
	var direction = Vector3()
	if not actor.animator.is_playing():
		actor.animator.play("Walking")
	nav.target_position = PlayerGlobals.player.global_position
	direction = nav.get_next_path_position() - actor.global_position
	direction = direction.normalized()	
	actor.velocity = actor.velocity.lerp(direction * actor.max_speed , actor.acceleration * delta)
	actor.move_and_slide()
	
	if vision_cast.is_colliding() && vision_cast.get_collider().name != "Character":
		lost_player.emit()
