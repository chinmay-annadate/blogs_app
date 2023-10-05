import 'package:flutter/material.dart';

class Details extends StatefulWidget {
  const Details({super.key, required this.post});

  final Map post;

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.post['title'])),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            widget.post['image_url'],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.post['title'],
              style: const TextStyle(fontSize: 24),
            ),
          )
        ],
      ),
    );
  }
}
