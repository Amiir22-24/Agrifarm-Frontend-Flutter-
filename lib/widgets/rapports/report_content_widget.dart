// lib/widgets/rapports/report_content_widget.dart
import 'package:flutter/material.dart';

/// Widget pour afficher le contenu formaté du rapport avec émojis et sections
/// Le contenu est formaté avec des émojis par le backend
class ReportContentWidget extends StatelessWidget {
  final String contenu;
  final bool selectable;
  final TextStyle? customStyle;
  final EdgeInsetsGeometry? padding;

  const ReportContentWidget({
    Key? key,
    required this.contenu,
    this.selectable = true,
    this.customStyle,
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: padding,
      child: selectable
          ? SelectableText(
              contenu,
              style: customStyle ??
                  const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    height: 1.5,
                  ),
            )
          : Text(
              contenu,
              style: customStyle ??
                  const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    height: 1.5,
                  ),
            ),
    );
  }
}

/// Widget alternatif avec mise en forme structurée basée sur les émojis
class ReportContentFormatted extends StatelessWidget {
  final String contenu;
  final double fontSize;
  final double lineHeight;
  final bool showDividers;

  const ReportContentFormatted({
    Key? key,
    required this.contenu,
    this.fontSize = 14,
    this.lineHeight = 1.6,
    this.showDividers = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lines = contenu.split('\n');
    final widgets = <Widget>[];

    for (var line in lines) {
      // Lignes de séparateur (═, ─, etc.)
      if (_isDividerLine(line)) {
        if (showDividers) {
          widgets.add(const Divider(height: 24));
        }
      }
      // Titres de section (🌤️, 💰, 🌱, 🌾, 📦, 🔔, 📊)
      else if (_isSectionTitle(line)) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            line,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontSize + 2,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ));
      }
      // Sous-sections (1️⃣, 2️⃣, 3️⃣)
      else if (_isSubSection(line)) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4, left: 8),
          child: Text(
            line,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
              color: Colors.grey[800],
            ),
          ),
        ));
      }
      // Listes (commençant par •, -, ou contiennent •)
      else if (_isListItem(line)) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 20, top: 4, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '•  ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Expanded(
                child: Text(
                  line.trim().replaceAll(RegExp(r'^[\s•·‣-]+'), ''),
                  style: TextStyle(
                    fontSize: fontSize,
                    height: lineHeight,
                  ),
                ),
              ),
            ],
          ),
        ));
      }
      // Lignes de sous-titres dans les sections
      else if (_isSubTitle(line)) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4, left: 16),
          child: Text(
            line.trim(),
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: fontSize,
              color: Colors.grey[700],
            ),
          ),
        ));
      }
      // Lignes vides
      else if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
      }
      // Contenu normal
      else {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            line,
            style: TextStyle(
              fontSize: fontSize,
              height: lineHeight,
            ),
          ),
        ));
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ),
    );
  }

  bool _isDividerLine(String line) {
    return line.startsWith('═') ||
        line.startsWith('─') ||
        line.startsWith('──') ||
        line.startsWith('━━━━━━━━━━━━━━━━') ||
        line.trim().isEmpty && line.length > 10;
  }

  bool _isSectionTitle(String line) {
    return line.startsWith('🌤️') ||
        line.startsWith('💰') ||
        line.startsWith('🌱') ||
        line.startsWith('🌾') ||
        line.startsWith('📦') ||
        line.startsWith('🔔') ||
        line.startsWith('📊') ||
        line.startsWith('📋') ||
        line.startsWith('🚜') ||
        line.startsWith('🌍') ||
        line.startsWith('📈') ||
        line.startsWith('🔍') ||
        line.startsWith('💡') ||
        line.startsWith('⚠️') ||
        line.startsWith('✅');
  }

  bool _isSubSection(String line) {
    return line.startsWith('1️⃣') ||
        line.startsWith('2️⃣') ||
        line.startsWith('3️⃣') ||
        line.startsWith('4️⃣') ||
        line.startsWith('5️⃣');
  }

  bool _isListItem(String line) {
    return line.trim().startsWith('•') ||
        line.trim().startsWith('- ') ||
        line.trim().startsWith('·') ||
        (line.contains('•') && line.length < 50);
  }

  bool _isSubTitle(String line) {
    return line.startsWith('   -') ||
        line.trim().startsWith('-');
  }
}

/// Widget卡片 pour afficher une section spécifique du contenu
class ReportSectionWidget extends StatelessWidget {
  final String title;
  final String content;
  final IconData? icon;
  final Color? iconColor;
  final bool isExpandable;

  const ReportSectionWidget({
    Key? key,
    required this.title,
    required this.content,
    this.icon,
    this.iconColor,
    this.isExpandable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: iconColor ?? Theme.of(context).primaryColor),
              const SizedBox(width: 8),
            ],
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ReportContentWidget(contenu: content),
          ),
        ],
      ),
    );
  }
}

/// Widget pour prévisualiser le contenu avec un nombre limité de lignes
class ReportContentPreview extends StatelessWidget {
  final String contenu;
  final int maxLines;
  final VoidCallback? onSeeMore;

  const ReportContentPreview({
    Key? key,
    required this.contenu,
    this.maxLines = 5,
    this.onSeeMore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lines = contenu.split('\n');
    final displayLines = lines.take(maxLines).toList();
    final hasMore = lines.length > maxLines;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...displayLines.map((line) => Text(line)),
        if (hasMore) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onSeeMore,
            icon: const Icon(Icons.expand_more),
            label: const Text('Voir la suite'),
          ),
        ],
      ],
    );
  }
}

/// Widget de résumé du rapport avec les statistiques clés
class ReportSummaryWidget extends StatelessWidget {
  final String contenu;

  const ReportSummaryWidget({Key? key, required this.contenu}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extraire les informations clés du contenu
    final stats = _extractStats(contenu);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (stats['temperature'] != null)
          _buildStatItem(
            Icons.thermostat,
            'Température',
            '${stats['temperature']}°C',
            Colors.orange,
          ),
        if (stats['humidite'] != null)
          _buildStatItem(
            Icons.water_drop,
            'Humidité',
            '${stats['humidite']}%',
            Colors.blue,
          ),
        if (stats['conditions'] != null)
          _buildStatItem(
            Icons.wb_sunny,
            'Conditions',
            stats['conditions']!,
            Colors.yellow[700]!,
          ),
        if (stats['ventes'] != null)
          _buildStatItem(
            Icons.shopping_cart,
            'Ventes',
            stats['ventes']!,
            Colors.green,
          ),
        if (stats['cultures'] != null)
          _buildStatItem(
            Icons.grass,
            'Cultures',
            stats['cultures']!,
            Colors.lightGreen,
          ),
        if (stats['recoltes'] != null)
          _buildStatItem(
            Icons.agriculture,
            'Récoltes',
            stats['recoltes']!,
            Colors.brown,
          ),
      ],
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(color: Colors.grey[600]),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Map<String, String?> _extractStats(String contenu) {
    final stats = <String, String?>{};

    // Expressions régulières pour extraire les informations
    final temperatureReg = RegExp(r'Température[:\s]*([\d,]+)°?C?');
    final humiditeReg = RegExp(r'Humidité[:\s]*(\d+)%?');
    final conditionsReg = RegExp(r'Conditions[:\s]*([A-Za-zéèêëàâäùûüôöîï]+)');
    final ventesReg = RegExp(r'Nombre de transactions[:\s]*(\d+)');
    final culturesReg = RegExp(r'Cultures actives[:\s]*(\d+)');
    final recoltesReg = RegExp(r'Récoltes enregistrées[:\s]*(\d+)');

    final temperatureMatch = temperatureReg.firstMatch(contenu);
    final humiditeMatch = humiditeReg.firstMatch(contenu);
    final conditionsMatch = conditionsReg.firstMatch(contenu);
    final ventesMatch = ventesReg.firstMatch(contenu);
    final culturesMatch = culturesReg.firstMatch(contenu);
    final recoltesMatch = recoltesReg.firstMatch(contenu);

    if (temperatureMatch != null) {
      stats['temperature'] = temperatureMatch.group(1);
    }
    if (humiditeMatch != null) {
      stats['humidite'] = humiditeMatch.group(1);
    }
    if (conditionsMatch != null) {
      stats['conditions'] = conditionsMatch.group(1);
    }
    if (ventesMatch != null) {
      stats['ventes'] = '${ventesMatch.group(1)} transactions';
    }
    if (culturesMatch != null) {
      stats['cultures'] = '${culturesMatch.group(1)} actives';
    }
    if (recoltesMatch != null) {
      stats['recoltes'] = '${recoltesMatch.group(1)} récoltes';
    }

    return stats;
  }
}

