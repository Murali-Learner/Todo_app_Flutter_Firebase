import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:todoapp/firebaseTodo.dart';

class Homescreen extends StatefulWidget {
  @override
  _HomescreenState createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  @override
  void initState() {
    FirebaseTodo.readTodo().then((value) {
      for (var i = 0; i < value.docs.length; i++) {
        setState(() {
          todoListTextFieldEnabled.add(false);
        });
      }
    });
    super.initState();
  }

  List<bool> todoListTextFieldEnabled = [];
  TextEditingController _noteController = TextEditingController();
  showToast(String messege) {
    Fluttertoast.showToast(
      msg: messege,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            color: Color.fromRGBO(235, 235, 235, 1),
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 60),
                  alignment: Alignment.topCenter,
                  child: Text(
                    "TO DO App",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: _width * 0.7,
                      height: _height * 0.1,
                      child: TextFormField(
                        maxLength: 100,
                        style: TextStyle(),
                        decoration: new InputDecoration(
                          hintStyle: TextStyle(color: Colors.black),
                          hintText: "Type Something here....",
                          fillColor: Colors.white,
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(20.0),
                            // borderSide: new BorderSide(),
                          ),
                        ),
                        controller: _noteController,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(),
                      padding: EdgeInsets.only(
                        left: _width * 0.04,
                        bottom: 10,
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          // print("objectzd");
                          if (_noteController.text == "") {
                            showToast("Please Enter Todo Task");
                            return;
                          }
                          await FirebaseTodo.addTodo(
                            _noteController.text.trim(),
                            false,
                            // Incompleted Task
                          );

                          setState(() {
                            todoListTextFieldEnabled.add(false);
                          });
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.black,
                          radius: 30,
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: _height * 0.03,
                ),
                Container(
                  height: _height * 0.6,
                  // color: Colors.amber,
                  child: FutureBuilder<QuerySnapshot>(
                      future: FirebaseTodo.readTodo(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return snapshot.data!.docs.length != 0 &&
                                  snapshot.data!.docs.length ==
                                      todoListTextFieldEnabled.length
                              ? ListView.builder(
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    var value = snapshot.data!.docs[index]
                                        .data() as Map<String, dynamic>;
                                    List<TextEditingController> controllerList =
                                        List.generate(
                                      snapshot.data!.docs.length,
                                      (index) => TextEditingController(
                                          text: value["todo"]),
                                    );
                                    // List<bool> isEditList = List.generate(
                                    //     snapshot.data!.docs.length,
                                    //     (index) => false);

                                    return GestureDetector(
                                      onTap: () {
                                        print(snapshot.data!.docs[index].id);
                                      },
                                      child: Container(
                                        height: _height * 0.1,
                                        child: Card(
                                            child: Row(
                                          children: [
                                            SizedBox(
                                              width: _width * 0.02,
                                            ),
                                            value["isDone"]
                                                ? IconButton(
                                                    icon: Icon(
                                                      // task is done
                                                      Icons
                                                          .check_circle_outline,
                                                    ),
                                                    onPressed: () {
                                                      FirebaseTodo.updateTodo(
                                                        snapshot.data!
                                                            .docs[index].id,
                                                        value["todo"],
                                                        false,
                                                      );
                                                      // Uncheck
                                                      setState(() {});
                                                    },
                                                  )
                                                : IconButton(
                                                    icon: Icon(
                                                      Icons
                                                          .radio_button_unchecked,
                                                    ),
                                                    onPressed: () {
                                                      FirebaseTodo.updateTodo(
                                                        snapshot.data!
                                                            .docs[index].id,
                                                        value["todo"],
                                                        true,
                                                      );
                                                      setState(() {});
                                                      // Check To Complete the Task
                                                    },
                                                  ),

                                            SizedBox(
                                              width: _width * 0.05,
                                            ),
                                            Container(
                                              width: _width * 0.45,
                                              child: TextField(
                                                decoration: InputDecoration(
                                                  border:
                                                      !todoListTextFieldEnabled[
                                                              index]
                                                          ? InputBorder.none
                                                          : UnderlineInputBorder(),
                                                ),
                                                controller:
                                                    controllerList[index],
                                                enabled:
                                                    todoListTextFieldEnabled[
                                                        index],
                                                onSubmitted:
                                                    (inputValue) async {
                                                  if (controllerList[index]
                                                          .text ==
                                                      "") {
                                                    showToast(
                                                        "Please Enter Todo Task");
                                                    return;
                                                  }
                                                  await FirebaseTodo.updateTodo(
                                                    snapshot
                                                        .data!.docs[index].id,
                                                    inputValue,
                                                    (value["isDone"]),
                                                  );
                                                  setState(() {
                                                    todoListTextFieldEnabled[
                                                            index] =
                                                        !todoListTextFieldEnabled[
                                                            index];
                                                  });
                                                },
                                              ),
                                            ),
                                            SizedBox(
                                              width: _width * 0.01,
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                  Icons.mode_edit_outlined),
                                              onPressed: () {
                                                setState(() {
                                                  todoListTextFieldEnabled[
                                                          index] =
                                                      !todoListTextFieldEnabled[
                                                          index];
                                                });
                                                print(todoListTextFieldEnabled);
                                              },
                                            ),
                                            // Icon(Icons.mode_edit_outlitodoList[index]ned),
                                            SizedBox(
                                              width: _width * 0.01,
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.delete),
                                              onPressed: () {
                                                FirebaseTodo.deleteTodo(snapshot
                                                    .data!.docs[index].id);
                                                setState(() {
                                                  todoListTextFieldEnabled
                                                      .removeAt(index);
                                                });
                                              },
                                            ),
                                          ],
                                        )),
                                      ),
                                    );
                                  },
                                )
                              : Center(
                                  child: Text(
                                    "No ToDo List",
                                  ),
                                );
                        } else {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                          // return
                        }
                      }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
