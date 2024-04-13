// ignore_for_file: unnecessary_cast

import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:one_velocity_mobile/utils/navigator_util.dart';

import '../providers/bookmarks_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/loading_provider.dart';
import '../providers/profile_image_url_provider.dart';
import '../providers/purchases_provider.dart';
import 'string_util.dart';

//==============================================================================
//USERS=========================================================================
//==============================================================================
bool hasLoggedInUser() {
  return FirebaseAuth.instance.currentUser != null;
}

Future registerNewUser(BuildContext context, WidgetRef ref,
    {required TextEditingController emailController,
    required TextEditingController passwordController,
    required TextEditingController confirmPasswordController,
    required TextEditingController firstNameController,
    required TextEditingController lastNameController,
    required TextEditingController mobileNumberController}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  try {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty ||
        firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        mobileNumberController.text.isEmpty) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Please fill up all given fields.')));
      return;
    }
    if (!emailController.text.contains('@') ||
        !emailController.text.contains('.com')) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Please input a valid email address')));
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('The passwords do not match')));
      return;
    }
    if (passwordController.text.length < 6) {
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('The password must be at least six characters long')));
      return;
    }
    if (mobileNumberController.text.length != 11 ||
        mobileNumberController.text[0] != '0' ||
        mobileNumberController.text[1] != '9') {
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text(
              'The mobile number must be an 11 digit number formatted as: 09XXXXXXXXX')));
      return;
    }
    ref.read(loadingProvider.notifier).toggleLoading(true);
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(), password: passwordController.text);
    await FirebaseFirestore.instance
        .collection(Collections.users)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      UserFields.email: emailController.text.trim(),
      UserFields.password: passwordController.text,
      UserFields.firstName: firstNameController.text.trim(),
      UserFields.lastName: lastNameController.text.trim(),
      UserFields.mobileNumber: mobileNumberController.text,
      UserFields.userType: UserTypes.client,
      UserFields.profileImageURL: '',
      UserFields.bookmarkedProducts: [],
      UserFields.bookmarkedServices: []
    });
    scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Successfully registered new user')));
    await FirebaseAuth.instance.signOut();
    ref.read(loadingProvider.notifier).toggleLoading(false);

    navigator.pushReplacementNamed(NavigatorRoutes.login);
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error registering new user: $error')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
  }
}

Future logInUser(BuildContext context, WidgetRef ref,
    {required TextEditingController emailController,
    required TextEditingController passwordController}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  try {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Please fill up all given fields.')));
      return;
    }
    ref.read(loadingProvider.notifier).toggleLoading(true);
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text, password: passwordController.text);
    final userDoc = await getCurrentUserDoc();
    final userData = userDoc.data() as Map<dynamic, dynamic>;

    //  reset the password in firebase in case client reset it using an email link.
    if (userData[UserFields.password] != passwordController.text) {
      await FirebaseFirestore.instance
          .collection(Collections.users)
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({UserFields.password: passwordController.text});
    }
    ref
        .read(profileImageURLProvider)
        .setImageURL(userData[UserFields.profileImageURL]);
    ref.read(loadingProvider.notifier).toggleLoading(false);
    navigator.pushReplacementNamed(NavigatorRoutes.home);
  } catch (error) {
    scaffoldMessenger
        .showSnackBar(SnackBar(content: Text('Error logging in: $error')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
  }
}

Future sendResetPasswordEmail(BuildContext context, WidgetRef ref,
    {required TextEditingController emailController}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  if (!emailController.text.contains('@') ||
      !emailController.text.contains('.com')) {
    scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Please input a valid email address.')));
    return;
  }
  try {
    ref.read(loadingProvider.notifier).toggleLoading(true);
    final filteredUsers = await FirebaseFirestore.instance
        .collection(Collections.users)
        .where(UserFields.email, isEqualTo: emailController.text.trim())
        .get();

    if (filteredUsers.docs.isEmpty) {
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('There is no user with that email address.')));
      ref.read(loadingProvider.notifier).toggleLoading(false);
      return;
    }
    if (filteredUsers.docs.first.data()[UserFields.userType] !=
        UserTypes.client) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('This feature is for clients only.')));
      ref.read(loadingProvider.notifier).toggleLoading(false);
      return;
    }
    await FirebaseAuth.instance
        .sendPasswordResetEmail(email: emailController.text.trim());
    ref.read(loadingProvider.notifier).toggleLoading(false);
    scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text('Successfully sent password reset email!')));
    navigator.pop();
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error sending password reset email: $error')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
  }
}

Future<DocumentSnapshot> getCurrentUserDoc() async {
  return await getThisUserDoc(FirebaseAuth.instance.currentUser!.uid);
}

Future<String> getCurrentUserType() async {
  final userDoc = await getCurrentUserDoc();
  final userData = userDoc.data() as Map<dynamic, dynamic>;
  return userData[UserFields.userType];
}

Future<DocumentSnapshot> getThisUserDoc(String userID) async {
  return await FirebaseFirestore.instance
      .collection(Collections.users)
      .doc(userID)
      .get();
}

Future<List<DocumentSnapshot>> getAllClientDocs() async {
  final users = await FirebaseFirestore.instance
      .collection(Collections.users)
      .where(UserFields.userType, isEqualTo: UserTypes.client)
      .get();
  return users.docs;
}

Future editClientProfile(BuildContext context, WidgetRef ref,
    {required TextEditingController firstNameController,
    required TextEditingController lastNameController,
    required TextEditingController mobileNumberController}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  if (firstNameController.text.isEmpty ||
      lastNameController.text.isEmpty ||
      mobileNumberController.text.isEmpty) {
    scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Please fill up all given fields.')));
    return;
  }
  if (mobileNumberController.text.length != 11 ||
      mobileNumberController.text[0] != '0' ||
      mobileNumberController.text[1] != '9') {
    scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text(
            'The mobile number must be an 11 digit number formatted as: 09XXXXXXXXX')));
    return;
  }
  try {
    ref.read(loadingProvider.notifier).toggleLoading(true);
    await FirebaseFirestore.instance
        .collection(Collections.users)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      UserFields.firstName: firstNameController.text.trim(),
      UserFields.lastName: lastNameController.text.trim(),
      UserFields.mobileNumber: mobileNumberController.text
    });
    ref.read(loadingProvider.notifier).toggleLoading(false);
    navigator.pop();
    navigator.pushReplacementNamed(NavigatorRoutes.profile);
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error editing client profile : $error')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
  }
}

/*Future addProfilePic(BuildContext context, WidgetRef ref,
    {required Uint8List selectedImage}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);

  try {
    ref.read(loadingProvider.notifier).toggleLoading(true);

    final storageRef = FirebaseStorage.instance
        .ref()
        .child(StorageFields.profilePics)
        .child(FirebaseAuth.instance.currentUser!.uid);

    final uploadTask = storageRef.putData(selectedImage);
    final taskSnapshot = await uploadTask;
    final downloadURL = await taskSnapshot.ref.getDownloadURL();

    // Update the user's data in Firestore with the image URL
    await FirebaseFirestore.instance
        .collection(Collections.users)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      UserFields.profileImageURL: downloadURL,
    });
    scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text('Successfully added new profile picture')));
    ref.read(profileImageURLProvider.notifier).setImageURL(downloadURL);
    ref.read(loadingProvider.notifier).toggleLoading(false);
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error uploading new profile picture: $error')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
  }
}*/

Future uploadProfilePicture(BuildContext context, WidgetRef ref) async {
  try {
    ImagePicker imagePicker = ImagePicker();
    final selectedXFile =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (selectedXFile == null) {
      return;
    }
    //  Upload proof of employment to Firebase Storage
    ref.read(loadingProvider).toggleLoading(true);
    final storageRef = FirebaseStorage.instance
        .ref()
        .child(StorageFields.profilePics)
        .child(FirebaseAuth.instance.currentUser!.uid);
    final uploadTask = storageRef.putFile(File(selectedXFile.path));
    final taskSnapshot = await uploadTask;
    final String downloadURL = await taskSnapshot.ref.getDownloadURL();
    await FirebaseFirestore.instance
        .collection(Collections.users)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({UserFields.profileImageURL: downloadURL});
    ref.read(profileImageURLProvider).setImageURL(downloadURL);
    ref.read(loadingProvider).toggleLoading(false);
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading new profile picture: $error')));
    ref.read(loadingProvider).toggleLoading(false);
  }
}

Future<void> removeProfilePic(BuildContext context, WidgetRef ref) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  try {
    ref.read(loadingProvider.notifier).toggleLoading(true);
    await FirebaseFirestore.instance
        .collection(Collections.users)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({UserFields.profileImageURL: ''});

    final storageRef = FirebaseStorage.instance
        .ref()
        .child(StorageFields.profilePics)
        .child(FirebaseAuth.instance.currentUser!.uid);

    await storageRef.delete();
    scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Successfully removed profile picture.')));
    ref.read(profileImageURLProvider).removeImageURL();
    ref.read(loadingProvider).toggleLoading(false);
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error removing current profile pic: $error')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
  }
}

Future addBookmarkedProduct(BuildContext context, WidgetRef ref,
    {required String productID}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  try {
    await FirebaseFirestore.instance
        .collection(Collections.users)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      UserFields.bookmarkedProducts: FieldValue.arrayUnion([productID])
    });
    ref.read(bookmarksProvider).addProductToBookmarks(productID);
    scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text('Sucessfully added product to bookmarks.')));
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error adding product to bookmarks: $error')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
  }
}

Future removeBookmarkedProduct(BuildContext context, WidgetRef ref,
    {required String productID}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  try {
    await FirebaseFirestore.instance
        .collection(Collections.users)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      UserFields.bookmarkedProducts: FieldValue.arrayRemove([productID])
    });
    ref.read(bookmarksProvider).removeProductFromBookmarks(productID);
    scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text('Sucessfully removed product from bookmarks.')));
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error removing product to bookmarks: $error')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
  }
}

//==============================================================================
//PRODUCTS======================================================================
//==============================================================================
Future<List<DocumentSnapshot>> getAllProducts() async {
  final products =
      await FirebaseFirestore.instance.collection(Collections.products).get();
  return products.docs;
}

Future<DocumentSnapshot> getThisProductDoc(String productID) async {
  return await FirebaseFirestore.instance
      .collection(Collections.products)
      .doc(productID)
      .get();
}

Future<List<DocumentSnapshot>> getSelectedProductDocs(
    List<String> productIDs) async {
  if (productIDs.isEmpty) {
    return [];
  }
  final products = await FirebaseFirestore.instance
      .collection(Collections.products)
      .where(FieldPath.documentId, whereIn: productIDs)
      .get();
  return products.docs.map((doc) => doc as DocumentSnapshot).toList();
}

//==============================================================================
//==CART--======================================================================
//==============================================================================
Future<List<DocumentSnapshot>> getCartEntries(BuildContext context) async {
  final cartProducts = await FirebaseFirestore.instance
      .collection(Collections.cart)
      .where(CartFields.clientID,
          isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .get();
  return cartProducts.docs.map((doc) => doc as DocumentSnapshot).toList();
}

Future<DocumentSnapshot> getThisCartEntry(String cartID) async {
  return await FirebaseFirestore.instance
      .collection(Collections.cart)
      .doc(cartID)
      .get();
}

Future addProductToCart(BuildContext context, WidgetRef ref,
    {required String productID}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  if (!hasLoggedInUser()) {
    scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Please log-in to your account first.')));
    return;
  }
  try {
    if (ref.read(cartProvider).cartContainsThisItem(productID)) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('This item is already in your cart.')));
      return;
    }

    final cartDocReference =
        await FirebaseFirestore.instance.collection(Collections.cart).add({
      CartFields.productID: productID,
      CartFields.clientID: FirebaseAuth.instance.currentUser!.uid,
      CartFields.quantity: 1
    });
    ref.read(cartProvider.notifier).addCartItem(await cartDocReference.get());
    scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text('Successfully added this item to your cart.')));
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error adding product to cart: $error')));
  }
}

void removeCartItem(BuildContext context, WidgetRef ref,
    {required DocumentSnapshot cartDoc}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  try {
    ref.read(loadingProvider.notifier).toggleLoading(true);
    await cartDoc.reference.delete();

    scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text('Successfully removed this item from your cart.')));
    ref.read(cartProvider).removeCartItem(cartDoc);
    ref.read(loadingProvider.notifier).toggleLoading(false);
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error removing cart item: $error')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
  }
}

Future changeCartItemQuantity(BuildContext context, WidgetRef ref,
    {required DocumentSnapshot cartEntryDoc,
    required bool isIncreasing}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  try {
    final cartEntryData = cartEntryDoc.data() as Map<dynamic, dynamic>;
    int quantity = cartEntryData[CartFields.quantity];
    if (isIncreasing) {
      quantity++;
    } else {
      quantity--;
    }
    await FirebaseFirestore.instance
        .collection(Collections.cart)
        .doc(cartEntryDoc.id)
        .update({CartFields.quantity: quantity});
    ref.read(cartProvider).setCartItems(await getCartEntries(context));
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error changing item quantity: $error')));
  }
}

//==============================================================================
//==SERVICES====================================================================
//==============================================================================
Future<List<DocumentSnapshot>> getAllServices() async {
  final services =
      await FirebaseFirestore.instance.collection(Collections.services).get();
  return services.docs;
}

//==============================================================================
//==FAQS========================================================================
//==============================================================================
Future<List<DocumentSnapshot>> getAllFAQs() async {
  final faqs =
      await FirebaseFirestore.instance.collection(Collections.faqs).get();
  return faqs.docs;
}

Future<DocumentSnapshot> getThisFAQDoc(String faqID) async {
  return await FirebaseFirestore.instance
      .collection(Collections.faqs)
      .doc(faqID)
      .get();
}

//==============================================================================
//==PURCHASES===================================================================
//==============================================================================
Future<List<DocumentSnapshot>> getAllPurchaseDocs() async {
  final purchases =
      await FirebaseFirestore.instance.collection(Collections.purchases).get();
  return purchases.docs.reversed.toList();
}

Future purchaseSelectedCartItem(BuildContext context, WidgetRef ref,
    {required Uint8List? proofOfPayment}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  try {
    ref.read(loadingProvider.notifier).toggleLoading(true);
    //  1. Upload the proof of payment image to Firebase Storage
    String paymentID = DateTime.now().millisecondsSinceEpoch.toString();
    final storageRef = FirebaseStorage.instance
        .ref()
        .child(StorageFields.payments)
        .child('$paymentID.png');
    final uploadTask = storageRef.putData(proofOfPayment!);
    final taskSnapshot = await uploadTask.whenComplete(() {});
    final downloadURL = await taskSnapshot.ref.getDownloadURL();

    //  2. Generate a purchase document for the selected cart item
    final cartDoc =
        await getThisCartEntry(ref.read(cartProvider).selectedCartItem);
    final cartData = cartDoc.data() as Map<dynamic, dynamic>;
    final productID = cartData[CartFields.productID];
    final productDoc = await getThisProductDoc(productID);
    final productData = productDoc.data() as Map<dynamic, dynamic>;

    await FirebaseFirestore.instance
        .collection(Collections.purchases)
        .doc(paymentID)
        .set({
      PurchaseFields.productID: cartData[CartFields.productID],
      PurchaseFields.clientID: cartData[CartFields.clientID],
      PurchaseFields.quantity: cartData[CartFields.quantity],
      PurchaseFields.purchaseStatus: PurchaseStatuses.pending,
      PurchaseFields.datePickedUp: DateTime(1970),
      PurchaseFields.rating: ''
    });

    //  Added step: update the item's remaining quantity
    await FirebaseFirestore.instance
        .collection(Collections.products)
        .doc(cartData[CartFields.productID])
        .update({
      ProductFields.quantity:
          FieldValue.increment(-cartData[CartFields.quantity])
    });

    //  3. Generate a payment document in Firestore
    await FirebaseFirestore.instance
        .collection(Collections.payments)
        .doc(paymentID)
        .set({
      PaymentFields.clientID: cartData[CartFields.clientID],
      PaymentFields.paidAmount:
          productData[ProductFields.price] * cartData[CartFields.quantity],
      PaymentFields.proofOfPayment: downloadURL,
      PaymentFields.paymentVerified: false,
      PaymentFields.paymentStatus: PaymentStatuses.pending,
      PaymentFields.paymentMethod: ref.read(cartProvider).selectedPaymentMethod,
      PaymentFields.dateCreated: DateTime.now(),
      PaymentFields.dateApproved: DateTime(1970),
    });

    //  4. Delete cart entry
    await cartDoc.reference.delete();
    ref.read(cartProvider).cartItems = await getCartEntries(context);
    scaffoldMessenger.showSnackBar(const SnackBar(
        content:
            Text('Successfully settled payment and created purchase order')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error purchasing this cart item: $error')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
  }
}

Future<List<DocumentSnapshot>> getClientPurchaseHistory() async {
  final purchases = await FirebaseFirestore.instance
      .collection(Collections.purchases)
      .where(PurchaseFields.clientID,
          isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .get();
  return purchases.docs.map((doc) => doc as DocumentSnapshot).toList();
}

Future markPurchaseAsReadyForPickUp(BuildContext context, WidgetRef ref,
    {required String purchaseID}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  try {
    ref.read(loadingProvider.notifier).toggleLoading(true);

    await FirebaseFirestore.instance
        .collection(Collections.purchases)
        .doc(purchaseID)
        .update({PurchaseFields.purchaseStatus: PurchaseStatuses.forPickUp});
    ref.read(purchasesProvider).setPurchaseDocs(await getAllPurchaseDocs());
    scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text('Successfully marked purchase as ready for pick up.')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
  } catch (error) {
    scaffoldMessenger.showSnackBar(SnackBar(
        content: Text('Error marking purchase as ready for pick up: $error')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
  }
}

Future markPurchaseAsPickedUp(BuildContext context, WidgetRef ref,
    {required String purchaseID}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  try {
    ref.read(loadingProvider.notifier).toggleLoading(true);

    await FirebaseFirestore.instance
        .collection(Collections.purchases)
        .doc(purchaseID)
        .update({PurchaseFields.purchaseStatus: PurchaseStatuses.pickedUp});
    ref.read(purchasesProvider).setPurchaseDocs(await getAllPurchaseDocs());
    scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text('Successfully marked purchase picked up')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error marking purchase picked up: $error')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
  }
}
