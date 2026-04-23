import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
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
// 全局用户状态管理
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
    {
      "title": "欢迎来到碳碳",
      "content": "开启你的低碳生活之旅吧！",
      "time": "今天 00:00",
      "read": false
    },
    {
      "title": "成就解锁",
      "content": "你解锁了「步行达人」成就",
      "time": "昨天 19:20",
      "read": true
    },
  ];

  static List<Map<String, dynamic>> dailyTasks = [
    {"id": "walk", "title": "步行满8000步", "reward": 40, "finished": false},
    {"id": "upload", "title": "上传1次减碳行为", "reward": 30, "finished": true},
    {"id": "read", "title": "阅读1篇环保知识", "reward": 10, "finished": true},
    {"id": "calc", "title": "使用碳足迹计算器", "reward": 15, "finished": false},
    {"id": "sign", "title": "每日签到", "reward": 10, "finished": false},
  ];

  static List<Map<String, dynamic>> allAchievements = [
    {
      "id": "start",
      "title": "起步者",
      "desc": "首次获得能量",
      "icon": Icons.flag,
      "unlocked": true
    },
    {
      "id": "walk",
      "title": "步行达人",
      "desc": "单日步数超 10000",
      "icon": Icons.directions_walk,
      "unlocked": true
    },
    {
      "id": "upload10",
      "title": "环保先锋",
      "desc": "上传 10 次减碳行为",
      "icon": Icons.upload_file,
      "unlocked": false
    },
    {
      "id": "country3",
      "title": "环球旅行者",
      "desc": "解锁 3 个国家",
      "icon": Icons.public,
      "unlocked": false
    },
    {
      "id": "energy5000",
      "title": "零碳大师",
      "desc": "总能量超 5000",
      "icon": Icons.emoji_events,
      "unlocked": false
    },
    {
      "id": "read10",
      "title": "知识达人",
      "desc": "阅读 10 篇环保知识",
      "icon": Icons.menu_book,
      "unlocked": false
    },
    {
      "id": "friend5",
      "title": "社交达人",
      "desc": "添加5位好友",
      "icon": Icons.people,
      "unlocked": false
    },
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
      images: [
        "https://picsum.photos/400/400?random=202",
        "https://picsum.photos/400/400?random=203"
      ],
      time: "昨天",
      likes: 28,
      comments: [],
      isLiked: true,
    ),
  ];

  static Set<String> registeredUsers = {"环保小卫士", "低碳同学A", "环保同学B", "绿色使者"};

  static List<Map<String, dynamic>> mallGoods = [
    {
      "id": "badge1",
      "title": "环保先锋徽章",
      "price": 500,
      "type": "badge",
      "bought": false,
      "imageUrl": "https://cdn-icons-png.flaticon.com/512/2917/2917995.png"
    },
    {
      "id": "badge2",
      "title": "零碳大师徽章",
      "price": 1000,
      "type": "badge",
      "bought": false,
      "imageUrl": "https://cdn-icons-png.flaticon.com/512/2917/2917632.png"
    },
    {
      "id": "bag",
      "title": "环保帆布袋",
      "price": 2000,
      "type": "goods",
      "bought": false,
      "imageUrl": "https://cdn-icons-png.flaticon.com/512/3081/3081559.png"
    },
    {
      "id": "cup",
      "title": "不锈钢保温杯",
      "price": 3000,
      "type": "goods",
      "bought": false,
      "imageUrl": "https://cdn-icons-png.flaticon.com/512/3081/3081892.png"
    },
    {
      "id": "tshirt",
      "title": "有机棉T恤",
      "price": 3500,
      "type": "goods",
      "bought": false,
      "imageUrl": "https://cdn-icons-png.flaticon.com/512/3081/3081987.png"
    },
    {
      "id": "notebook",
      "title": "种子纸笔记本",
      "price": 800,
      "type": "goods",
      "bought": false,
      "imageUrl": "https://cdn-icons-png.flaticon.com/512/2997/2997924.png"
    },
    {
      "id": "straw",
      "title": "不锈钢吸管套装",
      "price": 600,
      "type": "goods",
      "bought": false,
      "imageUrl": "https://cdn-icons-png.flaticon.com/512/3135/3135715.png"
    },
    {
      "id": "bottle",
      "title": "折叠水杯",
      "price": 1200,
      "type": "goods",
      "bought": false,
      "imageUrl": "https://cdn-icons-png.flaticon.com/512/3081/3081861.png"
    },
    {
      "id": "bag2",
      "title": "蜂蜡保鲜布",
      "price": 400,
      "type": "goods",
      "bought": false,
      "imageUrl": "https://cdn-icons-png.flaticon.com/512/2933/2933116.png"
    },
  ];

  static int spriteLevel = 8;
  static int spriteExp = 390;
  static int spriteMaxExp = 700;
  static String spriteName = "小火人";
  static List<String> ownedDecorations = [];
  static String currentSpriteImage = "assets/icon/app_icon.png";

  static List<Map<String, dynamic>> knowledgeList = [
    {
      "title": "什么是碳足迹？",
      "content": "碳足迹是指企业机构、活动、产品或个人通过交通运输、食品生产和消费以及各类生产过程等引起的温室气体排放的集合。",
      "icon": Icons.eco
    },
    {
      "title": "为什么要垃圾分类？",
      "content": "垃圾分类可以减少占地，减少环境污染，变废为宝。每回收1吨废纸可造好纸850公斤，节省木材300公斤。",
      "icon": Icons.recycling
    },
    {
      "title": "如何节约用电？",
      "content": "使用节能灯泡，随手关灯，空调温度设置在26度，电器不用时拔掉插头，这些都能有效减少碳排放。",
      "icon": Icons.lightbulb
    },
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
      friends =
          friendList.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
    }
  }

  static void checkGlobalAchievements({void Function()? onUnlocked}) {
    bool changed = false;
    if (totalEnergy >= 5000 && !finishedAchievements.contains("零碳大师")) {
      finishedAchievements.add("零碳大师");
      allAchievements.firstWhere((e) => e["id"] == "energy5000")["unlocked"] =
          true;
      changed = true;
    }
    if (friends.length >= 5 && !finishedAchievements.contains("社交达人")) {
      finishedAchievements.add("社交达人");
      allAchievements.firstWhere((e) => e["id"] == "friend5")["unlocked"] =
          true;
      changed = true;
    }
    if (changed) {
      saveData();
      onUnlocked?.call();
    }
  }
}

class Moment {
  final String user;
  final String avatar;
  final String content;
  final List<String> images;
  final String? video;
  final String time;
  int likes;
  List<Comment> comments;
  bool isLiked;
  Moment({
    required this.user,
    required this.avatar,
    required this.content,
    this.images = const [],
    this.video,
    required this.time,
    required this.likes,
    required this.comments,
    required this.isLiked,
  });
}

class Comment {
  final String user;
  final String content;
  Comment({required this.user, required this.content});
}

// ------------------------------
// Main 入口
// ------------------------------
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
        scaffoldBackgroundColor: UserState.isDarkMode
            ? const Color(0xFF121212)
            : const Color(0xFFF9FFF6),
        fontFamily: globalFontFamily,
        brightness: UserState.isDarkMode ? Brightness.dark : Brightness.light,
        useMaterial3: true,
      ),
      home: UserState.isLogin ? const MainPage() : const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ------------------------------
// 登录页
// ------------------------------
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
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("请填写用户名和密码")));
      return;
    }
    if (_isRegister) {
      if (UserState.registeredUsers.contains(_nameController.text)) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("用户名已存在")));
        return;
      }
      UserState.userName = _nameController.text;
      UserState.userPassword = _pwdController.text;
      UserState.isLogin = true;
      UserState.registeredUsers.add(_nameController.text);
      await UserState.saveData();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (c) => const MainPage()));
    } else {
      if (_nameController.text == UserState.userName &&
          _pwdController.text == UserState.userPassword) {
        UserState.isLogin = true;
        await UserState.saveData();
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (c) => const MainPage()));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("用户名或密码错误")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 80),
            const Text("🌱 碳碳",
                style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.green)),
            const SizedBox(height: 50),
            TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: "用户名", border: OutlineInputBorder())),
            const SizedBox(height: 20),
            TextField(
                controller: _pwdController,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: "密码", border: OutlineInputBorder())),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _doLogin,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(18),
                    backgroundColor: Colors.green),
                child: Text(_isRegister ? "注册" : "登录",
                    style: const TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _isRegister = !_isRegister),
              child: Text(_isRegister ? "已有账号？去登录" : "没有账号？去注册"),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------
// 主页面 + 悬浮球
// ------------------------------
class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  late final List<Widget> _pages;
  final StepService _stepService = StepService();

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
    await _stepService.requestPermission();
    _stepService.startListening();
    _stepService.stepStream.listen((steps) {
      setState(() {
        UserState.todayStep = steps;
      });
    });
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
                  double newX = details.offset.dx
                      .clamp(0, MediaQuery.of(context).size.width - 60);
                  double newY = details.offset.dy
                      .clamp(0, MediaQuery.of(context).size.height - 100);
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
                  onClose: () => setState(() => _showChat = false)),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "首页"),
          BottomNavigationBarItem(icon: Icon(Icons.bolt), label: "能量"),
          BottomNavigationBarItem(icon: Icon(Icons.upload_file), label: "上传"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "好友"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "我的"),
        ],
      ),
    );
  }

  Widget _buildBall() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)
        ],
        image: const DecorationImage(
          image: AssetImage('assets/icon/app_icon.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// ------------------------------
// 碳碳助手聊天对话框
// ------------------------------
class CarbonChatDialog extends StatefulWidget {
  final VoidCallback onClose;
  const CarbonChatDialog({super.key, required this.onClose});
  @override
  State<CarbonChatDialog> createState() => _CarbonChatDialogState();
}

class _CarbonChatDialogState extends State<CarbonChatDialog> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final AiChatService _aiService = AiChatService();
  bool _isLoading = false;

  final List<String> _suggestedQuestions = ["如何省电？", "垃圾分类怎么做？", "什么是碳足迹？"];

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
    apiMessages.add({"role": "system", "content": "你是一个名叫“碳碳”的可爱环保助手。"});
    try {
      final stream = _aiService.sendMessage(apiMessages);
      String fullResponse = "";
      await for (final chunk in stream) {
        fullResponse += chunk;
        setState(() => _messages.last["content"] = fullResponse);
        _scrollToBottom();
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Container(
        width: 320,
        height: 500,
        decoration: BoxDecoration(
          color: UserState.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Text('🌱', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  const Text('碳碳小助手',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  const Spacer(),
                  IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: widget.onClose),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg["role"] == "user";
                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUser
                            ? Colors.green.shade100
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: msg["content"]!.isEmpty
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator())
                          : Text(msg["content"]!),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                          hintText: '输入问题...', border: OutlineInputBorder()),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.green),
                    onPressed: () => _sendMessage(_controller.text),
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

// ------------------------------
// 首页
// ------------------------------
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
    int finishTaskCount =
        UserState.dailyTasks.where((e) => e["finished"]).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.green,
                    child: Icon(Icons.person)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("你好，${UserState.userName}",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(UserState.userSign,
                        style:
                            TextStyle(fontSize: 13, color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none, size: 28),
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (c) => const MessagePage())),
                ),
                if (unreadCount > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                          color: Colors.red, shape: BoxShape.circle),
                      child: Center(
                          child: Text("$unreadCount",
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 10))),
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 26),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient:
                const LinearGradient(colors: [Colors.green, Colors.lightBlue]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(children: [
                    Icon(Icons.bolt, color: Colors.white),
                    Text("总能量", style: TextStyle(color: Colors.white))
                  ]),
                  Text(
                      "🌍 累计减碳 ${(UserState.totalCarbonReduce / 1000).toStringAsFixed(1)}kg",
                      style: const TextStyle(color: Colors.white)),
                ],
              ),
              Text("${UserState.totalEnergy}",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Row(children: [
                Icon(Icons.directions_walk, color: Colors.white),
                Text("今日步数", style: TextStyle(color: Colors.white))
              ]),
              Text("${UserState.todayStep}",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold)),
              Text(
                  "目标：10000 步 | 已兑换 ${(UserState.todayStep ~/ 100).toInt()} 能量",
                  style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 18),
              LinearProgressIndicator(
                  value: UserState.todayStep / 10000,
                  backgroundColor: Colors.white24,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.white)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            _buildQuickBtn(context, Icons.calculate, "碳足迹\n计算器",
                const CarbonCalculatorPage()),
            _buildQuickBtn(
                context, Icons.menu_book, "环保\n知识", const KnowledgePage()),
            _buildQuickBtn(
                context, Icons.emoji_events, "每日\n任务", const TaskPage()),
            _buildQuickBtn(
                context, Icons.shopping_bag, "环保\n商城", const MallPage()),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickBtn(
      BuildContext context, IconData icon, String title, Widget page) {
    return Expanded(
      child: InkWell(
        onTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: (c) => page)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4)
              ]),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Colors.green),
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------
// 能量页
// ------------------------------
class EnergyPage extends StatelessWidget {
  const EnergyPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("⚡ 能量中心"), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 20),
          const Center(
              child: Text("当前总能量",
                  style: TextStyle(fontSize: 20, color: Colors.grey))),
          Center(
              child: Text("${UserState.totalEnergy} ⚡",
                  style: const TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      color: Colors.green))),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: UserState.isDarkMode
                    ? const Color(0xFF2A2A2A)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4)
                ]),
            child: Column(
              children: [
                const Text("本周碳排放统计",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const days = ['一', '二', '三', '四', '五', '六', '日'];
                              return Text(days[value.toInt()],
                                  style: const TextStyle(fontSize: 12));
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 3.2),
                            FlSpot(1, 2.8),
                            FlSpot(2, 4.1),
                            FlSpot(3, 2.5),
                            FlSpot(4, 3.6),
                            FlSpot(5, 1.8),
                            FlSpot(6, 2.2)
                          ],
                          isCurved: true,
                          color: Colors.green,
                          barWidth: 3,
                          belowBarData: BarAreaData(
                              show: true, color: Colors.green.withOpacity(0.2)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Text("今日能量明细",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          EnergyDetailItem(
            title: "步行 ${UserState.todayStep} 步",
            value: "+${(UserState.todayStep ~/ 100).toInt()}",
            time: "今天",
          ),
          const EnergyDetailItem(title: "上传减碳行为", value: "+40", time: "12:10"),
          const EnergyDetailItem(title: "完成每日任务", value: "+20", time: "18:25"),
        ],
      ),
    );
  }
}

// ------------------------------
// 上传页（含校验）
// ------------------------------
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
    {
      "icon": Icons.directions_walk,
      "title": "绿色出行",
      "energy": 20,
      "carbon": 200
    },
    {"icon": Icons.restaurant, "title": "低碳饮食", "energy": 30, "carbon": 350},
    {"icon": Icons.recycling, "title": "垃圾分类", "energy": 25, "carbon": 250},
    {"icon": Icons.lightbulb, "title": "节约能源", "energy": 15, "carbon": 150},
    {"icon": Icons.shopping_bag, "title": "绿色消费", "energy": 35, "carbon": 400},
    {
      "icon": Icons.volunteer_activism,
      "title": "植树造林",
      "energy": 100,
      "carbon": 1000
    },
  ];

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(
          () => _selectedImages = images.map((e) => File(e.path)).toList());
    }
  }

  void _doUpload() async {
    if (_descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("请填写行为描述")));
      return;
    }
    final typeTitle = types[_selectedType]["title"];
    final validation =
        UploadValidator.validate(typeTitle, _descController.text);
    if (!validation.valid) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(validation.message!)));
      return;
    }

    List<String> savedImagePaths = [];
    for (var img in _selectedImages) {
      final directory = await getApplicationDocumentsDirectory();
      final newPath =
          '${directory.path}/carbon_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final saved = await img.copy(newPath);
      savedImagePaths.add(saved.path);
    }

    setState(() {
      UserState.totalEnergy += _getEnergy;
      UserState.todayEnergyGet += _getEnergy;
      UserState.totalCarbonReduce += _carbonReduce;
      UserState.carbonRecords.insert(0, {
        "type": typeTitle,
        "desc": _descController.text.trim(),
        "energy": _getEnergy,
        "carbon": _carbonReduce,
        "images": savedImagePaths,
        "time":
            "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day} ${DateTime.now().hour}:${DateTime.now().minute}",
      });
      UserState.dailyTasks.firstWhere((e) => e["id"] == "upload")["finished"] =
          true;
    });

    await UserState.saveData();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("上传成功！获得 $_getEnergy 能量")));
    _descController.clear();
    setState(() => _selectedImages.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("📤 上传减碳行为"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("选择行为类型",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 10,
              children: List.generate(types.length, (index) {
                return ChoiceChip(
                  label: Text(types[index]["title"]),
                  selected: _selectedType == index,
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = index;
                      _getEnergy = types[index]["energy"] as int;
                      _carbonReduce = types[index]["carbon"] as int;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 20),
            const Text("行为描述",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "请详细描述你的减碳行为...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text("上传图片（最多9张）",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: [
                ..._selectedImages.map((img) => Stack(
                      children: [
                        Image.file(img,
                            width: 100, height: 100, fit: BoxFit.cover),
                        Positioned(
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () =>
                                setState(() => _selectedImages.remove(img)),
                          ),
                        ),
                      ],
                    )),
                if (_selectedImages.length < 9)
                  InkWell(
                    onTap: _pickImages,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.add_photo_alternate, size: 40),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _doUpload,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(18),
                    backgroundColor: Colors.green),
                child: const Text("确认上传并领取奖励",
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------
// 好友页（动态+好友+聊天）
// ------------------------------
class FriendPage extends StatefulWidget {
  const FriendPage({super.key});
  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _postController = TextEditingController();
  List<File> _postImages = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _publishMoment() async {
    if (_postController.text.trim().isEmpty && _postImages.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("请输入内容或选择图片")));
      return;
    }
    final newMoment = Moment(
      user: UserState.userName,
      avatar: UserState.userAvatar,
      content: _postController.text.trim(),
      images: _postImages.map((e) => e.path).toList(),
      time: "刚刚",
      likes: 0,
      comments: [],
      isLiked: false,
    );
    setState(() => UserState.moments.insert(0, newMoment));
    _postController.clear();
    _postImages.clear();
    Navigator.pop(context);
  }

  void _showPublishDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _postController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      hintText: "分享你的减碳时刻...", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    ..._postImages.map((img) => Stack(
                          children: [
                            Image.file(img,
                                width: 80, height: 80, fit: BoxFit.cover),
                            Positioned(
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.close, size: 20),
                                onPressed: () =>
                                    setState(() => _postImages.remove(img)),
                              ),
                            ),
                          ],
                        )),
                    if (_postImages.length < 9)
                      IconButton(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final images = await picker.pickMultiImage();
                          setState(() => _postImages
                              .addAll(images.map((e) => File(e.path))));
                        },
                        icon: const Icon(Icons.add_photo_alternate),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _publishMoment,
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48)),
                  child: const Text("发布"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMomentsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: UserState.moments.length,
      itemBuilder: (context, index) {
        final moment = UserState.moments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: moment.avatar.isNotEmpty
                          ? FileImage(File(moment.avatar))
                          : null,
                      child: moment.avatar.isEmpty
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(moment.user,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text(moment.time,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                if (moment.content.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(moment.content),
                ],
                if (moment.images.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: moment.images.length == 1 ? 1 : 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                      childAspectRatio: 1,
                    ),
                    itemCount: moment.images.length,
                    itemBuilder: (context, imgIndex) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(File(moment.images[imgIndex]),
                            fit: BoxFit.cover),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                          moment.isLiked
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: moment.isLiked ? Colors.red : null),
                      onPressed: () {
                        setState(() {
                          moment.isLiked = !moment.isLiked;
                          moment.likes += moment.isLiked ? 1 : -1;
                        });
                      },
                    ),
                    Text('${moment.likes}'),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.comment),
                      onPressed: () => _showCommentsDialog(moment),
                    ),
                    Text('${moment.comments.length}'),
                    const Spacer(),
                    IconButton(
                        icon: const Icon(Icons.bookmark_border),
                        onPressed: () {}),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCommentsDialog(Moment moment) {
    final TextEditingController commentController = TextEditingController();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: moment.comments.length,
                itemBuilder: (context, index) {
                  final comment = moment.comments[index];
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(comment.user),
                    subtitle: Text(comment.content),
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: const InputDecoration(hintText: "添加评论..."),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (commentController.text.isNotEmpty) {
                      setState(() => moment.comments.add(Comment(
                          user: UserState.userName,
                          content: commentController.text)));
                      commentController.clear();
                      Navigator.pop(ctx);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: UserState.friends.length,
      itemBuilder: (context, index) {
        final friend = UserState.friends[index];
        return ListTile(
          leading: CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: Text(friend["name"][0])),
          title: Text(friend["name"]),
          subtitle: Text("能量值: ${friend["energy"]} ⚡"),
          trailing: IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () => _openChat(friend["name"]),
          ),
        );
      },
    );
  }

  void _openChat(String friendName) {
    Navigator.push(context,
        MaterialPageRoute(builder: (c) => ChatPage(friendName: friendName)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("好友圈"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: "动态"), Tab(text: "好友")],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildMomentsList(), _buildFriendsList()],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _showPublishDialog, child: const Icon(Icons.add))
          : null,
    );
  }
}

// ------------------------------
// 聊天页面
// ------------------------------
class ChatPage extends StatefulWidget {
  final String friendName;
  const ChatPage({super.key, required this.friendName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _msgController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
        sender: "低碳同学A", content: "今天你减碳了吗？", time: "10:30", isMe: false),
  ];

  void _sendMessage() {
    if (_msgController.text.trim().isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(
        sender: UserState.userName,
        content: _msgController.text.trim(),
        time: "${DateTime.now().hour}:${DateTime.now().minute}",
        isMe: true,
      ));
    });
    _msgController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.friendName)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment:
                      msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: msg.isMe
                          ? Colors.green.shade100
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!msg.isMe)
                          Text(msg.sender,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12)),
                        Text(msg.content),
                        Text(msg.time,
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: const InputDecoration(
                        hintText: "输入消息...", border: OutlineInputBorder()),
                  ),
                ),
                IconButton(
                    icon: const Icon(Icons.send, color: Colors.green),
                    onPressed: _sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String sender;
  final String content;
  final String time;
  final bool isMe;
  ChatMessage(
      {required this.sender,
      required this.content,
      required this.time,
      required this.isMe});
}

// ------------------------------
// 我的页面（含精灵功能）
// ------------------------------
class MinePage extends StatefulWidget {
  const MinePage({super.key});
  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("我的"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              UserState.isDarkMode = !UserState.isDarkMode;
              UserState.saveData();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (c) => const CarbonCarbonApp()));
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                UserState.userAvatar.isNotEmpty &&
                        File(UserState.userAvatar).existsSync()
                    ? CircleAvatar(
                        radius: 50,
                        backgroundImage: FileImage(File(UserState.userAvatar)))
                    : const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.green,
                        child: Icon(Icons.person, size: 50)),
                const SizedBox(height: 12),
                Text(UserState.userName,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                Text(UserState.userSign,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn("总能量", "${UserState.totalEnergy}"),
                    _buildStatColumn("减碳",
                        "${(UserState.totalCarbonReduce / 1000).toStringAsFixed(1)}kg"),
                    _buildStatColumn(
                        "成就", "${UserState.finishedAchievements.length}"),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // 精灵卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Image.asset('assets/icon/app_icon.png',
                          width: 60, height: 60),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(UserState.spriteName,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text('Lv.${UserState.spriteLevel}',
                                    style:
                                        const TextStyle(color: Colors.green)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: UserState.spriteExp /
                                        UserState.spriteMaxExp,
                                    backgroundColor: Colors.grey.shade200,
                                  ),
                                ),
                                Text(
                                    ' ${UserState.spriteExp}/${UserState.spriteMaxExp}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSpriteAction(Icons.favorite, "互动", () {
                        setState(() {
                          UserState.spriteExp += 10;
                          UserState.totalEnergy += 5;
                          if (UserState.spriteExp >= UserState.spriteMaxExp) {
                            UserState.spriteLevel++;
                            UserState.spriteExp -= UserState.spriteMaxExp;
                            UserState.spriteMaxExp =
                                (UserState.spriteMaxExp * 1.2).toInt();
                          }
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("与精灵互动，获得5能量！")));
                      }),
                      _buildSpriteAction(Icons.checkroom, "穿搭", () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (c) => const SpriteDressUpPage()));
                      }),
                      _buildSpriteAction(Icons.card_giftcard, "图鉴", () {}),
                      _buildSpriteAction(Icons.more_horiz, "更多", () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (c) => const SpriteMorePage()));
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.emoji_events, color: Colors.amber),
            title: const Text("我的成就"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (c) => const AchievementPage())),
          ),
          ListTile(
            leading: const Icon(Icons.history, color: Colors.blue),
            title: const Text("减碳记录"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (c) => const CarbonRecordPage())),
          ),
          ListTile(
            leading: const Icon(Icons.card_giftcard, color: Colors.purple),
            title: const Text("我的徽章/商品"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (c) => const MallPage())),
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text("退出登录"),
            onTap: () {
              UserState.isLogin = false;
              UserState.saveData();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (c) => const LoginPage()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSpriteAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: Icon(icon, color: Colors.green)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green)),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}

// ------------------------------
// 精灵穿搭页面
// ------------------------------
class SpriteDressUpPage extends StatefulWidget {
  const SpriteDressUpPage({super.key});
  @override
  State<SpriteDressUpPage> createState() => _SpriteDressUpPageState();
}

class _SpriteDressUpPageState extends State<SpriteDressUpPage> {
  final List<Map<String, dynamic>> decorations = [
    {
      "name": "小草帽",
      "price": 200,
      "icon": Icons.cabin,
      "bought": false
    }, // 修复：Icons.hat 不存在，改为 Icons.cabin
    {"name": "小围巾", "price": 300, "icon": Icons.style, "bought": false},
    {"name": "太阳镜", "price": 500, "icon": Icons.sunny, "bought": false},
    {"name": "小书包", "price": 400, "icon": Icons.backpack, "bought": false},
    {"name": "小翅膀", "price": 800, "icon": Icons.air, "bought": false},
    {"name": "花环", "price": 250, "icon": Icons.park, "bought": false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("精灵穿搭")),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, childAspectRatio: 1),
        itemCount: decorations.length,
        itemBuilder: (context, index) {
          final item = decorations[index];
          return Card(
            child: InkWell(
              onTap: () {
                if (!item["bought"]) {
                  int price = item["price"] as int; // 显式转换
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text("购买${item["name"]}"),
                      content: Text("消耗$price 能量购买？"),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text("取消")),
                        ElevatedButton(
                          onPressed: () {
                            if (UserState.totalEnergy >= price) {
                              setState(() {
                                UserState.totalEnergy -= price;
                                item["bought"] = true;
                                UserState.ownedDecorations.add(item["name"]);
                              });
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text("成功购买${item["name"]}！")));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("能量不足")));
                            }
                          },
                          child: const Text("确认"),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item["icon"],
                      size: 40,
                      color: item["bought"] ? Colors.green : Colors.grey),
                  const SizedBox(height: 8),
                  Text(item["name"]),
                  if (!item["bought"])
                    Text("${item["price"]}⚡",
                        style: const TextStyle(color: Colors.orange)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ------------------------------
// 精灵更多玩法页面
// ------------------------------
class SpriteMorePage extends StatelessWidget {
  const SpriteMorePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("更多玩法")),
      body: GridView.count(
        crossAxisCount: 3,
        padding: const EdgeInsets.all(16),
        children: [
          _buildMoreItem(Icons.style, "精灵卡", () {}),
          _buildMoreItem(Icons.work, "打工", () {
            UserState.totalEnergy += 50;
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text("打工完成！获得50能量")));
          }),
          _buildMoreItem(Icons.chat, "AI聊天", () {}),
          _buildMoreItem(Icons.emoji_emotions, "表情包", () {}),
          _buildMoreItem(Icons.leaderboard, "火星排行", () {}),
        ],
      ),
    );
  }

  Widget _buildMoreItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: Icon(icon, color: Colors.green)),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
}

// ------------------------------
// 环保商城页面
// ------------------------------
class MallPage extends StatelessWidget {
  const MallPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("环保商城")),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemCount: UserState.mallGoods.length,
        itemBuilder: (context, index) {
          final goods = UserState.mallGoods[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Expanded(
                    child: CachedNetworkImage(
                      imageUrl: goods["imageUrl"],
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.image_not_supported),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(goods["title"],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text("${goods["price"]} ⚡",
                      style: const TextStyle(color: Colors.green)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: goods["bought"]
                        ? null
                        : () {
                            int price = goods["price"] as int; // 显式转换
                            if (UserState.totalEnergy >= price) {
                              goods["bought"] = true;
                              UserState.totalEnergy -= price;
                              UserState.saveData();
                              (context as Element).markNeedsBuild();
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text("兑换成功！获得${goods["title"]}")));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("能量不足")));
                            }
                          },
                    child: Text(goods["bought"] ? "已兑换" : "兑换"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ------------------------------
// 每日任务页面
// ------------------------------
class TaskPage extends StatelessWidget {
  const TaskPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("每日任务")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: UserState.dailyTasks.length,
        itemBuilder: (context, index) {
          final task = UserState.dailyTasks[index];
          return TaskCard(
              task: task,
              onRefresh: () => (context as Element).markNeedsBuild());
        },
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
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: task["finished"] ? Colors.green : Colors.grey[300],
          child: Icon(task["finished"] ? Icons.check : Icons.timelapse,
              color: Colors.white),
        ),
        title: Text(task["title"]),
        subtitle: Text("奖励 ${task["reward"]} 能量"),
        trailing: task["finished"]
            ? null
            : ElevatedButton(
                onPressed: () {
                  if (task["id"] == "walk") {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("请通过步行自动完成")));
                    return;
                  }
                  task["finished"] = true;
                  UserState.totalEnergy += (task["reward"] as int);
                  UserState.todayEnergyGet += (task["reward"] as int);
                  UserState.saveData();
                  onRefresh();
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("完成任务！获得${task["reward"]}能量")));
                },
                child: const Text("领取"),
              ),
      ),
    );
  }
}

// ------------------------------
// 环保知识页面
// ------------------------------
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
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              leading: Icon(item["icon"], color: Colors.green),
              title: Text(item["title"]),
              children: [
                Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(item["content"])),
                TextButton(
                  onPressed: () {
                    var task = UserState.dailyTasks
                        .firstWhere((e) => e["id"] == "read");
                    if (!task["finished"]) {
                      task["finished"] = true;
                      UserState.totalEnergy += (task["reward"] as int);
                      UserState.todayEnergyGet += (task["reward"] as int);
                    }
                    UserState.knowledgeReadCount++;
                    UserState.saveData();
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("阅读完成！获得${task["reward"]}能量")));
                  },
                  child: const Text("标记为已读 (获得能量)"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ------------------------------
// 碳足迹计算器页面
// ------------------------------
class CarbonCalculatorPage extends StatefulWidget {
  const CarbonCalculatorPage({super.key});
  @override
  State<CarbonCalculatorPage> createState() => _CarbonCalculatorPageState();
}

class _CarbonCalculatorPageState extends State<CarbonCalculatorPage> {
  int _selectedTab = 0;
  final TextEditingController _distanceController = TextEditingController();
  String _transportMode = "汽车";
  double _result = 0.0;
  int _reward = 0;

  final Map<String, double> transportFactors = {
    "汽车": 0.2,
    "公交": 0.05,
    "地铁": 0.04,
    "步行": 0.0,
    "自行车": 0.0,
  };

  void _calculate() {
    double distance = double.tryParse(_distanceController.text) ?? 0;
    double factor = transportFactors[_transportMode] ?? 0.2;
    setState(() {
      _result = distance * factor;
      _reward = (_result * 10).toInt();
    });
  }

  void _claimReward() {
    setState(() {
      UserState.totalEnergy += _reward;
      UserState.totalCarbonReduce += _result.toInt();
      var task = UserState.dailyTasks.firstWhere((e) => e["id"] == "calc");
      if (!task["finished"]) {
        task["finished"] = true;
        UserState.totalEnergy += (task["reward"] as int);
      }
      _result = 0;
      _reward = 0;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("领取成功！获得 $_reward 能量")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("碳足迹计算器")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _transportMode,
              items: transportFactors.keys
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _transportMode = v!),
              decoration: const InputDecoration(labelText: "交通方式"),
            ),
            TextField(
                controller: _distanceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "距离（公里）")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _calculate, child: const Text("计算")),
            if (_result > 0) ...[
              const SizedBox(height: 20),
              Text("碳排放: ${_result.toStringAsFixed(2)} kg CO₂",
                  style: const TextStyle(fontSize: 18)),
              Text("可获得: $_reward ⚡"),
              ElevatedButton(
                  onPressed: _claimReward, child: const Text("领取奖励")),
            ],
          ],
        ),
      ),
    );
  }
}

// ------------------------------
// 消息通知页
// ------------------------------
class MessagePage extends StatelessWidget {
  const MessagePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("消息通知")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: UserState.messages.length,
        itemBuilder: (context, index) {
          final msg = UserState.messages[index];
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.notifications)),
            title: Text(msg["title"]),
            subtitle: Text(msg["content"]),
            trailing: Text(msg["time"]),
          );
        },
      ),
    );
  }
}

// ------------------------------
// 成就页面
// ------------------------------
class AchievementPage extends StatelessWidget {
  const AchievementPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("我的成就")),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemCount: UserState.allAchievements.length,
        itemBuilder: (context, index) {
          final ach = UserState.allAchievements[index];
          return Card(
            color:
                ach["unlocked"] ? Colors.green.shade50 : Colors.grey.shade100,
            child: InkWell(
              onTap: () => showDialog(
                context: context,
                builder: (c) => AlertDialog(
                    title: Text(ach["title"]), content: Text(ach["desc"])),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(ach["icon"],
                      color: ach["unlocked"] ? Colors.green : Colors.grey),
                  Text(ach["title"], textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ------------------------------
// 减碳记录页面
// ------------------------------
class CarbonRecordPage extends StatelessWidget {
  const CarbonRecordPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("减碳记录")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: UserState.carbonRecords.length,
        itemBuilder: (context, index) {
          final record = UserState.carbonRecords[index];
          return Card(
            child: ListTile(
              title: Text(record["type"] ?? "未知"),
              subtitle: Text(record["desc"] ?? ""),
              trailing: Text("+${record["energy"]}⚡"),
            ),
          );
        },
      ),
    );
  }
}

// ------------------------------
// 辅助组件
// ------------------------------
class EnergyDetailItem extends StatelessWidget {
  final String title;
  final String value;
  final String time;
  final bool isOut;
  const EnergyDetailItem(
      {super.key,
      required this.title,
      required this.value,
      required this.time,
      this.isOut = false});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(isOut ? Icons.arrow_downward : Icons.arrow_upward,
          color: isOut ? Colors.red : Colors.green),
      title: Text(title),
      subtitle: Text(time),
      trailing: Text(value,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isOut ? Colors.red : Colors.green)),
    );
  }
}

class UseItem extends StatelessWidget {
  final String text;
  const UseItem({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
