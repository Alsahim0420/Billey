/// Methods widely used throughout the global app.
class Utils {
  static final Utils _singleton = Utils._();

  factory Utils() {
    return _singleton;
  }
  Utils._();

  // ///returns: number formatted in [String] if @params [currency] is not null.
  // String valueCurrency(dynamic currency) {
  //   try {
  //     if (currency != null) {
  //       final NumberFormat f = NumberFormat("#,##0.00");
  //       String formatted = f.format(currency);
  //       return '\$ $formatted';
  //     }
  //     return '\$ 0.00';
  //   } catch (e) {
  //     return '\$ 0.00';
  //   }
  // }

  String capitalize(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

  String getmonthsbyNumber(
    int value,
  ) {
    switch (value) {
      case 1:
        return "Enero";
      case 2:
        return "Febrero";
      case 3:
        return "Marzo";
      case 4:
        return "Abril";
      case 5:
        return "Mayo";
      case 6:
        return "Junio";
      case 7:
        return "Julio";
      case 8:
        return "Agosto";
      case 9:
        return "Septiembre";
      case 10:
        return "Octubre";
      case 11:
        return "Noviembre";
      case 12:
        return "Diciembre";
    }
    return '';
  }
}
