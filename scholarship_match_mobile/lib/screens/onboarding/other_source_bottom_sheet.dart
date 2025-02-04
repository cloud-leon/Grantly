import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtherSourceBottomSheet extends StatefulWidget {
  const OtherSourceBottomSheet({super.key});

  @override
  State<OtherSourceBottomSheet> createState() => _OtherSourceBottomSheetState();
}

class _OtherSourceBottomSheetState extends State<OtherSourceBottomSheet> {
  final FocusNode _focusNode = FocusNode();
  bool isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    // Increase delay and ensure keyboard shows
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        FocusScope.of(context).requestFocus(_focusNode);
        // Use the correct method from services
        SystemChannels.textInput.invokeMethod('TextInput.show');
      }
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      isKeyboardVisible = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        top: size.height * 0.1,
      ),
      child: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            Navigator.pop(context);
          }
        },
        child: Container(
          height: size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: size.height * 0.02,
                  left: size.width * 0.02,
                ),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.black,
                    size: size.width * 0.03,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      focusNode: _focusNode,
                      autofocus: true,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: size.width * 0.045,
                      ),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      keyboardAppearance: Brightness.light,
                      decoration: InputDecoration(
                        hintText: 'Influencer, flyer, etc..',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: size.width * 0.045,
                        ),
                        border: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onSubmitted: (value) {
                        // Handle submission if needed
                      },
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Can you provide more details?',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: size.width * 0.04,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: keyboardHeight > 0 ? keyboardHeight + 20 : 20,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                  ),
                  child: const Text('NEXT'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 