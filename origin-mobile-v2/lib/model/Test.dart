// ** AUTO LOADER ** //
// ** PACKAGES ** //
// ** SERVICES ** //
// ** OTHERS ** //

class Test {
  int id;
  String title;
  bool checked;

  Test({this.id, this.title, this.checked,});

  Test.fromApi(Map<String, dynamic> testFromApi){
    this.id = testFromApi['testId'];
    this.title = testFromApi['title']?.replaceAll("\n", "");
    this.checked = testFromApi['checked'];
  }

  String toString(){
    return this.title;
  }
}
