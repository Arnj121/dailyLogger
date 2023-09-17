import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:week52/database.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'dart:math';
class Plan extends StatefulWidget {
  @override
  _PlanState createState() => _PlanState();
}

class _PlanState extends State<Plan> {
  bool lightmode=true;
  int today=0;DateTime dt;int id;int rndid;
  DatabaseHelper database = DatabaseHelper.instance;
  bool isNewVisible=false;
  TextEditingController controller = TextEditingController();
  List tasks=[];List todel=[];List newlyadded=[];
  List month = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  Random rnd = Random();

  Future<void> initData()async{
    tasks=[];todel=[];newlyadded=[];
    if(today==1){
      dynamic temp = await database.getPlans(dt.toString().substring(0,10));
      temp.forEach((e)=>{
        tasks.add(e)
      });
      this.setState(() {
        tasks=tasks;
      });
    }
    else if(dt!=null){
      dynamic temp = await database.getPlans(dt.toString().substring(0,10));
      temp.forEach((e)=>{
        tasks.add(e)
      });
      this.setState(() {
        tasks=tasks;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async{ await initData();});
  }

  @override
  Widget build(BuildContext context) {
    lightmode=MediaQuery.of(context).platformBrightness==Brightness.light;
    dynamic temp = ModalRoute.of(context).settings.arguments;
    today = temp['today'];
    if(today==1){
      dt = DateTime.now();
    }
    if(temp['para']==1){
      dt=DateTime.parse(temp['date']);
    }
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            controller.text='';
            this.setState(() {
            this.isNewVisible=!isNewVisible;
          });},
          child: Icon(
            this.isNewVisible?Icons.remove:Icons.add,
            color: Colors.blueGrey,
            size: 35,
          ),
          elevation: 2,
          backgroundColor: Colors.greenAccent,
        ),
        backgroundColor: lightmode?Colors.white:null,
        appBar: AppBar(
          backgroundColor: lightmode?Colors.white:Colors.grey[850],
          elevation: 0,
          leading: BackButton(
            color: lightmode?Colors.blueAccent:Colors.white,
          ),
          titleSpacing: 0,
          title: Text(
            'Planner',
            style: GoogleFonts.quicksand(
              color: lightmode?Colors.blueAccent:Colors.white,
              fontSize: 30
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'Done',
                style: GoogleFonts.quicksand(
                  color: lightmode?Colors.blueAccent:Colors.white,
                  fontSize: 20
                ),
              ),
              onPressed: ()async {
                if (dt != null) {
                  DateTime td = DateTime.now();
                  if(td.day==dt.day && td.year==dt.year && td.month==dt.month) {
                    today = 1;
                  }
                  await database.addplan(newlyadded, dt.toString());
                  todel.forEach((e) async {
                    await database.deleteplan(e);
                  });
                  rndid = int.parse(
                      rnd.nextInt(10000).toString() + dt.day.toString() +
                          dt.month.toString());
                  if (this.today == 0) {
                    dynamic t = await database.getTodayStatus(dt.day,dt.year,dt.month);
                    if (t.length == 0)
                      await database.addDateStatus(
                          rndid, dt.toString().substring(0, 10),
                          tasks.length == 0 ? 0 : 1);
                  }
                  if (tasks.length == 0) {
                    await database.togglePlan(
                        dt.toString().substring(0, 10), 0);
                  }
                  else {
                    await database.togglePlan(
                        dt.toString().substring(0, 10), 1);
                  }
                  if (this.today == 1)
                    Navigator.pop(context, {'task':tasks,'change':1});
                  else
                    Navigator.pop(context, {'task':[],'change':0});
                }
                else{
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      'Pick a date!',
                      style: GoogleFonts.quicksand(),
                    ),
                    duration: Duration(seconds:2),
                  ));
                }
              }
            )
          ],
        ),
        body: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  SizedBox(height: 20,),
                  Visibility(
                    visible: dt==null?true:false,
                    child: Center(
                      child: Text(
                        'Not selected',
                        style: GoogleFonts.quicksand(
                          fontSize: 30,
                          color: lightmode?Colors.blueGrey[800]:Colors.white
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: dt!=null?true:false,
                    child: Center(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 30,
                            color: lightmode?Colors.blueGrey[800]:Colors.white,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            dt!=null?dt.day.toString():'',
                            style: GoogleFonts.quicksand(
                                fontSize: 35,
                                color: Colors.redAccent
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            dt!=null?month[dt.month-1]:'',
                            style: GoogleFonts.quicksand(
                                fontSize: 35,
                                color: Colors.purpleAccent
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),

                          Text(
                            dt!=null?dt.year.toString():'',
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
                  ),
                  SizedBox(height: 20,),
                  Center(
                    child: TextButton(
                      onPressed: (){
                        if(today==0)
                          showDate();
                        else{
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                              'Date already picked',
                              style: GoogleFonts.quicksand(),
                            ),
                            duration: Duration(seconds: 2),
                          ));
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: today==0 && temp['para']==0?MaterialStateProperty.all<Color>(Colors.redAccent):MaterialStateProperty.all<Color>(Colors.redAccent[100])
                      ),
                      child: Text(
                        'Pick a date',
                        style: GoogleFonts.quicksand(
                          fontSize: 20,
                          color: Colors.white
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  Visibility(
                    visible: tasks.length==0?true:false,
                    child: Center(
                      child: Text(
                        'No plans added yet!',
                        style: GoogleFonts.quicksand(
                          fontSize: 30,
                          color: lightmode?Colors.blueGrey[800]:Colors.white
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  Visibility(
                    visible: isNewVisible,
                    child: Column(
                      children: [
                        Container(
                          child: TextField(
                            style: GoogleFonts.quicksand(),
                            controller: controller,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(
                                Icons.send,
                                color: Colors.green[400],
                              ),
                            ),
                            cursorHeight: 20,
                            maxLines: null,
                            autofocus: true,
                          ),
                          margin: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                        ),
                        SizedBox(height: 20,),
                        Center(
                          child:TextButton(
                            child: Text(
                              'Add',
                              style: GoogleFonts.quicksand(
                                fontSize: 20,
                                color: Colors.white
                              ),
                            ),
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(Colors.redAccent)
                            ),
                            onPressed: (){
                              if(controller.text.length==0){
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                    'Tis empty!',
                                    style: GoogleFonts.quicksand(),
                                  ),
                                  duration: Duration(seconds: 2),
                                ));
                              }
                              else if(dt==null){
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content:Text(
                                    'Pick a date first',
                                    style: GoogleFonts.quicksand(),
                                  ) ,
                                ));
                              }
                              else {
                                id=int.parse(rnd.nextInt(10000).toString()+dt.day.toString());
                                tasks.add({'id':id,'entry':controller.text,'date':dt.toString().substring(0,10),'accomplished':0});
                                newlyadded.add({'id':id,'entry':controller.text,'date':dt.toString().substring(0,10),'accomplished':0});
                                controller.text = '';
                                this.setState(() {
                                  tasks = tasks;
                                  isNewVisible = !isNewVisible;
                                });
                              }
                            },
                          )
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 20,)
                ]
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                  (BuildContext context,int index){
                    return planObject(index);
                  },
                childCount: tasks.length
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
          this.dt=date;
          initData();
        }
    );
  }
  Container planObject(int index){
    return Container(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.transparent,
          child: Text(
              (index+1).toString(),
            style: GoogleFonts.quicksand(
              fontSize: 20,
                color: lightmode?Colors.white:Colors.blueGrey[800]
            ),
          ),
        ),
        title:Text(
          tasks[index]['entry'],
          style: GoogleFonts.quicksand(
            fontSize: 17,
            color: lightmode?Colors.white:Colors.blueGrey[800]
          ),
        ),
        trailing: CircleAvatar(
          child: IconButton(
            icon:Icon(
            Icons.delete,
            color: Colors.redAccent,
              size: 30,
            ),
            onPressed: ()async{
              todel.add(tasks[index]['id']);
              tasks.removeAt(index);
              this.setState(() {
                tasks=tasks;
              });
            },
          ),
          backgroundColor: Colors.transparent,
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 10,horizontal:0),
      margin: EdgeInsets.symmetric(vertical: 5,horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: lightmode?Colors.deepPurpleAccent[100]:Colors.purple[50],
      ),
    );
  }
}
