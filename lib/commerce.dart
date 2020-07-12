class Commerce {

  String id;
  String nom;
  String adresse;
  int code_postal;
  String ville;
  String pays;
  String secteur;
  double lat;
  double long;
  String url;

  Commerce(String id, String nom, String adresse, int code_postal, String ville,
          String pays, String secteur, double lat, double long, String url) {

    this.id = id;
    this.nom = nom;
    this.adresse = adresse;
    this.code_postal = code_postal;
    this.ville = ville;
    this.pays = pays;
    this.secteur = secteur;
    this.lat = lat;
    this.long = long;
    this.url = url;

  }



}