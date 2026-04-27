import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sunnypool_app/models/conversation_model.dart';
import 'package:sunnypool_app/models/dossier_model.dart';
import 'package:sunnypool_app/models/message_model.dart';
import 'package:sunnypool_app/screens/login_screen.dart';
import 'package:sunnypool_app/screens/profile_screen.dart';
import 'package:sunnypool_app/services/pool_service.dart';
import 'package:sunnypool_app/services/sunny_service.dart';
import 'package:sunnypool_app/utils/poolId_storage.dart';
import 'package:sunnypool_app/utils/token_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

final uuid = Uuid();

enum MenuEntry {
  newMessage('Nouveau Message'),
  discussion('Continuer la discussion'),
  renommer('Renommer'),
  supprimer('Supprimer'),
  dupliquer('Dupliquer');

  const MenuEntry(this.label, [this.shortcut]);
  final String label;
  final MenuSerializableShortcut? shortcut;
}

class ChatSunnyScreen extends StatefulWidget {
  const ChatSunnyScreen({Key? key}) : super(key: key);

  @override
  State<ChatSunnyScreen> createState() => _ChatSunnyScreenState();
}

class _ChatSunnyScreenState extends State<ChatSunnyScreen> {
  //Variable Principale
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final ScrollController _messagesScrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<Map<String, String>> _messages = [];

  //Variable Drawer
  final TextEditingController _folderNameController = TextEditingController();

  final FocusNode _buttonFocusNode = FocusNode(debugLabel: 'Menu Button');
  MenuEntry? _lastSelection;

  String? sessionId = null;
  int? thread_id = null;

  bool _isLoading = false;
  bool _isLoadingConversation = false;

  bool activeWrap = false;

  File? image_pool;

  String? tokenValue;

  String? selectedMessageId;

  bool listDossierActive = false;

  bool addFolder = false;

  List<DossierModel> listDossiers = [
    DossierModel(id: 'dossier1', name: 'Dossier 1'),
    DossierModel(id: 'dossier2', name: 'Dossier 2'),
  ];

  DossierModel? selectedDossier;
  DossierModel? renamedDossier;

  ConversationModel? renamedConversation;

  void _handleNewFolder(String name) {
    if (_folderNameController.text.trim().isEmpty) {
      setState(() {
        addFolder = false;
      });
      return;
    }

    setState(() {
      listDossiers.add(DossierModel(id: uuid.v1(), name: name.trim()));
      addFolder = false;
      _folderNameController.clear();
    });
  }

  void showOptions(String id) {
    setState(() {
      selectedMessageId = id;
    });
  }

  void hideOptions() {
    setState(() {
      selectedMessageId = null;
    });
  }

  static const _borderColor = Color(0x33FFD54F);

  static const int _pollMaxAttempts = 25;
  static const Duration _pollInterval = Duration(seconds: 2);

  List<ConversationModel> listConversation = [];

  Map<String, bool> optionSend = {
    'meteo': false,
    'historique': true,
    'produits': false,
    'alertes': true,
    'planning': true,
    'coordonnees': true,
    'mesure de l\'eau': false,
  };

  Future<void> _pickImage(ImageSource source) async {
    final XFile? photo = await _picker.pickImage(source: source);

    setState(() {
      image_pool = File(photo!.path);
    });
  }

  void _showImageSourceSheet() {
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
                  _pickImage(ImageSource.gallery);
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
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _sendMessage(String text) {
    if (text.isEmpty && image_pool == null) return;

    var genSession = uuid.v4();

    setState(() {
      _getAIResponse(text, image_pool);
      sessionId = genSession;
      _messages.add({
        'id': genSession,
        'role': 'user',
        'text': text,
        'image': image_pool?.path ?? '',
      });
      _isLoading = true;
      image_pool = null;
    });
    _scrollToBottom();
    _messageController.clear();
  }

  void handleFavorite(ConversationModel conversation) async {
    var token = await TokenStorage.getToken();

    try{
      var response = await SunnyService().favoriteConversation(token!, int.tryParse(conversation.id!)! , conversation.favories);

      print(response);
      conversation.favories = response['data']['favorites'];

      ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(conversation.favories ? 'Classer en favorie' : 'N\'est plus votre favorie'),
                  backgroundColor: Colors.green,
                ),
              );
    }catch(error){
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

  void _getAIResponse(String userMessage, File? image) {
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
              data_options: optionSend,
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
                    'text': 'En cours de traitement. Merci de patienter...',
                  });
                  _isLoading = false;
                  thread_id ??= thread_id = response['thread_id'];
                });
                _scrollToBottom();
              }
              final finalResponse = await _pollUntilCompleted(
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
                  content: Text('Session expirée. Veuillez vous reconnecter.'),
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

  Future<String> _pollUntilCompleted(
    String token,
    String conversationId,
  ) async {
    for (int attempt = 0; attempt < _pollMaxAttempts; attempt++) {
      final res = await SunnyService().responseChat(token, conversationId);
      print(res);
      final found = res['found'] == true;

      if (found) {
        final response = (res['response'] ?? '').toString().trim();
        if (response.isNotEmpty) {
          return response;
        }
      }

      await Future.delayed(_pollInterval);
    }

    throw TimeoutException('Polling timeout');
  }

  Future<void> _getAllConversation() async {
    setState(() {
      _isLoadingConversation = true;
    });

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
            ConversationModel(id: item['id'].toString(), title: item['title'], favories: item['favorites']),
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

  Future<void> _renamedConversation(
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

  Future<void> _deletedConversation(ConversationModel conversation) async {
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //_getAllConversation();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Sunny'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundImage: AssetImage("assets/icon.png"),
              radius: 16,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileScreen()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF111111),
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
                    onTap: () => {
                      if (listDossierActive)
                        {
                          if (selectedDossier != null) _getAllConversation(),

                          setState(() {
                            listDossierActive = false;
                            selectedDossier = null;
                          }),
                        }
                      else
                        {
                          setState(() {
                            listDossierActive = true;
                          }),
                        },
                    },
                  ),
                  !listDossierActive
                      ? const SizedBox.shrink()
                      : Flexible(
                          fit: FlexFit.loose,
                          child: listDossiers.isEmpty
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
                                                listConversation = [];
                                              });
                                            },
                                          );
                                        }).toList(),
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
                            onRefresh: _getAllConversation,
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
      body: Container(
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
                            onTap: () {
                              if (isSelected) {
                                hideOptions();
                              } else {
                                showOptions(id);
                              }
                            },
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
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 5,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  constraints: const BoxConstraints(
                                    maxWidth: 290,
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
                                  child: Text(
                                    msg['text']!,
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
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(color: Colors.amber),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    image_pool != null
                        ? Stack(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  //borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: FileImage(image_pool!),
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
                                      image_pool = null;
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
                        activeWrap
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
                                    //final selected = optionSendChecked.contains(item);
                                    return FilterChip(
                                      label: Text(
                                        item.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.02,
                                        ),
                                      ),
                                      selected: optionSend[item]!,
                                      selectedColor: Colors.amber,
                                      checkmarkColor: Colors.black,
                                      labelStyle: TextStyle(
                                        color: optionSend[item]!
                                            ? Colors.black
                                            : Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      side: const BorderSide(
                                        color: _borderColor,
                                      ),
                                      onSelected: (_) {
                                        setState(() {
                                          optionSend[item] = !optionSend[item]!;
                                        });
                                      },
                                    );
                                  }).toList(),
                                ],
                              )
                            : SizedBox.shrink(),

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
                                        activeWrap = !activeWrap;
                                      });
                                    },
                                  ),
                                  suffixIcon: IconButton(
                                    icon: const Icon(
                                      Icons.add,
                                      color: Colors.white54,
                                    ),
                                    onPressed: _showImageSourceSheet,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            CircleAvatar(
                              backgroundColor: Colors.amber,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.send,
                                  color: Colors.black,
                                ),
                                onPressed: () =>
                                    _sendMessage(_messageController.text),
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
      ),
    );
  }

  Widget _buildListConversation(ConversationModel conversation) {
    final theme = Theme.of(context);
    final title = conversation.title;
    final threadId = conversation.id;

    return /* Card(
      child: */ InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () async {
        setState(() {
          //sessionId = threadId.toString();
          thread_id = int.tryParse(threadId!);
          _messages.clear();
          _isLoading = true;
        });
        Navigator.pop(context);
        dynamic message = await SunnyService().getConversation(
          tokenValue!,
          int.tryParse(threadId!)!,
        );
        List<dynamic> data = message['data'];
        final loadedMessages = <Map<String, String>>[];
        for (final item in data) {
          loadedMessages.add({
            'id': uuid.v1(),
            'role': 'user',
            'text': (item['message'] ?? '').toString(),
          });
          loadedMessages.add({
            'id': uuid.v1(),
            'role': 'assistant',
            'text': (item['response'] ?? '').toString(),
          });
        }
        setState(() {
          _messages
            ..clear()
            ..addAll(loadedMessages);
          _isLoading = false;
        });
        _scrollToBottom(animated: false);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: renamedConversation == conversation
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
                          renamedConversation = null;
                        });
                        if (e.trim() != '')
                          _renamedConversation(conversation, e);
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

            (renamedConversation != conversation)
                ? Row(
                    children: [
                      conversation.favories
                          ? IconButton(
                              onPressed: () {
                                setState(() {
                                  conversation.favories =
                                      !conversation.favories;
                                });
                                handleFavorite(conversation);
                              },
                              icon: Icon(Icons.favorite, color: Colors.amber),
                            )
                          : IconButton(
                              onPressed: () {
                                setState(() {
                                  conversation.favories =
                                      !conversation.favories;
                                });
                                handleFavorite(conversation);
                              },
                              icon: Icon(
                                Icons.favorite_border,
                                color: Colors.amber,
                              ),
                            ),

                      _buildMenuConversation(conversation),
                    ],
                  )
                : SizedBox.shrink(),

            /* IconButton.outlined(
                  style: ButtonStyle(
                    side: MaterialStateProperty.all(
                      const BorderSide(color: Colors.amber),
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    padding: MaterialStateProperty.all(EdgeInsets.zero),
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: () {},
                  icon: const Icon(
                    Icons.more_vert,
                    size: 18,
                    color: Colors.amber,
                  ),
                ), */
          ],
        ),

        //const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.amber),
      ),
    );
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
    }
  }

  void _activateConversation(
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
          renamedConversation = conversation;
        });
      //showingMessage = !showingMessage;
      case MenuEntry.supprimer:
        _deletedConversation(conversation);
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
    }
  }

  Widget _buildMenuDossier(DossierModel dossier) {
    return MenuAnchor(
      childFocusNode: _buttonFocusNode,
      menuChildren: <Widget>[
        MenuItemButton(
          child: Text(MenuEntry.newMessage.label),
          onPressed: () => _activateDossier(MenuEntry.newMessage, dossier),
        ),
        MenuItemButton(
          onPressed: () => _activateDossier(MenuEntry.renommer, dossier),
          //shortcut: MenuEntry.hideMessage.shortcut,
          child: Text(MenuEntry.renommer.label),
        ),
        MenuItemButton(
          onPressed: () => _activateDossier(MenuEntry.supprimer, dossier),
          //shortcut: MenuEntry.showMessage.shortcut,
          child: Text(MenuEntry.supprimer.label),
        ),
        MenuItemButton(
          onPressed: () => _activateDossier(MenuEntry.dupliquer, dossier),
          //shortcut: MenuEntry.showMessage.shortcut,
          child: Text(MenuEntry.dupliquer.label),
        ),
      ],
      builder:
          (BuildContext context, MenuController controller, Widget? child) {
            return IconButton(
              focusNode: _buttonFocusNode,
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

  Widget _buildMenuConversation(ConversationModel conversation) {
    return MenuAnchor(
      childFocusNode: _buttonFocusNode,
      menuChildren: <Widget>[
        /* MenuItemButton(
          child: Text(MenuEntry.newMessage.label),
          onPressed: () => _activateConversation(MenuEntry.newMessage, conversation),
        ), */
        MenuItemButton(
          onPressed: () =>
              _activateConversation(MenuEntry.renommer, conversation),
          //shortcut: MenuEntry.hideMessage.shortcut,
          child: Text(MenuEntry.renommer.label),
        ),
        MenuItemButton(
          onPressed: () =>
              _activateConversation(MenuEntry.supprimer, conversation),
          //shortcut: MenuEntry.showMessage.shortcut,
          child: Text(MenuEntry.supprimer.label),
        ),
        MenuItemButton(
          onPressed: () =>
              _activateConversation(MenuEntry.dupliquer, conversation),
          //shortcut: MenuEntry.showMessage.shortcut,
          child: Text(MenuEntry.dupliquer.label),
        ),
      ],
      builder:
          (BuildContext context, MenuController controller, Widget? child) {
            return IconButton(
              focusNode: _buttonFocusNode,
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

  @override
  void dispose() {
    _messageController.dispose();
    _messagesScrollController.dispose();
    super.dispose();
  }
}
