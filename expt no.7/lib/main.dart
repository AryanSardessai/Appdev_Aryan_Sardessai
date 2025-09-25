import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registration Form',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Or any color you prefer
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme( // Consistent styling for input fields
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
          ),
          labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
      home: const RegistrationScreen(),
    );
  }
}

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  // GlobalKey for the Form widget to enable validation
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields to retrieve their values
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State for Radio Buttons
  String? _selectedGender; // Can be 'male', 'female', 'other'

  // State for Dropdown
  String? _selectedCountry;
  final List<String> _countries = ['USA', 'Canada', 'UK', 'Australia', 'India', 'Germany', 'France'];

  // State for password visibility
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  @override
  void dispose() {
    // Clean up controllers when the widget is disposed
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      // If the form is valid, display a snackbar. In a real app, you'd process the data.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Processing Data...\nName: ${_nameController.text}\nEmail: ${_emailController.text}\nGender: $_selectedGender\nCountry: $_selectedCountry'),
          backgroundColor: Colors.green,
        ),
      );
      // Here you would typically send the data to a backend, save it locally, etc.
      // For example:
      // print('Name: ${_nameController.text}');
      // print('Email: ${_emailController.text}');
      // print('Password: ${_passwordController.text}');
      // print('Gender: $_selectedGender');
      // print('Country: $_selectedCountry');

      // You might want to clear the form after successful submission
      // _formKey.currentState?.reset();
      // _nameController.clear();
      // _emailController.clear();
      // _passwordController.clear();
      // _confirmPasswordController.clear();
      // setState(() {
      //   _selectedGender = null;
      //   _selectedCountry = null;
      // });

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct the errors in the form.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Assign the GlobalKey to the Form
          child: ListView( // Use ListView to make the form scrollable
            children: <Widget>[
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter your full name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  if (value.length < 3) {
                    return 'Name must be at least 3 characters long';
                  }
                  return null; // Return null if the input is valid
                },
                textInputAction: TextInputAction.next, // Focus next field on enter/next
              ),
              const SizedBox(height: 16.0),

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'you@example.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  // Basic email validation regex
                  if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16.0),

              // Password Field
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    onPressed: () {
                      setState(() {
                        _isPasswordObscured = !_isPasswordObscured;
                      });
                    },
                  ),
                ),
                obscureText: _isPasswordObscured,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters long';
                  }
                  // You can add more complex password rules here (e.g., uppercase, number, special character)
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16.0),

              // Confirm Password Field
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  hintText: 'Re-enter your password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_isConfirmPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordObscured = !_isConfirmPasswordObscured;
                      });
                    },
                  ),
                ),
                obscureText: _isConfirmPasswordObscured,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                textInputAction: TextInputAction.done, // Last field before submit
                onFieldSubmitted: (_) => _submitForm(), // Optionally submit on "done"
              ),
              const SizedBox(height: 24.0), // More space before radio buttons

              // Gender Radio Buttons
              const Text('Gender', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              Row(
                children: <Widget>[
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Male'),
                      value: 'male',
                      groupValue: _selectedGender,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Female'),
                      value: 'female',
                      groupValue: _selectedGender,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Other'),
                      value: 'other',
                      groupValue: _selectedGender,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              // Validation message for gender
              if (_formKey.currentState != null && // Check if form is built
                  _formKey.currentState!.validate() && // Only show if other fields are valid
                  _selectedGender == null && // And gender is not selected
                  _formKey.currentState!.mounted) // Check if form is mounted
                Padding(
                  padding: const EdgeInsets.only(top: 0, left: 12.0), // Adjust padding as needed
                  child: Text(
                    'Please select your gender',
                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 16.0),


              // Country Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Country',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                value: _selectedCountry,
                hint: const Text('Select your country'),
                isExpanded: true, // Make the dropdown take full width
                items: _countries.map((String country) {
                  return DropdownMenuItem<String>(
                    value: country,
                    child: Text(country),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCountry = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your country';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32.0), // More space before the submit button

              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Register'),
              ),
              const SizedBox(height: 16.0), // Space at the bottom
            ],
          ),
        ),
      ),
    );
  }
}
