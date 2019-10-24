import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:dbcrypt/dbcrypt.dart';
// https://github.com/delay/flutter_firebase_auth_example/blob/master/lib/util/auth.dart
abstract class BaseAuth {
  Future<String> signIn(String email, String password);

  Future<String> signUp(String email, String password);

  Future<FirebaseUser> getCurrentUser();

  Future<void> sendEmailVerification();

  Future<void> signOut();

  Future<bool> isEmailVerified();

  Future<void> changeEmail(String email);

  Future<void> changePassword(String password);

  Future<void> deleteUser();

  Future<void> sendPasswordResetMail(String email);
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;


//  static void addUserSettingsDB(User user) async {
//    checkUserExist(user.userId).then((value) {
//      if (!value) {
//        print("user ${user.firstName} ${user.email} added");
//        Firestore.instance
//            .document("users/${user.userId}")
//            .setData(user.toJson());
//        _addSettings(new Settings(
//          settingsId: user.userId,
//        ));
//      } else {
//        print("user ${user.firstName} ${user.email} exists");
//      }
//    });
//  }
//
//  static void _addSettings(Settings settings) async {
//    Firestore.instance
//        .document("settings/${settings.settingsId}")
//        .setData(settings.toJson());
//  }

  static Future<bool> checkUserExist(String userId) async {
    bool exists = false;
    try {
      await Firestore.instance.document("users/$userId").get().then((doc) {
        if (doc.exists)
          exists = true;
        else
          exists = false;
      });
      return exists;
    } catch (e) {
      return false;
    }
  }


  Future<String> signIn(String email, String password) async {
    //password = new DBCrypt().hashpw(password, null);
    print("Password = " + password);
    FirebaseUser user = (await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)).user;
    return user.uid;
//    AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
//        email: email, password: password);
//    FirebaseUser user = result.user;
//    return user.uid;
  }

  Future<String> signUp(String email, String password) async {
    FirebaseUser user = (await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password)).user;
    return user.uid;
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<void> sendEmailVerification() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.isEmailVerified;
  }

  @override
  Future<void> changeEmail(String email) async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    user.updateEmail(email).then((_) {
      print("Succesfull changed email");
    }).catchError((error) {
      print("email can't be changed" + error.toString());
    });
    return null;
  }

  @override
  Future<void> changePassword(String password) async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    user.updatePassword(password).then((_) {
      print("Succesfull changed password");
    }).catchError((error) {
      print("Password can't be changed" + error.toString());
    });
    return null;
  }

  @override
  Future<void> deleteUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    user.delete().then((_) {
      print("Succesfull user deleted");
    }).catchError((error) {
      print("user can't be delete" + error.toString());
    });
    return null;
  }

  @override
  Future<void> sendPasswordResetMail(String email) async{
    await _firebaseAuth.sendPasswordResetEmail(email: email);
    return null;
  }

}