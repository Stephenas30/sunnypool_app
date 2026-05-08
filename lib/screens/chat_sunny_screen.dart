import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sunnypool_app/models/conversation_model.dart';
import 'package:sunnypool_app/models/dossier_model.dart';
import 'package:sunnypool_app/models/message_model.dart';
import 'package:sunnypool_app/screens/login_screen.dart';
import 'package:sunnypool_app/services/folder_thread_service.dart';
import 'package:sunnypool_app/services/pool_service.dart';
import 'package:sunnypool_app/services/sunny_service.dart';
import 'package:sunnypool_app/utils/poolId_storage.dart';
import 'package:sunnypool_app/utils/token_storage.dart';
import 'package:sunnypool_app/widget/appBar_widget.dart';
import 'package:sunnypool_app/widget/typing_indicator_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

final uuid = Uuid();

enum MenuEntry {
  newMessage('Nouveau Message'),
  discussion('Continuer la discussion'),
  renommer('Renommer'),
  supprimer('Supprimer'),
  dupliquer('Dupliquer'),
  addToFolder('Ajouter dans un dossier'),
  more('Plus');

  const MenuEntry(this.label);
  final String label;
  //final MenuSerializableShortcut? shortcut;
}

class ChatSunnyScreen extends StatefulWidget {
  const ChatSunnyScreen({
    super.key,
    this.initialMessage,
    this.autoSendInitialMessage = false,
  });

  final String? initialMessage;
  final bool autoSendInitialMessage;

  @override
  State<ChatSunnyScreen> createState() => _ChatSunnyScreenState();
}

class _ChatSunnyScreenState extends State<ChatSunnyScreen> {
  //Variable Principale
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final ScrollController _messagesScrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _folderNameController = TextEditingController();

  final List<Map<String, dynamic>> _messages = [];

  String? sessionId;
  int? thread_id;

  bool _isLoading = false;
  bool _isLoadingConversation = false;
  bool _initialMessageSent = false;

  String? tokenValue;
  String? selectedMessageId;

  List<DossierModel> listDossiers = [];
  bool listDossierActive = false;
  bool addFolder = false;
  bool _isLoadingFolder = false;
  bool _activeWrap = false;
  File? _imagePool;
  final Map<String, bool> _optionSend = {
    'meteo': false,
    'historique': true,
    'produits': false,
    'alertes': true,
    'planning': true,
    'coordonnees': true,
    'mesure de l\'eau': false,
  };
  DossierModel? selectedDossier;
  DossierModel? renamedDossier;

  List<ConversationModel> listConversation = [];
  ConversationModel? renamedConversation;

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_messagesScrollController.hasClients) return;
      final target = _messagesScrollController.position.maxScrollExtent;
      if (animated) {
        _messagesScrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      } else {
        _messagesScrollController.jumpTo(target);
      }
    });
  }

  Future<void> _getAllConversation({int? folder_id}) async {
    setState(() {
      _isLoadingConversation = true;
    });

    if (folder_id != null) {
      _fetchThreadByFolder(folder_id);
      return;
    }

    try {
      tokenValue = await TokenStorage.getToken();
      String? poolId = await PoolIdStorage.getPoolId();

      Map<String, dynamic> response = await SunnyService().getAllConversation(
        tokenValue!,
        int.tryParse(poolId!)!,
      );

      if (response['data'] == null) {
        setState(() {
          _isLoadingConversation = false;
        });
        return;
      }

      List<ConversationModel> conversations = [];

      if (response['data'] is List) {
        print(response['data'][0]);
        for (final item in response['data']) {
          conversations.add(
            ConversationModel(
              id: item['id'].toString(),
              title: item['title'],
              favories: item['favorites'],
            ),
          );
        }
      }

      print(conversations);
      setState(() {
        listConversation = conversations;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement des conversations: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingConversation = false;
      });
    }
  }

  void showOptions(String id) {
    setState(() {
      selectedMessageId = id;
    });
  }

  void hideOptions() {
    setState(() {
      selectedMessageId = null;
      renamedConversation = null;
      renamedDossier = null;
    });
  }

  Map<String, dynamic>? _normalizeSunnyPayload(dynamic value) {
    dynamic payload = value;
    if (payload == null) return null;

    if (payload is String) {
      final trimmed = payload.trim();
      if (trimmed.isEmpty) return null;
      final looksLikeJson =
          (trimmed.startsWith('{') && trimmed.endsWith('}')) ||
          (trimmed.startsWith('[') && trimmed.endsWith(']'));
      if (!looksLikeJson) return null;
      try {
        payload = jsonDecode(trimmed);
      } catch (_) {
        return null;
      }
    }

    if (payload is! Map) return null;
    final map = Map<String, dynamic>.from(payload);
    final hasKnownKeys =
        map.containsKey('message') ||
        map.containsKey('diagnosis') ||
        map.containsKey('actions') ||
        map.containsKey('products') ||
        map.containsKey('links') ||
        map.containsKey('warnings') ||
        map.containsKey('questions');

    return hasKnownKeys ? map : null;
  }

  List<dynamic> _asList(dynamic value) => value is List ? value : const [];

  String _priorityKey(dynamic value) {
    final key = (value ?? '').toString().toLowerCase();
    if (key == 'high' || key == 'medium' || key == 'low') return key;
    return 'low';
  }

  String _priorityLabel(dynamic value) {
    switch (_priorityKey(value)) {
      case 'high':
        return 'Élevée';
      case 'medium':
        return 'Moyenne';
      default:
        return 'Faible';
    }
  }

  Color _priorityColor(dynamic value) {
    switch (_priorityKey(value)) {
      case 'high':
        return const Color(0xFFFF7B7B);
      case 'medium':
        return const Color(0xFFFFB86B);
      default:
        return const Color(0xFFE6C96E);
    }
  }

  Future<void> _openSunnyLink(String? rawUrl) async {
    final value = (rawUrl ?? '').trim();
    final uri = Uri.tryParse(value);
    final isHttp =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');

    if (!isHttp) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lien invalide.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final launched = await launchUrl(
      uri!,
      mode: LaunchMode.externalApplication,
    );
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'ouvrir ce lien.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildSunnySection(String title, Widget child) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFF0C75E),
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildPriorityChip(dynamic value, {String? prefix}) {
    final label = _priorityLabel(value);
    final color = _priorityColor(value);
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        border: Border.all(color: color.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '${prefix != null ? '$prefix: ' : ''}$label',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildSunnyStructuredMessage(Map<String, dynamic> payload) {
    final diagnosis = payload['diagnosis'];
    final actions = _asList(payload['actions']);
    final products = _asList(payload['products']);
    final links = _asList(payload['links']);
    final warnings = _asList(payload['warnings']);
    final questions = _asList(payload['questions']);

    final content = <Widget>[];

    final message = payload['message'];
    if (message != null && message.toString().trim().isNotEmpty) {
      content.add(
        Text(message.toString(), style: const TextStyle(color: Colors.white)),
      );
    }

    if (diagnosis is Map &&
        ((diagnosis['summary'] ?? '').toString().isNotEmpty ||
            (diagnosis['severity'] ?? '').toString().isNotEmpty)) {
      content.add(
        _buildSunnySection(
          'Diagnostic',
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  (diagnosis['summary'] ?? 'Diagnostic disponible').toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              if ((diagnosis['severity'] ?? '').toString().isNotEmpty)
                _buildPriorityChip(diagnosis['severity'], prefix: 'Niveau'),
            ],
          ),
        ),
      );
    }

    if (actions.isNotEmpty) {
      content.add(
        _buildSunnySection(
          'Actions recommandées',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: actions.map((item) {
              if (item is! Map) return const SizedBox.shrink();
              final title = (item['title'] ?? 'Action').toString();
              final description = (item['description'] ?? '').toString();
              final priority = item['priority'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(color: Colors.white)),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if ((priority ?? '').toString().isNotEmpty)
                          _buildPriorityChip(priority),
                      ],
                    ),
                    if (description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 4),
                        child: Text(
                          description,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      );
    }

    if (products.isNotEmpty) {
      content.add(
        _buildSunnySection(
          'Produits conseillés',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: products.map((item) {
              if (item is! Map) return const SizedBox.shrink();
              final name = (item['name'] ?? 'Produit').toString();
              final reason = (item['reason'] ?? '').toString();
              final dosage = item['dosage'];
              final details = <String>[];
              if (reason.isNotEmpty) details.add(reason);
              if (dosage != null && dosage.toString().trim().isNotEmpty) {
                details.add('Dosage: ${dosage.toString()}');
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(color: Colors.white)),
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (details.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 4),
                        child: Text(
                          details.join(' • '),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      );
    }

    if (links.isNotEmpty) {
      content.add(
        _buildSunnySection(
          'Liens utiles',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: links.map((item) {
              if (item is! Map) return const SizedBox.shrink();
              final title = (item['title'] ?? 'Ouvrir le lien').toString();
              final url = (item['url'] ?? '').toString();
              if (url.trim().isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0x66FFD54F)),
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0x14FFD54F),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFFF5D56D),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () => _openSunnyLink(url),
                        child: Text(
                          url,
                          style: const TextStyle(
                            color: Colors.lightBlueAccent,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    }

    if (warnings.isNotEmpty) {
      content.add(
        _buildSunnySection(
          'Avertissements',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: warnings.map((item) {
              final text = item.toString();
              if (text.trim().isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '• $text',
                  style: const TextStyle(color: Colors.white70),
                ),
              );
            }).toList(),
          ),
        ),
      );
    }

    if (questions.isNotEmpty) {
      content.add(
        _buildSunnySection(
          'Questions de suivi',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: questions.map((item) {
              final text = item.toString();
              if (text.trim().isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '• $text',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: content.isEmpty
          ? [
              Text(
                payload.toString(),
                style: const TextStyle(color: Colors.white),
              ),
            ]
          : content,
    );
  }

  Widget _buildDrawerChat() {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: const Color(0xFF111111),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: hideOptions, // tap en dehors => fermer
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, drawerConstraints) {
              final maxDossiersHeight = drawerConstraints.maxHeight * 0.3;
              return Column(
                //padding: EdgeInsets.zero,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    decoration: const BoxDecoration(color: Color(0xFF1A1A1A)),
                    child: const Text(
                      'Menu Sunny',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.chat, color: Colors.amber),
                    title: const Text(
                      'Nouveau message',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () => {
                      setState(() {
                        sessionId = null;
                        thread_id = null;
                        _messages.clear();
                        listDossierActive = false;
                        selectedDossier = null;
                      }),
                      Navigator.pop(context),
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.folder, color: Colors.amber),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Dossiers de conversation',
                          style: TextStyle(color: Colors.white),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              addFolder = true;
                              listDossierActive = true;
                            });
                          },
                          icon: Icon(
                            Icons.add,
                            size: screenWidth * 0.05,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      if (listDossierActive) {
                        if (selectedDossier != null) {
                          _getAllConversation();
                        }
                        setState(() {
                          listDossierActive = false;
                          selectedDossier = null;
                        });
                      } else {
                        setState(() {
                          listDossierActive = true;
                        });
                        _fetchFolderThread();
                      }
                    },
                  ),
                  !listDossierActive
                      ? const SizedBox.shrink()
                      : Flexible(
                          fit: FlexFit.loose,
                          child: _isLoadingFolder
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.amber,
                                  ),
                                )
                              : listDossiers.isEmpty
                              ? addFolder
                                    ? ListTile(
                                        leading: const Icon(
                                          Icons.folder,
                                          color: Colors.grey,
                                        ),
                                        title: TextField(
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                          decoration: const InputDecoration(
                                            hintText: 'Nouveau dossier',
                                            hintStyle: TextStyle(
                                              color: Colors.white54,
                                            ),
                                            border: InputBorder.none,
                                          ),
                                          autofocus: addFolder,
                                          controller: _folderNameController,
                                          //onChanged: (e){_handleNewFolder(e);},
                                          onSubmitted: (e) =>
                                              _handleNewFolder(e),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            addFolder = false;
                                          });
                                        },
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: Text(
                                          'Aucun dossier pour le moment. Les conversations sont automatiquement sauvegardées.',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(color: Colors.white54),
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                              : ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: double.infinity,
                                    maxHeight: maxDossiersHeight,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: ListView(
                                      physics: const BouncingScrollPhysics(),
                                      children: [
                                        if (addFolder)
                                          ListTile(
                                            leading: const Icon(
                                              Icons.folder,
                                              color: Colors.grey,
                                            ),
                                            title: TextField(
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                              decoration: const InputDecoration(
                                                hintText: 'Nouveau dossier',
                                                hintStyle: TextStyle(
                                                  color: Colors.white54,
                                                ),
                                                border: InputBorder.none,
                                              ),
                                              autofocus: addFolder,
                                              controller: _folderNameController,
                                              //onChanged: (e){_handleNewFolder(e);},
                                              onSubmitted: (e) =>
                                                  _handleNewFolder(e),
                                            ),
                                            onTap: () {
                                              setState(() {
                                                addFolder = false;
                                              });
                                            },
                                          ),
                                        ...listDossiers.map((dossier) {
                                          return ListTile(
                                            leading: selectedDossier == dossier
                                                ? const Icon(
                                                    Icons.folder_open,
                                                    color: Colors.amber,
                                                  )
                                                : const Icon(
                                                    Icons.folder,
                                                    color: Colors.amber,
                                                  ),
                                            title: renamedDossier == dossier
                                                ? /* SizedBox(
                                      width: 150,
                                      child:  */ TextField(
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                    decoration:
                                                        const InputDecoration(
                                                          hintText:
                                                              'Renommer le dossier',
                                                          hintStyle: TextStyle(
                                                            color:
                                                                Colors.white54,
                                                          ),
                                                          border:
                                                              InputBorder.none,
                                                        ),
                                                    autofocus: true,
                                                    /* controller:
                                            TextEditingController(text: dossier.name), */
                                                    onSubmitted: (e) {
                                                      setState(() {
                                                        //dossier.name = e;
                                                        renamedDossier = null;
                                                      });
                                                    },
                                                    //),
                                                  )
                                                : Text(
                                                    dossier.name,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        selectedDossier ==
                                                            dossier
                                                        ? const TextStyle(
                                                            color: Colors.amber,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          )
                                                        : const TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                  ),
                                            trailing: renamedDossier == dossier
                                                ? null
                                                : _buildMenuDossier(dossier),
                                            onTap: () {
                                              if (selectedDossier == dossier) {
                                                setState(() {
                                                  selectedDossier = null;
                                                });
                                                _getAllConversation();
                                                return;
                                              }
                                              setState(() {
                                                selectedDossier = dossier;
                                              });
                                              _fetchThreadByFolder(
                                                int.tryParse(dossier.id)!,
                                              );
                                            },
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                  SizedBox(height: 10),
                  Divider(),
                  SizedBox(height: 10),
                  Expanded(
                    child: _isLoadingConversation
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.amber,
                            ),
                          )
                        : listConversation.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                selectedDossier != null
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                          left: 16,
                                          right: 16,
                                          bottom: 20,
                                        ),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.amber,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              setState(() {
                                                sessionId = null;
                                                _messages.clear();
                                                //listDossierActive = false;
                                                //selectedDossier = null;
                                              });
                                              Navigator.pop(context);
                                            });
                                          },
                                          child: Text(
                                            'Nouveau message dans ${selectedDossier?.name}',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      )
                                    : SizedBox.shrink(),
                                Text(
                                  'Aucune conversation disponible pour le moment.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white54,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            color: Colors.amber,
                            onRefresh: () async {
                              setState(() {
                                _isLoadingConversation = true;
                              });
                              await _getAllConversation();
                            },
                            child: ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              itemCount: listConversation.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) =>
                                  _buildListConversation(
                                    listConversation[index],
                                  ),
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContentChat() {
    const borderColor = Color(0x33FFD54F);
    const int pollMaxAttempts = 25;
    const Duration pollInterval = Duration(seconds: 2);
    final screenWidth = MediaQuery.of(context).size.width;
    final ImagePicker picker = ImagePicker();

    Future<void> pickImage(ImageSource source) async {
      final XFile? photo = await picker.pickImage(source: source);
      if (photo == null) return;

      setState(() {
        _imagePool = File(photo.path);
      });
    }

    void showImageSourceSheet() {
      showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF1A1A1A),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.amber),
                  title: const Text(
                    'Sélectionner une photo',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera, color: Colors.amber),
                  title: const Text(
                    'Prendre une photo',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          );
        },
      );
    }

    Future<dynamic> pollUntilCompleted(
      String token,
      String conversationId,
    ) async {
      for (int attempt = 0; attempt < pollMaxAttempts; attempt++) {
        final res = await SunnyService().responseChat(token, conversationId);
        print(res);
        final found = res['found'] == true;

        if (found) {
          final response = res['response'];
          if (response != null && response.toString().trim().isNotEmpty) {
            return response;
          }
        }

        await Future.delayed(pollInterval);
      }

      throw TimeoutException('Polling timeout');
    }

    void getAIResponse(String userMessage, File? image) {
      //print(sessionId);
      TokenStorage.getToken().then((token) {
        if (token == null || token.isEmpty) {
          setState(() {
            _messages.add({
              'id': uuid.v1(),
              'role': 'assistant',
              'text': 'Session expirée. Veuillez vous reconnecter.',
            });
            _isLoading = false;
          });
          _scrollToBottom();
          return;
        }
        SunnyService()
            .sendChat(
              token,
              sessionId.toString(),
              MessageModel(
                message: userMessage,
                image: image?.path,
                data_options: _optionSend,
              ),
              thread_id,
            )
            .then((response) async {
              try {
                print(response);
                if (response['response'] == "pending") {
                  setState(() {
                    _messages.add({
                      'id': uuid.v1(),
                      'role': 'assistant',
                      'text': '',
                      'widget': TypingIndicator(),
                    });
                    print('En cours de traitement. Merci de patienter...');
                    _isLoading = false;
                    thread_id ??= thread_id = response['thread_id'];
                  });
                  _scrollToBottom();
                }
                final finalResponse = await pollUntilCompleted(
                  token,
                  response['conversation_id'],
                );
                if (!mounted) return;

                setState(() {
                  _messages[_messages.length - 1] = {
                    'id': uuid.v1(),
                    'role': 'assistant',
                    'text': finalResponse,
                  };
                  _isLoading = false;
                });
                _scrollToBottom();
              } catch (error) {
                if (!mounted) return;
                setState(() {
                  _messages.add({
                    'id': uuid.v1(),
                    'role': 'assistant',
                    'text': 'Temps d\'attente dépassé. Merci de réessayer.',
                  });
                  _isLoading = false;
                });
                _scrollToBottom();
              }
            })
            .catchError((error) {
              setState(() {
                _messages.add({
                  'id': uuid.v1(),
                  'role': 'assistant',
                  'text': 'Une erreur est survenue: $error',
                });
                _isLoading = false;
              });
              _scrollToBottom();

              if (error is ApiException && error.statusCode == 401) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Session expirée. Veuillez vous reconnecter.',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                TokenStorage.clearToken().then((_) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                  );
                });
              }
            });
      });
    }

    void sendMessage(String text) {
      if (text.isEmpty && _imagePool == null) return;

      final messageId = uuid.v4();

      setState(() {
        sessionId = messageId;
        _messages.add({
          'id': messageId,
          'role': 'user',
          'text': text,
          'image': _imagePool?.path ?? '',
        });
        _isLoading = true;
        _imagePool = null;
      });
      getAIResponse(text, _imagePool);
      _scrollToBottom();
      _messageController.clear();
    }

    final initialMessage = widget.initialMessage?.trim() ?? '';
    if (!_initialMessageSent &&
        widget.autoSendInitialMessage &&
        initialMessage.isNotEmpty) {
      _initialMessageSent = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        sendMessage(initialMessage);
      });
    }

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF050505), Color(0xFF111111)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: hideOptions, // tap en dehors => fermer
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, top: 8),
                    child: IconButton(
                      icon: const Icon(Icons.menu, color: Colors.amber),
                      onPressed: () => {
                        setState(() {
                          listDossierActive = false;
                          selectedDossier = null;
                        }),

                        if (selectedDossier == null) _getAllConversation(),
                        scaffoldKey.currentState?.openDrawer(),
                      },
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20, top: 8),
                    child: Text(
                      selectedDossier != null
                          ? selectedDossier!.name
                          : 'Nouvelle conversation',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: screenWidth * 0.018,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Expanded(
              child: ListView.builder(
                controller: _messagesScrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final id = msg['id']!;
                  final isUser = msg['role'] == 'user';
                  final isSelected = selectedMessageId == id;
                  final dynamic rawText = msg['text'];
                  final messageText = rawText?.toString() ?? '';
                  final sunnyPayload = isUser
                      ? null
                      : _normalizeSunnyPayload(rawText);
                  final hasTypingWidget =
                      messageText.isEmpty && msg['widget'] is Widget;

                  return Align(
                    alignment: isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: isUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if (msg['image'] != null && msg['image']!.isNotEmpty)
                          Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: FileImage(File(msg['image']!)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        GestureDetector(
                          onLongPress: () => showOptions(id),
                          /* onTap: () {
                            if (isSelected) {
                              hideOptions();
                            } else {
                              showOptions(id);
                            }
                          }, */
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected) ...[
                                const SizedBox(width: 8),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        debugPrint('Répondre à $id');
                                      },
                                      icon: const Icon(Icons.reply),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        debugPrint('Copier $id');
                                      },
                                      icon: const Icon(Icons.copy),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        debugPrint('Supprimer $id');
                                      },
                                      icon: const Icon(Icons.delete),
                                    ),
                                  ],
                                ),
                              ],
                              hasTypingWidget
                                  ? msg['widget'] as Widget
                                  : Container(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 5,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                      constraints: BoxConstraints(
                                        maxWidth: sunnyPayload != null
                                            ? 340
                                            : 290,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isUser
                                            ? Colors.amber
                                            : const Color(0xFF1D1D1D),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: isUser
                                              ? Colors.amber
                                              : Colors.white24,
                                        ),
                                      ),
                                      child: sunnyPayload != null
                                          ? _buildSunnyStructuredMessage(
                                              sunnyPayload,
                                            )
                                          : Text(
                                              messageText,
                                              style: TextStyle(
                                                color: isUser
                                                    ? Colors.black
                                                    : Colors.white,
                                              ),
                                            ),
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (_isLoading)
              const Align(
                alignment: Alignment.center,

                child: TypingIndicator(),
              ),

            /* const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(color: Colors.amber),
              ), */
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _imagePool != null
                      ? Stack(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                //borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: FileImage(_imagePool!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: -4,
                              right: -4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _imagePool = null;
                                  });
                                },
                                child: const CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Colors.black54,
                                  child: Icon(
                                    Icons.close,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(height: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _activeWrap
                          ? Wrap(
                              spacing: 0,
                              direction: Axis.vertical,
                              crossAxisAlignment: WrapCrossAlignment.start,
                              alignment: WrapAlignment.center,
                              children: [
                                Text(
                                  'Options inclus :',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: screenWidth * 0.018,
                                  ),
                                ),
                                ...[
                                  'meteo',
                                  'produits',
                                  'mesure de l\'eau',
                                ].map((item) {
                                  return FilterChip(
                                    label: Text(
                                      item.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.02,
                                      ),
                                    ),
                                    selected: _optionSend[item]!,
                                    selectedColor: Colors.amber,
                                    checkmarkColor: Colors.black,
                                    labelStyle: TextStyle(
                                      color: _optionSend[item]!
                                          ? Colors.black
                                          : Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    side: const BorderSide(color: borderColor),
                                    onSelected: (_) {
                                      setState(() {
                                        _optionSend[item] = !_optionSend[item]!;
                                      });
                                    },
                                  );
                                }),
                              ],
                            )
                          : const SizedBox.shrink(),

                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Tapez votre message...',
                                hintStyle: const TextStyle(
                                  color: Colors.white54,
                                ),
                                filled: true,
                                fillColor: const Color(0xFF1A1A1A),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: const BorderSide(
                                    color: Colors.amber,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: const BorderSide(
                                    color: Colors.amber,
                                  ),
                                ),
                                prefixIcon: IconButton(
                                  icon: const Icon(
                                    Icons.menu,
                                    color: Colors.white54,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _activeWrap = !_activeWrap;
                                    });
                                  },
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.white54,
                                  ),
                                  onPressed: showImageSourceSheet,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            backgroundColor: Colors.amber,
                            child: IconButton(
                              icon: const Icon(Icons.send, color: Colors.black),
                              onPressed: () =>
                                  sendMessage(_messageController.text),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListConversation(ConversationModel conversation) {
    final theme = Theme.of(context);
    final title = conversation.title;
    final threadId = conversation.id;
    final favories = conversation.favories;

    void handleFavorite(ConversationModel conversation) async {
      var token = await TokenStorage.getToken();

      try {
        var response = await SunnyService().favoriteConversation(
          token!,
          int.tryParse(conversation.id!)!,
          conversation.favories,
        );

        print(response);
        conversation.favories = response['data']['favorites'];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              conversation.favories
                  ? 'Classer en favorie'
                  : 'N\'est plus votre favorie',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Une erreur à survenue'),
            backgroundColor: Colors.red,
          ),
        );

        conversation.favories = !conversation.favories;
        print(error);
      }
    }

    //Conversation
    void selectConversation(String threadId) async {
      setState(() {
        thread_id = int.tryParse(threadId);
        _messages.clear();
        _isLoading = true;
      });

      Navigator.pop(context);

      try {
        dynamic response = await SunnyService().getConversation(
          tokenValue!,
          int.tryParse(threadId)!,
        );

        List<dynamic> messages = response['data'];

        final loadedMessages = <Map<String, dynamic>>[];

        for (final message in messages) {
          loadedMessages.add({
            'id': uuid.v1(),
            'role': 'user',
            'text': message['message'] ?? '',
          });
          loadedMessages.add({
            'id': uuid.v1(),
            'role': 'assistant',
            'text': message['response'],
          });
        }

        setState(() {
          _messages
            ..clear()
            ..addAll(loadedMessages);
        });

        _scrollToBottom(animated: false);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Une erreur est survenu! $error'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }

    Future<void> deletedConversation(ConversationModel conversation) async {
      final token = await TokenStorage.getToken();

      await SunnyService()
          .deleteConversation(token!, int.tryParse(conversation.id!)!)
          .then((onValue) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(onValue['message']),
                backgroundColor: Colors.green,
              ),
            );
            _getAllConversation();
          });
    }

    void activateConversation(
      MenuEntry selection,
      ConversationModel conversation,
    ) {
      setState(() {
        _lastSelection = selection;
      });

      switch (selection) {
        case MenuEntry.newMessage:
          {
            setState(() {
              _messages.clear();
            });
            Navigator.pop(context);
          }
        /* case MenuEntry.ouvrir:
        debugPrint('Ouvrir'); */
        case MenuEntry.renommer:
          setState(() {
            this.renamedConversation = conversation;
          });
        //showingMessage = !showingMessage;
        case MenuEntry.supprimer:
          deletedConversation(conversation);
        /* setState(() {
          listDossiers.remove(dossier);
        }); */
        case MenuEntry.dupliquer:
        /* setState(() {
          listDossiers.add(
            DossierModel(id: uuid.v1(), name: 'Copie: ${dossier.name}'),
          );
        }); */
        case MenuEntry.discussion:
          break;

        case MenuEntry.addToFolder:
          break;

        case MenuEntry.more:
          break;
      }
    }

    Widget buildMenuConversation(ConversationModel conversation) {
      final FocusNode buttonFocusNode = FocusNode(debugLabel: 'Menu Button');

      return MenuAnchor(
        childFocusNode: buttonFocusNode,
        menuChildren: <Widget>[
          MenuItemButton(
            onPressed: () =>
                activateConversation(MenuEntry.renommer, conversation),
            child: Text(MenuEntry.renommer.label),
          ),
          MenuItemButton(
            onPressed: () =>
                activateConversation(MenuEntry.supprimer, conversation),
            child: Text(MenuEntry.supprimer.label),
          ),
          MenuItemButton(
            onPressed: () =>
                activateConversation(MenuEntry.dupliquer, conversation),
            child: Text(MenuEntry.dupliquer.label),
          ),
          SubmenuButton(
            menuChildren: [
              SubmenuButton(
                menuChildren: [
                  ...listDossiers.map((dossier) {
                    return MenuItemButton(
                      onPressed: () async {
                        var token = await TokenStorage.getToken();

                        try {
                          var response = await FolderThreadServicce()
                              .addThreadToFolder(
                                token!,
                                int.tryParse(dossier.id)!,
                                int.tryParse(conversation.id!)!,
                              );
                          print(response);
                        } catch (error) {
                          print(error);
                        } finally {}
                      },
                      child: Text(dossier.name),
                    );
                  }),
                ],
                child: Text(MenuEntry.addToFolder.label),
              ),
            ],
            child: Text(MenuEntry.more.label),
          ),
        ],
        builder:
            (BuildContext context, MenuController controller, Widget? child) {
              return IconButton(
                focusNode: buttonFocusNode,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 36,
                  height: 36,
                ),
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
              );
            },
      );
    }

    Future<void> renameConversation(
      ConversationModel conversation,
      String newTitle,
    ) async {
      final token = await TokenStorage.getToken();

      await SunnyService()
          .renameConversation(token!, int.tryParse(conversation.id!)!, newTitle)
          .then((onValue) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(onValue['message']),
                backgroundColor: Colors.green,
              ),
            );
            _getAllConversation();
          });
    }

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => selectConversation(threadId!),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: this.renamedConversation == conversation
                  ? TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Renommer la conversation',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                      ),
                      autofocus: true,
                      /* controller:
                                            TextEditingController(text: dossier.name), */
                      onSubmitted: (e) {
                        setState(() {
                          //dossier.name = e;
                          this.renamedConversation = null;
                        });
                        if (e.trim() != '') {
                          renameConversation(conversation, e);
                        }
                      },
                      //),
                    )
                  : Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.amber,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),

            Row(
              children: [
                favories
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            conversation.favories = !favories;
                          });
                          handleFavorite(conversation);
                        },
                        icon: Icon(Icons.favorite, color: Colors.amber),
                      )
                    : IconButton(
                        onPressed: () {
                          setState(() {
                            conversation.favories = !favories;
                          });
                          handleFavorite(conversation);
                        },
                        icon: Icon(Icons.favorite_border, color: Colors.amber),
                      ),
                buildMenuConversation(conversation),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //Other fonctionnalité
  Widget _buildMenuDossier(DossierModel dossier) {
    final FocusNode buttonFocusNode = FocusNode(debugLabel: 'Menu Button');

    return MenuAnchor(
      childFocusNode: buttonFocusNode,
      menuChildren: <Widget>[
        MenuItemButton(
          child: Text(MenuEntry.newMessage.label),
          onPressed: () => _activateDossier(MenuEntry.newMessage, dossier),
        ),
        MenuItemButton(
          onPressed: () => _activateDossier(MenuEntry.renommer, dossier),
          child: Text(MenuEntry.renommer.label),
        ),
        MenuItemButton(
          onPressed: () => _activateDossier(MenuEntry.supprimer, dossier),
          child: Text(MenuEntry.supprimer.label),
        ),
        MenuItemButton(
          onPressed: () => _activateDossier(MenuEntry.dupliquer, dossier),
          child: Text(MenuEntry.dupliquer.label),
        ),
      ],
      builder:
          (BuildContext context, MenuController controller, Widget? child) {
            return IconButton(
              focusNode: buttonFocusNode,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 36, height: 36),
              visualDensity: VisualDensity.compact,
              onPressed: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
            );
          },
    );
  }

  MenuEntry? _lastSelection;

  void _fetchThreadByFolder(int folderId) async {
    print(folderId);
    var token = await TokenStorage.getToken();

    try {
      var response = await FolderThreadServicce().getAllThreadToFolder(
        token!,
        folderId,
      );

      print(response);

      List<ConversationModel> threads = [];

      for (var thread in response['data']) {
        threads.add(
          ConversationModel(
            id: thread['id'].toString(),
            title: thread['title'],
            favories: thread['favorites'],
          ),
        );
      }

      setState(() {
        listConversation = threads;
      });

      print(response);
    } catch (error) {
      print(error);
    } finally {}
  }

  void _fetchFolderThread() async {
    if (!listDossierActive) return;

    setState(() {
      _isLoadingFolder = true;
    });

    var token = await TokenStorage.getToken();
    var poolId = await PoolIdStorage.getPoolId();

    try {
      var response = await FolderThreadServicce().getAllFolderThread(
        token!,
        int.tryParse(poolId!)!,
      );

      if (response['success']) {
        List<DossierModel> dossiers = [];
        for (var dossier in response['data']) {
          dossiers.add(
            DossierModel(
              id: dossier['id'].toString(),
              name: dossier['name'].trim(),
            ),
          );
        }
        setState(() {
          listDossiers = dossiers;
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Une Erreur à survenue $error"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingFolder = false;
        });
      }
    }
  }

  void _handleNewFolder(String name) async {
    if (_folderNameController.text.trim().isEmpty) {
      setState(() {
        addFolder = false;
      });
      return;
    }

    var token = await TokenStorage.getToken();
    var poolId = await PoolIdStorage.getPoolId();

    try {
      var response = await FolderThreadServicce().createFolder(
        token!,
        poolId!,
        DossierModel(id: uuid.v1(), name: name.trim()),
      );

      if (response['success']) {
        print(response['data']);
        setState(() {
          listDossiers.add(DossierModel(id: uuid.v1(), name: name.trim()));
        });
      }
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Une Erreur à survenue $error"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        addFolder = false;
        _folderNameController.clear();
      });
    }
  }

  void _activateDossier(MenuEntry selection, DossierModel dossier) {
    setState(() {
      _lastSelection = selection;
    });

    switch (selection) {
      case MenuEntry.newMessage:
        {
          setState(() {
            sessionId = null;
            _messages.clear();
            listDossierActive = true;
            selectedDossier = dossier;
          });
          Navigator.pop(context);
        }
      /* case MenuEntry.ouvrir:
        debugPrint('Ouvrir'); */
      case MenuEntry.renommer:
        setState(() {
          renamedDossier = dossier;
        });
      //showingMessage = !showingMessage;
      case MenuEntry.supprimer:
        setState(() {
          listDossiers.remove(dossier);
        });
      case MenuEntry.dupliquer:
        setState(() {
          listDossiers.add(
            DossierModel(id: uuid.v1(), name: 'Copie: ${dossier.name}'),
          );
        });
      case MenuEntry.discussion:
        break;
      case MenuEntry.addToFolder:
        break;
      case MenuEntry.more:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    final initialMessage = widget.initialMessage?.trim() ?? '';
    if (!widget.autoSendInitialMessage && initialMessage.isNotEmpty) {
      _messageController.text = initialMessage;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppbarWidget(title: 'Sunny', context: context).build(),
      drawer: _buildDrawerChat(),
      body: _buildContentChat(),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _folderNameController.dispose();
    _messagesScrollController.dispose();
    super.dispose();
  }
}
