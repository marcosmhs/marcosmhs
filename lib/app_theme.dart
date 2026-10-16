import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class AppColors {
  static const Color primary = Color(0xFF667EEA);
  static const Color secondary = Color(0xFF764BA2);
  static const Color background = Color(0xFFF9FAFB); // bg-gray-50
  static const Color textPrimary = Color(0xFF1F2937); // text-gray-800
  static const Color textSecondary = Color(0xFF4B5563); // text-gray-600
  static const Color cardBackground = Colors.white;
  static const Color footerBackground = Color(0xFF1F2937); // bg-gray-800
}

/// Classe que centraliza a definição do tema do aplicativo.
class AppTheme {
  // Tornando o construtor privado para que a classe não possa ser instanciada.
  AppTheme._();

  /// Define o tema claro completo para a aplicação.
  static ThemeData get lightTheme {
    return ThemeData(
      // Ativa o Material 3 para um visual mais moderno.
      useMaterial3: true,
      
      // Define a paleta de cores principal baseada em AppColors.
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.cardBackground, // Cor de fundo para componentes como Card, Dialog, etc.
        onPrimary: Colors.white, // Cor do texto/ícones sobre a cor primária
        onSecondary: Colors.white, // Cor do texto/ícones sobre a cor secundária
        onSurface: AppColors.textPrimary, // Cor do texto sobre superfícies
        error: const Color(0xFFD32F2F), // Cor padrão para erros
        onError: Colors.white,
        brightness: Brightness.light,
      ),

      // Cor de fundo padrão para a maioria das telas.
      scaffoldBackgroundColor: AppColors.background,

      // Tipografia global usando Google Fonts (Poppins, como no exemplo original).
      // Isso garante que todos os textos no app sigam um padrão.
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        // Títulos grandes (Ex: "João Silva" no Hero)
        displayLarge: GoogleFonts.poppins(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 60),
        // Títulos de seção (Ex: "Sobre Mim")
        headlineLarge: GoogleFonts.poppins(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 40),
        headlineMedium: GoogleFonts.poppins(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 32),
        // Títulos de cards ou itens de lista
        titleLarge: GoogleFonts.poppins(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 22),
        // Corpo de texto principal
        bodyLarge: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 18, height: 1.5),
        bodyMedium: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 16, height: 1.5),
        // Texto para botões
        labelLarge: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
      ),

      // Tema para a barra de aplicativos (AppBar).
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary, // Cor para ícones e título padrão
        elevation: 4.0,
        shadowColor: Colors.black.withAlpha(25),
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Tema para botões elevados (ElevatedButton).
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),

      // Tema para botões de texto (TextButton).
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      
      // Tema para Cards.
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0, // A sombra será controlada pelo HoverCard ou BoxDecoration
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      
      // Tema para campos de entrada de texto (TextField).
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: TextStyle(color: AppColors.textSecondary),
      ),

      // Tema para Chips (ótimo para as tags de habilidades).
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primary.withAlpha(25),
        labelStyle: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide.none,
      ),

      // Adapta a densidade dos componentes para diferentes plataformas.
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}