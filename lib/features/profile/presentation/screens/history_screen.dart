import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_mobile/core/localization/str_enum.dart';
import 'package:ondas_mobile/core/localization/translations.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/core/theme/app_spacing.dart';
import 'package:ondas_mobile/core/widgets/reconnect_listener.dart';
import 'package:ondas_mobile/features/profile/presentation/bloc/history_bloc.dart';
import 'package:ondas_mobile/features/profile/presentation/bloc/history_event.dart';
import 'package:ondas_mobile/features/profile/presentation/bloc/history_state.dart';
import 'package:ondas_mobile/features/profile/presentation/widgets/history_item_widget.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<HistoryBloc>().add(const HistoryLoadRequested());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isNearBottom) {
      context.read<HistoryBloc>().add(const HistoryLoadMore());
    }
  }

  bool get _isNearBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= maxScroll - 200;
  }

  void _showClearConfirmation(BuildContext context) {
    final l = lang(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: Text(
          t(Str.historyClearTitle, l),
          style: const TextStyle(color: AppColors.white),
        ),
        content: Text(
          t(Str.historyClearConfirm, l),
          style: const TextStyle(color: AppColors.silver),
        ),
        actions: [
          TextButton(
            key: const Key('historyScreen_cancelClearButton'),
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              t(Str.cancel, l),
              style: const TextStyle(color: AppColors.silver),
            ),
          ),
          TextButton(
            key: const Key('historyScreen_confirmClearButton'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<HistoryBloc>().add(const HistoryClearRequested());
            },
            child: Text(
              t(Str.historyClearButton, l),
              style: const TextStyle(color: AppColors.negativeRed),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ReconnectListener(
      shouldReconnect: () =>
          context.read<HistoryBloc>().state is HistoryFailure,
      onReconnect: () =>
          context.read<HistoryBloc>().add(const HistoryLoadRequested()),
      child: Scaffold(
        backgroundColor: AppColors.nearBlack,
        appBar: AppBar(
          key: const Key('historyScreen_appBar'),
          title: Text(t(Str.historyTitle, lang(context))),
          backgroundColor: AppColors.nearBlack,
          actions: [
            BlocBuilder<HistoryBloc, HistoryState>(
              builder: (context, state) {
                final hasItems =
                    state is HistoryLoaded && state.items.isNotEmpty;
                if (!hasItems) return const SizedBox.shrink();
                return IconButton(
                  key: const Key('historyScreen_clearButton'),
                  icon: const Icon(Icons.delete_sweep_outlined),
                  tooltip: t(Str.historyClearAll, lang(context)),
                  onPressed: () => _showClearConfirmation(context),
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<HistoryBloc, HistoryState>(
          listener: (context, state) {
            if (state is HistoryFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.negativeRed,
                ),
              );
            } else if (state is HistoryClearSuccess) {
              context.read<HistoryBloc>().add(const HistoryLoadRequested());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(t(Str.historyCleared, lang(context)))),
              );
            }
          },
          builder: (context, state) => switch (state) {
            HistoryLoading() => const _LoadingView(),
            HistoryLoaded(:final items) when items.isEmpty =>
              const _EmptyView(),
            HistoryLoaded(:final items, :final hasMore) => _ListView(
                items: items,
                hasMore: hasMore,
                scrollController: _scrollController,
                isLoadingMore: false,
              ),
            HistoryLoadingMore(:final items) => _ListView(
                items: items,
                hasMore: true,
                scrollController: _scrollController,
                isLoadingMore: true,
              ),
            HistoryFailure(:final message) => _ErrorView(
                message: message,
                onRetry: () => context
                    .read<HistoryBloc>()
                    .add(const HistoryLoadRequested()),
              ),
            _ => const _LoadingView(),
          },
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.spotifyGreen),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.history,
            size: 64,
            color: AppColors.silver,
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            t(Str.historyEmpty, lang(context)),
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.silver),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.negativeRed),
            ),
            const SizedBox(height: AppSpacing.base),
            ElevatedButton(
              key: const Key('historyScreen_retryButton'),
              onPressed: onRetry,
              child: Text(t(Str.retry, lang(context))),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListView extends StatelessWidget {
  final List items;
  final bool hasMore;
  final ScrollController scrollController;
  final bool isLoadingMore;

  const _ListView({
    required this.items,
    required this.hasMore,
    required this.scrollController,
    required this.isLoadingMore,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: const Key('historyScreen_list'),
      controller: scrollController,
      itemCount: items.length + (isLoadingMore ? 1 : 0),
      separatorBuilder: (_, _) => const Divider(
        height: 1,
        color: AppColors.darkCard,
        indent: AppSpacing.base,
      ),
      itemBuilder: (context, index) {
        if (index == items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.base),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.spotifyGreen),
            ),
          );
        }
        final item = items[index];
        return HistoryItemWidget(
          item: item,
          onDelete: () => context
              .read<HistoryBloc>()
              .add(HistoryItemDeleteRequested(id: item.id)),
        );
      },
    );
  }
}
