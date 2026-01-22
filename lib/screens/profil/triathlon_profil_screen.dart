import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/data_manager.dart';
import '../../constants/triathlon_colors.dart';
import '../../models/sport_type.dart';

class TriathlonProfilScreen extends StatefulWidget {
  const TriathlonProfilScreen({super.key});

  @override
  _TriathlonProfilScreenState createState() => _TriathlonProfilScreenState();
}

class _TriathlonProfilScreenState extends State<TriathlonProfilScreen> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _swimmingTimeController = TextEditingController();
  final TextEditingController _cyclingFtpController = TextEditingController();
  final TextEditingController _runningVmaController = TextEditingController();
  final TextEditingController _poidsController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final dataManager = Provider.of<DataManager>(context, listen: false);

    try {
      // Charger les données utilisateur de manière asynchrone
      final nom = await dataManager.getUserNom();
      final prenom = await dataManager.getUserPrenom();

      // Mettre à jour les contrôleurs
      if (mounted) {
        setState(() {
          _nomController.text = nom;
          _prenomController.text = prenom;
        });
      }

      // Charger le profil triathlon
      final profile = dataManager.getTriathlonProfile();

      if (profile['swimming_400m_time'] != null) {
        _swimmingTimeController.text = _formatSwimmingTime(
          profile['swimming_400m_time'] as double,
        );
      }

      if (profile['cycling_ftp'] != null) {
        _cyclingFtpController.text = profile['cycling_ftp'].toStringAsFixed(0);
      }

      if (profile['running_vma'] != null) {
        _runningVmaController.text = profile['running_vma'].toStringAsFixed(1);
      }

      // CORRECTION ICI : Charger le poids du profil
      if (profile['poids'] != null) {
        final poids = profile['poids'] as double;
        _poidsController.text = poids.toStringAsFixed(1);
      } else {
        // Valeur par défaut
        _poidsController.text = '70.0';
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Erreur lors du chargement des données: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatSwimmingTime(double seconds) {
    int minutes = (seconds ~/ 60).toInt();
    double remainingSeconds = seconds % 60;

    if (minutes > 0) {
      return '$minutes:${remainingSeconds.toStringAsFixed(2).padLeft(5, '0')}';
    } else {
      return remainingSeconds.toStringAsFixed(2);
    }
  }

  double? _parseSwimmingTime(String timeStr) {
    try {
      if (timeStr.contains(':')) {
        List<String> parts = timeStr.split(':');
        if (parts.length == 2) {
          int minutes = int.parse(parts[0]);
          double seconds = double.parse(parts[1].replaceAll(',', '.'));
          return (minutes * 60.0) + seconds;
        }
      }
      return double.parse(timeStr.replaceAll(',', '.'));
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataManager = Provider.of<DataManager>(context);

    // Afficher un indicateur de chargement pendant le chargement initial
    if (_isLoading) {
      return Scaffold(
        backgroundColor: TriathlonColors.background,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: TriathlonColors.primary,
                ),
                const SizedBox(height: 20),
                Text(
                  'Chargement du profil...',
                  style: TextStyle(
                    color: TriathlonColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: TriathlonColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      color: TriathlonColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Mon Profil Triathlon',
                      style: TextStyle(
                        color: TriathlonColors.primary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Informations personnelles
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'INFORMATIONS PERSONNELLES',
                          style: TextStyle(
                            color: TriathlonColors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Nom
                        Text(
                          'Nom *',
                          style: TextStyle(
                            color: TriathlonColors.textPrimary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nomController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Votre nom',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: TriathlonColors.primary,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Le nom est obligatoire';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 15),

                        // Prénom
                        Text(
                          'Prénom',
                          style: TextStyle(
                            color: TriathlonColors.textPrimary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _prenomController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Votre prénom (facultatif)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: TriathlonColors.primary,
                                width: 2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // Poids
                        Text(
                          'Poids (kg)',
                          style: TextStyle(
                            color: TriathlonColors.textPrimary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _poidsController,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Ex: 70.0',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: TriathlonColors.primary,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              try {
                                double poids =
                                    double.parse(value.replaceAll(',', '.'));
                                if (poids < 30 || poids > 200) {
                                  return 'Poids invalide (30-200 kg)';
                                }
                              } catch (e) {
                                return 'Nombre invalide';
                              }
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Performances par sport
                Text(
                  'MES PERFORMANCES',
                  style: TextStyle(
                    color: TriathlonColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Ces données améliorent la précision des calculs',
                  style: TextStyle(
                    color: TriathlonColors.textSecondary,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 20),

                // Natation
                _buildSportCard(
                  context,
                  sportType: SportType.swimming,
                  title: 'Natation',
                  subtitle: 'Temps au 400m',
                  controller: _swimmingTimeController,
                  hintText: 'Ex: 6:30.50 (mm:ss.xx)',
                  icon: Icons.pool,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      double? time = _parseSwimmingTime(value);
                      if (time == null || time <= 0 || time > 1200) {
                        return 'Temps invalide (ex: 6:30.50)';
                      }
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // Cyclisme
                _buildSportCard(
                  context,
                  sportType: SportType.cycling,
                  title: 'Cyclisme',
                  subtitle: 'FTP (Functional Threshold Power)',
                  controller: _cyclingFtpController,
                  hintText: 'Ex: 250 (watts)',
                  icon: Icons.power,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      try {
                        double ftp = double.parse(value.replaceAll(',', '.'));
                        if (ftp <= 0 || ftp > 1000) {
                          return 'FTP invalide (50-1000 watts)';
                        }
                      } catch (e) {
                        return 'Nombre invalide';
                      }
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // Course à pied
                _buildSportCard(
                  context,
                  sportType: SportType.running,
                  title: 'Course à pied',
                  subtitle: 'VMA (Vitesse Maximale Aérobie)',
                  controller: _runningVmaController,
                  hintText: 'Ex: 16.5 (km/h)',
                  icon: Icons.directions_run,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      try {
                        double vma = double.parse(value.replaceAll(',', '.'));
                        if (vma <= 0 || vma > 30) {
                          return 'VMA invalide (5-30 km/h)';
                        }
                      } catch (e) {
                        return 'Nombre invalide';
                      }
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // Boutons
                Row(
                  children: [
                    // Bouton Sauvegarder
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              await _saveProfile(dataManager);

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Profil sauvegardé !'),
                                    backgroundColor: Colors.green,
                                  ),
                                );

                                Navigator.pop(context);
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TriathlonColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            'SAUVEGARDER',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Bouton Effacer
                    SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: _clearForm,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text('EFFACER'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Information
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: TriathlonColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: TriathlonColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info,
                            color: TriathlonColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'À propos des données',
                            style: TextStyle(
                              color: TriathlonColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '• FTP: Puissance maximale maintenue sur 1h\n'
                        '• VMA: Vitesse à consommation max d\'oxygène\n'
                        '• Temps 400m: Meilleur temps sur 400m en natation\n\n'
                        'Ces données ne sont pas obligatoires mais améliorent la précision.',
                        style: TextStyle(
                          color: TriathlonColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSportCard(
    BuildContext context, {
    required SportType sportType,
    required String title,
    required String subtitle,
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required String? Function(String?)? validator,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: sportType.color,
              width: 5,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: sportType.color,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: sportType.color,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: TriathlonColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: hintText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: sportType.color,
                      width: 2,
                    ),
                  ),
                ),
                validator: validator,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile(DataManager dataManager) async {
    // Sauvegarder les informations personnelles
    await dataManager.saveUser(
      _nomController.text.trim(),
      _prenomController.text.trim(),
    );

    // Préparer le profil triathlon
    Map<String, dynamic> profile = {};

    if (_swimmingTimeController.text.isNotEmpty) {
      double? swimmingTime = _parseSwimmingTime(_swimmingTimeController.text);
      if (swimmingTime != null) {
        profile['swimming_400m_time'] = swimmingTime;
      }
    }

    if (_cyclingFtpController.text.isNotEmpty) {
      double? ftp =
          double.tryParse(_cyclingFtpController.text.replaceAll(',', '.'));
      if (ftp != null) {
        profile['cycling_ftp'] = ftp;
      }
    }

    if (_runningVmaController.text.isNotEmpty) {
      double? vma =
          double.tryParse(_runningVmaController.text.replaceAll(',', '.'));
      if (vma != null) {
        profile['running_vma'] = vma;
      }
    }

    if (_poidsController.text.isNotEmpty) {
      double? poids =
          double.tryParse(_poidsController.text.replaceAll(',', '.'));
      if (poids != null) {
        profile['poids'] = poids;
      }
    }

    // Sauvegarder le profil
    await dataManager.saveTriathlonProfile(profile);
  }

  void _clearForm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Effacer le formulaire'),
        content: const Text(
          'Voulez-vous vraiment effacer toutes les données saisies ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _swimmingTimeController.clear();
                _cyclingFtpController.clear();
                _runningVmaController.clear();
                _poidsController.clear();
              });
              Navigator.pop(context);
            },
            child: const Text(
              'Effacer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
