import 'package:flutter/material.dart';
import 'package:project_1/main.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class FilmTile extends StatefulWidget {
  final String _imagePath;
  final String _filmTitle;
  final int _filmYear;
  final int _filmId;

  bool inQueue = false;
  bool inSeen = false;
  var color = ColorFilter.mode(Colors.black, BlendMode.difference);

  FilmTile(this._filmTitle, this._filmYear, this._imagePath, this._filmId,
      {Key key})
      : super(key: key);

  getId() {
    return _filmId;
  }

  @override
  _FilmTileState createState() => _FilmTileState();
}

class _FilmTileState extends State<FilmTile> {
  final SlidableController slidableController = SlidableController();

  var queueIcon = Icons.add_box_sharp;
  var queueColor = Colors.black;
  var queueCap = "Add to Queue";

  var seenIcon = Icons.add_box_sharp;
  var seenColor = Colors.black45;
  var seenCap = "Add to Seen";

  getTitle() {
    return widget._filmTitle;
  }

  getYear() {
    return widget._filmYear;
  }

  getImagePath() {
    return widget._imagePath;
  }

  getId() {
    return widget._filmId;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.inQueue) {
      queueColor = Colors.green;
      queueCap = "film in Queue";
      queueIcon = Icons.check_box;
    }

    if (widget.inSeen) {
      seenColor = Colors.blue;
      seenCap = "film in Seen";
      seenIcon = Icons.check_box;
    }

    return Slidable(
      controller: slidableController,
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      actions: [
        IconSlideAction(
            caption: queueCap,
            color: widget.inQueue ? Colors.green : queueColor,
            icon: queueIcon,
            onTap: () {
              String text;
              if (widget.inQueue) {
                text = "film already in queue";
              } else {
                setState(() {
                  widget.inQueue = true;
                  queueColor = Colors.green;
                  queueCap = "film in Queue";
                  queueIcon = Icons.check_box;
                });
                addToQueue(context);
                text = "film added to queue";
              }

              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text(text),
                ),
              );
            }),
        IconSlideAction(
            caption: seenCap,
            color: seenColor,
            icon: seenIcon,
            onTap: () {
              String text;
              if (widget.inSeen) {
                text = "film already in Seen";
              } else {
                setState(() {
                  widget.inSeen = true;
                  seenColor = Colors.blue;
                  seenCap = "film in Seen";
                  seenIcon = Icons.check_box;
                });
                text = "film added to Seen";
              }
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text(text),
                ),
              );
            }),
      ],
      child: ListTile(
        onTap: () => print("show more details about film"),
        leading: ColorFiltered(
          colorFilter: widget.color,
          child: Image(
            image: NetworkImage(widget._imagePath),
          ),
        ),
        title: FilmTitle(widget._filmTitle, widget._filmYear),
        subtitle: Text("Director: Name Here\nStaring: Name Here"),
        isThreeLine: true,
        trailing: _MoreButton(),
      ),
    );
  }

  void addToQueue(BuildContext context) {
    //TODO: make faster?
    int i = 0;
    for (; i < searchList.length; i++) {
      if (searchList[i].getId() == widget._filmId) {
        break;
      }
    }

    filmQ.add(searchList[i]);
    Scaffold.of(context)
        .showSnackBar(SnackBar(content: Text("added to Queue")));
  }
}

class _MoreButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.more_horiz),
      disabledColor: Colors.greenAccent,
      hoverColor: Colors.black,
      tooltip: "view options",

      //THIS MIGHT NOT BE WORKING EVERYTIME!
      onPressed: () {
        Slidable.of(context).open();
      },
      color: Colors.black54,
    );
  }
}

class FilmTitle extends StatelessWidget {
  String _title;
  int _year;

  FilmTitle(this._title, this._year);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: _title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: " (" + _year.toString() + ")",
            ),
          ],
        ),
      ),
    );
  }
}
