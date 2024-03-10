@tool

extends Node3D

@export var WEAPON_TYPE : Weapons:
	set(value):
		WEAPON_TYPE = value
		if Engine.is_editor_hint():
			load_weapon()


@onready var weapon_mesh : MeshInstance3D = %WeaponMesh
@onready var animation_player : AnimationPlayer = %WeaponAnimationPlayer
@onready var raycast : RayCast3D = %WeaponRayCast3D
@onready var sound_stream_player : AudioStreamPlayer3D = %WeaponSound
@onready var gun_tracer = %WeaponLineRenderer3D
@onready var gun_muzzle = %WeaponMuzzle
var fire_rate : float
var spray_randomness_vertical : float
var spray_randomness_horizontal : float
var damage : int
var max_ammo : int
var current_ammo : int
var activate_animation : String
var shooting_animation : String
var is_semi_auto : bool
var explosive : bool
var activate_sound : AudioStreamOggVorbis
var shooting_sound : AudioStreamOggVorbis
var raycast_range : float 
var hit_point : Vector3
var head : Node3D
var shoot_cooldown_current : float
var shoot_is_pressed : bool = false
var grenade_scene : PackedScene
var grenade_force : float


func _ready() -> void:
	load_weapon()
	play_weapon_activate_animation()
	raycast.target_position = Vector3(0,-raycast_range,0)


func _input(event):
	if event.is_action_pressed("weapon1"):
		WEAPON_TYPE = load("res://weapons/Resources/assault_rifle.tres")
		load_weapon()
		play_weapon_activate_animation()
		play_weapon_activate_sound()
	if event.is_action_pressed("weapon2"):
		WEAPON_TYPE = load("res://weapons/Resources/Pistol.tres")
		load_weapon()
		play_weapon_activate_animation()
		play_weapon_activate_sound()



func load_weapon() -> void:
	weapon_mesh.mesh = WEAPON_TYPE.mesh
	position = WEAPON_TYPE.position
	rotation_degrees  = WEAPON_TYPE.rotation
	fire_rate = WEAPON_TYPE.fire_rate
	damage = WEAPON_TYPE.damage
	current_ammo = WEAPON_TYPE.max_ammo
	max_ammo = WEAPON_TYPE.max_ammo
	activate_animation = WEAPON_TYPE.activate_animation
	shooting_animation = WEAPON_TYPE.shooting_animation
	is_semi_auto = WEAPON_TYPE.is_semi_auto
	explosive = WEAPON_TYPE.explosive
	activate_sound = WEAPON_TYPE.activate_sound
	shooting_sound = WEAPON_TYPE.shooting_sound
	spray_randomness_vertical = WEAPON_TYPE.spray_randomness_vertical
	spray_randomness_horizontal = WEAPON_TYPE.spray_randomness_horizontal
	raycast_range = WEAPON_TYPE.raycast_range
	gun_muzzle.position = WEAPON_TYPE.gun_muzzle
	shoot_cooldown_current = WEAPON_TYPE.shoot_cooldown_max
	grenade_scene = WEAPON_TYPE.grenade_scene
	grenade_force = WEAPON_TYPE.grenade_force


func play_weapon_activate_animation() -> void:
	animation_player.play(activate_animation)

# func play_weapon_activate_sound() -> void:
	

func play_weapon_shoot_animation() -> void :
	if not animation_player.is_playing():
		animation_player.play(shooting_animation)
		

func play_weapon_activate_sound() -> void : 
	sound_stream_player.stream = activate_sound
	sound_stream_player.play()

func play_weapon_shoot_sound() -> void:
	sound_stream_player.stream = shooting_sound	
	sound_stream_player.play()

func shoot():
		if explosive == true:
			#TODO: grenades are weirdly moving rn,I believe the solution to be using the raycast to get the global_position of the hit_point (normalizing that Vector - self.position)
			var grenade : Node3D = grenade_scene.instantiate()
			hit_point = raycast.get_collision_point()
			get_node("../../..").add_child(grenade)
			grenade.set_owner(get_node("../../.."))
			grenade.global_position = global_position
			# var grenade_rb : RigidBody3D = grenade.get_node("RigidBody3D")
			grenade.apply_impulse((hit_point-self.position).normalized()*grenade_force)
		else:
			raycast.global_position = PlayerGlobals.head.global_position
			raycast.target_position = Vector3(0,-raycast_range,0)
			hit_point = raycast.get_collision_point()
			var new_array : Array[Vector3] = [gun_muzzle.global_position,hit_point]
			gun_tracer.points = new_array
			var hit_object = raycast.get_collider().get_parent()
			if hit_object.has_method("take_damage"):
				print("we hit : " + str(hit_object.name))
				hit_object.take_damage(damage)
			shoot_cooldown_current = fire_rate
	
func _process(delta):
	if not Engine.is_editor_hint():
		if Input.is_action_just_pressed("shoot"):
			if is_semi_auto == false:
				shoot_is_pressed = true
			if shoot_cooldown_current <= 0:
				play_weapon_shoot_animation()
				play_weapon_shoot_sound()
				shoot()	
		if Input.is_action_just_released("shoot"):
			if is_semi_auto == false:
				shoot_is_pressed = false
		shoot_cooldown_current -= delta
		if shoot_is_pressed == true:
			if shoot_cooldown_current <= 0:
				play_weapon_shoot_animation()
				play_weapon_shoot_sound()
				shoot()	
		# print("shoot_cooldown_current : " + str(shoot_cooldown_current))
	
