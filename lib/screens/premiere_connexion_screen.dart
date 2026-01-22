import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_manager.dart';
import '../constants/triathlon_colors.dart';
import '../constants/triathlon_dimens.dart';
import 'main_triathlon_menu_screen.dart';

class PremiereConnexionScreen extends StatefulWidget {
  const PremiereConnexionScreen({super.key});

  @override
  _PremiereConnexionScreenState createState() =>
      _PremiereConnexionScreenState();
}

class _PremiereConnexionScreenState extends State<PremiereConnexionScreen> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    DataManager dataManager = Provider.of<DataManager>(context);

    return Scaffold(
      backgroundColor: TriathlonColors.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(TriathlonDimens.paddingXLarge),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // Logo
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.directions_bike,
                      size: 100,
                      color: TriathlonColors.primary,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Titre
                  Text(
                    'Bienvenue sur ACR Triathlon !',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: TriathlonDimens.fontSizeXXXLarge,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Entrez vos informations pour commencer',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: TriathlonDimens.fontSizeLarge,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // Champ Nom
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Nom *',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: TriathlonDimens.fontSizeLarge,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _nomController,
                    style: TextStyle(
                      color: TriathlonColors.textPrimary,
                      fontSize: TriathlonDimens.fontSizeLarge,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Votre nom',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          TriathlonDimens.borderRadiusMedium,
                        ),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: TriathlonDimens.paddingMedium,
                        vertical: TriathlonDimens.paddingMedium,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Le nom est obligatoire';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Champ Prénom
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Prénom',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: TriathlonDimens.fontSizeLarge,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _prenomController,
                    style: TextStyle(
                      color: TriathlonColors.textPrimary,
                      fontSize: TriathlonDimens.fontSizeLarge,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Votre prénom (facultatif)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          TriathlonDimens.borderRadiusMedium,
                        ),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: TriathlonDimens.paddingMedium,
                        vertical: TriathlonDimens.paddingMedium,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Bouton Continuer
                  SizedBox(
                    width: 250,
                    height: TriathlonDimens.buttonHeightLarge,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          String nom = _nomController.text.trim();
                          String prenom = _prenomController.text.trim();

                          await dataManager.saveUser(nom, prenom);

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const MainTriathlonMenuScreen(),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: TriathlonColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            TriathlonDimens.borderRadiusXLarge,
                          ),
                        ),
                        elevation: 8,
                      ),
                      child: const Text(
                        'COMMENCER',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Information
                  Container(
                    padding:
                        const EdgeInsets.all(TriathlonDimens.paddingMedium),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        TriathlonDimens.borderRadiusMedium,
                      ),
                    ),
                    child: Text(
                      'Vous pourrez configurer vos performances (VMA, FTP, temps natation) plus tard dans votre profil.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: TriathlonDimens.fontSizeSmall,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
