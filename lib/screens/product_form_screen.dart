// ignore_for_file: unused_import

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/app_drawer.dart';
import 'package:shop/models/category.dart';
import 'package:shop/models/category_list.dart';
import 'package:shop/models/product.dart';
import 'package:shop/models/product_list.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _priceFocus = FocusNode();

  final _categoryFocus = FocusNode();

  final _descriptionFocus = FocusNode();

  final _imageUrlFocus = FocusNode();
  final _imageUrlcontroller = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _formData = Map<String, Object>();

  late final List<ProductCategory> _categories;

  bool _isLoading = false;

  void updateImage() {
    setState(() {});
  }

  bool isValidImageUrl(String url) {
    bool isValidUrl = Uri.tryParse(url)?.hasAbsolutePath ?? false;

    bool endsWithFile = url.toLowerCase().endsWith('.png') ||
        url.toLowerCase().endsWith('.jpg') ||
        url.toLowerCase().endsWith('.jpeg');

    return isValidUrl && endsWithFile;
  }

  Future<void> _submitForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    _formKey.currentState?.save();

    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<ProductList>(context, listen: false)
          .saveProduct(_formData);

      Navigator.of(context).pop();
    } catch (e) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Ocorreu um erro"),
          content: const Text('Ocorreu um erro ao salvar o produto'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Ok"),
            ),
          ],
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
void initState() {
  super.initState();

  _imageUrlFocus.addListener(updateImage);

  _categories = Provider.of<CategoryList>(context, listen: false).items;
}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_formData.isEmpty) {
      final arg = ModalRoute.of(context)?.settings.arguments;

      if (arg != null) {
        final product = arg as Product;

        _formData['id'] = product.id;
        _formData['name'] = product.name;
        _formData['price'] = product.price;
        _formData['categoryId'] = product.categoryId == null ? '' : product.categoryId;
        _formData['description'] = product.description;
        _formData['imageUrl'] = product.imageUrl;

        _imageUrlcontroller.text = product.imageUrl;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();

    _priceFocus.dispose();

    _categoryFocus.dispose();

    _descriptionFocus.dispose();

    _imageUrlFocus.dispose();
    _imageUrlFocus.removeListener(updateImage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          "Formulário de Produto",
        ),
        actions: [
          IconButton(
            onPressed: () {
              _submitForm();
            },
            icon: const Icon(Icons.save),
          )
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: (_formData['name'] ?? '') as String,
                      decoration: InputDecoration(
                        labelText: "Nome",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_priceFocus),
                      onSaved: (name) => _formData['name'] = name ?? '',
                      validator: (_name) {
                        final name = _name ?? '';

                        if (name.trim().isEmpty) {
                          return 'Nome é obrigatório';
                        }

                        if (name.trim().length < 3) {
                          return 'Nome precisa de no mínimo de 3 letras';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    TextFormField(
                      initialValue: _formData['price']?.toString(),
                      decoration: InputDecoration(
                        labelText: "Preço",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      focusNode: _priceFocus,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_priceFocus),
                      onSaved: (price) => _formData['price'] = double.parse(
                          price != null && price.isNotEmpty
                              ? price.replaceAll(',', '.')
                              : '0'),
                      validator: (_price) {
                        final priceString = _price ?? '';
                        final price =
                            double.tryParse(priceString.replaceAll(',', '.')) ??
                                -1;

                        if (price <= 0) {
                          return 'Informe um preço válido';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Categoria",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      value: _categories.any((category) => category.id == _formData['categoryId'])
                        ? _formData['categoryId'] as String?
                        : null,

                      items: [
                        const DropdownMenuItem<String>(
                          value: null, // Valor para a opção padrão
                          child: Text(
                            'Selecione a categoria',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        ..._categories.map(
                          (category) => DropdownMenuItem<String>(
                            value: category.id,
                            child: Text(category.name, style: TextStyle(color: Colors.black,)),
                          ),
                        ),
                      ],
                      onChanged: (selectedCategory) {
                        setState(() {
                          _formData['categoryId'] = selectedCategory ?? '';
                        });
                      },
                      onSaved: (selectedCategory) {
                        _formData['categoryId'] = selectedCategory ?? '';
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, selecione uma categoria';
                        }
                        return null;
                      },
                      style: const TextStyle(fontSize: 16),
                      dropdownColor: Colors.white,
                      icon: const Icon(Icons.arrow_drop_down),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    TextFormField(
                      initialValue: _formData['description']?.toString(),
                      decoration: InputDecoration(
                        labelText: "Descrição",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      focusNode: _descriptionFocus,
                      onSaved: (description) =>
                          _formData['description'] = description ?? '',
                      validator: (_description) {
                        final description = _description ?? '';

                        if (description.trim().isEmpty) {
                          return 'Descrição é obrigatório';
                        }

                        if (description.trim().length < 10) {
                          return 'Descrição precisa de no mínimo de 10 letras';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: "URL da Imagem",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            focusNode: _imageUrlFocus,
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlcontroller,
                            onFieldSubmitted: (value) => _submitForm(),
                            onSaved: (imageUrl) =>
                                _formData['imageUrl'] = imageUrl ?? '',
                            validator: (_imageUrl) {
                              final imageUrl = _imageUrl ?? '';

                              if (!isValidImageUrl(imageUrl)) {
                                return 'Informe uma Url válida';
                              }

                              return null;
                            },
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 10),
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1)),
                          alignment: Alignment.center,
                          child: _imageUrlcontroller.text.isEmpty
                              ? const Text("Informe a Url")
                              : SizedBox(
                                  height: 100,
                                  width: 100,
                                  child: FittedBox(
                                      child: Image.network(
                                    _imageUrlcontroller.text,
                                    fit: BoxFit.cover,
                                  )),
                                ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
