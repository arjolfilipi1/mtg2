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
@onready var pt_label: Label = $CardUI/PowerToughness
@onready var background: ColorRect = $CardUI/Background

# Hover properties
@export var hover_scale: float = 1.2
@export var normal_scale: float = 1.0
@export var hover_raise_height: float = 50.0
@export var animation_duration: float = 0.15

var card_name: String
var mana_cost: String
var card_type: String
var is_tapped: bool = false
var is_hovered: bool = false
var original_position: Vector2
var original_z_index: int

# Tween for smooth animations
var hover_tween: Tween

func _ready():
	if not card_data.is_empty():
		setup_card()
	
	# Store original state
	original_position = position
	original_z_index = z_index
	
	# Connect mouse signals
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func setup_card():
	card_name = card_data.get("name", "Unknown")
	mana_cost = card_data.get("mana_cost", "")
	card_type = card_data.get("type", "")
	
	# Update visual elements
	name_label.text = card_name
	mana_cost_label.text = mana_cost
	type_label.text = card_type
	
	if card_data.has("rules_text"):
		rules_text_label.text = card_data.get("rules_text")
	else:
		rules_text_label.text = ""
	
	if card_data.has("power") and card_data.has("toughness"):
		pt_label.text = "%d/%d" % [card_data.power, card_data.toughness]
		pt_label.visible = true
	else:
		pt_label.visible = false
	
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

func _on_mouse_entered():
	print(name)
	if is_tapped:
		return  # Don't hover tapped cards
	
	is_hovered = true
	start_hover_animation()

func _on_mouse_exited():
	is_hovered = false
	start_unhover_animation()

func start_hover_animation():
	if hover_tween:
		hover_tween.kill()
	
	hover_tween = create_tween()
	hover_tween.set_parallel(true)  # Animate multiple properties at once
	
	# Scale up
	hover_tween.tween_property(self, "scale", Vector2(hover_scale, hover_scale), animation_duration)
	
	# Move up
	var target_position = original_position + Vector2(0, -hover_raise_height)
	hover_tween.tween_property(self, "position", target_position, animation_duration)
	
	# Bring to front
	hover_tween.tween_property(self, "z_index", original_z_index + 10, animation_duration)
	
	# Add a subtle shadow/drop shadow effect
	hover_tween.tween_property(card_ui, "modulate", Color(1.1, 1.1, 1.1), animation_duration)

func start_unhover_animation():
	if hover_tween:
		hover_tween.kill()
	
	hover_tween = create_tween()
	hover_tween.set_parallel(true)
	
	# Scale back to normal
	hover_tween.tween_property(self, "scale", Vector2(normal_scale, normal_scale), animation_duration)
	
	# Move back to original position
	hover_tween.tween_property(self, "position", original_position, animation_duration)
	
	# Restore z-index
	hover_tween.tween_property(self, "z_index", original_z_index, animation_duration)
	
	# Remove highlight effect
	hover_tween.tween_property(card_ui, "modulate", Color.WHITE, animation_duration)

func tap():
	is_tapped = true
	rotation = PI / 2
	# Stop any hover animations if card is tapped
	if is_hovered:
		_on_mouse_exited()

func untap():
	is_tapped = false
	rotation = 0
