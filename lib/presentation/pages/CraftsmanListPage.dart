import 'package:flutter/material.dart';
import 'package:herafi/data/models/craftsmanModel.dart';
import 'package:herafi/domain/entites/craftsman.dart';
import 'package:herafi/presentation/pages/CraftsmanProfilePage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CraftsmanListPage extends StatefulWidget {
  const CraftsmanListPage({Key? key}) : super(key: key);

  @override
  _CraftsmanListPageState createState() => _CraftsmanListPageState();
}

class _CraftsmanListPageState extends State<CraftsmanListPage> {
  List<CraftsmanEntity> craftsmen = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCraftsmen();
  }

  Future<void> _fetchCraftsmen() async {
    try {
      final response = await Supabase.instance.client
          .from('craftsman')
          .select('*, users(*)')
          .then((data) => data as List<dynamic>);

      setState(() {
        craftsmen = response
            .where((json) {
              final userJson = json['users'];
              return userJson['user_type'] == 'craftsman'; 
            })
            .map((json) {
              final userJson = json['users'] as Map<String, dynamic>;
              return CraftsmanModel.fromJson({
                ...json,
                ...userJson, 
              });
            })
            .toList();

        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching craftsmen: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Craftsmen List'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : craftsmen.isEmpty
              ? const Center(child: Text('No craftsmen found.'))
              : ListView.builder(
                  itemCount: craftsmen.length,
                  itemBuilder: (context, index) {
                    final craftsman = craftsmen[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(craftsman.image ?? ''),
                        child: craftsman.image == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(craftsman.name ?? 'Unknown'),
                      subtitle: Text(craftsman.category ?? 'No category'),
                      onTap: () {
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CraftsmanProfilePage(
                              craftsmanId: craftsman.id, 
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
