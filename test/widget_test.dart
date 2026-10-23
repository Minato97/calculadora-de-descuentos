import 'package:calc_descuentos/logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('descuentos encadenados e IVA', () {
    final r = applyDiscounts(1000, [20, 10], taxPercent: 16);
    expect(r.afterDiscount, closeTo(720, 1e-9));
    expect(r.tax, closeTo(115.2, 1e-9));
    expect(r.total, closeTo(835.2, 1e-9));
    expect(r.saved, closeTo(280, 1e-9));
    expect(r.savedPercent, closeTo(28, 1e-9));
  });

  test('descuento combinado', () {
    expect(combinedDiscount([20, 10]), closeTo(28, 1e-9));
    expect(combinedDiscount([]), 0);
    expect(combinedDiscount([100, 50]), 100);
  });

  test('mejor oferta', () {
    expect(bestOffer([45, 78, 120], [500, 1000, 1800]), 2);
    expect(bestOffer([10, 0], [1, 0]), 0);
    expect(bestOffer([], []), -1);
  });

  test('formato', () {
    expect(money(1234.5), '\$1,234.50');
    expect(parseNumber('1,000.5'), 1000.5);
    expect(parseNumber('x'), 0);
  });
}
