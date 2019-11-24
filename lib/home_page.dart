import 'dart:convert';

import 'package:contacts_service/contacts_service.dart';
import 'package:dart_random_choice/dart_random_choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:random_string/random_string.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> firstNames;
  List<String> middleNames;
  List<String> lastNames;

  @override
  initState() {
    super.initState();
    loadAssets();
    getPermission();
  }

  @override
  dispose() {
    super.dispose();
  }

  loadAssets() async {
    firstNames = await rootBundle
        .loadString('assets/first-names.json')
        .then((value) => List<String>.from(json.decode(value)));
    middleNames = await rootBundle
        .loadString('assets/middle-names.json')
        .then((value) => List<String>.from(json.decode(value)));
    lastNames = await rootBundle
        .loadString('assets/last-names.json')
        .then((value) => List<String>.from(json.decode(value)));
  }

  getPermission() async {
    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      print('Contact Permission Granted');
    } else {
      _handleInvalidPermissions(permissionStatus);
    }
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.contacts);
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.disabled) {
      Map<PermissionGroup, PermissionStatus> permissionStatus =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.contacts]);
      return permissionStatus[PermissionGroup.contacts] ??
          PermissionStatus.unknown;
    } else {
      return permission;
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      throw new PlatformException(
          code: "PERMISSION_DENIED",
          message: "Access to location data denied",
          details: null);
    } else if (permissionStatus == PermissionStatus.disabled) {
      throw new PlatformException(
          code: "PERMISSION_DISABLED",
          message: "Location data is not available on device",
          details: null);
    }
  }

  loadContacts(int numContacts, {bool fuzz = false}) async {
    for (var i = 0; i < numContacts; i++) {
      Contact contact = Contact(
          givenName: fuzz ? randomString(10) : randomChoice(firstNames),
          middleName: fuzz ? randomString(10) : randomChoice(middleNames),
          familyName: fuzz ? randomString(10) : randomChoice(lastNames),
          phones: [
            for (var i = 0; i < randomBetween(1, 4); i++)
              Item(
                  label: 'phone $i',
                  value: randomBetween(2000000000, 7999999999).toString())
          ],
          emails: [
            for (var i = 0; i < randomBetween(1, 4); i++)
              Item(label: 'email $i', value: randomAlpha(10) + '@gmail.com')
          ]);
      await ContactsService.addContact(contact);
    }
  }

  deleteAllContacts() async {
    Iterable<Contact> contacts =
        await ContactsService.getContacts(withThumbnails: false);
    for (var contact in contacts) await ContactsService.deleteContact(contact);
  }

  Future<bool> _addDialog(BuildContext context, int num) {
    return showPlatformDialog(
        context: context,
        builder: (_) => PlatformAlertDialog(
              title: Text('Add $num Random Contacts?'),
              actions: <Widget>[
                PlatformDialogAction(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                PlatformDialogAction(
                  child: Text('OK'),
                  onPressed: () => Navigator.pop(context, true),
                ),
              ],
            ));
  }

  Future<bool> _deleteDialog(BuildContext context) {
    return showPlatformDialog(
        context: context,
        builder: (_) => PlatformAlertDialog(
              title: Text('Delete All Contact?'),
              content: Text('This cannot be undone!'),
              actions: <Widget>[
                PlatformDialogAction(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                PlatformDialogAction(
                  child: Text('OK'),
                  onPressed: () => Navigator.pop(context, true),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text('Contacts Generator'),
      ),
      body: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            PlatformButton(
              child: Text('Generate 100 Random Contacts'),
              onPressed: () async {
                var numContacts = 100;
                await _addDialog(context, numContacts).then((val) async {
                  if (val ?? false) await loadContacts(numContacts);
                });
              },
            ),
            PlatformButton(
              child: Text('Generate 1000 Random Contacts'),
              onPressed: () async {
                var numContacts = 1000;
                await _addDialog(context, numContacts).then((val) async {
                  if (val ?? false) await loadContacts(numContacts);
                });
              },
            ),
            PlatformButton(
              child: Text('Generate 100 Fuzzing Contacts'),
              onPressed: () async {
                var numContacts = 100;
                await _addDialog(context, numContacts).then((val) async {
                  if (val ?? false) await loadContacts(numContacts, fuzz: true);
                });
              },
            ),
            PlatformButton(
              child: Text('DELETE ALL CONTACTS'),
              onPressed: () async {
                await _deleteDialog(context).then((val) async {
                  if (val ?? false) await deleteAllContacts();
                });
              },
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
