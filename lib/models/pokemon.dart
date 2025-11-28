
class PokemonListEntry {
  final String name;
  final String url;

  PokemonListEntry({required this.name, required this.url});

  factory PokemonListEntry.fromJson(Map<String, dynamic> json) {
    return PokemonListEntry(
      name: json['name'],
      url: json['url'],
    );
  }

  int get id {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    // url format: https://pokeapi.co/api/v2/pokemon/1/
    // segments: ['api', 'v2', 'pokemon', '1', '']
    return int.parse(segments[segments.length - 2]);
  }
  
  String get imageUrl {
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
  }
}

class PokemonDetail {
  final int id;
  final String name;
  final int height;
  final int weight;
  final List<String> types;
  final List<PokemonStat> stats;
  final List<PokemonAbility> abilities;
  final List<PokemonMove> moves;
  final String spriteUrl;

  PokemonDetail({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.types,
    required this.stats,
    required this.abilities,
    required this.moves,
    required this.spriteUrl,
  });

  factory PokemonDetail.fromJson(Map<String, dynamic> json) {
    return PokemonDetail(
      id: json['id'],
      name: json['name'],
      height: json['height'],
      weight: json['weight'],
      types: (json['types'] as List)
          .map((t) => t['type']['name'] as String)
          .toList(),
      stats: (json['stats'] as List)
          .map((s) => PokemonStat.fromJson(s))
          .toList(),
      abilities: (json['abilities'] as List)
          .map((a) => PokemonAbility.fromJson(a))
          .toList(),
      moves: (json['moves'] as List)
          .map((m) => PokemonMove.fromJson(m))
          .toList(),
      spriteUrl: json['sprites']['other']['official-artwork']['front_default'] ?? 
                 json['sprites']['front_default'] ?? '',
    );
  }
}

class PokemonStat {
  final String name;
  final int baseStat;

  PokemonStat({required this.name, required this.baseStat});

  factory PokemonStat.fromJson(Map<String, dynamic> json) {
    return PokemonStat(
      name: json['stat']['name'],
      baseStat: json['base_stat'],
    );
  }
}

class PokemonAbility {
  final String name;
  final String url;
  final bool isHidden;

  PokemonAbility({required this.name, required this.url, required this.isHidden});

  factory PokemonAbility.fromJson(Map<String, dynamic> json) {
    return PokemonAbility(
      name: json['ability']['name'],
      url: json['ability']['url'],
      isHidden: json['is_hidden'],
    );
  }
}

class PokemonMoveVersion {
  final int levelLearnedAt;
  final String learnMethod;
  final String versionGroup;

  PokemonMoveVersion({
    required this.levelLearnedAt,
    required this.learnMethod,
    required this.versionGroup,
  });

  factory PokemonMoveVersion.fromJson(Map<String, dynamic> json) {
    return PokemonMoveVersion(
      levelLearnedAt: json['level_learned_at'],
      learnMethod: json['move_learn_method']['name'],
      versionGroup: json['version_group']['name'],
    );
  }
}

class PokemonMove {
  final String name;
  final String url;
  final int levelLearnedAt;
  final String learnMethod;
  final String versionGroup;
  final List<PokemonMoveVersion> versionDetails;

  PokemonMove({
    required this.name,
    required this.url,
    required this.levelLearnedAt,
    required this.learnMethod,
    required this.versionGroup,
    required this.versionDetails,
  });

  factory PokemonMove.fromJson(Map<String, dynamic> json) {
    var details = <PokemonMoveVersion>[];
    if (json['version_group_details'] != null) {
      details = (json['version_group_details'] as List)
          .map((d) => PokemonMoveVersion.fromJson(d))
          .toList();
    }

    // We need to find the version group details relevant to the current version context
    // For simplicity, we'll take the latest version group detail or the first one
    int level = 0;
    String method = 'unknown';
    String vGroup = '';
    
    if (json['version_group_details'] != null && (json['version_group_details'] as List).isNotEmpty) {
      // Prefer 'level-up' if available, otherwise take the last one (usually latest gen)
      var rawDetails = (json['version_group_details'] as List);
      
      // Sort details by version group if possible, but here we just try to find level-up first
      // or just take the last entry which is often the latest game
      var detail = rawDetails.last;
      
      // If there is a level-up entry, use that for level info
      var levelUpEntry = rawDetails.firstWhere(
        (d) => d['move_learn_method']['name'] == 'level-up',
        orElse: () => null,
      );

      if (levelUpEntry != null) {
        level = levelUpEntry['level_learned_at'];
        method = 'level-up';
        vGroup = levelUpEntry['version_group']['name'];
      } else {
        level = detail['level_learned_at'];
        method = detail['move_learn_method']['name'];
        vGroup = detail['version_group']['name'];
      }
    }

    return PokemonMove(
      name: json['move']['name'],
      url: json['move']['url'],
      levelLearnedAt: level,
      learnMethod: method,
      versionGroup: vGroup,
      versionDetails: details,
    );
  }
}

class PokemonSpecies {
  final String name;
  final String genus;
  final String flavorText;
  final List<FlavorTextEntry> flavorTextEntries;
  final List<String> eggGroups;
  final int captureRate;
  final int genderRate;
  final int baseHappiness;
  final String growthRate;
  final int hatchCounter;

  PokemonSpecies({
    required this.name,
    required this.genus,
    required this.flavorText,
    required this.flavorTextEntries,
    required this.eggGroups,
    required this.captureRate,
    required this.genderRate,
    required this.baseHappiness,
    required this.growthRate,
    required this.hatchCounter,
  });

  factory PokemonSpecies.fromJson(Map<String, dynamic> json) {
    String findName(List<dynamic> names, String lang) {
      final entry = names.firstWhere(
        (n) => n['language']['name'] == lang,
        orElse: () => names.firstWhere((n) => n['language']['name'] == 'en', orElse: () => {'name': 'Unknown'}),
      );
      return entry['name'];
    }

    String findGenus(List<dynamic> genera, String lang) {
      if (genera.isEmpty) return '';
      final entry = genera.firstWhere(
        (g) => g['language']['name'] == lang,
        orElse: () => genera.firstWhere((g) => g['language']['name'] == 'en', orElse: () => {'genus': ''}),
      );
      return entry['genus'];
    }

    String findFlavorText(List<dynamic> entries, String lang) {
      if (entries.isEmpty) return '';
      // Filter for current version if possible, but here we just take the first matching language
      final entry = entries.firstWhere(
        (e) => e['language']['name'] == lang,
        orElse: () => entries.firstWhere((e) => e['language']['name'] == 'en', orElse: () => {'flavor_text': ''}),
      );
      return entry['flavor_text'].toString().replaceAll('\n', ' ');
    }

    return PokemonSpecies(
      name: findName(json['names'] ?? [], 'zh-Hans'),
      genus: findGenus(json['genera'] ?? [], 'zh-Hans'),
      flavorText: findFlavorText(json['flavor_text_entries'] ?? [], 'zh-Hans'),
      flavorTextEntries: (json['flavor_text_entries'] as List?)
          ?.map((e) => FlavorTextEntry.fromJson(e))
          .toList() ?? [],
      eggGroups: (json['egg_groups'] as List?)?.map((e) => e['name'] as String).toList() ?? [],
      captureRate: json['capture_rate'] ?? 0,
      genderRate: json['gender_rate'] ?? -1,
      baseHappiness: json['base_happiness'] ?? 0,
      growthRate: json['growth_rate'] != null ? json['growth_rate']['name'] : 'unknown',
      hatchCounter: json['hatch_counter'] ?? 0,
    );
  }
}

class FlavorTextEntry {
  final String flavorText;
  final String language;
  final String version;

  FlavorTextEntry({
    required this.flavorText,
    required this.language,
    required this.version,
  });

  factory FlavorTextEntry.fromJson(Map<String, dynamic> json) {
    return FlavorTextEntry(
      flavorText: json['flavor_text'].toString().replaceAll('\n', ' '),
      language: json['language']['name'],
      version: json['version']['name'],
    );
  }
}
