class_name Enemy
extends CharacterBody3D
@export_group("values")
@export var max_speed = 40.0
@export var acceleration = 50.0
@export var max_health : float = 100
@export var current_health : float
@export_group("Enemy_Nodes")
@export var idle_list : Array[StringName]
@export var player_pos_to_raycast: Vector3
@onready var health_bar_3d = %EnemyHealthBar3D
@onready var raycast3d = $RayCast3D
@onready var fsm  = $FiniteStateMachine as FiniteStateMachine
@onready var enemy_wander_state = $FiniteStateMachine/EnemyWanderState as EnemyWanderState
@onready var enemy_chase_state = $FiniteStateMachine/EnemyChaseState as EnemyChaseState
@export var animator : AnimationPlayer 
func _ready():
	enemy_wander_state.found_player.connect(fsm.change_state.bind(enemy_chase_state))
	enemy_chase_state.lost_player.connect(fsm.change_state.bind(enemy_wander_state))
	current_health = max_health

func take_damage(damage):
	current_health = current_health - damage
	var health_ratio = current_health/max_health
	health_bar_3d.value = health_ratio*health_bar_3d.max_value
	if current_health <= 0:
		destroyed()

func destroyed():
	self.queue_free()

func _physics_process(delta):
	player_pos_to_raycast = to_local(PlayerGlobals.player.COLLISION_MESH.global_position - Vector3(0,raycast3d.global_position.y,0))
	raycast3d.target_position = player_pos_to_raycast
