import 'package:flutter/material.dart';
import '../Navigations/Screens/add_screen.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:note_taker/Navigations/Screens/viewing_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../Lists/colorlist.dart';
import 'package:path/path.dart';
import '../dbstuff/mydbservice.dart';
import '../../Screensections/staggered_grid.dart';
import 'package:form_field_validator/form_field_validator.dart';

class StaggeredGridBuilder extends StatefulWidget {
  const StaggeredGridBuilder({Key? key}) : super(key: key);

  @override
  State<StaggeredGridBuilder> createState() => _StaggeredGridBuilderState();
}

class _StaggeredGridBuilderState extends State<StaggeredGridBuilder> {
  int _version = 1;

  late Database dbase;
  @override
  void initState() {
    // colorList.shuffle(); // TODO: implement initState
    initAndGetNotes();

    super.initState();
  }

  addNote() async {
    await DbService.addNote(
      body: bodyController.text,
      title: titleController.text,
    );
    getNote();
    setState(() {});
  }

  getNote() async {
    final result = await DbService.getNote();

    DbService.notes = result;

    setState(() {});
  }

  initAndGetNotes() {
    DbService.initDatabase().then((value) {
      getNote();
    });
  }

  deleteNote(int id) async {
    await DbService.deleteNote(id);
    getNote();
  }

  @override
  Widget build(BuildContext context) => StaggeredGridViewScreen();
  Widget StaggeredGridViewScreen() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    color: Colors.green,
                    duration: Duration(milliseconds: 20),
                    child: MaterialButton(
                      onPressed: (() => addNote()),
                      child: Text("addnote"),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    color: Colors.red,
                    duration: Duration(milliseconds: 20),
                    child: MaterialButton(
                      onPressed: (() => getNote()),
                      child: Text("fetch note"),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 1),
            child: GridView.custom(
                physics: BouncingScrollPhysics(),
                gridDelegate: SliverQuiltedGridDelegate(
                    repeatPattern: QuiltedGridRepeatPattern.inverted,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 12,
                    crossAxisCount: 4,
                    pattern: [
                      QuiltedGridTile(2, 2),
                      QuiltedGridTile(2, 2),
                      QuiltedGridTile(2, 4),
                      QuiltedGridTile(4, 2),
                      QuiltedGridTile(2, 2),
                      QuiltedGridTile(2, 2),
                      QuiltedGridTile(3, 4),
                    ]),
                childrenDelegate: SliverChildBuilderDelegate(
                    childCount: DbService.notes.length, (context, index) {
                  final item = DbService.notes[index];
                  return InkWell(
                    onTap: () {
                      print("tapped");
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewScreen(),
                          ));
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: EdgeInsets.all(15),
                        color: colorList[index],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              // color: Colors.black,
                              width: 220,
                              child: Text(
                                item['title'],
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400),
                                overflow: TextOverflow.clip,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              item['dateCreated'],
                              style: TextStyle(color: Colors.grey[800]),
                            ),
                            InkWell(
                              onTap: () => deleteNote(item['id']),
                              child: Container(
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                })),
          ),
        ),
      ],
    );
  }
}
