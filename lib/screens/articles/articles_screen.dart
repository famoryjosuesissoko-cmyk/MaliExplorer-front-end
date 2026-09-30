import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/app_loader.dart';
import '../../core/widgets/app_error.dart';
import '../../models/article_model.dart';
import '../../services/article_service.dart';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  final ArticleService _service = ArticleService();
  late Future<List<ArticleModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getAllArticles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Articles Culturels')),
      body: FutureBuilder<List<ArticleModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoader(message: 'Chargement des articles...');
          }
          if (snapshot.hasError) {
            return AppError(
              message: snapshot.error.toString(),
              onRetry: () => setState(() => _future = _service.getAllArticles()),
            );
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('Aucun article trouvé'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppDimensions.md),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.sm),
            itemBuilder: (context, index) {
              final a = items[index];
              return ListTile(
                title: Text(a.titre, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(a.contenu ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push('/articles/${a.idArticle}'),
              );
            },
          );
        },
      ),
    );
  }
}
