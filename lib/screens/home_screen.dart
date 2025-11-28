import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/pokemon_provider.dart';
import '../utils/pokemon_names_cn.dart';
import '../services/poke_service.dart';
import '../models/pokemon.dart';
import '../utils/type_colors.dart';
import '../utils/translations.dart';
import 'detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
        title: const Text('宝可梦图鉴'),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: '搜索宝可梦 (名称或ID)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onChanged: (value) {
                Provider.of<PokemonProvider>(context, listen: false)
                    .setSearchQuery(value);
              },
            ),
          ),
          Expanded(
            child: Consumer<PokemonProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final list = provider.filteredList;

                if (list.isEmpty) {
                  return const Center(child: Text('未找到宝可梦'));
                }

                return ListView.builder(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.all(8),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final pokemon = list[index];
                    final nameCn = pokemonNamesCn[pokemon.name.toLowerCase()] ?? pokemon.name;
                    
                    return PokemonListItem(pokemon: pokemon, nameCn: nameCn);
                  },
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class PokemonListItem extends StatefulWidget {
  final PokemonListEntry pokemon;
  final String nameCn;

  const PokemonListItem({super.key, required this.pokemon, required this.nameCn});

  @override
  State<PokemonListItem> createState() => _PokemonListItemState();
}

class _PokemonListItemState extends State<PokemonListItem> {
  final PokeService _service = PokeService();
  List<String>? _types;

  @override
  void initState() {
    super.initState();
    _loadTypes();
  }

  Future<void> _loadTypes() async {
    try {
      final detail = await _service.getPokemonDetail(widget.pokemon.id);
      if (mounted) {
        setState(() {
          _types = detail.types;
        });
      }
    } catch (e) {
      // Handle error or ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(pokemonId: widget.pokemon.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
        ),
        child: Row(
          children: [
            // Number
            SizedBox(
              width: 40,
              child: Text(
                '#${widget.pokemon.id.toString().padLeft(3, '0')}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            
            // Image (1/4 size - assuming original was large, let's say 50x50 is good for list)
            SizedBox(
              width: 50,
              height: 50,
              child: CachedNetworkImage(
                imageUrl: widget.pokemon.imageUrl,
                placeholder: (context, url) => Container(color: Colors.grey[100]),
                errorWidget: (context, url, error) => const Icon(Icons.error, size: 20, color: Colors.grey),
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 16),

            // Names
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.nameCn,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    widget.pokemon.name,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Types
            if (_types != null)
              Row(
                children: _types!.map((type) {
                  return Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: typeColors[type] ?? Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      typeTranslations[type] ?? type,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
