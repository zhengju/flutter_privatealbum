import 'package:flutter/material.dart';
import 'package:flutter_privatealbum/about_us.dart';
import 'about_qa.dart';
import 'securityquestion_page.dart';
import 'draggable_card_page.dart';
import 'sepassword_page.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'dart:async';

void main() => runApp(const MyApp());

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        // 检查是否有路由参数
        final route = state.uri.queryParameters['route'];
        print("进来检查了。。。。。");
        print(state.uri.queryParameters);
        if (route != null) {
          return const AboutUsPage(title: "关于我们");
        }
        return const MyHomePage(title: "首页");
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'about_qa',
          name: 'about_qa',
          pageBuilder: (context, state) => NoTransitionPage(
            key: ValueKey('about_qa_${DateTime.now().millisecondsSinceEpoch}'),
            child: const AboutQAPage(title: "常见问题"),
          ),
        ),
        GoRoute(
          path: 'about_us',
          name: 'about_us',
          pageBuilder: (context, state) => NoTransitionPage(
            key: ValueKey('about_qa_${DateTime.now().millisecondsSinceEpoch}'),
            child: const AboutUsPage(title: "关于我们"),
          ),
        ),
        GoRoute(
          path: 'security_page',
          name: 'security_page',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            print(extra?['defaultAnswer'] as String?);
            return SecurityQuestionPage(
              securityQuestions: extra?['securityQuestions'] as List<String>?,
              defaultQuestion: extra?['defaultQuestion'] as String?,
              defaultAnswer: extra?['defaultAnswer'] as String?,
            );
          },
        ),
        GoRoute(
          path: '/set_password',
          builder: (context, state) => SetPasswordPage(),
        ),
        GoRoute(
          path: 'draggable_card_page',
          name: 'draggable_card_page',
          pageBuilder: (context, state) => NoTransitionPage(
            key: ValueKey('about_qa_${DateTime.now().millisecondsSinceEpoch}'),
            child: DraggableCard(),
          ),
        ),
      ],
    ),
  ],
  // 添加错误处理
  // errorBuilder: (context, state) => const ErrorPage(),
);

//强制重绘，还是会闪屏上一页内容
class NoTransitionPage extends Page<void> {
  final Widget child;

  const NoTransitionPage({required this.child, super.key});

  @override
  Route<void> createRoute(BuildContext context) {
    return PageRouteBuilder<void>(
      settings: this,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  String? _pendingNavigation;
  Map<String, dynamic>? _pendingArguments;
  // // 创建MethodChannel
  static const MethodChannel _channel = MethodChannel(
    'ios_flutter_base_channel',
  );

  @override
  void initState() {
    super.initState();
    _channel.setMethodCallHandler((call) {
      var method = call.method;
      var arguments = call.arguments;
      Future.delayed(Duration(milliseconds: 100), () {
        if (mounted) {
          _handleNavigation(method, arguments);
        }
      });
      setState(() {
        _pendingNavigation = method;
        // _pendingArguments = arguments;
      });
      return Future(() {});
    });
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
    print("didChangeDependencies");
  }

  @override
  void dispose() {
    print('dispose: mounted = $mounted'); // true
    super.dispose();
    print('after dispose: mounted = $mounted'); // false
  }

  @override
  Widget build(BuildContext context) {
    print("build");
    return MaterialApp.router(
      title: 'Flutter Private Album',
      theme: ThemeData(
        primarySwatch: Colors.blue, // 使用 primarySwatch 而不是 primaryColor
        useMaterial3: true, // 添加 Material 3 支持
      ),
      routerConfig: _router,
    );
  }

  void _handleNavigation(String method, dynamic arguments) {
    switch (method) {
      case 'navigate_to_about_qa':
        _router.go("/about_qa");
        break;
      case 'navigate_to_about_us':
        _router.go("/about_us");
        break;
      case 'navigate_to_security_page':
        try {
          // final arguments = call.arguments;

          if (arguments != null) {
            print("带参数: ${arguments.toString()}");

            // 安全地获取列表参数
            final securityQuestionsRaw = arguments['securityQuestions'];
            List<String>? securityQuestions;

            if (securityQuestionsRaw is List) {
              try {
                securityQuestions = securityQuestionsRaw.cast<String>();
              } catch (e) {
                print("列表转换失败，尝试过滤: $e");
                securityQuestions = securityQuestionsRaw
                    .whereType<String>()
                    .toList();
              }
            }

            // 安全地获取字符串参数
            final defaultQuestion = arguments['defaultQuestion'] as String?;
            final defaultAnswer = arguments['defaultAnswer'] as String?;
            if (securityQuestions != null && securityQuestions.isNotEmpty) {
              _router.go(
                "/security_page",
                extra: {
                  'securityQuestions': securityQuestions,
                  'defaultQuestion': defaultQuestion ?? securityQuestions[0],
                  'defaultAnswer': defaultAnswer,
                },
              );
            } else {
              print("参数无效，使用默认页面");
              _router.go("/security_page");
            }
          } else {
            print("不带参数");
            _router.go("/security_page");
          }
        } catch (e) {
          print("处理参数时发生错误: $e");
          _router.go("/security_page");
        }
        break;
      case 'navigate_to_gallery':
        if (arguments != null && arguments['albumId'] != null) {
          context.go("/gallery/${arguments['albumId']}");
        } else {
          context.go("/gallery");
        }
        break;
      default:
        print('Unknown method: $method');
        context.go("/home");
    }
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 列表数据
  final List<Map<String, dynamic>> _menuItems = [
    {
      'title': '关于我们',
      'subtitle': '了解我们的团队和使命',
      'icon': Icons.info,
      'route': '/about_us',
    },
    {
      'title': '常见问题',
      'subtitle': '查看常见问题解答',
      'icon': Icons.help,
      'route': '/about_qa',
    },
    {
      'title': '设置',
      'subtitle': '应用设置和偏好',
      'icon': Icons.settings,
      'route': '/settings',
    },
    {
      'title': '密保页面',
      'subtitle': '设置密保',
      'icon': Icons.support,
      'route': '/security_page',
    },
    {
      'title': '可拖拽卡片',
      'subtitle': '手势练习',
      'icon': Icons.support,
      'route': '/draggable_card_page',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView.builder(
        itemCount: _menuItems.length,
        itemBuilder: (context, index) {
          final item = _menuItems[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: Icon(
                item['icon'],
                color: Theme.of(context).primaryColor,
              ),
              title: Text(
                item['title'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                item['subtitle'],
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.go(item['route']),
            ),
          );
        },
      ),
    );
  }
}
