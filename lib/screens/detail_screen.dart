import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/pokemon.dart';
import '../services/poke_service.dart';
import '../utils/translations.dart';
import '../utils/type_colors.dart';
import '../utils/smogon_translations.dart';

class DetailScreen extends StatefulWidget {
  final int pokemonId;

  const DetailScreen({super.key, required this.pokemonId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final PokeService _service = PokeService();
  
  PokemonDetail? _detail;
  PokemonSpecies? _species;
  PokemonVariety? _selectedVariety;
  bool _isLoading = true;
  String? _error;
  
  String? _selectedVersionGroup;
  List<String> _availableVersionGroups = [];
  
  final ScrollController _scrollController = ScrollController();
  bool _showTitle = false;

  static const Map<String, List<String>> versionGroupToVersions = {
    'red-blue': ['red', 'blue'],
    'yellow': ['yellow'],
    'gold-silver': ['gold', 'silver'],
    'crystal': ['crystal'],
    'ruby-sapphire': ['ruby', 'sapphire'],
    'emerald': ['emerald'],
    'firered-leafgreen': ['firered', 'leafgreen'],
    'diamond-pearl': ['diamond', 'pearl'],
    'platinum': ['platinum'],
    'heartgold-soulsilver': ['heartgold', 'soulsilver'],
    'black-white': ['black', 'white'],
    'black-2-white-2': ['black-2', 'white-2'],
    'x-y': ['x', 'y'],
    'omega-ruby-alpha-sapphire': ['omega-ruby', 'alpha-sapphire'],
    'sun-moon': ['sun', 'moon'],
    'ultra-sun-ultra-moon': ['ultra-sun', 'ultra-moon'],
    'lets-go-pikachu-lets-go-eevee': ['lets-go-pikachu', 'lets-go-eevee'],
    'sword-shield': ['sword', 'shield'],
    'brilliant-diamond-shining-pearl': ['brilliant-diamond', 'shining-pearl'],
    'legends-arceus': ['legends-arceus'],
    'scarlet-violet': ['scarlet', 'violet'],
  };

  static const Map<String, double> _typeSpriteOffsets = {
    'normal': 0,
    'fighting': 20,
    'flying': 40,
    'poison': 60,
    'ground': 80,
    'rock': 100,
    'bug': 120,
    'ghost': 140,
    'steel': 160,
    'fire': 180,
    'water': 200,
    'grass': 220,
    'electric': 240,
    'psychic': 260,
    'ice': 280,
    'dragon': 300,
    'dark': 320,
    'fairy': 340,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        bool show = _scrollController.offset > 140;
        if (show != _showTitle) {
          setState(() {
            _showTitle = show;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final detail = await _service.getPokemonDetail(widget.pokemonId);
      final species = await _service.getPokemonSpecies(widget.pokemonId);
      
      if (mounted) {
        _processData(detail, species);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _processData(PokemonDetail detail, PokemonSpecies species) {
    final groups = <String>{};
    for (var move in detail.moves) {
      for (var version in move.versionDetails) {
        groups.add(version.versionGroup);
      }
    }

    final orderedKeys = versionGroupTranslations.keys.toList();
    final availableGroups = groups.toList();
    availableGroups.sort((a, b) {
      final indexA = orderedKeys.indexOf(a);
      final indexB = orderedKeys.indexOf(b);
      if (indexA == -1) return 1;
      if (indexB == -1) return -1;
      return indexB.compareTo(indexA);
    });

    PokemonVariety? currentVariety;
    try {
      currentVariety = species.varieties.firstWhere((v) => v.id == detail.id);
    } catch (_) {
      if (species.varieties.isNotEmpty) {
        currentVariety = species.varieties.first;
      }
    }

    setState(() {
      _detail = detail;
      _species = species;
      _selectedVariety = currentVariety;
      _availableVersionGroups = availableGroups;
      if (_selectedVersionGroup == null ||
          !availableGroups.contains(_selectedVersionGroup)) {
        _selectedVersionGroup =
            availableGroups.isNotEmpty ? availableGroups.first : null;
      }
      _isLoading = false;
    });
  }

  Future<void> _onVarietyChanged(PokemonVariety? newVariety) async {
    if (newVariety == null || newVariety.id == _detail?.id) return;

    setState(() {
      _isLoading = true;
      _selectedVariety = newVariety;
    });

    try {
      final detail = await _service.getPokemonDetail(newVariety.id);
      if (mounted && _species != null) {
        _processData(detail, _species!);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getVarietyLabel(PokemonVariety variety) {
    if (variety.isDefault) return '一般样子';

    final name = variety.name;
    if (name.endsWith('-alola')) return '阿罗拉的样子';
    if (name.endsWith('-galar')) return '伽勒尔的样子';
    if (name.endsWith('-hisui')) return '洗翠的样子';
    if (name.endsWith('-paldea')) return '帕底亚的样子';
    if (name.endsWith('-mega')) return '超级进化';
    if (name.endsWith('-mega-x')) return '超级进化 X';
    if (name.endsWith('-mega-y')) return '超级进化 Y';
    if (name.endsWith('-gmax')) return '超极巨化';
    if (name.endsWith('-eternamax')) return '无极巨化';
    if (name.endsWith('-origin')) return '起源形态';
    if (name.endsWith('-therian')) return '灵兽形态';
    if (name.endsWith('-incarnate')) return '化身形态';
    if (name.endsWith('-black')) return '黑色';
    if (name.endsWith('-white')) return '白色';

    final parts = name.split('-');
    if (parts.length > 1) {
      return parts.sublist(1).join(' ').toUpperCase();
    }

    return name;
  }

  List<PokemonMove> _getMovesForSelectedVersion() {
    if (_detail == null || _selectedVersionGroup == null) return [];
    
    final filteredMoves = <PokemonMove>[];
    
    for (var move in _detail!.moves) {
      // Find details for the selected version
      // We might have multiple entries for the same version group (e.g. different methods)
      // But usually we want to show all of them? 
      // Or just the "best" one?
      // A move can be learned by level-up AND machine in the same version.
      // Let's find ALL entries for this version group.
      
      final versionEntries = move.versionDetails.where(
        (v) => v.versionGroup == _selectedVersionGroup
      ).toList();
      
      if (versionEntries.isEmpty) continue;

      // If there are multiple entries (e.g. level-up and machine), we should probably 
      // treat them as separate "moves" in the list or pick one.
      // For simplicity in the UI, let's prioritize level-up, then machine, then others.
      // OR, we can just add one entry per move, prioritizing level-up info if available.
      
      var bestEntry = versionEntries.first;
      final levelUpEntry = versionEntries.firstWhere(
        (v) => v.learnMethod == 'level-up',
        orElse: () => versionEntries.first, // Fallback to first
      );
      
      // If we have a level-up entry, use it. 
      // If not, use whatever we have (machine, tutor, etc.)
      if (versionEntries.any((v) => v.learnMethod == 'level-up')) {
        bestEntry = levelUpEntry;
      } else {
        // If no level up, maybe machine?
        final machineEntry = versionEntries.firstWhere(
          (v) => v.learnMethod == 'machine',
          orElse: () => versionEntries.first,
        );
        bestEntry = machineEntry;
      }

      filteredMoves.add(PokemonMove(
        name: move.name,
        url: move.url,
        levelLearnedAt: bestEntry.levelLearnedAt,
        learnMethod: bestEntry.learnMethod,
        versionGroup: bestEntry.versionGroup,
        versionDetails: move.versionDetails,
      ));
    }
    return filteredMoves;
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Error: $_error')),
      );
    }

    if (_detail == null || _species == null) return const SizedBox();

    Color bgColor;
    if (_detail!.types.length >= 2) {
      final c1 = typeColors[_detail!.types[0]] ?? Colors.grey;
      final c2 = typeColors[_detail!.types[1]] ?? Colors.grey;
      bgColor = Color.lerp(c1, c2, 0.5) ?? Colors.grey;
    } else {
      final primaryType = _detail!.types.isNotEmpty ? _detail!.types.first : 'normal';
      bgColor = typeColors[primaryType] ?? Colors.grey;
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: bgColor,
            elevation: 0,
            leading: Transform.translate(
              offset: const Offset(-8, 0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            title: _showTitle 
                ? Text(_species!.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                : null,
            centerTitle: false,
            titleSpacing: 0,
            actions: [
              if (_availableVersionGroups.isNotEmpty)
                Container(
                  height: 32,
                  margin: const EdgeInsets.only(right: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedVersionGroup,
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white, size: 18),
                      dropdownColor: bgColor,
                      isDense: true,
                      style: const TextStyle(
                        color: Colors.white, 
                        fontSize: 12, 
                        fontWeight: FontWeight.bold
                      ),
                      items: _availableVersionGroups.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(versionGroupTranslations[value] ?? value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedVersionGroup = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left: Name & Types
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '#${_detail!.id.toString().padLeft(3, '0')}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _species!.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_species!.varieties.length > 1)
                              Container(
                                height: 32,
                                margin: const EdgeInsets.only(top: 8),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.2)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<PokemonVariety>(
                                    value: _selectedVariety,
                                    isDense: true,
                                    dropdownColor: bgColor,
                                    icon: const Icon(Icons.arrow_drop_down,
                                        color: Colors.white),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    items: _species!.varieties.map((v) {
                                      return DropdownMenuItem<PokemonVariety>(
                                        value: v,
                                        child: Text(_getVarietyLabel(v)),
                                      );
                                    }).toList(),
                                    onChanged: _onVarietyChanged,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _detail!.types.map((type) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: typeColors[type] ?? Colors.grey,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (_typeSpriteOffsets.containsKey(type))
                                        Container(
                                          width: 20,
                                          height: 20,
                                          margin:
                                              const EdgeInsets.only(right: 4),
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image:
                                                  const CachedNetworkImageProvider(
                                                'https://media.52poke.com/wiki/8/87/MST_SV.webp',
                                              ),
                                              fit: BoxFit.none,
                                              alignment: Alignment(
                                                0.0,
                                                -1.0 +
                                                    (_typeSpriteOffsets[type]! /
                                                        200.0),
                                              ),
                                              scale: 2.5,
                                            ),
                                          ),
                                        ),
                                      Text(
                                        typeTranslations[type] ?? type,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      
                      // Right: Image
                      Hero(
                        tag: _detail!.id,
                        child: SizedBox(
                          width: 120,
                          height: 120,
                          child: CachedNetworkImage(
                            imageUrl: _detail!.spriteUrl,
                            fit: BoxFit.fitHeight,
                            placeholder: (context, url) => const SizedBox(),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  top: 40, 
                  left: 20, 
                  right: 20, 
                  bottom: 20 + MediaQuery.of(context).padding.bottom
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Flavor Text
                    Text(
                      _getFlavorTextForVersion(),
                      style: const TextStyle(fontSize: 16, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Basic Info
                    Text(
                      '基础信息',
                      style: TextStyle(
                        color: bgColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _buildInfoItem('身高', '${_detail!.height / 10} m'),
                              _buildInfoItem('体重', '${_detail!.weight / 10} kg'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildInfoItem('分类', _species!.genus.replaceAll('宝可梦', '')),
                              _buildInfoItem('捕获率', '${_species!.captureRate}'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildInfoItem('性别', _getGenderText(_species!.genderRate)),
                              _buildInfoItem('孵化周期', '${(_species!.hatchCounter + 1) * 255} 步'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildInfoItem('蛋组', _species!.eggGroups.map((e) => eggGroupTranslations[e] ?? e).join('/')),
                              _buildInfoItem('成长速度', growthRateTranslations[_species!.growthRate] ?? _species!.growthRate),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Base Stats
                    Text(
                      '种族值',
                      style: TextStyle(
                        color: bgColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._detail!.stats.map((stat) => _buildStatRow(stat, bgColor)),
                    
                    const SizedBox(height: 24),

                    // Abilities
                    Text(
                      '特性',
                      style: TextStyle(
                        color: bgColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._detail!.abilities.map((ability) => AbilityTile(ability: ability)),
                    
                    const SizedBox(height: 24),



                    // Level Up Moves
                    const Text(
                      '升级技能',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Builder(
                      builder: (context) {
                        final currentMoves = _getMovesForSelectedVersion();
                        final moves = currentMoves.where((m) => m.learnMethod == 'level-up').toList();
                        moves.sort((a, b) => a.levelLearnedAt.compareTo(b.levelLearnedAt));
                        
                        if (moves.isEmpty) {
                           return const Padding(
                             padding: EdgeInsets.symmetric(vertical: 8.0),
                             child: Text('该版本无升级技能数据', style: TextStyle(color: Colors.grey)),
                           );
                        }
                        return MoveTable(moves: moves, isLevelUp: true);
                      }
                    ),
                    
                    const SizedBox(height: 24),

                    // Machine Moves
                    const Text(
                      '招式机器',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Builder(
                      builder: (context) {
                        final currentMoves = _getMovesForSelectedVersion();
                        final moves = currentMoves.where((m) => m.learnMethod == 'machine').toList();
                        
                        if (moves.isEmpty) {
                           return const Padding(
                             padding: EdgeInsets.symmetric(vertical: 8.0),
                             child: Text('该版本无招式机器数据', style: TextStyle(color: Colors.grey)),
                           );
                        }
                        return MoveTable(moves: moves, isLevelUp: false);
                      }
                    ),

                    const SizedBox(height: 24),

                    // Competitive Movesets
                    CompetitiveSection(pokemonName: _detail!.name),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _getGenderText(int rate) {
    if (rate == -1) return '无性别';
    if (rate == 0) return '100% ♂';
    if (rate == 8) return '100% ♀';
    final femaleRate = (rate / 8.0) * 100;
    final maleRate = 100 - femaleRate;
    return '${maleRate.toStringAsFixed(0)}% ♂, ${femaleRate.toStringAsFixed(0)}% ♀';
  }

  Widget _buildStatRow(PokemonStat stat, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              statTranslations[stat.name] ?? stat.name,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '${stat.baseStat}',
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: stat.baseStat / 255,
                backgroundColor: Colors.grey[200],
                color: color,
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFlavorTextForVersion() {
    if (_species == null || _selectedVersionGroup == null) return _species?.flavorText ?? '';
    
    // Get versions included in this group
    final versions = versionGroupToVersions[_selectedVersionGroup] ?? [];
    if (versions.isEmpty) return _species!.flavorText;

    // Find entry matching language and one of the versions
    // Prefer zh-Hans
    var entry = _species!.flavorTextEntries.firstWhere(
      (e) => e.language == 'zh-Hans' && versions.contains(e.version),
      orElse: () => FlavorTextEntry(flavorText: '', language: '', version: ''),
    );

    if (entry.flavorText.isEmpty) {
      // Try English
      entry = _species!.flavorTextEntries.firstWhere(
        (e) => e.language == 'en' && versions.contains(e.version),
        orElse: () => FlavorTextEntry(flavorText: '', language: '', version: ''),
      );
    }

    if (entry.flavorText.isNotEmpty) {
      return entry.flavorText;
    }

    return _species!.flavorText; // Fallback to default
  }
}

class AbilityTile extends StatelessWidget {
  final PokemonAbility ability;
  final PokeService _service = PokeService();

  AbilityTile({super.key, required this.ability});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: _service.getAbilityInfo(ability.url),
      builder: (context, snapshot) {
        final name = snapshot.data?['name'] ?? ability.name;
        final desc = snapshot.data?['flavorText'] ?? 'Loading...';
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (ability.isHidden) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '隐藏',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ),
                  ],
                ],
              ),
              if (snapshot.hasData) ...[
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class MoveTable extends StatelessWidget {
  final List<PokemonMove> moves;
  final bool isLevelUp;

  const MoveTable({super.key, required this.moves, required this.isLevelUp});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 50,
                child: Text(
                  isLevelUp ? '等级' : '来源',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
              const Expanded(
                flex: 3,
                child: Text(
                  '招式',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
              const Expanded(
                flex: 2,
                child: Text(
                  '属性',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
              const Expanded(
                flex: 2,
                child: Text(
                  '分类',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
              const Expanded(
                flex: 2,
                child: Text(
                  '威力',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
              const Expanded(
                flex: 2,
                child: Text(
                  '命中',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Rows
        ...moves.map((move) => MoveTableRow(move: move, isLevelUp: isLevelUp)),
      ],
    );
  }
}

class MoveTableRow extends StatelessWidget {
  final PokemonMove move;
  final bool isLevelUp;
  final PokeService _service = PokeService();

  MoveTableRow({super.key, required this.move, required this.isLevelUp});

  @override
  Widget build(BuildContext context) {
    // Pre-calculate static translation
    String staticName = move.name;
    try {
      final normalizedSlug = move.name.replaceAll('-', ' ').toLowerCase();
      final key = moveTranslations.keys.firstWhere(
        (k) => k.toLowerCase() == normalizedSlug,
        orElse: () => '',
      );
      if (key.isNotEmpty) {
        staticName = moveTranslations[key]!;
      }
    } catch (_) {}

    return FutureBuilder<Map<String, dynamic>>(
      future: _service.getMoveDetails(move.url, versionGroup: move.versionGroup),
      builder: (context, snapshot) {
        String name = staticName;
        final apiName = snapshot.data?['name'];

        if (apiName != null && apiName != 'Unknown') {
          final isApiChinese = RegExp(r'[\u4e00-\u9fa5]').hasMatch(apiName);
          final isStaticChinese =
              RegExp(r'[\u4e00-\u9fa5]').hasMatch(staticName);

          if (isApiChinese) {
            name = apiName;
          } else if (isStaticChinese) {
            name = staticName;
          } else {
            name = apiName;
          }
        }

        final damageClass = snapshot.data?['damageClass'] ?? 'status';
        final type = snapshot.data?['type'] ?? 'normal';
        final power = snapshot.data?['power'];
        final accuracy = snapshot.data?['accuracy'];
        // final pp = snapshot.data?['pp'];
        // final description = snapshot.data?['description'] ?? '';
        final machineName = snapshot.data?['machineName'] as String?;
        
        String iconUrl;
        switch (damageClass) {
          case 'physical':
            iconUrl = 'https://img.pokemondb.net/images/icons/move-physical.png';
            break;
          case 'special':
            iconUrl = 'https://img.pokemondb.net/images/icons/move-special.png';
            break;
          case 'status':
          default:
            iconUrl = 'https://img.pokemondb.net/images/icons/move-status.png';
            break;
        }

        return InkWell(
          onTap: () {
            if (!snapshot.hasData) return;
            showMoveDetails(context, snapshot.data!);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                // Level / Source
                SizedBox(
                  width: 50,
                  child: Text(
                    isLevelUp 
                      ? '${move.levelLearnedAt}' 
                      : ((machineName != null && machineName.isNotEmpty) ? machineName : '机器'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Name
                Expanded(
                  flex: 3,
                  child: Text(
                    name,
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Type
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: typeColors[type] ?? Colors.grey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        typeTranslations[type] ?? type,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                // Class
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Tooltip(
                      message: damageClass,
                      child: CachedNetworkImage(
                        imageUrl: iconUrl,
                        width: 24,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => const SizedBox(width: 24, height: 16),
                        errorWidget: (context, url, error) => const Icon(Icons.help_outline, size: 16, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                // Power
                Expanded(
                  flex: 2,
                  child: Text(
                    damageClass == 'status' ? '-' : (power?.toString() ?? '-'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                // Accuracy
                Expanded(
                  flex: 2,
                  child: Text(
                    accuracy?.toString() ?? '-',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CompetitiveSection extends StatefulWidget {
  final String pokemonName;

  const CompetitiveSection({super.key, required this.pokemonName});

  @override
  State<CompetitiveSection> createState() => _CompetitiveSectionState();
}

class _CompetitiveSectionState extends State<CompetitiveSection> {
  final PokeService _service = PokeService();
  String _selectedGen = 'sv'; // Default Gen 9
  List<dynamic> _strategies = [];
  bool _isLoading = false;

  final Map<String, String> _genNames = {
    'sv': 'G9 朱/紫',
    'ss': 'G8 剑/盾',
    'sm': 'G7 日/月',
    'xy': 'G6 X/Y',
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await _service.getSmogonData(widget.pokemonName, _selectedGen);
    if (mounted) {
      setState(() {
        _strategies = data;
        _isLoading = false;
      });
    }
  }

  void _onMoveTap(String moveName) async {
    // 1. Slugify
    String slug = moveName.toLowerCase()
        .replaceAll(' ', '-')
        .replaceAll(RegExp(r"[^a-z0-9-]"), '');
    
    // 2. Fetch details
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final data = await _service.getMoveDetails('https://pokeapi.co/api/v2/move/$slug');
      if (mounted) {
        Navigator.pop(context); // Close loading
        showMoveDetails(context, data);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load move details: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with Dropdown
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '竞技对战',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            DropdownButton<String>(
              value: _selectedGen,
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
              style: const TextStyle(color: Colors.black, fontSize: 14),
              items: _genNames.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null && newValue != _selectedGen) {
                  setState(() => _selectedGen = newValue);
                  _loadData();
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (_isLoading)
          const Center(child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
          ))
        else if (_strategies.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            child: const Text('暂无该世代对战数据', style: TextStyle(color: Colors.grey)),
          )
        else
          ..._strategies.map((strategy) => _buildStrategyCard(strategy)),
      ],
    );
  }

  Widget _buildStrategyCard(dynamic strategy) {
    final format = strategy['format'];
    final movesets = strategy['movesets'] as List;
    if (movesets.isEmpty) return const SizedBox();
    
    // Usually take the first moveset as primary
    final moveset = movesets.first;
    
    // Helper to build list of translated terms
    Widget buildTermList(List<dynamic> items, String category, Map<String, String> manual, {Map<String, String>? modifiers}) {
      if (items.isEmpty) return const Text('-');
      return Wrap(
        spacing: 4,
        runSpacing: 4,
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          var item = entry.value.toString();

          // Handle case-insensitivity for types
          if (category == 'type' && !manual.containsKey(item)) {
            if (manual.containsKey(item.toLowerCase())) {
              item = item.toLowerCase();
            }
          }

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TranslatedTerm(
                term: item, 
                category: category, 
                manualTranslations: manual
              ),
              if (modifiers != null && modifiers.containsKey(item) && modifiers[item]!.isNotEmpty)
                 Text(' ${modifiers[item]}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              if (index < items.length - 1)
                const Text(' / '),
            ],
          );
        }).toList(),
      );
    }

    final itemsList = moveset['items'] as List;
    final abilitiesList = moveset['abilities'] as List;
    final naturesList = moveset['natures'] as List;
    final teraTypesList = (moveset['teratypes'] as List?) ?? [];
    
    // EVs
    final evConfigs = moveset['evconfigs'] as List;
    String evText = '';
    if (evConfigs.isNotEmpty) {
      final evs = evConfigs.first as Map<String, dynamic>;
      final List<String> evParts = [];
      evs.forEach((stat, value) {
        if (value > 0) {
          final statName = smogonStatTranslations[stat.toLowerCase()] ?? stat;
          evParts.add('$statName $value');
        }
      });
      evText = evParts.join(' / ');
    }

    // Moves
    final moveslots = moveset['moveslots'] as List; // List of Lists

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                format,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildRow('道具', buildTermList(itemsList, 'item', itemTranslations)),
          _buildRow('特性', buildTermList(abilitiesList, 'ability', abilityTranslations)),
          if (teraTypesList.isNotEmpty)
            _buildRow(
                '太晶', buildTermList(teraTypesList, 'type', typeTranslations)),
          _buildRow('性格', buildTermList(naturesList, 'nature', natureTranslations, modifiers: natureModifiers)),
          _buildRow('努力值', Text(evText)),
          const SizedBox(height: 12),
          const Text('配招:', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          ...moveslots.map((slot) {
            final moves = slot as List;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Icon(Icons.circle, size: 6, color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: moves.asMap().entries.map((entry) {
                        final index = entry.key;
                        final moveName = entry.value['move'].toString();
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () => _onMoveTap(moveName),
                              child: TranslatedTerm(
                                term: moveName, 
                                category: 'move', 
                                manualTranslations: moveTranslations
                              ),
                            ),
                            if (index < moves.length - 1)
                              const Text(' / '),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRow(String label, Widget content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
          Expanded(
            child: DefaultTextStyle(
              style: const TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 14,
                color: Colors.black87,
              ),
              child: content,
            ),
          ),
        ],
      ),
    );
  }
}

class TranslatedTerm extends StatelessWidget {
  final String term;
  final String category;
  final Map<String, String> manualTranslations;
  final PokeService _service = PokeService();

  TranslatedTerm({
    super.key, 
    required this.term, 
    required this.category,
    this.manualTranslations = const {},
  });

  @override
  Widget build(BuildContext context) {
    // 1. Check manual translation first (Exact match)
    if (manualTranslations.containsKey(term)) {
      return Text(manualTranslations[term]!);
    }

    // 1.5 Check case-insensitive match
    try {
      final key = manualTranslations.keys.firstWhere(
        (k) => k.toLowerCase() == term.toLowerCase(),
      );
      return Text(manualTranslations[key]!);
    } catch (_) {
      // Not found in manual map
    }

    // 2. Async fetch
    return FutureBuilder<String?>(
      future: _service.translateTerm(term, category),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Text(snapshot.data!);
        }
        // Show original term if loading or failed
        return Text(term);
      },
    );
  }
}

void showMoveDetails(BuildContext context, Map<String, dynamic> data) {
  final name = data['name'];
  final type = data['type'];
  final damageClass = data['damageClass'];
  final power = data['power'];
  final accuracy = data['accuracy'];
  final pp = data['pp'];
  final description = data['description'];
  
  String iconUrl;
  switch (damageClass) {
    case 'physical':
      iconUrl = 'https://img.pokemondb.net/images/icons/move-physical.png';
      break;
    case 'special':
      iconUrl = 'https://img.pokemondb.net/images/icons/move-special.png';
      break;
    case 'status':
    default:
      iconUrl = 'https://img.pokemondb.net/images/icons/move-status.png';
      break;
  }

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: typeColors[type] ?? Colors.grey,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  typeTranslations[type] ?? type,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              CachedNetworkImage(
                imageUrl: iconUrl,
                width: 40,
                fit: BoxFit.contain,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoColumn('威力', power?.toString() ?? '-'),
              _buildInfoColumn('命中', accuracy?.toString() ?? '-'),
              _buildInfoColumn('PP', pp?.toString() ?? '-'),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            '技能介绍',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description.isEmpty ? '暂无介绍' : description,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ],
      ),
    ),
  );
}

Widget _buildInfoColumn(String label, String value) {
  return Column(
    children: [
      Text(
        label,
        style: const TextStyle(color: Colors.grey, fontSize: 14),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}
