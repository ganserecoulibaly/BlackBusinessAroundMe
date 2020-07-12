import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:url_launcher/url_launcher.dart';

class wanted extends StatelessWidget {

  String title;
  final  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _nom;
  String _prenom;
  String _email;
  String _business;

  wanted(String title) {
    this.title = title;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: new Center(
        child: new Column(
          children: <Widget>[
            Text('Faites votre demande de nouvueau business \n Précisez le type de commerce et le lieu dans le champ Business'),
            _buildForm()
          ],
        )

      ),
        bottomNavigationBar: BottomAppBar(
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                //ajout nouveau commerce
                icon: Icon(Icons.add),
                color: Colors.black,
                onPressed: () {},
              ),
              IconButton(
                //refresh la map
                icon: Icon(Icons.refresh),
                color: Colors.black,
                onPressed: () {
                  Navigator.pushNamed(context, '/homepage');
                },
              ),
              IconButton(
                //demander un nouveau commerce
                icon: Icon(Icons.contact_mail),
                color: Colors.black,
                onPressed: (){
                  Navigator.pushNamed(context, '/wanted');
                },
              )
            ],
          ),
        )
    );
  }

  Widget _buildForm() {
    return Container(
      //margin: EdgeInsets.all(5),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 10),
            _buildNomField(),
            _buildPrenomField(),
            _buildEmailField(),
            _buildBusinessField(),
            SizedBox(height: 10),
          RaisedButton(
           onPressed: () {
            print('soumission du formulaire');
            if (_formKey.currentState.validate()) {
              //onSaved is called!
              _formKey.currentState.save();
            /*  print(_nom);
              print(_prenom);
              print(_business);
              print(_email); */
              _testSendMail(_nom, _prenom, _business, _email);
              return;
            }

           },
            child: Text('Envoyer'),
           )
             ],
            )
      )
    );
  }

  Widget _buildNomField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Nom'),
      validator: (String value) {
        if (value.isEmpty) {
          return 'le nom est requis';
        }
        return null;
      },
      onSaved: (String value) {
        _nom = value;
      },
    );
  }

  Widget _buildPrenomField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Prénom'),
        validator: (String value) {
          if (value.isEmpty) {
            return 'le prénom est requis';
          }
          return null;
        },
      onSaved: (String value) {
      _prenom = value;
    },
    );
  }

  Widget _buildBusinessField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Business'),
        validator: (String value) {
          if (value.isEmpty) {
            return 'le business demandé est requis';
          }
          return null;
        },
      onSaved: (String value) {
        _business = value;
      },
    );
  }


  Widget _buildEmailField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Email'),
      validator: (String value) {
        if (!RegExp(
            r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
            .hasMatch(value)) {
          return 'Email non valide';
        }
        return null;
      },
      onSaved: (String value) {
        _email = value;
      },
    );
  }

    void _testSendMail(String _nom, String  _prenom, String _business, String _email) async {

      final Email email = Email(
        body: 'Bonjour, je suis '+ _nom +' '+  _prenom  + '.\n'
            'Je souhaiterais que ma demande concernant : ' + _business + ' soit prise en compte.\n Mon mail est ' +_email +'.\n'
            'Cordialement.',
        subject: 'Souhait de nouveau business',
        recipients: ['gansere.factory@gmail.com'],
      );
      await FlutterEmailSender.send(email);
    }

}