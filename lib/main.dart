import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Danh sach san pham',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomeSreen(),
      //ProductListScreen(),
    );
  }
}
class HomeSreen extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Trang chủ"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> ProductListScreen()),);
          },
          child: Text('Go to ProductListSreen'),
        ),
      ),
    );
  }
}
class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}
class _ProductListScreenState extends State<ProductListScreen>{
  late List<Product> products;
  @override
  void initState(){
    super.initState();
    products=[];
    fetchProducts();
  }
  //convert tu mang sang list
  List<Product> converMapToProductList(Map<String,dynamic> data){
    List<Product> productList=[];
    data.forEach((key, value) {
      for( int i=0; i<value.length; i++)
        {
          Product product=Product(
              search_image: value[i]['search_image'] ?? '',
              styleid: value[i]['styleid']?? 0,
              brands_filter_facet: value[i]['brands_filter_facet']??'',
              price: value[i]['price'] ?? '',
              product_additional_info: value[i]['product_additional_info']??'');
          productList.add(product);
        }
    });
    return productList;
  }
  //--
  Future<void> fetchProducts() async {
    final response = await http.get(
        Uri.parse("http://192.168.0.104/aserver/api.php"));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        products = converMapToProductList(data);
      });
    }
    else {
      throw Exception("Khong load duoc du lieu ");
    }
  }
  //--
@override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sach san pham'),
      ),
      body: products != null?
        ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index){
              return ListTile(
                title: Text(products[index].brands_filter_facet),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Price: ${products[index].price}'),
                    Text('product_additional_info: ${products[index].product_additional_info}'),
                  ],
                ),
                leading: Image.network(
                  products[index].search_image,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                onTap: (){
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context)=> ProductDetailScreen(products[index], products),
                      ),
                  );
                },
              );
            },
        )
        : Center(
          child: CircularProgressIndicator(),
      ),
    );
  }
}
class ProductDetailScreen extends StatelessWidget {
  final Product product;
  final List<Product> products;
  ProductDetailScreen(this.product, this.products);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Detail'),
        actions: [
          ElevatedButton(
            onPressed: () {
              cartManager.addItem(CartItem(styleid: product.styleid, price: product.price));
              Navigator.push(context,
              MaterialPageRoute(
                  builder: (context)=> CartScreen(cartManager,products),
              ),
              );
          },
          child: Icon(Icons.shopping_cart),
          style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              padding: EdgeInsets.all(0)
          ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.all(8),
          child: Text('Brand: ${product.brands_filter_facet}'),
          ),
          Image.network(product.search_image),
          Padding(padding: const EdgeInsets.all(8),
            child: Text('Info: ${product.product_additional_info}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(padding: const EdgeInsets.all(8),
            child: Text('ID: ${product.styleid}'),
          ),
          Padding(padding: const EdgeInsets.all(8),
          child: Text('Price: ${product.price}'),)
        ],
      ),
    );
  }
}
class CartManager {
  List<CartItem> items = [];

  void addItem(CartItem item) {
    items.add(item);
  }
  int get itemCount => items.length;
  double get total => items.fold(0, (sum, item) => sum + double.parse(item.price));
}
final cartManager = CartManager();

class CartScreen extends StatelessWidget {
  final CartManager cartManager;
  final List<Product> products;
  CartScreen(this.cartManager, this.products);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Shopping Cart"),
      ),
      body: ListView.builder(
        itemCount: cartManager.itemCount,
        itemBuilder: (context, index) {
          final cartItem = cartManager.items[index];
          return ListTile(
              title: Text(products[index].brands_filter_facet),
          subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text('Price: ${products[index].price}'),
          Text('product_additional_info: ${products[index].product_additional_info}'),
          ],
          ),
          );
        },
      ),
    );
  }
}

class CartItem {
  String styleid;
  String price;
  CartItem({
    required this.styleid,
    required this.price,
  });
}
String getProductName(String styleId, List<Product> products) {
  // Tìm kiếm sản phẩm theo styleId
  Product? product = products.firstWhere((product) => product.styleid == styleId);

  // Nếu tìm thấy sản phẩm, trả về tên sản phẩm; nếu không, trả về "Unknown"
  return product != null ? product.product_additional_info : 'Unknown';
}


//---
class Product {
  String search_image;
  String styleid;
  String brands_filter_facet;
  String price;
  String product_additional_info;

  Product({
    required this.search_image,
    required this.styleid,
    required this.brands_filter_facet,
    required this.price,
    required this.product_additional_info
  });
}

