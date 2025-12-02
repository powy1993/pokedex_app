import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/pokemon.dart';
import '../utils/move_data.dart';
import '../utils/ability_data.dart';

class PokeService {
  static const String baseUrl = 'https://pokeapi.co/api/v2';
  
  // 单例模式
  static final PokeService _instance = PokeService._internal();
  factory PokeService() => _instance;
  PokeService._internal();

  // Cache for translations to avoid repeated API calls
  final Map<String, String> _translationCache = {};
  
  // Cache for Pokemon details
  final Map<int, PokemonDetail> _detailCache = {};
  
  // Cache for Pokemon species
  final Map<int, PokemonSpecies> _speciesCache = {};
  
  // Cache for evolution chains
  final Map<String, EvolutionChain> _evolutionChainCache = {};
  
  // Cache for ability info
  final Map<String, Map<String, String>> _abilityCache = {};
  
  // Cache for move details
  final Map<String, Map<String, dynamic>> _moveCache = {};
  
  // 清除所有缓存
  void clearCache() {
    _translationCache.clear();
    _detailCache.clear();
    _speciesCache.clear();
    _evolutionChainCache.clear();
    _abilityCache.clear();
    _moveCache.clear();
  }

  Future<List<PokemonListEntry>> getPokemonList({int limit = 20, int offset = 0}) async {
    final response = await http.get(Uri.parse('$baseUrl/pokemon?limit=$limit&offset=$offset'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((json) => PokemonListEntry.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load pokemon list');
    }
  }

  Future<List<PokemonListEntry>> getPokemonByGeneration(int generationId) async {
    final response = await http.get(Uri.parse('$baseUrl/generation/$generationId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List species = data['pokemon_species'];
      // Sort by ID to make it look nicer
      species.sort((a, b) {
        final idA = _getIdFromUrl(a['url']);
        final idB = _getIdFromUrl(b['url']);
        return idA.compareTo(idB);
      });
      
      return species.map((json) {
        // Convert species url to pokemon url (usually same ID)
        // Species: https://pokeapi.co/api/v2/pokemon-species/1/
        // Pokemon: https://pokeapi.co/api/v2/pokemon/1/
        final id = _getIdFromUrl(json['url']);
        return PokemonListEntry(
          name: json['name'],
          url: '$baseUrl/pokemon/$id/',
        );
      }).toList();
    } else {
      throw Exception('Failed to load generation $generationId');
    }
  }

  Future<PokemonDetail> getPokemonDetail(int id) async {
    // 检查缓存
    if (_detailCache.containsKey(id)) {
      return _detailCache[id]!;
    }
    
    final response = await http.get(Uri.parse('$baseUrl/pokemon/$id'));

    if (response.statusCode == 200) {
      final detail = PokemonDetail.fromJson(json.decode(response.body));
      // 缓存结果
      _detailCache[id] = detail;
      return detail;
    } else {
      throw Exception('Failed to load pokemon detail $id');
    }
  }

  Future<PokemonSpecies> getPokemonSpecies(int id) async {
    // 检查缓存
    if (_speciesCache.containsKey(id)) {
      return _speciesCache[id]!;
    }
    
    final response = await http.get(Uri.parse('$baseUrl/pokemon-species/$id'));

    if (response.statusCode == 200) {
      final species = PokemonSpecies.fromJson(json.decode(response.body));
      // 缓存结果
      _speciesCache[id] = species;
      return species;
    } else {
      throw Exception('Failed to load pokemon species $id');
    }
  }

  Future<EvolutionChain> getEvolutionChain(String url) async {
    // 检查缓存
    if (_evolutionChainCache.containsKey(url)) {
      return _evolutionChainCache[url]!;
    }
    
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final chain = EvolutionChain.fromJson(json.decode(response.body));
      // 缓存结果
      _evolutionChainCache[url] = chain;
      return chain;
    } else {
      throw Exception('Failed to load evolution chain');
    }
  }

  Future<Map<String, String>> getAbilityInfo(String url) async {
    // 检查缓存
    if (_abilityCache.containsKey(url)) {
      return _abilityCache[url]!;
    }
    
    // Resolve local data
    Map<String, dynamic>? localData;
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      String idOrSlug =
          segments.last.isEmpty ? segments[segments.length - 2] : segments.last;

      if (int.tryParse(idOrSlug) != null) {
        final id = int.parse(idOrSlug);
        if (abilityIdToSlug.containsKey(id)) {
          localData = abilityDetailsData[abilityIdToSlug[id]];
        }
      } else {
        if (abilityDetailsData.containsKey(idOrSlug)) {
          localData = abilityDetailsData[idOrSlug];
        }
      }
    } catch (_) {}

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        String name = (data['names'] as List).firstWhere(
          (n) => n['language']['name'] == 'zh-Hans',
          orElse: () => {'name': data['name']},
        )['name'];

        String flavorText = '';
        final entries = (data['flavor_text_entries'] as List);
        if (entries.isNotEmpty) {
          final entry = entries.firstWhere(
            (e) => e['language']['name'] == 'zh-Hans',
            orElse: () => entries.firstWhere(
                (e) => e['language']['name'] == 'en',
                orElse: () => {'flavor_text': ''}),
          );
          flavorText = entry['flavor_text'].toString().replaceAll('\n', ' ');
        }

        // Overwrite with local data if available
        if (localData != null) {
          name = localData['name'];
          flavorText = localData['description'];
        }

        final result = {'name': name, 'flavorText': flavorText};
        // 缓存结果
        _abilityCache[url] = result;
        return result;
      }
    } catch (e) {
      // Error fetching ability info, will use local data
    }

    // Fallback to local data
    if (localData != null) {
      final result = <String, String>{
        'name': localData['name'].toString(),
        'flavorText': localData['description'].toString()
      };
      // 缓存结果
      _abilityCache[url] = result;
      return result;
    }

    final fallback = <String, String>{'name': 'Unknown', 'flavorText': ''};
    _abilityCache[url] = fallback;
    return fallback;
  }

  Future<List<PokemonListEntry>> getAllPokemon() async {
    // Fetch all pokemon (limit 10000 to get all)
    final response = await http.get(Uri.parse('$baseUrl/pokemon?limit=10000&offset=0'));

    if (response.statusCode == 200) {
      return compute(_parsePokemonList, response.body);
    } else {
      throw Exception('Failed to load all pokemon');
    }
  }

  static List<PokemonListEntry> _parsePokemonList(String responseBody) {
    final data = json.decode(responseBody);
    final List results = data['results'];
    return results
        .map((json) => PokemonListEntry.fromJson(json))
        .where((entry) => entry.id < 10000)
        .toList();
  }

  Future<Map<String, dynamic>> getMoveDetails(String url, {String? versionGroup}) async {
    // Resolve local data
    Map<String, dynamic>? localData;
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      String idOrSlug =
          segments.last.isEmpty ? segments[segments.length - 2] : segments.last;

      if (int.tryParse(idOrSlug) != null) {
        final id = int.parse(idOrSlug);
        if (moveIdToSlug.containsKey(id)) {
          localData = moveDetailsData[moveIdToSlug[id]];
        }
      } else {
        if (moveDetailsData.containsKey(idOrSlug)) {
          localData = moveDetailsData[idOrSlug];
        }
      }
    } catch (_) {}

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String name = (data['names'] as List).firstWhere(
          (n) => n['language']['name'] == 'zh-Hans',
          orElse: () => {'name': data['name']},
        )['name'];

        String damageClass =
            data['damage_class']['name']; // physical, special, status
        String type = data['type']['name'];
        int? power = data['power'];
        int? accuracy = data['accuracy'];
        int? pp = data['pp'];

        String flavorText = '';
        final entries = (data['flavor_text_entries'] as List);
        if (entries.isNotEmpty) {
          final entry = entries.firstWhere(
            (e) => e['language']['name'] == 'zh-Hans',
            orElse: () => entries.firstWhere(
                (e) => e['language']['name'] == 'en',
                orElse: () => {'flavor_text': ''}),
          );
          flavorText = entry['flavor_text'].toString().replaceAll('\n', ' ');
        }

        String machineName = '';
        if (versionGroup != null) {
          final machines = data['machines'] as List;
          if (machines.isNotEmpty) {
            final machineEntry = machines.firstWhere(
              (m) => m['version_group']['name'] == versionGroup,
              orElse: () => null,
            );

            if (machineEntry != null) {
              try {
                final machineUrl = machineEntry['machine']['url'];
                final machineResponse = await http.get(Uri.parse(machineUrl));
                if (machineResponse.statusCode == 200) {
                  final machineData = json.decode(machineResponse.body);
                  machineName =
                      machineData['item']['name'].toString().toUpperCase();
                }
              } catch (e) {
                // Error fetching machine data, continue without it
              }
            }
          }
        }

        // Overwrite with local data if available
        if (localData != null) {
          name = localData['name'];
          damageClass = localData['damageClass'];
          type = localData['type'];
          power = localData['power'];
          accuracy = localData['accuracy'];
          pp = localData['pp'];
          flavorText = localData['description'];
        }

        return {
          'name': name,
          'damageClass': damageClass,
          'type': type,
          'power': power,
          'accuracy': accuracy,
          'pp': pp,
          'description': flavorText,
          'machineName': machineName,
        };
      }
    } catch (e) {
      // Error fetching move details, will use local data
    }

    // Fallback to local data if API fails
    if (localData != null) {
      return {
        'name': localData['name'],
        'damageClass': localData['damageClass'],
        'type': localData['type'],
        'power': localData['power'],
        'accuracy': localData['accuracy'],
        'pp': localData['pp'],
        'description': localData['description'],
        'machineName': '',
      };
    }

    return {
      'name': 'Unknown', 
      'damageClass': 'status', 
      'type': 'normal',
      'power': null,
      'accuracy': null,
      'pp': null,
      'description': '',
      'machineName': '',
    };
  }

  Future<List<dynamic>> getSmogonData(String pokemonName, String gen) async {
    // gen: sv, ss, sm, xy
    // alias: lowercase, remove special chars
    final alias = pokemonName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    
    try {
      final response = await http.post(
        Uri.parse('https://www.smogon.com/dex/_rpc/dump-pokemon'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'gen': gen,
          'alias': alias,
          'language': 'en',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['strategies'] ?? [];
      }
    } catch (e) {
      // Error fetching Smogon data
    }
    return [];
  }

  Future<String?> translateTerm(String term, String category) async {
    // category: move, ability, item, nature
    // term: English name (e.g. "Heavy-Duty Boots")
    
    // 1. Check cache
    final key = '$category:$term';
    if (_translationCache.containsKey(key)) return _translationCache[key];

    // 2. Format slug (lowercase, spaces to hyphens)
    // Remove special chars like ' in "King's Rock" -> "kings-rock"
    // But PokeAPI usually handles "king's rock" as "kings-rock"
    String slug = term.toLowerCase()
        .replaceAll(' ', '-')
        .replaceAll(RegExp(r"[^a-z0-9-]"), ''); // Remove non-alphanumeric except hyphen

    // Special case fixes for common mismatches if needed
    
    try {
      final response = await http.get(Uri.parse('$baseUrl/$category/$slug'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final names = data['names'] as List;
        final cnName = names.firstWhere(
          (n) => n['language']['name'] == 'zh-Hans',
          orElse: () => null,
        );
        
        if (cnName != null) {
          final translated = cnName['name'].toString();
          _translationCache[key] = translated;
          return translated;
        }
      }
    } catch (e) {
      // print('Translation failed for $term ($slug): $e');
    }
    
    return null; // Return null if not found
  }

  int _getIdFromUrl(String url) {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    return int.parse(segments[segments.length - 2]);
  }
}
