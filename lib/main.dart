import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox<String>('numbers');
  runApp(const NumberApp());
}

class NumberApp extends StatelessWidget {
  const NumberApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const NumberHomePage(),
    );
  }
}

class NumberHomePage extends StatefulWidget {
  const NumberHomePage({super.key});

  @override
  State<NumberHomePage> createState() => _NumberHomePageState();
}

class _NumberHomePageState extends State<NumberHomePage> {
  final Box<String> numbersBox = Hive.box<String>('numbers');
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  void _addNumber() {
    String input = _numberController.text.trim();
    if (input.isEmpty) return;

    List<String> numbersToAdd = [];

    if (input.contains('-')) {
      final parts = input.split('-');
      if (parts.length == 2) {
        int start = int.tryParse(parts[0].trim()) ?? 0;
        int end = int.tryParse(parts[1].trim()) ?? 0;

        if (start > 0 && end > 0 && end >= start) {
          for (int i = start; i <= end; i++) {
            numbersToAdd.add(i.toString());
          }
        }
      }
    } else {
      numbersToAdd.add(input);
    }

    for (var num in numbersToAdd) {
      if (!numbersBox.values.contains(num)) {
        numbersBox.add(num);
      }
    }

    _numberController.clear();
  }

  void _showAddNumberDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Add Number",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
        ),
        content: TextField(
          controller: _numberController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: "e.g. 1005 or 1005-1100",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _numberController.clear();
              Navigator.pop(context);
            },
            child: const Text("Cancel", style: TextStyle(color: Colors.redAccent),),
          ),
          ElevatedButton.icon(
            onPressed: () {
              _addNumber();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add,color: Colors.white,),
            label: const Text("Add",style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Number Store", style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.teal,
        elevation: 4,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: Text(
                "Total: ${numbersBox.length}",
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Search box
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim();
                });
              },
              decoration: InputDecoration(
                hintText: "Search number...",
                prefixIcon: const Icon(Icons.search, color: Colors.teal),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),

          // Number list
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: numbersBox.listenable(),
              builder: (context, Box<String> box, _) {
                final allNumbers = box.values.toList();
                final filteredNumbers = searchQuery.isEmpty
                    ? allNumbers
                    : allNumbers
                        .where((num) =>
                            num.toLowerCase().contains(searchQuery.toLowerCase()))
                        .toList();

                if (filteredNumbers.isEmpty) {
                  return const Center(
                    child: Text(
                      "No numbers found",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredNumbers.length,
                  itemBuilder: (context, index) {
                    final number = filteredNumbers[index];
                    final serial = index + 1;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.teal.shade100, Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(2, 2),
                          )
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal,
                          radius: 22,
                          child: Text(
                            serial.toString(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          number,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => box.deleteAt(
                              allNumbers.indexOf(filteredNumbers[index])),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.teal,
        onPressed: _showAddNumberDialog,
        icon: const Icon(Icons.add, color: Colors.white,),
        label: const Text("Add Number", style: TextStyle(color: Colors.white),),
      ),
    );
  }
}
