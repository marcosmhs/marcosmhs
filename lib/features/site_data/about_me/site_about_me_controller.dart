import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:marcosmhs/consts.dart';
import 'package:marcosmhs/features/site_data/about_me/site_about_me_data.dart';
import 'package:teb_package/util/teb_return.dart';
import 'package:teb_package/util/teb_uid_generator.dart';

class SiteAboutMeController with ChangeNotifier {
  Future<AboutMeData> getAboutMeData({required String siteName}) async {
    if (siteName.isEmpty) {
      return AboutMeData(siteName: Consts.siteName);
    }

    final dataRef = await FirebaseFirestore.instance.collection(FirebaseConsts.aboutMeDataCollectionName).doc(siteName).get();
    final data = dataRef.data();

    if (data == null) {
      return AboutMeData(siteName: Consts.siteName);
    }

    return AboutMeData.fromMap(map: data);
  }

  Future<List<AboutMeText>> getAboutMeTextListData({required String siteName}) async {
    if (siteName.isEmpty) return [];

    final dataRef = await FirebaseFirestore.instance.collection(FirebaseConsts.aboutMeTextCollectionName).get();

    final dataList = dataRef.docs.map((doc) => doc.data()).toList();

    final List<AboutMeText> r = [];
    for (var aboutMeData in dataList) {
      r.add(AboutMeText.fromMap(map: aboutMeData));
    }
    return r;
  }

  Future<List<AboutMeTechnology>> getAboutMeTechnologyListData({required String siteName}) async {
    if (siteName.isEmpty) return [];

    final dataRef = await FirebaseFirestore.instance.collection(FirebaseConsts.aboutMeTechnologyCollectionName).get();

    final dataList = dataRef.docs.map((doc) => doc.data()).toList();

    final List<AboutMeTechnology> r = [];
    for (var aboutMeTechnology in dataList) {
      r.add(AboutMeTechnology.fromMap(map: aboutMeTechnology));
    }
    return r;
  }

  Future<String> _savePhotoOnStorage(MemoryImage photo) async {
    try {
      var ref = FirebaseStorage.instance.ref().child('images/profile/photo.jpeg');
      await ref.putData(
        photo.bytes,
        SettableMetadata(contentType: "image/jpeg"),
      );
      String url = (await ref.getDownloadURL()).toString();
      return url;
    } catch (e) {
      return '';
    }
  }

  Future<TebCustomReturn> saveAboutMeData({required AboutMeData aboutMeData}) async {
    try {
      if (aboutMeData.photo != null) {
        aboutMeData.profilePhotoUrl = await _savePhotoOnStorage(aboutMeData.photo!);
        if (aboutMeData.profilePhotoUrl.isEmpty) {
          return TebCustomReturn.error('Erro ao salvar a foto');
        }
      }
      aboutMeData.updateDate = DateTime.now();
      await FirebaseFirestore.instance
          .collection(FirebaseConsts.aboutMeDataCollectionName)
          .doc(aboutMeData.siteName)
          .set(aboutMeData.toMap);

      return TebCustomReturn.sucess;
    } catch (e) {
      return TebCustomReturn.error(e.toString());
    }
  }

  Future<TebCustomReturn> saveAboutMeTextList({required List<AboutMeText> aboutMeTextList}) async {
    try {
      for (var aboutMeText in aboutMeTextList) {
        aboutMeText.updateDate = DateTime.now();

        if (aboutMeText.id.isEmpty) {
          aboutMeText.id = TebUidGenerator.firestoreUid;
        }

        await FirebaseFirestore.instance
            .collection(FirebaseConsts.aboutMeTextCollectionName)
            .doc(aboutMeText.id)
            .set(aboutMeText.toMap);
      }

      return TebCustomReturn.sucess;
    } catch (e) {
      return TebCustomReturn.error(e.toString());
    }
  }

  Future<TebCustomReturn> saveAboutTechnologyList({required List<AboutMeTechnology> aboutMeTechnologyList}) async {
    try {
      for (var aboutMeTechnology in aboutMeTechnologyList) {
        aboutMeTechnology.updateDate = DateTime.now();

        if (aboutMeTechnology.id.isEmpty) {
          aboutMeTechnology.id = TebUidGenerator.firestoreUid;
        }

        await FirebaseFirestore.instance
            .collection(FirebaseConsts.aboutMeTechnologyCollectionName)
            .doc(aboutMeTechnology.id)
            .set(aboutMeTechnology.toMap);
      }

      return TebCustomReturn.sucess;
    } catch (e) {
      return TebCustomReturn.error(e.toString());
    }
  }
}
