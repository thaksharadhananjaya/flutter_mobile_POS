import 'dart:io' as io;
import 'package:another_flushbar/flushbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:subhasinghe/config.dart';

class Settings extends StatelessWidget {
  const Settings({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: KPaddingHorizontal),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 60,
              width: double.maxFinite,
              child: FlatButton(
                color: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: Text(
                  "Backup",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22),
                ),
                onPressed: () => backup(context),
              ),
            ),
            SizedBox(
              height: 32,
            ),
            SizedBox(
              height: 60,
              width: double.maxFinite,
              child: FlatButton(
                color: Colors.green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: Text(
                  "Restore",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22),
                ),
                onPressed: () => restore(context),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> backup(BuildContext context) async {
    try{

    String selectedDirectory = await FilesystemPicker.open(
      title: 'Save backup',
      context: context,
      rootDirectory: io.Directory("storage/emulated/0/"),
      fsType: FilesystemType.folder,
      pickText: 'Save backup to this folder',
      folderIconColor: kPrimaryColor,
    );

    if (selectedDirectory != null) {
      print(selectedDirectory);
      selectedDirectory = join(selectedDirectory, "backup.db");

      io.Directory documentsDirectory =
          await getApplicationDocumentsDirectory();
      final dbPath = join(documentsDirectory.path, "tdj.db");
      print("path: $dbPath");

      io.File(dbPath).copySync(selectedDirectory);

      Flushbar(
        message: 'Backup Success',
        messageColor: Colors.green,
        icon: Icon(
          Icons.info_rounded,
          color: Colors.green,
        ),
        duration: Duration(seconds: 3),
      ).show(context);
    }}catch(e){
       Flushbar(
        message: e.toString(),
        messageColor: Colors.red,
        icon: Icon(
          Icons.warning_rounded,
          color: Colors.red,
        ),
        duration: Duration(seconds: 3),
      ).show(context);
    }
  }

  Future<void> restore(BuildContext context) async {
    try{
    FilePickerResult result = await FilePicker.platform.pickFiles(
      dialogTitle: "Select Backup",
    );

    if (result != null) {
      String targetPath = result.files.single.path;

      io.Directory documentsDirectory =
          await getApplicationDocumentsDirectory();
      String dbPath = join(documentsDirectory.path, "tdj.db");
      print("path: $dbPath");

      io.File(targetPath).copySync(dbPath);
      print(targetPath);
      Flushbar(
        message: 'Restore Success',
        messageColor: Colors.green,
        icon: Icon(
          Icons.info_rounded,
          color: Colors.green,
        ),
        duration: Duration(seconds: 3),
      ).show(context);
    }}catch(e){
       Flushbar(
        message: e.toString(),
        messageColor: Colors.red,
        icon: Icon(
          Icons.warning_rounded,
          color: Colors.red,
        ),
        duration: Duration(seconds: 3),
      ).show(context);
    }
  }
}
