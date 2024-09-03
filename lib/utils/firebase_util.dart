// ignore_for_file: unnecessary_cast

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:one_velocity_mobile/providers/user_data_provider.dart';
import 'package:one_velocity_mobile/utils/navigator_util.dart';

import '../providers/bookmarks_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/loading_provider.dart';
import '../providers/profile_image_url_provider.dart';
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
    ref.read(userDataProvider).setName(
        '${userData[UserFields.firstName]} ${userData[UserFields.lastName]}');
    ref.read(userDataProvider).setEmail(userData[UserFields.email]);
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
    ref.read(userDataProvider).setName(
        '${firstNameController.text.trim()} ${lastNameController.text.trim()}');
    ref.read(loadingProvider.notifier).toggleLoading(false);
    navigator.pop();
    navigator.pushReplacementNamed(NavigatorRoutes.profile);
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error editing client profile : $error')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
  }
}

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
    if (!hasLoggedInUser()) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Please log-in to your account first.')));
      return;
    }
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
    if (!hasLoggedInUser()) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Please log-in to your account first.')));
      return;
    }
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

Future removeBookmarkedService(BuildContext context, WidgetRef ref,
    {required String serviceID}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  try {
    if (!hasLoggedInUser()) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Please log-in to your account first.')));
      return;
    }
    await FirebaseFirestore.instance
        .collection(Collections.users)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      UserFields.bookmarkedServices: FieldValue.arrayRemove([serviceID])
    });
    ref.read(bookmarksProvider).removeProductFromBookmarks(serviceID);
    scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text('Sucessfully removed service from bookmarks.')));
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error removing service to bookmarks: $error')));
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

Future<List<DocumentSnapshot>> getAllWheelProducts() async {
  final products = await FirebaseFirestore.instance
      .collection(Collections.products)
      .where(ProductFields.category, isEqualTo: ProductCategories.wheel)
      .get();
  return products.docs;
}

Future<List<DocumentSnapshot>> getAllBattryProducts() async {
  final products = await FirebaseFirestore.instance
      .collection(Collections.products)
      .where(ProductFields.category, isEqualTo: ProductCategories.battery)
      .get();
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
//==SERVICES====================================================================
//==============================================================================
Future<List<DocumentSnapshot>> getAllServices() async {
  final services =
      await FirebaseFirestore.instance.collection(Collections.services).get();
  return services.docs;
}

Future<DocumentSnapshot> getThisServiceDoc(String serviceID) async {
  return await FirebaseFirestore.instance
      .collection(Collections.services)
      .doc(serviceID)
      .get();
}

Future<List<DocumentSnapshot>> getSelectedServiceDocs(
    List<dynamic> serviceIDs) async {
  if (serviceIDs.isEmpty) {
    return [];
  }
  final services = await FirebaseFirestore.instance
      .collection(Collections.services)
      .where(FieldPath.documentId, whereIn: serviceIDs)
      .get();
  return services.docs.map((doc) => doc as DocumentSnapshot).toList();
}

//==============================================================================
//==CART--======================================================================
//==============================================================================
Future<List<DocumentSnapshot>> getProductCartEntries(
    BuildContext context) async {
  final cartProducts = await FirebaseFirestore.instance
      .collection(Collections.cart)
      .where(CartFields.clientID,
          isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .where(CartFields.cartType, isEqualTo: CartTypes.product)
      .get();
  return cartProducts.docs.map((doc) => doc as DocumentSnapshot).toList();
}

Future<List<DocumentSnapshot>> getServiceCartEntries(
    BuildContext context) async {
  final cartProducts = await FirebaseFirestore.instance
      .collection(Collections.cart)
      .where(CartFields.clientID,
          isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .where(CartFields.cartType, isEqualTo: CartTypes.service)
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
      CartFields.itemID: productID,
      CartFields.clientID: FirebaseAuth.instance.currentUser!.uid,
      CartFields.quantity: 1,
      CartFields.cartType: CartTypes.product
    });
    ref.read(cartProvider.notifier).addCartItem(await cartDocReference.get());
    scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text('Successfully added this item to your cart.')));
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error adding product to cart: $error')));
  }
}

Future addServiceToCart(BuildContext context, WidgetRef ref,
    {required String serviceID}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  if (!hasLoggedInUser()) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Please log-in to your account first.')));
    return;
  }
  try {
    if (ref.read(cartProvider).cartContainsThisItem(serviceID)) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('This service is already in your cart.')));
      return;
    }

    final cartDocReference =
        await FirebaseFirestore.instance.collection(Collections.cart).add({
      CartFields.itemID: serviceID,
      CartFields.clientID: FirebaseAuth.instance.currentUser!.uid,
      CartFields.quantity: 1,
      CartFields.cartType: CartTypes.service
    });
    ref.read(cartProvider.notifier).addCartItem(await cartDocReference.get());
    scaffoldMessenger.showSnackBar(SnackBar(
        content: Text('Successfully added this service to your cart.')));
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
    ref.read(cartProvider).setCartItems(await getProductCartEntries(context));
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error changing item quantity: $error')));
  }
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

Future purchaseSelectedCartItems(BuildContext context, WidgetRef ref,
    {required num paidAmount}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  try {
    ref.read(loadingProvider.notifier).toggleLoading(true);
    //  1. Generate a purchase document for the selected cart item
    List<String> purchaseIDs = [];
    for (var cartItem in ref.read(cartProvider).selectedCartItemIDs) {
      final cartDoc = await getThisCartEntry(cartItem);
      final cartData = cartDoc.data() as Map<dynamic, dynamic>;

      DocumentReference purchaseReference = await FirebaseFirestore.instance
          .collection(Collections.purchases)
          .add({
        PurchaseFields.productID: cartData[CartFields.itemID],
        PurchaseFields.clientID: cartData[CartFields.clientID],
        PurchaseFields.quantity: cartData[CartFields.quantity],
        PurchaseFields.purchaseStatus: PurchaseStatuses.pending,
        PurchaseFields.datePickedUp: DateTime(1970),
        PurchaseFields.rating: ''
      });

      purchaseIDs.add(purchaseReference.id);

      //  Added step: update the item's remaining quantity
      await FirebaseFirestore.instance
          .collection(Collections.products)
          .doc(cartData[CartFields.itemID])
          .update({
        ProductFields.quantity:
            FieldValue.increment(-cartData[CartFields.quantity])
      });

      await FirebaseFirestore.instance
          .collection(Collections.cart)
          .doc(cartItem)
          .delete();
    }

    //  2. Generate a payment document in Firestore
    DocumentReference paymentReference =
        await FirebaseFirestore.instance.collection(Collections.payments).add({
      PaymentFields.clientID: FirebaseAuth.instance.currentUser!.uid,
      PaymentFields.paidAmount: paidAmount,
      //PaymentFields.proofOfPayment: downloadURL,
      PaymentFields.paymentVerified: false,
      PaymentFields.paymentStatus: PaymentStatuses.pending,
      PaymentFields.paymentMethod: ref.read(cartProvider).selectedPaymentMethod,
      PaymentFields.dateCreated: DateTime.now(),
      PaymentFields.dateApproved: DateTime(1970),
      PaymentFields.invoiceURL: '',
      PaymentFields.purchaseIDs: purchaseIDs
    });

    //  2. Upload the proof of payment image to Firebase Storage
    final storageRef = FirebaseStorage.instance
        .ref()
        .child(StorageFields.payments)
        .child('${paymentReference.id}.png');
    final uploadTask = storageRef
        .putFile(File(ref.read(cartProvider).proofOfPaymentFile!.path));
    final taskSnapshot = await uploadTask;
    final downloadURL = await taskSnapshot.ref.getDownloadURL();

    await FirebaseFirestore.instance
        .collection(Collections.payments)
        .doc(paymentReference.id)
        .update({PaymentFields.proofOfPayment: downloadURL});

    for (var purchaseID in purchaseIDs) {
      await FirebaseFirestore.instance
          .collection(Collections.purchases)
          .doc(purchaseID)
          .update({PurchaseFields.paymentID: paymentReference.id});
    }
    ref.read(cartProvider).cartItems = await getProductCartEntries(context);

    scaffoldMessenger.showSnackBar(const SnackBar(
        content:
            Text('Successfully settled payment and created purchase order')));
    Navigator.of(context).pop();
    ref.read(cartProvider).resetSelectedCartItems();
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

//==============================================================================
//==PAYMENTS====================================================================
//==============================================================================
Future<DocumentSnapshot> getThisPaymentDoc(String paymentID) async {
  return FirebaseFirestore.instance
      .collection(Collections.payments)
      .doc(paymentID)
      .get();
}

//==============================================================================
//==BOOKING=====================================================================
//==============================================================================
Future<DocumentSnapshot> getThisBookingDoc(String bookingID) async {
  return await FirebaseFirestore.instance
      .collection(Collections.bookings)
      .doc(bookingID)
      .get();
}

Future<List<DocumentSnapshot>> getUserBookingDocs() async {
  final bookings = await FirebaseFirestore.instance
      .collection(Collections.bookings)
      .where(BookingFields.clientID,
          isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .get();
  return bookings.docs.reversed.map((e) => e as DocumentSnapshot).toList();
}

Future createNewBookingRequest(BuildContext context, WidgetRef ref,
    {required DateTime datePicked}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  try {
    ref.read(loadingProvider.notifier).toggleLoading(true);
    List<dynamic> serviceIDs = [];
    for (var cartID in ref.read(cartProvider).selectedCartItemIDs) {
      final cartDoc = await getThisCartEntry(cartID);
      final cartData = cartDoc.data() as Map<dynamic, dynamic>;
      serviceIDs.add(cartData[CartFields.itemID]);
    }
    await FirebaseFirestore.instance.collection(Collections.bookings).add({
      BookingFields.serviceIDs: serviceIDs,
      BookingFields.clientID: FirebaseAuth.instance.currentUser!.uid,
      BookingFields.dateCreated: DateTime.now(),
      BookingFields.dateRequested: datePicked,
      BookingFields.serviceStatus: ServiceStatuses.pendingApproval
    });

    for (var cartID in ref.read(cartProvider).selectedCartItemIDs) {
      await FirebaseFirestore.instance
          .collection(Collections.cart)
          .doc(cartID)
          .delete();
    }
    ref.read(cartProvider).resetSelectedCartItems();
    ref.read(cartProvider).setCartItems(await getServiceCartEntries(context));

    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Successfully requested for this service.')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
  } catch (error) {
    scaffoldMessenger.showSnackBar(SnackBar(
        content: Text('Error creating new service booking request: $error')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
  }
}

Future settleBookingRequestPayment(BuildContext context, WidgetRef ref,
    {required String bookingID,
    required List<dynamic> purchaseIDs,
    required num servicePrice}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  try {
    ref.read(loadingProvider.notifier).toggleLoading(true);
    //  1. Generate a payment document in Firestore
    await FirebaseFirestore.instance
        .collection(Collections.payments)
        .doc(bookingID)
        .set({
      PaymentFields.clientID: FirebaseAuth.instance.currentUser!.uid,
      PaymentFields.paidAmount: servicePrice,
      PaymentFields.paymentVerified: false,
      PaymentFields.paymentStatus: PaymentStatuses.pending,
      PaymentFields.paymentMethod: ref.read(cartProvider).selectedPaymentMethod,
      PaymentFields.dateCreated: DateTime.now(),
      PaymentFields.dateApproved: DateTime(1970),
      PaymentFields.invoiceURL: '',
      PaymentFields.paymentType: PaymentTypes.service,
      PaymentFields.purchaseIDs: purchaseIDs
    });

    //  3. Upload the proof of payment image to Firebase Storage
    final storageRef = FirebaseStorage.instance
        .ref()
        .child(StorageFields.payments)
        .child('${bookingID}.png');
    final uploadTask =
        storageRef.putFile(ref.read(cartProvider).proofOfPaymentFile!);
    final taskSnapshot = await uploadTask;
    final downloadURL = await taskSnapshot.ref.getDownloadURL();
    await FirebaseFirestore.instance
        .collection(Collections.payments)
        .doc(bookingID)
        .update({PaymentFields.proofOfPayment: downloadURL});

    //  2. Change bookings status
    await FirebaseFirestore.instance
        .collection(Collections.bookings)
        .doc(bookingID)
        .update(
            {BookingFields.serviceStatus: ServiceStatuses.processingPayment});
    scaffoldMessenger.showSnackBar(SnackBar(
        content: Text('Successfully settled booking request payment!')));
    navigator.pop();
    navigator.pushReplacementNamed(NavigatorRoutes.bookings);
    ref.read(loadingProvider.notifier).toggleLoading(false);
  } catch (error) {
    scaffoldMessenger.showSnackBar(SnackBar(
        content: Text('Error seetling booking request payment: $error')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
  }
}
//==============================================================================
//==MESSAGES====================================================================
//==============================================================================

Future<String> getChatDocumentId(
    String currentUserUID, String otherUserUID) async {
  final userDoc = await getCurrentUserDoc();
  final currentUserData = userDoc.data() as Map<dynamic, dynamic>;
  bool isClient = currentUserData[UserFields.userType] == UserTypes.client;
  final querySnapshot = await FirebaseFirestore.instance
      .collection(Collections.messages)
      .where(MessageFields.adminID,
          isEqualTo: isClient ? otherUserUID : currentUserUID)
      .where(MessageFields.clientID,
          isEqualTo: isClient ? currentUserUID : otherUserUID)
      .get();

  if (querySnapshot.docs.isNotEmpty) {
    return querySnapshot.docs.first.id;
  } else {
    // Chat document doesn't exist yet, create a new one
    final newChatDocRef =
        FirebaseFirestore.instance.collection(Collections.messages).doc();
    await newChatDocRef.set({
      MessageFields.adminID: isClient ? otherUserUID : currentUserUID,
      MessageFields.clientID: isClient ? currentUserUID : otherUserUID,
      MessageFields.dateTimeCreated: DateTime.now(),
      MessageFields.dateTimeSent: DateTime.now(),
      MessageFields.adminUnread: 0,
      MessageFields.clientUnread: 0
    });
    return newChatDocRef.id;
  }
}

Future submitMessage(
    {required String message,
    required bool isClient,
    required String senderUID,
    required String otherUID}) async {
  //final user = FirebaseAuth.instance.currentUser!;

  final checkMessages = await FirebaseFirestore.instance
      .collection(Collections.messages)
      .where(MessageFields.adminID, isEqualTo: isClient ? otherUID : senderUID)
      .where(MessageFields.clientID, isEqualTo: isClient ? senderUID : otherUID)
      .get();
  final chatDocument = checkMessages.docs.first;
  final messageThreadCollection =
      chatDocument.reference.collection(MessageFields.messageThread);
  DateTime timeNow = DateTime.now();
  await messageThreadCollection.add({
    MessageFields.sender: senderUID,
    MessageFields.dateTimeSent: timeNow,
    MessageFields.messageContent: message
  });
  await chatDocument.reference.update({
    MessageFields.lastMessageSent: timeNow,
    isClient ? MessageFields.adminUnread : MessageFields.clientUnread:
        FieldValue.increment(1)
  });
}

Future setClientMessagesAsRead({required String messageThreadID}) async {
  await FirebaseFirestore.instance
      .collection(Collections.messages)
      .doc(messageThreadID)
      .update({MessageFields.clientUnread: 0});
}

Future setAdminMessagesAsRead({required String messageThreadID}) async {
  await FirebaseFirestore.instance
      .collection(Collections.messages)
      .doc(messageThreadID)
      .update({MessageFields.adminUnread: 0});
}
