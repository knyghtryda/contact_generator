import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  initState() {
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
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
                await _addDialog(context, numContacts);
              },
            ),
            PlatformButton(
              child: Text('Generate 1000 Random Contacts'),
              onPressed: () async {
                var numContacts = 1000;
                await _addDialog(context, numContacts);
              },
            ),
            PlatformButton(
              child: Text('DELETE ALL CONTACTS'),
              onPressed: () async {
                await _deleteDialog(context);
              },
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
