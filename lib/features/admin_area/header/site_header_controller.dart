import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marcosmhs/consts.dart';
import 'package:marcosmhs/features/admin_area/header/site_header_data.dart';
import 'package:teb_package/util/teb_return.dart';

class SiteHeaderController {
  SiteHeaderController();

  Future<SiteHeaderText> getData({required String siteName}) async {
    if (siteName.isEmpty) {
      return SiteHeaderText(siteName: Consts.siteName);
    }

    final userDataRef = await FirebaseFirestore.instance.collection(FirebaseConsts.headerTextCollectionName).doc(siteName).get();
    final userData = userDataRef.data();

    if (userData == null) {
      return SiteHeaderText(siteName: Consts.siteName);
    }

    return SiteHeaderText.fromMap(map: userData);
  }

  Future<TebCustomReturn> save({required SiteHeaderText mainData}) async {
    try {
      mainData.updateDate = DateTime.now();

      await FirebaseFirestore.instance
          .collection(FirebaseConsts.headerTextCollectionName)
          .doc(mainData.siteName)
          .set(mainData.toMap);

      return TebCustomReturn.sucess;
    } catch (e) {
      return TebCustomReturn.error(e.toString());
    }
  }
}
