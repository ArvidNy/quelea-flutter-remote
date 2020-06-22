/// A class to parse and use the status data.
class StatusItem {
  bool logo = false;
  bool black = false;
  bool clear = false;
  String play = "Play";
  bool record = false;

  StatusItem parseStatus(String html) {
    List<String> status = html.split(",");
    logo = status[0] == "true";
    black = status[1] == "true";
    clear = status[2] == "true";
    play = status[3];
    record = status[4] == "true"; 
    return this;
  }
}
