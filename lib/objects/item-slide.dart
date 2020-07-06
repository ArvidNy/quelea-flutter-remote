class ItemSlide {
  String lyrics;
  String title = "";

  /// A class for item slides containing lyrics and optionally a section title.
  ///
  /// Is a part of a `LiveItem` and is shown in the `LyricsView`.
  ItemSlide(this.lyrics, {this.title = ""});
}
