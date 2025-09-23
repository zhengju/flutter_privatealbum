import 'package:flutter/material.dart';

class DraggableCard extends StatefulWidget {
  @override
  _DraggableCardState createState() => _DraggableCardState();
}

class _DraggableCardState extends State<DraggableCard> {
  double _left = 50;
  double _top = 100;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('可拖拽卡片')),
      body: Stack(
        children: [
          Positioned(
            left: _left,
            top: _top,
            child: GestureDetector(
              onPanStart: (details) {
                setState(() {
                  _isDragging = true;
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  _left += details.delta.dx;
                  _top += details.delta.dy;
                });
              },
              onPanEnd: (details) {
                setState(() {
                  _isDragging = false;
                });
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                width: 200,
                height: 150,
                decoration: BoxDecoration(
                  color: _isDragging ? Colors.blue[300] : Colors.blue,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: _isDragging ? 10 : 5,
                      offset: Offset(0, _isDragging ? 5 : 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '拖拽我',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
