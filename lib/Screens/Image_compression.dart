import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/route_manager.dart';
import 'package:image_picker/image_picker.dart';

class ImageCompress extends StatefulWidget {
  const ImageCompress({super.key});

  @override
  State<ImageCompress> createState() => _ImageCompressState();
}

class _ImageCompressState extends State<ImageCompress> {

  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  File? _compressedImage;

  int? _originalSize;
  int? _compressedSize;

  Future<void> compress() async {
    if (_imageFile != null) {
      var result = await FlutterImageCompress.compressAndGetFile(
        _imageFile!.absolute.path,
        '${_imageFile!.path}compressed.jpg',
        quality: 75,
      );

      setState(() {
        _compressedImage = File(result!.path);
        _compressedSize = _compressedImage!.lengthSync();
      });
    }
  }


  Future<void> pickImage(ImageSource source) async {
    final image = await _picker.pickImage(source: source);

    setState(() {
      _imageFile = File(image!.path);
      _originalSize = _imageFile!.lengthSync();
    });
  }



  Future<void> downloadCompressedImage() async {
    if (_compressedImage != null) {
      String? results = await FilePicker.platform.getDirectoryPath();

      if (results != null) {
        String savePath = '$results/${DateTime.now().millisecondsSinceEpoch}.jpg';
        File newFile = await _compressedImage!.copy(savePath);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Compressed image downloaded')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please compress the image first')),
      );
    }
  }

  Future<void> downloadOriginalImage() async {
    if (_imageFile != null) {
      String? result = await FilePicker.platform.getDirectoryPath();

      if (result != null) {
        String savePath = '$result/${DateTime.now().millisecondsSinceEpoch}.jpg';
        File newFile = await _imageFile!.copy(savePath);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Original image downloaded')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select the image first')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[900],
        centerTitle: true,
        title: Text('IMAGE COMPRESSION',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white,fontSize: 18)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,color: Colors.white,), onPressed: () { Get.back(); },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Before'),
            if (_imageFile != null)
              Image.file(
                _imageFile!,
                height: 200,
                width: 400,
              ),
            if (_originalSize != null)
              Text('${filesize(_originalSize!)} '),
            _originalSize != null?
            ElevatedButton(
              onPressed: () async {
                await downloadOriginalImage();
              },
              child: const Text('Download Original Image'),
            ):
            Container(),

            const Divider(),
            const Text('After'),
            if (_compressedImage != null)
              Image.file(
                _compressedImage!,
                height: 200,
                width: 400,
              ),
            if (_compressedSize != null)
              Text('${filesize(_compressedSize!)} '),
            _compressedSize != null?
            ElevatedButton(
              onPressed: () async {
                await downloadCompressedImage();
              },
              child: const Text('Download Compressed Image'),
            ):
            Container(),
            const Divider(),
            _originalSize != null?
            ElevatedButton(
              onPressed: () async {
                await compress();
              },
              child: const Text('Compress'),
            ):
            Container(),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await pickImage(ImageSource.gallery);
                  },
                  child: const Text('Select Image'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () async {
                    await pickImage(ImageSource.camera);
                  },
                  child: const Text('Capture Image'),
                ),
              ],
            ),

            const SizedBox(height:5),


          ],
        ),
      ),
    );
  }
}

