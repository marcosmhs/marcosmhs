import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const List<Color> _colorSeedList = [
  Color.fromARGB(255, 124, 24, 24),
  Color.fromARGB(255, 131, 42, 199),
  Color.fromARGB(255, 44, 189, 102),
  Color.fromARGB(255, 42, 89, 243),
  Color.fromARGB(255, 32, 185, 185),
];

/// Cor estável por card: a mesma semente gera sempre a mesma cor, evitando
/// que as cores mudem a cada rebuild da tela.
Color cardColorSeed(String seed) => _colorSeedList[seed.hashCode.abs() % _colorSeedList.length];

/// Imagem de cabeçalho dos cards; mostra um ícone quando não há URL ou o download falha.
class CardImageWidget extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final Color color;

  const CardImageWidget({super.key, required this.url, required this.fit, required this.color});

  @override
  Widget build(BuildContext context) {
    final placeholder = Icon(FontAwesomeIcons.image, size: 48, color: color);
    if (url.isEmpty) return placeholder;
    return Image.network(url, fit: fit, errorBuilder: (_, _, _) => placeholder);
  }
}
