import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/injection/injection.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/storage_strategy.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../profile/presentation/bloc/profile_state.dart';

class ProfilePhotoUploadPage extends StatefulWidget {
  const ProfilePhotoUploadPage({super.key});

  @override
  State<ProfilePhotoUploadPage> createState() => _ProfilePhotoUploadPageState();
}

// Temporary localization class until AppLocalizations is fixed
class _TempL10n {
  String get profileDetails => 'Profil Detayı';
  String get uploadPhotos => 'Fotoğraflarınızı Yükleyin';
  String get uploadPhotoDescription =>
      'Resources out incentivize\nrelaxation floor loss cc.';
  String get continueButton => 'Devam Et';
  String get pickFromGallery => 'Galeriden Seç';
  String get takePhoto => 'Fotoğraf Çek';
  String get cancelButton => 'İptal';
  String get errorUploading => 'Fotoğraf yüklenirken bir hata oluştu';
  String get photoUploaded => 'Fotoğraf başarıyla yüklendi';
}

class _ProfilePhotoUploadPageState extends State<ProfilePhotoUploadPage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  String _responseMessage = '';
  bool _isUploading = false;
  String? _uploadedPhotoUrl;

  void _showImageSourceActionSheet() {
    final l10n = _TempL10n();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: Text(
                  l10n.pickFromGallery,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white),
                title: Text(
                  l10n.takePhoto,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.white),
                title: Text(
                  l10n.cancelButton,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _responseMessage = 'Fotoğraf seçildi. Yükleme başlatılabilir.';
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
      _responseMessage = 'Fotoğraf yükleniyor...';
    });

    try {
      // First try the regular upload through BLoC
      context.read<ProfileBloc>().add(UploadProfilePhotoEvent(_selectedImage!));

      // Also try the direct API call for debugging
      await _directApiUpload();

      setState(() {
        _isUploading = false;
        _responseMessage =
            'Fotoğraf başarıyla yüklendi! API yanıtı: $_uploadedPhotoUrl';
      });

      // Refresh profile to see if photoUrl is updated
      context.read<ProfileBloc>().add(const RefreshProfileEvent());
    } catch (e) {
      setState(() {
        _isUploading = false;
        _responseMessage = 'Hata: $e';
      });
    }
  }

  Future<void> _directApiUpload() async {
    try {
      // Get the auth token
      final storageManager = getIt<StorageManager>();
      final userToken = await storageManager.getAuthToken();

      if (userToken == null || userToken.isEmpty) {
        setState(() {
          _responseMessage = 'Auth token bulunamadı!';
        });
        return;
      }

      // Create Dio instance
      final dio = Dio(
        BaseOptions(
          baseUrl: AppConstants.baseUrl,
          headers: {'Authorization': userToken, 'Accept': 'application/json'},
        ),
      );

      // Create form data
      final formData = FormData();
      formData.files.add(
        MapEntry(
          'file',
          await MultipartFile.fromFile(
            _selectedImage!.path,
            filename: 'profile_photo.${_selectedImage!.path.split('.').last}',
          ),
        ),
      );

      print(
        '🔄 Sending direct API upload request to ${AppConstants.uploadPhotoEndpoint}',
      );
      print('🔑 Using token: ${userToken.substring(0, 15)}...');

      // Make the request
      final response = await dio.post(
        AppConstants.uploadPhotoEndpoint,
        data: formData,
      );

      print('✅ Direct upload response: ${response.statusCode}');
      print('📄 Response data: ${response.data}');

      if (response.statusCode == 200) {
        String photoUrl = '';
        final responseData = response.data;

        if (responseData is Map) {
          if (responseData.containsKey('data') && responseData['data'] is Map) {
            final data = responseData['data'] as Map<String, dynamic>;
            if (data.containsKey('photoUrl')) {
              photoUrl = data['photoUrl'] as String;
            }
          } else if (responseData.containsKey('photoUrl')) {
            photoUrl = responseData['photoUrl'] as String;
          }
        }

        setState(() {
          _uploadedPhotoUrl = photoUrl;
          _responseMessage = 'Direct API upload successful. URL: $photoUrl';
        });

        // Now check if the profile data includes the photo URL
        _checkProfilePhotoUrl();
      } else {
        setState(() {
          _responseMessage =
              'Direct API upload failed: ${response.statusMessage}';
        });
      }
    } catch (e) {
      setState(() {
        _responseMessage = 'Direct API upload error: $e';
      });
      print('❌ Direct API upload error: $e');
    }
  }

  Future<void> _checkProfilePhotoUrl() async {
    try {
      // Get the auth token
      final storageManager = getIt<StorageManager>();
      final userToken = await storageManager.getAuthToken();

      if (userToken == null || userToken.isEmpty) return;

      // Create Dio instance
      final dio = Dio(
        BaseOptions(
          baseUrl: AppConstants.baseUrl,
          headers: {'Authorization': userToken, 'Accept': 'application/json'},
        ),
      );

      // Get profile data
      final response = await dio.get('/user/profile');

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data;
        if (data.containsKey('data') && data['data'] is Map) {
          final profileData = data['data'] as Map<String, dynamic>;
          final photoUrl = profileData['photoUrl'] as String?;

          print('👤 Profile check - photoUrl from API: "$photoUrl"');

          setState(() {
            _responseMessage +=
                '\nProfile data photoUrl: ${photoUrl ?? "null"}';
          });
        }
      }
    } catch (e) {
      print('❌ Error checking profile: $e');
    }
  }

  void _onContinue() {
    if (_selectedImage != null && !_isUploading) {
      _uploadImage().then((_) {
        // Wait a moment for the upload to complete visually
        Future.delayed(const Duration(seconds: 1), () {
          final navigationService = getIt<NavigationService>();
          navigationService.navigateAndClearAll(AppRoutes.home);
        });
      });
    } else {
      // If no image selected or already uploading, just navigate
      final navigationService = getIt<NavigationService>();
      navigationService.navigateAndClearAll(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    // final l10n = AppLocalizations.of(context)!;
    // Temporary strings until localization is fixed
    final l10n = _TempL10n();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade800.withOpacity(0.4),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text(
          l10n.profileDetails,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is PhotoUploadError) {
            String errorMsg = l10n.errorUploading;
            // Show more specific error message if available
            if (state.message.contains('Unauthorized')) {
              errorMsg = 'Oturum hatası. Lütfen tekrar giriş yapın.';
            } else if (state.message.contains('Invalid file format')) {
              errorMsg =
                  'Geçersiz dosya formatı. Lütfen başka bir fotoğraf seçin.';
            } else if (state.message.contains('Network')) {
              errorMsg =
                  'Ağ hatası. Lütfen internet bağlantınızı kontrol edin.';
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMsg),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Tekrar Dene',
                  textColor: Colors.white,
                  onPressed: () {
                    if (_selectedImage != null) {
                      _uploadImage();
                    }
                  },
                ),
              ),
            );
          } else if (state is ProfileLoaded &&
              !state.isUploadingPhoto &&
              _selectedImage != null) {
            if (state.profile.profilePhotoUrl != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.photoUploaded),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        },
        builder: (context, state) {
          final bool isUploadingFromBloc =
              state is ProfileLoaded && state.isUploadingPhoto;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // Title
                Center(
                  child: Text(
                    l10n.uploadPhotos,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 12),

                // Subtitle
                Center(
                  child: Text(
                    l10n.uploadPhotoDescription,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 48),

                // Photo upload square
                GestureDetector(
                  onTap: _isUploading ? null : _showImageSourceActionSheet,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(16),
                      image:
                          _selectedImage != null && !_isUploading
                              ? DecorationImage(
                                image: FileImage(_selectedImage!),
                                fit: BoxFit.cover,
                              )
                              : null,
                    ),
                    child:
                        _isUploading || isUploadingFromBloc
                            ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                            : _selectedImage == null
                            ? const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 40,
                            )
                            : null,
                  ),
                ),

                // Status text
                if (_selectedImage != null && !_isUploading)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      'Fotoğraf seçildi',
                      style: TextStyle(
                        color: Colors.green.shade300,
                        fontSize: 14,
                      ),
                    ),
                  ),

                // Response message
                if (_responseMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _responseMessage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),

                // Photo URL from profile
                if (state is ProfileLoaded &&
                    state.profile.profilePhotoUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Profile photoUrl: "${state.profile.profilePhotoUrl}"',
                      style: TextStyle(
                        color: Colors.green.shade300,
                        fontSize: 12,
                      ),
                    ),
                  ),

                const Spacer(),

                // Continue button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE50914),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      l10n.continueButton,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
