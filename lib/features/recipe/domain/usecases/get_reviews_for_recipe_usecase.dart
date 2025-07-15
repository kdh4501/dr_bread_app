// lib/features/recipe/domain/usecases/get_reviews_for_recipe_usecase.dart
import '../entities/review.dart';
import '../repositories/review_repository.dart';

class GetReviewsForRecipeUseCase {
  final ReviewRepository repository;
  GetReviewsForRecipeUseCase(this.repository);

  Stream<List<ReviewEntity>> call(String recipeId) {
    return repository.getReviewsForRecipe(recipeId);
  }
}