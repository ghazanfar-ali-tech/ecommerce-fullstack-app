enum SortOption {
  newest,
  oldest,
  priceLowToHigh,
  priceHighToLow,
  nameAZ,
  nameZA,
  highestDiscount,
}

extension SortOptionExtension on SortOption {
  String get label {
    switch (this) {
      case SortOption.newest:
        return 'Newest First';
      case SortOption.oldest:
        return 'Oldest First';
      case SortOption.priceLowToHigh:
        return 'Price: Low to High';
      case SortOption.priceHighToLow:
        return 'Price: High to Low';
      case SortOption.nameAZ:
        return 'Name: A → Z';
      case SortOption.nameZA:
        return 'Name: Z → A';
      case SortOption.highestDiscount:
        return 'Highest Discount';
    }
  }
}

enum ViewMode { grid, list }