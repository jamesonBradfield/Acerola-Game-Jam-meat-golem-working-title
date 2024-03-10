extends Node3D

@export var max_health : float = 100
@export var current_health : float
@onready var health_bar_3d = %EnemyHealthBar3D


func _ready():
	current_health = max_health

func take_damage(damage):
	current_health = current_health - damage
	var health_ratio = current_health/max_health
	health_bar_3d.value = health_ratio*health_bar_3d.max_value
	if current_health <= 0:
		destroyed()

func destroyed():
	self.queue_free()
