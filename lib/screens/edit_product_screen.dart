import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = 'edit-product';

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  var _editProduct = Product(
    id: "",
    title: '',
    description: '',
    price: 0,
    imageUrl: '',
  );

  var _initvalues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  final _descriptionFocusNode = FocusNode();
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final _imageURLController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _priceFocusNode = FocusNode();

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageURLController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  var _isinit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isinit) {
      final productId = ModalRoute.of(context)!.settings.arguments == null
          ? null
          : ModalRoute.of(context)!.settings.arguments as String;

      if (productId != null) {
        _editProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initvalues = {
          'title': _editProduct.title,
          'description': _editProduct.description,
          'price': _editProduct.price.toString(),
          'imageurl': '',
        };
        _imageURLController.text = _editProduct.imageUrl;
      }
    }
    _isinit = false;
    super.didChangeDependencies();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if (_imageURLController.text.isEmpty ||
          (!_imageURLController.text.startsWith('http') &&
              !_imageURLController.text.startsWith('https')) ||
          (!_imageURLController.text.endsWith('.png') &&
              !_imageURLController.text.endsWith('.jpg') &&
              !_imageURLController.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final _valid = _form.currentState!.validate();
    if (!_valid) {
      return;
    }

    _form.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    if (_editProduct.id.isEmpty) {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editProduct);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An error occured!'),
            content: Text('Something went wrong!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text('Okay'),
              ),
            ],
          ),
        );
      } /* finally {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      } */
    } else {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editProduct.id, _editProduct);
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [
          IconButton(
            onPressed: () {
              _saveForm();
            }, //_saveForm,
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initvalues['title'],
                      decoration: InputDecoration(labelText: 'Title:'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                        //editProduct.title = value;
                        // log(value.toString());
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'please enter a value';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editProduct = Product(
                            id: _editProduct.id,
                            title: value!,
                            description: _editProduct.description,
                            price: _editProduct.price,
                            imageUrl: _editProduct.imageUrl,
                            isfavorite: _editProduct.isfavorite);
                      },
                    ),
                    TextFormField(
                      initialValue: _initvalues['price'],
                      decoration: InputDecoration(labelText: 'Price:'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (value) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                        //editProduct.price = double.parse(value);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'please enter a value';
                        }
                        if (double.tryParse(value) == null) {
                          return 'please enter a valid number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'please enter a number greater than zero.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editProduct = Product(
                            id: _editProduct.id,
                            title: _editProduct.title,
                            description: _editProduct.description,
                            price: double.parse(value!),
                            imageUrl: _editProduct.imageUrl,
                            isfavorite: _editProduct.isfavorite);
                      },
                    ),
                    TextFormField(
                      initialValue: _initvalues['description'],
                      decoration: InputDecoration(labelText: 'Description:'),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      onSaved: (value) {
                        _editProduct = Product(
                            id: _editProduct.id,
                            title: _editProduct.title,
                            description: value!,
                            price: _editProduct.price,
                            imageUrl: _editProduct.imageUrl,
                            isfavorite: _editProduct.isfavorite);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'please enter a description';
                        }
                        if (value.length < 10) {
                          return 'should be atleast 10 characters long.';
                        }
                        return null;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(
                            top: 8,
                            right: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          child: _imageURLController.text.isEmpty
                              ? Text('Enter a URL')
                              : FittedBox(
                                  child: Image.network(
                                    _imageURLController.text,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'image URL',
                            ),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageURLController,
                            focusNode: _imageUrlFocusNode,
                            onFieldSubmitted: (value) {
                              FocusScope.of(context)
                                  .requestFocus(_imageUrlFocusNode);
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'please enter a image url';
                              }
                              if (!value.startsWith('http') &&
                                  !value.startsWith('https')) {
                                return 'please enter a valid url';
                              }
                              if (!value.endsWith('.png') &&
                                  !value.endsWith('.jpg') &&
                                  !value.endsWith('.jpeg')) {
                                return 'please enter a valid url';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _editProduct = Product(
                                  id: _editProduct.id,
                                  title: _editProduct.title,
                                  description: _editProduct.description,
                                  price: _editProduct.price,
                                  imageUrl: value!,
                                  isfavorite: _editProduct.isfavorite);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
