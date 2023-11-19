import 'package:flutter/material.dart';

class ArticleImage extends StatelessWidget {
  final String imagePath;
  const ArticleImage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.all(1.75),
      child: SizedBox(
        height: size.height * 0.18,
        width: size.width * 0.18,
        child: Image.network(
          imagePath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
