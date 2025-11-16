import 'package:flutter/material.dart';
import 'package:odoo_bridge_client/models/models.dart';
import 'package:odoo_bridge_client/odoo_bridge_client.dart';
import 'models/models.dart';

void main() {
  // Register all models for the example
  BaseOdooModelsRegistry.registerAll();
  OdooModelsRegistry.registerAll();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Odoo Bridge Client Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 0, 117, 234),
        ),
        useMaterial3: true,
      ),
      home: const OdooConnectionPage(),
    );
  }
}

class OdooConnectionPage extends StatefulWidget {
  const OdooConnectionPage({super.key});

  @override
  State<OdooConnectionPage> createState() => _OdooConnectionPageState();
}

class _OdooConnectionPageState extends State<OdooConnectionPage> {
  final _formKey = GlobalKey<FormState>();
  final _baseUrlController = TextEditingController(
    text: 'http://localhost:3000',
  );
  final _targetNameController = TextEditingController(text: 'SD-IT');
  final _loginController = TextEditingController(text: 'admin');
  final _passwordController = TextEditingController(text: 'erp@1er4932');

  Odoo? _odoo;
  bool _isLoading = false;
  String _statusMessage = '';
  bool _isConnected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Odoo Bridge Client Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Odoo Server Configuration',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _baseUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Base URL',
                          hintText: 'Enter your Odoo bridge server URL',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the base URL';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _targetNameController,
                        decoration: const InputDecoration(
                          labelText: 'Target Name',
                          hintText: 'Enter your target name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the target name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _loginController,
                        decoration: const InputDecoration(
                          labelText: 'Login',
                          hintText: 'Enter your login',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your login';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _testConnection,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Test Connection'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isLoading ? null : _authenticate,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Connect & Authenticate'),
              ),
              const SizedBox(height: 16),
              if (_statusMessage.isNotEmpty)
                Card(
                  color: _isConnected
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(_statusMessage),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              if (_isConnected && _odoo != null)
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => OdooOperationsPage(odoo: _odoo!),
                      ),
                    );
                  },
                  child: const Text('Explore Odoo Operations'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing connection...';
      _isConnected = false;
    });

    try {
      _odoo = Odoo(
        baseUrl: _baseUrlController.text.trim(),
        targetName: _targetNameController.text.trim(),
      );

      final result = await _odoo!.test();

      setState(() {
        _isLoading = false;
        if (result) {
          _statusMessage = 'Connection successful! Server is reachable.';
          _isConnected = false; // Not authenticated yet
        } else {
          _statusMessage =
              'Connection failed. Please check your server URL and target name.';
          _isConnected = false;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error: ${e.toString()}';
        _isConnected = false;
      });
    }
  }

  Future<void> _authenticate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Authenticating...';
      _isConnected = false;
    });

    try {
      _odoo = Odoo(
        baseUrl: _baseUrlController.text.trim(),
        targetName: _targetNameController.text.trim(),
      );

      final response = await _odoo!.authenticate(
        login: _loginController.text.trim(),
        password: _passwordController.text,
      );

      setState(() {
        _isLoading = false;
        if (response.success && response.value != null) {
          _statusMessage =
              'Authentication successful!\nUser: ${response.value!.name}\nEmail: ${response.value!.email}';
          _isConnected = true;
        } else {
          _statusMessage = 'Authentication failed: ${response.message}';
          _isConnected = false;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error: ${e.toString()}';
        _isConnected = false;
      });
    }
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _targetNameController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

const SEARCH_MODELS = {
  'Users': {
    'model': ResUsers,
    'searchFields': ['name', 'email', 'login'],
    'modelName': 'res.users',
  },
  'Companies': {
    'model': ResCompany,
    'searchFields': ['name', 'email', 'vat'],
    'modelName': 'res.company',
  },
  'Partners': {
    'model': ResPartner,
    'searchFields': ['name', 'email', 'phone'],
    'modelName': 'res.partner',
  },
};

class OdooOperationsPage extends StatefulWidget {
  final Odoo odoo;

  const OdooOperationsPage({super.key, required this.odoo});

  @override
  State<OdooOperationsPage> createState() => _OdooOperationsPageState();
}

class _OdooOperationsPageState extends State<OdooOperationsPage> {
  String _searchModel = SEARCH_MODELS.keys.first;
  final _searchController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  List _items = [];
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Odoo Operations'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Model to Search',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    DropdownButton<String>(
                      value: _searchModel,
                      items: SEARCH_MODELS.entries
                          .map(
                            (entry) => DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text(entry.key),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _searchModel = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Search Operations
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Search $_searchModel',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Search by name or email',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _searchItems,
                          child: const Text('Search'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _isLoading ? null : _getAllItems,
                          child: const Text('Get All'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _countItems,
                          child: const Text('Count'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Create Operations
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create New ${_searchModel.substring(0, _searchModel.length - 1)}', // Remove 's' from plural
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _createItem,
                      child: Text(
                        'Create ${_searchModel.substring(0, _searchModel.length - 1)}',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Status Message
            if (_statusMessage.isNotEmpty)
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(_statusMessage),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Results
            if (_items.isNotEmpty) ...[
              Text(
                'Items (${_items.length})',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Card(
                      child: ListTile(
                        subtitle: Text(item.toJson()),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) => _handleItemAction(value, item),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'update',
                              child: Text('Update'),
                            ),
                            const PopupMenuItem(
                              value: 'copy',
                              child: Text('Copy'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                        onTap: () => _showItemDetails(item),
                      ),
                    );
                  },
                ),
              ),
            ],

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _searchItems() async {
    if (_searchController.text.trim().isEmpty) {
      _getAllItems();
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Searching items...';
    });

    try {
      final modelInfo = SEARCH_MODELS[_searchModel]!;
      final domain = [
        '|',
        for (final field in modelInfo['searchFields'] as List<String>)
          [field, 'ilike', _searchController.text.trim()],
      ];

      // Use dynamic search based on selected model
      late final response;
      switch (_searchModel) {
        case 'Users':
          response = await Odoo.search<ResUsers>(widget.odoo, domain);
          break;
        case 'Companies':
          response = await Odoo.search<ResCompany>(widget.odoo, domain);
          break;
        case 'Partners':
          response = await Odoo.search<ResPartner>(widget.odoo, domain);
          break;
        default:
          throw Exception('Unsupported model: $_searchModel');
      }

      setState(() {
        _isLoading = false;
        if (response.success && response.value != null) {
          _items = response.value!;
          _statusMessage =
              'Found ${_items.length} items matching "${_searchController.text.trim()}"';
        } else {
          _items = [];
          _statusMessage = 'Search failed: ${response.message}';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _items = [];
        _statusMessage = 'Error searching items: ${e.toString()}';
      });
    }
  }

  Future<void> _getAllItems() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Loading all items...';
    });

    try {
      // Use dynamic search based on selected model
      late final response;
      switch (_searchModel) {
        case 'Users':
          response = await Odoo.search<ResUsers>(widget.odoo, []);
          break;
        case 'Companies':
          response = await Odoo.search<ResCompany>(widget.odoo, []);
          break;
        case 'Partners':
          response = await Odoo.search<ResPartner>(widget.odoo, []);
          break;
        default:
          throw Exception('Unsupported model: $_searchModel');
      }

      setState(() {
        _isLoading = false;
        if (response.success && response.value != null) {
          _items = response.value!;
          _statusMessage = 'Loaded ${_items.length} items';
        } else {
          _items = [];
          _statusMessage = 'Failed to load items: ${response.message}';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _items = [];
        _statusMessage = 'Error loading items: ${e.toString()}';
      });
    }
  }

  Future<void> _countItems() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Counting items...';
    });

    try {
      // Use dynamic search count based on selected model
      late final response;
      switch (_searchModel) {
        case 'Users':
          response = await Odoo.searchCount<ResUsers>(widget.odoo, []);
          break;
        case 'Companies':
          response = await Odoo.searchCount<ResCompany>(widget.odoo, []);
          break;
        case 'Partners':
          response = await Odoo.searchCount<ResPartner>(widget.odoo, []);
          break;
        default:
          throw Exception('Unsupported model: $_searchModel');
      }

      setState(() {
        _isLoading = false;
        if (response.success && response.value != null) {
          _statusMessage =
              'Total ${_searchModel.toLowerCase()} in database: ${response.value}';
        } else {
          _statusMessage =
              'Failed to count ${_searchModel.toLowerCase()}: ${response.message}';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage =
            'Error counting ${_searchModel.toLowerCase()}: ${e.toString()}';
      });
    }
  }

  Future<void> _createItem() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _statusMessage =
            'Please enter a name for the ${_searchModel.substring(0, _searchModel.length - 1).toLowerCase()}';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage =
          'Creating ${_searchModel.substring(0, _searchModel.length - 1).toLowerCase()}...';
    });

    try {
      late final Map<String, dynamic> values;
      late final response;

      switch (_searchModel) {
        case 'Users':
          values = {
            'name': _nameController.text.trim(),
            'login':
                '${_nameController.text.trim().toLowerCase().replaceAll(' ', '_')}@example.com',
            if (_emailController.text.trim().isNotEmpty)
              'email': _emailController.text.trim(),
          };
          response = await Odoo.create<ResUsers>(widget.odoo, values);
          break;
        case 'Companies':
          values = {
            'name': _nameController.text.trim(),
            if (_emailController.text.trim().isNotEmpty)
              'email': _emailController.text.trim(),
          };
          response = await Odoo.create<ResCompany>(widget.odoo, values);
          break;
        case 'Partners':
          values = {
            'name': _nameController.text.trim(),
            if (_emailController.text.trim().isNotEmpty)
              'email': _emailController.text.trim(),
          };
          response = await Odoo.create<ResPartner>(widget.odoo, values);
          break;
        default:
          throw Exception('Unsupported model: $_searchModel');
      }

      setState(() {
        _isLoading = false;
        if (response.success && response.value != null) {
          _statusMessage =
              '${_searchModel.substring(0, _searchModel.length - 1)} created successfully with ID: ${response.value}';
          _nameController.clear();
          _emailController.clear();
          // Refresh the list
          _getAllItems();
        } else {
          _statusMessage =
              'Failed to create ${_searchModel.substring(0, _searchModel.length - 1).toLowerCase()}: ${response.message}';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage =
            'Error creating ${_searchModel.substring(0, _searchModel.length - 1).toLowerCase()}: ${e.toString()}';
      });
    }
  }

  void _handleItemAction(String action, dynamic item) async {
    switch (action) {
      case 'update':
        await _updateItem(item);
        break;
      case 'copy':
        await _copyItem(item);
        break;
      case 'delete':
        await _deleteItem(item);
        break;
    }
  }

  Future<void> _updateItem(dynamic item) async {
    // Get name and email from item regardless of type
    final currentName = item.name ?? '';
    final currentEmail =
        (item is ResPartner || item is ResUsers || item is ResCompany)
        ? (item.runtimeType.toString().contains('ResPartner')
                  ? (item as ResPartner).email
                  : item.runtimeType.toString().contains('ResUsers')
                  ? (item as ResUsers).email
                  : item.runtimeType.toString().contains('ResCompany')
                  ? (item as ResCompany).email
                  : '') ??
              ''
        : '';

    final nameController = TextEditingController(text: currentName);
    final emailController = TextEditingController(text: currentEmail);

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update ${currentName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, {
              'name': nameController.text,
              'email': emailController.text,
            }),
            child: const Text('Update'),
          ),
        ],
      ),
    );

    final itemId = item.id;
    if (result != null && itemId != null) {
      setState(() {
        _isLoading = true;
        _statusMessage =
            'Updating ${_searchModel.substring(0, _searchModel.length - 1).toLowerCase()}...';
      });

      try {
        late final response;
        switch (_searchModel) {
          case 'Users':
            response = await Odoo.write<ResUsers>(widget.odoo, [
              itemId,
            ], result);
            break;
          case 'Companies':
            response = await Odoo.write<ResCompany>(widget.odoo, [
              itemId,
            ], result);
            break;
          case 'Partners':
            response = await Odoo.write<ResPartner>(widget.odoo, [
              itemId,
            ], result);
            break;
          default:
            throw Exception('Unsupported model: $_searchModel');
        }

        setState(() {
          _isLoading = false;
          if (response.success) {
            _statusMessage = 'Item updated successfully';
            _getAllItems(); // Refresh the list
          } else {
            _statusMessage = 'Failed to update item: ${response.message}';
          }
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
          _statusMessage =
              'Error updating ${_searchModel.substring(0, _searchModel.length - 1).toLowerCase()}: ${e.toString()}';
        });
      }
    }

    nameController.dispose();
    emailController.dispose();
  }

  Future<void> _copyItem(dynamic item) async {
    final itemId = item.id;
    final itemName = item.name ?? 'Unknown';
    if (itemId == null) return;

    setState(() {
      _isLoading = true;
      _statusMessage =
          'Copying ${_searchModel.substring(0, _searchModel.length - 1).toLowerCase()}...';
    });

    try {
      late final response;
      switch (_searchModel) {
        case 'Users':
          response = await Odoo.copy<ResUsers>(
            widget.odoo,
            itemId,
            defaults: {'name': '$itemName (Copy)'},
          );
          break;
        case 'Companies':
          response = await Odoo.copy<ResCompany>(
            widget.odoo,
            itemId,
            defaults: {'name': '$itemName (Copy)'},
          );
          break;
        case 'Partners':
          response = await Odoo.copy<ResPartner>(
            widget.odoo,
            itemId,
            defaults: {'name': '$itemName (Copy)'},
          );
          break;
        default:
          throw Exception('Unsupported model: $_searchModel');
      }

      setState(() {
        _isLoading = false;
        if (response.success && response.value != null) {
          _statusMessage =
              '${_searchModel.substring(0, _searchModel.length - 1)} copied successfully with ID: ${response.value}';
          _getAllItems(); // Refresh the list
        } else {
          _statusMessage =
              'Failed to copy ${_searchModel.substring(0, _searchModel.length - 1).toLowerCase()}: ${response.message}';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage =
            'Error copying ${_searchModel.substring(0, _searchModel.length - 1).toLowerCase()}: ${e.toString()}';
      });
    }
  }

  Future<void> _deleteItem(dynamic item) async {
    final itemId = item.id;
    final itemName = item.name ?? 'Unknown';
    if (itemId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete ${_searchModel.substring(0, _searchModel.length - 1)}',
        ),
        content: Text('Are you sure you want to delete "$itemName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
        _statusMessage =
            'Deleting ${_searchModel.substring(0, _searchModel.length - 1).toLowerCase()}...';
      });

      try {
        late final response;
        switch (_searchModel) {
          case 'Users':
            response = await Odoo.unlink<ResUsers>(widget.odoo, [itemId]);
            break;
          case 'Companies':
            response = await Odoo.unlink<ResCompany>(widget.odoo, [itemId]);
            break;
          case 'Partners':
            response = await Odoo.unlink<ResPartner>(widget.odoo, [itemId]);
            break;
          default:
            throw Exception('Unsupported model: $_searchModel');
        }

        setState(() {
          _isLoading = false;
          if (response.success) {
            _statusMessage =
                '${_searchModel.substring(0, _searchModel.length - 1)} deleted successfully';
            _getAllItems(); // Refresh the list
          } else {
            _statusMessage =
                'Failed to delete ${_searchModel.substring(0, _searchModel.length - 1).toLowerCase()}: ${response.message}';
          }
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
          _statusMessage =
              'Error deleting ${_searchModel.substring(0, _searchModel.length - 1).toLowerCase()}: ${e.toString()}';
        });
      }
    }
  }

  void _showItemDetails(dynamic item) {
    final itemName = item.name ?? 'Unknown';
    final itemId = item.id ?? 'Unknown';
    final itemCreateDate = item.createDate;

    // Get email field safely
    String? itemEmail;
    try {
      if (item is ResPartner) {
        itemEmail = item.email;
      } else if (item is ResUsers) {
        itemEmail = item.email;
      } else if (item is ResCompany) {
        itemEmail = item.email;
      }
    } catch (e) {
      itemEmail = null;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(itemName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: $itemId'),
            Text('Name: $itemName'),
            if (itemEmail != null && itemEmail.isNotEmpty)
              Text('Email: $itemEmail'),
            if (itemCreateDate != null) Text('Created: $itemCreateDate'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
