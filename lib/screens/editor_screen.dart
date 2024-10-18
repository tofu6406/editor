import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fleather/fleather.dart';
import 'package:url_launcher/url_launcher.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  EditorScreenState createState() => EditorScreenState();
}

class EditorScreenState extends State<EditorScreen> {
  FleatherController? _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _loadDocument().then((document) {
      setState(() {
        _controller = FleatherController(document: document);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editor'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveDocument(context),
          ),
          IconButton(
            icon: const Icon(Icons.link),
            onPressed: () {
              final url = 'https://flutter.dev'; // サンプルのリンク
              _insertLink(url);
            },
          ),
        ],
      ),
      body: _controller == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                FleatherToolbar.basic(controller: _controller!),
                const Divider(),
                Expanded(
                  child: FleatherEditor(
                    padding: const EdgeInsets.all(16),
                    controller: _controller!,
                    focusNode: _focusNode,
                    onLaunchUrl: _launchUrl, // リンクタップ時の処理
                  ),
                ),
              ],
            ),
    );
  }

  Future<ParchmentDocument> _loadDocument() async {
    final file = File(Directory.systemTemp.path + "/quick_start.json");
    if (await file.exists()) {
      final contents = await file.readAsString();
      return ParchmentDocument.fromJson(jsonDecode(contents));
    }
    final Delta delta = Delta()..insert("Fleather Quick Start\n");
    return ParchmentDocument.fromDelta(delta);
  }

  void _saveDocument(BuildContext context) {
    final contents = jsonEncode(_controller!.document);
    final file = File('${Directory.systemTemp.path}/quick_start.json');
    file.writeAsString(contents).then(
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved.')),
        );
      },
    );
  }

  /// URLを開く処理
  void _launchUrl(String? url) async {
    if (url == null) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  /// エディタにリンクを挿入する処理
  void _insertLink(String url) {
  final selection = _controller!.selection;

  if (selection.isCollapsed) {
    // テキストが選択されていない場合、リンクを直接挿入
    _controller!.replaceText(selection.baseOffset, 0, url, selection: selection);
    _controller!.formatText(selection.baseOffset, url.length, ParchmentAttribute.link.fromString(url));
  } else {
    // 選択されたテキストにリンクを適用
    _controller!.formatText(
      selection.baseOffset,
      selection.extentOffset - selection.baseOffset,
      ParchmentAttribute.link.fromString(url),
    );
  }
}

}
