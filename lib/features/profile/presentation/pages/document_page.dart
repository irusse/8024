import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:neighbours/core/components/default_app_bar.dart';
import 'package:neighbours/core/components/default_loading_overlay.dart';
import 'package:neighbours/core/constants/ui_constants.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/features/community/presentation/widgets/error_with_try_btn.dart';
import '../cubits/document/document_cubit.dart';

class DocumentPage extends StatefulWidget {
  final String documentKey;

  const DocumentPage({super.key, required this.documentKey});

  @override
  State<DocumentPage> createState() => _DocumentPageState();
}

class _DocumentPageState extends State<DocumentPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DocumentCubit>().getDocumentByType(widget.documentKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DocumentCubit, DocumentState>(
      builder: (context, state) {
        if (state.fetchState.isFailure) {
          return Scaffold(
            body: ErrorWithTryBtn(
                error: state.fetchState.error!,
                onErrorClick: () => context
                    .read<DocumentCubit>()
                    .getDocumentByType(widget.documentKey)),
          );
        }
        if (state.fetchState.isLoading) {
          return const Scaffold(
            body: DefaultLoadingOverlay(),
          );
        }

        final document = state.document;
        if (document == null) {
          return Scaffold(
            appBar: const DefaultAppBar(
              showBackButton: true,
              title: 'Документ',
            ),
            body: Center(
              child: Text(
                'Документ не найден',
                style: context.text.bodyLarge,
              ),
            ),
          );
        }

        return Scaffold(
          appBar: DefaultAppBar(
            showBackButton: true,
            title: document.title,
          ),
          body: Markdown(
            data: document.content,
            styleSheet: _markdownStyle(context),
            padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.defaultHorizontalPadding, vertical: 8),
          ),
        );
      },
    );
  }
}

MarkdownStyleSheet _markdownStyle(BuildContext context) {
  final base = MarkdownStyleSheet.fromTheme(Theme.of(context));
  final color = context.color.primaryText;

  TextStyle applyColor(TextStyle? style) =>
      (style ?? const TextStyle()).copyWith(color: color);

  return base.copyWith(
    p: applyColor(base.p),
    h1: applyColor(base.h1),
    h2: applyColor(base.h2),
    h3: applyColor(base.h3),
    h4: applyColor(base.h4),
    h5: applyColor(base.h5),
    h6: applyColor(base.h6),
    em: applyColor(base.em),
    strong: applyColor(base.strong),
    blockquote: applyColor(base.blockquote),
    code: applyColor(base.code),
    listBullet: applyColor(base.listBullet),
    tableBody: applyColor(base.tableBody),
    tableHead: applyColor(base.tableHead),
  );
}
