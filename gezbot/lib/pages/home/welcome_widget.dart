import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class WelcomeWidget extends StatefulWidget {
  const WelcomeWidget({super.key});

  @override
  WelcomeWidgetState createState() => WelcomeWidgetState();
}

class WelcomeWidgetState extends State<WelcomeWidget> {
  late SharedPreferences _prefs;
  bool _showPopup = true;
  bool _dontShowAgain = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _dontShowAgain = _prefs.getBool('dontShowAgain') ?? false;
    });
  }

  void _toggleDontShowAgain(bool? value) {
    if (value != null)
    {
      setState(() {
        _dontShowAgain = value;
      });
      _prefs.setBool('dontShowAgain', value);
    }
  }

  void _closePopup() {
    setState(() {
      _showPopup = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_showPopup || (_dontShowAgain && _prefs.containsKey('dontShowAgain'))) {
      return const SizedBox.shrink(); //Return an empty widget if popup should not be shown
    }

    return Visibility(
      visible: _showPopup,
      maintainState: true,
      maintainAnimation: true,
      child: AlertDialog(
        title: const Text('Welcome!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/appicon.jpeg',
              width: 100,
              height: 100,
            ),
            const Text('You can make plans for your future travels. By stating your preferences, you can create a suitable one.'),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _dontShowAgain,
                  onChanged: _toggleDontShowAgain,
                ),
                const Text('Don\'t show this again'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _closePopup,
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}