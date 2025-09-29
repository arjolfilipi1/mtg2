# CardDatabase.gd
extends Node

var cards = {
	"forest": {
		"name": "Forest",
		"mana_cost": "",
		"type": "Land - Forest",
		"abilities": ["T: Add G"]
	},
	"grizzly_bears": {
		"name": "Grizzly Bears",
		"mana_cost": "1G",
		"type": "Creature - Bear",
		"power": 2,
		"toughness": 2
	},
	"lightning_bolt": {
		"name": "Lightning Bolt",
		"mana_cost": "R",
		"type": "Instant",
		"abilities": ["Lightning Bolt deals 3 damage to any target"]
	}
}

func get_card(card_id: String) -> Dictionary:
	return cards.get(card_id, {})
