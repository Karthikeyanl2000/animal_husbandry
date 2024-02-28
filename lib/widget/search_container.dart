import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class SearchContainer extends StatefulWidget {
  final TextEditingController controller;
  final List<String> suggestionList;
  final void Function(String) onSuggestionSelected;
  final InputDecoration decoration;
  bool showSuggestions;
  //  final VoidCallback onPressedCallback;

  SearchContainer({
    Key? key,
    required this.controller,
    required this.suggestionList,
    required this.onSuggestionSelected,
    required this.decoration,
    required this.showSuggestions,
    // required this.onPressedCallback,
  }) : super(key: key);

  @override
  SearchContainerState createState() => SearchContainerState();
}

class SearchContainerState extends State<SearchContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
      decoration: BoxDecoration(
        color: Colors.white60,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              TypeAheadField<String>(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: widget.controller,
                  decoration: widget.decoration.copyWith(
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          widget.showSuggestions = !widget.showSuggestions;
                        });
                      },
                      icon: Icon(
                        widget.showSuggestions
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                      ),
                      color: Colors.black,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      widget.showSuggestions = true;
                    });
                  },
                  onChanged: (value) {
                    setState(() {
                      widget.showSuggestions = true;
                    });
                  },
                ),
                suggestionsCallback: (pattern) {
                  if (widget.showSuggestions) {
                    final regexPattern = RegExp(
                      pattern.replaceAll(
                          RegExp(r'[.*+?^${}()|[\]\\]'), r'\\$&'),
                      caseSensitive: false,
                    );
                    return widget.suggestionList
                        .where((tagNo) => regexPattern.hasMatch(tagNo))
                        .toList();
                  } else {
                    return [];
                  }
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion),
                  );
                },
                onSuggestionSelected: (suggestion) {
                  setState(() {
                    widget.controller.text = suggestion;
                    widget.onSuggestionSelected(suggestion);
                    widget.showSuggestions = false;
                  });
                },
              ),
            ],
          ),
          if (widget.showSuggestions)
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: widget.suggestionList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(widget.suggestionList[index]),
                    onTap: () {
                      setState(() {
                        widget.controller.text = widget.suggestionList[index];
                        widget
                            .onSuggestionSelected(widget.suggestionList[index]);
                        widget.showSuggestions = false;
                      });
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
