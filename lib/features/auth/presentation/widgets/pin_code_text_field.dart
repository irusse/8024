import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

class PinCodeTextField extends StatefulWidget {
  /// Total number of pin code fields.
  final int length;

  /// Enable/ disable autofocus on the field.
  final bool autofocus;

  /// Border width of the field.
  final double borderWidth;

  final TextInputType textInputType;

  /// Color of the border.
  final Color borderColor;

  /// true/false hasError
  final bool hasError;

  /// Height of the pin code fields.
  final double? fieldHeight;

  /// Width of the pin code fields.
  final double? fieldWidth;

  /// Border color of the active/ highlighted field.
  final Color activeBorderColor;

  /// Background color of the fields.
  final Color? fieldBackgroundColor;

  /// Background color of the active/ highlighted field.
  final Color? activeBackgroundColor;

  /// Focus node for the fields.
  final FocusNode? focusNode;

  /// Enable/ disable editing on the fields.
  final bool enabled;

  /// Hides the input text of the user.
  final bool obscureText;

  /// Style of the text in the fields.
  final TextStyle textStyle;

  /// Automatically hide keyboard when the user reaches the last field or the first field (by delete).
  final bool autoHideKeyboard;

  /// Animation duration for the text in the fields.
  final Duration animationDuration;

  /// Callback that returns text on input.
  final ValueChanged<String>? onChange;

  @required

  /// Text editing controller for the fields.
  final TextEditingController controller;

  @required

  /// Border radius of the field.
  final BorderRadius borderRadius;

  /// Callback that returns text on filling all the fields.
  @required
  final ValueChanged<String> onComplete;

  const PinCodeTextField({
    super.key,

    /// Default length is 4.
    this.length = 4,
    required this.hasError,

    /// autofocus is false by default.
    this.autofocus = false,

    /// Default width for border is 2.0.
    this.borderWidth = 2.0,

    /// Default border color is grey.
    this.borderColor = Colors.grey,
    this.fieldHeight,
    this.fieldWidth,
    this.textInputType = TextInputType.number,

    /// Default active border color is blue.
    this.activeBorderColor = Colors.blue,
    this.fieldBackgroundColor,
    this.activeBackgroundColor,
    this.focusNode,

    /// Text fields are enabled by default.
    this.enabled = true,

    /// Obscure text is false by default.
    this.obscureText = false,

    /// Default text style for the fields.
    this.textStyle = const TextStyle(
      fontSize: 20.0,
    ),

    /// Auto hide keyboard is true by default.
    this.autoHideKeyboard = true,

    /// Default animation for text is Fade.

    /// Default duration for animation on text is 150ms.
    this.animationDuration = const Duration(milliseconds: 150),
    this.onChange,
    required this.onComplete,
    required this.borderRadius,
    required this.controller,
  });

  @override
  State<PinCodeTextField> createState() => _PincodeTextFieldState();
}

class _PincodeTextFieldState extends State<PinCodeTextField> {
  late FocusNode _focusNode;

  /// Storing the input in this list.
  late List<String> _inputList;

  /// Keeps a track of selected pin code field.
  int _selectedIndex = 0;

  @override
  void initState() {
    _assignController();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(() {
      setState(() {});
    });
    _inputList = List<String>.filled(widget.length, '', growable: false);
    _initializeValues();
    super.initState();
  }

  /// function responsible for assigning controller to the text field.
  void _assignController() {
    /// Text editing controllers' listener
    /// Used to check which is the current field and set focus on that field,
    /// populate onComplete callback.
    widget.controller.addListener(() {
      var currentText = widget.controller.text;

      if (widget.enabled && _inputList.join("") != currentText) {
        if (currentText.length >= widget.length) {
          if (currentText.length > widget.length) {
            currentText = currentText.substring(0, widget.length);
          }
          widget.onComplete(currentText);
          if (widget.autoHideKeyboard) {
            _focusNode.unfocus();
          }
        } else if (currentText.isEmpty) {
          if (widget.autoHideKeyboard) {
            _focusNode.unfocus();
          }
        }
        if (widget.onChange != null) {
          widget.onChange!(currentText);
        }
      }
      _setTextToInput(currentText);
    });
  }

  /// Initializing the input list to empty.
  void _initializeValues() {
    for (int i = 0; i < _inputList.length; i++) {
      _inputList[i] = "";
    }
  }

  /// Checking if the requested text field has focus or not.
  void _onFocus() {
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
    }

    /// Launching keyboard.
    FocusScope.of(context).requestFocus(_focusNode);
    SystemChannels.textInput.invokeMethod('TextInput.show');
  }

  /// Populating the input list with the text that the user inputs.
  void _setTextToInput(String data) async {
    var replaceInputList = List<String>.filled(widget.length, '');

    for (int i = 0; i < widget.length; i++) {
      if (data.length > i) {
        replaceInputList[i] = data[i];
      } else {
        replaceInputList[i] = "";
      }
    }

    setState(() {
      _selectedIndex = data.length;
      _inputList = replaceInputList;
    });
  }

  /// Setting the color of the active text field using _selectedIndex.
  Color _getColorFromIndex(int index) {
    if (!widget.enabled) {
      return widget.borderColor;
    }
    if (widget.hasError) {
      return context.color.basicRed;
    }
    if (((_selectedIndex == index) ||
            (_selectedIndex == index + 1 && index + 1 == widget.length)) &&
        _focusNode.hasFocus) {
      return widget.activeBorderColor;
    } else if (_selectedIndex > index) {
      return widget.borderColor;
    }
    return widget.borderColor;
  }

  /// Setting the background color of the active text field using _selectedIndex.
  Color _getBackgroundColorFromIndex(int index) {
    if (!widget.enabled) {
      return widget.fieldBackgroundColor ?? Colors.transparent;
    }
    if (((_selectedIndex == index) ||
            (_selectedIndex == index + 1 && index + 1 == widget.length)) &&
        _focusNode.hasFocus) {
      return widget.activeBackgroundColor ?? Colors.transparent;
    } else if (_selectedIndex > index) {
      return widget.fieldBackgroundColor ?? Colors.transparent;
    }
    return widget.fieldBackgroundColor ?? Colors.transparent;
  }

  Border _generateBorder(int index) {
    return Border.all(
      color: _getColorFromIndex(index),
      width: widget.borderWidth,
    );
  }

  /// Generating animation for text based on the animation selected.
  Widget _getAnimation(Widget child, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -.5),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }

  /// Generating text fields based on the length of text field provided
  Widget _generateTextField(int index) {
    return AnimatedContainer(
        duration: widget.animationDuration,
        width: widget.fieldWidth,
        height: widget.fieldHeight,
        decoration: BoxDecoration(
          border: _generateBorder(index),
          borderRadius: widget.borderRadius,
          color: _getBackgroundColorFromIndex(index),
        ),
        child: _switcherContainer(index));
  }

  Widget _switcherContainer(int index) {
    return Center(
      child: AnimatedSwitcher(
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        duration: widget.animationDuration,
        transitionBuilder: (child, animation) {
          return _getAnimation(child, animation);
        },
        child: Text(
          widget.obscureText
              ? _inputList[index].replaceAll(RegExp(r'.'), '*')
              : _inputList[index],
          key: ValueKey(_inputList[index]),
          style: widget.textStyle
              .copyWith(color: widget.hasError ? context.color.basicRed : null),
        ),
      ),
    );
  }

  List<Widget> _generateFields() {
    var result = <Widget>[];
    for (int i = 0; i < widget.length; i++) {
      result.add(_generateTextField(i));
    }
    return result;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        AbsorbPointer(
          absorbing: true,
          child: TextFormField(
            style: const TextStyle(color: Colors.transparent),
            autofillHints: const [AutofillHints.oneTimeCode],
            inputFormatters: <TextInputFormatter>[
              if (widget.textInputType == TextInputType.number)
                FilteringTextInputFormatter.digitsOnly
              else
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
            ],
            controller: widget.controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            autofocus: widget.autofocus,
            autocorrect: false,
            keyboardType: widget.textInputType,
            enableInteractiveSelection: false,
            showCursor: false,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(0),
              border: InputBorder.none,
            ),
          ),
        ),
        GestureDetector(
          onTap: _onFocus,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _generateFields(),
          ),
        ),
      ],
    );
  }
}
