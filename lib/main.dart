import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

void main() {
  runApp(const MaterialApp(
    title: 'Syncfusion PDF Viewer Demo',
    home: HomePage(),
  ));
}

/// Represents Homepage for Navigation
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  late Directory _pdfDirectory;

  @override
  void initState() {
    super.initState();
    _pdfDirectory = Directory('C:/PDF_Gen');
    // Check if the directory exists, if not, create it
    if (!_pdfDirectory.existsSync()) {
      _pdfDirectory.createSync(recursive: true);
    }
  }

  List<File> _loadRootPDFFiles() {
    List<File> pdfFiles = [];
    List<FileSystemEntity> entities = _pdfDirectory.listSync();
    for (var entity in entities) {
      if (entity is File && entity.path.toLowerCase().endsWith('.pdf')) {
        pdfFiles.add(entity);
      }
    }
    return pdfFiles;
  }

  List<File> _loadPDFFilesInDirectory(String directoryPath) {
    Directory directory = Directory(directoryPath);
    List<File> pdfFiles = [];
    List<FileSystemEntity> entities = directory.listSync();
    for (var entity in entities) {
      if (entity is File && entity.path.toLowerCase().endsWith('.pdf')) {
        pdfFiles.add(entity);
      }
    }
    return pdfFiles;
  }

  Future<void> _refreshDirectory() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Syncfusion Flutter PDF Viewer'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: _refreshDirectory,
          ),
          IconButton(
            icon: const Icon(
              Icons.bookmark,
              color: Colors.white,
              semanticLabel: 'Bookmark',
            ),
            onPressed: () {
              _pdfViewerKey.currentState?.openBookmarkView();
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildRootPDFList(),
          _buildPDFGenDirectory(),
        ],
      ),
    );
  }

  Widget _buildRootPDFList() {
    List<File> rootPDFFiles = _loadRootPDFFiles();
    return ExpansionTile(
      title: const Text('PDF_Gen'),
      children: rootPDFFiles.map((file) {
        return ListTile(
          title: Text(file.path.split('/').last),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PDFViewer(file: file),
              ),
            ).then((_) {
              _refreshDirectory();
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildPDFGenDirectory() {
    List<Widget> children = [];
    List<FileSystemEntity> entities = _pdfDirectory.listSync();
    for (var entity in entities) {
      if (entity is Directory) {
        String directoryName = entity.path.split('/').last;
        List<File> pdfFilesInDirectory = _loadPDFFilesInDirectory(entity.path);
        if (pdfFilesInDirectory.isNotEmpty) {
          children.add(ExpansionTile(
            title: Text(directoryName),
            children: pdfFilesInDirectory.map((file) {
              return ListTile(
                title: Text(file.path.split('/').last),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PDFViewer(file: file),
                    ),
                  ).then((_) {
                    _refreshDirectory();
                  });
                },
              );
            }).toList(),
          ));
        }
      }
    }
    return Column(children: children);
  }
}

class PDFViewer extends StatelessWidget {
  final File file;

  const PDFViewer({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
      ),
      body: SfPdfViewer.file(
        file,
      ),
    );
  }
}
