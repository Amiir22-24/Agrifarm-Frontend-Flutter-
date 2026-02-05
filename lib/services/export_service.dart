// lib/services/export_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/rapport.dart';
import '../utils/rapport_messages.dart';

/// Service d'export pour les rapports en différents formats
class ExportService {
  /// Export en format texte (base64) - Compatible avec toutes les plateformes
  static Future<String> exportToText(Rapport rapport) async {
    try {
      final directory = await _getExportDirectory();
      final fileName = 'rapport_${rapport.titre.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.txt';
      final file = File('${directory.path}/$fileName');

      final textContent = _generateTextContent(rapport);
      await file.writeAsString(textContent);

      return file.path;
    } catch (e) {
      throw Exception('Erreur export texte: $e');
    }
  }

  /// Export en format HTML amélioré
  static Future<String> exportToHtml(Rapport rapport) async {
    try {
      final directory = await _getExportDirectory();
      final fileName = 'rapport_${rapport.titre.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.html';
      final file = File('${directory.path}/$fileName');

      final htmlContent = _generateHtmlContent(rapport);
      await file.writeAsString(htmlContent);

      return file.path;
    } catch (e) {
      throw Exception('Erreur export HTML: $e');
    }
  }

  /// Export en format Markdown
  static Future<String> exportToMarkdown(Rapport rapport) async {
    try {
      final directory = await _getExportDirectory();
      final fileName = 'rapport_${rapport.titre.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.md';
      final file = File('${directory.path}/$fileName');

      final markdownContent = _generateMarkdownContent(rapport);
      await file.writeAsString(markdownContent);

      return file.path;
    } catch (e) {
      throw Exception('Erreur export Markdown: $e');
    }
  }

  /// Export avec choix du format
  static Future<String> exportWithFormat({
    required Rapport rapport,
    required ExportFormat format,
  }) async {
    switch (format) {
      case ExportFormat.txt:
        return await exportToText(rapport);
      case ExportFormat.html:
        return await exportToHtml(rapport);
      case ExportFormat.markdown:
        return await exportToMarkdown(rapport);
    }
  }

  /// Partager un fichier (simulation simple)
  static Future<void> shareFile(String filePath, String fileName) async {
    try {
      // Dans un vrai projet, on utiliserait share_plus
      // Pour l'instant, on simule le partage
      print('Partage simulé: $filePath');
    } catch (e) {
      throw Exception('Erreur partage: $e');
    }
  }

  /// Générer le contenu texte simple
  static String _generateTextContent(Rapport rapport) {
    return '''
AGRI FARM - RAPPORT AGRICOLE
==================================================

TITRE: ${rapport.titre}
PÉRIODE: ${rapport.periodeDisplay}
DATE DE CRÉATION: ${rapport.dateCompleteFormatee}
ID: ${rapport.id}
UTILISATEUR: ${rapport.userId}

${rapport.aDonneesMeteo ? '''
CONDITIONS MÉTÉOROLOGIQUES
==================================================
🌡️ Température: ${rapport.temperature?.toStringAsFixed(1) ?? 'N/A'}°C
💧 Humidité: ${rapport.humidite ?? 'N/A'}%
☁️ Conditions: ${rapport.conditions ?? 'N/A'}
''' : ''}

CONTENU DU RAPPORT
==================================================
${rapport.contenu}

${rapport.aAiPrompt ? '''
PROMPT IA UTILISÉ
==================================================
${rapport.aiPrompt}
''' : ''}

MÉTADONNÉES
==================================================
Statut: ${rapport.statusDisplay}
Taille du contenu: ${rapport.tailleContenu} caractères
Téléchargeable: ${rapport.aTelechargement ? 'Oui' : 'Non'}

==================================================
Généré par AgriFarm App - ${DateTime.now().toString().split(' ')[0]}
Rapport agricole automatisé par intelligence artificielle
    ''';
  }

  /// Générer le contenu HTML amélioré
  static String _generateHtmlContent(Rapport rapport) {
    return '''
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${rapport.titre}</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            line-height: 1.6;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            color: #333;
            background-color: #fff;
        }
        .header {
            background: linear-gradient(135deg, #7c3aed 0%, #a855f7 100%);
            color: white;
            padding: 30px;
            border-radius: 12px;
            margin-bottom: 30px;
            text-align: center;
        }
        .logo {
            font-size: 2em;
            margin-bottom: 10px;
        }
        .title {
            font-size: 28px;
            font-weight: bold;
            margin: 0;
        }
        .subtitle {
            font-size: 16px;
            opacity: 0.9;
            margin: 5px 0 0 0;
        }
        .card {
            background: white;
            border-radius: 12px;
            padding: 24px;
            margin: 20px 0;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            border-left: 4px solid #7c3aed;
        }
        .info-card {
            border-left-color: #3b82f6;
        }
        .meteo-card {
            border-left-color: #f59e0b;
            background: linear-gradient(135deg, #fff7ed 0%, #fed7aa 100%);
        }
        .content-card {
            border-left-color: #10b981;
        }
        .meta-card {
            border-left-color: #6b7280;
            background: #f9fafb;
        }
        .section-title {
            font-size: 20px;
            font-weight: bold;
            color: #1f2937;
            margin-bottom: 16px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .label {
            font-weight: 600;
            color: #374151;
        }
        .value {
            color: #111827;
        }
        .content-text {
            background: #f9fafb;
            padding: 20px;
            border-radius: 8px;
            border: 1px solid #e5e7eb;
            white-space: pre-wrap;
            font-family: 'Monaco', 'Consolas', monospace;
            font-size: 14px;
            line-height: 1.5;
        }
        .meta-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 12px;
        }
        .meta-item {
            padding: 12px;
            background: white;
            border-radius: 6px;
            border: 1px solid #e5e7eb;
        }
        .footer {
            text-align: center;
            margin-top: 40px;
            padding-top: 30px;
            border-top: 2px solid #e5e7eb;
            color: #6b7280;
            font-size: 14px;
        }
        .ai-prompt {
            background: linear-gradient(135deg, #f3e8ff 0%, #e9d5ff 100%);
            border: 1px solid #c084fc;
            border-radius: 8px;
            padding: 16px;
            font-style: italic;
            color: #7c3aed;
            margin: 16px 0;
        }
        @media (max-width: 768px) {
            body { padding: 15px; }
            .header { padding: 20px; }
            .title { font-size: 24px; }
            .card { padding: 20px; }
            .meta-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
    <div class="header">
        <div class="logo">🌱</div>
        <h1 class="title">${rapport.titre}</h1>
        <p class="subtitle">Généré par AgriFarm App</p>
    </div>

    <div class="card info-card">
        <div class="section-title">
            📋 Informations Générales
        </div>
        <div class="meta-grid">
            <div class="meta-item">
                <span class="label">Période:</span> <span class="value">${rapport.periodeDisplay}</span>
            </div>
            <div class="meta-item">
                <span class="label">Créé le:</span> <span class="value">${rapport.dateCompleteFormatee}</span>
            </div>
            <div class="meta-item">
                <span class="label">ID:</span> <span class="value">${rapport.id}</span>
            </div>
            <div class="meta-item">
                <span class="label">Utilisateur:</span> <span class="value">${rapport.userId}</span>
            </div>
        </div>
    </div>

    ${rapport.aDonneesMeteo ? '''
    <div class="card meteo-card">
        <div class="section-title">
            🌤️ Conditions Météorologiques
        </div>
        <div class="meta-grid">
            ${rapport.temperature != null ? '''
            <div class="meta-item">
                <span class="label">🌡️ Température:</span> <span class="value">${rapport.temperature!.toStringAsFixed(1)}°C</span>
            </div>
            ''' : ''}
            ${rapport.humidite != null ? '''
            <div class="meta-item">
                <span class="label">💧 Humidité:</span> <span class="value">${rapport.humidite}%</span>
            </div>
            ''' : ''}
            ${rapport.conditions != null ? '''
            <div class="meta-item">
                <span class="label">☁️ Conditions:</span> <span class="value">${rapport.conditions!}</span>
            </div>
            ''' : ''}
        </div>
    </div>
    ''' : ''}

    <div class="card content-card">
        <div class="section-title">
            📄 Contenu du Rapport
        </div>
        <div class="content-text">${rapport.contenu}</div>
    </div>

    ${rapport.aAiPrompt ? '''
    <div class="card">
        <div class="section-title">
            🤖 Prompt IA Utilisé
        </div>
        <div class="ai-prompt">
            ${rapport.aiPrompt}
        </div>
    </div>
    ''' : ''}

    <div class="card meta-card">
        <div class="section-title">
            📊 Métadonnées
        </div>
        <div class="meta-grid">
            <div class="meta-item">
                <span class="label">Statut:</span> <span class="value">${rapport.statusDisplay}</span>
            </div>
            <div class="meta-item">
                <span class="label">Taille du contenu:</span> <span class="value">${rapport.tailleContenu} caractères</span>
            </div>
            <div class="meta-item">
                <span class="label">Téléchargeable:</span> <span class="value">${rapport.aTelechargement ? '✅ Oui' : '❌ Non'}</span>
            </div>
            <div class="meta-item">
                <span class="label">Période:</span> <span class="value">${rapport.iconePeriode} ${rapport.periodeDisplay}</span>
            </div>
        </div>
    </div>

    <div class="footer">
        <p><strong>Généré par AgriFarm App</strong></p>
        <p>${DateTime.now().toString().split(' ')[0]} - Rapport agricole automatisé par intelligence artificielle</p>
        <p>🌱 <em>Pour une agriculture intelligente et durable</em></p>
    </div>
</body>
</html>
    ''';
  }

  /// Générer le contenu Markdown
  static String _generateMarkdownContent(Rapport rapport) {
    return '''
# 🌱 ${rapport.titre}

*Généré par AgriFarm App*

---

## 📋 Informations Générales

| Élément | Valeur |
|---------|--------|
| **Période** | ${rapport.periodeDisplay} |
| **Créé le** | ${rapport.dateCompleteFormatee} |
| **ID** | ${rapport.id} |
| **Utilisateur** | ${rapport.userId} |

${rapport.aDonneesMeteo ? '''
## 🌤️ Conditions Météorologiques

| Paramètre | Valeur |
|-----------|--------|
| 🌡️ **Température** | ${rapport.temperature?.toStringAsFixed(1) ?? 'N/A'}°C |
| 💧 **Humidité** | ${rapport.humidite ?? 'N/A'}% |
| ☁️ **Conditions** | ${rapport.conditions ?? 'N/A'} |
''' : ''}

## 📄 Contenu du Rapport

```
${rapport.contenu}
```

${rapport.aAiPrompt ? '''
## 🤖 Prompt IA Utilisé

> ${rapport.aiPrompt}
''' : ''}

## 📊 Métadonnées

| Propriété | Valeur |
|-----------|--------|
| **Statut** | ${rapport.statusDisplay} |
| **Taille du contenu** | ${rapport.tailleContenu} caractères |
| **Téléchargeable** | ${rapport.aTelechargement ? '✅ Oui' : '❌ Non'} |
| **Période** | ${rapport.iconePeriode} ${rapport.periodeDisplay} |

---

*Généré par AgriFarm App le ${DateTime.now().toString().split(' ')[0]}*
*Rapport agricole automatisé par intelligence artificielle*

---

**🌱 Pour une agriculture intelligente et durable**
    ''';
  }

  /// Obtenir le répertoire d'export
  static Future<Directory> _getExportDirectory() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        // Pour mobile, utiliser le répertoire de téléchargement
        final directory = await getExternalStorageDirectory();
        if (directory != null) {
          final exportDir = Directory('${directory.path}/Download/AgriFarm_Rapports');
          if (!await exportDir.exists()) {
            await exportDir.create(recursive: true);
          }
          return exportDir;
        }
      }
      
      // Pour desktop/web, utiliser le répertoire de documents
      final directory = await getApplicationDocumentsDirectory();
      final exportDir = Directory('${directory.path}/AgriFarm_Rapports');
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }
      return exportDir;
    } catch (e) {
      // Fallback vers le répertoire temporaire
      final tempDir = await getTemporaryDirectory();
      final exportDir = Directory('${tempDir.path}/AgriFarm_Rapports');
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }
      return exportDir;
    }
  }

  /// Obtenir la liste des formats d'export supportés
  static List<ExportFormat> getSupportedFormats() {
    return ExportFormat.values;
  }

  /// Obtenir les informations sur un format
  static Map<ExportFormat, ExportFormatInfo> getFormatInfo() {
    return {
      ExportFormat.txt: ExportFormatInfo(
        extension: 'txt',
        mimeType: 'text/plain',
        description: RapportMessages.word, // Réutiliser les messages
        icon: Icons.description,
      ),
      ExportFormat.html: ExportFormatInfo(
        extension: 'html',
        mimeType: 'text/html',
        description: 'HTML',
        icon: Icons.web,
      ),
      ExportFormat.markdown: ExportFormatInfo(
        extension: 'md',
        mimeType: 'text/markdown',
        description: 'Markdown',
        icon: Icons.text_fields,
      ),
    };
  }
}

/// Formats d'export supportés
enum ExportFormat {
  txt,
  html,
  markdown,
}

/// Informations sur un format d'export
class ExportFormatInfo {
  final String extension;
  final String mimeType;
  final String description;
  final IconData icon;

  const ExportFormatInfo({
    required this.extension,
    required this.mimeType,
    required this.description,
    required this.icon,
  });
}

/// Widget de sélection de format d'export
class ExportFormatSelector extends StatelessWidget {
  final Rapport rapport;
  final Function(String filePath) onExportComplete;

  const ExportFormatSelector({
    Key? key,
    required this.rapport,
    required this.onExportComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatInfo = ExportService.getFormatInfo();

    return AlertDialog(
      title: Text(RapportMessages.export),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Exporter "${rapport.titre}" en:',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ...ExportFormat.values.map((format) {
            final info = formatInfo[format]!;
            return ListTile(
              leading: Icon(info.icon, color: Theme.of(context).primaryColor),
              title: Text(info.description),
              subtitle: Text('.${info.extension}'),
              onTap: () => _exportWithFormat(context, format),
            );
          }).toList(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(RapportMessages.supprimer.replaceAll('Supprimer', 'Annuler')),
        ),
      ],
    );
  }

  void _exportWithFormat(BuildContext context, ExportFormat format) async {
    Navigator.of(context).pop();
    
    try {
      final filePath = await ExportService.exportWithFormat(
        rapport: rapport,
        format: format,
      );
      
      // Utiliser les messages centralisés
      context.showRapportSuccess(
        '${RapportMessages.rapportTelecharge}: ${filePath.split('/').last}'
      );
      
      onExportComplete(filePath);
    } catch (e) {
      context.showRapportError(
        '${RapportMessages.telechargementEchoue}: $e'
      );
    }
  }
}
