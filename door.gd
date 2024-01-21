extends CharacterBody2D

@export var texture : Texture2D

func _ready():
	$Sprite2D.texture = texture
