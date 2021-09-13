import 'package:flutter/material.dart';

class LoaderDialog extends StatelessWidget {
  const LoaderDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return SimpleDialog(
    //   children: <Widget>[
    //     Center(
    //       child: Column(children: [
    //         CircularProgressIndicator(),
    //         SizedBox(
    //           height: 10,
    //         ),
    //         Text(
    //           "Please Wait....",
    //           style: TextStyle(color: Colors.blueAccent),
    //         )
    //       ]),
    //     )
    //   ],
    // );
    return Center(
      child: CircularProgressIndicator(
        backgroundColor: Colors.grey,
      ),
    );
  }
}
