import 'package:flutter/material.dart';
import 'package:flutter_privatealbum/about_us.dart';
import 'about_qa.dart';
import 'package:go_router/go_router.dart';

void main() => runApp(const MyApp());

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const MyHomePage(title: "首页");
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'about_qa',
          name: 'about_qa',
          builder: (BuildContext context, GoRouterState state) {
            return const AboutQAPage(title: "常见问题");
          },
        ),
        GoRoute(
          path: 'about_us',
          name: 'about_us',
          builder: (BuildContext context, GoRouterState state) {
            return const AboutUsPage(title: "关于我们");
          },
        ),
      ],
    ),
  ],
  // 添加错误处理
  // errorBuilder: (context, state) => const ErrorPage(),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(primaryColor: Colors.blue),
      routerConfig: _router,
    );
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
