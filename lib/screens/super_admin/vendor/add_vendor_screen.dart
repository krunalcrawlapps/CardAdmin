import 'package:card_app_admin/constant/app_constant.dart';
import 'package:card_app_admin/database/database_helper.dart';
import 'package:card_app_admin/models/vendor_model.dart';
import 'package:card_app_admin/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

class AddVendorScreen extends StatefulWidget {
  final VendorModel? vendorModel;
  const AddVendorScreen({Key? key, this.vendorModel}) : super(key: key);

  @override
  _AddVendorScreenState createState() => _AddVendorScreenState();
}

class _AddVendorScreenState extends State<AddVendorScreen> {
  //variables
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.vendorModel != null) {
      nameController.text = widget.vendorModel?.vendorName ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
                widget.vendorModel != null ? 'Edit Vendor' : 'Add Vendor')),
        body: Form(
            key: _formKey,
            child: SingleChildScrollView(
                child: Padding(
              padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
              child: Column(children: <Widget>[
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Name',
                      labelStyle: TextStyle(fontSize: 15)),
                  validator: RequiredValidator(
                      errorText: StringConstant.enter_name_validation),
                ),
                SizedBox(height: 50),
                isLoading
                    ? const CircularProgressIndicator()
                    : Container(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.orange)),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              if (widget.vendorModel != null) {
                                _updateVendor();
                              } else {
                                _addVendor();
                              }
                            }
                          },
                          child: Text(
                              widget.vendorModel != null ? 'Save' : 'Submit',
                              style: TextStyle(fontSize: 18)),
                        ),
                      )
              ]),
            ))));
  }

  _addVendor() async {
    setState(() {
      isLoading = true;
    });

    try {
      setState(() {
        isLoading = false;
      });

      VendorModel vendor = VendorModel(getRandomId(), nameController.text,
          DatabaseHelper.shared.getLoggedInUserModel()?.adminId ?? '');
      DatabaseHelper.shared.addNewVendor(vendor);

      showAlert(context, 'Vendor added successfully.', onClick: () {
        Navigator.of(context).pop();
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      showAlert(context, error.toString());
    }
  }

  _updateVendor() async {
    setState(() {
      isLoading = true;
    });

    try {
      setState(() {
        isLoading = false;
      });

      VendorModel? vendor = widget.vendorModel;
      vendor?.vendorName = nameController.text;
      DatabaseHelper.shared.addNewVendor(vendor!);

      showAlert(context, 'Vendor updated successfully.', onClick: () {
        Navigator.of(context).pop();
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      showAlert(context, error.toString());
    }
  }
}
