import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controladores/auth_controller.dart';
import '../widgets/curva_login.dart';

/// Pantalla de registro: mismo lenguaje visual que [LoginScreen], pero
/// crea una cuenta real en el backend (`POST /auth/register`) en vez de
/// iniciar sesión con una ya existente.
class RegisterScreen extends GetView<AuthController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final verdeSuave = Color.lerp(esquema.primary, esquema.surface, 0.68)!;
    final verdeMedio = Color.lerp(esquema.primary, esquema.surface, 0.42)!;
    final verdeProfundo = Color.lerp(esquema.primary, esquema.onSurface, 0.12)!;
    final margenSuperiorSistema = MediaQuery.viewPaddingOf(context).top;

    return Scaffold(
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
              height: 220,
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
              child: CircleAvatar(
                radius: 27,
                backgroundColor: esquema.surface,
                child: Icon(Icons.bolt, color: esquema.primary, size: 28),
              ),
            ),
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                30,
                margenSuperiorSistema + 178,
                30,
                48,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      (restricciones.maxHeight - margenSuperiorSistema - 178 - 48)
                          .clamp(0, double.infinity)
                          .toDouble(),
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
                      'CREAR\nCUENTA',
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
                          sufijo: IconButton(
                            tooltip: controller.mostrarContrasena.value
                                ? 'Ocultar contraseña'
                                : 'Mostrar contraseña',
                            onPressed: controller.alternarVisibilidadContrasena,
                            icon: Icon(
                              controller.mostrarContrasena.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
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
                            : controller.registrar,
                        child: controller.cargando.value
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('CREAR CUENTA'),
                      ),
                    ),
                    const SizedBox(height: 22),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                    ),
                  ],
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
