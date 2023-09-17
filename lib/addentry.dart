import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:week52/database.dart';
import 'dart:math';
class AddEntry extends StatefulWidget {
  @override
  _AddEntryState createState() => _AddEntryState();
}

class _AddEntryState extends State<AddEntry> {

  bool lightmode=true;
  DateTime dt = DateTime.now();int id;
  Random rnd = Random();
  DatabaseHelper database = DatabaseHelper.instance;
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    lightmode = MediaQuery.of(context).platformBrightness == Brightness.light;
    return SafeArea(
      child: Scaffold(
        backgroundColor: lightmode?Colors.white:null,
        appBar: AppBar(
          backgroundColor: lightmode?Colors.white:Colors.grey[850],
          elevation: 0,
          leading: BackButton(
            color: lightmode?Colors.blueAccent:Colors.white,
            onPressed: (){
              controller.text='';
              Navigator.pop(context,[]);
            },
          ),
          title: Text(
            'Add Entry',
            style: GoogleFonts.quicksand(
              fontSize: 30,
              color: lightmode?Colors.blueAccent:Colors.white,
              fontWeight: FontWeight.bold
            ),
          ),
          titleSpacing: 0,
        ),
        body: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  SizedBox(height: 30,),
                  Center(
                    child: Text(
                      'Time',
                      style: GoogleFonts.quicksand(
                          fontSize: 35,
                          color: Colors.green[400]
                      ),
                    ),
                  ),
                  SizedBox(height: 30,),
                  Center(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dt.hour>=13?(dt.hour-12).toString()+' : ':dt.hour.toString()+' : ',
                          style: GoogleFonts.quicksand(
                              fontSize: 35,
                              color: Colors.pink
                          ),
                        ),
                        Text(
                          dt.minute.toString()+' : ',
                          style: GoogleFonts.quicksand(
                              fontSize: 35,
                              color: Colors.redAccent
                          ),
                        ),
                        Text(
                          dt.second.toString(),
                          style: GoogleFonts.quicksand(
                              fontSize: 35,
                              color: Colors.orange
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          dt.hour>13?'PM':'AM',
                          style: GoogleFonts.quicksand(
                              fontSize: 20,
                              color: lightmode?Colors.blueGrey[800]:Colors.white
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20,),
                  Container(
                    child: TextField(
                      controller: controller,
                      style: GoogleFonts.quicksand(),
                      maxLines: null,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.send),
                        border: OutlineInputBorder(),
                        focusColor: Colors.green[400]
                      ),
                      autofocus: true,
                      cursorHeight: 20,
                    ),
                    margin: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                  ),
                  SizedBox(height: 20,),
                  Center(
                    child: TextButton.icon(
                      label: Text(
                        'Add',
                        style: GoogleFonts.quicksand(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: lightmode?Colors.blueGrey[800]:Colors.white
                        ),
                      ),
                      icon: Icon(Icons.add,color: lightmode?Colors.blueGrey[800]:Colors.white,),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.orangeAccent)
                      ),
                      onPressed: ()async{
                        String text = controller.text;
                        if(text.length==0){
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                              'Entry cannot be empty!',
                              style: GoogleFonts.quicksand(),
                            ),
                            duration: Duration(seconds: 3),
                          )
                          );
                        }
                        else{
                          id=int.parse(rnd.nextInt(10000).toString()+dt.hour.toString()+dt.minute.toString());
                          String date = dt.toString().substring(0,19);
                          await database.addEntry(id, date, text);
                          Navigator.pop(context,[id,date,text]);
                        }
                      },
                    ),
                  )
                ]
              ),
            )
          ],
        ),
      ),
    );
  }
}
