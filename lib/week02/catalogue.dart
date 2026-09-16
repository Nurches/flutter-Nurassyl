import 'models.dart';

class Library{
  //final List<LibraryItem> items and void add(LibraryItem item) 
  final List<LibraryItem> items;
  
  void add(LibraryItem item) {
    items.add(item);
  }

  Library({List<LibraryItem>? items}) : items = items ?? [];

  //late final DateTime openedAt, assigned by void open() — not in the constructor 
  late final DateTime openedAt;

  void open() {
    openedAt = DateTime.now();
  }

  //Book? findByTitle(String title) — returns null when there is none, never throws 
  Book? findByTitle(String title) {
    for (var item in items) {
      if(item is Book && item.title == title){
        return item;
      }
    }
    return null;
  }

  //String countryOf(String title) — the author country for a title, or 'unknown'; one expression with ?. and ??
  String countryOf(String title) => findByTitle(title)?.author.country ?? 'unknown';

  //•String? _cachedReport filled with ??= the first time a report is built 
  String? _cachedReport;

  String buildReport() {
    return _cachedReport ??= items.map((item) => item.describe()).join('\n');
  }
}

extension LibraryCatalogue on Library {
  //1. Every title
  List<String> get allTitles => items.map((e) => e.title).toList();

  //2. Books published after 2010
  List<Book> get booksAfter2010 => items.whereType<Book>().where((e) => e.year > 2010).toList();

  //3. fold, not reduce: reduce throws on an empty collection and must return
  // the element type (Book), while we need an int sum starting from 0.

  double get averagePageCount {
    final books = items.whereType<Book>();
    return books.isEmpty
            ? 0.0 
            : books.fold<int>(0, (sum, b) => sum + b.pages) / books.length;
  }

  //Map<String, int> from author name to number of books 
  Map<String, int> get bookCountByAuthor => items.whereType<Book>().fold<Map<String, int>>(
    {}, (map, book) => map..[book.author.name] = (map[book.author.name] ?? 0) + 1
  );

  // 5. Set<String> of distinct author names
  Set<String> get distinctAuthorNames => items.whereType<Book>().map((e) => e.author.name).toSet();

  // 6. Set<Genre> of every genre present in the library
  Set<Genre> get setOfGenres => items.whereType<Book>().map((e) => e.genre).toSet();

  List<String> get displayList => [
    'CATALOGUE',
    for(final book in items.whereType<Book>().toList()) '${book.title} (${book.year})',
    ...distinctAuthorNames,
    if(items.whereType<Book>().any((e) => e.pages == 0)) '(incomplete data)'
  ];

}