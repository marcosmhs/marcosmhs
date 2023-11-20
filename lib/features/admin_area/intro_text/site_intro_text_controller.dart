import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:marcosmhs/consts.dart';
import 'package:marcosmhs/features/admin_area/intro_text/site_intro_text.dart';
import 'package:teb_package/util/teb_return.dart';
import 'package:teb_package/util/teb_uid_generator.dart';

class SiteIntroTextController with ChangeNotifier {
  Future<List<IntroTextData>> getData({required String siteName}) async {
    if (siteName.isEmpty) return [];

    final dataRef = await FirebaseFirestore.instance.collection(FirebaseConsts.introTextCollectionName).get();

    final dataList = dataRef.docs.map((doc) => doc.data()).toList();

    final List<IntroTextData> r = [];
    for (var introTextData in dataList) {
      r.add(IntroTextData.fromMap(map: introTextData));
    }
    return r;
  }

  Future<TebCustomReturn> save({required List<IntroTextData> introTextDataList}) async {
    try {
      for (var introTextData in introTextDataList) {
        introTextData.updateDate = DateTime.now();

        if (introTextData.id.isEmpty) {
          introTextData.id = TebUidGenerator.firestoreUid;
        }

        await FirebaseFirestore.instance
            .collection(FirebaseConsts.introTextCollectionName)
            .doc(introTextData.id)
            .set(introTextData.toMap);
      }

      return TebCustomReturn.sucess;
    } catch (e) {
      return TebCustomReturn.error(e.toString());
    }
  }
}
