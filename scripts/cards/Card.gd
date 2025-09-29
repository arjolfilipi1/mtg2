extends Area2D
class_name Card  # This is important!
@export var card_data: Dictionary = {}:
	set(value):
		card_data = value
		if is_inside_tree():
			setup_card()

@onready var card_ui = $CardUI

var card_name: String
var mana_cost: String
var card_type: String
var is_tapped: bool = false

func _ready():
	if not card_data.is_empty():
		setup_card()

func setup_card():
	card_name = card_data.get("name", "Unknown")
	mana_cost = card_data.get("mana_cost", "")
	card_type = card_data.get("type", "")
	
	if card_ui:
		card_ui.update_display(self)

func tap():
	is_tapped = true
	rotation = PI / 2

func untap():
	is_tapped = false
	rotation = 0
