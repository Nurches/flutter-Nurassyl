
// •abstract class LibraryItem — final title and year, an abstract String describe(), and a getter isOld with a body 
abstract class LibraryItem {
  final String title;
  final int year;

  const LibraryItem({required this.title, required this.year});

  String describe();

  bool get isOld => year < DateTime.now().year - 50;
}


// •mixin Borrowable on LibraryItem — String borrowLabel() built from title; mix it into Book only 
mixin Borrowable on LibraryItem {
  String borrowLabel() => 'Borrow "$title"';
}

// •class Ghost implements LibraryItem — every member written by hand, nothing inherited: the final fields become @override declarations you write yourself 
class Ghost implements LibraryItem {
  @override
  final String title;

  @override
  final int year;

  const Ghost({
    required this.title,
    required this.year
  });

  @override
  String describe() {
    return 'Ghost: $title, published in $year';
  }

  @override
  bool get isOld => year < DateTime.now().year - 50;
}

class Author {
  final String name;
  final String? country;
  const Author({required this.name, this.country});

  @override
  String toString() {
    return 'Author(name: $name, country: $country)';
  }
}

//Genre enum with a static method fromString(String? raw) that returns the corresponding Genre value or Genre.unknown if the string does not match any of the enum values
enum Genre { 
  craft('Craft'), 
  theory('Theory'), 
  unknown('Unknown');

  final String label;
  const Genre(this.label);

  static Genre fromString(String? raw){
    return Genre.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => Genre.unknown,
    );
  }
}


// •Book extends LibraryItem — implements describe() 
class Book extends LibraryItem with Borrowable {
  final int pages;
  final Author author;
  final Genre genre;
  final String? description;
  
  const Book({
    required String title,
    required int year,
    required this.pages,
    required this.author,
    required this.genre,
    this.description,
  }) : super(title: title, year: year);

  //Factory constructor to create a unknown Book instance 
  const Book.missing()
      : pages = 0,
        author = const Author(name: 'Unknown'),
        genre = Genre.unknown,
        description = null,
        super(title: 'Unknown', year: 0);


  factory Book.fromJson(Map<String, dynamic> json){
    final author = Author(
      name: json['author'] as String? ?? 'Unknown',
      country: json['country'] as String?,
    );

    return Book(
      title: json['title'] as String? ?? 'Unknown',
      year: json['year'] as int? ?? 0,
      pages: json['pages'] as int? ?? 0,
      author: author,
      genre: Genre.fromString(json['genre'] as String?),
      description: json['description'] as String?
    );
  }

  //getter isLong
  bool get isLong => pages > 400;

  //override describe() method
  @override
  String describe() {
    return 'Book: $title, written by ${author.name} in $year, ${pages} pages, genre: ${genre.name}, description: ${description ?? 'No description'}';
  }

  //method copyWith
  Book copyWith({
    String? title,
    int? year,
    int? pages,
    Author? author,
    Genre? genre,
    Object? description = const _Sentinel(),
  }){
    return Book(
      title: title ?? this.title,
      year: year ?? this.year,
      pages: pages ?? this.pages,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      description: description is _Sentinel 
        ? this.description 
        : description as String?,
    );
  }

  @override
  String toString() {
    return 'Book(title: $title, year: $year, pages: $pages, author: $author, genre: $genre, description: $description)';
  }
}

class _Sentinel {
  const _Sentinel();
}


// •Magazine extends LibraryItem — final issue, implements describe() 
class Magazine extends LibraryItem {
  final int issue;

  const Magazine({
    required String title,
    required int year,
    required this.issue,
  }) : super(title: title, year: year);

  @override
  String describe() {
    return 'Magazine: $title, issue $issue, published in $year';
  }
}

