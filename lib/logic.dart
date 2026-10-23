/// Precio final tras aplicar descuentos encadenados (en %) e IVA opcional.
class DiscountResult {
  const DiscountResult(this.original, this.afterDiscount, this.tax, this.total);

  final double original;
  final double afterDiscount;
  final double tax;
  final double total;

  double get saved => original - afterDiscount;
  double get savedPercent => original == 0 ? 0 : saved / original * 100;
}

DiscountResult applyDiscounts(
  double price,
  List<double> discounts, {
  double taxPercent = 0,
}) {
  var p = price;
  for (final d in discounts) {
    p = p * (1 - d.clamp(0, 100) / 100);
  }
  final tax = p * taxPercent / 100;
  return DiscountResult(price, p, tax, p + tax);
}

/// Descuento equivalente único de varios descuentos encadenados.
double combinedDiscount(List<double> discounts) {
  var f = 1.0;
  for (final d in discounts) {
    f *= 1 - d.clamp(0, 100) / 100;
  }
  return (1 - f) * 100;
}

/// Precio por unidad (para comparar ofertas de distinto tamaño).
double unitPrice(double price, double quantity) =>
    quantity <= 0 ? double.infinity : price / quantity;

/// Índice de la mejor oferta (menor precio por unidad), o -1 si no hay.
int bestOffer(List<double> prices, List<double> quantities) {
  var best = -1;
  var bestUnit = double.infinity;
  for (var i = 0; i < prices.length; i++) {
    final u = unitPrice(prices[i], quantities[i]);
    if (prices[i] > 0 && u < bestUnit) {
      bestUnit = u;
      best = i;
    }
  }
  return best;
}

String money(double v) {
  final neg = v < 0;
  final s = v.abs().toStringAsFixed(2);
  final parts = s.split('.');
  final i = parts[0]
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  return '${neg ? '-' : ''}\$$i.${parts[1]}';
}

double parseNumber(String s) =>
    double.tryParse(s.replaceAll(',', '').trim()) ?? 0;
