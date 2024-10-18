import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

class TextWithUrl extends StatelessWidget {
  const TextWithUrl({
    required this.text,
    Key? key,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    // URLを検知する正規表現
    final urlRegExp = RegExp(
        r'((https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?');

    final urlMatches = urlRegExp.allMatches(text);

    if (urlMatches.isEmpty) {
      // URLがない場合そのままテキストを表示
      return SelectableText(text);
    }

    final textSpanList = <TextSpan>[];
    var lastMatchEnd = 0;

    for (final match in urlMatches) {
      // リンクの前のテキストを追加
      if (match.start > lastMatchEnd) {
        textSpanList.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }

      // リンク部分を追加
      final url = text.substring(match.start, match.end);
      textSpanList.add(
        TextSpan(
          text: url,
          style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
          recognizer: TapGestureRecognizer()..onTap = () => _launchUrl(url),
        ),
      );

      lastMatchEnd = match.end;
    }

    // リンクの後の残りのテキストを追加
    if (lastMatchEnd < text.length) {
      textSpanList.add(TextSpan(text: text.substring(lastMatchEnd)));
    }

    return SelectableText.rich(TextSpan(children: textSpanList));
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}
