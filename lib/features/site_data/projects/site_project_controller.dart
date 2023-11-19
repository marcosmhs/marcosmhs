import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:marcosmhs/consts.dart';
import 'package:marcosmhs/features/site_data/projects/site_project_data.dart';
import 'package:teb_package/util/teb_return.dart';
import 'package:teb_package/util/teb_uid_generator.dart';

class ProjectsController with ChangeNotifier {
  Future<List<Project>> getData({required String siteName}) async {
    if (siteName.isEmpty) return [];

    final dataRef = await FirebaseFirestore.instance.collection(FirebaseConsts.projectCollectionName).get();

    final dataList = dataRef.docs.map((doc) => doc.data()).toList();

    final List<Project> r = [];
    for (var project in dataList) {
      r.add(Project.fromMap(map: project));
    }
    r.sort((a, b) => b.order.compareTo(a.order));
    return r;
  }

  Future<String> _saveImageOnStorage({
    required MemoryImage image,
    required String imageName,
  }) async {
    try {
      var ref = FirebaseStorage.instance.ref().child('images/projects/$imageName.jpeg');
      await ref.putData(
        image.bytes,
        SettableMetadata(contentType: "image/jpeg"),
      );
      String url = (await ref.getDownloadURL()).toString();
      return url;
    } catch (e) {
      return '';
    }
  }

  Future<TebCustomReturn> save({required List<Project> projectList}) async {
    try {
      for (var project in projectList) {
        if (project.status == ProjectStatus.delete) {
          await FirebaseFirestore.instance.collection(FirebaseConsts.projectCollectionName).doc(project.id).delete();
        } else {
          project.updateDate = DateTime.now();

          if (project.id.isEmpty) project.id = TebUidGenerator.firestoreUid;

          if (project.image != null) {
            project.firestorageImageUrl = await _saveImageOnStorage(
              image: project.image!,
              imageName: project.id,
            );
            if (project.firestorageImageUrl.isEmpty) {
              return TebCustomReturn.error('Erro ao salvar a foto');
            } else {
              project.externalImageUrl = '';
            }
          }

          if (project.removeFirestorageImage) {
            await FirebaseStorage.instance.refFromURL(project.firestorageImageUrl).delete();
            project.firestorageImageUrl = '';
          }
          await FirebaseFirestore.instance.collection(FirebaseConsts.projectCollectionName).doc(project.id).set(project.toMap);
        }
      }

      return TebCustomReturn.sucess;
    } catch (e) {
      return TebCustomReturn.error(e.toString());
    }
  }
}
