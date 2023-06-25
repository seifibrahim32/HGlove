import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_diagnosis/presentation/views/account_creation_success/welcome_screen.dart';

import '../../../controllers/device_controllers.dart';
import '../../../controllers/network/firebase_dio_calls.dart';
import '../../../controllers/reusable_components.dart';
import '../../bloc/bloc_states.dart';
import '../../bloc/cubit_manager.dart';
import '../dashboard_screen.dart';
import '../snackbar.dart';
import 'create_new_account.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool isHidden = false;

  final GlobalKey<FormState> _loginKey = GlobalKey<FormState>();

  late TextEditingController? email, password;

  @override
  void initState() {
    super.initState();
    email = TextEditingController();
    password = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/dashboard': (_) => const DashboardScreen(),
        '/welcome': (_) => const WelcomeScreen(),
        '/log-out': (_) {
          return const LoginScreen();
        },
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: Theme
            .of(context)
            .textTheme
            .copyWith(
            headlineSmall: const TextStyle(fontSize: 16, color: Colors.white)),
      ),
      home: Scaffold(
          backgroundColor: const Color(0xFF312F2F),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: BlocProvider(
                create: (BuildContext context) => RegistrationCubit(),
                child: BlocBuilder<RegistrationCubit, ScreenStates>(
                    builder: (context, state) {
                      if (state is LoadingScreenState) {
                        BlocProvider.of<RegistrationCubit>(context)
                            .connectInternet();
                        return const Center(child: CircularProgressIndicator());
                      }
                      else if (state is LoginScreenState) {
                        return Form(
                          key: _loginKey,
                          child: SingleChildScrollView(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 65),
                                  const Wrap(
                                    children: [
                                      Text(
                                        'HGlove',
                                        //'${AppLocalizations.of(context)!.appTitle}....',
                                        style: TextStyle(
                                            fontFamily: "SF",
                                            fontSize: 24,
                                            color: Colors.white,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 60),
                                  const Row(
                                    children: [
                                      Padding(
                                        padding:
                                        EdgeInsets.only(left: 8.0, bottom: 5),
                                        child: Text('Sign in to your account',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'Lora',
                                                color: Color(0xFFA1A0A0),
                                                fontWeight: FontWeight.normal)),
                                      ),
                                    ],
                                  ),
                                  //Email
                                  Container(
                                    decoration: const BoxDecoration(
                                        color: Color(0xFF575555),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                        )),
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: textFormField(
                                        suffixIcon: null,
                                        hintText: "Email",
                                        kind: TextInputType.emailAddress,
                                        context: context,
                                        type: "login",
                                        controller: email,
                                        isHidden: false),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFB4ADAD),
                                      border: Border.all(
                                          color: Colors.transparent),
                                    ),
                                    height: 1,
                                  ),
                                  // Password
                                  Container(
                                    decoration: const BoxDecoration(
                                        color: Color(0xFF575555),
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                        )),
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: textFormField(
                                        suffixIcon: IconButton(
                                          icon: Padding(
                                            padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                            child: Icon(
                                              isHidden == false
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          onPressed: () =>
                                              setState(() =>
                                              isHidden = !isHidden),
                                        ),
                                        hintText: "Password",
                                        kind: TextInputType.visiblePassword,
                                        context: context,
                                        type: "login",
                                        controller: password,
                                        isHidden: isHidden),
                                  ),
                                  const SizedBox(height: 13),
                                  // Authorize access
                                  GestureDetector(
                                    onTap: () {
                                      if (_loginKey.currentState!.validate()) {
                                        hideKeyboard(context);
                                        try {
                                          FirebaseAPI.signInWithEmailAndPassword(
                                            email: email!.text,
                                            password: password!.text,
                                            context: context,
                                          );
                                          showSnackBar(context,
                                              "Successfully signed",
                                              Colors.green);
                                        } on Exception catch (error) {
                                          showSnackBar(
                                              context, error.toString(),
                                              Colors.green);
                                        }
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: const Color(0xFF3A94DB),
                                          border:
                                          Border.all(color: Colors.transparent),
                                          borderRadius: BorderRadius.circular(
                                              7)),
                                      height: 39,
                                      width: 400,
                                      child: const Center(
                                        child: Text(
                                          'LOGIN',
                                          style: TextStyle(
                                              fontFamily: "Lora",
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 34,
                                  ),
                                  // Login Facebook button for non-web apps
                                  !kIsWeb
                                      ? GestureDetector(
                                    onTap: () {
                                      try {
                                        FirebaseAPI.signInWithFacebook(context);
                                      } on Resource catch (e) {
                                        log(e.status.name);
                                        showSnackBar(context, e.status.name,
                                            Colors.red);
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: const Color(0xFF1316C6),
                                          border: Border.all(
                                              color: Colors.transparent),
                                          borderRadius:
                                          BorderRadius.circular(7)),
                                      height: 39,
                                      width: 400,
                                      child: const Center(
                                        child: Text(
                                          'LOGIN WITH FACEBOOK',
                                          style: TextStyle(
                                              fontFamily: "Lora",
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  )
                                      : const SizedBox(
                                    height: 0,
                                  ),
                                  const SizedBox(
                                    height: 14,
                                  ),
                                  // Login Google button
                                  GestureDetector(
                                    onTap: () {
                                      try {
                                        FirebaseAPI.googleSignIn(context);
                                      } on Exception catch (e) {
                                        log(e.toString());
                                        showSnackBar(
                                            context, 'Cancelled', Colors.red);
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: const Color(0xFFC1420A),
                                          border:
                                          Border.all(color: Colors.transparent),
                                          borderRadius: BorderRadius.circular(
                                              7)),
                                      height: 39,
                                      width: 400,
                                      child: const Center(
                                        child: Text(
                                          'LOGIN WITH GOOGLE',
                                          style: TextStyle(
                                              fontFamily: "Lora",
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 33),
                                  // New to HF ? Create an account
                                  const Text('New to HF ?',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: "SecularOne",
                                          color: Color(0xFFA1A0A0),
                                          fontWeight: FontWeight.normal)),
                                  // Register account
                                  GestureDetector(
                                    onTap: () {
                                      context
                                          .read<RegistrationCubit>()
                                          .gotoRegisterScreen();
                                    },
                                    child: const Text("Create an account.",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: "SFn",
                                            color: Color(0xFF28D4D4),
                                            fontWeight: FontWeight.normal)),
                                  )
                                ]),
                          ),
                        );
                      } else if (state is CreateNewAccountScreenState) {
                        return const SingleChildScrollView(
                          child: CreateNewAccount(),
                        );
                      }
                      return Container();
                    })),
          )),
    );
  }
}
