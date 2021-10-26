import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:subhasinghe/models/productModel.dart';

class DBHelper {
  static Database _db;

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "tdj.db");
    
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    // When creating the db, create the table
    try {
      await db.execute(
          "CREATE TABLE Product(id INTEGER PRIMARY KEY AUTOINCREMENT, categoryName Text, productName TEXT, price Double, salePrice DOUBLE, qty INTEGER)");
      await db.execute(
          "CREATE TABLE Cart(id INTEGER PRIMARY KEY AUTOINCREMENT, productName TEXT, price Double, salePrice Double, qty INTEGER)");
      await db.execute("CREATE TABLE Category(categoryName TEXT PRIMARY KEY)");
      await db.execute(
          "CREATE TABLE Orders(orderID INTEGER PRIMARY KEY AUTOINCREMENT, time DATETIME DEFAULT (strftime('%Y-%m-%d %H:%M', 'now', 'localtime')), total Double, profit Double)");
      await db.execute(
          "CREATE TABLE OrderItem(orderID INTEGER , id INTEGER, productName TEXT, qty INTEGER, price Double, salePrice Double, PRIMARY KEY (id, orderID))");
      await db.execute("INSERT INTO Category(categoryName) VALUES('All')");
    } catch (e) {
      print(e);
    }
  }

void updateSale() async{
  var dbClient = await db;
  try{
    await dbClient.execute("ALTER TABLE Product ADD salePrice DOUBLE");
  }catch(e){

  }
}

  void saveProduct(
    Product product,
  ) async {
    var dbClient = await db;

    try {
      await dbClient.transaction((txn) async {
        return await txn.rawInsert(
            "INSERT INTO Product(productName, categoryName, price, salePrice, qty) VALUES('${product.name}', '${product.category}', '${product.price}', '${product.salePrice}','${product.qty}')");
      });
    } catch (e) {
      print(e);
    }
  }

  Future<int> addOrder(
    List<OrderProduct> orderProduct,
    double total,
    double profit,
  ) async {
    var dbClient = await db;
    int orderID;
    print("addOdr");
    try {
      orderID = await dbClient.transaction((txn) async {
        return await txn.rawInsert(
            "INSERT INTO Orders(total, profit) VALUES('$total', '$profit')");
      });
      addOrderItem(orderProduct, orderID);
    } catch (e) {
      print(e);
    }
    return orderID;
  }

  void addOrderItem(List<OrderProduct> orderProduct, int orderID) async {
    var dbClient = await db;

    try {
      for (int i = 0; i < orderProduct.length; i++) {
        await dbClient.transaction((txn) async {
          return await txn.rawInsert(
              "INSERT INTO OrderItem(orderID, id, productName, price, qty, salePrice) VALUES('$orderID', '${orderProduct[i].productID}', '${orderProduct[i].name}', '${orderProduct[i].price}', '${orderProduct[i].qty}', '${orderProduct[i].salePrice}')");
        });
        updateProductQty(orderProduct[i].productID, orderProduct[i].qty);
      }
    } catch (e) {
      print(e);
    }
  }

  void adCategory(String categoryName) async {
    var dbClient = await db;

    try {
      await dbClient.transaction((txn) async {
        return await txn.rawInsert(
            "INSERT INTO Category(categoryName) VALUES('$categoryName')");
      });
      await dbClient.transaction((txn) async {
        return await txn.rawInsert(
            "UPDATE Product SET categoryName = 'null' WHERE categoryName = '$categoryName'");
      });
    } catch (e) {
      print(e);
    }
  }

  void deleteAllProduct() async {
    var dbClient = await db;
    try {
      await dbClient.execute("DELETE FROM Product");
    } catch (e) {
      print(e);
    }
  }

  void deleteProduct(int id) async {
    var dbClient = await db;
    try {
      await dbClient.execute("DELETE FROM Product WHERE id = '$id'");
    } catch (e) {
      print(e);
    }
  }

  void deleteCategory(String category) async {
    var dbClient = await db;
    try {
      await dbClient
          .execute("DELETE FROM Category WHERE categoryName = '$category'");
    } catch (e) {
      print(e);
    }
  }

  void deleteCart() async {
    var dbClient = await db;
    try {
      await dbClient.execute("DELETE FROM Cart");
    } catch (e) {
      print(e);
    }
  }

  Future getCartSum() async {
    var dbClient = await db;
    try {
      var data = await dbClient
          .rawQuery("SELECT SUM(salePrice*qty) AS 'sum' FROM CART");
      return data[0]['sum'];
    } catch (e) {
      print(e);
    }
  }

  Future getItemCount() async {
    var dbClient = await db;
    try {
      var data =
          await dbClient.rawQuery("SELECT Count(id) AS 'count' FROM CART");
      return data[0]['count'];
    } catch (e) {
      print(e);
    }
  }

  Future getCartProfit() async {
    var dbClient = await db;
    try {
      var data = await dbClient.rawQuery(
          "SELECT SUM((salePrice - price)*qty) AS 'profit' FROM CART");
      return data[0]['profit'];
    } catch (e) {
      print(e);
    }
  }

  void deleteOrder(int id) async {
    var dbClient = await db;
    try {
      await dbClient.execute("DELETE FROM Orders WHERE orderID = '$id'");
    } catch (e) {
      print(e);
    }
  }

  void updateProduct(Product product) async {
    var dbClient = await db;
    try {
      await dbClient.execute(
          "UPDATE Product SET productName = '${product.name}', categoryName = '${product.category}', qty = '${product.qty}', price = '${product.price}', salePrice = '${product.salePrice}' WHERE id = '${product.productID}'");
    } catch (e) {
      print(e);
    }
  }

  void updateProductQty(int id, int qty) async {
    var dbClient = await db;
    try {
      await dbClient
          .execute("UPDATE Product SET qty = qty- $qty WHERE id = '$id'");
    } catch (e) {
      print(e);
    }
  }

  Future getOrder(String date, bool isAll) async {
    var dbClient = await db;

    var order = await dbClient.rawQuery(isAll
        ? "SELECT * FROM Orders"
        : "SELECT * FROM Orders WHERE time LIKE '$date%'");

    return order;
  }

  Future getCategory() async {
    var dbClient = await db;

    var order = await dbClient.rawQuery("SELECT * FROM Category");
    print(order);
    return order;
  }

  Future getOrderByID(String date, bool isAll, String id) async {
    var dbClient = await db;

    var order = await dbClient.rawQuery(isAll
        ? "SELECT * FROM Orders WHERE orderID = '$id'"
        : "SELECT * FROM Orders WHERE time LIKE '$date%' AND orderID = '$id'");

    return order;
  }

  Future getProfit(String date, bool isAll) async {
    var dbClient = await db;
    var profit = await dbClient.rawQuery(isAll
        ? "SELECT SUM(profit) AS 'profit', SUM(total) AS 'total' FROM Orders"
        : "SELECT SUM(profit) AS 'profit', SUM(total) AS 'total' FROM Orders WHERE time LIKE '$date%'");

    return profit[0];
  }

  Future getProfitByID(String date, bool isAll, String id) async {
    var dbClient = await db;
    var profit = await dbClient.rawQuery(isAll
        ? "SELECT SUM(profit) AS 'profit', SUM(total) AS 'total' FROM Orders WHERE  orderID ='$id'"
        : "SELECT SUM(profit) AS 'profit', SUM(total) AS 'total' FROM Orders WHERE time LIKE '$date%' AND orderID ='$id'");

    return profit[0];
  }

  Future getOrderItem(int orderID) async {
    var dbClient = await db;
    print(orderID);
    var item = await dbClient
        .rawQuery("SELECT * From OrderItem WHERE orderID = '$orderID'");

    return item;
  }

  Future getOrderItemProfit(int orderID) async {
    var dbClient = await db;
    print(orderID);
    var item = await dbClient.rawQuery(
        "SELECT SUM(salePrice*qty) AS 'total', SUM(price*qty) AS 'cost', SUM(salePrice*qty-price*qty) AS 'profit' From OrderItem WHERE orderID = '$orderID'");

    return item[0];
  }

  Future<List<Product>> getProduct() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Product');
    List<Product> product = new List();

    for (int i = 0; i < list.length; i++) {
      product.add(new Product(
          list[i]["id"],
          list[i]["price"],
          list[i]["salePrice"],
          list[i]["productName"].toString(),
          list[i]["categoryName"].toString(),
          list[i]["qty"]));
    }
    return product;
  }

  Future<List<OrderProduct>> getCartProduct() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Cart');
    List<OrderProduct> product = new List();

    for (int i = 0; i < list.length; i++) {
      product.add(new OrderProduct(
          list[i]["id"],
          list[i]["productName"].toString(),
          list[i]["price"],
          list[i]["qty"],
          list[i]["salePrice"]));
    }
    return product;
  }

  Future<bool> addCart(OrderProduct product) async {
    var dbClient = await db;

    try {
      await dbClient.transaction((txn) async {
        return await txn.rawInsert(
            "INSERT INTO Cart(id, productName, price, qty, salePrice) VALUES('${product.productID}', '${product.name}', '${product.price}','${product.qty}','${product.salePrice}')");
      });
      return false;
    } catch (e) {
      await dbClient.execute(
          "UPDATE Cart SET qty = '${product.qty}', salePrice = '${product.salePrice}' WHERE id = '${product.productID}'");
      return true;
    }
  }

  Future<List<Product>> getProductByCategory(String category) async {
    var dbClient = await db;
    List<Map> list = await dbClient
        .rawQuery("SELECT * FROM Product WHERE categoryName = '$category'");
    List<Product> product = new List();

    for (int i = 0; i < list.length; i++) {
      product.add(new Product(
          list[i]["id"],
          list[i]["price"],
          list[i]["salePrice"],
          list[i]["productName"].toString(),
          list[i]["categoryName"].toString(),
          list[i]["qty"]));
    }
    return product;
  }

  Future<List<Product>> searchProduct(String search) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery(
        "SELECT * FROM Product WHERE productName LIKE '%$search%' OR id = '$search'");
    List<Product> product = new List();

    for (int i = 0; i < list.length; i++) {
      product.add(new Product(
          list[i]["id"],
          list[i]["price"],
          list[i]["salePrice"],
          list[i]["productName"].toString(),
          list[i]["categoryName"].toString(),
          list[i]["qty"]));
    }
    return product;
  }
}
