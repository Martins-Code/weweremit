import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../app_theme.dart';
import '../models/dealer.dart';
import 'home_screen.dart';

class DealerSignupScreen extends StatefulWidget {
  const DealerSignupScreen({super.key});

  static const routeName = '/dealer-signup';

  @override
  State<DealerSignupScreen> createState() => _DealerSignupScreenState();
}

class _DealerSignupScreenState extends State<DealerSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passportNumberController = TextEditingController();
  final _rateAUDtoNGNController = TextEditingController();
  final _rateNGNtoAUDController = TextEditingController();
  final _minLimitController = TextEditingController();
  final _maxLimitController = TextEditingController();

  bool _agreeToTerms = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isPickingImage = false;
  XFile? _passportImage;
  List<CurrencyDirection> _selectedDirections = [];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _passportNumberController.dispose();
    _rateAUDtoNGNController.dispose();
    _rateNGNtoAUDController.dispose();
    _minLimitController.dispose();
    _maxLimitController.dispose();
    super.dispose();
  }

  Future<void> _pickPassportImage() async {
    if (_isPickingImage) return; // Prevent multiple simultaneous calls

    setState(() {
      _isPickingImage = true;
    });

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _passportImage = image;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
    }
  }

  Future<String?> _uploadPassportImage(String uid) async {
    if (_passportImage == null) return null;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('dealer_passports')
          .child('$uid.jpg');

      await storageRef.putFile(File(_passportImage!.path));
      return await storageRef.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading passport: $e');
      return null;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDirections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one currency direction'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_passportImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload your passport document'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms of Service and Privacy Policy'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create user account
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('User creation failed');
      }

      // Upload passport image
      final passportUrl = await _uploadPassportImage(user.uid);

      // Calculate rates based on selected directions
      final rateAUDtoNGN = _selectedDirections.contains(CurrencyDirection.audToNgn) ||
              _selectedDirections.contains(CurrencyDirection.both)
          ? double.tryParse(_rateAUDtoNGNController.text) ?? 0
          : 0;

      final rateNGNtoAUD = _selectedDirections.contains(CurrencyDirection.ngnToAud) ||
              _selectedDirections.contains(CurrencyDirection.both)
          ? double.tryParse(_rateNGNtoAUDController.text) ?? 0
          : 0;

      // Store dealer information in Firestore
      final Map<String, dynamic> dealerData = {
        'userId': user.uid,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'passportImageUrl': passportUrl,
        'minLimit': double.tryParse(_minLimitController.text) ?? 0,
        'maxLimit': double.tryParse(_maxLimitController.text) ?? 0,
        'currencyDirections': _selectedDirections
            .where((d) => d != CurrencyDirection.both)
            .map((d) => d.name)
            .toList(),
        'exchangeRates': {}, // Store rates as a map
        'status': 'pending', // Awaiting admin approval
        'rating': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add exchange rates to the map
      if (_selectedDirections.contains(CurrencyDirection.audToNgn)) {
        dealerData['exchangeRates']['audToNgn'] = rateAUDtoNGN;
      }
      if (_selectedDirections.contains(CurrencyDirection.ngnToAud)) {
        dealerData['exchangeRates']['ngnToAud'] = rateNGNtoAUD;
      }

      // Store dealer information in Firestore
      try {
        await FirebaseFirestore.instance.collection('dealers').doc(user.uid).set(dealerData);
        debugPrint('✅ Dealer document created in Firestore');
      } catch (dealerError) {
        debugPrint('❌ Error creating dealer document: $dealerError');
        // Continue anyway, we'll try to create the user document
      }

      // Store user role in Firestore
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'role': 'dealer', // Important: Set role as dealer
          'phoneNumber': _phoneController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        debugPrint('✅ User document created with dealer role in Firestore');
        debugPrint('   User UID: ${user.uid}');
        debugPrint('   Email: ${_emailController.text.trim()}');
        debugPrint('   Role: dealer');
      } catch (userError) {
        debugPrint('❌ Error creating user document: $userError');
        // Show error but don't block navigation
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Account created but there was an error saving user data: $userError'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }

      if (!mounted) return;

      // Navigate to home screen (dealer will be redirected to dashboard on next login)
      Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Dealer registration submitted! Your account is pending admin approval.',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 5),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Registration failed. Please try again.';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists with this email.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Dealer signup error: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          'Become a Dealer',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dealer Information',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Business/Full Name *',
                          hintText: 'Enter your name or business name',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email Address *',
                          hintText: 'Enter your email',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number *',
                          hintText: '+61 XXX XXX XXX',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password *',
                          hintText: 'Create a secure password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      // Passport Upload
                      const Text(
                        'Identity Verification',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passportNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Passport Number *',
                          hintText: 'Enter passport number',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter passport number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _pickPassportImage,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.3),
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                _passportImage != null
                                    ? Icons.check_circle
                                    : Icons.upload_file,
                                size: 48,
                                color: _passportImage != null
                                    ? AppColors.success
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _passportImage != null
                                    ? 'Passport uploaded'
                                    : 'Upload Passport Document',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (_passportImage != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  _passportImage!.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Text(
                                'Required for verification',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Currency Directions
                      const Text(
                        'Currency Exchange Directions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...CurrencyDirection.values.map((direction) {
                        if (direction == CurrencyDirection.both) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: CheckboxListTile(
                            value: _selectedDirections.contains(direction),
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _selectedDirections.add(direction);
                                } else {
                                  _selectedDirections.remove(direction);
                                }
                              });
                            },
                            title: Text(
                              direction.label,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(direction.description),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 24),
                      // Exchange Rates
                      if (_selectedDirections.contains(CurrencyDirection.audToNgn)) ...[
                        TextFormField(
                          controller: _rateAUDtoNGNController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'AUD → NGN Rate *',
                            hintText: 'e.g., 950 (means ₦950 per \$1 AUD)',
                            helperText: 'Nigerian Naira per 1 Australian Dollar',
                          ),
                          validator: (value) {
                            if (_selectedDirections.contains(CurrencyDirection.audToNgn) &&
                                (value == null || value.trim().isEmpty)) {
                              return 'Please enter exchange rate';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                      if (_selectedDirections.contains(CurrencyDirection.ngnToAud)) ...[
                        TextFormField(
                          controller: _rateNGNtoAUDController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'NGN → AUD Rate *',
                            hintText: 'e.g., 0.00105 (means \$0.00105 per ₦1)',
                            helperText: 'Australian Dollar per 1 Nigerian Naira',
                          ),
                          validator: (value) {
                            if (_selectedDirections.contains(CurrencyDirection.ngnToAud) &&
                                (value == null || value.trim().isEmpty)) {
                              return 'Please enter exchange rate';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                      // Limits
                      const Text(
                        'Transaction Limits',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _minLimitController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Minimum (AUD) *',
                                hintText: '100',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _maxLimitController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Maximum (AUD) *',
                                hintText: '10000',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Terms checkbox
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _agreeToTerms,
                            onChanged: (value) {
                              setState(() {
                                _agreeToTerms = value ?? false;
                              });
                            },
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _agreeToTerms = !_agreeToTerms;
                                });
                              },
                              child: const Padding(
                                padding: EdgeInsets.only(top: 12),
                                child: Text(
                                  'I agree to the Terms of Service and Privacy Policy. I confirm that all information provided is accurate.',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: Gradients.button,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryBlue.withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              disabledBackgroundColor: Colors.grey,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Submit for Approval',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

