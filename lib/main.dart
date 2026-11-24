import 'dart:math' as math;
import 'dart:ui';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import 'services/api_service.dart';

void main() => runApp(const MyApp());

// ====== A PERSONNALISER ======
const kNom = 'Munguankowa Zihingula Lydie';
const kTitre = 'Étudiant en informatique • Développeur mobile';
const kPhoto = 'assets/images/moi.jpg';

// ================= DESIGN TOKENS =================
class C {
  static const bg = Color(0xFF080808);
  static const blue = Color(0xFF3B82F6);
  static const violet = Color(0xFF2563EB);
  static const cyan = Color(0xFF60A5FA);
  static const pink = Color(0xFF1D4ED8);
  static const text = Color(0xFFF5F5F5);
  static const muted = Color(0xFF94A3B8);

  static const btn = LinearGradient(colors: [blue, violet]);
  static const textGrad = LinearGradient(
    colors: [Color(0xFF60A5FA), Color(0xFF3B82F6), Color(0xFF2563EB)],
  );
}

OutlineInputBorder _border(Color c, [double w = 1]) => OutlineInputBorder(
  borderRadius: BorderRadius.circular(16),
  borderSide: BorderSide(color: c, width: w),
);

Route<T> fadeRoute<T>(Widget page) => PageRouteBuilder<T>(
  transitionDuration: const Duration(milliseconds: 650),
  pageBuilder: (_, __, ___) => page,
  transitionsBuilder: (_, a, __, child) {
    final c = CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: c,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.95, end: 1).animate(c),
        child: child,
      ),
    );
  },
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Mon CV',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: C.blue,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: C.bg,
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1A1A1A),
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        labelStyle: const TextStyle(color: C.muted),
        prefixIconColor: C.muted,
        suffixIconColor: C.muted,
        border: _border(Colors.white.withValues(alpha: 0.12)),
        enabledBorder: _border(Colors.white.withValues(alpha: 0.12)),
        focusedBorder: _border(C.blue, 1.8),
        errorBorder: _border(C.pink),
        focusedErrorBorder: _border(C.pink, 1.8),
      ),
    ),
    home: const LoginPage(),
  );
}

// ================= WIDGETS REUTILISABLES =================

/// Fond animé : halos de lumière qui flottent lentement.
class Aurora extends StatefulWidget {
  final Widget child;
  const Aurora({super.key, required this.child});
  @override
  State<Aurora> createState() => _AuroraState();
}

class _AuroraState extends State<Aurora> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 20),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _blob(Alignment a, Color color, double size) => Align(
    alignment: a,
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.38), color.withValues(alpha: 0)],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, child) {
      final t = _c.value * 2 * math.pi;
      return Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: C.bg),
          _blob(Alignment(math.cos(t) * .9, math.sin(t) * .7), C.blue, 420),
          _blob(
            Alignment(math.sin(t * 2) * .9, math.cos(t) * .9),
            C.violet,
            380,
          ),
          _blob(
            Alignment(-math.cos(t) * .8, math.sin(t * 3) * .8),
            C.cyan,
            320,
          ),
          child!,
        ],
      );
    },
    child: widget.child,
  );
}

/// Carte en verre dépoli.
class Glass extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double fill;
  const Glass({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.radius = 22,
    this.fill = 0.06,
  });

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: Colors.white.withValues(alpha: fill),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: child,
      ),
    ),
  );
}

/// Apparition en fondu + glissement, avec délai selon l'index.
class Reveal extends StatefulWidget {
  final Widget child;
  final int index;
  const Reveal({super.key, required this.child, this.index = 0});
  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  late final Animation<double> _a = CurvedAnimation(
    parent: _c,
    curve: Curves.easeOutCubic,
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 90 * widget.index), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _a,
    child: SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.15),
        end: Offset.zero,
      ).animate(_a),
      child: widget.child,
    ),
  );
}

/// Effet de pression / survol.
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const Pressable({super.key, required this.child, this.onTap});
  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false, _hover = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => _hover = true),
    onExit: (_) => setState(() => _hover = false),
    child: GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.96 : (_hover ? 1.02 : 1),
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    ),
  );
}

class GText extends StatelessWidget {
  final String text;
  final TextStyle style;
  const GText(this.text, {super.key, required this.style});
  @override
  Widget build(BuildContext context) => ShaderMask(
    blendMode: BlendMode.srcIn,
    shaderCallback: (r) => C.textGrad.createShader(Offset.zero & r.size),
    child: Text(text, style: style.copyWith(color: Colors.white)),
  );
}

/// Icône lumineuse qui pulse.
class PulseIcon extends StatefulWidget {
  final IconData icon;
  final double size;
  const PulseIcon(this.icon, {super.key, this.size = 70});
  @override
  State<PulseIcon> createState() => _PulseIconState();
}

class _PulseIconState extends State<PulseIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, __) {
      final v = Curves.easeInOut.transform(_c.value);
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          gradient: C.btn,
          borderRadius: BorderRadius.circular(widget.size * .3),
          boxShadow: [
            BoxShadow(
              color: C.blue.withValues(alpha: .35 + .25 * v),
              blurRadius: 24 + 24 * v,
              spreadRadius: 2 * v,
            ),
          ],
        ),
        child: Icon(widget.icon, color: Colors.white, size: widget.size * .5),
      );
    },
  );
}

class GradientButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onTap;
  const GradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: loading ? null : onTap,
    child: Container(
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: C.btn,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: C.violet.withValues(alpha: .45),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: loading
            ? const SizedBox(
                key: ValueKey('load'),
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                key: const ValueKey('text'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ],
              ),
      ),
    ),
  );
}

/// Avatar : photo ou icône si l'image est absente.
class Avatar extends StatelessWidget {
  final String path;
  final double radius;
  const Avatar(this.path, {super.key, this.radius = 30});
  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: radius,
    backgroundColor: const Color(0xFF151515),
    child: ClipOval(
      child: path.isEmpty
          ? Icon(Icons.person, size: radius, color: C.blue)
          : path.startsWith('http')
          ? Image.network(
              path,
              key: ValueKey(path),
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              errorBuilder: (_, error, ___) {
                debugPrint('Erreur de chargement de la photo $path : $error');
                return Icon(Icons.person, size: radius, color: C.blue);
              },
              loadingBuilder: (_, child, p) => p == null
                  ? child
                  : const Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
            )
          : Image.asset(
              path,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.person, size: radius, color: C.blue),
            ),
    ),
  );
}

/// Avatar entouré d'un anneau dégradé qui tourne.
class SpinningAvatar extends StatefulWidget {
  final String path;
  final double radius;
  const SpinningAvatar(this.path, {super.key, this.radius = 40});
  @override
  State<SpinningAvatar> createState() => _SpinningAvatarState();
}

class _SpinningAvatarState extends State<SpinningAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, child) => Container(
      padding: const EdgeInsets.all(3.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          transform: GradientRotation(_c.value * 2 * math.pi),
          colors: const [C.blue, C.violet, C.cyan, C.pink, C.blue],
        ),
      ),
      child: child,
    ),
    child: Container(
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(shape: BoxShape.circle, color: C.bg),
      child: Avatar(widget.path, radius: widget.radius),
    ),
  );
}

class IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  const IconBox(this.icon, this.color, {super.key, this.size = 42});
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color.withValues(alpha: .16),
      borderRadius: BorderRadius.circular(size * .32),
      border: Border.all(color: color.withValues(alpha: .4)),
    ),
    child: Icon(icon, color: color, size: size * .5),
  );
}

// ================= SESSION & OUTILS =================
class Session {
  static int? id;
  static String? email;
  static void start(Map<String, dynamic> d) {
    id = int.tryParse('${d['id']}');
    email = d['email'] as String?;
  }

  static void clear() {
    id = null;
    email = null;
  }
}

void toast(BuildContext c, String m, {bool lifted = false}) {
  final s = ScaffoldMessenger.of(c);
  s.hideCurrentSnackBar();
  s.showSnackBar(
    SnackBar(
      content: Text(m),
      margin: EdgeInsets.fromLTRB(16, 0, 16, lifted ? 100 : 16),
    ),
  );
}

// ================= PAGE 1 : CONNEXION (API) =================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pwd = TextEditingController();
  bool _hide = true, _loading = false, _register = false;
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  @override
  void dispose() {
    _email.dispose();
    _pwd.dispose();
    _shake.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final isRegistration = _register;
      final data = isRegistration
          ? await ApiService.register(_email.text.trim(), _pwd.text)
          : await ApiService.login(_email.text.trim(), _pwd.text);
      if (!mounted) return;

      if (isRegistration) {
        setState(() {
          _loading = false;
          _register = false;
          _pwd.clear();
        });
        toast(context, 'Compte créé avec succès. Vous pouvez vous connecter.');
        return;
      }

      Session.start(data);
      if (!mounted) return;
      Navigator.pushReplacement(context, fadeRoute(const HomeShell()));
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _shake.forward(from: 0);
      HapticFeedback.heavyImpact();
      toast(context, e.display);
    }
  }

  Future<void> _editServer() async {
    final c = TextEditingController(text: ApiService.baseUrl);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF151515),
        title: const Text('Adresse de l’API'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: c,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(labelText: 'URL de base'),
            ),
            const SizedBox(height: 12),
            const Text(
              'Émulateur Android : http://10.0.2.2/api-test-main/public\n'
              'Téléphone réel : http://IP_DU_PC/api-test-main/public',
              style: TextStyle(color: C.muted, fontSize: 12, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    if (ok == true) {
      ApiService.baseUrl = c.text.trim().replaceAll(RegExp(r'/+$'), '');
      if (mounted) {
        final joignable = await ApiService.testerConnexion();
        if (mounted) {
          toast(
            context,
            joignable
                ? 'API joignable ✓ (${ApiService.baseUrl})'
                : 'API injoignable : ${ApiService.baseUrl}',
          );
        }
      }
    }
    c.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Aurora(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      tooltip: 'Adresse de l’API',
                      icon: const Icon(Icons.dns_rounded, color: C.muted),
                      onPressed: _editServer,
                    ),
                  ),
                  const Reveal(
                    child: PulseIcon(Icons.grid_view_rounded, size: 76),
                  ),
                  const SizedBox(height: 24),
                  const Reveal(
                    index: 1,
                    child: GText(
                      'Portfolio',
                      style: TextStyle(
                        fontSize: 46,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Reveal(
                    index: 2,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _register
                            ? 'Créez votre compte pour accéder au portfolio.'
                            : 'Connectez-vous pour découvrir mon parcours.',
                        key: ValueKey(_register),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: C.muted, fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Reveal(
                    index: 3,
                    child: AnimatedBuilder(
                      animation: _shake,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(
                          math.sin(_shake.value * math.pi * 8) *
                              10 *
                              (1 - _shake.value),
                          0,
                        ),
                        child: child,
                      ),
                      child: Glass(
                        radius: 26,
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: _email,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'E-mail',
                                  prefixIcon: Icon(
                                    Icons.alternate_email_rounded,
                                  ),
                                ),
                                validator: (v) {
                                  final t = v?.trim() ?? '';
                                  if (t.isEmpty) return 'Champ requis';
                                  if (!RegExp(
                                    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                  ).hasMatch(t)) {
                                    return 'Adresse e-mail invalide';
                                  }
                                  if (t.length > 100) {
                                    return '100 caractères maximum';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _pwd,
                                obscureText: _hide,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _submit(),
                                decoration: InputDecoration(
                                  labelText: 'Mot de passe',
                                  prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _hide
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                    onPressed: () =>
                                        setState(() => _hide = !_hide),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Champ requis';
                                  }
                                  if (_register && v.length < 6) {
                                    return '6 caractères minimum';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              GradientButton(
                                label: _register
                                    ? 'Créer mon compte'
                                    : 'Se connecter',
                                loading: _loading,
                                onTap: _submit,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Reveal(
                    index: 4,
                    child: TextButton(
                      onPressed: _loading
                          ? null
                          : () => setState(() => _register = !_register),
                      child: Text(
                        _register
                            ? 'Déjà un compte ? Se connecter'
                            : 'Pas de compte ? Créer un compte',
                        style: const TextStyle(
                          color: C.cyan,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

// ================= NAVIGATION =================
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _i = 0;
  static const _titles = ['Accueil', 'Famille', 'Contact'];
  static const _pages = [AccueilPage(), FamillePage(), ContactPage()];

  @override
  Widget build(BuildContext context) => Scaffold(
    extendBody: true,
    body: Aurora(
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      transitionBuilder: (c, a) => FadeTransition(
                        opacity: a,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, .3),
                            end: Offset.zero,
                          ).animate(a),
                          child: c,
                        ),
                      ),
                      child: Align(
                        key: ValueKey(_i),
                        alignment: Alignment.centerLeft,
                        child: GText(
                          _titles[_i],
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Pressable(
                    onTap: () {
                      Session.clear();
                      Navigator.pushReplacement(
                        context,
                        fadeRoute(const LoginPage()),
                      );
                    },
                    child: const Glass(
                      radius: 16,
                      padding: EdgeInsets.all(12),
                      child: Icon(Icons.logout_rounded, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeOutCubic,
                transitionBuilder: (c, a) => FadeTransition(
                  opacity: a,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.04, 0),
                      end: Offset.zero,
                    ).animate(a),
                    child: c,
                  ),
                ),
                child: KeyedSubtree(key: ValueKey(_i), child: _pages[_i]),
              ),
            ),
          ],
        ),
      ),
    ),
    bottomNavigationBar: FloatingNav(
      index: _i,
      onChanged: (v) {
        HapticFeedback.selectionClick();
        setState(() => _i = v);
      },
    ),
  );
}

class FloatingNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  const FloatingNav({super.key, required this.index, required this.onChanged});

  static const _icons = [
    Icons.home_rounded,
    Icons.family_restroom_rounded,
    Icons.alternate_email_rounded,
  ];
  static const _labels = ['Accueil', 'Famille', 'Contact'];

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Glass(
            radius: 28,
            fill: 0.09,
            padding: const EdgeInsets.all(6),
            child: SizedBox(
              height: 56,
              child: Stack(
                children: [
                  AnimatedAlign(
                    alignment: Alignment(index - 1.0, 0),
                    duration: const Duration(milliseconds: 380),
                    curve: Curves.easeOutBack,
                    child: FractionallySizedBox(
                      widthFactor: 1 / 3,
                      heightFactor: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: C.btn,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: C.violet.withValues(alpha: .5),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      for (var i = 0; i < 3; i++)
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => onChanged(i),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedScale(
                                  scale: i == index ? 1.15 : 1,
                                  duration: const Duration(milliseconds: 250),
                                  child: Icon(
                                    _icons[i],
                                    size: 22,
                                    color: i == index ? Colors.white : C.muted,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 250),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: i == index ? Colors.white : C.muted,
                                  ),
                                  child: Text(_labels[i]),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

// ================= PAGE 2 : ACCUEIL (CV) =================
class Section extends StatelessWidget {
  final String titre;
  final IconData icon;
  final Color accent;
  final List<Widget> children;
  const Section(
    this.titre,
    this.icon,
    this.accent, {
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) => Glass(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconBox(icon, accent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                titre,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.3,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        ...children,
      ],
    ),
  );
}

class TLItem extends StatelessWidget {
  final String titre, sous;
  final bool last;
  const TLItem(this.titre, this.sous, {super.key, this.last = false});

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 20,
          child: Column(
            children: [
              const SizedBox(height: 4),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: C.btn,
                  boxShadow: [
                    BoxShadow(
                      color: C.blue.withValues(alpha: .6),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              if (!last)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: Colors.white.withValues(alpha: .12),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: last ? 0 : 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(sous, style: const TextStyle(color: C.muted)),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class SkillBar extends StatelessWidget {
  final String label;
  final double level;
  final Color color;
  const SkillBar(this.label, this.level, {super.key, this.color = C.blue});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: level),
      duration: const Duration(milliseconds: 1400),
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '${(v * 100).round()}%',
                style: const TextStyle(color: C.muted, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: v.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [color, C.violet]),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: .5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class AccueilPage extends StatelessWidget {
  const AccueilPage({super.key});

  Widget _chip(String t, IconData i) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .06),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withValues(alpha: .14)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(i, size: 16, color: C.cyan),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            t,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );

  Widget _stat(int n, String label, IconData icon) => Glass(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
    child: Column(
      children: [
        Icon(icon, color: C.cyan, size: 22),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: n.toDouble()),
          duration: const Duration(milliseconds: 1400),
          curve: Curves.easeOutCubic,
          builder: (_, v, __) => GText(
            '${v.round()}',
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: C.muted, fontSize: 11),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, cs) {
      final wide = cs.maxWidth >= 800;
      Widget r(int i, Widget w) => Reveal(
        index: i,
        child: Padding(padding: const EdgeInsets.only(bottom: 14), child: w),
      );

      final hero = r(
        0,
        Glass(
          radius: 26,
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              const SpinningAvatar(kPhoto, radius: 44),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      kNom,
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.5,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      kTitre,
                      style: TextStyle(color: C.muted, height: 1.35),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _chip('Goma, RDC', Icons.location_on_rounded),
                        if (Session.email != null)
                          _chip(Session.email!, Icons.verified_user_rounded),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

      final stats = r(
        1,
        Row(
          children: [
            Expanded(child: _stat(3, "ans d'études", Icons.school_rounded)),
            const SizedBox(width: 12),
            Expanded(child: _stat(6, 'technologies', Icons.code_rounded)),
            const SizedBox(width: 12),
            Expanded(child: _stat(2, 'langues', Icons.translate_rounded)),
          ],
        ),
      );

      final formation = r(
        2,
        const Section(
          'Formation',
          Icons.school_rounded,
          C.blue,
          children: [
            TLItem('Études en informatique', 'ISIG GOMA depuis 2023'),
            TLItem('Baccalauréat', '2023', last: true),
          ],
        ),
      );
      final experiences = r(
        3,
        const Section(
          'Expériences',
          Icons.work_outline_rounded,
          C.violet,
          children: [
            TLItem(
              'Stage – Telecommunication',
              'Entreprise hayatcom • juin 2026',
            ),
            TLItem(
              'Projet – Application de gestion',
              'Flutter & Firebase • 2025',
            ),
            TLItem(
              'Job étudiant – Assistant informatique',
              'Cybercafé Y • 2024',
              last: true,
            ),
          ],
        ),
      );
      final competences = r(
        4,
        const Section(
          'Compétences techniques',
          Icons.code_rounded,
          C.cyan,
          children: [
            SkillBar('Flutter', .85),
            SkillBar('Dart', .85),
            SkillBar('Java', .70, color: C.violet),
            SkillBar('Python', .70, color: C.violet),
            SkillBar('SQL', .75, color: C.cyan),
            SkillBar('Git/GitHub', .80, color: C.cyan),
          ],
        ),
      );
      final langues = r(
        5,
        const Section(
          'Langues',
          Icons.language_rounded,
          C.pink,
          children: [
            SkillBar('Français · langue maternelle', 1, color: C.pink),
            SkillBar('Anglais · intermédiaire (B1)', .6, color: C.pink),
          ],
        ),
      );
      final interets = r(
        6,
        Section(
          "Centres d'intérêt",
          Icons.favorite_outline_rounded,
          C.blue,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip('Football', Icons.sports_soccer_rounded),
                _chip('Musique', Icons.music_note_rounded),
                _chip('Lecture', Icons.menu_book_rounded),
                _chip('Technologie', Icons.memory_rounded),
              ],
            ),
          ],
        ),
      );

      final pad = wide ? 32.0 : 16.0;
      return ListView(
        padding: EdgeInsets.fromLTRB(pad, 8, pad, 120),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Column(
                children: [
                  hero,
                  stats,
                  if (wide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [formation, experiences, interets],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(children: [competences, langues]),
                        ),
                      ],
                    )
                  else ...[
                    formation,
                    experiences,
                    competences,
                    langues,
                    interets,
                  ],
                ],
              ),
            ),
          ),
        ],
      );
    },
  );
}

// ================= PAGE 3 : FAMILLE (API REST + MySQL) =================
class Skeleton extends StatefulWidget {
  const Skeleton({super.key});
  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, __) => Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withValues(alpha: .04 + .07 * _c.value),
      ),
    ),
  );
}

class FamillePage extends StatefulWidget {
  const FamillePage({super.key});
  @override
  State<FamillePage> createState() => _FamillePageState();
}

class _FamillePageState extends State<FamillePage> {
  late Future<List<Membre>> _future = ApiService.listMembres();
  List<Membre>? _localList;
  Timer? _poller;
  static const _accents = [C.blue, C.violet, C.cyan, C.pink];

  @override
  void initState() {
    super.initState();
    _reload();
    _poller = Timer.periodic(const Duration(seconds: 5), (_) => _reload());
  }

  @override
  void dispose() {
    _poller?.cancel();
    super.dispose();
  }

  Future<void> _reload() async {
    final request = ApiService.listMembres();
    if (mounted) {
      setState(() => _future = request);
    }
    try {
      final list = await request;
      if (!mounted) return;
      setState(() {
        _localList = list;
        _future = Future.value(list);
      });
    } catch (_) {}
  }

  Future<void> _refresh() async {
    await _reload();
  }

  Future<void> _openForm([Membre? m]) async {
    final result = await showModalBottomSheet<Membre>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 560),
      builder: (_) => MembreForm(membre: m),
    );
    if (result != null && mounted) {
      toast(
        context,
        m == null ? 'Membre ajouté avec succès' : 'Membre modifié',
        lifted: true,
      );
      setState(() {
        final list = List<Membre>.from(_localList ?? []);
        final index = list.indexWhere((item) => item.id == result.id);
        if (index >= 0) {
          list[index] = result;
        } else {
          list.add(result);
        }
        _localList = list;
        _future = Future.value(list);
      });
    }
  }

  Future<void> _delete(Membre m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF151515),
        title: const Text('Supprimer ce membre ?'),
        content: Text(
          '${m.nomComplet} sera supprimé définitivement, ainsi que sa photo.',
          style: const TextStyle(color: C.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: C.pink),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ApiService.deleteMembre(m.id);
      if (!mounted) return;
      toast(context, 'Membre supprimé', lifted: true);
      setState(() {
        final list = List<Membre>.from(_localList ?? []);
        list.removeWhere((item) => item.id == m.id);
        _localList = list;
        _future = Future.value(list);
      });
    } on ApiException catch (e) {
      if (mounted) toast(context, e.display, lifted: true);
    }
  }

  Widget _lien(String t, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: c.withValues(alpha: .18),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: c.withValues(alpha: .4)),
    ),
    child: Text(
      t,
      style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w700),
    ),
  );

  Widget _info(IconData i, String t) => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(i, size: 16, color: C.cyan),
        const SizedBox(width: 8),
        Flexible(
          child: Text(t, style: const TextStyle(color: C.muted)),
        ),
      ],
    ),
  );

  void _details(Membre m, Color accent) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheet) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(sheet).height * 0.9,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Glass(
            radius: 28,
            fill: 0.14,
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SpinningAvatar(m.imageUrl ?? '', radius: 52),
                const SizedBox(height: 16),
                Text(
                  m.nomComplet,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                _lien(m.parente, accent),
                const SizedBox(height: 6),
                _info(Icons.location_on_rounded, 'Né(e) à ${m.lieuNaissance}'),
                _info(
                  Icons.cake_rounded,
                  m.age == null ? m.dateFr : '${m.dateFr} • ${m.age} ans',
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.edit_rounded, size: 18),
                        label: const Text('Modifier'),
                        onPressed: () {
                          Navigator.pop(sheet);
                          _openForm(m);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: C.pink,
                        ),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                        ),
                        label: const Text('Supprimer'),
                        onPressed: () {
                          Navigator.pop(sheet);
                          _delete(m);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _grid(int n, Widget Function(int) item) => LayoutBuilder(
    builder: (_, cs) {
      final count = cs.maxWidth >= 900 ? 3 : (cs.maxWidth >= 520 ? 2 : 1);
      return GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 180),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: count,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 124,
        ),
        itemCount: n,
        itemBuilder: (_, i) => item(i),
      );
    },
  );

  Widget _card(Membre m, int i) {
    final accent = _accents[i % _accents.length];
    return Reveal(
      index: i,
      child: Pressable(
        onTap: () => _details(m, accent),
        child: Glass(
          padding: const EdgeInsets.fromLTRB(14, 14, 4, 14),
          child: Row(
            children: [
              SpinningAvatar(m.imageUrl ?? '', radius: 31),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.nomComplet,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _lien(m.parente, accent),
                    const SizedBox(height: 6),
                    Text(
                      m.lieuNaissance,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: C.muted),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                color: const Color(0xFF181818),
                icon: const Icon(Icons.more_vert_rounded, color: C.muted),
                onSelected: (v) => v == 'edit' ? _openForm(m) : _delete(m),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Modifier')),
                  PopupMenuItem(value: 'del', child: Text('Supprimer')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _message(
    IconData icon,
    String titre,
    String texte, {
    Widget? action,
  }) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Glass(
          radius: 26,
          padding: const EdgeInsets.all(26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PulseIcon(icon, size: 60),
              const SizedBox(height: 18),
              Text(
                titre,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                texte,
                textAlign: TextAlign.center,
                style: const TextStyle(color: C.muted, height: 1.4),
              ),
              if (action != null) ...[const SizedBox(height: 20), action],
            ],
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Stack(
      children: [
        Positioned.fill(
          child: FutureBuilder<List<Membre>>(
            future: _future,
            builder: (_, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return _grid(4, (_) => const Skeleton());
              }
              if (snap.hasError) {
                return _message(
                  Icons.cloud_off_rounded,
                  'Connexion impossible',
                  '${snap.error}',
                  action: GradientButton(label: 'Réessayer', onTap: _reload),
                );
              }
              final list = snap.data!;
              if (list.isEmpty) {
                return _message(
                  Icons.family_restroom_rounded,
                  'Aucun membre pour l’instant',
                  'Ajoutez le premier membre de la famille avec le bouton ci-dessous.',
                );
              }
              return RefreshIndicator(
                color: C.violet,
                backgroundColor: const Color(0xFF151515),
                onRefresh: _refresh,
                child: _grid(list.length, (i) => _card(list[i], i)),
              );
            },
          ),
        ),
        Positioned(
          right: 20,
          bottom: bottom + 98,
          child: Reveal(
            index: 3,
            child: Pressable(
              onTap: () => _openForm(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  gradient: C.btn,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: C.violet.withValues(alpha: .5),
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Ajouter',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Formulaire d'ajout / modification (feuille modale).
class MembreForm extends StatefulWidget {
  final Membre? membre;
  const MembreForm({super.key, this.membre});
  @override
  State<MembreForm> createState() => _MembreFormState();
}

class _MembreFormState extends State<MembreForm> {
  final _form = GlobalKey<FormState>();
  late final _nom = TextEditingController(text: widget.membre?.nom);
  late final _postnom = TextEditingController(text: widget.membre?.postnom);
  late final _prenom = TextEditingController(text: widget.membre?.prenom);
  late final _lieu = TextEditingController(text: widget.membre?.lieuNaissance);
  late final _date = TextEditingController(text: widget.membre?.dateNaissance);
  late final _parente = TextEditingController(text: widget.membre?.parente);

  XFile? _img;
  Uint8List? _bytes;
  bool _saving = false;
  String? _err;
  Map<String, String> _srv = {};

  bool get _edit => widget.membre != null;

  @override
  void dispose() {
    for (final c in [_nom, _postnom, _prenom, _lieu, _date, _parente]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pick() async {
    final f = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (f == null) return;
    final b = await f.readAsBytes();
    if (b.length > 2 * 1024 * 1024) {
      setState(() => _err = 'Image trop lourde (2 Mo maximum).');
      return;
    }
    setState(() {
      _img = f;
      _bytes = b;
      _err = null;
    });
  }

  Future<void> _pickDate() async {
    final init = DateTime.tryParse(_date.text) ?? DateTime(2000);
    final d = await showDatePicker(
      context: context,
      initialDate: init.isAfter(DateTime.now()) ? DateTime.now() : init,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Date de naissance',
    );
    if (d != null) {
      _date.text =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _save() async {
    setState(() {
      _srv = {};
      _err = null;
    });
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final fields = {
      'nom': _nom.text.trim(),
      'postnom': _postnom.text.trim(),
      'prenom': _prenom.text.trim(),
      'lieu_naissance': _lieu.text.trim(),
      'date_naissance': _date.text.trim(),
      'parente': _parente.text.trim(),
    };
    try {
      if (_edit) {
        final updated = await ApiService.updateMembre(
          widget.membre!.id,
          fields,
          image: _img,
        );
        if (mounted) Navigator.pop(context, updated);
      } else {
        final created = await ApiService.createMembre(fields, image: _img);
        if (mounted) Navigator.pop(context, created);
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _srv = e.errors;
        _err = e.errors.isEmpty ? e.message : null;
      });
      _form.currentState!.validate();
    }
  }

  Widget _field(
    String label,
    TextEditingController c,
    String key,
    int max,
    IconData icon,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: c,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: (v) {
        final t = v?.trim() ?? '';
        if (t.isEmpty) return 'Champ requis';
        if (t.length > max) return '$max caractères maximum';
        return _srv[key];
      },
    ),
  );

  Widget _photo() {
    Widget inner;
    if (_bytes != null) {
      inner = ClipOval(
        child: Image.memory(_bytes!, width: 92, height: 92, fit: BoxFit.cover),
      );
    } else if (widget.membre?.imageUrl != null) {
      inner = Avatar(widget.membre!.imageUrl!, radius: 46);
    } else {
      inner = const CircleAvatar(
        radius: 46,
        backgroundColor: Color(0xFF151515),
        child: Icon(Icons.add_a_photo_rounded, color: C.cyan, size: 30),
      );
    }
    return Center(
      child: Pressable(
        onTap: _pick,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: C.btn,
              ),
              child: inner,
            ),
            const SizedBox(height: 8),
            Text(
              (_bytes != null || widget.membre?.imageUrl != null)
                  ? 'Changer la photo'
                  : 'Ajouter une photo (facultatif)',
              style: const TextStyle(
                color: C.cyan,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFF121212),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      border: Border.all(color: Colors.white.withValues(alpha: .12)),
    ),
    child: Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              GText(
                _edit ? 'Modifier le membre' : 'Nouveau membre',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.8,
                ),
              ),
              const SizedBox(height: 18),
              _photo(),
              const SizedBox(height: 18),
              if (_err != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: C.pink.withValues(alpha: .14),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: C.pink.withValues(alpha: .4)),
                  ),
                  child: Text(
                    _err!,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              _field('Nom', _nom, 'nom', 50, Icons.badge_outlined),
              _field('Postnom', _postnom, 'postnom', 50, Icons.badge_outlined),
              _field(
                'Prénom',
                _prenom,
                'prenom',
                50,
                Icons.person_outline_rounded,
              ),
              _field(
                'Lieu de naissance',
                _lieu,
                'lieu_naissance',
                100,
                Icons.location_on_outlined,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: TextFormField(
                  controller: _date,
                  readOnly: true,
                  onTap: _pickDate,
                  decoration: const InputDecoration(
                    labelText: 'Date de naissance',
                    prefixIcon: Icon(Icons.cake_outlined),
                    suffixIcon: Icon(Icons.calendar_month_rounded),
                  ),
                  validator: (v) {
                    final t = v?.trim() ?? '';
                    if (t.isEmpty) return 'Choisissez une date';
                    final d = DateTime.tryParse(t);
                    if (d == null) return 'Date invalide';
                    if (d.isAfter(DateTime.now())) {
                      return 'La date ne peut pas être dans le futur';
                    }
                    return _srv['date_naissance'];
                  },
                ),
              ),
              _field(
                'Parenté',
                _parente,
                'parente',
                50,
                Icons.family_restroom_outlined,
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final p in [
                    'Père',
                    'Mère',
                    'Frère',
                    'Sœur',
                    'Oncle',
                    'Tante',
                  ])
                    ActionChip(
                      label: Text(p),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: .14),
                      ),
                      backgroundColor: Colors.white.withValues(alpha: .06),
                      onPressed: () => setState(() => _parente.text = p),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              GradientButton(
                label: _edit ? 'Enregistrer' : 'Ajouter le membre',
                loading: _saving,
                onTap: () {
                  if (!_saving) _save();
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// ================= PAGE 4 : CONTACT =================
class Ct {
  final IconData icon;
  final String titre, valeur, url;
  final Color color;
  const Ct(this.icon, this.titre, this.valeur, this.url, this.color);
}

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  static const items = [
    Ct(
      Icons.phone_rounded,
      'Téléphone',
      '+243 971 185 261',
      'tel:+243971185261',
      C.blue,
    ),
    Ct(
      Icons.email_outlined,
      'E-mail',
      'elianelydie@gmail.com',
      'mailto:elianelydie@gmail.com',
      C.violet,
    ),
    Ct(
      Icons.location_on_outlined,
      'Adresse',
      'Goma, RDC',
      'https://www.google.com/maps/search/?api=1&query=Goma',
      C.cyan,
    ),
    Ct(
      Icons.business_center_outlined,
      'LinkedIn',
      'linkedin.com/in/votreprenom',
      'https://www.linkedin.com/in/votreprenom',
      C.pink,
    ),
    Ct(
      Icons.code_rounded,
      'GitHub',
      'github.com/ALINDEKABWENDE',
      'https://github.com/ALINDEKABWENDE',
      C.blue,
    ),
  ];

  Future<void> _open(BuildContext c, String url) async {
    var ok = false;
    try {
      ok = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {}
    if (!ok && c.mounted) {
      ScaffoldMessenger.of(c).showSnackBar(
        const SnackBar(content: Text("Impossible d'ouvrir le lien")),
      );
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, cs) {
      final pad = cs.maxWidth >= 800 ? 32.0 : 16.0;
      return ListView(
        padding: EdgeInsets.fromLTRB(pad, 8, pad, 120),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                children: [
                  Reveal(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Glass(
                        radius: 26,
                        padding: const EdgeInsets.all(22),
                        child: Row(
                          children: [
                            const PulseIcon(
                              Icons.mark_unread_chat_alt_outlined,
                              size: 60,
                            ),
                            const SizedBox(width: 18),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GText(
                                    'Restons en contact',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Une opportunité, un projet ou simplement envie d’échanger ?',
                                    style: TextStyle(color: C.muted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  for (var i = 0; i < items.length; i++)
                    Reveal(
                      index: i + 1,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Pressable(
                          onTap: () => _open(context, items[i].url),
                          child: Glass(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                IconBox(
                                  items[i].icon,
                                  items[i].color,
                                  size: 46,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        items[i].titre,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        items[i].valeur,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: C.muted),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_outward_rounded,
                                  size: 20,
                                  color: items[i].color,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      );
    },
  );
}
