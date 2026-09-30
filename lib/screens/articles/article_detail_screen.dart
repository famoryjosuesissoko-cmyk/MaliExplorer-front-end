import 'package:flutter/material.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/app_loader.dart';
import '../../core/widgets/app_error.dart';
import '../../models/article_model.dart';
import '../../services/article_service.dart';

class ArticleDetailScreen extends StatefulWidget {
  final int articleId;
  const ArticleDetailScreen({super.key, required this.articleId});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  final ArticleService _service = ArticleService();
  late Future<ArticleModel> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getArticleById(widget.articleId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détail Article')),
      body: FutureBuilder<ArticleModel>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoader();
          }
          if (snapshot.hasError) {
            return AppError(
              message: snapshot.error.toString(),
              onRetry: () => setState(() => _future = _service.getArticleById(widget.articleId)),
            );
          }
          final a = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.titre, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: AppDimensions.md),
                Text(a.contenu ?? '', style: const TextStyle(fontSize: 16, height: 1.5)),
              ],
            ),
          );
        },
      ),
    );
  }
}
