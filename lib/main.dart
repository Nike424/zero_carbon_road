import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:record/record.dart';
import 'services/ai_chat_service.dart';
import 'services/step_service.dart';
import 'services/upload_validator.dart';

// ------------------------------
// 全局配置
// ------------------------------
const String globalFontFamily = "Microsoft YaHei";
const Color green50 = Color(0xFFE8F5E9);
const Color amber50 = Color(0xFFFFF8E1);
const Color grey50 = Color(0xFFFAFAFA);
const Color grey300 = Color(0xFFE0E0E0);

// ------------------------------
// 用户状态
// ------------------------------
class UserState {
  static bool isLogin = false;
  static String userName = "环保小卫士";
  static String userPassword = "123456";
  static bool rememberPwd = false;
  static String userSign = "用行动守护地球";
  static String userAvatar = "";
  static String userGender = "保密";
  static String userArea = "上海市";
  static String userBirthday = "2000-01-01";

  static int totalEnergy = 1280;
  static int todayStep = 0;
  static int todayEnergyGet = 120;
  static int totalCarbonReduce = 2800;
  static bool isDarkMode = false;

  static int signInDay = 0;
  static bool todaySigned = false;
  static String lastSignDate = "";

  static List<String> unlockedCountries = ["中国", "越南"];
  static List<String> finishedAchievements = ["起步者", "步行达人"];
  static List<Map<String, dynamic>> carbonRecords = [];
  static List<Map<String, dynamic>> messages = [
    {"title": "欢迎来到碳碳", "content": "开启你的低碳生活之旅吧！", "time": "今天 00:00", "read": false},
    {"title": "成就解锁", "content": "你解锁了「步行达人」成就", "time": "昨天 19:20", "read": true},
  ];

  static List<Map<String, dynamic>> dailyTasks = [
    {"id": "walk", "title": "步行满8000步", "reward": 40, "finished": false},
    {"id": "upload", "title": "上传1次减碳行为", "reward": 30, "finished": true},
    {"id": "read", "title": "阅读1篇环保知识", "reward": 10, "finished": true},
    {"id": "calc", "title": "使用碳足迹计算器", "reward": 15, "finished": false},
    {"id": "sign", "title": "每日签到", "reward": 10, "finished": false},
  ];

  static List<Map<String, dynamic>> allAchievements = [
    {"id": "start", "title": "起步者", "desc": "首次获得能量", "icon": Icons.flag, "unlocked": true},
    {"id": "walk", "title": "步行达人", "desc": "单日步数超 10000", "icon": Icons.directions_walk, "unlocked": true},
    {"id": "upload10", "title": "环保先锋", "desc": "上传 10 次减碳行为", "icon": Icons.upload_file, "unlocked": false},
    {"id": "country3", "title": "环球旅行者", "desc": "解锁 3 个国家", "icon": Icons.public, "unlocked": false},
    {"id": "energy5000", "title": "零碳大师", "desc": "总能量超 5000", "icon": Icons.emoji_events, "unlocked": false},
    {"id": "read10", "title": "知识达人", "desc": "阅读 10 篇环保知识", "icon": Icons.menu_book, "unlocked": false},
    {"id": "friend5", "title": "社交达人", "desc": "添加5位好友", "icon": Icons.people, "unlocked": false},
  ];

  static List<Map<String, dynamic>> friends = [
    {"name": "低碳同学A", "energy": 2120, "isOnline": true, "avatar": ""},
    {"name": "环保同学B", "energy": 1860, "isOnline": false, "avatar": ""},
    {"name": "绿色使者", "energy": 3920, "isOnline": true, "avatar": ""},
  ];

  static List<Moment> moments = [
    Moment(
      user: "低碳同学A",
      avatar: "",
      content: "今天骑共享单车上班，减碳3.2kg！🚲",
      images: ["https://picsum.photos/400/400?random=201"],
      time: "2小时前",
      likes: 12,
      comments: [Comment(user: "环保同学B", content: "太棒了！")],
      isLiked: false,
    ),
    Moment(
      user: "绿色使者",
      avatar: "",
      content: "光盘行动，从我做起！🍽️",
      images: ["https://picsum.photos/400/400?random=202", "https://picsum.photos/400/400?random=203"],
      time: "昨天",
      likes: 28,
      comments: [],
      isLiked: true,
    ),
  ];

  static Set<String> registeredUsers = {"环保小卫士", "低碳同学A", "环保同学B", "绿色使者"};

  static List<Map<String, dynamic>> mallGoods = [
    {"id": "badge1", "title": "环保先锋徽章", "price": 500, "type": "badge", "bought": false, "imageUrl": "https://cdn-icons-png.flaticon.com/512/2917/2917995.png"},
    {"id": "badge2", "title": "零碳大师徽章", "price": 1000, "type": "badge", "bought": false, "imageUrl": "https://cdn-icons-png.flaticon.com/512/2917/2917632.png"},
    {"id": "bag", "title": "环保帆布袋", "price": 2000, "type": "goods", "bought": false, "imageUrl": "https://cdn-icons-png.flaticon.com/512/3081/3081559.png"},
    {"id": "cup", "title": "不锈钢保温杯", "price": 3000, "type": "goods", "bought": false, "imageUrl": "https://cdn-icons-png.flaticon.com/512/3081/3081892.png"},
    {"id": "tshirt", "title": "有机棉T恤", "price": 3500, "type": "goods", "bought": false, "imageUrl": "https://cdn-icons-png.flaticon.com/512/3081/3081987.png"},
    {"id": "notebook", "title": "种子纸笔记本", "price": 800, "type": "goods", "bought": false, "imageUrl": "https://cdn-icons-png.flaticon.com/512/2997/2997924.png"},
    {"id": "straw", "title": "不锈钢吸管套装", "price": 600, "type": "goods", "bought": false, "imageUrl": "https://cdn-icons-png.flaticon.com/512/3135/3135715.png"},
    {"id": "bottle", "title": "折叠水杯", "price": 1200, "type": "goods", "bought": false, "imageUrl": "https://cdn-icons-png.flaticon.com/512/3081/3081861.png"},
    {"id": "bag2", "title": "蜂蜡保鲜布", "price": 400, "type": "goods", "bought": false, "imageUrl": "https://cdn-icons-png.flaticon.com/512/2933/2933116.png"},
  ];

  static String spriteName = "碳碳";
  static int spriteLevel = 8;
  static int spriteExp = 390;
  static int spriteMaxExp = 700;
  static List<String> ownedDecorations = [];
  static String currentSpriteImage = "assets/icon/app_icon.png";
  static String equippedHat = "";
  static String equippedScarf = "";
  static String equippedGlasses = "";

  static List<Map<String, dynamic>> knowledgeList = [
    {"title": "什么是碳足迹？", "content": "碳足迹是指企业机构、活动、产品或个人通过交通运输、食品生产和消费以及各类生产过程等引起的温室气体排放的集合。", "icon": Icons.eco},
    {"title": "为什么要垃圾分类？", "content": "垃圾分类可以减少占地，减少环境污染，变废为宝。每回收1吨废纸可造好纸850公斤，节省木材300公斤。", "icon": Icons.recycling},
    {"title": "如何节约用电？", "content": "使用节能灯泡，随手关灯，空调温度设置在26度，电器不用时拔掉插头，这些都能有效减少碳排放。", "icon": Icons.lightbulb},
  ];

  static int knowledgeReadCount = 0;

  static Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("isLogin", isLogin);
    prefs.setString("userName", userName);
    prefs.setInt("totalEnergy", totalEnergy);
    prefs.setInt("totalCarbonReduce", totalCarbonReduce);
    prefs.setString("userAvatar", userAvatar);
    prefs.setStringList("friends", friends.map((e) => jsonEncode(e)).toList());
  }

  static Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    isLogin = prefs.getBool("isLogin") ?? false;
    userName = prefs.getString("userName") ?? "环保小卫士";
    totalEnergy = prefs.getInt("totalEnergy") ?? 1280;
    totalCarbonReduce = prefs.getInt("totalCarbonReduce") ?? 2800;
    userAvatar = prefs.getString("userAvatar") ?? "";
    final friendList = prefs.getStringList("friends");
    if (friendList != null) {
      friends = friendList.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
    }
  }
}

class Moment {
  final String user;
  final String avatar;
  final String content;
  final List<String> images;
  final String time;
  int likes;
  List<Comment> comments;
  bool isLiked;
  Moment({required this.user, required this.avatar, required this.content, this.images = const [], required this.time, required this.likes, required this.comments, required this.isLiked});
}

class Comment {
  final String user;
  final String content;
  Comment({required this.user, required this.content});
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserState.loadData();
  runApp(const CarbonCarbonApp());
}

class CarbonCarbonApp extends StatefulWidget {
  const CarbonCarbonApp({super.key});
  @override
  State<CarbonCarbonApp> createState() => CarbonCarbonAppState();
}

class CarbonCarbonAppState extends State<CarbonCarbonApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '碳碳',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: UserState.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF0F8F0),
        fontFamily: globalFontFamily,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      home: UserState.isLogin ? const MainPage() : const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ---------- 登录页 ----------
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  bool _isRegister = false;

  void _doLogin() async {
    if (_nameController.text.isEmpty || _pwdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("请填写用户名和密码")));
      return;
    }
    if (_isRegister) {
      if (UserState.registeredUsers.contains(_nameController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("用户名已存在")));
        return;
      }
      UserState.userName = _nameController.text;
      UserState.userPassword = _pwdController.text;
      UserState.isLogin = true;
      UserState.registeredUsers.add(_nameController.text);
      await UserState.saveData();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const MainPage()));
    } else {
      if (_nameController.text == UserState.userName && _pwdController.text == UserState.userPassword) {
        UserState.isLogin = true;
        await UserState.saveData();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const MainPage()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("用户名或密码错误")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Colors.green, Colors.lightGreen], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                Image.asset('assets/icon/app_icon.png', width: 80),
                const SizedBox(height: 16),
                const Text("🌱 碳碳", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 50),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        TextField(controller: _nameController, decoration: InputDecoration(labelText: "用户名", prefixIcon: const Icon(Icons.person), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                        const SizedBox(height: 20),
                        TextField(controller: _pwdController, obscureText: true, decoration: InputDecoration(labelText: "密码", prefixIcon: const Icon(Icons.lock), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _doLogin,
                            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(18), backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            child: Text(_isRegister ? "注册" : "登录", style: const TextStyle(fontSize: 18, color: Colors.white)),
                          ),
                        ),
                        TextButton(onPressed: () => setState(() => _isRegister = !_isRegister), child: Text(_isRegister ? "已有账号？去登录" : "没有账号？去注册", style: const TextStyle(color: Colors.green))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------- 主页面 ----------
class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  late final List<Widget> _pages;
  final StepService _stepService = StepService();
  final AudioRecorder _audioRecorder = AudioRecorder();
  Offset _ballPosition = const Offset(300, 100);
  bool _showChat = false;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(stepService: _stepService),
      const EnergyPage(),
      const UploadPage(),
      const FriendPage(),
      const MinePage(),
    ];
    _initStepService();
  }

  Future<void> _initStepService() async {
    try {
      await _stepService.requestPermission();
      _stepService.startListening();
      _stepService.stepStream.listen((steps) {
        if (mounted) setState(() { UserState.todayStep = steps; });
      });
    } catch (e) {
      debugPrint('步数服务启动失败: $e');
    }
  }

  @override
  void dispose() {
    _stepService.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _pages[_currentIndex],
          Positioned(
            left: _ballPosition.dx,
            top: _ballPosition.dy,
            child: Draggable(
              feedback: _buildBall(),
              childWhenDragging: Opacity(opacity: 0.3, child: _buildBall()),
              onDragEnd: (details) {
                setState(() {
                  double newX = details.offset.dx.clamp(0, MediaQuery.of(context).size.width - 60);
                  double newY = details.offset.dy.clamp(0, MediaQuery.of(context).size.height - 100);
                  _ballPosition = Offset(newX, newY);
                });
              },
              child: GestureDetector(
                onTap: () => setState(() => _showChat = true),
                child: _buildBall(),
              ),
            ),
          ),
          if (_showChat)
            Positioned(
              bottom: 20,
              right: 20,
              child: CarbonChatDialog(
                onClose: () => setState(() => _showChat = false),
                audioRecorder: _audioRecorder,
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))]),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "首页"),
            BottomNavigationBarItem(icon: Icon(Icons.bolt_rounded), label: "能量"),
            BottomNavigationBarItem(icon: Icon(Icons.upload_rounded), label: "上传"),
            BottomNavigationBarItem(icon: Icon(Icons.people_rounded), label: "好友"),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "我的"),
          ],
        ),
      ),
    );
  }

  Widget _buildBall() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
        image: const DecorationImage(image: AssetImage('assets/icon/app_icon.png'), fit: BoxFit.cover),
      ),
    );
  }
}

// ---------- 碳碳聊天对话框 (全新设计) ----------
class CarbonChatDialog extends StatefulWidget {
  final VoidCallback onClose;
  final AudioRecorder audioRecorder;
  const CarbonChatDialog({super.key, required this.onClose, required this.audioRecorder});

  @override
  State<CarbonChatDialog> createState() => _CarbonChatDialogState();
}

class _CarbonChatDialogState extends State<CarbonChatDialog> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final AiChatService _aiService = AiChatService();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _isRecording = false;

  void _sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return;
    setState(() {
      _messages.add({"role": "user", "content": text});
      _messages.add({"role": "assistant", "content": ""});
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    final apiMessages = <Map<String, String>>[];
    apiMessages.add({"role": "system", "content": "你是碳碳，一个可爱的环保助手，请用亲切鼓励的语气回答，使用emoji，简洁明了。"});
    final historyStart = _messages.length > 11 ? _messages.length - 11 : 0;
    for (int i = historyStart; i < _messages.length - 1; i++) {
      if (_messages[i]["content"]!.isNotEmpty) {
        apiMessages.add({"role": _messages[i]["role"]!, "content": _messages[i]["content"]!});
      }
    }
    try {
      final stream = _aiService.sendMessage(apiMessages);
      String fullResponse = "";
      await for (final chunk in stream) {
        fullResponse += chunk;
        if (mounted) setState(() => _messages.last["content"] = fullResponse);
        _scrollToBottom();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    });
  }

  Future<void> _startRecording() async {
    if (await widget.audioRecorder.hasPermission()) {
      setState(() => _isRecording = true);
      await widget.audioRecorder.start(const RecordConfig(), path: 'temp_audio.m4a');
    }
  }

  Future<void> _stopRecording() async {
    final path = await widget.audioRecorder.stop();
    setState(() => _isRecording = false);
    if (path != null) {
      _sendMessage("🎤 语音消息");
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _sendMessage("📷 图片: ${image.path}");
    }
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      _sendMessage("📸 拍照: ${photo.path}");
    }
  }

  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(leading: const Icon(Icons.photo_library), title: const Text("相册"), onTap: () { Navigator.pop(ctx); _pickImage(); }),
            ListTile(leading: const Icon(Icons.camera_alt), title: const Text("拍照"), onTap: () { Navigator.pop(ctx); _takePhoto(); }),
            ListTile(leading: const Icon(Icons.insert_drive_file), title: const Text("文件"), onTap: () => Navigator.pop(ctx)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: UserState.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Colors.green, Colors.teal]),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(backgroundImage: AssetImage('assets/icon/app_icon.png')),
                  const SizedBox(width: 12),
                  const Text('碳碳小助手', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: widget.onClose),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg["role"] == "user";
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!isUser) const CircleAvatar(backgroundImage: AssetImage('assets/icon/app_icon.png'), radius: 16),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isUser ? Colors.green.shade100 : Colors.grey.shade200,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                                bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                              ),
                            ),
                            child: msg["content"]!.isEmpty
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : Text(msg["content"]!, style: const TextStyle(fontSize: 15)),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(_isRecording ? Icons.mic : Icons.mic_none, color: _isRecording ? Colors.red : Colors.grey),
                    onPressed: _isRecording ? _stopRecording : _startRecording,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: !_isLoading,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: '输入消息...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      onSubmitted: (value) => _sendMessage(value),
                    ),
                  ),
                  const SizedBox(width: 4),
                  CircleAvatar(
                    backgroundColor: Colors.green,
                    radius: 20,
                    child: IconButton(
                      icon: Icon(_isLoading ? Icons.hourglass_empty : Icons.send, color: Colors.white, size: 20),
                      onPressed: _isLoading ? null : () => _sendMessage(_controller.text),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                    onPressed: _showAttachmentMenu,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ---------- 首页 ----------
class HomePage extends StatefulWidget {
  final StepService stepService;
  const HomePage({super.key, required this.stepService});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    int unreadCount = UserState.messages.where((e) => !e["read"]).length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: (UserState.userAvatar.isNotEmpty && File(UserState.userAvatar).existsSync())
                      ? FileImage(File(UserState.userAvatar)) as ImageProvider
                      : const AssetImage('assets/icon/app_icon.png'),
            ),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("你好，${UserState.userName}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(UserState.userSign, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                ]),
              ],
            ),
            Stack(
              children: [
                IconButton(icon: const Icon(Icons.notifications_outlined, size: 30), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MessagePage()))),
                if (unreadCount > 0) Positioned(top: 6, right: 6, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: Text("$unreadCount", style: const TextStyle(color: Colors.white, fontSize: 10)))),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Colors.green, Colors.lightGreen], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [const Icon(Icons.bolt, color: Colors.white, size: 28), const SizedBox(width: 8), const Text("总能量", style: TextStyle(color: Colors.white, fontSize: 18)), const Spacer(), Text("减碳 ${(UserState.totalCarbonReduce / 1000).toStringAsFixed(1)}kg", style: const TextStyle(color: Colors.white70))]),
              const SizedBox(height: 8),
              Text("${UserState.totalEnergy} ⚡", style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(children: [const Icon(Icons.directions_walk, color: Colors.white), const SizedBox(width: 8), Text("${UserState.todayStep} 步", style: const TextStyle(color: Colors.white, fontSize: 18)), const Spacer(), Text("兑换 ${(UserState.todayStep ~/ 100).toInt()} ⚡", style: const TextStyle(color: Colors.white70))]),
              const SizedBox(height: 12),
              LinearProgressIndicator(value: (UserState.todayStep / 10000).clamp(0.0, 1.0), backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation<Color>(Colors.white)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildQuickCard(Icons.calculate, "碳足迹", const Color(0xFF4CAF50), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CarbonCalculatorPage()))),
            _buildQuickCard(Icons.menu_book, "环保知识", const Color(0xFF2196F3), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KnowledgePage()))),
            _buildQuickCard(Icons.emoji_events, "任务", const Color(0xFFFF9800), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TaskPage()))),
            _buildQuickCard(Icons.shopping_bag, "商城", const Color(0xFFE91E63), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MallPage()))),
          ],
        ),
        const SizedBox(height: 30),
        const Text("📋 今日任务", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...UserState.dailyTasks.take(3).map((task) => TaskCard(task: task, onRefresh: () => setState(() {}))),
        TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TaskPage())), child: const Text("查看全部", style: TextStyle(color: Colors.green))),
      ],
    );
  }

  Widget _buildQuickCard(IconData icon, String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 3))]),
        child: Column(children: [
          CircleAvatar(radius: 20, backgroundColor: color.withOpacity(0.15), child: Icon(icon, color: color, size: 22)),
          const SizedBox(height: 6),
          Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color)),
        ]),
      ),
    );
  }
}

// ---------- 能量页 ----------
class EnergyPage extends StatelessWidget {
  const EnergyPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("⚡ 能量中心"), centerTitle: true, backgroundColor: Colors.white, foregroundColor: Colors.green, elevation: 0),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const SizedBox(height: 10),
        Center(child: Text("${UserState.totalEnergy} ⚡", style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.green))),
        const SizedBox(height: 20),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 2,
          child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("本周碳排放趋势", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 160, child: LineChart(LineChartData(lineBarsData: [LineChartBarData(spots: const [FlSpot(0,3), FlSpot(1,2.5), FlSpot(2,4), FlSpot(3,3.2), FlSpot(4,2.8), FlSpot(5,1.9), FlSpot(6,2.3)], isCurved: true, color: Colors.green, barWidth: 3)]))),
          ])),
        ),
        const SizedBox(height: 20),
        EnergyDetailItem(title: "步行 ${UserState.todayStep} 步", value: "+${(UserState.todayStep ~/ 100).toInt()}", time: "今天"),
        const EnergyDetailItem(title: "上传减碳行为", value: "+40", time: "12:10"),
        const EnergyDetailItem(title: "完成每日任务", value: "+20", time: "18:25"),
      ]),
    );
  }
}

// ---------- 上传页 ----------
class UploadPage extends StatefulWidget {
  const UploadPage({super.key});
  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  int _selectedType = 0;
  final TextEditingController _descController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];
  int _getEnergy = 20;
  int _carbonReduce = 200;

  final List<Map<String, dynamic>> types = [
    {"icon": Icons.directions_walk, "title": "绿色出行", "energy": 20, "carbon": 200},
    {"icon": Icons.restaurant, "title": "低碳饮食", "energy": 30, "carbon": 350},
    {"icon": Icons.recycling, "title": "垃圾分类", "energy": 25, "carbon": 250},
    {"icon": Icons.lightbulb, "title": "节约能源", "energy": 15, "carbon": 150},
    {"icon": Icons.shopping_bag, "title": "绿色消费", "energy": 35, "carbon": 400},
    {"icon": Icons.volunteer_activism, "title": "植树造林", "energy": 100, "carbon": 1000},
  ];

  void _doUpload() async {
    if (_descController.text.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("请填写行为描述"))); return; }
    final typeTitle = types[_selectedType]["title"];
    final validation = UploadValidator.validate(typeTitle, _descController.text);
    if (!validation.valid) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(validation.message!))); return; }
    setState(() {
      UserState.totalEnergy += _getEnergy;
      UserState.totalCarbonReduce += _carbonReduce;
      UserState.dailyTasks.firstWhere((e) => e["id"] == "upload")["finished"] = true;
    });
    UserState.saveData();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("上传成功！获得 $_getEnergy 能量")));
    _descController.clear();
    _selectedImages.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("📤 上传减碳行为"), centerTitle: true),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("选择行为类型", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Wrap(spacing: 8, children: List.generate(types.length, (index) => ChoiceChip(label: Text(types[index]["title"]), selected: _selectedType == index, onSelected: (_) => setState(() { _selectedType = index; _getEnergy = types[index]["energy"] as int; _carbonReduce = types[index]["carbon"] as int; })))),
        const SizedBox(height: 20),
        TextField(controller: _descController, maxLines: 4, decoration: const InputDecoration(hintText: "请描述你的减碳行为...", border: OutlineInputBorder())),
        const SizedBox(height: 20),
        Wrap(spacing: 8, children: [..._selectedImages.map((img) => Image.file(img, width: 80, height: 80, fit: BoxFit.cover)), if (_selectedImages.length < 9) InkWell(onTap: () async { final images = await _picker.pickMultiImage(); if (images != null) setState(() => _selectedImages.addAll(images.map((e) => File(e.path)))); }, child: Container(width: 80, height: 80, decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.add_photo_alternate)))]),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _doUpload, style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text("确认上传并领取奖励", style: TextStyle(fontSize: 16, color: Colors.white)))),
      ])),
    );
  }
}

// ---------- 好友页 ----------
class FriendPage extends StatefulWidget {
  const FriendPage({super.key});
  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() { super.initState(); _tabController = TabController(length: 2, vsync: this); }
  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  Widget _buildMomentCard(Moment moment) {
    return Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [CircleAvatar(backgroundImage: moment.avatar.isNotEmpty ? FileImage(File(moment.avatar)) : null, child: moment.avatar.isEmpty ? const Icon(Icons.person) : null), const SizedBox(width: 10), Text(moment.user, style: const TextStyle(fontWeight: FontWeight.bold)), const Spacer(), Text(moment.time, style: const TextStyle(color: Colors.grey, fontSize: 12))]),
      if (moment.content.isNotEmpty) Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(moment.content)),
      if (moment.images.isNotEmpty) SizedBox(height: 100, child: ListView(scrollDirection: Axis.horizontal, children: moment.images.map((img) => Padding(padding: const EdgeInsets.only(right: 8), child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(img), width: 100, fit: BoxFit.cover)))).toList())),
      const SizedBox(height: 8),
      Row(children: [IconButton(icon: Icon(moment.isLiked ? Icons.favorite : Icons.favorite_border, color: moment.isLiked ? Colors.red : null), onPressed: () => setState(() { moment.isLiked = !moment.isLiked; moment.likes += moment.isLiked ? 1 : -1; })), Text("${moment.likes}"), const SizedBox(width: 16), IconButton(icon: const Icon(Icons.comment), onPressed: () {}), Text("${moment.comments.length}")]),
    ])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("好友圈"), centerTitle: true, bottom: TabBar(controller: _tabController, tabs: const [Tab(text: "动态"), Tab(text: "好友")])),
      body: TabBarView(controller: _tabController, children: [
        ListView.builder(itemCount: UserState.moments.length, itemBuilder: (_, i) => _buildMomentCard(UserState.moments[i])),
        ListView.builder(itemCount: UserState.friends.length, itemBuilder: (_, i) {
          final friend = UserState.friends[i];
          return ListTile(
            leading: CircleAvatar(child: Text(friend["name"][0])),
            title: Text(friend["name"]),
            subtitle: Text("能量值: ${friend["energy"]}"),
            trailing: IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatPage(friendName: friend["name"]))),
            ),
          );
        }),
      ]),
    );
  }
}

class ChatPage extends StatefulWidget {
  final String friendName;
  const ChatPage({super.key, required this.friendName});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Map<String, String>> _messages = [{"role": "friend", "content": "你好！今天减碳了吗？", "time": "10:30"}];
  final TextEditingController _controller = TextEditingController();

  void _send() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add({"role": "me", "content": _controller.text, "time": "${DateTime.now().hour}:${DateTime.now().minute}"});
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.friendName)),
      body: Column(children: [
        Expanded(child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: _messages.length, itemBuilder: (_, i) {
          final msg = _messages[i];
          final isMe = msg["role"] == "me";
          return Align(alignment: isMe ? Alignment.centerRight : Alignment.centerLeft, child: Container(padding: const EdgeInsets.all(12), margin: const EdgeInsets.symmetric(vertical: 4), decoration: BoxDecoration(color: isMe ? Colors.green.shade100 : Colors.grey.shade200, borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(msg["content"]!), Text(msg["time"]!, style: const TextStyle(fontSize: 10, color: Colors.grey))])));
        })),
        Padding(padding: const EdgeInsets.all(8.0), child: Row(children: [Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: "输入消息", border: OutlineInputBorder()))), IconButton(icon: const Icon(Icons.send, color: Colors.green), onPressed: _send)])),
      ]),
    );
  }
}
// ---------- 我的页面 ----------
class MinePage extends StatefulWidget {
  const MinePage({super.key});
  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> with SingleTickerProviderStateMixin {
  late AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("我的"), centerTitle: true, backgroundColor: Colors.white, foregroundColor: Colors.green, elevation: 0),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Center(child: Column(children: [
          CircleAvatar(radius: 50, backgroundImage: UserState.userAvatar.isNotEmpty ? FileImage(File(UserState.userAvatar)) : AssetImage('assets/icon/app_icon.png')),
          const SizedBox(height: 12),
          Text(UserState.userName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(UserState.userSign, style: TextStyle(color: Colors.grey[600])),
        ])),
        const SizedBox(height: 20),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              GestureDetector(
                onTap: () {
                  setState(() { UserState.spriteExp += 10; UserState.totalEnergy += 5; });
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("碳碳很开心！+5能量")));
                },
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(_spinController.value * 2 * pi),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset('assets/icon/app_icon.png', width: 100, height: 100),
                      if (UserState.equippedHat.isNotEmpty) Positioned(top: -10, child: Icon(Icons.cabin, size: 40, color: Colors.brown)),
                      if (UserState.equippedGlasses.isNotEmpty) Positioned(child: Icon(Icons.sunny, size: 60, color: Colors.black45)),
                      if (UserState.equippedScarf.isNotEmpty) Positioned(bottom: -10, child: Icon(Icons.style, size: 30, color: Colors.red)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text("${UserState.spriteName}  Lv.${UserState.spriteLevel}", style: const TextStyle(fontWeight: FontWeight.bold)),
              LinearProgressIndicator(value: UserState.spriteExp / UserState.spriteMaxExp),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _buildSpriteAction(Icons.favorite, "互动", () {}),
                _buildSpriteAction(Icons.checkroom, "穿搭", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SpriteDressUpPage()))),
                _buildSpriteAction(Icons.more_horiz, "更多", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SpriteMorePage()))),
              ]),
            ]),
          ),
        ),
        const Divider(height: 30),
        ListTile(leading: const Icon(Icons.emoji_events), title: const Text("我的成就"), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AchievementPage()))),
        ListTile(leading: const Icon(Icons.history), title: const Text("减碳记录"), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CarbonRecordPage()))),
        ListTile(leading: const Icon(Icons.card_giftcard), title: const Text("我的徽章/商品"), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MallPage()))),
        ListTile(leading: const Icon(Icons.exit_to_app, color: Colors.red), title: const Text("退出登录"), onTap: () { UserState.isLogin = false; Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage())); }),
      ]),
    );
  }

  Widget _buildSpriteAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(onTap: onTap, child: Column(children: [CircleAvatar(backgroundColor: Colors.green.shade50, child: Icon(icon, color: Colors.green)), const SizedBox(height: 4), Text(label, style: const TextStyle(fontSize: 12))]));
  }
}

// ---------- 精灵穿搭 ----------
class SpriteDressUpPage extends StatefulWidget {
  const SpriteDressUpPage({super.key});
  @override
  State<SpriteDressUpPage> createState() => _SpriteDressUpPageState();
}

class _SpriteDressUpPageState extends State<SpriteDressUpPage> {
  final List<Map<String, dynamic>> decorations = [
    {"name": "小草帽", "type": "hat", "price": 200, "icon": Icons.cabin},
    {"name": "小围巾", "type": "scarf", "price": 300, "icon": Icons.style},
    {"name": "太阳镜", "type": "glasses", "price": 500, "icon": Icons.sunny},
  ];

  void _equip(Map<String, dynamic> item) {
    if (!UserState.ownedDecorations.contains(item["name"])) return;
    setState(() {
      switch (item["type"]) {
        case "hat": UserState.equippedHat = item["name"]; break;
        case "scarf": UserState.equippedScarf = item["name"]; break;
        case "glasses": UserState.equippedGlasses = item["name"]; break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("精灵穿搭")),
      body: GridView.builder(padding: const EdgeInsets.all(16), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3), itemCount: decorations.length, itemBuilder: (_, i) {
        final item = decorations[i];
        return Card(
          child: InkWell(
            onTap: () {
              if (!UserState.ownedDecorations.contains(item["name"])) {
                int price = item["price"] as int;
                showDialog(context: context, builder: (_) => AlertDialog(title: Text("购买${item["name"]}"), content: Text("消耗$price能量？"), actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("取消")),
                  ElevatedButton(onPressed: () {
                    if (UserState.totalEnergy >= price) {
                      setState(() { UserState.totalEnergy -= price; UserState.ownedDecorations.add(item["name"]); });
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("能量不足")));
                    }
                  }, child: const Text("购买")),
                ]));
              } else {
                _equip(item);
              }
            },
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(item["icon"], size: 40, color: UserState.ownedDecorations.contains(item["name"]) ? Colors.green : Colors.grey),
              Text(item["name"]),
            ]),
          ),
        );
      }),
    );
  }
}

// ---------- 精灵更多玩法 ----------
class SpriteMorePage extends StatelessWidget {
  const SpriteMorePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("更多玩法")), body: GridView.count(crossAxisCount: 3, padding: const EdgeInsets.all(16), children: [
    _buildItem(Icons.work, "打工", () { UserState.totalEnergy += 50; ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("打工完成！+50能量"))); }),
    _buildItem(Icons.chat, "AI聊天", () {}),
    _buildItem(Icons.emoji_emotions, "表情包", () {}),
    _buildItem(Icons.leaderboard, "火星排行", () {}),
  ]));
  Widget _buildItem(IconData icon, String label, VoidCallback onTap) => InkWell(onTap: onTap, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircleAvatar(backgroundColor: Colors.green.shade50, child: Icon(icon, color: Colors.green)), const SizedBox(height: 8), Text(label)]));
}

// ---------- 商城 ----------
class MallPage extends StatelessWidget {
  const MallPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("环保商城")),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.75),
        itemCount: UserState.mallGoods.length,
        itemBuilder: (context, index) {
          final goods = UserState.mallGoods[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(children: [
                Expanded(child: CachedNetworkImage(imageUrl: goods["imageUrl"], fit: BoxFit.cover)),
                Text(goods["title"], style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("${goods["price"]} ⚡"),
                ElevatedButton(
                  onPressed: goods["bought"] ? null : () {
                    int price = goods["price"] as int;
                    if (UserState.totalEnergy >= price) {
                      goods["bought"] = true;
                      UserState.totalEnergy -= price;
                      UserState.saveData();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("兑换成功！获得${goods["title"]}")));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("能量不足")));
                    }
                  },
                  child: Text(goods["bought"] ? "已兑换" : "兑换"),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }
}

// ---------- 任务 ----------
class TaskPage extends StatelessWidget {
  const TaskPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("每日任务")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: UserState.dailyTasks.length,
        itemBuilder: (context, index) => TaskCard(task: UserState.dailyTasks[index], onRefresh: () => (context as Element).markNeedsBuild()),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final Map<String, dynamic> task;
  final VoidCallback onRefresh;
  const TaskCard({super.key, required this.task, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: task["finished"] ? Colors.green : Colors.grey[300], child: Icon(task["finished"] ? Icons.check : Icons.timelapse)),
        title: Text(task["title"]),
        subtitle: Text("奖励 ${task["reward"]} 能量"),
        trailing: task["finished"] ? null : ElevatedButton(onPressed: () {
          task["finished"] = true;
          UserState.totalEnergy += task["reward"] as int;
          UserState.saveData();
          onRefresh();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("完成任务！获得${task["reward"]}能量")));
        }, child: const Text("领取")),
      ),
    );
  }
}

// ---------- 知识 ----------
class KnowledgePage extends StatelessWidget {
  const KnowledgePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("环保知识")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: UserState.knowledgeList.length,
        itemBuilder: (context, index) {
          final item = UserState.knowledgeList[index];
          return Card(
            child: ExpansionTile(
              leading: Icon(item["icon"], color: Colors.green),
              title: Text(item["title"]),
              children: [
                Padding(padding: const EdgeInsets.all(16), child: Text(item["content"])),
                TextButton(onPressed: () {
                  UserState.knowledgeReadCount++;
                  UserState.saveData();
                }, child: const Text("已读")),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------- 碳足迹计算器 ----------
class CarbonCalculatorPage extends StatefulWidget {
  const CarbonCalculatorPage({super.key});
  @override
  State<CarbonCalculatorPage> createState() => _CarbonCalculatorPageState();
}

class _CarbonCalculatorPageState extends State<CarbonCalculatorPage> {
  final _distanceController = TextEditingController();
  String _transport = "汽车";
  double _result = 0;
  final Map<String, double> factors = {"汽车": 0.2, "公交": 0.05, "地铁": 0.04, "步行": 0, "自行车": 0};

  void _calculate() {
    double dist = double.tryParse(_distanceController.text) ?? 0;
    setState(() => _result = dist * (factors[_transport] ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("碳足迹计算器")),
      body: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
        DropdownButtonFormField(value: _transport, items: factors.keys.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => _transport = v!)),
        TextField(controller: _distanceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "距离（公里）")),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: _calculate, child: const Text("计算")),
        if (_result > 0) Text("碳排放: ${_result.toStringAsFixed(2)} kg CO₂"),
      ])),
    );
  }
}

// ---------- 消息 ----------
class MessagePage extends StatelessWidget {
  const MessagePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("消息通知")),
      body: ListView.builder(padding: const EdgeInsets.all(16), itemCount: UserState.messages.length, itemBuilder: (_, i) => ListTile(title: Text(UserState.messages[i]["title"]), subtitle: Text(UserState.messages[i]["content"]))),
    );
  }
}

// ---------- 成就 ----------
class AchievementPage extends StatelessWidget {
  const AchievementPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("我的成就")),
      body: GridView.builder(padding: const EdgeInsets.all(16), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3), itemCount: UserState.allAchievements.length, itemBuilder: (_, i) {
        final ach = UserState.allAchievements[i];
        return Card(color: ach["unlocked"] ? Colors.green.shade50 : Colors.grey.shade100, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(ach["icon"], color: ach["unlocked"] ? Colors.green : Colors.grey), Text(ach["title"], textAlign: TextAlign.center)]));
      }),
    );
  }
}

// ---------- 减碳记录 ----------
class CarbonRecordPage extends StatelessWidget {
  const CarbonRecordPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("减碳记录")),
      body: ListView.builder(padding: const EdgeInsets.all(16), itemCount: UserState.carbonRecords.length, itemBuilder: (_, i) => ListTile(title: Text(UserState.carbonRecords[i]["type"]), subtitle: Text(UserState.carbonRecords[i]["desc"]))),
    );
  }
}

// ---------- 辅助组件 ----------
class EnergyDetailItem extends StatelessWidget {
  final String title;
  final String value;
  final String time;
  const EnergyDetailItem({super.key, required this.title, required this.value, required this.time});
  @override
  Widget build(BuildContext context) => ListTile(title: Text(title), subtitle: Text(time), trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)));
}
