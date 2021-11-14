import 'package:gsheets/gsheets.dart';

class GoogleSheetsApi {
  // create credentials
  static const _credentials = r'''
  {
    "type": "service_account",
    "project_id": "expense-tracker-331823",
    "private_key_id": "7aaf4def921f268d99b57e418870b7f05afa336b",
    "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCSdfE4BJ9sZ7i8\nSDWfORLvlBIdWWKslVOIFPDc+1fJiIO/Mx1cWm/86kXxgwuvd4+Ss3rCXqQkDLde\nfdvexaQe2vqo7TG+Sqhfg37JBRe/x96Cc+J5olyLs9s0SEGuKWLBRLiNDUJFeFOz\ncBqL/BNWS9MtB722YGeMoPqcGFXz/joUNnxlr4/4jxKNEbSh/H4U3FyeIIDXcJdj\nA8ICNsS7GfTseYt/kw7nfIiOiQoWKBGVUrRRgn27dx56psO9W1coItlgvh9WU1CA\n5Ldaw6zD8IlWL7E/J/joEVzbGDIyLHlCFcFp1LcvPX77mlqO7sPKG3HdD1zHwnvG\nEmdZvKj1AgMBAAECggEANCsusPV0k/ieJPLTptN9mzjy+uFL9I18I4zR/uTIcFDg\nHMroOm08VqpcH5q+HtJHocmsgG+VqAGfj1jlaISd4R+/CUzz2wRc1SjRkGjv/LAE\n4hLFKO5caKa3/fd+7bpwIseHtTZz1Kr3pYLY8ePoP2Ti47dOLBhKyhzNJ6zDcRUj\nIUFWlDSOFUHT4uBPXtkOiY/52WrovFMXMV2oxYM1dNrsxKqoJM1W26aLEbS8Pd2v\n/rEPetZ2FMtr5V3eIGYk8vdjXMN49UzAN4U5wu+NT/otTtVLUjlrC+pHdNT+BQMx\nW9bJQmO9uWlOgKv7Ka2nFyoUj+Tip8YLDQc77yfkQQKBgQDLCyuqTn6L6M0V98Bh\n0zlo7x9XsjvpoV920GNzZjXxdNwlvEllVxilubtUWiK36hrsjOvCXl2UD5YkUFu4\nG5QOE1PTKq0VAKE74EZlWfJ2JZf4Lg33lLNT9YkfSP+IE6OFP9gRo6EHiDmwEgmv\n1BvJpZ9vM6HmDQnekQeHQD2nmwKBgQC4qNb5KHCvB6/9O8kjyvwi+vEYHoypB3CK\nU+7NnAwcLawoU+aqSZSaNa3UT8YlZowHEYO9tPcbYR2BFlvZ/roRLysSn57AXmf5\njzAdoDXtGtehuhaPTAE4Rwv52hMxpGZRMKY02YkinJXhwL4oTIlzKK7EFnY1fnEr\neUW7iIWirwKBgQCe3S2cAfB3bX3RW1h18ftwQ/AlAHpqEO4Nm3zElMtOEZ4SFGDk\n3qGVQV314NRbS9snDBeGq6jSKOPTo+Avi7xqyuqCRVjJHwYIQDE0KY1QrZdbAkXB\nWeJ5pZpVFRuCD8OYhVx8aKecqhRg06wqm23mdyTor+BTjA4Vyym1xCi5UwKBgE+e\nNLpPDm7ZMK9N9MajAZ2Pdx5AJcPHemWaFM/AJZSMuLrWmhD4EsN+u4lcMAH2Og/e\nJGBKQ3UhpVgALPBMHSvFm5u3CPrGeawnacaMSlQGC80mcA2u5qO+NlKvDTGNQbRl\n9nO5C6DJxPIGabb0cRsfAmN3j9Y2w1LMQh2+mmfvAoGAGtc87CTsnALb5PyNcwDD\n+r9qpi3AMHtuoEG0Ud71sBwI+zl2nYDLEkfhK8+nCdJ4bEx5tcHND6mhv3YdXAX8\nMx9+6BZEdVdokQEjVpKNOVkWJLIdoMFapIT7P9jkP57qhnhGceetx5IaHicQmexF\nCqNeEPYVT38gntLnD6xYOnE=\n-----END PRIVATE KEY-----\n",
    "client_email": "expense-tracker@expense-tracker-331823.iam.gserviceaccount.com",
    "client_id": "109066685954536665737",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/expense-tracker%40expense-tracker-331823.iam.gserviceaccount.com"
  }
  ''';

  // set up & connect to the spreadsheet
  static final _spreadsheetId = '1rGfe6yrwaGyXlMGn0pqNoh54a9S02OPlmqo4ykYSYtI';
  static final _gsheets = GSheets(_credentials);
  static Worksheet? _worksheet;

  // some variables to keep track of..
  static int numberOfTransactions = 0;
  static List<List<dynamic>> currentTransactions = [];
  static bool loading = true;

  // initialise the spreadsheet!
  Future init() async {
    final ss = await _gsheets.spreadsheet(_spreadsheetId);
    _worksheet = ss.worksheetByTitle('expense_tracker');
    countRows();
  }

  // count the number of notes
  static Future countRows() async {
    while ((await _worksheet!.values
            .value(column: 1, row: numberOfTransactions + 1)) !=
        '') {
      numberOfTransactions++;
    }
    // now we know how many notes to load, now let's load them!
    loadTransactions();
  }

  // load existing notes from the spreadsheet
  static Future loadTransactions() async {
    if (_worksheet == null) return;

    for (int i = 1; i < numberOfTransactions; i++) {
      final String transactionName =
          await _worksheet!.values.value(column: 1, row: i + 1);
      final String transactionAmount =
          await _worksheet!.values.value(column: 2, row: i + 1);
      final String transactionType =
          await _worksheet!.values.value(column: 3, row: i + 1);

      if (currentTransactions.length < numberOfTransactions) {
        currentTransactions.add([
          transactionName,
          transactionAmount,
          transactionType,
        ]);
      }
    }
    print(currentTransactions);
    // this will stop the circular loading indicator
    loading = false;
  }

  // insert a new transaction
  static Future insert(String name, String amount, bool _isIncome) async {
    if (_worksheet == null) return;
    numberOfTransactions++;
    currentTransactions.add([
      name,
      amount,
      _isIncome == true ? 'income' : 'expense',
    ]);
    await _worksheet!.values.appendRow([
      name,
      amount,
      _isIncome == true ? 'income' : 'expense',
    ]);
  }

  // total income calculation
  static double calculateIncome() {
    double totalIncome = 0;
    for (int i = 0; i < currentTransactions.length; i++) {
      if (currentTransactions[i][2] == 'income') {
        totalIncome += double.parse(currentTransactions[i][1]);
      }
    }
    return totalIncome;
  }

  // total expense calculation
  static double calculateExpense() {
    double totalExpense = 0;
    for (int i = 0; i < currentTransactions.length; i++) {
      if (currentTransactions[i][2] == 'expense') {
        totalExpense += double.parse(currentTransactions[i][1]);
      }
    }
    return totalExpense;
  }
}
