import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../models/product_list.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({Key? key}) : super(key: key);

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _priceFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _imageFocus = FocusNode();
  final _imageUrlController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _formData = <String, Object>{};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _imageFocus.addListener(_updateImageUrl);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_formData.isEmpty) {
      final arg = ModalRoute
          .of(context)
          ?.settings
          .arguments;

      if (arg != null) {
        final product = arg as Product;
        _formData['id'] = product.id;
        _formData['name'] = product.name;
        _formData['price'] = product.price;
        _formData['description'] = product.description;
        _formData['imageUrl'] = product.imageUrl;

        _imageUrlController.text = product.imageUrl;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _priceFocus.dispose();
    _descriptionFocus.dispose();
    _imageFocus.removeListener(_updateImageUrl);
    _imageFocus.dispose();
  }

  void _updateImageUrl() {
    setState(() {});
  }

  bool isValidUrl(String url) {
    bool isValid = Uri
        .tryParse(url)
        ?.hasAbsolutePath ?? false;
    bool endsWithFileExtension = url.endsWith('.png') ||
        url.endsWith('.jpg') ||
        url.endsWith('.jpeg') ||
        url.endsWith('.gif');
    return isValid && endsWithFileExtension;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      setState(() => _isLoading = true);
      try {
        await Provider.of<ProductList>(context, listen: false)
            .saveProduct(_formData);
      } catch (e) {
        await showDialog<void>(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: const Text('An error occurred!'),
              content: const Text('Something went wrong.'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Okay'))
              ],
            );
          },
        );
      } finally {
        setState(() => _isLoading = false);
        Navigator.of(context).pop();
      }
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Product Form'),
      actions: [
        IconButton(
          onPressed: _submitForm,
          icon: const Icon(Icons.save),
        ),
      ],
    ),
    body: _isLoading
        ? const Center(
      child: CircularProgressIndicator(),
    )
        : Padding(
      padding: const EdgeInsets.all(15.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              initialValue: _formData['name'] as String?,
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.name,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_priceFocus);
              },
              onSaved: (value) => _formData['name'] = value ?? 'null',
              validator: (value) {
                if (value == null || value
                    .trim()
                    .isEmpty) {
                  return 'Invalid name!';
                }
                if (value
                    .trim()
                    .length < 3) {
                  return 'Name is too short!';
                }
                return null;
              },
            ),
            TextFormField(
              initialValue: _formData['price']?.toString(),
              decoration: const InputDecoration(
                labelText: 'Price',
              ),
              focusNode: _priceFocus,
              textInputAction: TextInputAction.next,
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_descriptionFocus);
              },
              onSaved: (value) =>
              _formData['price'] = double.parse(value ?? '0'),
              validator: (value) {
                final newPrice = double.tryParse(value ?? '');
                if (newPrice == null || newPrice <= 0) {
                  return 'Invalid price!';
                }
                return null;
              },
            ),
            TextFormField(
              initialValue: _formData['description'] as String?,
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
              focusNode: _descriptionFocus,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.multiline,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_imageFocus);
              },
              maxLines: 3,
              onSaved: (value) =>
              _formData['description'] = value ?? 'null',
              validator: (value) {
                if (value == null || value
                    .trim()
                    .isEmpty) {
                  return 'Invalid description!';
                }
                if (value
                    .trim()
                    .length < 10) {
                  return 'Description is too short!';
                }
                return null;
              },
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Image URL',
                    ),
                    focusNode: _imageFocus,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.url,
                    controller: _imageUrlController,
                    onFieldSubmitted: (_) => _submitForm(),
                    onSaved: (value) =>
                    _formData['imageUrl'] = value ?? 'null',
                    validator: (url) {
                      if (!isValidUrl(url ?? '')) {
                        return 'Invalid URL!';
                      }
                      return null;
                    },
                  ),
                ),
                Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.only(top: 8, left: 10),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(width: 1, color: Colors.grey),
                      left: BorderSide(width: 1, color: Colors.grey),
                      right: BorderSide(width: 1, color: Colors.grey),
                      bottom: BorderSide(width: 1, color: Colors.grey),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: _imageUrlController.text.isEmpty
                      ? const Text('Enter a URL')
                      : Image.network(_imageUrlController.text),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}}
