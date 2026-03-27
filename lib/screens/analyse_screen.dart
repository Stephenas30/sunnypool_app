import 'package:flutter/material.dart';
import 'profile_screen.dart';

class AnalyseScreen extends StatefulWidget {
  const AnalyseScreen({Key? key}) : super(key: key);

  @override
  State<AnalyseScreen> createState() => _AnalyseScreenState();
}

const listAnalyse = ['pH', 'Chlore', 'TAC', 'Stabilisant', 'Température'];
String analyseChecked = 'pH';


class _AnalyseScreenState extends State<AnalyseScreen> {
  late List<bool> buttonSelected = [true, false];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
        centerTitle: true,
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
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: screenWidth * 0.08),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            spacing: 20,
            children: [
              Row(
                children: [
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
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          ),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          buttonSelected[0] = true;
                          buttonSelected[1] = false;
                        });
                      },
                      child: Text("Saisir les valeurs", style: TextStyle(fontSize: screenWidth * 0.035), textAlign: TextAlign.end,),
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
                            topRight: Radius.circular(20),
                            bottomRight: Radius.circular(20),
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
                      child: Text("Photo bandelette", style: TextStyle(fontSize: screenWidth * 0.035)),
                    ),
                  ),
                ],
              ),
              ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                
                children: listAnalyse
                    .map((item) => _buildListAnalyse(item))
                    .toList(),
              ),
              ElevatedButton(
                onPressed: () {},
                child: Text(
                  'Analyser',
                  style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.03),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.1,
                    vertical: screenHeight * 0.01,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListAnalyse(String title) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
  return ElevatedButton(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(
        analyseChecked.contains(title) ? Colors.amber : Colors.transparent,
      ),
      foregroundColor: WidgetStateProperty.all(Colors.white),
    ),
    onPressed: () {
      setState(() {
        if (!analyseChecked.contains(title)) {
          analyseChecked = title;
        } else {
          analyseChecked = title;
        }
      });
    },
    child: Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontSize: screenWidth * 0.05,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    ),
  );
}
}
