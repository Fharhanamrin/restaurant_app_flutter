import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app_flutter/data/models/restaurant.dart';
import 'package:restaurant_app_flutter/ui/widgets/restaurant_card.dart';

void main() {
  const restaurant = Restaurant(
    id: '1',
    name: 'Restoran Test',
    description: 'Deskripsi test',
    pictureId: 'pic-test',
    city: 'Jakarta',
    rating: 4.5,
  );

  testWidgets('RestaurantCard menampilkan nama, kota, dan rating restoran', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RestaurantCard(restaurant: restaurant, onTap: () {}),
        ),
      ),
    );

    expect(find.text('Restoran Test'), findsOneWidget);
    expect(find.text('Jakarta'), findsOneWidget);
    expect(find.text('4.5'), findsOneWidget);
  });

  testWidgets('RestaurantCard memanggil onTap saat ditekan', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RestaurantCard(
            restaurant: restaurant,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(RestaurantCard));
    expect(tapped, isTrue);
  });
}
