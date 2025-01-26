class Quote {
  final int? id;
  final String date;
  final String content;
  final String? aiAnalysis;
  final String? sentiment;
  final List<String>? keywords;
  final String? summary;

  Quote({
    this.id,
    required this.date,
    required this.content,
    this.aiAnalysis,
    this.sentiment,
    this.keywords,
    this.summary,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'content': content,
      'aiAnalysis': aiAnalysis,
      'sentiment': sentiment,
      'keywords': keywords,
      'summary': summary,
    };
  }

  factory Quote.fromMap(Map<String, dynamic> map) {
    return Quote(
      id: map['id'] as int?,
      date: map['date'] as String,
      content: map['content'] as String,
      aiAnalysis: map['aiAnalysis'] as String?,
      sentiment: map['sentiment'] as String?,
      keywords: (map['keywords'] as List?)?.cast<String>(),
      summary: map['summary'] as String?,
    );
  }
}