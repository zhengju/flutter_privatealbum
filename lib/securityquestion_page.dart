import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class SecurityQuestionPage extends StatefulWidget {
  final List<String>? securityQuestions;
  final String? defaultQuestion;

  const SecurityQuestionPage({
    super.key,
    this.securityQuestions,
    this.defaultQuestion,
  });

  @override
  _SecurityQuestionPageState createState() => _SecurityQuestionPageState();
}

class _SecurityQuestionPageState extends State<SecurityQuestionPage> {
  // // 创建MethodChannel
  static const MethodChannel _channel = MethodChannel(
    'ios_flutter_base_channel',
  );
  String? selectedQuestion;
  String answer = '';
  bool isExpanded = false;
  OverlayEntry? _overlayEntry;
  final GlobalKey _questionKey = GlobalKey();
  bool _isDisposed = false; // 添加销毁标志

  // 使用 widget.securityQuestions 和 widget.defaultQuestion
  List<String> get securityQuestions =>
      widget.securityQuestions ??
      [
        '您最常用的电子邮箱后缀是什么?',
        '您最喜欢的颜色是什么?',
        '您学生时代最喜欢的老师姓什么?',
        '您平时喜欢吃的水果是什么?',
        '您出生地的邮政编码是什么?',
        '您第一只宠物的名字是什么?',
      ];

  @override
  void initState() {
    super.initState();
    // 如果有默认问题，设置为选中状态
    if (widget.defaultQuestion != null) {
      selectedQuestion = widget.defaultQuestion;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // 关键：禁止键盘调整布局
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
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
        title: Text(
          '密保问题',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 密保问题选择区域
            _buildQuestionSection(),
            SizedBox(height: 24),
            // 答案输入区域
            _buildAnswerSection(),
            Spacer(),
            // 确认按钮
            _buildConfirmButton(),

            SizedBox(height: 49),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '密保问题',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12),
        GestureDetector(
          key: _questionKey,
          onTap: () {
            if (isExpanded) {
              _hideOverlay();
            } else {
              _showOverlay();
            }
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedQuestion ?? '请选择密保问题',
                    style: TextStyle(
                      color: selectedQuestion != null
                          ? Colors.white
                          : Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '答案',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            style: TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: '请输入答案',
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: InputBorder.none,
            ),
            onChanged: (value) {
              if (!_isDisposed) {
                setState(() {
                  answer = value;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: selectedQuestion != null && answer.isNotEmpty
            ? () {
                _handleConfirm();
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedQuestion != null && answer.isNotEmpty
              ? Color(0xFF007AFF)
              : Colors.grey[600],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          '确认',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showOverlay() {
    if (_isDisposed) return; // 检查是否已销毁

    // 检查 context 是否有效
    if (!mounted) return;

    setState(() {
      isExpanded = true;
    });

    // 获取问题选择框的位置
    final RenderBox? renderBox =
        _questionKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Offset position = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () {
          _hideOverlay();
        },
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // 半透明背景
              Positioned.fill(
                child: Container(color: Colors.black.withOpacity(0.3)),
              ),
              // 问题列表
              Positioned(
                left: 16,
                right: 16,
                top: position.dy + size.height + 8,
                child: _buildQuestionList(),
              ),
            ],
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _buildQuestionList() {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.4,
      ),
      decoration: BoxDecoration(
        color: Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: securityQuestions.map((question) {
            return GestureDetector(
              onTap: () {
                if (!_isDisposed && mounted) {
                  setState(() {
                    selectedQuestion = question;
                  });
                }
                _hideOverlay();
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[800]!, width: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        question,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    if (selectedQuestion == question)
                      Icon(Icons.check, color: Colors.blue, size: 20),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _hideOverlay() {
    if (_isDisposed) return; // 检查是否已销毁

    if (mounted) {
      setState(() {
        isExpanded = false;
      });
    }

    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _handleConfirm() async {
    if (_isDisposed) return; // 检查是否已销毁
    final currentContext = context;

    // 1. 异步操作开始前检查
    if (!currentContext.mounted) return;
    if (selectedQuestion != null && answer.isNotEmpty) {
      if (currentContext.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('密保问题设置成功'), backgroundColor: Colors.green),
        );
        try {
          // 调用iOS原生方法
          final result = await _channel.invokeMethod('dismiss', {
            'selectedQuestion': selectedQuestion,
            "answer": answer,
          });
          if (kDebugMode) {
            print('iOS返回结果: $result');
          }
        } catch (e) {
          debugPrint('调用iOS方法错误: $e');
          if (!currentContext.mounted) return;
          currentContext.go('/');
        }
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true; // 设置销毁标志
    _hideOverlay();
    super.dispose();
  }
}
