class Product {
  int productID;
  String name;
  String category;
  double price;
  double salePrice;
  int qty;

  Product(
    this.productID,
    this.price,
    this.salePrice,
    this.name,
    this.category,
    this.qty,
  );

  Product.fromMap(Map map) {
    productID = int.parse(map['productID']);

    price = double.parse(map['price']);
    salePrice = double.parse(map['salePrice']);
    qty = int.parse(map['qty']);
    name = map['name'];
    category = map['categoryName'];
  }
}

class OrderProduct {
  int productID;
  String name;
  double price, salePrice;
  int qty;

  OrderProduct(this.productID, this.name, this.price, this.qty, this.salePrice);
}
