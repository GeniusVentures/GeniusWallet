import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';


class GeniusCheckbox<custom> extends StatelessWidget{
  final constraints;
  
  GeniusCheckbox<custom>(this.constraints, {Key key, }) : super(key : key);
  

  @override
  Widget build(BuildContext context){
    return Container(width: constraints.maxWidth * 1.006,height: constraints.maxHeight * 1.048,child: Align(alignment: Alignment(0.00, 0.00),child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.start,
    children:[
      Flexible(flex: 7,child: Padding(padding: EdgeInsets.only(),child: Container(width: constraints.maxWidth * 0.065,height: constraints.maxHeight * 0.952,decoration: BoxDecoration(color: Color(0x00000000),
borderRadius: BorderRadius.all(Radius.circular(4.0)),border: Border.all(color: Color(0x00000000),),),)),),Spacer(flex: 4,),Flexible(flex: 91,child: Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.48,),child: Container(width: constraints.maxWidth * 0.909,height: constraints.maxHeight * 0.571,child: Align(alignment: Alignment(0.00, 0.00),child: AutoSizeText(
'Type something',
style: TextStyle(
fontFamily: 'Prompt',
fontSize: 10.0,
fontWeight: FontWeight.w400,
fontStyle: FontStyle.normal,
letterSpacing: 0.0,
color: Colors.white,),textAlign: TextAlign.left,

),))),)
    ]
    )
    ,));
  }
}