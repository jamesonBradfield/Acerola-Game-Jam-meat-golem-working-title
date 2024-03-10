class_name Weapons extends Resource

@export var name : StringName
@export_category("Weapon Orientation")
@export var position : Vector3
@export var rotation : Vector3
@export_category("Visual Settings")
@export var mesh : Mesh
@export var activate_animation : StringName
@export var shooting_animation : StringName
# @export var shadow : bool
@export_category("weapon statistics")
@export var fire_rate : float
@export var damage : int
@export var max_ammo : int
@export var current_ammo : int
@export var is_semi_auto : bool
@export var explosive : bool
@export var raycast_range : float 

@export_category("sound effects")
@export var activate_sound : AudioStreamOggVorbis
@export var shooting_sound : AudioStreamOggVorbis
@export var spray_randomness_vertical : float
@export var spray_randomness_horizontal : float
