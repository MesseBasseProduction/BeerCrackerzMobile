/* Spot types and modifiers */

enum SpotTypes {
  forest,
  river,
  cliff,
  mountain,
  beach,
  sea,
  city,
  pov,
  lake,
}

enum SpotModifiers {
  bench,
  covered,
  toilet,
  store,
  trash,
  parking,
}

/* Shop types and modifiers */

enum ShopTypes {
  store,
  super_, // Must add '_' before super for supermarket type
  hyper,
  cellar,
}

enum ShopModifiers {
  bio,
  craft,
  fresh,
  card,
  choice,
}

/* Bar types and modifiers */

enum BarTypes {
  regular,
  snack,
  cellar,
  rooftop,
}

enum BarModifiers {
  tobacco,
  food,
  card,
  choice,
  outdoor,
}
