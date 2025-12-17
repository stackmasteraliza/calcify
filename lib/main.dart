import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calcify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'SF Pro Display', useMaterial3: true),
      home: const SplashScreen(),
    );
  }
}

// Splash Screen with Logo
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _pulseController;
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Text animation controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Pulse animation controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Logo scale animation
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    // Logo rotation animation
    _logoRotation = Tween<double>(begin: -0.5, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    // Text opacity animation
    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    // Text slide animation
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    // Pulse animation
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start animations
    _logoController.forward().then((_) {
      _textController.forward();
      _pulseController.repeat(reverse: true);
    });

    // Navigate to calculator after delay
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const CalculatorScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, 0.1),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                      child: child,
                    ),
                  );
                },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f0f23)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Logo
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScale.value * _pulseAnimation.value,
                        child: Transform.rotate(
                          angle: _logoRotation.value,
                          child: const AppLogo(),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 40),
              // Animated App Name
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _textOpacity.value,
                    child: SlideTransition(
                      position: _textSlide,
                      child: Column(
                        children: [
                          // App Name with Gradient
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                Color(0xFF64ffda),
                                Color(0xFF48cae4),
                                Color(0xFFa855f7),
                              ],
                            ).createShader(bounds),
                            child: const Text(
                              'Calcify',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Tagline
                          Text(
                            'Smart. Beautiful. Powerful.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              color: Colors.grey[500],
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 80),
              // Loading indicator
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _textOpacity.value,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color(0xFF64ffda).withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom App Logo Widget
class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366f1), Color(0xFF4f46e5), Color(0xFF7c3aed)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366f1).withValues(alpha: 0.4),
            blurRadius: 30,
            spreadRadius: 5,
          ),
          const BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
        border: Border.all(color: const Color(0x33FFFFFF), width: 2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background pattern
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(33),
              child: CustomPaint(painter: LogoPatternPainter()),
            ),
          ),
          // Main icon content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Calculator icon representation
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMiniButton(const Color(0xFFf97316)),
                  const SizedBox(width: 8),
                  _buildMiniButton(const Color(0xFF64ffda)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMiniButton(const Color(0xFFf472b6)),
                  const SizedBox(width: 8),
                  _buildMiniButton(Colors.white),
                ],
              ),
              const SizedBox(height: 12),
              // "=" symbol
              Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniButton(Color color) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

// Custom painter for logo background pattern
class LogoPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x15FFFFFF)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw grid pattern
    for (int i = 0; i < 8; i++) {
      canvas.drawLine(
        Offset(size.width * i / 7, 0),
        Offset(size.width * i / 7, size.height),
        paint,
      );
      canvas.drawLine(
        Offset(0, size.height * i / 7),
        Offset(size.width, size.height * i / 7),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _expression = '';
  double? _firstOperand;
  String? _operator;
  bool _shouldResetDisplay = false;
  bool _isScientificMode = false;
  bool _isRadianMode = true;

  void _onDigitPressed(String digit) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_shouldResetDisplay) {
        _display = digit;
        _shouldResetDisplay = false;
      } else {
        if (_display == '0' && digit != '.') {
          _display = digit;
        } else if (digit == '.' && _display.contains('.')) {
          return;
        } else {
          _display += digit;
        }
      }
    });
  }

  void _onOperatorPressed(String operator) {
    HapticFeedback.mediumImpact();
    setState(() {
      if (_firstOperand != null && _operator != null && !_shouldResetDisplay) {
        _calculateResult();
      }
      _firstOperand = double.tryParse(_display);
      _operator = operator;
      _expression = '$_display $operator';
      _shouldResetDisplay = true;
    });
  }

  void _calculateResult() {
    if (_firstOperand == null || _operator == null) return;

    double secondOperand = double.tryParse(_display) ?? 0;
    double result = 0;

    switch (_operator) {
      case '+':
        result = _firstOperand! + secondOperand;
        break;
      case '-':
        result = _firstOperand! - secondOperand;
        break;
      case '×':
        result = _firstOperand! * secondOperand;
        break;
      case '÷':
        if (secondOperand != 0) {
          result = _firstOperand! / secondOperand;
        } else {
          _display = 'Error';
          _expression = '';
          _firstOperand = null;
          _operator = null;
          return;
        }
        break;
      case '^':
        result = math.pow(_firstOperand!, secondOperand).toDouble();
        break;
    }

    setState(() {
      if (result.isInfinite || result.isNaN) {
        _display = 'Error';
      } else if (result == result.toInt()) {
        _display = result.toInt().toString();
      } else {
        _display = result
            .toStringAsFixed(8)
            .replaceAll(RegExp(r'0+$'), '')
            .replaceAll(RegExp(r'\.$'), '');
      }
      _expression = '';
      _firstOperand = null;
      _operator = null;
    });
  }

  void _onEqualsPressed() {
    HapticFeedback.heavyImpact();
    setState(() {
      _calculateResult();
      _shouldResetDisplay = true;
    });
  }

  void _onClearPressed() {
    HapticFeedback.mediumImpact();
    setState(() {
      _display = '0';
      _expression = '';
      _firstOperand = null;
      _operator = null;
      _shouldResetDisplay = false;
    });
  }

  void _onBackspacePressed() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_display.length > 1) {
        _display = _display.substring(0, _display.length - 1);
      } else {
        _display = '0';
      }
    });
  }

  void _onPlusMinusPressed() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_display != '0') {
        if (_display.startsWith('-')) {
          _display = _display.substring(1);
        } else {
          _display = '-$_display';
        }
      }
    });
  }

  void _onPercentPressed() {
    HapticFeedback.lightImpact();
    setState(() {
      double? value = double.tryParse(_display);
      if (value != null) {
        double result = value / 100;
        _display = _formatResult(result);
      }
    });
  }

  String _formatResult(double result) {
    if (result.isInfinite || result.isNaN) {
      return 'Error';
    } else if (result == result.toInt()) {
      return result.toInt().toString();
    } else {
      return result
          .toStringAsFixed(8)
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }
  }

  // Scientific functions
  void _onScientificFunction(String func) {
    HapticFeedback.lightImpact();
    double? value = double.tryParse(_display);
    if (value == null) return;

    double result;
    double angleValue = _isRadianMode ? value : value * math.pi / 180;

    switch (func) {
      case 'sin':
        result = math.sin(angleValue);
        break;
      case 'cos':
        result = math.cos(angleValue);
        break;
      case 'tan':
        result = math.tan(angleValue);
        break;
      case 'log':
        result = value > 0 ? math.log(value) / math.ln10 : double.nan;
        break;
      case 'ln':
        result = value > 0 ? math.log(value) : double.nan;
        break;
      case '√':
        result = value >= 0 ? math.sqrt(value) : double.nan;
        break;
      case 'x²':
        result = value * value;
        break;
      case 'x³':
        result = value * value * value;
        break;
      case '1/x':
        result = value != 0 ? 1 / value : double.nan;
        break;
      case '|x|':
        result = value.abs();
        break;
      case 'π':
        result = math.pi;
        break;
      case 'e':
        result = math.e;
        break;
      case 'e^x':
        result = math.exp(value);
        break;
      case '10^x':
        result = math.pow(10, value).toDouble();
        break;
      case 'x!':
        result = _factorial(value.toInt()).toDouble();
        break;
      default:
        return;
    }

    setState(() {
      _display = _formatResult(result);
      _shouldResetDisplay = true;
    });
  }

  int _factorial(int n) {
    if (n < 0) return 0;
    if (n <= 1) return 1;
    if (n > 20) return 0;
    int result = 1;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }

  void _toggleScientificMode() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isScientificMode = !_isScientificMode;
    });
  }

  void _toggleAngleMode() {
    HapticFeedback.lightImpact();
    setState(() {
      _isRadianMode = !_isRadianMode;
    });
  }

  void _openPoliciesScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PoliciesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f0f23)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(flex: 2, child: _buildDisplay()),
              if (_isScientificMode) _buildScientificButtons(),
              Expanded(
                flex: _isScientificMode ? 3 : 4,
                child: _buildButtonGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App branding
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366f1), Color(0xFF7c3aed)],
                  ),
                ),
                child: const Center(
                  child: Text(
                    '=',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF64ffda), Color(0xFFa855f7)],
                ).createShader(bounds),
                child: const Text(
                  'Calcify',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          // Controls
          Row(
            children: [
              // Scientific mode toggle
              GestureDetector(
                onTap: _toggleScientificMode,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: _isScientificMode
                        ? const LinearGradient(
                            colors: [Color(0xFFf472b6), Color(0xFFec4899)],
                          )
                        : null,
                    color: _isScientificMode ? null : const Color(0xFF2d3748),
                    border: Border.all(
                      color: const Color(0x33FFFFFF),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.science_outlined,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'SCI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isScientificMode) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _toggleAngleMode,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: const Color(0xFF2d3748),
                      border: Border.all(
                        color: const Color(0x33FFFFFF),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _isRadianMode ? 'RAD' : 'DEG',
                      style: const TextStyle(
                        color: Color(0xFF64ffda),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _openPoliciesScreen,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xFF2d3748),
                    border: Border.all(
                      color: const Color(0x33FFFFFF),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AnimatedOpacity(
            opacity: _expression.isNotEmpty ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Text(
              _expression,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w300,
                color: Color(0xFF8892b0),
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF64ffda), Color(0xFF48cae4), Color(0xFFa855f7)],
            ).createShader(bounds),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  _display,
                  key: ValueKey<String>(_display),
                  style: TextStyle(
                    fontSize: _isScientificMode ? 56 : 72,
                    fontWeight: FontWeight.w200,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScientificButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          Row(
            children: [
              _buildScientificButton('sin'),
              _buildScientificButton('cos'),
              _buildScientificButton('tan'),
              _buildScientificButton('log'),
              _buildScientificButton('ln'),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildScientificButton('√'),
              _buildScientificButton('x²'),
              _buildScientificButton('x³'),
              _buildScientificButton('^', isOperator: true),
              _buildScientificButton('1/x'),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildScientificButton('π'),
              _buildScientificButton('e'),
              _buildScientificButton('e^x'),
              _buildScientificButton('10^x'),
              _buildScientificButton('x!'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScientificButton(String text, {bool isOperator = false}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: GestureDetector(
          onTap: () {
            if (isOperator) {
              _onOperatorPressed(text);
            } else {
              _onScientificFunction(text);
            }
          },
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF374151), Color(0xFF1f2937)],
              ),
              border: Border.all(color: const Color(0x20FFFFFF), width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFf472b6),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonGrid() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                _buildButton('C', ButtonType.function),
                _buildButton('±', ButtonType.function),
                _buildButton('%', ButtonType.function),
                _buildButton('÷', ButtonType.operator),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _buildButton('7', ButtonType.number),
                _buildButton('8', ButtonType.number),
                _buildButton('9', ButtonType.number),
                _buildButton('×', ButtonType.operator),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _buildButton('4', ButtonType.number),
                _buildButton('5', ButtonType.number),
                _buildButton('6', ButtonType.number),
                _buildButton('-', ButtonType.operator),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _buildButton('1', ButtonType.number),
                _buildButton('2', ButtonType.number),
                _buildButton('3', ButtonType.number),
                _buildButton('+', ButtonType.operator),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _buildButton('⌫', ButtonType.function),
                _buildButton('0', ButtonType.number),
                _buildButton('.', ButtonType.number),
                _buildButton('=', ButtonType.equals),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, ButtonType type) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: CalculatorButton(
          text: text,
          type: type,
          onPressed: () => _handleButtonPress(text),
          isActive: _operator == text,
        ),
      ),
    );
  }

  void _handleButtonPress(String text) {
    switch (text) {
      case 'C':
        _onClearPressed();
        break;
      case '±':
        _onPlusMinusPressed();
        break;
      case '%':
        _onPercentPressed();
        break;
      case '⌫':
        _onBackspacePressed();
        break;
      case '=':
        _onEqualsPressed();
        break;
      case '+':
      case '-':
      case '×':
      case '÷':
      case '^':
        _onOperatorPressed(text);
        break;
      default:
        _onDigitPressed(text);
    }
  }
}

enum ButtonType { number, operator, function, equals }

class CalculatorButton extends StatefulWidget {
  final String text;
  final ButtonType type;
  final VoidCallback onPressed;
  final bool isActive;

  const CalculatorButton({
    super.key,
    required this.text,
    required this.type,
    required this.onPressed,
    this.isActive = false,
  });

  @override
  State<CalculatorButton> createState() => _CalculatorButtonState();
}

class _CalculatorButtonState extends State<CalculatorButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Color> _getGradientColors() {
    switch (widget.type) {
      case ButtonType.number:
        return const [Color(0xFF2d3748), Color(0xFF1a202c)];
      case ButtonType.operator:
        return const [Color(0xFF6366f1), Color(0xFF4f46e5)];
      case ButtonType.function:
        return const [Color(0xFF475569), Color(0xFF334155)];
      case ButtonType.equals:
        return const [Color(0xFFf97316), Color(0xFFea580c)];
    }
  }

  Color _getGlowColor() {
    switch (widget.type) {
      case ButtonType.number:
        return const Color(0x4D64ffda);
      case ButtonType.operator:
        return const Color(0x80818cf8);
      case ButtonType.function:
        return const Color(0x4D94a3b8);
      case ButtonType.equals:
        return const Color(0x80fb923c);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = _getGradientColors();
    final glowColor = _getGlowColor();

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.isActive
                      ? const [Color(0xFF818cf8), Color(0xFF6366f1)]
                      : gradientColors,
                ),
                boxShadow: [
                  const BoxShadow(
                    color: Color(0x4D000000),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                  BoxShadow(
                    color: glowColor.withValues(
                      alpha: glowColor.a * _glowAnimation.value,
                    ),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                  const BoxShadow(
                    color: Color(0x1AFFFFFF),
                    blurRadius: 1,
                    offset: Offset(0, 1),
                  ),
                ],
                border: Border.all(color: const Color(0x1AFFFFFF), width: 1),
              ),
              child: Center(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: widget.text == '⌫' ? 26 : 32,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    shadows: const [
                      Shadow(
                        color: Color(0x4D000000),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;

  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }
}

// Policies Screen
class PoliciesScreen extends StatelessWidget {
  const PoliciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f0f23)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xFF2d3748),
                          border: Border.all(
                            color: const Color(0x33FFFFFF),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF64ffda), Color(0xFFa855f7)],
                      ).createShader(bounds),
                      child: const Text(
                        'Policies & Info',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildPolicyCard(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        content:
                            'Calcify does not collect, store, or share any personal data. All calculations are performed locally on your device. We respect your privacy and do not track your usage.',
                        gradientColors: const [
                          Color(0xFF6366f1),
                          Color(0xFF4f46e5),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildPolicyCard(
                        icon: Icons.description_outlined,
                        title: 'Terms of Use',
                        content:
                            'By using Calcify, you agree to use it for lawful purposes only. The app is provided "as is" without warranties. We are not responsible for any errors in calculations.',
                        gradientColors: const [
                          Color(0xFFf472b6),
                          Color(0xFFec4899),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildPolicyCard(
                        icon: Icons.info_outline,
                        title: 'About Calcify',
                        content:
                            'Calcify v1.0.0\n\nSmart. Beautiful. Powerful.\n\nA modern calculator with basic and scientific modes. Features trigonometric functions, logarithms, powers, and more.\n\nBuilt with Flutter.',
                        gradientColors: const [
                          Color(0xFF10b981),
                          Color(0xFF059669),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildPolicyCard(
                        icon: Icons.calculate_outlined,
                        title: 'Scientific Features',
                        content:
                            '• Trigonometric: sin, cos, tan\n• Logarithmic: log (base 10), ln (natural)\n• Powers: x², x³, x^y, 10^x, e^x\n• Others: √, factorial, 1/x\n• Constants: π, e\n• Angle modes: Radians & Degrees',
                        gradientColors: const [
                          Color(0xFFf97316),
                          Color(0xFFea580c),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildPolicyCard(
                        icon: Icons.email_outlined,
                        title: 'Contact Us',
                        content:
                            'Have questions or feedback?\n\nEmail: support@calcify.app\n\nWe appreciate your feedback!',
                        gradientColors: const [
                          Color(0xFF8b5cf6),
                          Color(0xFF7c3aed),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Text(
                        '© 2024 Calcify. All rights reserved.',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolicyCard({
    required IconData icon,
    required String title,
    required String content,
    required List<Color> gradientColors,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF1e293b),
        border: Border.all(color: const Color(0x20FFFFFF), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(colors: gradientColors),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
