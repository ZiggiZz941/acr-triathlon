import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:triathlon_app/models/sport_type.dart';
import 'package:triathlon_app/models/triathlon_resultat.dart';
import '../../models/triathlon_seance.dart';
import '../../models/triathlon_exercice.dart';
import '../../services/data_manager.dart';
import '../../constants/triathlon_colors.dart';

class SaisieResultatScreen extends StatefulWidget {
  final TriathlonSeance seance;

  const SaisieResultatScreen({
    super.key,
    required this.seance,
  });

  @override
  _SaisieResultatScreenState createState() => _SaisieResultatScreenState();
}

class _SaisieResultatScreenState extends State<SaisieResultatScreen> {
  late List<ExerciceSaisie> _exercicesSaisie;
  final Map<String, TextEditingController> _controllers = {};
  final TextEditingController _commentaireController = TextEditingController();
  bool _isLoading = true;
  final Map<String, Map<String, dynamic>> _resultatsExistant = {};
  String? _commentaireExistant;
  final FocusNode _commentaireFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _chargerDonneesExistantes();
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _commentaireController.dispose();
    _commentaireFocusNode.dispose();
    super.dispose();
  }

  Future<void> _chargerDonneesExistantes() async {
    final dataManager = Provider.of<DataManager>(context, listen: false);

    final resultatsExistants =
        dataManager.getResultatsForSeance(widget.seance.id);

    for (var resultat in resultatsExistants) {
      final key =
          '${resultat.exerciceId}_${resultat.serieIndex}_${resultat.repetitionIndex}';
      _resultatsExistant[key] = {
        'id': resultat.id,
        'tempsReel': resultat.tempsReel,
        'tempsAttenduMin': resultat.tempsAttenduMin,
        'tempsAttenduMax': resultat.tempsAttenduMax,
      };
    }

    final commentaireSeance =
        dataManager.getCommentaireForSeance(widget.seance.id);
    _commentaireExistant = commentaireSeance?.commentaire;
    _commentaireController.text = _commentaireExistant ?? '';

    _exercicesSaisie = [];

    for (var exercice in widget.seance.exercices) {
      final structure = _genererStructureResultatsPourExercice(exercice);

      final cases = structure.map((item) {
        final key = '${exercice.id}_${item['serie']}_${item['repetition']}';
        final resultatExistant = _resultatsExistant[key];

        double? tempsSaisi;
        double? tempsAttenduMin;
        double? tempsAttenduMax;
        int? resultatId;

        if (resultatExistant != null) {
          tempsSaisi = resultatExistant['tempsReel'] as double?;
          tempsAttenduMin = resultatExistant['tempsAttenduMin'] as double?;
          tempsAttenduMax = resultatExistant['tempsAttenduMax'] as double?;
          resultatId = resultatExistant['id'] as int?;
        }

        return CaseResultat(
          exerciceId: exercice.id,
          serieIndex: item['serie'],
          repetitionIndex: item['repetition'],
          tempsAttenduMin: tempsAttenduMin ?? item['attendus']['tempsMin'],
          tempsAttenduMax: tempsAttenduMax ?? item['attendus']['tempsMax'],
          tempsSaisi: tempsSaisi,
          resultatId: resultatId,
        );
      }).toList();

      _exercicesSaisie.add(ExerciceSaisie(
        exercice: exercice,
        cases: cases,
      ));

      for (var caseResultat in cases) {
        final key =
            '${caseResultat.exerciceId}_${caseResultat.serieIndex}_${caseResultat.repetitionIndex}';
        if (!_controllers.containsKey(key)) {
          _controllers[key] = TextEditingController(
            text: caseResultat.tempsSaisi != null
                ? _formatTemps(caseResultat.tempsSaisi!)
                : '',
          );
        }
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _genererStructureResultatsPourExercice(
      TriathlonExercice exercice) {
    List<Map<String, dynamic>> structure = [];

    for (int serie = 1; serie <= exercice.nbSeries; serie++) {
      for (int repetition = 1;
          repetition <= exercice.nbRepetitions;
          repetition++) {
        structure.add({
          'serie': serie,
          'repetition': repetition,
          'attendus': {
            'tempsMin': exercice.tempsMin,
            'tempsMax': exercice.tempsMax,
          },
        });
      }
    }

    return structure;
  }

  @override
  Widget build(BuildContext context) {
    final sportColor = widget.seance.sportType.color;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saisie des résultats'),
        backgroundColor: sportColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(sportColor),
    );
  }

  Widget _buildContent(Color sportColor) {
    final totalCases = _calculerTotalCases();
    final casesRemplies = _calculerCasesRemplies();

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      widget.seance.nom,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: sportColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Saisissez vos temps pour chaque répétition',
                      style: TextStyle(
                        color: TriathlonColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: totalCases > 0 ? casesRemplies / totalCases : 0,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(sportColor),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$casesRemplies/$totalCases remplis',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: sportColor,
                      ),
                    ),
                  ],
                ),
              ),
              ..._exercicesSaisie
                  .map((exerciceSaisie) => _buildExerciceCard(exerciceSaisie))
                  .toList(),
              _buildCommentaireSection(),
              const SizedBox(height: 100),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildSaveButton(sportColor),
        ),
      ],
    );
  }

  Widget _buildExerciceCard(ExerciceSaisie exerciceSaisie) {
    final sportColor = widget.seance.sportType.color;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.fitness_center,
                  color: sportColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    exerciceSaisie.exercice.nom,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              exerciceSaisie.exercice.getDescription(),
              style: TextStyle(
                color: TriathlonColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 600 ? 4 : 3;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: exerciceSaisie.cases.length,
                  itemBuilder: (context, index) {
                    final caseResultat = exerciceSaisie.cases[index];
                    final key =
                        '${caseResultat.exerciceId}_${caseResultat.serieIndex}_${caseResultat.repetitionIndex}';

                    final controller =
                        _controllers[key] ?? TextEditingController();
                    if (!_controllers.containsKey(key)) {
                      _controllers[key] = controller;
                    }

                    return _buildCaseResultat(caseResultat, controller);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentaireSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.comment,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Commentaire sur la séance (optionnel)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _commentaireController,
            focusNode: _commentaireFocusNode,
            maxLines: 3,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: 'Ajoutez vos impressions, difficultés, sensations...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.blue),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.clear,
                  color: Colors.grey[600],
                  size: 20,
                ),
                onPressed: () {
                  _commentaireController.clear();
                  _commentaireFocusNode.unfocus();
                },
              ),
              Text(
                '${_commentaireController.text.length}/500 caractères',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(Color sportColor) {
    final totalCases = _calculerTotalCases();
    final casesRemplies = _calculerCasesRemplies();

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _sauvegarderResultats,
          style: ElevatedButton.styleFrom(
            backgroundColor: sportColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            casesRemplies > 0
                ? 'MODIFIER LES RÉSULTATS ($casesRemplies/$totalCases)'
                : 'SAUVEGARDER LES RÉSULTATS',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCaseResultat(
      CaseResultat caseResultat, TextEditingController controller) {
    final estRempli = caseResultat.tempsSaisi != null;
    final tempsAttenduMin = caseResultat.tempsAttenduMin;
    final tempsAttenduMax = caseResultat.tempsAttenduMax;

    String texteAttendu;
    Color couleurAttendu;

    if (tempsAttenduMin == tempsAttenduMax) {
      texteAttendu = 'Attendu: ${_formatTemps(tempsAttenduMin)}';
      couleurAttendu = Colors.blue;
    } else {
      texteAttendu =
          'Attendu: ${_formatTemps(tempsAttenduMin)}-${_formatTemps(tempsAttenduMax)}';
      couleurAttendu = Colors.green;
    }

    return GestureDetector(
      onTap: () => _ouvrirSaisieDetaillee(caseResultat, controller),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: estRempli ? Colors.green : TriathlonColors.border,
            width: estRempli ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: estRempli ? Colors.green.shade50 : Colors.white,
          boxShadow: estRempli
              ? [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'S${caseResultat.serieIndex}R${caseResultat.repetitionIndex}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: estRempli ? Colors.green : TriathlonColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              estRempli ? _formatTemps(caseResultat.tempsSaisi!) : '--:--',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: estRempli ? Colors.green : TriathlonColors.textSecondary,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                texteAttendu,
                style: TextStyle(
                  fontSize: 10,
                  color: couleurAttendu,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _ouvrirSaisieDetaillee(
      CaseResultat caseResultat, TextEditingController controller) {
    final tempsActuel = controller.text;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
              'Série ${caseResultat.serieIndex} - Répétition ${caseResultat.repetitionIndex}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: TextEditingController(text: tempsActuel),
                  decoration: InputDecoration(
                    labelText: 'Temps réalisé (mm:ss)',
                    hintText: 'Ex: 8:30',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _effacerTemps(caseResultat, controller);
                      },
                    ),
                  ),
                  onChanged: (value) {
                    controller.text = value;
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '📊 Temps de référence',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (caseResultat.tempsAttenduMin ==
                          caseResultat.tempsAttenduMax)
                        Text(
                          'Attendu: ${_formatTemps(caseResultat.tempsAttenduMin)}',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                          ),
                        )
                      else
                        Column(
                          children: [
                            Text(
                              'Plage: ${_formatTemps(caseResultat.tempsAttenduMin)} à ${_formatTemps(caseResultat.tempsAttenduMax)}',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Idéal: Dans cette plage',
                              style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: Colors.blue.shade600,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildBoutonTempsRapide('8:00', caseResultat, controller),
                    _buildBoutonTempsRapide('8:30', caseResultat, controller),
                    _buildBoutonTempsRapide('9:00', caseResultat, controller),
                    _buildBoutonTempsRapide(
                        caseResultat.tempsAttenduMin > 0
                            ? _formatTemps(caseResultat.tempsAttenduMin)
                            : '8:30',
                        caseResultat,
                        controller),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                final temps = _parseTemps(controller.text);
                if (temps != null) {
                  setState(() {
                    caseResultat.tempsSaisi = temps;
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Valider'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBoutonTempsRapide(String temps, CaseResultat caseResultat,
      TextEditingController controller) {
    return ElevatedButton(
      onPressed: () {
        controller.text = temps;
        final tempsParsed = _parseTemps(temps);
        if (tempsParsed != null) {
          setState(() {
            caseResultat.tempsSaisi = tempsParsed;
          });
        }
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade100,
        foregroundColor: Colors.blue.shade800,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(temps),
    );
  }

  void _effacerTemps(
      CaseResultat caseResultat, TextEditingController controller) {
    setState(() {
      caseResultat.tempsSaisi = null;
      controller.clear();
    });
  }

  int _calculerTotalCases() {
    int total = 0;
    for (var exercice in widget.seance.exercices) {
      total += exercice.nbSeries * exercice.nbRepetitions;
    }
    return total;
  }

  int _calculerCasesRemplies() {
    int remplis = 0;
    for (var exerciceSaisie in _exercicesSaisie) {
      for (var caseResultat in exerciceSaisie.cases) {
        if (caseResultat.tempsSaisi != null) {
          remplis++;
        }
      }
    }
    return remplis;
  }

  String _formatTemps(double seconds) {
    int minutes = (seconds ~/ 60).toInt();
    int secs = (seconds % 60).toInt();
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  double? _parseTemps(String input) {
    try {
      final trimmed = input.trim();
      if (trimmed.isEmpty) return null;

      if (trimmed.contains(':')) {
        final parts = trimmed.split(':');
        if (parts.length == 2) {
          final minutes = int.parse(parts[0]);
          final seconds = int.parse(parts[1]);
          return (minutes * 60 + seconds).toDouble();
        }
      }
      return double.parse(trimmed);
    } catch (e) {
      return null;
    }
  }

  Future<void> _sauvegarderResultats() async {
    FocusScope.of(context).unfocus();

    final dataManager = Provider.of<DataManager>(context, listen: false);

    final List<TriathlonResultat> nouveauxResultats = [];
    int totalSauvegardes = 0;

    for (var exerciceSaisie in _exercicesSaisie) {
      for (var caseResultat in exerciceSaisie.cases) {
        if (caseResultat.tempsSaisi != null) {
          final nouveauResultat = TriathlonResultat(
            id: caseResultat.resultatId ??
                DateTime.now().millisecondsSinceEpoch + totalSauvegardes,
            seanceId: widget.seance.id,
            exerciceId: caseResultat.exerciceId,
            serieIndex: caseResultat.serieIndex,
            repetitionIndex: caseResultat.repetitionIndex,
            tempsReel: caseResultat.tempsSaisi!,
            tempsAttenduMin: caseResultat.tempsAttenduMin,
            tempsAttenduMax: caseResultat.tempsAttenduMax,
            dateRealisation: DateTime.now(),
            estComplete: true,
          );
          nouveauxResultats.add(nouveauResultat);
          totalSauvegardes++;
        }
      }
    }

    await dataManager.saveResultatsWithCommentaire(
      widget.seance.id,
      nouveauxResultats,
      commentaireText: _commentaireController.text.trim(),
    );

    if (mounted) {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            totalSauvegardes > 0
                ? '$totalSauvegardes résultats sauvegardés'
                : 'Aucun résultat à sauvegarder',
          ),
          backgroundColor: totalSauvegardes > 0 ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

class ExerciceSaisie {
  final TriathlonExercice exercice;
  final List<CaseResultat> cases;

  ExerciceSaisie({
    required this.exercice,
    required this.cases,
  });
}

class CaseResultat {
  final int exerciceId;
  final int serieIndex;
  final int repetitionIndex;
  final double tempsAttenduMin;
  final double tempsAttenduMax;
  double? tempsSaisi;
  int? resultatId;

  CaseResultat({
    required this.exerciceId,
    required this.serieIndex,
    required this.repetitionIndex,
    required this.tempsAttenduMin,
    required this.tempsAttenduMax,
    this.tempsSaisi,
    this.resultatId,
  });
}
