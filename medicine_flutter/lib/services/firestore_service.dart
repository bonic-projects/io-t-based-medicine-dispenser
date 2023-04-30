import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicine/app/app.logger.dart';
import 'package:medicine/constants/app_keys.dart';
import 'package:medicine/models/appuser.dart';

const tokenDocId = "doctor_token";

class FirestoreService {
  final log = getLogger('FirestoreApi');

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection(UsersFirestoreKey);
  final CollectionReference tokenCollection =
      FirebaseFirestore.instance.collection(TokenFirestoreKey);

  // final CollectionReference regionsCollection = FirebaseFirestore.instance.collection(RegionsFirestoreKey);

  Future<bool> createUser({required AppUser user, required keyword}) async {
    log.i('user:$user');
    try {
      final userDocument = usersCollection.doc(user.id);
      await userDocument.set(user.toJson(keyword));
      log.v('UserCreated at ${userDocument.path}');
      return true;
    } catch (error) {
      log.e("Error $error");
      return false;
    }
  }

  Future<AppUser?> getUser({required String userId}) async {
    log.i('userId:$userId');

    if (userId.isNotEmpty) {
      final userDoc = await usersCollection.doc(userId).get();
      if (!userDoc.exists) {
        log.v('We have no user with id $userId in our database');
        return null;
      }

      final userData = userDoc.data();
      log.v('User found. Data: $userData');

      return AppUser.fromData(userData! as Map<String, dynamic>);
    } else {
      log.e("Error no user");
      return null;
    }
  }

  Future<bool> updateToken({required String token}) async {
    log.i('token:$token');
    try {
      final tokenDocument = tokenCollection.doc(tokenDocId);
      await tokenDocument.set({"token": token});
      log.v('token added at ${tokenDocument.path}');
      return true;
    } catch (error) {
      log.e("Error $error");
      return false;
    }
  }

  Future<String?> getToken() async {
    final tokenDoc = await tokenCollection.doc(tokenDocId).get();
    if (!tokenDoc.exists) {
      log.v('We have no token in our database');
      return null;
    }

    final tokenData = tokenDoc.data();
    log.v('User found. Data: $tokenData');

    return (tokenData! as Map<String, dynamic>)['token'];
  }

  /// Saves the address passed in to the backend for the user and also sets
  /// the default address if the user doesn't have one set.
  /// Returns true if no errors occured
  /// Returns false for any error at any part of the process
  // Future<bool> saveAddress({
  //   required Address address,
  //   required User user,
  // }) async {
  //   log.i('address:$address');
  //
  //   try {
  //     final addressDoc = getAddressCollectionForUser(user.id).doc();
  //     final newAddressId = addressDoc.id;
  //     log.v('Address will be stored with id: $newAddressId');
  //
  //     await addressDoc.set(
  //       address.copyWith(id: newAddressId).toJson(),
  //     );
  //
  //     final hasDefaultAddress = user.hasAddress;
  //
  //     log.v('Address save complete. hasDefaultAddress:$hasDefaultAddress');
  //
  //     if (!hasDefaultAddress) {
  //       log.v(
  //           'This user has no default address. We need to set the current one as default');
  //
  //       await usersCollection.doc(user.id).set(
  //             user.copyWith(defaultAddress: newAddressId).toJson(),
  //           );
  //       log.v('User ${user.id} defaultAddress set to $newAddressId');
  //     }
  //
  //     return true;
  //   } on Exception catch (e) {
  //     log.e('we could not save the users address. $e');
  //     return false;
  //   }
  // }

  // Future<bool> isCityServiced({required String city}) async {
  //   log.i('city:$city');
  //   final cityDocument = await regionsCollection.doc(city).get();
  //   return cityDocument.exists;
  // }
  //
  // CollectionReference getAddressCollectionForUser(String userId) {
  //   return usersCollection.doc(userId).collection(AddressesFirestoreKey);
  // }
}
