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

  // NOUVEAU: Contrôleurs séparés pour le temps de natation
  final TextEditingController _swimmingMinutesController =
      TextEditingController();
  final TextEditingController _swimmingSecondesController =
      TextEditingController();
  final TextEditingController _swimmingCentiemesController =
      TextEditingController();

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

      // NOUVEAU: Initialiser le temps de natation séparé en minutes/secondes/centièmes
      if (profile['swimming_400m_time'] != null) {
        final swimmingTime = profile['swimming_400m_time'] as double;
        _initializeSwimmingTime(swimmingTime);
      } else {
        // Valeurs par défaut
        _swimmingMinutesController.text = '6';
        _swimmingSecondesController.text = '30';
        _swimmingCentiemesController.text = '00';
      }

      if (profile['cycling_ftp'] != null) {
        _cyclingFtpController.text = profile['cycling_ftp'].toStringAsFixed(0);
      }

      if (profile['running_vma'] != null) {
        _runningVmaController.text = profile['running_vma'].toStringAsFixed(1);
      }

      // Charger le poids du profil
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

  // NOUVEAU: Fonction pour initialiser le temps de natation séparé
  void _initializeSwimmingTime(double seconds) {
    int minutes = (seconds ~/ 60).toInt();
    int secondes = (seconds % 60).toInt();
    int centiemes = ((seconds % 1) * 100).toInt();

    _swimmingMinutesController.text = minutes.toString();
    _swimmingSecondesController.text = secondes.toString().padLeft(2, '0');
    _swimmingCentiemesController.text = centiemes.toString().padLeft(2, '0');
  }

  // NOUVEAU: Fonction pour convertir le temps de natation en secondes
  double? _convertirSwimmingTimeEnSecondes() {
    try {
      int minutes = int.tryParse(_swimmingMinutesController.text) ?? 0;
      int secondes = int.tryParse(_swimmingSecondesController.text) ?? 0;
      int centiemes = int.tryParse(_swimmingCentiemesController.text) ?? 0;

      // Validation et correction automatique
      if (secondes >= 60) {
        minutes += secondes ~/ 60;
        secondes = secondes % 60;
        _swimmingMinutesController.text = minutes.toString();
        _swimmingSecondesController.text = secondes.toString().padLeft(2, '0');
      }

      if (centiemes >= 100) {
        secondes += centiemes ~/ 100;
        centiemes = centiemes % 100;
        if (secondes >= 60) {
          minutes += secondes ~/ 60;
          secondes = secondes % 60;
          _swimmingMinutesController.text = minutes.toString();
        }
        _swimmingSecondesController.text = secondes.toString().padLeft(2, '0');
        _swimmingCentiemesController.text =
            centiemes.toString().padLeft(2, '0');
      }

      // Convertir en secondes avec décimales
      double totalSecondes = (minutes * 60) + secondes + (centiemes / 100.0);

      if (totalSecondes <= 0 || totalSecondes > 1200) {
        return null;
      }

      return totalSecondes;
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

                // Natation - MODIFIÉ
                _buildSwimmingCard(context),

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

  // NOUVEAU: Widget spécifique pour la natation
  Widget _buildSwimmingCard(BuildContext context) {
    final sportType = SportType.swimming;

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
                    Icons.pool,
                    color: sportType.color,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Natation',
                          style: TextStyle(
                            color: sportType.color,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Temps au 400m',
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

              // NOUVEAU: Champ séparé en Minutes/Secondes/Centièmes
              Row(
                children: [
                  // Minutes
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Minutes',
                          style: TextStyle(
                            color: TriathlonColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        TextFormField(
                          controller: _swimmingMinutesController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: '0',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: sportType.color,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 12,
                            ),
                          ),
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              int? minutes = int.tryParse(value);
                              if (minutes == null ||
                                  minutes < 0 ||
                                  minutes > 20) {
                                return 'Min invalide';
                              }
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Séparateur :
                  Container(
                    alignment: Alignment.bottomCenter,
                    height: 60,
                    child: Text(
                      ':',
                      style: TextStyle(
                        color: sportType.color,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Secondes
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Secondes',
                          style: TextStyle(
                            color: TriathlonColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        TextFormField(
                          controller: _swimmingSecondesController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: '00',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: sportType.color,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 12,
                            ),
                          ),
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              int? secondes = int.tryParse(value);
                              if (secondes == null ||
                                  secondes < 0 ||
                                  secondes >= 60) {
                                return 'Sec invalide';
                              }
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Séparateur .
                  Container(
                    alignment: Alignment.bottomCenter,
                    height: 60,
                    child: Text(
                      '.',
                      style: TextStyle(
                        color: sportType.color,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Centièmes
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Centièmes',
                          style: TextStyle(
                            color: TriathlonColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        TextFormField(
                          controller: _swimmingCentiemesController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: '00',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: sportType.color,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 12,
                            ),
                          ),
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              int? centiemes = int.tryParse(value);
                              if (centiemes == null ||
                                  centiemes < 0 ||
                                  centiemes >= 100) {
                                return 'Cent invalide';
                              }
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Aide pour le format
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Text(
                  'Format: minutes:secondes.centièmes (ex: 6:30.50)',
                  style: TextStyle(
                    color: TriathlonColors.textSecondary,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
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

    // Temps de natation
    double? swimmingTime = _convertirSwimmingTimeEnSecondes();
    if (swimmingTime != null) {
      profile['swimming_400m_time'] = swimmingTime;
      print("Temps natation sauvegardé: $swimmingTime secondes");
    }

    // FTP cyclisme
    if (_cyclingFtpController.text.isNotEmpty) {
      double? ftp =
          double.tryParse(_cyclingFtpController.text.replaceAll(',', '.'));
      if (ftp != null) {
        profile['cycling_ftp'] = ftp;
        print("FTP sauvegardé: $ftp watts");
      }
    }

    // VMA course
    if (_runningVmaController.text.isNotEmpty) {
      double? vma =
          double.tryParse(_runningVmaController.text.replaceAll(',', '.'));
      if (vma != null) {
        profile['running_vma'] = vma;
        print("VMA sauvegardée: $vma km/h");
      }
    }

    // Poids
    if (_poidsController.text.isNotEmpty) {
      double? poids =
          double.tryParse(_poidsController.text.replaceAll(',', '.'));
      if (poids != null) {
        profile['poids'] = poids;
        print("Poids sauvegardé: $poids kg");
      }
    }

    // MODIFICATION IMPORTANTE : Toujours sauvegarder même si certains champs sont vides
    // Sauvegarder le profil (cela va écrire dans le fichier JSON)
    await dataManager.saveTriathlonProfile(profile);

    // DEBUG : Afficher l'état des données
    await dataManager.debugPrintData();
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
                _swimmingMinutesController.clear();
                _swimmingSecondesController.clear();
                _swimmingCentiemesController.clear();
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
