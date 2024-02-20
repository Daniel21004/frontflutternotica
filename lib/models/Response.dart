class Response {
  final String msg;
  final String tag;
  final dynamic datos; //dynamic ya es null
  final int code;
  final int currentPage;
  final int totalPages;

  const Response({
    required this.msg,
    this.datos,
    this.tag = '',
    this.currentPage = 1,
    this.totalPages = 1,
    required this.code,
  });

  factory Response.fromJson(Map<String, dynamic> json) {
    try {
      return Response(
        msg: json['msg'] as String,
        datos: json['datos'],
        tag: json['tag'] as String? ?? '',
        code: json['code'],
      currentPage: json['currentPage'] != null ? json['currentPage'] as int : 1,
      totalPages: json['totalPages'] != null ? json['totalPages'] as int : 1,
      );
    } catch (e) {
      throw FormatException('Error al convertir JSON a Response: $e');
    }
  }

  dynamic getDatos() {
    return datos;
  }

  @override
  String toString() {
    return "msg: $msg \n tag: $tag \n datos:$datos \n code $code";
  }
}
