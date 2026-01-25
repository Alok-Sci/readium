import 'package:flutter/material.dart';
import 'package:readium/core/context_extension.dart';
import 'package:readium/core/sizedbox_extension.dart';

class NetwokrErrorScreen extends StatelessWidget {
  const NetwokrErrorScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '🛰️',
              style: TextStyle(fontSize: 150),
            ),
            Text(
              'It looks like you\'re offline',
              style: context.textTheme.headlineSmall!
                  .copyWith(fontWeight: FontWeight.w500),
            ),
            Text(
              'Check your connection and try again',
              style: context.textTheme.bodyMedium!
                  .copyWith(backgroundColor: Colors.transparent),
            ),
            20.height,
            TextButton(
              onPressed: () {},
              child: Text(
                "Try again",
              ),
              style: TextButton.styleFrom(
                  backgroundColor: context.theme.primaryColor,
                  foregroundColor: context.colorScheme.primary,
                  fixedSize: Size(270, 10),
                  // padding: EdgeInsets.symmetric(
                  //     horizontal: 60, vertical: 3),
                  textStyle: context.textTheme.bodyMedium!
                      .copyWith(fontWeight: FontWeight.w500)),
            )
          ],
        ),
      ),
    );
  }
}
