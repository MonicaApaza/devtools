import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controladores/auth_controller.dart';
import '../widgets/curva_login.dart';

/// Pantalla de login: puerta de entrada de la app, con curvas como
/// elemento visual principal (Sesión 7: Clean Architecture con GetX +
/// personalización de pantalla inicial con efectos curvos). No valida
/// credenciales contra nada — ver AuthController.
class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 260,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [esquema.primary, esquema.primaryContainer],
                      ),
                    ),
                  ),
                  CustomPaint(
                    painter: CurvaLoginPainter(
                      colorPrincipal: Theme.of(context).scaffoldBackgroundColor,
                      colorAcento: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Hero(
                            tag: 'app-icon',
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: esquema.onPrimary,
                              child: Icon(
                                Icons.bolt,
                                color: esquema.primary,
                                size: 30,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'QuickDev',
                            style: TextStyle(
                              color: esquema.onPrimary,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tu referencia rápida de shortcuts y comandos',
                            style: TextStyle(
                              color: esquema.onPrimary.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOut,
                builder: (context, valor, child) => Opacity(
                  opacity: valor,
                  child: Transform.translate(
                    offset: Offset(0, (1 - valor) * 24),
                    child: child,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Ingresa a tu cuenta local',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller.tecUsuario,
                      decoration: const InputDecoration(
                        labelText: 'Usuario',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: controller.tecPassword,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: controller.iniciarSesion,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text('Ingresar'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Obx(() {
                      final sesion = controller.sesion.value;
                      if (sesion == null) return const SizedBox.shrink();
                      return OutlinedButton(
                        onPressed: controller.continuarConSesionGuardada,
                        child: Text('Continuar como: ${sesion.usuario}'),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
