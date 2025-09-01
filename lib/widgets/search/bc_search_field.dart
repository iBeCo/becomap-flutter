import 'package:flutter/material.dart';
import 'models/bc_search_field_type.dart';

/// **BCSearchField** - Individual search input field component with debouncing and validation.
///
/// This widget provides a styled search input field with configurable placeholder text,
/// clear button functionality, focus management, and input validation. It supports
/// both origin and destination field types for navigation mode.
///
/// **Usage Example:**
/// ```dart
/// BCSearchField(
///   fieldType: BCSearchFieldType.destination,
///   placeholder: 'Where to go?',
///   onChanged: (query) {
///     controller.performSearch(query, BCSearchFieldType.destination);
///   },
///   onClear: () {
///     controller.clearSearch(BCSearchFieldType.destination);
///   },
/// )
/// ```
class BCSearchField extends StatefulWidget {
  /// **Field type** - Origin or destination field identifier.
  final BCSearchFieldType fieldType;

  /// **Placeholder text** - Text shown when field is empty.
  final String? placeholder;

  /// **Initial value** - Pre-populated text value.
  final String? initialValue;

  /// **Text change callback** - Called when user types in the field.
  final ValueChanged<String>? onChanged;

  /// **Submit callback** - Called when user presses enter or search button.
  final ValueChanged<String>? onSubmitted;

  /// **Clear callback** - Called when user taps the clear button.
  final VoidCallback? onClear;

  /// **Focus change callback** - Called when field gains or loses focus.
  final ValueChanged<bool>? onFocusChanged;

  /// **Enabled state** - Whether the field accepts input.
  final bool enabled;

  /// **Auto focus** - Whether to automatically focus this field.
  final bool autofocus;

  /// **Show clear button** - Whether to show the clear button when text is present.
  final bool showClearButton;

  /// **Maximum length** - Maximum number of characters allowed.
  final int? maxLength;

  /// Creates a new BCSearchField instance.
  ///
  /// **Parameters:**
  /// - [fieldType] The search field type (origin or destination)
  /// - [placeholder] Placeholder text (defaults to field type default)
  /// - [initialValue] Initial text value
  /// - [onChanged] Callback for text changes
  /// - [onSubmitted] Callback for form submission
  /// - [onClear] Callback for clear button tap
  /// - [onFocusChanged] Callback for focus changes
  /// - [enabled] Whether field accepts input (default: true)
  /// - [autofocus] Whether to auto-focus (default: false)
  /// - [showClearButton] Whether to show clear button (default: true)
  /// - [maxLength] Maximum character limit (default: 100)
  const BCSearchField({
    super.key,
    required this.fieldType,
    this.placeholder,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onFocusChanged,
    this.enabled = true,
    this.autofocus = false,
    this.showClearButton = true,
    this.maxLength = 100,
  });

  @override
  State<BCSearchField> createState() => _BCSearchFieldState();
}

class _BCSearchFieldState extends State<BCSearchField> {
  late TextEditingController _textController;
  late FocusNode _focusNode;
  bool _hasFocus = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();

    _textController = TextEditingController(text: widget.initialValue ?? '');
    _focusNode = FocusNode();

    _hasText = _textController.text.isNotEmpty;

    // Listen to text changes
    _textController.addListener(_onTextChanged);

    // Listen to focus changes
    _focusNode.addListener(_onFocusChanged);

    // Auto focus if requested
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(BCSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update text if initial value changed
    if (widget.initialValue != oldWidget.initialValue) {
      _textController.text = widget.initialValue ?? '';
    }

    // Update auto focus
    if (widget.autofocus != oldWidget.autofocus && widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _textController.text.isNotEmpty;
    if (_hasText != hasText) {
      setState(() {
        _hasText = hasText;
      });
    }

    widget.onChanged?.call(_textController.text);
  }

  void _onFocusChanged() {
    final hasFocus = _focusNode.hasFocus;
    if (_hasFocus != hasFocus) {
      setState(() {
        _hasFocus = hasFocus;
      });
      widget.onFocusChanged?.call(hasFocus);
    }
  }

  void _onClearTapped() {
    _textController.clear();
    widget.onClear?.call();
    _focusNode.requestFocus();
  }

  void _onSubmitted(String value) {
    widget.onSubmitted?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        enabled: widget.enabled,
        maxLength: widget.maxLength,
        onSubmitted: _onSubmitted,
        decoration: InputDecoration(
          hintText: widget.placeholder ?? widget.fieldType.placeholder,
          hintStyle: TextStyle(
            color: const Color(0xFF999999),
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: _hasFocus
                ? Theme.of(context).primaryColor
                : const Color(0xFF999999),
            size: 20,
          ),
          suffixIcon: _hasText && widget.showClearButton
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: Color(0xFF999999),
                    size: 20,
                  ),
                  onPressed: widget.enabled ? _onClearTapped : null,
                  tooltip: 'Clear search',
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          counterText: '', // Hide character counter
        ),
        style: const TextStyle(
          color: Color(0xFF333333),
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        textInputAction: TextInputAction.search,
        autocorrect: false,
        enableSuggestions: true,
      ),
    );
  }
}

/// **BCSearchFieldPair** - Convenience widget for displaying origin and destination fields together.
///
/// This widget provides a pre-configured layout for navigation mode with both
/// origin and destination search fields, including proper spacing and alignment.
///
/// **Usage Example:**
/// ```dart
/// BCSearchFieldPair(
///   originValue: originQuery,
///   destinationValue: destinationQuery,
///   onOriginChanged: (query) {
///     controller.performSearch(query, BCSearchFieldType.origin);
///   },
///   onDestinationChanged: (query) {
///     controller.performSearch(query, BCSearchFieldType.destination);
///   },
/// )
/// ```
class BCSearchFieldPair extends StatelessWidget {
  /// **Origin field value** - Current text in origin field.
  final String? originValue;

  /// **Destination field value** - Current text in destination field.
  final String? destinationValue;

  /// **Origin change callback** - Called when origin field text changes.
  final ValueChanged<String>? onOriginChanged;

  /// **Destination change callback** - Called when destination field text changes.
  final ValueChanged<String>? onDestinationChanged;

  /// **Origin submit callback** - Called when origin field is submitted.
  final ValueChanged<String>? onOriginSubmitted;

  /// **Destination submit callback** - Called when destination field is submitted.
  final ValueChanged<String>? onDestinationSubmitted;

  /// **Origin clear callback** - Called when origin field is cleared.
  final VoidCallback? onOriginClear;

  /// **Destination clear callback** - Called when destination field is cleared.
  final VoidCallback? onDestinationClear;

  /// **Enabled state** - Whether both fields accept input.
  final bool enabled;

  /// Creates a new BCSearchFieldPair instance.
  const BCSearchFieldPair({
    super.key,
    this.originValue,
    this.destinationValue,
    this.onOriginChanged,
    this.onDestinationChanged,
    this.onOriginSubmitted,
    this.onDestinationSubmitted,
    this.onOriginClear,
    this.onDestinationClear,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BCSearchField(
          fieldType: BCSearchFieldType.origin,
          initialValue: originValue,
          onChanged: onOriginChanged,
          onSubmitted: onOriginSubmitted,
          onClear: onOriginClear,
          enabled: enabled,
        ),
        const SizedBox(height: 12),
        BCSearchField(
          fieldType: BCSearchFieldType.destination,
          initialValue: destinationValue,
          onChanged: onDestinationChanged,
          onSubmitted: onDestinationSubmitted,
          onClear: onDestinationClear,
          enabled: enabled,
          autofocus: true,
        ),
      ],
    );
  }
}
