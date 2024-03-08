
part of "bird_post_cubit.dart";

enum BirdPostsStatus { initial, error, loading, loaded, postAdded, postRemoved }

class BirdPostState extends Equatable {
  final List<BirdModel> birdPosts;
  final BirdPostsStatus status;

  const BirdPostState({required this.birdPosts, required this.status});

  @override
  List<Object?> get props => [birdPosts, status];

  BirdPostState copyWith({
    List<BirdModel>? birdPosts,
    BirdPostsStatus? status,
  }) {
    return BirdPostState(
        birdPosts: birdPosts ?? this.birdPosts,
        status: status ?? this.status,
    );
  }

}
