import 'package:flutter/material.dart';
import 'package:smart_home/pages/details_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

final Color bgColor = Color(0xFF100d30);
final Color whiteColor = Colors.white;
final Color accentColor = Color(0xFFff5102);

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,

      floatingActionButton: FloatingActionButton(
        backgroundColor: accentColor,
        child: Icon(Icons.details, color: whiteColor,),
        onPressed: (){
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context){
                return DetailsPage();
              }
            )
          );
        },
      ),

    );
  }
}
