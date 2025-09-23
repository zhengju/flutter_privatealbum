import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './res/about_qa_data.dart';
import 'package:go_router/go_router.dart';

class AboutQAPage extends StatefulWidget {
  const AboutQAPage({super.key, required this.title});
  final String title;

  @override
  State<AboutQAPage> createState() => _AboutQAPageState();
}

class _AboutQAPageState extends State<AboutQAPage> {
  // // 创建MethodChannel
  static const MethodChannel _channel = MethodChannel(
    'ios_flutter_base_channel',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.blue),
            onPressed: () async {
              final currentContext = context;

              // 1. 异步操作开始前检查
              if (!currentContext.mounted) return;

              try {
                // 2. 执行异步操作
                final result = await _channel.invokeMethod('dismiss', {
                  'url': "",
                });

                // 3. 异步操作完成后检查
                if (!currentContext.mounted) return;

                // 4. 处理成功结果
                if (kDebugMode) {
                  print('iOS返回结果: $result');
                }
              } catch (e) {
                debugPrint('调用iOS方法错误: $e');

                // 5. 错误处理前检查
                if (!currentContext.mounted) return;

                // 6. 处理错误
                currentContext.go('/');
              }
            },
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: listData.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Q: ${listData[index]["question"]}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12),
                  Text(
                    "A: ${listData[index]["answer"]}",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5, // 增加行高
                    ),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
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
