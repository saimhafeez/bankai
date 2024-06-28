String formatCardNumber(String cardNumber) {
  StringBuffer formattedNumber = StringBuffer();
  for (int i = 0; i < cardNumber.length; i++) {
    if (i > 0 && i % 4 == 0) {
      formattedNumber.write(' '); // Add a space after every 4 characters
    }
    formattedNumber.write(cardNumber[i]);
  }
  return formattedNumber.toString();
}

String formatDate(String originalDate) {
  // Parsing the original date string into a DateTime object
  DateTime dateTime = DateTime.parse(originalDate);

  // Extracting month and year from the DateTime object
  int month = dateTime.month;
  int year =
      dateTime.year % 100; // Extracting the last two digits of the year

  // Formatting the date into mm/yy format
  String formattedDate = '$month/${year.toString().padLeft(2, '0')}';

  return formattedDate;
}