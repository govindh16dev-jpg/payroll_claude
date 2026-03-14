import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:sizer/sizer.dart';

import '../../../../routes/app_pages.dart';
import '../../../../theme/theme_controller.dart';
import '../../../login/domain/model/login_model.dart';
import '../../data/model/profile_model.dart';
import '../../data/repository/profile_repository.dart';

class ProfilePageController extends GetxController {
  final GlobalKey<ScaffoldState> drawerKeyProfile = GlobalKey<ScaffoldState>();
  final ProfileRepository repository = Get.put(ProfileRepository());
  RxString name = ''.obs;
  RxString email = ''.obs;
  final profileFormKey = const GlobalObjectKey<FormState>('profile');
  var imageString = ''.obs;
  var loading = Loading.initial.obs;
  final ProfileRepository profileRepository = Get.put(ProfileRepository());
  RxString profileImage = "".obs;
  final Rx<File?> imageSelected = Rx<File?>(null);
  RxList user = <UserProfile>[].obs;
  UserData userData = UserData();
  ProfileInfoData userDataInfo = ProfileInfoData();
  final appStateController = Get.put(AppStates());
  Map<String, List<Map<String, dynamic>>> bannerData = {};
  Rxn<File> selectedImage = Rxn<File>();
  RxnString imagePath = RxnString();
  RxnString imageName = RxnString();
  @override
  void onReady() {
    getUserData()?.then((v) {
      fetchProfileData();
    });

    super.onReady();
  }

  final ImagePicker _picker = ImagePicker();

  void showImageSourceBottomSheet(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(
                Icons.camera_enhance,
                color: appTheme.appThemeLight,
                size: 22.sp,
              ),
              title: const Text('Camera'),
              onTap: () {
                Get.back();
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.cloud_upload_outlined,
                color: appTheme.appThemeLight,
                size: 22.sp,
              ),
              title: const Text('Gallery'),
              onTap: () {
                Get.back();
                pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickImage(ImageSource source) async {
    final XFile? pickedImage = await _picker.pickImage(source: source);

    if (pickedImage != null) {
      File file = File(pickedImage.path);
      selectedImage.value = file;
      imagePath.value = pickedImage.path;
      imageName.value = basename(pickedImage.path);
      uploadImage();
    }
  }

  uploadImage() async {
    try {
      loading.value = Loading.loading;
      ProfilePostData empData = ProfilePostData(
          employeeId: userData.user?.employeeId,
          companyId: userData.user?.companyId,
          clientId: userData.user?.clientId);
      await profileRepository
          .updateProfileImage(empData, selectedImage.value!)
          .then((value) {
        final responseData = jsonDecode(value.body);
        if (responseData['success'] == true) {
          appSnackBar(data: responseData['message'], color: Colors.green);
          fetchProfileData();
          loading.value = Loading.loaded;
        }
      });
      update();
    } on CustomException catch (err) {
      loading.value = Loading.loaded;
      appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (error) {
      loading.value = Loading.loaded;
      appSnackBar(
          data: 'Failed: ${error.toString()}', color: AppColors.appRedColor);
    }
  }

  fetchProfileData() async {
    try {
      loading.value = Loading.loading;
      ProfilePostData employeeData = ProfilePostData(
          employeeId: userData.user?.employeeId,
          companyId: userData.user?.companyId,
          clientId: userData.user?.clientId);
      await profileRepository.getUserProfile(employeeData).then((value) {
        loading.value = Loading.loaded;
        appStateController.userProfileData.value = value[0];

        var userInfo = value[0].userData;
        Map<String, List<Map<String, dynamic>>> groupedData = {};
        // Group items by tab_name
        userInfo.forEach((key, value) {
          if (value is List) {
            for (var item in value) {
              if (item is Map<String, dynamic> &&
                  item.containsKey('tab_name')) {
                String tabName = item['tab_name']; // Get tab_name
                if (!groupedData.containsKey(tabName)) {
                  groupedData[tabName] = [];
                }
                groupedData[tabName]!.add(item);
              }
            }
          }
        });
        user.value = value;
        bannerData = groupedData;
        user.value = value;
      });
      update();
    } on CustomException catch (err) {
      loading.value = Loading.loaded;
      appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (error) {
      loading.value = Loading.loaded;
      appSnackBar(
          data: 'Failed: ${error.toString()}', color: AppColors.appRedColor);
    }
  }

  removeDocument(documentID) async {
    var appTheme = Get.find<ThemeController>().currentTheme;
    try {
      loading.value = Loading.loading;
      ProfilePostData employeeData = ProfilePostData(
          employeeId: userData.user?.employeeId,
          companyId: userData.user?.companyId,
          clientId: userData.user?.clientId);
      await profileRepository
          .removeDocument(employeeData, documentID!)
          .then((value) {
        final responseData = jsonDecode(value.body);
        if (responseData['success'] == true) {
          appSnackBar(data: responseData['message'], color: appTheme.green);
          loading.value = Loading.loaded;
          fetchProfileData();
        }
      });
      update();
    } on CustomException catch (err) {
      loading.value = Loading.loaded;
      appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (error) {
      loading.value = Loading.loaded;
      appSnackBar(
          data: 'Failed: ${error.toString()}', color: AppColors.appRedColor);
    }
  }

  Future<UserData>? getUserData() async {
    const storage = FlutterSecureStorage();
    final String? userDataLocalStr =
        await storage.read(key: PrefStrings.userData);

    if (userDataLocalStr != null) {
      final UserData userDataLocal = userDataFromJson(userDataLocalStr);
      userData = userDataLocal;
      name.value = userData.user!.name!;
      email.value = userData.user!.email!;
    }

    return userData;
  }

  @override
  void dispose() {
    Get.delete<ProfilePageController>();
    super.dispose();
  }
}
