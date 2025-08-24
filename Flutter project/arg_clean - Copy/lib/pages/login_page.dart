import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  bool _loading = false;
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _googleSignIn(BuildContext context) async {
    setState(() => _loading = true);
    try {
      await context.read<AuthService>().signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha no login: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // ======= FUNDO ANIMADO =======
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) {
              final t = _ctrl.value;
              final begin = Alignment.lerp(Alignment.topLeft, Alignment.bottomRight, t)!;
              final end = Alignment.lerp(Alignment.centerRight, Alignment.topCenter, t)!;
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: begin,
                    end: end,
                    colors: [
                      cs.primaryContainer.withOpacity(.55),
                      cs.surfaceVariant.withOpacity(.55),
                      cs.surface,
                    ],
                  ),
                ),
              );
            },
          ),
          // blobs decorativos
          Positioned(
            left: -60,
            top: 40,
            child: _Blob(color: cs.primary.withOpacity(.18), size: 180),
          ),
          Positioned(
            right: -40,
            bottom: 60,
            child: _Blob(color: cs.tertiary.withOpacity(.18), size: 140),
          ),

          // ======= CONTEÚDO =======
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: _GlassCard(
                    borderRadius: 24,
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // LOGO com aura
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: cs.primary.withOpacity(.25),
                                  blurRadius: 24,
                                  spreadRadius: 4,
                                ),
                              ],
                              gradient: RadialGradient(
                                colors: [cs.primaryContainer.withOpacity(.45), Colors.transparent],
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: SizedBox(
                                height: 150,
                                width: 150,
                                child: FittedBox(
                                  fit: BoxFit.contain, // nunca corta sua arte
                                  child: Image.asset('assets/images/icon_1024.png'),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // TÍTULO COM GRADIENTE
                          ShaderMask(
                            shaderCallback: (r) => LinearGradient(
                              colors: [cs.primary, cs.tertiary],
                            ).createShader(r),
                            child: Text(
                              'SC scheduler',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white, // é mascarado pelo shader
                                  ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // DESCRIÇÃO
                          Text(
                            'Aplicativo para auxiliar no acompanhamento da '
                            'Semana da Computação do DECSI/UFOP. '
                            'Entre com sua conta Google para acessar a programação, '
                            'favoritar eventos, fazer check-in e participar dos chats.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  height: 1.35,
                                ),
                          ),

                          const SizedBox(height: 24),

                          // BOTÃO GOOGLE (estilizado)
                          _PrimaryAction(
                            loading: _loading,
                            onTap: _loading ? null : () => _googleSignIn(context),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Image.asset('assets/images/google.png', width: 20, height: 20),
                                ),
                                Text(_loading ? 'Entrando...' : 'Entrar com o Google'),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),
                          _DividerDot(text: 'DECSI • UFOP'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ======= OVERLAY DE CARREGAMENTO =======
          if (_loading)
            _LoadingOverlay(
              text: 'Conectando…',
              color: cs.primary,
            ),
        ],
      ),
    );
  }
}

// =============== Widgets de estilo ===============

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withOpacity(.35), blurRadius: 40, spreadRadius: 12)],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  const _GlassCard({required this.child, this.borderRadius = 16});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          colors: [cs.primary.withOpacity(.18), cs.surfaceVariant.withOpacity(.12)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(1.2), // “borda” com gradiente
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - 1),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(.86),
              borderRadius: BorderRadius.circular(borderRadius - 1),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool loading;
  const _PrimaryAction({required this.child, required this.onTap, required this.loading});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // No escuro: fundo sólido com contraste garantido.
    // No claro: mantém o gradiente bonito.
    final BoxDecoration decoration = isDark
        ? BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(color: cs.primary.withOpacity(.25), blurRadius: 18, offset: const Offset(0, 8)),
            ],
            border: Border.all(color: Colors.white24, width: 1), // ajuda a separar do fundo no dark
          )
        : BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: [cs.primary, cs.tertiary],
              begin: Alignment.centerLeft, end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(color: cs.primary.withOpacity(.25), blurRadius: 18, offset: const Offset(0, 8)),
            ],
          );

    final textColor = isDark ? cs.onPrimary : Colors.white;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: loading ? .8 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          decoration: decoration,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: DefaultTextStyle(
            style: theme.textTheme.titleMedium!.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
              shadows: isDark
                  ? const [] // já tem contraste
                  : const [Shadow(blurRadius: 2, offset: Offset(0, 1), color: Colors.black26)],
            ),
            child: loading
                ? SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.6, color: textColor),
                  )
                : child,
          ),
        ),
      ),
    );
  }
}

class _DividerDot extends StatelessWidget {
  final String text;
  const _DividerDot({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: Divider(color: cs.outlineVariant, endIndent: 12)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: cs.surfaceVariant.withOpacity(.6),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(text, style: Theme.of(context).textTheme.labelSmall),
        ),
        Expanded(child: Divider(color: cs.outlineVariant, indent: 12)),
      ],
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  final String text;
  final Color color;
  const _LoadingOverlay({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Bloqueia toque e escurece levemente
        ModalBarrier(color: Colors.black.withOpacity(.15), dismissible: false),
        // Caixa de loading
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(.12), blurRadius: 18)],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 22, width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.6, color: color),
                ),
                const SizedBox(width: 12),
                Text(text, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
