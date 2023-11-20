import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marcosmhs/consts.dart';
import 'package:marcosmhs/features/admin_area/experience/site_experience_data.dart';
import 'package:teb_package/util/teb_return.dart';
import 'package:teb_package/util/teb_uid_generator.dart';

class ExperienceController with ChangeNotifier {
  Future<List<Experience>> getData({required String siteName}) async {
    if (siteName.isEmpty) return [];

    final dataRef = await FirebaseFirestore.instance.collection(FirebaseConsts.experienceCollectionName).get();

    final dataList = dataRef.docs.map((doc) => doc.data()).toList();

    final List<Experience> r = [];
    for (var experience in dataList) {
      r.add(Experience.fromMap(map: experience));
    }
    r.sort((a, b) => b.order.compareTo(a.order));
    return r;
  }

  Future<TebCustomReturn> save({required List<Experience> experienceList}) async {
    try {
      for (var experience in experienceList) {
        if (experience.status == ExperienceStatus.delete) {
          await FirebaseFirestore.instance.collection(FirebaseConsts.experienceCollectionName).doc(experience.id).delete();
        } else {
          experience.updateDate = DateTime.now();
          if (experience.id.isEmpty) experience.id = TebUidGenerator.firestoreUid;

          await FirebaseFirestore.instance
              .collection(FirebaseConsts.experienceCollectionName)
              .doc(experience.id)
              .set(experience.toMap);
        }
      }

      return TebCustomReturn.sucess;
    } catch (e) {
      return TebCustomReturn.error(e.toString());
    }
  }
}
