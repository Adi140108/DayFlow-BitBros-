// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;

/// Universal cross-platform helper to trigger real browser file downloads on Flutter Web.
class FileDownloadHelper {
  /// Downloads text content (e.g. CSV, JSON, TXT) as a real file download in the browser.
  static void downloadTextFile({
    required String filename,
    required String content,
    String mimeType = 'text/csv;charset=utf-8',
  }) {
    if (kIsWeb) {
      final bytes = utf8.encode(content);
      final blob = html.Blob([bytes], mimeType);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = filename;
      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    }
  }

  /// Downloads binary bytes (e.g. PDF, PNG) as a file download in the browser.
  static void downloadBytes({
    required String filename,
    required List<int> bytes,
    String mimeType = 'application/octet-stream',
  }) {
    if (kIsWeb) {
      final blob = html.Blob([bytes], mimeType);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = filename;
      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    }
  }

  /// Opens or triggers download from a direct URL in the browser.
  static void downloadFromUrl({
    required String url,
    required String filename,
  }) {
    if (kIsWeb) {
      final anchor = html.AnchorElement(href: url)
        ..target = '_blank'
        ..download = filename;
      anchor.click();
    }
  }
}
