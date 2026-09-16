import 'catalogue.dart';
import 'data.dart';
import 'models.dart';
import 'shelf_state.dart';

void main(){
  final library = Library(
    items: rawBooks.map<LibraryItem>(Book.fromJson).toList(),
  )..open();

  library.add(const Magazine(title: "Wired", year: 1993, issue: 42));
  library.add(const Ghost(title: 'Phantom', year: 1900));

  print('Opened at: ${library.openedAt}');
  print(library.buildReport());

  print(library.allTitles);
  print(library.booksAfter2010.map((e) => e.title,).toList());
  print(library.averagePageCount.toStringAsFixed(2));
  print(library.bookCountByAuthor);
  print(library.distinctAuthorNames);
  print(library.setOfGenres);
  print(library.countryOf('Clean Code'));
  print(library.countryOf('Design Patterns'));
  print(library.findByTitle('No Such Book'));
  library.displayList.forEach(print);

  final books = library.items.whereType<Book>().toList();
  print(books.first.borrowLabel());
  print(statsOf(books));
  print(describe(Empty()));
  print(describe(Ready(books)));
  print(describe(Broken('Shelf collapsed')));
}