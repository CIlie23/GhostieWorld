extends Resource
class_name EntityStats

@export var Name:String 
@export var Attack: int
@export var Health: int 
@export var Defense: int 
@export var Mana: int 
@export var CritChance: float
@export var sprite:Texture2D

func take_damage(amount: int) -> void:
	print("Damage: ", amount)
	amount -= Defense
	print("Health: ", amount)
	Health -= amount

func heal(amount: int):
	print(amount)
	Health += amount

func raise_defense(amount: int):
	pass
