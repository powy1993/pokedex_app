import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import 'poke_service.dart';
import '../utils/pokemon_names_cn.dart';

class PokemonProvider with ChangeNotifier {
  final PokeService _service = PokeService();
  
  List<PokemonListEntry> _pokemonList = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _error;

  List<PokemonListEntry> get pokemonList => _pokemonList;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get error => _error;

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
    if (_pokemonList.isNotEmpty) {
      // 已经加载过，不重复加载
      return;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pokemonList = await _service.getAllPokemon();
      _error = null;
    } catch (e) {
      debugPrint('Error fetching pokemon: $e');
      _error = '加载失败：$e';
      _pokemonList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 手动刷新
  Future<void> refresh() async {
    _pokemonList = [];
    _service.clearCache();
    await fetchAllPokemon();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
