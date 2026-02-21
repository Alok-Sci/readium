import 'package:flutter/material.dart';
import 'package:readium/core/context_extension.dart';
import 'package:readium/core/utils/app_assets.dart';

class ReadiumSearchBar extends StatelessWidget {
  ReadiumSearchBar({
    super.key,
    FocusNode? focusNode,
    TextEditingController? controller,
    required this.onSearch,
  }) : _focusNode = focusNode ?? FocusNode(),
       _controller = controller ?? TextEditingController();

  final FocusNode _focusNode;
  final TextEditingController _controller;
  final Function(String) onSearch;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: TextFormField(
              controller: _controller,
              focusNode: _focusNode,
              onTapOutside: (event) => _focusNode.unfocus(),
              onFieldSubmitted: (value) => onSearch(_controller.text),
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.search,
              style: context.textTheme.labelLarge,
              decoration: InputDecoration(
                filled: !_focusNode.hasFocus,
                focusColor: context.colorScheme.tertiary,
                fillColor: context.colorScheme.surface,
                prefixIconConstraints: BoxConstraints(
                  minHeight: 20,
                  minWidth: 40,
                  maxHeight: 20,
                  maxWidth: 40,
                ),
                prefixIcon: SizedBox(
                  width: 25,
                  child: Center(
                    child: Image.asset(
                      _focusNode.hasFocus
                          ? AppAssets.searchActive
                          : AppAssets.search,
                      height: 23,
                    ),
                  ),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(width: 0, color: Colors.transparent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 0, color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    color: context.colorScheme.secondary,
                  ),
                ),
                hintText: 'Enter Medium Article URL',
                hintStyle: context.textTheme.labelMedium,
              ),
              validator: (value) {
                if (value == "") return "Value cannot be empty";
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }
}
