import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:week52/database.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  bool lightmode=true;
  DateTime searchdt ;
  dynamic history=[],number={};
  DatabaseHelper database = DatabaseHelper.instance;
  List month = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  Future<void> searchDate()async{
    dynamic temp =await database.getTodayStatus(searchdt.day, searchdt.year, searchdt.month);
    if(temp.length==0){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Oops! No history found for ${searchdt.day} ${month[searchdt.month]} ${searchdt.year}',
          style:GoogleFonts.quicksand(),
        ),
        duration: Duration(seconds: 3),
      ));
    }
    else{
      Navigator.pushNamed(context, '/logdisplay',arguments: {'id':temp[0]['id'],'date':temp[0]['date']});
    }
  }

  Future<void> initData()async{
    history=[];number={};DateTime td=DateTime.parse(DateTime.now().toString().substring(0,10));
    dynamic temp=await database.getHistory();
    for(int i=0;i<temp.length;i++){
      dynamic e = temp[i];
      if(td.isAfter(DateTime.parse(e['date'])) || td.compareTo(DateTime.parse(e['date']))==0) {
        history.add(e);
        dynamic c = await database.getLogs(e['id']);
        number[e['date'].toString()] = c.length;
      }
    }
    this.setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async{ await initData();});
  }


  @override
  Widget build(BuildContext context) {
    lightmode = MediaQuery.of(context).platformBrightness==Brightness.light;
    return SafeArea(
      child: Scaffold(
        backgroundColor: lightmode?Colors.white:null,
        appBar: AppBar(
          backgroundColor: lightmode?Colors.white:Colors.grey[850],
          leading: BackButton(
            color: lightmode?Colors.blueAccent:Colors.white,
          ),
          title: Text(
            'History',
            style: GoogleFonts.quicksand(
              fontSize: 30,
              color: lightmode?Colors.blueAccent:Colors.white
            ),
          ),
          titleSpacing: 0,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(
                Icons.refresh_sharp,
                size: 30,
                color: lightmode?Colors.blueAccent:Colors.white,
              ),
              onPressed: (){initData();},
            )
          ],
        ),
        body: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextButton(
                        child: Text(
                          'Pick date',
                          style: GoogleFonts.quicksand(
                              color: Colors.white,
                            fontSize: 20
                          ),
                        ),
                        onPressed: showDate,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.redAccent)
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            searchdt!=null?searchdt.day.toString():'--',
                            style: GoogleFonts.quicksand(
                              fontSize: 30,
                              color: lightmode?Colors.blueGrey[800]:Colors.white
                            ),
                          ),
                          SizedBox(width: 10,),
                          Text(
                            searchdt!=null?month[searchdt.month]:'--',
                            style: GoogleFonts.quicksand(
                                fontSize: 30,
                                color: lightmode?Colors.blueGrey[800]:Colors.white
                            ),
                          ),
                          SizedBox(width: 10,),
                          Text(
                            searchdt!=null?searchdt.year.toString():'--',
                            style: GoogleFonts.quicksand(
                                fontSize: 30,
                                color: lightmode?Colors.blueGrey[800]:Colors.white
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        icon: Icon(Icons.search,color: Colors.white,),
                        label: Text(
                            'Search',
                          style: GoogleFonts.quicksand(
                            color: Colors.white,
                            fontSize: 20
                          ),
                        ),
                        onPressed: searchDate,
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20,),
                ]
              ),
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                  (BuildContext context,int index){
                    return historBuilder(index);
                  },
                childCount: history.length
              ),
            )
          ],
        ),
      ),
    );
  }
  void showDate(){
    DatePicker.showDatePicker(context,
        minTime: DateTime.now(),
        maxTime: DateTime(2030),
        onConfirm: (date){
          this.setState(() {
            this.searchdt=date;
          });
        }
    );
  }


  Container historBuilder(int index){
    String date=history[index]['date'];
    date = date.substring(8,10)+' '+month[int.parse(date.substring(5,7))]+' '+date.substring(0,4);
    return Container(
      child: ListTile(
        leading: Icon(
          Icons.calendar_today_sharp,
          color: lightmode?Colors.white:Colors.blueGrey[800],
        ),
        title: Text(
          date+'\n'+history[index]['description'],
          style: GoogleFonts.quicksand(
              fontSize: 20,
              color: lightmode?Colors.white:Colors.blueGrey[800]
          ),
        ),
        subtitle: Text(
          'Tap to view',
          style: GoogleFonts.quicksand(
            fontSize: 17,
            color: lightmode?Colors.white:Colors.blueGrey[800]
          ),
        ),
        onTap: (){Navigator.pushNamed(context, '/logdisplay',arguments: {'id':history[index]['id'],'date':history[index]['date']});},
        trailing: Text(
          number[history[index]['date']].toString(),
          style: GoogleFonts.quicksand(
              fontSize: 17,
              color: lightmode?Colors.white:Colors.blueGrey[800]
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 10,horizontal:0),
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: lightmode?Colors.deepPurpleAccent[100]:Colors.purple[50],
      ),
    );
  }
}

