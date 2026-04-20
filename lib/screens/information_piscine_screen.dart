import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sunnypool_app/models/pool_model.dart';
import 'package:sunnypool_app/screens/dashboard_screen.dart';
import 'package:sunnypool_app/widget/appBar_widget.dart';

class InformationPiscineScreen extends StatefulWidget {
  final Pool? pool;
  final List<String> traitementChecked;

  const InformationPiscineScreen({
    super.key,
    this.pool,
    this.traitementChecked = const ['Chlore'],
  });

  @override
  State<InformationPiscineScreen> createState() =>
      _InformationPiscineScreenState();
}

class _InformationPiscineScreenState extends State<InformationPiscineScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final lengthController = TextEditingController();
  final widthController = TextEditingController();
  final depthController = TextEditingController();

  TypePool? typePool;
  double? volumePool;
  List<String> traitementChecked = ['Chlore'];
  bool showTraitementError = false;
  final List<String> traitementOptions = const [
    'Chlore',
    'Brome',
    'Sel',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    typePool = widget.pool?.type;
    volumePool = widget.pool?.volume;
    nameController.text = widget.pool?.name ?? '';
    lengthController.text = widget.pool?.dimension.length.toString() ?? '';
    widthController.text = widget.pool?.dimension.width.toString() ?? '';
    depthController.text = widget.pool?.dimension.depth.toString() ?? '';
    traitementChecked = List<String>.from(widget.traitementChecked);
    onChangedVolume();
  }

  @override
  void dispose() {
    nameController.dispose();
    lengthController.dispose();
    widthController.dispose();
    depthController.dispose();
    super.dispose();
  }

  void onChangedVolume() {
    final length = _parsePositiveValue(lengthController.text);
    final width = _parsePositiveValue(widthController.text);
    final depth = _parsePositiveValue(depthController.text);

    setState(() {
      if (length == null || width == null || depth == null) {
        volumePool = null;
        return;
      }
      volumePool = length * width * depth;
    });
  }

  double? _parsePositiveValue(String rawValue) {
    final parsed = double.tryParse(rawValue.trim().replaceAll(',', '.'));
    if (parsed == null || parsed <= 0) {
      return null;
    }
    return parsed;
  }

  String? _validateDimension(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Champ requis';
    }
    final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
    if (parsed == null) {
      return 'Nombre invalide';
    }
    if (parsed <= 0) {
      return 'Valeur > 0';
    }
    return null;
  }

  bool _isFormReady() {
    return typePool != null &&
        _parsePositiveValue(lengthController.text) != null &&
        _parsePositiveValue(widthController.text) != null &&
        _parsePositiveValue(depthController.text) != null &&
        traitementChecked.isNotEmpty;
  }

  void _toggleTraitement(String item) {
    setState(() {
      if (traitementChecked.contains(item)) {
        traitementChecked.remove(item);
      } else {
        traitementChecked.add(item);
      }
      showTraitementError = traitementChecked.isEmpty;
    });
  }

  void _onContinue() {
    FocusScope.of(context).unfocus();
    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (traitementChecked.isEmpty) {
      setState(() {
        showTraitementError = true;
      });
    }

    if (!isFormValid || traitementChecked.isEmpty) {
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => DashboardScreen()),
    );
  }

  Future<void> _onSkip() async {
    FocusScope.of(context).unfocus();
    final shouldSkip = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text(
            'Passer la configuration ?',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Vous pourrez compléter ces informations plus tard.',
            style: TextStyle(color: Color(0xFFB8B8B8)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC54D),
                foregroundColor: Colors.black,
              ),
              child: const Text('Passer'),
            ),
          ],
        );
      },
    );

    if (!mounted || shouldSkip != true) {
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => DashboardScreen()),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    const borderColor = Color(0xFFFFC54D);
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: borderColor),
      filled: true,
      fillColor: const Color(0xCC151515),
      labelStyle: const TextStyle(color: borderColor),
      hintStyle: const TextStyle(color: Color(0xFF8F8F8F)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: borderColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  Widget _dimensionField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required TextInputAction action,
  }) {
    return TextFormField(
      controller: controller,
      textInputAction: action,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(label: label, icon: icon, hint: label),
      validator: _validateDimension,
      onChanged: (_) => onChangedVolume(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isFormReady = _isFormReady();

    return Scaffold(
      appBar: AppbarWidget(
        title: 'Informations de la piscine',
        context: context,
      ).build(),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF050505), Color(0xFF111111)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0x221A1A1A),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0x33FFC54D)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: const Color(0x22FFC54D),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.pool,
                              color: Color(0xFFFFC54D),
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nameController.text.isEmpty
                                      ? 'Bienvenue !'
                                      : 'Configuration de votre bassin',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Renseignez les caractéristiques pour un suivi précis.',
                                  style: TextStyle(
                                    color: Color(0xFFB6B6B6),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x191FC9A6),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0x551FC9A6)),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'Etape 2/3',
                            style: TextStyle(
                              color: Color(0xFF9EDFD1),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: const LinearProgressIndicator(
                                value: 0.67,
                                minHeight: 8,
                                backgroundColor: Color(0x3326B39A),
                                valueColor: AlwaysStoppedAnimation(
                                  Color(0xFF61E7CD),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onChanged: () => setState(() {}),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0x99111111),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 14,
                              offset: Offset(0, 8),
                            ),
                          ],
                          border: Border.all(color: const Color(0x22FFFFFF)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: nameController,
                              readOnly: true,
                              style: const TextStyle(color: Colors.white),
                              decoration: _inputDecoration(
                                label: 'Nom de la piscine',
                                icon: Icons.badge_outlined,
                                hint: 'Nom de la piscine',
                              ),
                            ),
                            const SizedBox(height: 14),
                            DropdownButtonFormField<TypePool>(
                              isExpanded: true,
                              initialValue: typePool,
                              style: const TextStyle(color: Colors.white),
                              dropdownColor: const Color(0xFF242424),
                              iconEnabledColor: const Color(0xFFFFC54D),
                              decoration: _inputDecoration(
                                label: 'Type de piscine',
                                icon: Icons.format_shapes,
                              ),
                              items: TypePool.values
                                  .map(
                                    (type) => DropdownMenuItem<TypePool>(
                                      value: type,
                                      child: Text(
                                        type.toString().split('.').last,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  typePool = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Veuillez sélectionner une option';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final useColumn = constraints.maxWidth < 540;
                                if (useColumn) {
                                  return Column(
                                    children: [
                                      _dimensionField(
                                        label: 'Longueur (m)',
                                        controller: lengthController,
                                        icon: Icons.straighten,
                                        action: TextInputAction.next,
                                      ),
                                      const SizedBox(height: 10),
                                      _dimensionField(
                                        label: 'Largeur (m)',
                                        controller: widthController,
                                        icon: Icons.swap_horiz,
                                        action: TextInputAction.next,
                                      ),
                                      const SizedBox(height: 10),
                                      _dimensionField(
                                        label: 'Profondeur (m)',
                                        controller: depthController,
                                        icon: Icons.height,
                                        action: TextInputAction.done,
                                      ),
                                    ],
                                  );
                                }

                                return Row(
                                  children: [
                                    Expanded(
                                      child: _dimensionField(
                                        label: 'Longueur (m)',
                                        controller: lengthController,
                                        icon: Icons.straighten,
                                        action: TextInputAction.next,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _dimensionField(
                                        label: 'Largeur (m)',
                                        controller: widthController,
                                        icon: Icons.swap_horiz,
                                        action: TextInputAction.next,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _dimensionField(
                                        label: 'Profondeur (m)',
                                        controller: depthController,
                                        icon: Icons.height,
                                        action: TextInputAction.done,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0x221FC9A6),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0x551FC9A6),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.water_drop,
                                    color: Color(0xFF61E7CD),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Volume estimé',
                                    style: TextStyle(
                                      color: Color(0xFF9EDFD1),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 220),
                                    transitionBuilder: (child, animation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                    child: Text(
                                      volumePool == null
                                          ? '-- m3'
                                          : '${volumePool!.toStringAsFixed(2)} m3',
                                      key: ValueKey<String>(
                                        volumePool == null
                                            ? 'no-volume'
                                            : volumePool!.toStringAsFixed(2),
                                      ),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Traitement',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: traitementOptions
                                  .map(
                                    (item) => FilterChip(
                                      label: Text(item),
                                      selected: traitementChecked.contains(
                                        item,
                                      ),
                                      showCheckmark: false,
                                      labelStyle: TextStyle(
                                        color: traitementChecked.contains(item)
                                            ? Colors.black
                                            : Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: screenWidth < 360 ? 12 : 13,
                                      ),
                                      backgroundColor: const Color(0x22151515),
                                      selectedColor: const Color(0xFFFFC54D),
                                      side: const BorderSide(
                                        color: Color(0x44FFC54D),
                                      ),
                                      onSelected: (_) =>
                                          _toggleTraitement(item),
                                    ),
                                  )
                                  .toList(),
                            ),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeOut,
                              child: showTraitementError
                                  ? const Padding(
                                      padding: EdgeInsets.only(top: 8),
                                      child: Text(
                                        'Choisissez au moins un traitement.',
                                        style: TextStyle(
                                          color: Color(0xFFFF8A80),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: _onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFormReady
                            ? const Color(0xFFFFC54D)
                            : const Color(0xFF8C7A46),
                        foregroundColor: isFormReady
                            ? Colors.black
                            : Colors.white70,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Continuer',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: _onSkip,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0x55FFFFFF)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Passer',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
