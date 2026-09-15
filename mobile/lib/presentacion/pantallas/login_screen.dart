import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../rutas/app_rutas.dart';
import '../controladores/auth_controller.dart';
import '../widgets/curva_login.dart';

/// Pantalla de acceso local con contenido limpio, una curva en la esquina
/// superior y ondas decorativas al pie.
class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final verdeSuave = Color.lerp(esquema.primary, esquema.surface, 0.68)!;
    final verdeMedio = Color.lerp(esquema.primary, esquema.surface, 0.42)!;
    final verdeProfundo = Color.lerp(esquema.primary, esquema.onSurface, 0.12)!;
    final margenSuperiorSistema = MediaQuery.viewPaddingOf(context).top;
    final esEscritorio = MediaQuery.sizeOf(context).width >= 600;
    final alturaCurvaInferior = esEscritorio ? 110.0 : 220.0;
    final rellenoSuperior = margenSuperiorSistema + (esEscritorio ? 110.0 : 178.0);
    final rellenoInferior = esEscritorio ? 140.0 : 244.0;

    return Scaffold(
      // El fondo se dibuja fuera de SafeArea para continuar detrás del reloj
      // y la cámara frontal; el formulario conserva su separación vertical.
      body: LayoutBuilder(
        builder: (context, restricciones) => Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 250,
              child: CustomPaint(
                painter: CurvaLoginPainter(
                  colorPrincipal: verdeMedio,
                  colorAcento: verdeSuave,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: alturaCurvaInferior,
              child: IgnorePointer(
                child: CustomPaint(
                  painter: CurvasLoginInferioresPainter(
                    colorPrincipal: verdeProfundo,
                    colorAcento: verdeMedio,
                  ),
                ),
              ),
            ),
            Positioned(
              top: margenSuperiorSistema + 48,
              right: 42,
              child: Hero(
                tag: 'app-icon',
                child: CircleAvatar(
                  radius: 27,
                  backgroundColor: esquema.surface,
                  child: Icon(Icons.bolt, color: esquema.primary, size: 28),
                ),
              ),
            ),
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                30,
                rellenoSuperior,
                30,
                rellenoInferior,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      (restricciones.maxHeight -
                              rellenoSuperior -
                              rellenoInferior)
                          .clamp(0, double.infinity)
                          .toDouble(),
                ),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOut,
                  builder: (context, valor, child) => Opacity(
                    opacity: valor,
                    child: Transform.translate(
                      offset: Offset(0, (1 - valor) * 22),
                      child: child,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'QuickDev',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: esquema.primary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'INICIAR\nSESIÓN',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: esquema.primary,
                              fontWeight: FontWeight.w800,
                              height: 0.98,
                            ),
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        controller: controller.tecUsuario,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _decoracionLinea(
                          contexto: context,
                          etiqueta: 'Usuario',
                          icono: Icons.person_outline_rounded,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Obx(
                        () => TextField(
                          controller: controller.tecPassword,
                          obscureText: !controller.mostrarContrasena.value,
                          decoration: _decoracionLinea(
                            contexto: context,
                            etiqueta: 'Contraseña',
                            icono: Icons.lock_outline_rounded,
                            sufijo: ExcludeFocusTraversal(
                              child: IconButton(
                                tooltip: controller.mostrarContrasena.value
                                    ? 'Ocultar contraseña'
                                    : 'Mostrar contraseña',
                                onPressed:
                                    controller.alternarVisibilidadContrasena,
                                icon: Icon(
                                  controller.mostrarContrasena.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ExcludeFocusTraversal(
                          child: TextButton(
                            onPressed: () {},
                            child: const Text('¿Olvidaste tu contraseña?'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Obx(
                        () => FilledButton(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(54),
                            shape: const StadiumBorder(),
                          ),
                          onPressed: controller.cargando.value
                              ? null
                              : controller.iniciarSesion,
                          child: controller.cargando.value
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('INGRESAR'),
                        ),
                      ),
                      const SizedBox(height: 22),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: esquema.primary,
                          backgroundColor: esquema.surface.withValues(alpha: 0.94),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        onPressed: () => Get.toNamed(AppRutas.registro),
                        child: const Text('¿No tienes cuenta? Regístrate'),
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

  InputDecoration _decoracionLinea({
    required BuildContext contexto,
    required String etiqueta,
    required IconData icono,
    Widget? sufijo,
  }) {
    final esquema = Theme.of(contexto).colorScheme;
    final borde = UnderlineInputBorder(
      borderSide: BorderSide(color: esquema.outlineVariant),
    );

    return InputDecoration(
      labelText: etiqueta,
      prefixIcon: Icon(icono, size: 20),
      suffixIcon: sufijo,
      filled: false,
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
      enabledBorder: borde,
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: esquema.primary, width: 2),
      ),
    );
  }
}
