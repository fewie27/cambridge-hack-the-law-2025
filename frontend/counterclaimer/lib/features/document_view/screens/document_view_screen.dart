import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:counterclaimer/simple_api/simple_api.dart';
import 'package:counterclaimer/features/case_analysis/providers/case_providers.dart';

final documentHtmlProvider = FutureProvider.family<String, String>((ref, caseId) async {
  final response = await CambridgeApi.genDraft(GenDraftRequest(caseId));
  return response.text;
});

class DocumentViewScreen extends ConsumerWidget {
  const DocumentViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentCaseId = ref.watch(currentCaseIdProvider);
    
    if (currentCaseId == null) {
      return const Center(
        child: Text(
          'No case selected.\nPlease analyze a case first.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      );
    }
    
    return ref.watch(documentHtmlProvider(currentCaseId)).when(
      data: (htmlContent) {
        // Create a WebView controller
        final controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadHtmlString(htmlContent);

        return Scaffold(
          appBar: AppBar(
            title: Text('Document - Case $currentCaseId'),
            actions: [
              IconButton(
                icon: const Icon(Icons.print),
                onPressed: () {
                  // TODO: Implement print functionality
                },
              ),
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () {
                  // TODO: Implement download functionality
                },
              ),
            ],
          ),
          body: WebViewWidget(controller: controller),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text('Error loading document: $error'),
      ),
    );
  }
} 