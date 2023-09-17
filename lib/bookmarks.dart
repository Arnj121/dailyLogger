import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:week52/database.dart';

class Bookmarks extends StatefulWidget {
  @override
  _BookmarksState createState() => _BookmarksState();
}

class _BookmarksState extends State<Bookmarks> {
  bool lightmode=true;

  TextEditingController daycont,monthcont,yearcont = TextEditingController();
  List month = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  String order = 'asc';
  List bookmarked=[];
  DatabaseHelper database = DatabaseHelper.instance;

  Future<void> initData()async{
    bookmarked=[];
    dynamic temp = await database.getBookmarked(order);
    temp.forEach((e)=>{
      bookmarked.add(jsonDecode(jsonEncode(e)))
    });
    this.setState(() {
      bookmarked = bookmarked;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async{await initData();});
  }

  @override
  Widget build(BuildContext context) {
    lightmode = MediaQuery.of(context).platformBrightness== Brightness.light;
    return SafeArea(
      child: Scaffold(
        backgroundColor: lightmode?Colors.white:null,
        appBar: AppBar(
          backgroundColor: lightmode?Colors.white:null,
          elevation: 0,
          titleSpacing: 0,
          title: Text(
            'Bookmarks',
            style: GoogleFonts.quicksand(
              fontSize: 30,
              letterSpacing: 1,
              fontWeight: FontWeight.bold,
              color: lightmode?Colors.blueAccent:Colors.white
            ),
          ),
          leading: BackButton(
              color: lightmode?Colors.blueAccent:Colors.white
          ),
        ),
        body: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        child: TextField(
                          controller: daycont,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText:'Date',
                            hintStyle: GoogleFonts.quicksand(),
                            contentPadding: EdgeInsets.symmetric(vertical: 0,horizontal: 10)
                          ),
                          cursorHeight: 20,
                        ),
                        height: 40,
                        width: 80,
                      ),
                      Container(
                        child: TextField(
                          controller: monthcont,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText:'Month',
                              hintStyle: GoogleFonts.quicksand(),
                              contentPadding: EdgeInsets.symmetric(vertical: 0,horizontal: 10)

                          ),
                          cursorHeight: 20,
                        ),
                        height: 40,
                        width: 80,
                      ),
                      Container(
                        child: TextField(
                          controller: yearcont,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText:'Year',
                              hintStyle: GoogleFonts.quicksand(),
                              contentPadding: EdgeInsets.symmetric(vertical: 0,horizontal: 10)
                          ),
                          cursorHeight: 20,
                        ),
                        height: 40,
                        width: 80,
                      ),
                      Container(
                        child: IconButton(
                          icon: Icon(
                            Icons.sort_sharp,
                            size: 20,
                            color: lightmode?Colors.grey[850]:Colors.white,
                          ),
                          onPressed: (){
                            if(order=='asc')
                              order='desc';
                            else
                              order='asc';
                            this.setState(() {
                              order=order;
                            });
                          },
                        ),
                        decoration: BoxDecoration(
                          color: order=='asc'?null:Colors.redAccent,
                          borderRadius: BorderRadius.circular(5)
                        ),
                        height: 40,
                        width: 40,
                      )
                    ],
                  ),
                  SizedBox(height: 20,),
                  Container(
                    child: TextButton.icon(
                      icon:Icon(Icons.search,size: 25,color: Colors.white,),
                      onPressed: (){},
                      label: Text(
                        'Search',
                        style: GoogleFonts.quicksand(
                          fontSize: 25,
                          color: Colors.white
                        ),
                      ),
                      style: ButtonStyle(
                        elevation: MaterialStateProperty.all<double>(1),
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.redAccent)
                      ),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 5,horizontal: 20),
                  ),
                  Visibility(
                    visible: bookmarked.length>0?false:true,
                    child: Container(
                      child: Center(
                        child: Text(
                          'No bookmarks yet!',
                          style: GoogleFonts.quicksand(
                            fontSize: 30,
                          ),
                        ),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 20,horizontal: 0),
                    ),
                  )
                ]
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                  (BuildContext context,int index){
                    return bookbuilder(index);
                  },
                childCount: bookmarked.length
              ),
            )
          ],
        ),
      ),
    );
  }
  Container bookbuilder(int index){
    dynamic date = bookmarked[index]['date'];
    date = date.split('-');
    return Container(
      child: ListTile(
        onTap: (){
          Navigator.pushNamed(context, '/logdisplay',arguments: bookmarked[index]);
        },
        subtitle: Text(
          'Tap to view logs',
          style: GoogleFonts.quicksand(
              color: lightmode?Colors.white:Colors.blueGrey[800]
          ),
        ),
        leading: CircleAvatar(
          child: Icon(
            Icons.calendar_today_rounded,
              color: lightmode?Colors.white:Colors.blueGrey[800]
          ),
          backgroundColor: Colors.transparent,
        ),
        title: Text(
          date[2]+' '+month[int.parse(date[1])]+' '+date[0]+'\n'+bookmarked[index]['description'],
          style: GoogleFonts.quicksand(
              fontSize: 20,
              color: lightmode?Colors.white:Colors.blueGrey[800]
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            this.bookmarked[index]['bookmarked']==1?Icons.star:Icons.star_border_outlined,color: Colors.yellow[700],size: 30
          ),
          onPressed: (){
            database.bookmark(bookmarked[index]['id'], bookmarked[index]['bookmarked']==1?0:1);
            bookmarked[index]['bookmarked']=bookmarked[index]['bookmarked']==1?0:1;
            String text=bookmarked[index]['bookmarked']==1?'Bookmark added':'Bookmark removed';
            ScaffoldMessenger.of(context).showSnackBar(showToast(text));
            this.setState(() {
              bookmarked=bookmarked;
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
