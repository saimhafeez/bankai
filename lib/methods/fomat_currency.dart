import 'package:intl/intl.dart';

formatCurrency(value){
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  return oCcy.format(value);
}