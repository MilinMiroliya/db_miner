class Quote {
  final int id;
  final String text;
  final String author;
  final String category;

  Quote(
      {required this.id,
      required this.text,
      required this.author,
      required this.category});

  Map<String, dynamic> toMap() {
    return {'id': id, 'text': text, 'author': author, 'category': category};
  }
}
