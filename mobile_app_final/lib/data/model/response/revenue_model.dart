class RevenueModel {
  RevenueSummary _revenueSummary;

  RevenueModel({RevenueSummary revenueSummary}) {
    if (revenueSummary != null) {
      this._revenueSummary = revenueSummary;
    }
  }

  RevenueSummary get revenueSummary => _revenueSummary;

  RevenueModel.fromJson(Map<String, dynamic> json) {
    _revenueSummary = json['revenueSummary'] != null
        ? new RevenueSummary.fromJson(json['revenueSummary'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this._revenueSummary != null) {
      data['revenueSummary'] = this._revenueSummary.toJson();
    }
    return data;
  }
}

class RevenueSummary {
  double _totalIncome;
  double _totalExpense;
  double _totalPayable;
  double _totalReceivable;

  RevenueSummary(
      {double totalIncome,
      double totalExpense,
      double totalPayable,
      double totalReceivable}) {
    if (totalIncome != null) {
      this._totalIncome = totalIncome;
    }
    if (totalExpense != null) {
      this._totalExpense = totalExpense;
    }
    if (totalPayable != null) {
      this._totalPayable = totalPayable;
    }
    if (totalReceivable != null) {
      this._totalReceivable = totalReceivable;
    }
  }

  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;
  double get totalPayable => _totalPayable;
  double get totalReceivable => _totalReceivable;

  RevenueSummary.fromJson(Map<String, dynamic> json) {
    _totalIncome = double.parse(json['totalIncome'].toString());
    _totalExpense = double.parse(json['totalExpense'].toString());
    _totalPayable = double.parse(json['totalPayable'].toString());
    _totalReceivable = double.parse(json['totalReceivable'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalIncome'] = this._totalIncome;
    data['totalExpense'] = this._totalExpense;
    data['totalPayable'] = this._totalPayable;
    data['totalReceivable'] = this._totalReceivable;
    return data;
  }
}
