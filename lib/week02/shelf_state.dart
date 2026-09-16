import 'models.dart';

sealed class ShelfState {}

//1. Empty Shelf
class Empty extends ShelfState {
  Empty();
}


//2. Ready Shelf
class Ready extends ShelfState {
  final List<Book> books;
  Ready(this.books);
}

//3. Broken Shelf
class Broken extends ShelfState {
  final String message;
  Broken(this.message);
}

String describe(ShelfState state) {
  return switch (state) {
    Empty() => "Empty shelf",
    Ready(: final books) => 'The shelf is ready and it contains books: ${books.length}',
    Broken(: final message) => 'Shelf has broken: ${message}'
  };
}

({int count, double avgPages}) statsOf(List<Book> books){
  if(books.isEmpty) {
    return (count: 0, avgPages: 0.0);
  }

  final totalPages = books.fold<int>(0, (sum, b) => sum + b.pages);

  return (count: books.length,
          avgPages: totalPages / books.length);
}