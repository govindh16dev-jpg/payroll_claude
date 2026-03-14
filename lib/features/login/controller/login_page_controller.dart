import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../routes/app_route.dart';
import '../data/repository/login_provider.dart';
import '../domain/model/login_model.dart';

class LoginPageController extends GetxController {
  var loading = Loading.initial.obs;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final loginFormKey = GlobalKey<FormState>();

  LoginProvider get loginProvider => Get.find<LoginProvider>();

  FocusNode usernameFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  RxBool isVisible = true.obs;
  RxBool isRememberMe = true.obs;
  RxBool isLoggedIn = false.obs;
  static const storage = FlutterSecureStorage();

  AppStates get appStateController => Get.put(AppStates());

  @override
  Future<void> onInit() async {
    super.onInit();

    if (!Get.isRegistered<LoginProvider>()) {
      print('⚠️ WARNING: LoginProvider not found!');
      Get.put(LoginProvider(), permanent: true);
    }

    if (kDebugMode) {
      // usernameController.text = 'arun.kumar@democorp.com';
      // passwordController.text = "Smartiapps\$2020";
      usernameController.text = "arun.kumar@democorp.com";
     passwordController.text ="democorp@123";
    }

    isLoggedIn.value = await checkLoggedIn();
  }

  onLoginTap() async {
    bool isFieldValid = loginFormKey.currentState!.validate();

    if (isFieldValid == true) {
      try {
        loading.value = Loading.loading;

        LoginPostData userDetails = LoginPostData(
          email: usernameController.text,
          password: passwordController.text,
        );

        await loginProvider.login(userDetails, isRememberMe.value).then((value) {
          loading.value = Loading.loaded;
          appStateController.userData.value = value;
          Get.offAllNamed(AppRoutes.homePage);
        });
      } on CustomException catch (err) {
        loading.value = Loading.loaded;
        appSnackBar(data: err.message, color: AppColors.appRedColor);
      } catch (error) {
        loading.value = Loading.loaded;
        appSnackBar(
            data: 'Failed: ${error.toString()}',
            color: AppColors.appRedColor
        );
      }
    }
  }

  Future<bool> checkLoggedIn() async {
    bool isLoggedIn = false;
    bool rememberMe = false;
    String? userCredData;

    const storage = FlutterSecureStorage();
    isLoggedIn = await storage.read(key: PrefStrings.accessToken) != null;
    userCredData = await storage.read(key: PrefStrings.userCredentialsData);
    rememberMe = await storage.read(key: PrefStrings.rememberMe) == 'true';
    isRememberMe.value = rememberMe;

    if (userCredData != null && rememberMe && !isLoggedIn) {
      LoginCredentials userData = loginCredentialsFromJson(userCredData);
      usernameController.text = userData.email;
      passwordController.text = userData.password;
    }

    return isLoggedIn;
  }

  @override
  void onClose() {
    // DON'T dispose controllers - causes errors
    print('🗑️ LoginPageController onClose called (not disposing controllers)');
    super.onClose();
  }
}
