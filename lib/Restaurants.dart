//import 'package:units/units.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final database = db();
const restaurantTable = 'recents1';

//final double rating;
//final String price;
//final String phone;
//final String id;
//final String name;
//
//final double latitude;
//final double longitude;
//final double distance;
//
//final String alias;
//final bool isClosed;
//final int reviewCount;
//
//final String url;
//final String imageUrl;
//
//final String address1;
//final String address2;
//final String address3;
//final String city;
//final String state;
//final String country;
//final String zip;

Future<Database> db() async {
  return openDatabase(
    join(await getDatabasesPath(), 'products_database.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE IF NOT EXISTS $restaurantTable(id TEXT PRIMARY KEY, '
            'name TEXT, '
            'rating REAL, '
            'phone TEXT, '
            'price TEXT,'
            'lat REAL,'
            'long REAL,'
            'distance REAL,'
            'alias TEXT,'
            'reviewCount INTEGER,'
            'url TEXT,'
            'imageURL TEXT,'
            'address1 TEXT,'
            'address2 TEXT,'
            'address3 TEXT,'
            'city TEXT,'
            'state TEXT,'
            'country TEXT,'
            'zip TEXT'
            ')',
      );
    },
    // Version provides path to perform database upgrades and downgrades.
    version: 1,
  );
}

//Inserting demo data into database
void initDB() async {
//  var prod1 = Product(
//    id: 1,
//    title: 'Shoes',
//    description: 'Rainbow Shoes',
//    image: 'shoes.jpeg',
//    price: 65.0,
//  );
//
//  // Insert a product into the database.
//  await insertProduct(prod1);

}

Future<void> insertRestaurant(Restaurants restaurant) async {
  // Get a reference to the database.
  final Database db = await database;

  //await db.execute("DROP TABLE IF EXISTS $restaurantTable");
  await db.execute(
    'CREATE TABLE IF NOT EXISTS $restaurantTable(id TEXT PRIMARY KEY, '
        'name TEXT, '
        'rating REAL, '
        'phone TEXT, '
        'price TEXT,'
        'lat REAL,'
        'long REAL,'
        'distance REAL,'
        'alias TEXT,'
        'reviewCount INTEGER,'
        'url TEXT,'
        'imageURL TEXT,'
        'address1 TEXT,'
        'address2 TEXT,'
        'address3 TEXT,'
        'city TEXT,'
        'state TEXT,'
        'country TEXT,'
        'zip TEXT'
        ')',
  );

  // Insert the Product into the correct table. Also specify the
  // `conflictAlgorithm`. In this case, if the same product is inserted
  // multiple times, it replaces the previous data.
  await db.insert(
    restaurantTable,
    restaurant.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<List<Restaurants>> getRecents() async {
  // Get a reference to the database.
  final Database db = await database;

  //db.execute('DROP TABLE IF EXISTS $restaurantTable');

  // Query the table for all The Products.
  List<Map<String, dynamic>> maps = await db.query(restaurantTable);

  print("RESULTS == " + maps.toString());
  // Convert the List<Map<String, dynamic> into a List<Product>.

  return List.generate(
    maps.length,
        (i) {
      return Restaurants(
          id: maps[i]['id'],
          name: maps[i]['name'],
          rating: maps[i]['rating'],
          phone: maps[i]['phone'],
          price: maps[i]['price'],
          latitude: maps[i]['lat'],
          longitude: maps[i]['long'],
          distance: maps[i]['distance'],
          alias: maps[i]['alias'],
          reviewCount: maps[i]['reviewCount'],
          url: maps[i]['url'],
          imageUrl: maps[i]['imageURL'],
          address1: maps[i]['address1'],
          address2: maps[i]['address2'],
          address3: maps[i]['address3'],
          city: maps[i]['city'],
          state: maps[i]['state'],
          country: maps[i]['country'],
          zip: maps[i]['zip']
      );
    },
  );
}

Future<void> updateProduct(Restaurants restaurant) async {
  // Get a reference to the database.
  final db = await database;

  // Update the given Product.
  await db.update(
    restaurantTable,
    restaurant.toMap(),
    // Ensure that the Product has a matching id.
    where: "id = ?",
    // Pass the Products's id as a whereArg to prevent SQL injection.
    whereArgs: [restaurant.id],
  );
}

Future<void> deleteRecent(int id) async {
  // Get a reference to the database.
  final db = await database;

  // Remove the Product from the database.
  await db.delete(
    restaurantTable,
    // Use a `where` clause to delete a specific product.
    where: "id = ?",
    // Pass the Products's id as a whereArg to prevent SQL injection.
    whereArgs: [id],
  );
}


class Restaurants {
  final num rating;
  final String price;
  final String phone;
  final String id;
  final String name;

  final num latitude;
  final num longitude;
  final num distance;

  final String alias;
  final bool isClosed;
  final int reviewCount;

  final String url;
  final String imageUrl;

  final String address1;
  final String address2;
  final String address3;
  final String city;
  final String state;
  final String country;
  final String zip;

  Restaurants(
      {this.rating,
        this.price,
        this.phone,
        this.id,
        this.name,
        this.latitude,
        this.longitude,
        this.distance,
        this.alias,
        this.isClosed,
        this.reviewCount,
        this.url,
        this.imageUrl,
        this.address1,
        this.address2,
        this.address3,
        this.city,
        this.state,
        this.country,
        this.zip});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rating': rating,
      'phone': phone,
      'price': price ?? "n",
      'lat': latitude,
      'long': longitude,
      'distance': distance,
      'alias': alias,
      'reviewCount': reviewCount,
      'url': url,
      'imageURL': imageUrl,
      'address1': address1,
      'address2': address2?? "n",
      'address3': address3?? "n",
      'city': city,
      'state': state,
      'country': country,
      'zip': zip
    };
  }

  factory Restaurants.fromJson(Map<String, dynamic> json) {
    return Restaurants(
      rating: json['rating'],
      price: json['price'],
      phone: json['phone'],
      id: json['id'],
      name: json['name'],
      latitude: json['coordinates']['latitude'],
      longitude: json['coordinates']['longitude'],
      distance: json['distance'],
      alias: json['alias'],
      isClosed: json['is_closed'],
      reviewCount: json['review_count'],
      url: json['url'],
      imageUrl: json['image_url'],
      address1: json['location']['address1'],
      address2: json['location']['address2'],
      address3: json['location']['address3'],
      city: json['location']['city'],
      state: json['location']['state'],
      country: json['location']['country'],
      zip: json['location']['zip_code'],
    );
  }
}