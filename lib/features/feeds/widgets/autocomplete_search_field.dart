import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';

class AutocompleteSearchField extends StatefulWidget {
  final String hintText;
  final String? initialValue;
  final Function(String) onChanged;
  final Function(String)? onSubmitted;
  final List<String>? recentSearches;
  final Function(String)? onSuggestionSelected;
  final bool enabled;

  const AutocompleteSearchField({
    Key? key,
    required this.hintText,
    this.initialValue,
    required this.onChanged,
    this.onSubmitted,
    this.recentSearches,
    this.onSuggestionSelected,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<AutocompleteSearchField> createState() =>
      _AutocompleteSearchFieldState();
}

class _AutocompleteSearchFieldState extends State<AutocompleteSearchField> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  final ApiClient _apiClient = ApiClient();

  List<String> _suggestions = [];
  List<String> _recentSearches = [];
  bool _isLoadingSuggestions = false;
  bool _showSuggestions = false;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    _recentSearches = widget.recentSearches ?? [];
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus && _controller.text.isEmpty) {
      setState(() {
        _showSuggestions = true;
        _suggestions = _recentSearches;
      });
    } else if (!_focusNode.hasFocus) {
      setState(() {
        _showSuggestions = false;
      });
    }
  }

  Future<void> _getSuggestions(String query) async {
    if (query.length < 2) {
      setState(() {
        _suggestions = _recentSearches;
        _isLoadingSuggestions = false;
      });
      return;
    }

    setState(() {
      _isLoadingSuggestions = true;
    });

    try {
      final response = await _apiClient.get(
        ApiEndpoints.searchSuggestions,
        queryParameters: {'q': query, 'type': 'fundi', 'limit': 8},
      );

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final suggestions = (data['suggestions'] as List<dynamic>)
            .map((item) => item['text'] as String)
            .toList();

        setState(() {
          _suggestions = suggestions;
          _isLoadingSuggestions = false;
        });
      } else {
        setState(() {
          _suggestions = _recentSearches
              .where(
                (search) => search.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
          _isLoadingSuggestions = false;
        });
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
      setState(() {
        _suggestions = _recentSearches
            .where(
              (search) => search.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
        _isLoadingSuggestions = false;
      });
    }
  }

  void _onTextChanged(String value) {
    _currentQuery = value;
    widget.onChanged(value);

    if (value.isEmpty) {
      setState(() {
        _suggestions = _recentSearches;
        _showSuggestions = _focusNode.hasFocus;
      });
    } else {
      _getSuggestions(value);
      setState(() {
        _showSuggestions = true;
      });
    }
  }

  void _onSuggestionSelected(String suggestion) {
    _controller.text = suggestion;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: suggestion.length),
    );

    setState(() {
      _showSuggestions = false;
    });

    widget.onSuggestionSelected?.call(suggestion);
    widget.onChanged(suggestion);

    // Add to recent searches
    _addToRecentSearches(suggestion);
  }

  void _addToRecentSearches(String search) {
    if (search.trim().isEmpty) return;

    setState(() {
      _recentSearches.remove(search);
      _recentSearches.insert(0, search);
      if (_recentSearches.length > 5) {
        _recentSearches = _recentSearches.take(5).toList();
      }
    });
  }

  void _clearSearch() {
    _controller.clear();
    widget.onChanged('');
    setState(() {
      _showSuggestions = false;
      _suggestions = _recentSearches;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          enabled: widget.enabled,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearSearch,
                  )
                : null,
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
          ),
          onChanged: _onTextChanged,
          onSubmitted: widget.onSubmitted,
          textInputAction: TextInputAction.search,
        ),

        if (_showSuggestions && _suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                if (_currentQuery.isEmpty && _recentSearches.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.history, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          'Recent searches',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                if (_isLoadingSuggestions)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = _suggestions[index];
                      final isRecent =
                          _currentQuery.isEmpty &&
                          _recentSearches.contains(suggestion);

                      return ListTile(
                        dense: true,
                        leading: Icon(
                          isRecent ? Icons.history : Icons.search,
                          size: 18,
                          color: Colors.grey[600],
                        ),
                        title: Text(
                          suggestion,
                          style: const TextStyle(fontSize: 14),
                        ),
                        onTap: () => _onSuggestionSelected(suggestion),
                        hoverColor: Colors.grey[100],
                      );
                    },
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
