/// Pure CSV & Report Export Engine for Dayflow.
class ReportEngine {
  /// Converts a header list and rows into standard CSV text
  static String generateCsv(List<String> headers, List<List<dynamic>> rows) {
    final buffer = StringBuffer();
    buffer.writeln(headers.map((h) => '"$h"').join(','));

    for (var row in rows) {
      final line = row.map((val) {
        final str = val?.toString() ?? '';
        return '"${str.replaceAll('"', '""')}"';
      }).join(',');
      buffer.writeln(line);
    }
    return buffer.toString();
  }
}
