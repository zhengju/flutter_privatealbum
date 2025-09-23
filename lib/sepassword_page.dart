import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class SetPasswordPage extends StatefulWidget {
  const SetPasswordPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SetPasswordPageState createState() => _SetPasswordPageState();
}

class _SetPasswordPageState extends State<SetPasswordPage> {
  static const MethodChannel _channel = MethodChannel(
    'ios_flutter_base_channel',
  );

  String password = '';
  String confirmPassword = '';
  bool _isDisposed = false;

  // 密码输入控制器
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // 焦点控制器
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("设置密码"),
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.blue),
            onPressed: () async {
              final currentContext = context;
              if (!currentContext.mounted) return;

              try {
                final result = await _channel.invokeMethod('dismiss', {
                  'url': "",
                });

                if (!currentContext.mounted) return;

                if (kDebugMode) {
                  print('iOS返回结果: $result');
                }
              } catch (e) {
                debugPrint('调用iOS方法错误: $e');
                if (!currentContext.mounted) return;
                currentContext.pop(); // 使用 GoRouter 的 pop 方法
              }
            },
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 密码输入区域
            _buildPasswordSection(),
            SizedBox(height: 24),
            // 确认密码输入区域
            _buildConfirmPasswordSection(),
            Spacer(),
            // 确认按钮
            _buildConfirmButton(),
            SizedBox(height: 49),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '设置密码',
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
            controller: _passwordController,
            focusNode: _passwordFocus,
            style: TextStyle(color: Colors.white, fontSize: 16),
            // keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            obscureText: true,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: '请输入6位数字密码',
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: InputBorder.none,
            ),
            onChanged: (value) {
              if (!_isDisposed) {
                setState(() {
                  password = value;
                });
              }
            },
          ),
        ),
        SizedBox(height: 8),
        // 密码提示
        Text(
          '密码必须是6位数字',
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '确认密码',
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
            controller: _confirmPasswordController,
            focusNode: _confirmPasswordFocus,
            style: TextStyle(color: Colors.white, fontSize: 16),
            // keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            obscureText: true,
            textInputAction: TextInputAction.done,

            decoration: InputDecoration(
              hintText: '请再次输入密码',
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: InputBorder.none,
            ),

            onChanged: (value) {
              if (!_isDisposed) {
                setState(() {
                  confirmPassword = value;
                });
              }
            },
          ),
        ),
        SizedBox(height: 8),
        // 密码匹配提示
        if (confirmPassword.isNotEmpty && password != confirmPassword)
          Text('两次输入的密码不一致', style: TextStyle(color: Colors.red, fontSize: 12))
        else if (confirmPassword.isNotEmpty && password == confirmPassword)
          Text('密码匹配', style: TextStyle(color: Colors.green, fontSize: 12)),
      ],
    );
  }

  Widget _buildConfirmButton() {
    // 检查密码是否有效
    bool isPasswordValid =
        password.length == 6 &&
        password.isNotEmpty &&
        confirmPassword.isNotEmpty &&
        password == confirmPassword;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isPasswordValid
            ? () {
                _handleConfirm();
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPasswordValid
              ? Color(0xFF007AFF)
              : Colors.grey[600],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          '确认设置',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _handleConfirm() async {
    if (_isDisposed) return;
    final currentContext = context;

    if (!currentContext.mounted) return;

    // 验证密码
    if (!_validatePassword()) {
      _showErrorSnackBar('密码格式不正确');
      return;
    }

    if (password != confirmPassword) {
      _showErrorSnackBar('两次输入的密码不一致');
      return;
    }

    try {
      // 调用iOS原生方法设置密码
      final result = await _channel.invokeMethod('setPassword', {
        'password': password,
      });

      if (!currentContext.mounted) return;

      if (kDebugMode) {
        print('iOS返回结果: $result');
      }

      // 显示成功提示
      if (currentContext.mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(content: Text('密码设置成功'), backgroundColor: Colors.green),
        );

        // 延迟返回上一页
        Future.delayed(Duration(seconds: 1), () {
          if (currentContext.mounted) {
            currentContext.go('/');
          }
        });
      }
    } catch (e) {
      debugPrint('调用iOS方法错误: $e');
      if (!currentContext.mounted) return;

      _showErrorSnackBar('设置密码失败: $e');
    }
  }

  bool _validatePassword() {
    // 检查密码长度
    if (password.length != 6) return false;

    // 检查密码是否为空
    if (password.isEmpty) return false;

    // 检查密码是否只包含数字
    if (!RegExp(r'^\d+$').hasMatch(password)) return false;

    return true;
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }
}
