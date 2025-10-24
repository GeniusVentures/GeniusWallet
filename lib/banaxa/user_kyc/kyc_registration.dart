import 'dart:io';
import 'package:flutter/material.dart';
import 'package:csc_picker_plus/csc_picker_plus.dart';
import 'package:genius_wallet/banaxa/banaxa_api_services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:image_picker/image_picker.dart';

class BanxaKycScreen extends StatefulWidget {
  const BanxaKycScreen({Key? key}) : super(key: key);

  @override
  State<BanxaKycScreen> createState() => _BanxaKycScreenState();
}

class _BanxaKycScreenState extends State<BanxaKycScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Page 1 controllers
  final _formKey1 = GlobalKey<FormState>();
  final _givenNameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  String? _fullMobileNumber;
  final _addressController = TextEditingController();
  final _suburbController = TextEditingController();
  final _postcodeController = TextEditingController();
  String? _countryValue;
  String? _stateValue;
  DateTime? _dob;

  // Page 2 controllers
  final _formKey2 = GlobalKey<FormState>();
  String? _selectedDocType;
  final List<String> _docTypes = [
    'Passport',
    'Driving License',
    'National ID',
  ];

  final _docNumberController = TextEditingController();
  File? _docFrontImage;
  File? _docBackImage;
  File? _selfieImage;

  // General state
  bool _loading = false;
  String? _resultMessage;

  // Helpers
  Future<void> _pickImage(Function(File) onPicked) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      onPicked(File(picked.path));
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(now.year - 100, now.month, now.day),
      lastDate: DateTime(now.year - 18, now.month, now.day),
      helpText: 'Select your date of birth',
    );
    if (picked != null) {
      setState(() {
        _dob = picked;
      });
    }
  }

  Widget _imageUploadTile({
    required String label,
    File? image,
    required VoidCallback onUpload,
    required VoidCallback? onRemove,
  }) {
    return GestureDetector(
      onTap: onUpload,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: image != null ? Colors.green : Colors.grey[300]!,
            width: image != null ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            if (image == null)
              const Icon(Icons.upload_file, color: Colors.blueGrey, size: 30),
            if (image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  image,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                image == null ? 'Upload $label' : 'Uploaded: $label',
                style: TextStyle(
                  color: image == null ? Colors.grey[600] : Colors.green[700],
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
            if (image != null)
              IconButton(
                icon: const Icon(Icons.close, color: Colors.redAccent),
                onPressed: onRemove,
                splashRadius: 18,
                tooltip: "Remove",
              ),
          ],
        ),
      ),
    );
  }

  Future<String> _uploadImage(File? file) async {
    if (file == null) throw Exception('No file selected');
    await Future.delayed(const Duration(seconds: 1));
    // Replace this with your actual upload logic and return the image URL.
    return 'https://dummy.com/${file.path.split('/').last}';
  }

  void _goToPage(int page) {
    setState(() => _currentPage = page);
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onNextPage1() {
    if (_formKey1.currentState?.validate() != true) return;
    if (_countryValue == null || _stateValue == null) {
      setState(() => _resultMessage = "Select country and state.");
      return;
    }
    if (_dob == null) {
      setState(() => _resultMessage = "Select date of birth.");
      return;
    }
    setState(() => _resultMessage = null);
    _goToPage(1);
  }

  void _onNextPage2() {
    if (_formKey2.currentState?.validate() != true) return;
    if (_selectedDocType == null) {
      setState(() => _resultMessage = "Select document type.");
      return;
    }
    if (_selectedDocType == 'Driving License') {
      if (_docNumberController.text.isEmpty) {
        setState(() => _resultMessage = "Enter license number.");
        return;
      }
      if (_docFrontImage == null || _docBackImage == null) {
        setState(
            () => _resultMessage = "Upload front & back images of license.");
        return;
      }
    } else if (_selectedDocType == 'Passport' ||
        _selectedDocType == 'National ID') {
      if (_docNumberController.text.isEmpty) {
        setState(() => _resultMessage = "Enter document number.");
        return;
      }
      if (_docFrontImage == null) {
        setState(() => _resultMessage = "Upload document image.");
        return;
      }
    }
    if (_selfieImage == null) {
      setState(() => _resultMessage = "Upload a selfie image.");
      return;
    }
    setState(() => _resultMessage = null);
    _submitKYC();
  }

  Future<bool> _showBanxaConsentDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('KYC Data Sharing'),
            content: const Text(
              'Your personal details and KYC documents will be securely shared with Banxa. '
              'Banxa may contact you to collect additional documents if required by regulations.',
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              ElevatedButton(
                child: const Text('I Understand & Agree'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _submitKYC() async {
    final consented = await _showBanxaConsentDialog(context);
    if (!consented) return;
    setState(() => _loading = true);

    try {
      // Upload images (simulate upload, replace with your upload logic)
      String? frontUrl;
      String? backUrl;
      String? selfieUrl;

      if (_docFrontImage != null) frontUrl = await _uploadImage(_docFrontImage);
      if (_docBackImage != null) backUrl = await _uploadImage(_docBackImage);
      if (_selfieImage != null) selfieUrl = await _uploadImage(_selfieImage);

      // Build identity_documents
      final List<Map<String, dynamic>> identityDocuments = [];

      if (_selectedDocType == 'Driving License') {
        identityDocuments.add({
          "type": "DRIVING_LICENSE",
          "data": {"number": _docNumberController.text.trim()},
          "images": [
            {"link": frontUrl},
            {"link": backUrl},
          ],
        });
      } else if (_selectedDocType == 'Passport') {
        identityDocuments.add({
          "type": "PASSPORT",
          "data": {"number": _docNumberController.text.trim()},
          "images": [
            {"link": frontUrl}
          ],
        });
      } else if (_selectedDocType == 'National ID') {
        identityDocuments.add({
          "type": "NATIONAL_ID",
          "data": {"number": _docNumberController.text.trim()},
          "images": [
            {"link": frontUrl}
          ],
        });
      }

      // Always attach a selfie document
      if (selfieUrl != null) {
        identityDocuments.add({
          "type": "SELFIE",
          "images": [
            {"link": selfieUrl}
          ],
        });
      }

      final kycData = {
        "account_reference": DateTime.now().millisecondsSinceEpoch.toString(),
        "email": _emailController.text.trim(),
        "mobile_number": _fullMobileNumber,
        "customer_identity": {
          "given_name": _givenNameController.text.trim(),
          "surname": _surnameController.text.trim(),
          "dob": _dob!.toIso8601String().split("T")[0],
          "residential_address": {
            "address_line_1": _addressController.text.trim(),
            "suburb": _suburbController.text.trim(),
            "post_code": _postcodeController.text.trim(),
            "state": _stateValue,
            "country": _countryValue,
          }
        },
        "identity_documents": identityDocuments,
      };

      final response = await BanxaApiService.submitKYC(kycData);

      setState(() {
        _loading = false;
        if (response != null) {
          _resultMessage = '✅ KYC submitted!\n'
              'Account ID: ${response.accountId}\n'
              'Reference: ${response.accountReference}';
        } else {
          _resultMessage = '❌ Submission failed. See logs.';
        }
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _resultMessage = '❌ Error: $e';
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _givenNameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _suburbController.dispose();
    _postcodeController.dispose();
    _docNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC Verification'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // PAGE 1: Personal Info
              SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  key: _formKey1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Given Name',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _givenNameController,
                        decoration: const InputDecoration(
                          hintText: 'Enter your given name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      const Text('Surname',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _surnameController,
                        decoration: const InputDecoration(
                          hintText: 'Enter your surname',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      const Text('Date of Birth',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: () => _pickDate(context),
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              hintText: 'YYYY-MM-DD',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            controller: TextEditingController(
                              text: _dob != null
                                  ? "${_dob!.year}-${_dob!.month.toString().padLeft(2, '0')}-${_dob!.day.toString().padLeft(2, '0')}"
                                  : "",
                            ),
                            validator: (v) =>
                                _dob == null ? 'Select date of birth' : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Email',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          hintText: 'Enter your email',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v == null || v.isEmpty
                            ? 'Required'
                            : (!RegExp(r"^[^@]+@[^@]+\.[^@]+").hasMatch(v)
                                ? "Invalid email"
                                : null),
                      ),
                      const SizedBox(height: 16),
                      const Text('Mobile Number',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 5),
                      IntlPhoneField(
                        decoration: const InputDecoration(
                          hintText: 'Enter your mobile number',
                          border: OutlineInputBorder(),
                        ),
                        initialCountryCode: 'PK',
                        onChanged: (phone) {
                          _fullMobileNumber = phone.completeNumber;
                        },
                        validator: (phone) =>
                            (phone == null || phone.completeNumber.isEmpty)
                                ? 'Required'
                                : null,
                      ),
                      const SizedBox(height: 16),
                      const Text('Address Line 1',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          hintText: 'Enter your address',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      const Text('Suburb',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _suburbController,
                        decoration: const InputDecoration(
                          hintText: 'Enter your suburb',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      const Text('Postcode',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _postcodeController,
                        decoration: const InputDecoration(
                          hintText: 'Enter your postcode',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      const Text('Country & State',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 5),
                      CSCPickerPlus(
                        dropdownDecoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          border: Border.all(
                            color: Colors.white,
                            width: 1,
                          ),
                        ),
                        showCities: false,
                        flagState: CountryFlag.ENABLE,
                        countryStateLanguage:
                            CountryStateLanguage.englishOrNative,
                        onCountryChanged: (value) {
                          setState(() => _countryValue = value);
                        },
                        onStateChanged: (value) {
                          setState(() => _stateValue = value ?? '');
                        },
                        onCityChanged: (_) {},
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          if (_currentPage != 0)
                            TextButton(
                              onPressed: () => _goToPage(_currentPage - 1),
                              child: const Text('Back'),
                            ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: _onNextPage1,
                            child: const Text('Next'),
                          ),
                        ],
                      ),
                      if (_resultMessage != null && _currentPage == 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            _resultMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // PAGE 2: Documents
              SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  key: _formKey2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedDocType,
                        items: _docTypes
                            .map((type) => DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(type),
                                ))
                            .toList(),
                        onChanged: (val) => setState(() {
                          _selectedDocType = val;
                          _docFrontImage = null;
                          _docBackImage = null;
                          _selfieImage = null;
                          _docNumberController.clear();
                        }),
                        decoration: const InputDecoration(
                          labelText: 'Select Document Type',
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 18),
                      if (_selectedDocType != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: TextFormField(
                            controller: _docNumberController,
                            decoration: InputDecoration(
                              labelText: '${_selectedDocType!} Number',
                              hintText: 'Enter your document number',
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Required' : null,
                          ),
                        ),
                      if (_selectedDocType == 'Driving License')
                        Column(
                          children: [
                            _imageUploadTile(
                              label: "License Front",
                              image: _docFrontImage,
                              onUpload: () => _pickImage((file) {
                                setState(() => _docFrontImage = file);
                              }),
                              onRemove: _docFrontImage != null
                                  ? () => setState(() => _docFrontImage = null)
                                  : null,
                            ),
                            _imageUploadTile(
                              label: "License Back",
                              image: _docBackImage,
                              onUpload: () => _pickImage((file) {
                                setState(() => _docBackImage = file);
                              }),
                              onRemove: _docBackImage != null
                                  ? () => setState(() => _docBackImage = null)
                                  : null,
                            ),
                          ],
                        ),
                      if (_selectedDocType == 'Passport')
                        _imageUploadTile(
                          label: "Passport Image",
                          image: _docFrontImage,
                          onUpload: () => _pickImage((file) {
                            setState(() => _docFrontImage = file);
                          }),
                          onRemove: _docFrontImage != null
                              ? () => setState(() => _docFrontImage = null)
                              : null,
                        ),
                      if (_selectedDocType == 'National ID')
                        Column(
                          children: [
                            _imageUploadTile(
                              label: "ID Front",
                              image: _docFrontImage,
                              onUpload: () => _pickImage((file) {
                                setState(() => _docFrontImage = file);
                              }),
                              onRemove: _docFrontImage != null
                                  ? () => setState(() => _docFrontImage = null)
                                  : null,
                            ),
                            _imageUploadTile(
                              label: "ID Back",
                              image: _docBackImage,
                              onUpload: () => _pickImage((file) {
                                setState(() => _docBackImage = file);
                              }),
                              onRemove: _docBackImage != null
                                  ? () => setState(() => _docBackImage = null)
                                  : null,
                            ),
                          ],
                        ),
                      const SizedBox(height: 18),
                      const Text(
                        'Selfie (Required)',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      _imageUploadTile(
                        label: "Selfie",
                        image: _selfieImage,
                        onUpload: () => _pickImage((file) {
                          setState(() => _selfieImage = file);
                        }),
                        onRemove: _selfieImage != null
                            ? () => setState(() => _selfieImage = null)
                            : null,
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => _goToPage(_currentPage - 1),
                            child: const Text('Back'),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: _onNextPage2,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(120, 48),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Text('Submit KYC'),
                          ),
                        ],
                      ),
                      if (_resultMessage != null && _currentPage == 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            _resultMessage!,
                            style: TextStyle(
                                color: _resultMessage!.startsWith('✅')
                                    ? Colors.green
                                    : Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
