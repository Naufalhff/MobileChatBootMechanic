class AiModel {
  final String id;
  final String label;
  final String? ownedBy;
  final bool isCombo;
  final bool? supportsVision;

  const AiModel({
    required this.id,
    required this.label,
    this.ownedBy,
    this.isCombo = false,
    this.supportsVision,
  });

  factory AiModel.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? '').toString();
    return AiModel(
      id: id,
      label: (json['label'] as String?)?.trim().isNotEmpty == true
          ? json['label'] as String
          : id,
      ownedBy: json['owned_by'] as String?,
      isCombo: json['is_combo'] as bool? ?? false,
      supportsVision: json['supports_vision'] as bool?,
    );
  }
}

class AiModelCatalog {
  final String defaultModel;
  final List<AiModel> models;

  const AiModelCatalog({
    required this.defaultModel,
    required this.models,
  });

  factory AiModelCatalog.fromJson(Map<String, dynamic> json) {
    final rawModels = json['models'];
    final models = rawModels is List
        ? rawModels
            .whereType<Map>()
            .map((item) => AiModel.fromJson(Map<String, dynamic>.from(item)))
            .where((model) => model.id.isNotEmpty)
            .toList()
        : <AiModel>[];

    return AiModelCatalog(
      defaultModel: (json['default_model'] ?? '').toString(),
      models: models,
    );
  }
}
