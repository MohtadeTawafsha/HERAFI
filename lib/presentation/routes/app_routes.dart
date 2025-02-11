import 'package:get/get.dart';
import 'package:herafi/presentation/bindings/MapBinding/showPointOnMap.dart';
import 'package:herafi/presentation/bindings/Project/createProjectBinding.dart';
import 'package:herafi/presentation/bindings/chatsBinding/chatPageBinding.dart';
import 'package:herafi/presentation/bindings/jobsBinding/craftsmanSearch.dart';
import 'package:herafi/presentation/bindings/orderHistoryPageBinding.dart';
import 'package:herafi/presentation/bindings/profilePageBinding.dart';
import 'package:herafi/presentation/bindings/settingPageBinding.dart';
import 'package:herafi/presentation/bindings/smsVerificationBinding.dart';
import 'package:herafi/presentation/bindings/trackingPageBinding.dart';
import 'package:herafi/presentation/pages/authPages/PravicyPolicy.dart';
import 'package:herafi/presentation/pages/authPages/RegisterCustomer.dart';
import 'package:herafi/presentation/pages/authPages/authPage.dart';
import 'package:herafi/presentation/pages/orderHistoryPage.dart';
import 'package:herafi/presentation/pages/orderProcessPage/chatsPage.dart';
import 'package:herafi/presentation/pages/settingPage.dart';
import 'package:herafi/presentation/pages/trakingPage.dart';

import '../bindings/Project/viewProject.dart';
import '../bindings/authBinding.dart';
import '../bindings/chatsBinding/chatbot_binding.dart';
import '../bindings/chatsBinding/chatsBinding.dart';
import '../bindings/homePageBinding.dart';
import '../bindings/introductionPageBinding.dart';
import '../bindings/MapBinding/selectPointOnMapScreenBinding.dart';
import '../pages/JobPages/searchForJobPage.dart';
import '../pages/MapFeature/selectPointOnMapScreen.dart';
import '../pages/MapFeature/showPointOnMap.dart';
import '../pages/account/components-of-craftsman/certificate-Page.dart';
import '../pages/account/account_screen.dart';
import '../pages/authPages/RegisterCraftsman.dart';
import '../pages/authPages/accountType.dart';
import '../pages/account/components-of-craftsman/availability-Page.dart';
import '../pages/account/components-of-customer/customer_profile_page.dart';
import '../pages/account/components-of-craftsman/edit_profile_craftsman.dart';
import '../pages/homePages/homePage.dart';
import '../pages/authPages/introductionPage.dart';
import '../pages/orderProcessPage/Chatbot.dart';
import '../pages/orderProcessPage/chatPage.dart';
import '../pages/project/ViewProject.dart';
import '../pages/project/projectPage.dart';
import '../pages/states/noInternetConnection.dart';
import '../pages/profilePage.dart';
import '../pages/authPages/smsVerificationPage.dart';
import '../pages/states/waiting.dart';

class AppRoutes {
  static const String home = '/';
  static const String auth = '/auth';
  static const String introduction = '/introduction';
  static const String smsVerification = '/smsVerification';
  static const String orderherafi = '/orderherafi';
  static const String profile = '/profile';
  static const String setting = '/setting';
  static const String orderHistory = '/orderHistory';
  static const String noInternetConnection = '/noInternetConnection';
  static const String selectPointOnMap = '/selectPointOnMap';
  static const String waitingPage = '/waitingPage';
  static const String chatpage = '/chatPage';
  static const String chatspage = '/chatsPage';
  static const String chatbot = '/chatbot';
  static const String privacyPolicy = '/privacyPolicy';
  static const String registerRole = '/RegisterRole';
  static const String accountScreen = '/AccountScreen';
  static const String availabilityScreen = '/AvailabilityScreen';
  static const String diplomaScreen = '/DiplomaScreen';
  static const String editProfileScreen = '/EditProfileScreen';
  static const String portfolioScreen = '/PortfolioScreen';
  static const String ProfilePage = '/profilePage';
  static const String registerCustomer = '/RegisterCustomer';
  static const String registerCraftsman = '/RegisterCraftsman';
  static const String accountType = '/accountType';
  static const String createJob = '/createJob';
  static const String ShowPointOnMap = '/showPointOnMap';
  static const String CraftsmanSearchPage = '/craftsmanSearchPage';
  static const String customerProfile = '/customerProfile'; // Add this route
  static const String createProject = '/createProject'; // Add this route
  static const String ViewProject = '/ViewProject'; // Add this route
  static const String tracking = '/tracking'; // Add this route

  static List<GetPage> pages = [
    GetPage(name: home, page: () => homePage(), binding: homePageBinding()),
    GetPage(
      name: introduction,
      page: () => introductionPage(),
      binding: introductionPageBinding(),
    ),
    GetPage(
      name: auth,
      page: () => authPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: smsVerification,
      page: () => smsVerificationPage(),
      binding: smsVerificationBinding(),
    ),
    GetPage(
      name: profile,
      page: () => profilePage(),
      binding: profilePageBinding(),
    ),
    GetPage(
      name: setting,
      page: () => settingPage(),
      binding: settingPageBinding(),
    ),
    GetPage(
      name: orderHistory,
      page: () => orderHistoryPage(),
      binding: orderHistoryPageBinding(),
    ),
    GetPage(
      name: noInternetConnection,
      page: () => NoInternetConnection(),
    ),
    GetPage(
      name: waitingPage,
      page: () => WaitingPage(),
    ),
    GetPage(name: chatpage, page: () => chatPage(), binding: chatPageBinding()),
    GetPage(
        name: chatspage, page: () => chatsPage(), binding: chatsPageBinding()),
    GetPage(
      name: chatbot,
      page: () => ChatbotPage(),
      binding: ChatbotBinding(),
    ),
    GetPage(
      name: privacyPolicy,
      page: () => PrivacyPolicy(),
    ),
    GetPage(
      name: accountScreen,
      page: () => AccountScreen(),
    ),
    GetPage(
      name: diplomaScreen,
      page: () => CertificateScreen(),
    ),
    GetPage(
      name: editProfileScreen,
      page: () => EditCraftsmanScreen(),
    ),
    GetPage(
      name: ProfilePage,
      page: () => profilePage(),
    ),
    GetPage(
      name: availabilityScreen,
      page: () => AvailabilityScreen(),
    ),
    GetPage(
      name: accountType,
      page: () => AccountType(),
    ),
    GetPage(
      name: registerCraftsman,
      page: () => RegisterCraftsman(),
    ),
    GetPage(
      name: registerCustomer,
      page: () => RegisterCustomer(),
    ),
    GetPage(
        name: selectPointOnMap,
        page: () => selectPointOnMapScreen(),
        binding: selectPointOnMapScreenBinding(),
        transition: Transition.downToUp),
    GetPage(
        name: ShowPointOnMap,
        page: () => showPointOnMap(),
        binding: showPointOnMapBinding(),
        transition: Transition.downToUp),
    GetPage(
        name: CraftsmanSearchPage,
        page: () => craftsmanSearchPage(),
        binding: craftsmanSearchBinding(),
        transition: Transition.downToUp),
    GetPage(
      name: customerProfile,
      page: () => CustomerProfilePage(
        customerId: '',
      ),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: createProject,
      page: () => CreateProject(),
      binding: createProjectBinding(),
    ),
    GetPage(
      name: ViewProject,
      page: () => viewProject(),
      binding: viewProjectBinding(),
    ),
    GetPage(
      name: tracking,
      page: () => trackingPage(),
      binding: trackingPageBinding(),
    ),
  ];
}
