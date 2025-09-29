extends Area2D
class_name Card

@export var card_data: Dictionary = {}:
	set(value):
		card_data = value
		if is_inside_tree():
			setup_card()

@onready var card_ui = $CardUI
@onready var name_label: Label = $CardUI/NameLabel
@onready var mana_cost_label: Label = $CardUI/ManaCostLabel
@onready var type_label: Label = $CardUI/TypeLabel
@onready var rules_text_label: Label = $CardUI/RulesText
@onready var pt_label: Label = $CardUI/PTLabel
@onready var background: ColorRect = $CardUI/Background

var card_name: String
var mana_cost: String
var card_type: String
var is_tapped: bool = false

func _ready():
	if not card_data.is_empty():
		setup_card()
		print(scale)
func setup_card():
	card_name = card_data.get("name", "Unknown")
	mana_cost = card_data.get("mana_cost", "")
	card_type = card_data.get("type", "")
	
	# Update visual elements
	name_label.text = card_name
	mana_cost_label.text = mana_cost
	type_label.text = card_type
	
	# Set rules text if available
	if card_data.has("rules_text"):
		rules_text_label.text = card_data.get("rules_text")
	else:
		rules_text_label.text = ""
	
	# Set power/toughness for creatures
	if card_data.has("power") and card_data.has("toughness"):
		pt_label.text = "%d/%d" % [card_data.power, card_data.toughness]
		pt_label.visible = true
	else:
		pt_label.visible = false
	
	# Set card color based on type
	set_card_color()

func set_card_color():
	var color: Color
	var type_lower = card_type.to_lower()
	
	if "land" in type_lower:
		color = Color.BROWN
	elif "creature" in type_lower:
		color = Color.YELLOW_GREEN
	elif "instant" in type_lower or "sorcery" in type_lower:
		color = Color.SKY_BLUE
	elif "enchantment" in type_lower:
		color = Color.BLUE_VIOLET
	elif "artifact" in type_lower:
		color = Color.LIGHT_GRAY
	else:
		color = Color.WHITE
	
	background.color = color

func tap():
	is_tapped = true
	rotation = PI / 2

func untap():
	is_tapped = false
	rotation = 0

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton and event.pressed:
		# Emit a signal or handle the click
		print("Card clicked: %s" % card_name)
