import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';

import 'package:bake_and_go_admin/models/auth.dart';
import 'package:bake_and_go_admin/models/cart.dart';
import 'package:bake_and_go_admin/models/checkout.dart';
import 'package:bake_and_go_admin/models/order_list.dart';
import 'package:bake_and_go_admin/utils/app_routes.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {  
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers para os campos
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Usar addPostFrameCallback para acessar o contexto após a montagem do widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Auth auth = Provider.of<Auth>(context, listen: false);
      _emailController.text = auth.email ?? '';
    });
  }


  String _selectedPaymentMethod = 'Cartão de Crédito';

  TextInputFormatter _cardExpiryFormatter() {
  return TextInputFormatter.withFunction((oldValue, newValue) {
    String text = newValue.text;
    
    // Remove todos os caracteres não numéricos (para garantir apenas números)
    text = text.replaceAll(RegExp(r'[^0-9]'), '');

    // Se a entrada tiver mais de 2 caracteres, inserimos a barra ("/") após os 2 primeiros dígitos
    if (text.length >= 2 && text.length <= 5 && !newValue.text.endsWith('/')) {
      // Colocamos a barra após o mês
      text = text.substring(0, 2) + '/' + text.substring(2);
    }
    
    // Garantir que a string tenha no máximo 5 caracteres
    if (text.length > 5) {
      text = text.substring(0, 5);
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  });
}

  // Função para buscar o endereço via API (ViaCEP)
  Future<void> _fetchAddressByCep(String cep) async {
    final url = 'https://viacep.com.br/ws/$cep/json/';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Verificar se a resposta contém um "erro" (CEP não encontrado)
        if (data['erro'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('CEP não encontrado!')),
          );
        } else {
          // Preencher os campos de endereço com os dados retornados
          setState(() {
            _addressController.text = data['logradouro'] ?? '';
            _cityController.text = data['localidade'] ?? '';
            _stateController.text = data['uf'] ?? '';
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao buscar o CEP!')),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de conexão!')),
      );
    }
  }

  Future<void> _submitCheckout() async {
    if (_formKey.currentState!.validate()) {
      // Processar os dados
      final checkoutData = CheckoutData(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      city: _cityController.text,
      state: _stateController.text,
      zip: _zipController.text,
      paymentMethod: _selectedPaymentMethod,
      cardNumber: _cardNumberController.text.isNotEmpty ? _cardNumberController.text : null,
      cardName: _cardNameController.text.isNotEmpty ? _cardNameController.text : null,
      cardExpiry: _cardExpiryController.text.isNotEmpty ? _cardExpiryController.text : null,
      cardCvv: _cardCvvController.text.isNotEmpty ? _cardCvvController.text : null,
    );


      print('Checkout Data: $checkoutData');

      // Aqui você pode enviar os dados para o backend ou salvar localmente

      final Cart cart = Provider.of(context, listen: false);
      
      setState(() => _isLoading = true);

      await Provider.of<OrderList>(context, listen: false).addOrder(cart, checkoutData);

      cart.clear();

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 2),
                  content: const Text("Compra realizada sucesso"),
                ),
              );
      Navigator.of(context).pushNamed(AppRoutes.AUTH_OR_HOME);
      
    }
  }

    InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.blue, width: 2.0),
      ),
      filled: true,
      fillColor: Colors.grey.shade100,
    );
  }

  // Função para validar o número do cartão
  String? _validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira o número do cartão.';
    } else if (value.length != 16) {
      return 'O número do cartão deve ter 16 dígitos.';
    }
    return null;
  }

  // Função para validar a data de validade (MM/AA)
  String? _validateCardExpiry(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira a validade (MM/AA).';
    } else if (value.length != 5 || !RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
      return 'Data inválida. Formato esperado: MM/AA';
    }
    return null;
  }

  // Função para validar o CVV
  String? _validateCardCvv(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira o CVV.';
    } else if (value.length != 3) {
      return 'O CVV deve ter 3 dígitos.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              
              // Informações Pessoais
              const Text(
                'Informações Pessoais',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                controller: _nameController,
                decoration: _buildInputDecoration('Nome completo', Icons.person),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu nome completo.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _emailController,
                decoration: _buildInputDecoration('E-mail', Icons.email),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Por favor, insira um e-mail válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _phoneController,
                decoration: _buildInputDecoration('Telefone', Icons.phone),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu telefone.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              // Endereço
              TextFormField(
                controller: _addressController,
                decoration: _buildInputDecoration('Endereço', Icons.home),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o endereço.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _cityController,
                decoration: _buildInputDecoration('Cidade', Icons.location_city),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a cidade.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _stateController,
                decoration: _buildInputDecoration('Estado', Icons.map),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o estado.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              // Campo de CEP com a funcionalidade de consulta automática
              TextFormField(
                controller: _zipController,
                decoration: _buildInputDecoration('CEP', Icons.local_post_office),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o CEP.';
                  }
                  return null;
                },
                onChanged: (value) {
                  // Inicia a busca do endereço assim que o CEP for preenchido
                  if (value.length == 8) {
                    _fetchAddressByCep(value);
                  }
                },
              ),
              const SizedBox(height: 24.0),
              // Forma de Pagamento
              const Text(
                'Forma de Pagamento',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12.0),
              DropdownButtonFormField<String>(
                value: _selectedPaymentMethod,
                items: [
                  'Cartão de Crédito',
                  'Pix',
                  'Boleto',
                ]
                    .map((method) => DropdownMenuItem(
                          value: method,
                          child: Text(method),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
                decoration: _buildInputDecoration(
                    'Selecione o método de pagamento', Icons.payment),
              ),
              const SizedBox(height: 16.0),
              // Campos do Cartão de Crédito (Cartão de Crédito como forma de pagamento)
              if (_selectedPaymentMethod == 'Cartão de Crédito') ...[
                TextFormField(
                  controller: _cardNumberController,
                  decoration:
                      _buildInputDecoration('Número do cartão', Icons.credit_card),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o número do cartão.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _cardNameController,
                  decoration:
                      _buildInputDecoration('Nome no cartão', Icons.person),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o nome no cartão.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cardExpiryController,
                        decoration:
                            _buildInputDecoration('Validade (MM/AA)', Icons.date_range),
                        keyboardType: TextInputType.number,
                        validator: _validateCardExpiry,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(5), // MM/AA
                          _cardExpiryFormatter(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: TextFormField(
                        controller: _cardCvvController,
                        decoration:
                            _buildInputDecoration('CVV', Icons.lock),
                        keyboardType: TextInputType.number,
                        validator: _validateCardCvv,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3), // 3 dígitos CVV
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24.0),
              // Botão Finalizar
              ElevatedButton(
                onPressed: _submitCheckout,
                child: _isLoading
                  ? CircularProgressIndicator()
                  : const Text('Finalizar Compra'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _cardNumberController.dispose();
    _cardNameController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    super.dispose();
  }
}
