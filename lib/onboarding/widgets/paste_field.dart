import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PasteField extends StatelessWidget {
  final String hintText;
  final Widget? additionalWidget;
  final String subtitle;
  final TextEditingController controller;
  final double height;
  const PasteField({
    super.key,
    this.additionalWidget,
    this.subtitle = '',
    this.hintText = '',
    this.height = 200,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16.0,
      children: [
        Stack(
          children: [
            TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
              ),
              minLines: 4,
              maxLines: 10,
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey)),
                onPressed: () async {
                  final textValue =
                      (await Clipboard.getData(Clipboard.kTextPlain))?.text ??
                          "";
                  controller.text = textValue;
                },
                icon: const Icon(Icons.content_copy),
                label: const Text("Paste"),
              ),
            ),
          ],
        ),
        if (additionalWidget != null) additionalWidget!,
        SizedBox(
            width: MediaQuery.sizeOf(context).width,
            child: Text(
              subtitle,
              textAlign: TextAlign.left,
            )),
      ],
    );
  }
}
