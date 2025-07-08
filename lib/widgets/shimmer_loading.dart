import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/colors/app_colors.dart';

class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.textLight.withOpacity(0.3),
      highlightColor: AppColors.white.withOpacity(0.8),
      child: Column(
        children: [
          // Balance cards shimmer
          Row(
            children: [
              Expanded(child: _buildCardShimmer()),
              const SizedBox(width: 12),
              Expanded(child: _buildCardShimmer()),
              const SizedBox(width: 12),
              Expanded(child: _buildCardShimmer()),
            ],
          ),
          const SizedBox(height: 20),

          // Chart shimmer
          _buildChartShimmer(),
          const SizedBox(height: 20),

          // Transaction list shimmer
          ...List.generate(
            5,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildTransactionShimmer(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardShimmer() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildChartShimmer() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildTransactionShimmer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16,
                  color: AppColors.white,
                ),
                const SizedBox(height: 4),
                Container(
                  width: 100,
                  height: 12,
                  color: AppColors.white,
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 16,
            color: AppColors.white,
          ),
        ],
      ),
    );
  }
}

class TransactionListShimmer extends StatelessWidget {
  const TransactionListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.textLight.withOpacity(0.3),
      highlightColor: AppColors.white.withOpacity(0.8),
      child: ListView.builder(
        itemCount: 8,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 16,
                        color: AppColors.white,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 100,
                        height: 12,
                        color: AppColors.white,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 60,
                  height: 16,
                  color: AppColors.white,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
