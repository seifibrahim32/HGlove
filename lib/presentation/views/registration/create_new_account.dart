import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_diagnosis/presentation/bloc/cubit_manager.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../../controllers/create_account_controllers/firebase_controllers.dart';
import '../../../controllers/device_controllers.dart';
import '../../../controllers/files/file_controllers.dart';
import '../../../controllers/reusable_components.dart';
import '../../bloc/bloc_states.dart';

class CreateNewAccount extends StatefulWidget {
  const CreateNewAccount({super.key});

  @override
  State<CreateNewAccount> createState() => _CreateNewAccountState();
}

class _CreateNewAccountState extends State<CreateNewAccount> {
  final _registerKey = GlobalKey<FormState>();

  final List<TextEditingController> _phoneNumberControllers = [];

  late TextEditingController? email,
      confirmEmail,
      newPassword,
      confirmPassword,
      firstName,
      lastName;

  @override
  void initState() {
    super.initState();
    firstName = TextEditingController();
    lastName = TextEditingController();
    email = TextEditingController();
    newPassword = TextEditingController();
    confirmPassword = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => TermsCubit()),
        BlocProvider(create: (context) => PhotoRegistrationCubit()),
      ],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _registerKey,
          child: BlocBuilder<PhotoRegistrationCubit, ImageRegisterScreenStates>(
              builder: (context, photoState) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 25),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Register with HGlove',
                          style: TextStyle(
                              fontSize: 25,
                              fontFamily: "SF",
                              color: Colors.white,
                              fontWeight: FontWeight.normal)),
                    ],
                  ),
                  const SizedBox(height: 34),
                  //Image profile
                  photoState is ImageUnpickedState
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(64.0),
                          child: Image.asset('assets/blank-profile.webp',
                              errorBuilder: (ctx, object, index) {
                            return const CircularProgressIndicator();
                          }, scale: 10.0))
                      : photoState is ImagePickedState
                          ? SizedBox(
                              width: 100,
                              height: 100,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(64.0),
                                  child: kIsWeb
                                      ? Image.memory(photoState.fileBytes!,
                                          errorBuilder: (ctx, object, index) {
                                          return const CircularProgressIndicator();
                                        }, scale: 4.0)
                                      : Image.file(File(photoState.path),
                                          errorBuilder: (ctx, object, index) {
                                          return const CircularProgressIndicator();
                                        }, scale: 4.0)),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(64.0),
                              child: Image.asset('assets/blank-profile.webp',
                                  errorBuilder: (ctx, object, index) {
                                return const CircularProgressIndicator();
                              }, scale: 10.0)),
                  const SizedBox(height: 16),
                  //First Name
                  Container(
                    decoration: const BoxDecoration(
                        color: Color(0xFF575555),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12))),
                    padding: const EdgeInsets.only(left: 20.0),
                    child: textFormField(
                        suffixIcon: null,
                        hintText: "First Name",
                        kind: TextInputType.name,
                        context: context,
                        type: "register",
                        controller: firstName,
                        isHidden: false),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 1,
                    decoration: const BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(0),
                            topRight: Radius.circular(0))),
                  ),
                  //Last Name
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF575555),
                    ),
                    padding: const EdgeInsets.only(left: 20.0),
                    child: textFormField(
                        suffixIcon: null,
                        hintText: "Last Name",
                        kind: TextInputType.name,
                        context: context,
                        type: "register",
                        controller: lastName,
                        isHidden: false),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 1,
                    decoration: const BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12))),
                  ),
                  //Email
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF575555),
                    ),
                    padding: const EdgeInsets.only(left: 20.0),
                    child: textFormField(
                        suffixIcon: null,
                        hintText: "Email",
                        kind: TextInputType.emailAddress,
                        context: context,
                        type: "register",
                        controller: email,
                        isHidden: false),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 1,
                    decoration: const BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12))),
                  ),
                  //Password
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF575555),
                    ),
                    padding: const EdgeInsets.only(left: 20.0),
                    child: textFormField(
                        hintText: "Password",
                        kind: TextInputType.visiblePassword,
                        context: context,
                        type: "register",
                        controller: newPassword,
                        isHidden: true,
                        suffixIcon: null),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 1,
                    decoration: const BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12))),
                  ),
                  //Confirm Password
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF575555),
                    ),
                    padding: const EdgeInsets.only(left: 20.0),
                    child: textFormField(
                        hintText: "Confirm Password",
                        kind: TextInputType.visiblePassword,
                        context: context,
                        type: "register",
                        controller: confirmPassword,
                        isHidden: true,
                        suffixIcon: null),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 1,
                    decoration: const BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12))),
                  ),
                  //Add multi-emergency numbers
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF575555),
                    ),
                    padding: const EdgeInsets.only(
                        left: 20.0, bottom: 10, top: 10, right: 20.0),
                    child: Row(children: [
                      const Expanded(
                        flex: 1,
                        child: Text(
                          'Add emergency number..',
                          style: TextStyle(
                              fontFamily: "SF",
                              color: Colors.white,
                              fontSize: 13),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _phoneNumberControllers
                                .add(TextEditingController());
                          });
                        },
                        child: const Icon(Icons.add),
                      )
                    ]),
                  ),
                  //Emergency number
                  ..._phoneNumberControllers.map((controller) =>
                      InternationalPhoneNumberInput(
                        validator: (number) {
                          if (number!.length < 8) {
                            return 'Enter emergency number';
                          }
                          return null;
                        },
                        selectorTextStyle: const TextStyle(
                          color: Colors.white,
                        ),
                        textStyle: Theme.of(context).textTheme.headlineSmall,
                        countrySelectorScrollControlled: true,
                        onInputChanged: (PhoneNumber number) {
                          log(number.phoneNumber!);
                        },
                        spaceBetweenSelectorAndTextField: 12,
                        selectorConfig: const SelectorConfig(
                          selectorType: PhoneInputSelectorType.DIALOG,
                          leadingPadding: 28,
                          setSelectorButtonAsPrefixIcon: true,
                        ),
                        ignoreBlank: true,
                        formatInput: false,
                        textFieldController: controller,
                        inputBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.all(Radius.circular(0.0)),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        onSaved: (PhoneNumber number) {
                          log('On Saved: $number');
                        },
                        inputDecoration: const InputDecoration(
                            alignLabelWithHint: true,
                            isCollapsed: true,
                            hintText: "Emergency number",
                            hintStyle: TextStyle(color: Colors.white),
                            fillColor: Color(0xFF575555),
                            filled: true),
                      )),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 1,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                    ),
                  ),
                  //Upload an image
                  Container(
                    decoration: const BoxDecoration(
                        color: Color(0xFF575555),
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(12),
                            bottomLeft: Radius.circular(12))),
                    padding: const EdgeInsets.only(
                        left: 20.0, bottom: 10, top: 10, right: 20.0),
                    child: Row(children: [
                      const Expanded(
                        flex: 1,
                        child: Text(
                          'Upload an image',
                          style: TextStyle(
                              fontFamily: "SF",
                              color: Colors.white,
                              fontSize: 16),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          filePicker(context).then((filePath) {
                            BlocProvider.of<PhotoRegistrationCubit>(context)
                                .pick(filePath);
                          });
                        },
                        child: const Icon(Icons.add),
                      )
                    ]),
                  ),
                  const SizedBox(height: 14),
                  //Terms and Conditions + Create Account button
                  BlocBuilder<TermsCubit, CheckboxTermsStates>(
                    builder:
                        (BuildContext context, CheckboxTermsStates state) =>
                            Column(
                      children: [
                        Row(
                          children: [
                            Checkbox(
                                value: state is CheckboxTermsStatesClicked
                                    ? true
                                    : false,
                                onChanged: (_) {
                                  state is CheckboxTermsStatesUnClicked
                                      ? context.read<TermsCubit>().check()
                                      : context.read<TermsCubit>().uncheck();
                                }),
                            const Text('I agree to',
                                style: TextStyle(color: Colors.white)),
                            TextButton(
                              onPressed: () {
                                showAlertDialog(context);
                              },
                              child: const Text('terms and conditions',
                                  style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Colors.blue)),
                            )
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Register Button
                        state is CheckboxTermsStatesClicked
                            ? GestureDetector(
                                onTap: () {
                                  if (_registerKey.currentState!.validate() &&
                                      confirmPassword?.text ==
                                          newPassword?.text) {
                                    hideKeyboard(context);
                                    if (photoState is ImagePickedState) {
                                      File file = File(photoState.path);
                                      createUserToFirebase(
                                          email: email,
                                          lastName: lastName,
                                          firstName: firstName,
                                          stateImage: photoState,
                                          phoneNumbersControllers:
                                              _phoneNumberControllers,
                                          password: newPassword,
                                          file: file,
                                          context: context);
                                    } else {
                                      createUserToFirebase(
                                          email: email,
                                          lastName: lastName,
                                          firstName: firstName,
                                          stateImage: photoState,
                                          phoneNumbersControllers:
                                              _phoneNumberControllers,
                                          password: newPassword,
                                          context: context);
                                    }
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: const Color(0xBF3A94DB),
                                      border:
                                          Border.all(color: Colors.transparent),
                                      borderRadius: BorderRadius.circular(7)),
                                  height: 39,
                                  child: const Center(
                                    child: Text(
                                      'Create an account',
                                      style: TextStyle(
                                          fontFamily: "SF",
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                    color: const Color(0xAF575A5A),
                                    border:
                                        Border.all(color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(7)),
                                height: 39,
                                child: const Center(
                                  child: Text(
                                    'Create an account',
                                    style: TextStyle(
                                        fontFamily: "SF", color: Colors.white),
                                  ),
                                ),
                              )
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Login screen
                  GestureDetector(
                    onTap: () {
                      context.read<RegistrationCubit>().gotoLoginScreen();
                    },
                    child: const Text('Already have an account? Go back.',
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: "SFn",
                            color: Color(0xFF28D4D4),
                            fontWeight: FontWeight.normal)),
                  )
                ]);
          }),
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context) async {
    // Create AlertDialog
    AlertDialog alert = const AlertDialog(
      title: Text('Privacy and Policy'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Text('What Type of Patient Choice Exists Under HIPAA?',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w700)),
            Text(
                "Most health care providers must follow the"
                " Health Insurance Portability and Accountability Act (HIPAA) Priv"
                "acy Rule (Privacy Rule), a federal privacy law that sets a base"
                "line of protection for certain individ"
                "ually identifiable health information (“health information”)"
                "The Privacy Rule generally permits, but does not require, cov"
                "ered health care providers to give patients the choice as "
                "to whether their health information may be disclosed to ot"
                "hers for certain key purposes.  These key purposes include"
                " treatment, payment, and health care operations.",
                style: TextStyle(color: Colors.black)),
            Text(
                'How Can Patient Choice Be Implemented in Electronic '
                'Health Information Exchange (eHIE)?',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w700)),
            Text(
                "\nWhile it is not required, health care providers may decide to"
                " offer patients a choice as to whether their health informatio"
                "n may be exchanged electronically, either directly or through "
                "a Health Information Exchange Organization (HIE). That is, the"
                "y may offer an “opt-in” or “opt-out” policy [PD"
                "F - 713 KB] or a combination.",
                style: TextStyle(color: Colors.black)),
            Text(
                '\nFederal, State, and Organization Resources ab'
                'out Consent, Personal Choice, and Confidentiality',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w700)),
            Text(
                "We encourage providers, HIEs, and other health IT implementers to "
                "seek expert advice when evaluating these resources, as privacy laws "
                "and policies continually evolve.  The resources are not intended to s"
                "erve as legal advice or offer recommendations"
                " based on an implementer’s specific circumstances.",
                style: TextStyle(color: Colors.black)),
          ],
        ),
      ),
    );

    // show the dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
