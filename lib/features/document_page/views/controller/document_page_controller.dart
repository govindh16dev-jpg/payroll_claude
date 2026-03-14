import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:payroll/features/document_page/data/model/document_model.dart';
import 'package:payroll/routes/app_route.dart';
import 'package:sizer/sizer.dart';
import 'package:path/path.dart';
import '../../../../routes/app_pages.dart';
import '../../../../theme/theme_controller.dart';
import '../../../../util/custom_widgets.dart';
import '../../../login/domain/model/login_model.dart';
import '../../../profile_page/data/model/profile_model.dart';
import '../../data/model/document_dropdown.dart';
import '../../data/repository/document_repository.dart';

class DocumentPageController extends GetxController {
  final GlobalKey<ScaffoldState> drawerKeyProfile = GlobalKey<ScaffoldState>();
  RxString name = ''.obs;
  RxString email = ''.obs;
  final profileFormKey = const GlobalObjectKey<FormState>('profile');
  var imageString = ''.obs;
  var loading = Loading.initial.obs;
  final DocumentRepository documentRepository = Get.put(DocumentRepository());
  var appTheme = Get.find<ThemeController>().currentTheme;
  RxList user = <UserProfile>[].obs;
  UserData userData = UserData();
  ProfileInfoData userDataInfo = ProfileInfoData();
  final appStateController = Get.put(AppStates());
  final ScrollController scrollController = ScrollController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController docNoController = TextEditingController();
  final TextEditingController placeController = TextEditingController();
  final FocusNode nameFocusNode = FocusNode();
  final FocusNode docNoFocusNode = FocusNode();
  final FocusNode placeFocusNode = FocusNode();
  final labelWidth = 30.w;
  final inputWidth = 35.w;
  RxList<DocumentLookUp>? documentTypeDropdown = <DocumentLookUp>[
    DocumentLookUp(
        documentTypeId: "1",
        documentType: "PAN_Card",
        documentCategory: "general")
  ].obs;
  var selectedDocumentType = DocumentLookUp().obs;
  RxString selectedDocumentTypeID = "1".obs;
  Rxn<DateTime?> validFrom = Rxn<DateTime?>();
  Rxn<DateTime?> validTo = Rxn<DateTime?>();
  Rxn<DateTime?> issueDate = Rxn<DateTime?>();
  final ImagePicker _picker = ImagePicker();

  // Enhanced file selection - supports both images and documents
  Rxn<File> selectedImage = Rxn<File>();
  Rxn<File> selectedDocument = Rxn<File>();
  RxnString imagePath = RxnString();
  RxnString imageName = RxnString();
  RxnString documentPath = RxnString();
  RxnString documentName = RxnString();
  RxString selectedFileType = 'none'.obs; // 'image', 'document', or 'none'

  RxList<Document>? docDetails = <Document>[Document()].obs;
  String? documentID;
  RxBool isEditingDoc = false.obs;

  @override
  void onReady() {
    super.onReady();
    final args = Get.arguments;
    if (args != null && args is Map && args.containsKey('docID')) {
      documentID = args['docID'];
      isEditingDoc.value = true;
    } else {
      documentID = null;
      isEditingDoc.value = false;
      debugPrint('docID not passed');
    }
    getUserData()?.then((v) {
      fetchDocumentDropdown();
      if (documentID != null) {
        fetchDocumentDetails();
      }
    });
    placeFocusNode.addListener(() {
      if (placeFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });
      }
    });
    docNoFocusNode.addListener(() {
      if (docNoFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () {
          scrollController.animateTo(
            scrollController.position.minScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });
      }
    });
  }

  void setSelectedDocumentType(String docTypeId) {
    final index = documentTypeDropdown
        ?.indexWhere((doc) => doc.documentTypeId == docTypeId);
    if (index != null && index != -1) {
      selectedDocumentType.value = documentTypeDropdown![index];
    } else {
      if (kDebugMode) {
        print("Document type not found.");
      }
    }
  }

  // Existing image picker methods
  Future<void> pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85, // Compress to reduce file size
      );

      if (image != null) {
        File file = File(image.path);
        selectedImage.value = file;
        selectedDocument.value = null;
        imagePath.value = image.path;
        imageName.value = basename(image.path);
        documentPath.value = null;
        documentName.value = null;
        selectedFileType.value = 'image';

        if (kDebugMode) {
          print('Camera image captured: ${image.name}');
          print('Image path: ${image.path}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error picking from camera: $e');
      }
      appSnackBar(
          data: 'Failed to capture image: ${e.toString()}',
          color: AppColors.appRedColor);
    }
  }

  Future<void> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // Compress to reduce file size
      );

      if (image != null) {
        File file = File(image.path);
        selectedImage.value = file;
        selectedDocument.value = null;
        imagePath.value = image.path;
        imageName.value = basename(image.path);
        documentPath.value = null;
        documentName.value = null;
        selectedFileType.value = 'image';

        if (kDebugMode) {
          print('Gallery image selected: ${image.name}');
          print('Image path: ${image.path}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error picking from gallery: $e');
      }
      appSnackBar(
          data: 'Failed to pick image: ${e.toString()}',
          color: AppColors.appRedColor);
    }
  }

  // Pick document files only (PDF, DOC, DOCX, etc.)
  Future<void> pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'xlsx', 'xls'],
        allowMultiple: false,
        allowCompression: true,
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;

        if (file.path != null) {
          File selectedFile = File(file.path!);
          selectedDocument.value = selectedFile;
          selectedImage.value = null;
          documentPath.value = file.path;
          documentName.value = file.name;
          imagePath.value = null;
          imageName.value = null;
          selectedFileType.value = 'document';

          if (kDebugMode) {
            print('Document selected: ${file.name}');
            print('Document path: ${file.path}');
            print('Document size: ${file.size} bytes');
            print('Document extension: ${file.extension}');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error picking document: $e');
      }
      appSnackBar(
          data: 'Failed to pick document: ${e.toString()}',
          color: AppColors.appRedColor);
    }
  }

  // ✅ UPDATED: Pick any file type with full iOS and Android support
  Future<void> pickAnyFile() async {
    try {
      // Platform-specific handling
      if (Platform.isIOS) {
        await _pickAnyFileIOS();
      } else if (Platform.isAndroid) {
        await _pickAnyFileAndroid();
      } else {
        // Fallback for other platforms
        await _pickAnyFileGeneric();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error picking file: $e');
      }
      appSnackBar(
          data: 'Failed to pick file: ${e.toString()}',
          color: AppColors.appRedColor);
    }
  }

  // iOS-specific file picker with HEIC/HEIF support
  Future<void> _pickAnyFileIOS() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any, // Use 'any' for iOS to access all file types
        allowMultiple: false,
        allowCompression: true,
        withData: false, // Don't load file data into memory
        withReadStream: false,
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;

        if (file.path != null) {
          File selectedFile = File(file.path!);
          String extension = file.extension?.toLowerCase() ?? '';

          // iOS image formats including HEIC/HEIF
          final imageExtensions = [
            'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp',
            'heic', 'heif', // iOS-specific formats
          ];

          if (kDebugMode) {
            print('iOS - File selected: ${file.name}');
            print('iOS - File extension: $extension');
            print('iOS - File path: ${file.path}');
            print('iOS - File size: ${file.size} bytes');
          }

          if (imageExtensions.contains(extension)) {
            // It's an image
            selectedImage.value = selectedFile;
            selectedDocument.value = null;
            imagePath.value = file.path;
            imageName.value = file.name;
            documentPath.value = null;
            documentName.value = null;
            selectedFileType.value = 'image';

            if (kDebugMode) {
              print('iOS - Detected as image file');
            }
          } else {
            // It's a document
            selectedDocument.value = selectedFile;
            selectedImage.value = null;
            documentPath.value = file.path;
            documentName.value = file.name;
            imagePath.value = null;
            imageName.value = null;
            selectedFileType.value = 'document';

            if (kDebugMode) {
              print('iOS - Detected as document file');
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('iOS - Error picking file: $e');
      }
      rethrow;
    }
  }

  // Android-specific file picker
  Future<void> _pickAnyFileAndroid() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          // Image formats
          'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp',
          // Document formats
          'pdf', 'doc', 'docx', 'txt', 'xlsx', 'xls',
        ],
        allowMultiple: false,
        allowCompression: true,
        withData: false,
        withReadStream: false,
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;

        if (file.path != null) {
          File selectedFile = File(file.path!);
          String extension = file.extension?.toLowerCase() ?? '';

          final imageExtensions = [
            'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'
          ];

          if (kDebugMode) {
            print('Android - File selected: ${file.name}');
            print('Android - File extension: $extension');
            print('Android - File path: ${file.path}');
            print('Android - File size: ${file.size} bytes');
          }

          if (imageExtensions.contains(extension)) {
            selectedImage.value = selectedFile;
            selectedDocument.value = null;
            imagePath.value = file.path;
            imageName.value = file.name;
            documentPath.value = null;
            documentName.value = null;
            selectedFileType.value = 'image';

            if (kDebugMode) {
              print('Android - Detected as image file');
            }
          } else {
            selectedDocument.value = selectedFile;
            selectedImage.value = null;
            documentPath.value = file.path;
            documentName.value = file.name;
            imagePath.value = null;
            imageName.value = null;
            selectedFileType.value = 'document';

            if (kDebugMode) {
              print('Android - Detected as document file');
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Android - Error picking file: $e');
      }
      rethrow;
    }
  }

  // Generic file picker for other platforms
  Future<void> _pickAnyFileGeneric() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp',
          'pdf', 'doc', 'docx', 'txt', 'xlsx', 'xls',
        ],
        allowMultiple: false,
        allowCompression: true,
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;

        if (file.path != null) {
          File selectedFile = File(file.path!);
          String extension = file.extension?.toLowerCase() ?? '';

          final imageExtensions = [
            'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'
          ];

          if (imageExtensions.contains(extension)) {
            selectedImage.value = selectedFile;
            selectedDocument.value = null;
            imagePath.value = file.path;
            imageName.value = file.name;
            documentPath.value = null;
            documentName.value = null;
            selectedFileType.value = 'image';
          } else {
            selectedDocument.value = selectedFile;
            selectedImage.value = null;
            documentPath.value = file.path;
            documentName.value = file.name;
            imagePath.value = null;
            imageName.value = null;
            selectedFileType.value = 'document';
          }

          if (kDebugMode) {
            print('Generic - File selected: ${file.name}');
            print('Generic - File type: ${selectedFileType.value}');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Generic - Error picking file: $e');
      }
      rethrow;
    }
  }

  // Clear selected file
  void clearSelectedFile() {
    selectedImage.value = null;
    selectedDocument.value = null;
    imagePath.value = null;
    imageName.value = null;
    documentPath.value = null;
    documentName.value = null;
    selectedFileType.value = 'none';

    if (kDebugMode) {
      print('File selection cleared');
    }
  }

  // Get the currently selected file (image or document)
  File? getSelectedFile() {
    if (selectedFileType.value == 'image') {
      return selectedImage.value;
    } else if (selectedFileType.value == 'document') {
      return selectedDocument.value;
    }
    return null;
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

  fetchDocumentDropdown() async {
    try {
      loading.value = Loading.loading;
      ProfilePostData employeeData = ProfilePostData(
          employeeId: userData.user?.employeeId,
          companyId: userData.user?.companyId,
          clientId: userData.user?.clientId);
      await documentRepository.getDocDropdown(employeeData).then((value) {
        final responseData = jsonDecode(value.body);
        if (responseData['success'] == true) {
          final docData = documentDropdownFromJson(value.body);
          if (docData.data != null) {
            documentTypeDropdown?.value = docData.data!.documentLookUps!;
          }
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

  fetchDocumentDetails() async {
    try {
      loading.value = Loading.loading;
      ProfilePostData employeeData = ProfilePostData(
          employeeId: userData.user?.employeeId,
          companyId: userData.user?.companyId,
          clientId: userData.user?.clientId);
      await documentRepository
          .getDocDetails(employeeData, documentID!)
          .then((value) {
        final responseData = jsonDecode(value.body);
        if (responseData['success'] == true) {
          final docData = documentDetailsFromJson(value.body);
          if (docData.data != null) {
            docDetails?.value = docData.data!.document!;
            var docDetail = docDetails![0];
            setSelectedDocumentType(docDetail.documentTypeId ?? '');
            nameController.text = docDetail.documentName ?? '';
            placeController.text = docDetail.issuePlace ?? "";
            docNoController.text = docDetail.documentValue ?? '';
            issueDate.value = docDetail.issueDate;
            validFrom.value = docDetail.validFrom;
            validTo.value = docDetail.validTo;

            // Determine file type based on extension
            String fileName = docDetail.fileName ?? '';
            String extension = fileName.split('.').last.toLowerCase();

            // Include iOS formats
            if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'heic', 'heif']
                .contains(extension)) {
              imageName.value = fileName;
              selectedFileType.value = 'image';
            } else {
              documentName.value = fileName;
              selectedFileType.value = 'document';
            }
          }
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

  Future<void> openBase64Pdf(String base64String) async {
    try {
      final bytes = base64Decode(base64String);
      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/Doc_${selectedDocumentType.value.documentType}.pdf');
      await file.writeAsBytes(bytes);
      await OpenFile.open(file.path);
    } catch (e) {
      print('Error opening PDF: $e');
    }
  }

  fetchDocPdf() async {
    try {
      loading.value = Loading.loading;
      ProfilePostData employeeData = ProfilePostData(
          employeeId: userData.user?.employeeId,
          companyId: userData.user?.companyId,
          clientId: userData.user?.clientId);
      await documentRepository
          .downloadDoc(employeeData, documentID!)
          .then((value) async {
        loading.value = Loading.loaded;
        final responseData = jsonDecode(value.body);
        if (responseData['success'] == true) {
          String base64Pdf = responseData['data']['doc_url'];
          await openBase64Pdf(base64Pdf);
        }
      });
    } on CustomException catch (err) {
      loading.value = Loading.loaded;
      appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (error) {
      loading.value = Loading.loaded;
      appSnackBar(
          data: 'Failed: ${error.toString()}', color: AppColors.appRedColor);
    }
  }

  submitDocument() async {
    // Validation checks
    if (selectedDocumentType.value.documentTypeId == null) {
      messageAlert('Select Document', "Document Error", true, Get.context);
      return;
    }

    if (nameController.text.isEmpty) {
      messageAlert('Enter Name', "Document Error", true, Get.context);
      return;
    }

    if (docNoController.text.isEmpty) {
      messageAlert('Enter Document Number', "Document Error", true, Get.context);
      return;
    }

    if (issueDate.value == null) {
      messageAlert('Select Issue Date', "Document Error", true, Get.context);
      return;
    }

    if (validFrom.value == null) {
      messageAlert(
          'Select Valid From Date', "Document Error", true, Get.context);
      return;
    }

    if (validTo.value == null) {
      messageAlert('Select Valid To Date', "Document Error", true, Get.context);
      return;
    }

    // File validation: Required for new documents, optional for editing
    if (!isEditingDoc.value && selectedFileType.value == 'none') {
      messageAlert(
          'Select Image or Document', "Document Error", true, Get.context);
      return;
    }

    try {
      loading.value = Loading.loading;
      DocumentPostData docData = DocumentPostData(
        employeeId: userData.user?.employeeId,
        companyId: userData.user?.companyId,
        clientId: userData.user?.clientId,
        documentTypeId: selectedDocumentType.value.documentTypeId,
        documentValue: docNoController.text,
        issueDate: DateFormat('yyyy/MM/dd').format(issueDate.value!),
        documentName: nameController.text,
        issuePlace: placeController.text,
        validFrom: DateFormat('yyyy/MM/dd').format(validFrom.value!),
        validTo: DateFormat('yyyy/MM/dd').format(validTo.value!),
      );

      // Get the selected file (either image or document)
      File? fileToUpload = getSelectedFile();

      if (kDebugMode && fileToUpload != null) {
        print('Uploading file: ${fileToUpload.path}');
        print('File type: ${selectedFileType.value}');
        print('File size: ${await fileToUpload.length()} bytes');
      }

      // Call the repository method with nullable file parameter
      await documentRepository
          .addDocument(docData, fileToUpload)
          .then((value) {
        final responseData = jsonDecode(value.body);
        if (responseData['success'] == true) {
          appSnackBar(data: responseData['message'], color: appTheme.green);
          Get.offNamed(AppRoutes.profilePage);
          loading.value = Loading.loaded;
        }
      });
      update();
    } on CustomException catch (err) {
      loading.value = Loading.loaded;
      appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (error, st) {
      loading.value = Loading.loaded;
      print(st.toString());
      appSnackBar(
          data: 'Failed: ${error.toString()}', color: AppColors.appRedColor);
    }
  }

  Future<void> selectDate(BuildContext context, bool isValidFrom,
      bool isValidTo, bool isIssueDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime(2080),
    );
    if (picked != null) {
      if (isValidFrom) {
        validFrom.value = picked;
      }
      if (isValidTo) {
        validTo.value = picked;
      }
      if (isIssueDate) {
        issueDate.value = picked;
      }
    }
  }

  @override
  void dispose() {
    Get.delete<DocumentPageController>();
    super.dispose();
  }
}
