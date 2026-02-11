// lib/utils/pdf_generator.dart
// Generator PDF A3 professionnel pour les rapports AgriFarm
// Format A3 centré et justifié avec structure claire

import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../models/rapport.dart';

/// Service de generation de PDF professionnel A3
class PdfGenerator {
  // Couleurs AgriFarm
  static const PdfColor primaryGreen = PdfColor.fromInt(0xFF21A84D);
  static const PdfColor darkGreen = PdfColor.fromInt(0xFF1B5E20);
  static const PdfColor lightGreen = PdfColor.fromInt(0xFFE8F5E9);
  static const PdfColor lightGreenBorder = PdfColor.fromInt(0xFF81C784);
  static const PdfColor grayLight = PdfColor.fromInt(0xFFF3F4F6);
  static const PdfColor grayDark = PdfColor.fromInt(0xFF374151);
  static const PdfColor textWhite = PdfColor.fromInt(0xFFFFFFFF); 
  static const PdfColor textWhiteDim = PdfColor.fromInt(0xFFE0E0E0);
  
  /// Generer un PDF A3 professionnel a partir d'un rapport
  static Future<Uint8List> generateRapportPdf(Rapport rapport) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a3.copyWith(
          marginTop: 30,
          marginBottom: 30,
          marginLeft: 40,
          marginRight: 40,
        ),
        build: (context) => [
          _buildHeader(rapport),
          pw.SizedBox(height: 25),
          _buildInfoSection(rapport),
          pw.SizedBox(height: 20),
          if (rapport.aDonneesMeteo) ...[
            _buildMeteoSection(rapport),
            pw.SizedBox(height: 20),
          ],
          _buildContentSection(rapport),
          pw.SizedBox(height: 20),
          _buildMetaSection(rapport),
        ],
        footer: (context) => _buildFooter(context),
      ),
    );

    return pdf.save();
  }

  /// Construire l'en-tete professionnel (fond vert, texte centré)
  static pw.Widget _buildHeader(Rapport rapport) {
    return pw.Center(
      child: pw.Container(
        width: double.infinity,
        decoration: pw.BoxDecoration(
          color: primaryGreen,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        ),
        padding: const pw.EdgeInsets.all(30),
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              'AGRI FARM',
              style: pw.TextStyle(
                color: textWhite,
                fontSize: 36,
                fontWeight: pw.FontWeight.bold,
                fontStyle: pw.FontStyle.normal,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'RAPPORT AGRICOLE',
              style: pw.TextStyle(
                color: textWhite,
                fontSize: 22,
                fontStyle: pw.FontStyle.normal,
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Text(
              rapport.periodeDisplay.toUpperCase(),
              style: pw.TextStyle(
                color: textWhite,
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                fontStyle: pw.FontStyle.normal,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              rapport.dateCompleteFormatee,
              style: pw.TextStyle(
                color: textWhiteDim,
                fontSize: 14,
                fontStyle: pw.FontStyle.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construire la section d'informations generales (centrée)
  static pw.Widget _buildInfoSection(Rapport rapport) {
    return pw.Center(
      child: pw.Container(
        width: double.infinity,
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        ),
        padding: const pw.EdgeInsets.all(22),
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Container(
                  width: 5,
                  height: 22,
                  decoration: pw.BoxDecoration(
                    color: primaryGreen,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
                  ),
                ),
                pw.SizedBox(width: 12),
                pw.Text(
                  'INFORMATIONS DU RAPPORT',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryGreen,
                    fontStyle: pw.FontStyle.normal,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 18),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 18),
            pw.Wrap(
              alignment: pw.WrapAlignment.spaceBetween,
              spacing: 40,
              runSpacing: 15,
              children: [
                _buildInfoItemCentered('Titre', rapport.titre),
                _buildInfoItemCentered('Periode', rapport.periodeDisplay),
                _buildInfoItemCentered('Date', rapport.dateCompleteFormatee),
                _buildInfoItemCentered('Statut', rapport.statusDisplay),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Construire un element d'information centré
  static pw.Widget _buildInfoItemCentered(String label, String value) {
    return pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 11,
            color: PdfColors.grey,
            fontStyle: pw.FontStyle.normal,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 13,
            fontWeight: pw.FontWeight.bold,
            color: grayDark,
            fontStyle: pw.FontStyle.normal,
          ),
        ),
      ],
    );
  }

  /// Construire la section meteorologique (centrée)
  static pw.Widget _buildMeteoSection(Rapport rapport) {
    return pw.Center(
      child: pw.Container(
        width: double.infinity,
        decoration: pw.BoxDecoration(
          color: lightGreen,
          border: pw.Border.all(color: lightGreenBorder),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        ),
        padding: const pw.EdgeInsets.all(22),
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Container(
                  width: 5,
                  height: 22,
                  decoration: pw.BoxDecoration(
                    color: primaryGreen,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
                  ),
                ),
                pw.SizedBox(width: 12),
                pw.Text(
                  'CONDITIONS METEOROLOGIQUES',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryGreen,
                    fontStyle: pw.FontStyle.normal,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Wrap(
              alignment: pw.WrapAlignment.spaceEvenly,
              spacing: 60,
              runSpacing: 15,
              children: [
                if (rapport.temperature != null)
                  _buildMeteoItemCentered('Temperature', '${rapport.temperature!.toStringAsFixed(1)} C'),
                if (rapport.humidite != null)
                  _buildMeteoItemCentered('Humidite', '${rapport.humidite}%'),
                if (rapport.conditions != null)
                  _buildMeteoItemCentered('Conditions', rapport.conditions!),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Construire un element meteorologique centré
  static pw.Widget _buildMeteoItemCentered(String label, String value) {
    return pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 22,
            fontWeight: pw.FontWeight.bold,
            color: darkGreen,
            fontStyle: pw.FontStyle.normal,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 12,
            color: grayDark,
            fontStyle: pw.FontStyle.normal,
          ),
        ),
      ],
    );
  }

  /// Construire la section de contenu (justifiée)
  static pw.Widget _buildContentSection(Rapport rapport) {
    String cleanContent = _cleanContent(rapport.contenu);
    
    return pw.Center(
      child: pw.Container(
        width: double.infinity,
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        ),
        padding: const pw.EdgeInsets.all(22),
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Container(
                  width: 5,
                  height: 22,
                  decoration: pw.BoxDecoration(
                    color: primaryGreen,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
                  ),
                ),
                pw.SizedBox(width: 12),
                pw.Text(
                  'CONTENU DU RAPPORT',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryGreen,
                    fontStyle: pw.FontStyle.normal,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(18),
              decoration: pw.BoxDecoration(
                color: grayLight,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Text(
                cleanContent,
                style: pw.TextStyle(
                  fontSize: 11,
                  lineSpacing: 2.0,
                  color: grayDark,
                  fontStyle: pw.FontStyle.normal,
                ),
                textAlign: pw.TextAlign.justify,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Verifier si un caractere Unicode est un emoji
  static bool _isEmoji(int codeUnit) {
    // Emojis et symboles etranges (U+1F300 à U+1F9FF)
    if (codeUnit >= 0x1F300 && codeUnit <= 0x1F9FF) {
      return true;
    }
    // Emojis supplementaires (U+1FA00 à U+1FAFF)
    if (codeUnit >= 0x1FA00 && codeUnit <= 0x1FAFF) {
      return true;
    }
    // Selecteurs de variation (U+FE00 à U+FE0F) souvent utilisés avec les emojis
    if (codeUnit >= 0xFE00 && codeUnit <= 0xFE0F) {
      return true;
    }
    // Symbole emoji keycap (U+20E3)
    if (codeUnit == 0x20E3) {
      return true;
    }
    return false;
  }

  /// Nettoyer le contenu en supprimant les caracteres Unicode problematiques et les emojis
  static String _cleanContent(String content) {
    StringBuffer cleanedBuffer = StringBuffer();
    
    for (int i = 0; i < content.length; i++) {
      int codeUnit = content.codeUnitAt(i);
      bool shouldSkip = false;
      
      // Vérifier les caractères de contrôle (U+0000 à U+001F, U+007F)
      if (codeUnit <= 0x1F || codeUnit == 0x7F) {
        shouldSkip = true;
      }
      // Box-drawing characters (U+2500 à U+257F)
      else if (codeUnit >= 0x2500 && codeUnit <= 0x257F) {
        shouldSkip = true;
      }
      // Block characters (U+2580 à U+259F)
      else if (codeUnit >= 0x2580 && codeUnit <= 0x259F) {
        shouldSkip = true;
      }
      // Misc symbols (U+2600 à U+27BF)
      else if (codeUnit >= 0x2600 && codeUnit <= 0x27BF) {
        shouldSkip = true;
      }
      // Emojis et symboles etendus (U+1F300 à U+1F9FF)
      else if (codeUnit >= 0x1F300 && codeUnit <= 0x1F9FF) {
        shouldSkip = true;
      }
      // Emojis supplementaires (U+1FA00 à U+1FAFF)
      else if (codeUnit >= 0x1FA00 && codeUnit <= 0x1FAFF) {
        shouldSkip = true;
      }
      // Private use area (U+E000 à U+F8FF)
      else if (codeUnit >= 0xE000 && codeUnit <= 0xF8FF) {
        shouldSkip = true;
      }
      // Variation selectors (U+FE00 à U+FE0F)
      else if (codeUnit >= 0xFE00 && codeUnit <= 0xFE0F) {
        shouldSkip = true;
      }
      // Symbole keycap (U+20E3)
      else if (codeUnit == 0x20E3) {
        shouldSkip = true;
      }
      
      if (!shouldSkip) {
        cleanedBuffer.writeCharCode(codeUnit);
      }
    }
    
    String cleaned = cleanedBuffer.toString()
      // Remplacer euro par "euros"
      .replaceAll('€', 'euros')
      // Remplacer degrees
      .replaceAll('°C', ' C');
    
    // Nettoyer les listes et caracteres speciaux
    cleaned = cleaned
      .replaceAll(RegExp(r'[0-9]+\.\s*'), '')
      .replaceAll(RegExp(r'[0-9]+\)'), '')
      .replaceAll(RegExp(r'[•·‣]'), '-');
    
    // Supprimer les separateurs repetitifs
    cleaned = cleaned.replaceAll(RegExp(r'[-═─]{3,}'), '');
    
    // Normaliser les sauts de ligne
    cleaned = cleaned
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .replaceAll(RegExp(r'[ \t]+'), ' ')
      .trim();
    
    // Supprimer les lignes vides composees uniquement de tirets
    cleaned = cleaned.split('\n')
      .where((line) => !line.trim().isEmpty && !line.trim().replaceAll('-', '').isEmpty)
      .join('\n');
    
    return cleaned;
  }

  /// Construire la section des metadonnees (centrée)
  static pw.Widget _buildMetaSection(Rapport rapport) {
    return pw.Center(
      child: pw.Container(
        width: double.infinity,
        decoration: pw.BoxDecoration(
          color: grayLight,
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        ),
        padding: const pw.EdgeInsets.all(22),
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Container(
                  width: 5,
                  height: 22,
                  decoration: pw.BoxDecoration(
                    color: darkGreen,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
                  ),
                ),
                pw.SizedBox(width: 12),
                pw.Text(
                  'INFORMATIONS COMPLEMENTAIRES',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: darkGreen,
                    fontStyle: pw.FontStyle.normal,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 18),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 18),
            pw.Wrap(
              alignment: pw.WrapAlignment.spaceEvenly,
              spacing: 50,
              runSpacing: 15,
              children: [
                _buildMetaItemCentered('Statut', rapport.statusDisplay),
                _buildMetaItemCentered('Caracteres', '${rapport.tailleContenu}'),
                _buildMetaItemCentered('Reference', '#R${rapport.id}'),
                _buildMetaItemCentered('Genere le', rapport.dateCompleteFormatee),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Construire un element de metadonnee centré
  static pw.Widget _buildMetaItemCentered(String label, String value) {
    return pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey,
            fontStyle: pw.FontStyle.normal,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: grayDark,
            fontStyle: pw.FontStyle.normal,
          ),
        ),
      ],
    );
  }

  /// Construire le pied de page (centré)
  static pw.Widget _buildFooter(pw.Context context) {
    final now = DateTime.now();
    final formattedDate = DateFormat('dd/MM/yyyy').format(now);
    
    return pw.Center(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 10),
        decoration: pw.BoxDecoration(
          border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'AgriFarm - Gestion Agricole Intelligente',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey,
                fontStyle: pw.FontStyle.normal,
              ),
            ),
            pw.Text(
              '$formattedDate  |  Page ${context.pageNumber}/${context.pagesCount}',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey,
                fontStyle: pw.FontStyle.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Sauvegarder le PDF dans un fichier
  static Future<String> savePdfToFile({
    required Uint8List pdfBytes,
    required String fileName,
  }) async {
    try {
      final directory = await _getDownloadDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(pdfBytes);
      return file.path;
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde du PDF: $e');
    }
  }

  /// Obtenir le repertoire de telechargements - utilise path_provider pour compatibilite multi-plateforme
  static Future<Directory> _getDownloadDirectory() async {
    try {
      // Pour les applications mobiles, essayer d'utiliser le repertoire de documents externes
      if (Platform.isAndroid || Platform.isIOS) {
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          final downloadDir = Directory('${externalDir.path}/Download/AgriFarm_Rapports');
          if (!await downloadDir.exists()) {
            await downloadDir.create(recursive: true);
          }
          return downloadDir;
        }
      }
      
      // Pour desktop et autres plateformes, utiliser le repertoire de documents
      final docsDir = await getApplicationDocumentsDirectory();
      final downloadDir = Directory('${docsDir.path}/AgriFarm_Rapports');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      return downloadDir;
      
    } catch (e) {
      // Fallback vers le repertoire temporaire
      final tempDir = await getTemporaryDirectory();
      final downloadDir = Directory('${tempDir.path}/AgriFarm_Rapports');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      return downloadDir;
    }
  }

  /// Generer le nom de fichier PDF
  static String generateFileName(Rapport rapport) {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final safeTitle = rapport.titre.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').toLowerCase();
    return 'agrifarm_rapport_${safeTitle}_$timestamp.pdf';
  }
}
