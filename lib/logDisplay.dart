import 'package:flutter/material.dart';
import 'package:week52/database.dart';
import 'package:google_fonts/google_fonts.dart';
class LogDisplay extends StatefulWidget {
  @override
  _LogDisplayState createState() => _LogDisplayState();
}

class _LogDisplayState extends State<LogDisplay> {
  bool lightmode=true;
  DatabaseHelper database = DatabaseHelper.instance;
  dynamic logs = [],tasks=[];int id;String date;String descript='';
  List month = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

  Future<void> initData()async{
    logs=[];tasks=[];
    logs = await database.getLogs(id);
    descript=await database.getDescript(id);
    tasks=await database.getPlans(date);
    this.setState(() {logs=logs;tasks=tasks;});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async{await initData();});
  }

  @override
  Widget build(BuildContext context) {
    lightmode = MediaQuery.of(context).platformBrightness == Brightness.light;
    dynamic temp = ModalRoute.of(context).settings.arguments;
    date = temp['date'];
    id = temp['id'];
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: lightmode?Colors.white:Colors.grey[850],
          elevation: 0,
          title: Text(
            'Logs',
            style: GoogleFonts.quicksand(
                fontSize: 35,
                letterSpacing: 1,
                fontWeight: FontWeight.bold,
                color: lightmode?Colors.blueAccent:Colors.white
            ),
          ),
          leading: BackButton(
            color: lightmode?Colors.blueAccent:Colors.white,
          ),
        ),
        body: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  SizedBox(height: 10,),
                  Center(
                    child: Text(
                      'Logs for',
                      style: GoogleFonts.quicksand(
                        fontSize: 30,
                        color: lightmode?Colors.blueGrey[800]:Colors.white
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  Center(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 30,
                            color: lightmode?Colors.blueGrey[800]:Colors.white,
                          ),
                          SizedBox(width: 10,),
                          Text(
                            date.substring(8,),
                            style: GoogleFonts.quicksand(
                                fontSize: 35,
                                color: Colors.redAccent
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            month[int.parse(date.substring(5,7))-1],
                            style: GoogleFonts.quicksand(
                                fontSize: 35,
                                color: Colors.purpleAccent
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            date.substring(0,4),
                            style: GoogleFonts.quicksand(
                                fontSize: 35,
                                color: Colors.orange
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                  ),
                  SizedBox(height: 20,),
                  Center(
                    child: Container(
                      child: Text(
                        descript,
                        style: GoogleFonts.quicksand(
                          fontSize: 20,
                          color: lightmode?Colors.blueGrey[800]:Colors.white
                        ),
                        softWrap: true,
                      ),
                      margin: EdgeInsets.symmetric(vertical: 0,horizontal: 10),
                    ),
                  ),
                  SizedBox(height: 20,),
                ]
              )
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                  [
                    Visibility(
                      visible: tasks.length==0?false:true,
                      child: Container(
                        child:Text(
                          'Plans',
                          style: GoogleFonts.quicksand(
                            fontSize: 30,
                          ),
                        ),
                        margin: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                      ),
                    )
                  ]
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                      (BuildContext context,int index){
                    return taskBuilder(index);
                  },
                  childCount: tasks.length
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                  [
                    Visibility(
                      visible:true,
                      child: Container(
                        child:Text(
                          'Logs',
                          style: GoogleFonts.quicksand(
                            fontSize: 30,
                          ),
                        ),
                        margin: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                      ),
                    )
                  ]
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Visibility(
                    visible: logs.length==0?true:false,
                    child: Container(
                      child:Center(
                        child: Text(
                          'Nothing logged!',
                          style: GoogleFonts.quicksand(
                            fontSize: 30,
                          ),
                        ),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                    ),
                  )
                ]
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                  (BuildContext context,int index){
                    return LogBuilder(index);
                  },
                childCount: logs.length
              ),
            )
          ],
        ),
      ),
    );
  }
  Container taskBuilder(int index){
    return Container(
      child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.transparent,
            child: Icon(
              Icons.next_plan_sharp,
              color: lightmode?Colors.white:Colors.blueGrey[800],
              size: 40,
            ),
          ),
          title:Text(
            tasks[index]['entry'],
            style: GoogleFonts.quicksand(
                fontSize: 20,
                color: lightmode?Colors.white:Colors.blueGrey[800]
            ),
          ),
          trailing: Icon(
            tasks[index]['accomplished']==1?Icons.check_circle:Icons.cancel,
            size: 30,
            color: tasks[index]['accomplished']==1?Colors.greenAccent[400]:Colors.redAccent,
          )
      ),
      margin: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
      padding: EdgeInsets.symmetric(vertical: 10,horizontal:0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: lightmode?Colors.deepPurpleAccent[100]:Colors.purple[50],
      ),
    );
  }

  Container LogBuilder(int index){
    return Container(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.transparent,
          child: Icon(Icons.note,color: lightmode?Colors.white:Colors.blueGrey[800]),
        ),
        title: Text(
          logs[index]['entry'],
          style: GoogleFonts.quicksand(
            color: lightmode?Colors.white:Colors.blueGrey[800],
            fontSize: 17
          ),
        ),
        trailing: Text(
          logs[index]['datetime'].substring(11,),
          style: GoogleFonts.quicksand(
            color: lightmode?Colors.white:Colors.blueGrey[800],
            fontSize: 17
          ),
        ),
      ),
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      padding: EdgeInsets.symmetric(vertical: 10,horizontal:0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: lightmode?Colors.deepPurpleAccent[100]:Colors.purple[50],
      ),
    );
  }
}
