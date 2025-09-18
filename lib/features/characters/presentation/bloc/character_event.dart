abstract class CharacterEvent {}

class GetCharactersEvent extends CharacterEvent {
  final int offset;
  final int limit;

  GetCharactersEvent({this.offset = 0, this.limit = 20});
}

class GetFeaturedCharactersEvent extends CharacterEvent {}

class LoadMoreCharactersEvent extends CharacterEvent {}

class SearchCharactersEvent extends CharacterEvent {
  final String query;
  final int limit;

  SearchCharactersEvent(this.query, {this.limit = 20});
}

class ScrollEvent extends CharacterEvent {
  final double scrollPosition;
  final double maxScrollExtent;

  ScrollEvent(this.scrollPosition, this.maxScrollExtent);
}
