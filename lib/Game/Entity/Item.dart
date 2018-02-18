import 'package:json_object/json_object.dart' show JsonObject;

class Item {
  static const TYPE_EQUIPMENT = 'armor';
  static const TYPE_BOOSTER = 'booster';
  static const TYPE_BOOK = 'potion';
  static const TYPE_GIFT = 'gift';
  static const RARITY_COMMON = 'common';
  static const RARITY_RARE = 'rare';
  static const RARITY_EPIC = 'epic';
  static const RARITY_LEGENDARY = 'epic';

  final int id;
  final String type;
  final String rarity;
  final Price price;

  Item({
    this.id,
    this.type,
    this.rarity,
    this.price,
  });

  static int sortByHigherValue(Item a, Item b) =>
    a.price.compareTo(b.price);

  JsonObject toJson() =>
    new JsonObject
      .fromMap({
        'id': id,
        'type': type,
        'rarity': rarity,
        'price': price,
      });

  String toString() =>
    toJson().toString();
}

class Price implements Comparable<Price> {
  final int currency;
  final int specialCurrency;
  final int reSellCurrency;

  Price({
      this.currency = 0,
      this.specialCurrency = 0,
      this.reSellCurrency = 0,
  });

  int compareTo(Price b) =>
    (specialCurrency > b.specialCurrency)
    || (currency > b.currency && b.specialCurrency == 0)
      ? -1 : 1;

  JsonObject toJson() =>
    new JsonObject
      .fromMap({
        'currency': currency,
        'specialCurrency': specialCurrency,
        'reSellCurrency': reSellCurrency,
      });

  String toString() =>
    toJson().toString();
}
