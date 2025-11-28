import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import 'poke_service.dart';
import '../utils/pokemon_names_cn.dart';

class PokemonProvider with ChangeNotifier {
  final PokeService _service = PokeService();
  
  List<PokemonListEntry> _pokemonList = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<PokemonListEntry> get pokemonList => _pokemonList;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  List<PokemonListEntry> get filteredList {
    if (_searchQuery.isEmpty) {
      return _pokemonList;
    }
    final query = _searchQuery.toLowerCase();
    return _pokemonList.where((p) {
      final englishName = p.name.toLowerCase();
      final chineseName = pokemonNamesCn[englishName] ?? '';
      
      return englishName.contains(query) ||
             chineseName.contains(query) ||
             p.id.toString().contains(query);
    }).toList();
  }

  PokemonProvider() {
    Future.microtask(() => fetchAllPokemon());
  }

  Future<void> fetchAllPokemon() async {
    _isLoading = true;
    notifyListeners();

    try {
      _pokemonList = await _service.getAllPokemon();
    } catch (e) {
      debugPrint('Error fetching pokemon: $e');
      _pokemonList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
