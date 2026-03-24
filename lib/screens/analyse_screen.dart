import 'package:flutter/material.dart';
import 'profile_screen.dart';

class AnalyseScreen extends StatefulWidget {
  const AnalyseScreen({Key? key}) : super(key: key);

  @override
  State<AnalyseScreen> createState() => _AnalyseScreenState();
}

const listAnalyse = ['pH', 'Chlore', 'TAC', 'Stabilisant', 'Température'];

Widget _buildListAnalyse(String title) {
  return Container(
    padding: EdgeInsets.all(16),
    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.transparent,
      border: Border.all(
        color: const Color.fromARGB(255, 158, 129, 127),
        width: 1,
      ),
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
    child: Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    ),
  );
}

class _AnalyseScreenState extends State<AnalyseScreen> {
  late List<bool> buttonSelected = [true, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Analyse de l\'eau',
          style: TextStyle(color: Colors.yellow),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.yellow),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundImage: AssetImage("assets/icon.png"),
              radius: 16,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 20),
            Row(
              children: [
                SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonSelected[0]
                          ? Colors.amber
                          : Colors.black,
                      foregroundColor: buttonSelected[0]
                          ? Colors.black
                          : Colors.amber,
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(0),
                          bottomRight: Radius.circular(0),
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        buttonSelected[0] = true;
                        buttonSelected[1] = false;
                      });
                    },
                    child: const Text("Saisir les valeurs"),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonSelected[1]
                          ? Colors.amber
                          : Colors.black,
                      foregroundColor: buttonSelected[1]
                          ? Colors.black
                          : Colors.amber,
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                          topLeft: Radius.circular(0),
                          bottomLeft: Radius.circular(0),
                        ),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        buttonSelected[0] = false;
                        buttonSelected[1] = true;
                      });
                    },
                    child: const Text("Photo bandelette"),
                  ),
                ),
                SizedBox(width: 20),
              ],
            ),
            SizedBox(height: 50,),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: listAnalyse
                    .map((item) => _buildListAnalyse(item))
                    .toList(),
              ),
            ),

            ElevatedButton(
              onPressed: () {},
              child: Text('Analyser', style: TextStyle(color: Colors.white, fontSize: 20)),
              style: ElevatedButton.styleFrom(
                backgroundColor:  Colors.amber,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 16)
              ),
            ),

            SizedBox(height: 120,)
          ],
        ),
      ),
    );
  }
}
