import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:marcosmhs/consts.dart';
import 'package:marcosmhs/features/site_data/main_data/site_main_data.dart';
import 'package:teb_package/util/teb_return.dart';

class SiteMainDataController with ChangeNotifier {
  Future<SiteMainData> getData({required String siteName}) async {
    if (siteName.isEmpty) {
      return SiteMainData(siteName: Consts.siteName);
    }

    final userDataRef = await FirebaseFirestore.instance.collection(FirebaseConsts.mainDataCollectionName).doc(siteName).get();
    final userData = userDataRef.data();

    if (userData == null) {
      return SiteMainData(siteName: Consts.siteName);
    }

    return SiteMainData.fromMap(map: userData);
  }

  Future<TebCustomReturn> save({required SiteMainData mainData}) async {
    try {
      mainData.updateDate = DateTime.now();

      await FirebaseFirestore.instance
          .collection(FirebaseConsts.mainDataCollectionName)
          .doc(mainData.siteName)
          .set(mainData.toMap);

      return TebCustomReturn.sucess;
    } catch (e) {
      return TebCustomReturn.error(e.toString());
    }
  }
}
