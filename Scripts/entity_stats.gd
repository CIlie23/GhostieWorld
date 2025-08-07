extends Resource
class_name EntityStats

@export var Name:String 
@export var Attack: int
@export var Health: int 
@export var Defense: int 
@export var Mana: int 

@export var CritChance: float
@export var MissChance: float
@export var StunChance: float

@export var sprite:Texture2D

func take_damage(amount: int) -> void:
	#print("Damage: ", amount)
	amount -= Defense
	amount = max(amount, 1) 
	#print("Health: ", amount)
	Health -= amount

func heal(amount: int):
	var heal_amount = max(amount, 10)
	print(amount)
	Health += heal_amount

func raise_defense(amount: int):
	amount = max(amount, 10) 
	pass
