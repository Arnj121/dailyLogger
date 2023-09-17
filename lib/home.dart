import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:week52/database.dart';
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  bool lightmode=true,productive=false,bookmarked=false;
  DateTime dt = DateTime.now();int id;
  DatabaseHelper database = DatabaseHelper.instance;
  Random rnd = Random();
  List month = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  dynamic entries = [],tasks=[];
  TextEditingController descript = TextEditingController();
  Future<void> initData()async{
    entries=[];tasks=[];
    dynamic temp = await database.getTodayStatus(dt.day, dt.year, dt.month);
    if(temp.length==0){
      id=int.parse(rnd.nextInt(10000).toString()+dt.day.toString()+dt.month.toString());
      await database.addDateStatus(id, dt.toString(),0);
    }
    else{
      productive=temp[0]['productive']==1?true:false;bookmarked=temp[0]['bookmarked']==1?true:false;id=temp[0]['id'];
      descript.text=temp[0]['description'];
    }
    temp = await database.getTodayEntries(dt.day, dt.year, dt.month);
    temp.forEach((e)=>{
      entries.add(jsonDecode(jsonEncode(e)))
    });
    temp = await database.getPlans(dt.toString().substring(0,10));
    temp.forEach((e)=>{
      tasks.add(jsonDecode(jsonEncode(e)))
    });
    this.setState(() {
      tasks=tasks;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async{ initData();});
  }

  @override
  Widget build(BuildContext context) {
    lightmode = MediaQuery.of(context).platformBrightness == Brightness.light;
    return SafeArea(
      child: Scaffold(
        backgroundColor: lightmode?Colors.white:null,
        floatingActionButton: FloatingActionButton(
          elevation: 2,
          child: Icon(Icons.add,color: Colors.white,size: 40,),
          backgroundColor: Colors.red.shade300,
          onPressed: ()async{
            dynamic res = await Navigator.pushNamed(context, '/addentry');
            if(res!=null && res.length>0){
              this.entries.insert(0,{'id':res[0],'date':res[1].substring(0,10),'datetime':res[1],'entry':res[2]});
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  'Entry added',
                  style: GoogleFonts.quicksand(),
                ),
                duration: Duration(seconds: 3),
              ));
              this.setState(() {this.entries=entries;});
            }
          },
        ),
        appBar: AppBar(
          backgroundColor: lightmode?Colors.white:Colors.grey[850],
          elevation: 0,
          title: Text(
            '52weeks',
            style: GoogleFonts.quicksand(
              fontSize: 35,
              letterSpacing: 1,
              fontWeight: FontWeight.bold,
              color: lightmode?Colors.blueAccent:Colors.white
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
                icon: Icon(this.bookmarked?Icons.star:Icons.star_border_outlined,color: Colors.yellow[700],size: 30),
                onPressed: (){
                  database.bookmark(id, this.bookmarked?0:1);
                  String text = bookmarked?'Bookmark removed':'Bookmark added';
                  ScaffoldMessenger.of(context).showSnackBar(showToast(text));
                  this.setState(() {
                    this.bookmarked = !this.bookmarked;
                  });
                }
                ),
            IconButton(
                icon: Icon(Icons.book,color: Colors.yellow[700],size: 30),
                onPressed: (){
                  Navigator.pushNamed(context,'/plandisplay');
                  // database.clear();
                }
            )
          ],
        ),
        body: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  SizedBox(
                    height: 10,
                  ),
                  Center(
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
                          dt.day.toString(),
                          style: GoogleFonts.quicksand(
                              fontSize: 35,
                              color: Colors.redAccent
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          month[dt.month-1],
                          style: GoogleFonts.quicksand(
                              fontSize: 35,
                              color: Colors.pink
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),

                        Text(
                          dt.year.toString(),
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
                  SizedBox(height: 10,),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          child: TextButton(
                            child: Text(
                              'Plan today',
                              style: GoogleFonts.quicksand(
                                fontSize: 20,
                                color: Colors.white
                              ),
                            ),
                            onPressed: ()async{
                              dynamic ret = await Navigator.pushNamed(context, '/plan',arguments: {'today':1,'para':0});
                              if(ret['task']!=null && ret['change']==1){
                                this.setState(() {
                                  tasks=ret['task'];
                                });
                              }
                              },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(Colors.deepOrangeAccent)
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: this.productive,
                              onChanged: (bool v)async{
                                await database.productive(id, v?1:0);
                                this.setState(() {
                                  this.productive=v;
                                });
                              },
                              checkColor: Colors.green[400],
                              fillColor:MaterialStateProperty.all<Color>(Colors.green[100]),
                            ),
                            Text(
                              'Productive day',
                              style: GoogleFonts.quicksand(
                                  fontSize: 20,
                                  color: Colors.green[400]
                              ),
                            )
                          ],
                        ),
                        Container(
                          child: TextButton(
                            child: Text(
                              'Plan a day',
                              style: GoogleFonts.quicksand(
                                  fontSize: 20,
                                  color: Colors.white
                              ),
                            ),
                            onPressed: ()async{
                              dynamic ret = await Navigator.pushNamed(context, '/plan',arguments: {'today':0,'para':0});
                              if(ret['task']!=null && ret['change']==1){
                                this.setState(() {
                                  tasks=ret['task'];
                                });
                              }
                              },
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(Colors.deepOrangeAccent)
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 10,),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          child: TextField(
                            controller:descript,
                            style: GoogleFonts.quicksand(),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintStyle: GoogleFonts.quicksand(),
                              hintText:'Enter something about the day to remember by...',
                            ) ,
                            maxLines: null,
                            cursorHeight: 20,
                          ),
                          // height: 50,
                          width: 310,
                        ),
                        IconButton(
                          icon:Icon(Icons.send,color: Colors.green[400],),
                          onPressed: ()async{
                            await database.saveDescription(id, descript.text);
                            FocusScope.of(context).unfocus();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:Text(
                                'Description saved!',
                                style: GoogleFonts.quicksand(),
                              ),
                              duration: Duration(seconds:2),
                            ));
                          },
                        )
                      ],
                    ),
                    margin: EdgeInsets.symmetric(vertical: 2,horizontal: 10),
                    // height: 50,
                  ),
                  SizedBox(height: 10,),
                  Visibility(
                    visible: tasks.length==0?false:true,
                    child: Container(
                      child:Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Today\'s plans',
                            style: GoogleFonts.quicksand(
                              fontSize: 25,
                              color: Colors.orangeAccent
                            ),
                          ),
                          IconButton(
                            icon:Icon(
                              Icons.refresh,
                              size: 25,
                              color: Colors.orangeAccent,
                            ),
                            onPressed: initData,
                          )
                        ],
                      ),
                      margin: EdgeInsets.symmetric(vertical: 5,horizontal: 20),
                    ),
                  )
                ]
              ),
            ),
            SliverVisibility(
              visible: tasks.length==0?false:true,
              sliver: SliverList(
                  delegate:SliverChildBuilderDelegate(
                          (BuildContext context,int index){
                        return taskBuilder(index);
                      },
                      childCount: tasks.length
                  )
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Container(
                    child: Text(
                      'Today\'s entries',
                      style: GoogleFonts.quicksand(
                          fontSize: 25,
                          color: Colors.orangeAccent
                      ),
                    ),
                    margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  ),
                  Visibility(
                    visible: entries.length>0?false:true,
                    child: Container(
                      child: Center(
                        child: Text(
                          'No entries',
                          style: GoogleFonts.quicksand(
                              fontSize: 25,
                              color: Colors.orangeAccent
                          ),
                        ),
                      ),
                      margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                    ),
                  ),
                ]
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                  (BuildContext context,int index){
                      return entryBuilder(index);
                  },
                childCount: entries.length
              ),
            )
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.purpleAccent,
          unselectedItemColor: Colors.purpleAccent,
          items: [
            BottomNavigationBarItem(
              icon: IconButton(
                  icon:Icon(Icons.star,color: Colors.yellow[700]),
                onPressed: (){
                    Navigator.pushNamed(context, '/bookmarks');
                },
              ),
              label: 'Booksmarks'
            ),
            BottomNavigationBarItem(
              icon: IconButton(
                icon:Icon(Icons.check_circle_sharp,color: Colors.green[400]),
                onPressed: (){
                  Navigator.pushNamed(context, '/productivedays');
                },
              ),
              label: 'Productive days'
            ),
            BottomNavigationBarItem(
                icon: IconButton(
                  icon:Icon(Icons.history,color: Colors.redAccent),
                  onPressed: (){
                    Navigator.pushNamed(context, '/history');
                  },
                ),
                label: 'History'
            ),
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
        trailing: Checkbox(
          value: tasks[index]['accomplished']==1?true:false,
          checkColor: Colors.green[400],
          fillColor:MaterialStateProperty.all<Color>(Colors.green[100]),
          onChanged: (bool v)async{
            await database.planaccomp(tasks[index]['id'],tasks[index]['accomplished']==1?0:1);
            this.setState(() {
              tasks[index]['accomplished']=tasks[index]['accomplished']==1?0:1;
            });
          },
        ),
      ),
      margin: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
      padding: EdgeInsets.symmetric(vertical: 10,horizontal:0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: lightmode?Colors.deepPurpleAccent[100]:Colors.purple[50],
      ),
    );
  }
  Container entryBuilder(int index){
    dt = DateTime.now();
    String type='hr';
    int rem=dt.hour-int.parse(entries[index]['datetime'].substring(11,13));
    if(rem==0){
      rem=dt.minute-int.parse(entries[index]['datetime'].substring(14,16));
      type='min';
      if(rem==0){
        rem=dt.second-int.parse(entries[index]['datetime'].substring(17,19));
        type='sec';
      }
    }
    return Container(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            '${rem.toString()} $type',
            style: GoogleFonts.quicksand(
              fontSize: 15,
                color: lightmode?Colors.white:Colors.blueGrey[800]
            ),
          ),
          radius: 30,
          backgroundColor: Colors.transparent,
        ),
        title: Text(
          entries[index]['entry'],
          style: GoogleFonts.quicksand(
            fontSize: 20,
            color: lightmode?Colors.white:Colors.blueGrey[800]
          ),
        ),
        trailing: Text(
          entries[index]['datetime'].substring(11,16),
          style: GoogleFonts.quicksand(
              fontSize: 20,
              color: lightmode?Colors.white:Colors.blueGrey[800]
          ),
        ),
      ),
      margin: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
      padding: EdgeInsets.symmetric(vertical: 10,horizontal:0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: lightmode?Colors.deepPurpleAccent[100]:Colors.purple[50],
      ),
    );
  }
  SnackBar showToast(String text){
    return SnackBar(
      content: Text(
        text,
        style: GoogleFonts.quicksand(),
      ),
      duration: Duration(seconds: 2),
    );
  }
}