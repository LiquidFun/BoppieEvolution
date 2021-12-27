extends Node

enum NNInput {ENERGY, RAY_DIST, RAY_TYPE, EATS, DANGER_SENSE}
enum Raytype {NONE, OWLIE, KLOPPIE, FOOD}
enum Senses {
	BIAS = 1 << 0,
	VISION_RAY_EATS = 1 << 1,
	DANGER_SENSE = 1 << 2,
	MEMORY = 1 << 3,
}
