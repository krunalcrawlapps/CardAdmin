import 'package:card_app_admin/constant/app_constant.dart';
import 'package:card_app_admin/database/database_helper.dart';
import 'package:card_app_admin/models/category_model.dart';
import 'package:card_app_admin/models/subcategory_model.dart';
import 'package:card_app_admin/screens/super_admin/sub-category/add_subcategory_screen.dart';
import 'package:card_app_admin/utils/in_app_translation.dart';
import 'package:card_app_admin/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SubCategoryListScreen extends StatefulWidget {
  const SubCategoryListScreen({Key? key}) : super(key: key);

  @override
  _SubCategoryListScreenState createState() => _SubCategoryListScreenState();
}

class _SubCategoryListScreenState extends State<SubCategoryListScreen> {
  final subCategoryRef = FirebaseFirestore.instance
      .collection(FirebaseCollectionConstant.subcategory)
      .withConverter<SubCategoryModel>(
        fromFirestore: (snapshots, _) =>
            SubCategoryModel.fromJson(snapshots.data()!),
        toFirestore: (vendor, _) => vendor.toJson(),
      );

  final categoryRef = FirebaseFirestore.instance
      .collection(FirebaseCollectionConstant.category)
      .withConverter<CategoryModel>(
        fromFirestore: (snapshots, _) =>
            CategoryModel.fromJson(snapshots.data()!),
        toFirestore: (vendor, _) => vendor.toJson(),
      );

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(AppTranslations.of(context)!
                            .text('Sub Category')),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            AddSubCategoryScreen()));
              },
              icon: Icon(Icons.add, size: 20)),
          IconButton(
              onPressed: () {
                showLogoutDialog(context);
              },
              icon: Icon(Icons.logout, size: 20))
        ],
      ),
      body: StreamBuilder<QuerySnapshot<CategoryModel>>(
        stream: categoryRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(AppTranslations.of(context)!
                            .text(snapshot.error.toString())),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.requireData;

          if (data.size == 0) {
            return SizedBox();
          }

          return ListView.builder(
            itemCount: data.size,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Padding(
                  padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Column(children: [
                    Container(
                      width: double.infinity,
                      child: Card(
                          color: Colors.white60,
                          child: Padding(
                            padding: EdgeInsets.all(5),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5),
                                  Text(data.docs[index].data().catName,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500)),
                                  SizedBox(height: 5),
                                ]),
                          )),
                    ),
                    getSubCategory(data.docs[index].data().catId)
                  ]));
            },
          );
        },
      ),
    );
  }

  Widget getSubCategory(String catId) {
    return StreamBuilder<QuerySnapshot<SubCategoryModel>>(
      stream: subCategoryRef
          .where('category_id', isEqualTo: catId)
          // .orderBy('amount', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.requireData;

        if (data.size == 0) {
          return Center(
            child: SizedBox(),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: data.size,
          itemBuilder: (context, index) {
            return Padding(
                padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Dismissible(
                  key: ValueKey<String>(data.docs[index].data().subCatId),
                  confirmDismiss: (DismissDirection direction) async {
                    showConfirmationDialog(
                        context, StringConstant.confirm_delete, () async {
                      // showLoader(context);
                      await DatabaseHelper.shared
                          .deleteSubCategory(data.docs[index].data());
                      // hideLoader(context);
                    });
                  },
                  onDismissed: (direction) {},
                  background: Container(
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 30,
                    ),
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 5),
                    decoration: BoxDecoration(
                      color: Colors.red,
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  AddSubCategoryScreen(
                                      subCategoryModel:
                                          data.docs[index].data())));
                    },
                    child: Container(
                      width: double.infinity,
                      child: Card(
                          child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 5),
                              Text(data.docs[index].data().subCatName),
                              SizedBox(height: 5),
                            ]),
                      )),
                    ),
                  ),
                ));
          },
        );
      },
    );
  }
}
