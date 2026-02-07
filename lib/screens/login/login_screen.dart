import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../config/asset_paths.dart';
import '../../services/auth/auth_providers.dart';
import '../../utils/florida_messages.dart';
import '../../utils/validators.dart';
import '../../widgets/app_button.dart';

/// Full authentication screen with Sign In / Sign Up tabs, social login, and
/// password reset. Uses Florida-themed messaging for all error feedback.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  // ---------------------------------------------------------------------------
  // Controllers & Keys
  // ---------------------------------------------------------------------------

  late TabController _tabController;

  final _signInFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _signUpEmailController = TextEditingController();
  final _signUpPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // ---------------------------------------------------------------------------
  // UI State
  // ---------------------------------------------------------------------------

  bool _obscurePassword = true;
  bool _obscureSignUpPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {
        // Clear errors when switching tabs.
        _errorMessage = null;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),

                // -- KNEX logo --
                Center(
                  child: Image.asset(
                    AssetPaths.knexLogo,
                    width: 80,
                    height: 80,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Valet Parking',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // -- Tab bar --
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Sign In'),
                    Tab(text: 'Sign Up'),
                  ],
                  indicatorColor: colorScheme.primary,
                  labelColor: colorScheme.primary,
                  unselectedLabelColor: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 24),

                // -- Error banner --
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: colorScheme.onErrorContainer,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            size: 18,
                            color: colorScheme.onErrorContainer,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () =>
                              setState(() => _errorMessage = null),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // -- Tab content (without nested scrollable) --
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: IndexedStack(
                    index: _tabController.index,
                    children: [
                      _buildSignInForm(),
                      _buildSignUpForm(),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // -- Divider with "or" --
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'or',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),

                // -- Social sign-in buttons --
                _buildSocialButtons(theme, colorScheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sign In Form
  // ---------------------------------------------------------------------------

  Widget _buildSignInForm() {
    return Form(
      key: _signInFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _emailController,
            validator: Validators.email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.email_outlined),
              labelText: 'Email',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            validator: (v) => Validators.required(v, 'Password'),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleSignIn(),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline),
              labelText: 'Password',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _handleForgotPassword,
              child: const Text('Forgot Password?'),
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Sign In',
            onPressed: _handleSignIn,
            isLoading: _isLoading,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sign Up Form
  // ---------------------------------------------------------------------------

  Widget _buildSignUpForm() {
    return Form(
      key: _signUpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _signUpEmailController,
            validator: Validators.email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.email_outlined),
              labelText: 'Email',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _signUpPasswordController,
            obscureText: _obscureSignUpPassword,
            validator: (v) =>
                Validators.required(v, 'Password') ??
                Validators.minLength(v, 6),
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline),
              labelText: 'Password',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureSignUpPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () => setState(
                    () => _obscureSignUpPassword = !_obscureSignUpPassword),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            validator: (v) =>
                Validators.passwordMatch(v, _signUpPasswordController.text),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleSignUp(),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline),
              labelText: 'Confirm Password',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Create Account',
            onPressed: _handleSignUp,
            isLoading: _isLoading,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Social Buttons
  // ---------------------------------------------------------------------------

  Widget _buildSocialButtons(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            icon: Icon(
              Icons.g_mobiledata,
              size: 24,
              color: colorScheme.onSurface,
            ),
            label: Text(
              'Continue with Google',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            onPressed: _isLoading ? null : _handleGoogleSignIn,
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: BorderSide(color: colorScheme.outline),
            ),
          ),
        ),
        if (Platform.isIOS) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.apple, color: Colors.white),
              label: Text(
                'Continue with Apple',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
              onPressed: _isLoading ? null : _handleAppleSignIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Handlers
  // ---------------------------------------------------------------------------

  Future<void> _handleSignIn() async {
    if (!_signInFormKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
      // Navigation is handled by GoRouter redirect on auth state change.
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _errorMessage =
            FloridaMessages.getMessageForAuthError(context, e.code));
      }
    } catch (e) {
      if (mounted) {
        setState(
            () => _errorMessage = FloridaMessages.genericError(context));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignUp() async {
    if (!_signUpFormKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signUpWithEmail(
        _signUpEmailController.text.trim(),
        _signUpPasswordController.text,
      );
      // Navigation is handled by GoRouter redirect on auth state change.
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _errorMessage =
            FloridaMessages.getMessageForAuthError(context, e.code));
      }
    } catch (e) {
      if (mounted) {
        setState(
            () => _errorMessage = FloridaMessages.genericError(context));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final result = await authService.signInWithGoogle();
      if (result == null) {
        // User cancelled -- do nothing.
        return;
      }
      // Navigation is handled by GoRouter redirect on auth state change.
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _errorMessage =
            FloridaMessages.getMessageForAuthError(context, e.code));
      }
    } catch (e) {
      if (mounted) {
        setState(
            () => _errorMessage = FloridaMessages.genericError(context));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithApple();
      // Navigation is handled by GoRouter redirect on auth state change.
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _errorMessage =
            FloridaMessages.getMessageForAuthError(context, e.code));
      }
    } catch (e) {
      if (mounted) {
        setState(
            () => _errorMessage = FloridaMessages.genericError(context));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() =>
          _errorMessage = FloridaMessages.emailRequired(context));
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.sendPasswordReset(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(FloridaMessages.passwordResetSent(context)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _errorMessage =
            FloridaMessages.getMessageForAuthError(context, e.code));
      }
    } catch (e) {
      if (mounted) {
        setState(
            () => _errorMessage = FloridaMessages.genericError(context));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
