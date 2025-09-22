import 'package:flutter/material.dart';
import 'package:flutter_privatealbum/about_us.dart';
import 'about_qa.dart';
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
          // builder: (BuildContext context, GoRouterState state) {
          //   return const AboutUsPage(title: "关于我们");
          // },
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
    print("initState");
    _channel.setMethodCallHandler((call) {
      var method = call.method;
      print("setMethodCallHandler" + call.method);
      // 延迟执行路由跳转，确保路由已经初始化

      Future.delayed(Duration(milliseconds: 100), () {
        if (mounted) {
          print("delayed");
          _handleNavigation(method, _pendingArguments);
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

  void _handleNavigation(String method, Map<String, dynamic>? arguments) {
    switch (method) {
      case 'navigate_to_about_qa':
        print("navigate_to_about_qa");
        _router.go("/about_qa");
        break;
      case 'navigate_to_about_us':
        print("navigate_to_about_us");
        _router.go("/about_us");
        break;
      case 'navigate_to_profile':
        context.go("/profile");
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
      'title': '帮助',
      'subtitle': '获取帮助和支持',
      'icon': Icons.support,
      'route': '/help',
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
