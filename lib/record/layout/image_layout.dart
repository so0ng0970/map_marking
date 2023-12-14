// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class ImageLayout extends StatefulWidget {
  List<XFile>? selectedImages;
  List<String>? selectedNetworkImages;

  bool networkImages;
  int initialIndex;
  ImageLayout({
    Key? key,
    this.selectedImages,
    this.selectedNetworkImages,

    required this.networkImages,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<ImageLayout> createState() => _ImageLayoutState();
}

class _ImageLayoutState extends State<ImageLayout> {
  late PageController _pageController;
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.black87,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.networkImages
                  ? widget.selectedNetworkImages?.length
                  : widget.selectedImages?.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: widget.networkImages
                      ? Image.network(
                          widget.selectedNetworkImages![index],
                        )
                      : Image.file(
                          File(widget.selectedImages![index].path),
                        ),
                );
              },
            ),
          ),
          Positioned(
            top: 0,
            child: IconButton(
              onPressed: () {
                context.pop();
              },
              icon: const Icon(
                Icons.chevron_left,
                color: Colors.white,
                size: 40,
              ),
            ),
          )
        ],
      ),
    );
  }
}
