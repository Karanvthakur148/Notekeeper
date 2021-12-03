import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notekeeperapp1/models/note.dart';
import 'package:notekeeperapp1/utils/database_helper.dart';

final _formKey = GlobalKey<FormState>();

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;
    NoteDetail(this.note,this.appBarTitle,);
    final _formKey = GlobalKey<FormState>();

  @override
  _NoteDetailState createState() => _NoteDetailState(note,appBarTitle);
}

class _NoteDetailState extends State<NoteDetail> {
  _NoteDetailState(this.note,this.appBarTitle);
  static final _priorities = ["High", "Low"];
  DatabaseHelper helper = DatabaseHelper();
  String appBarTitle;
  Note note;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.subtitle1;
    titleController.text = note.title;
    descriptionController.text = note.description;

    return Scaffold(
      appBar: AppBar(
        title:  Text(appBarTitle),
        leading: IconButton(icon: const Icon(Icons.arrow_back),onPressed:
          () {
            moveToLastScreen();
          },),
      ),
      body: Form(key: _formKey,
        child: Padding(
          padding: const EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
          child: ListView(
            children: [
              ListTile(
                title: DropdownButton(
                  items: _priorities.map((String dropDownStringItem) {
                    return DropdownMenuItem<String>(
                      value: dropDownStringItem,
                      child: Text(dropDownStringItem),
                    );
                  }).toList(),
                  style: textStyle,
                  value: getPriorityAsString(note.priority),
                  onChanged: (valueSelectedByUser) {
                    setState(() {
                      debugPrint("User selected $valueSelectedByUser");
                      updatePriorityAsInt(valueSelectedByUser);
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextFormField(validator:(String value) {
                  if (value.isEmpty){
                    return "please enter title";
                  }
                },
                  controller: titleController,
                  style: textStyle,
                  onChanged: (value) {
                    debugPrint("Somthing changed in titleTextfieldd");
                    updateTitle();

                  },
                  decoration: InputDecoration(
                      labelText: "Title",
                      labelStyle: textStyle,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      )),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextFormField(validator: (String value) {
                  if (value.isEmpty){
                    return "Please enter description";
                  }
                },
                  controller: descriptionController,
                  style: textStyle,
                  onChanged: (value) {
                    debugPrint("Somthing changed in DescriptionTextfieldd");
                    updateDescription.toString();
                  },
                  decoration: InputDecoration(
                      labelText: "Description".toString(),
                      labelStyle: textStyle,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      )),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              debugPrint("Save button");
                              if(_formKey.currentState.validate()){
                                _save();

                              }
                            });
                          },
                          child: Text(
                            "Save",
                            textScaleFactor: 1.5,
                            style: TextStyle(
                              color: Theme.of(context).primaryColorLight,
                            ),
                          )),
                    ),
                    const SizedBox(width: 5.0,),
                    Expanded(
                      child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              debugPrint("delet button");
                              if(_formKey.currentState.validate()){
                                _delete();

                              }
                            });
                          },
                          child: Text(
                            "Delete",
                            textScaleFactor: 1.5,
                            style: TextStyle(
                              color: Theme.of(context).primaryColorLight,
                            ),
                          )),
                    )

                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
   moveToLastScreen(){
    Navigator.pop(context,true);
  }

  void updatePriorityAsInt(String value){
    switch (value){
      case "High":
        note.priority = 1;
        break;
      case "Low":
        note.priority =2;
        break;
    }
  }

  String getPriorityAsString(int value){
    String priority;
    switch (value){
      case 1:
        priority = _priorities[0];
        break;
      case 2:
        priority = _priorities[1];
        break;
    }
    return priority;
  }

  void updateTitle(){
    note.title = titleController.text;
  }

  void updateDescription(){
    note.description = descriptionController.text;
  }

  void _save() async{

    moveToLastScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (note.id !=null){
result = await helper.updateNote(Note,note);
    }else{
      result = await helper.insertNote(note);
    }
    if (result != 0){
      _showAlertDialog("Status","Note Saved Successfully");
    }else{
      _showAlertDialog("Status","Problem Saving Note");
    }
  }

  void _delete()async{
    moveToLastScreen();
    if (note.id == null){
     _showAlertDialog("Status", "No Note was deleted");
     return;
    }
    int result = await helper.deleteNote(note.id);
    if (result !=0){
      _showAlertDialog("Status", "Note Deleted Successfully");
    }else{
      _showAlertDialog("Status", "Error Occured while Deleting Note");
    }
  }

  void _showAlertDialog(String title, String message){
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
      context:context,
      builder:(_)=>alertDialog
    );
  }
}
