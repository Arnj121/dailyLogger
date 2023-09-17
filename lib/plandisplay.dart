import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:week52/database.dart';
import 'dart:math';
class Planner extends StatefulWidget {
  @override
  _PlannerState createState() => _PlannerState();
}

class _PlannerState extends State<Planner> {

  bool lightmode=true;
  dynamic planned=[];Map<String,int> number={};
  DatabaseHelper database = DatabaseHelper.instance;
  List month = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  DateTime dt,today=DateTime.parse(DateTime.now().toString().substring(0,10));
  Future<void> initData()async{
    planned=[];
    dynamic temp = await database.getPlanned();
    for(int i=0;i<temp.length;i++){
      dynamic e=temp[i];
      dt = DateTime.parse(e['date']);
      if(today.isBefore(dt) || today.compareTo(dt)==0) {
        planned.add(jsonDecode(jsonEncode(e)));
        dynamic count = await database.getPlans(dt.toString().substring(0,10));
        number[dt.toString().substring(0,10)]=count.length;
      }
    }
    this.setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp)async {await initData(); });
  }

  @override
  Widget build(BuildContext context) {
    lightmode = MediaQuery.of(context).platformBrightness ==Brightness.light;
    return SafeArea(
      child: Scaffold(
        backgroundColor: lightmode?Colors.white:null,
        appBar: AppBar(
          backgroundColor: lightmode?Colors.white:Colors.grey[850],
          leading: BackButton(
            color: lightmode?Colors.blueAccent:Colors.white,
          ),
          title: Text(
            'Upcoming Plans',
            style: GoogleFonts.quicksand(
              fontSize: 30,
              color: lightmode?Colors.blueAccent:Colors.white,
            ),
          ),
          titleSpacing: 0,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.add,size: 30,color: Colors.orangeAccent,),
              onPressed: (){
                Navigator.pushNamed(context, '/plan',arguments: {'today':0,'para':0});
              },
            )
          ],
        ),
        body: GestureDetector(
          child: CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    SizedBox(height: 30,),
                  ]
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                    (BuildContext context,int index){
                      return planBuilder(index);
                    },
                  childCount: planned.length
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Container planBuilder(int index){
    String date= planned[index]['date'];
    String type='d', rem='0';
    Duration diff =DateTime.parse(date).difference(DateTime.now());
    if(diff.inDays/365>=1) {
      rem = (diff.inDays%365).toString();
      type='y';
    }
    else{
      if(diff.inDays/30>=1){
        rem = (diff.inDays%30).toString();
        type='m';
      }
      else{
        if(diff.inDays==0){
          if(diff.inHours<0) {
            rem = 'now';
            type = '';
          }
          else if(diff.inHours==0){
            if(diff.inMinutes==0){
              rem = diff.inSeconds.toString();
              type='s';
            }
            else{
              rem = diff.inMinutes.toString();
              type='m';
            }
          }
          else{
            rem = diff.inHours.toString();
            type = 'h';
          }
        }
        else {
          rem = diff.inDays.toString();
          type = 'd';
        }
      }
    }
    // print([rem,type,diff.inDays,diff.inHours,diff.inMinutes,diff.inSeconds]);
    return Container(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.transparent,
          child: Text(
            rem+type,
            style: GoogleFonts.quicksand(
                fontSize: 20,
                color: lightmode?Colors.white:Colors.blueGrey[800]
            ),
          ),
        ),
        title: Text(
          date.substring(8,)+' '+month[int.parse(date.substring(5,7))]+' '+date.substring(0,4)+'\n'+planned[index]['description'],
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
        trailing: Text(
          number[date].toString(),
          style: GoogleFonts.quicksand(
              fontSize: 22,
              color: lightmode?Colors.white:Colors.blueGrey[800]
          ),
        ),
        onTap: (){Navigator.pushNamed(context, '/plan',arguments: {'today':diff.inDays==0?1:0,'para':1,'date':date});},
      ),
      margin: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
      padding: EdgeInsets.symmetric(vertical: 10,horizontal:0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: lightmode?Colors.deepPurpleAccent[100]:Colors.purple[50],
      ),
    );
  }
}
