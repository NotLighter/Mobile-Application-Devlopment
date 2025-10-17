// data_models.dart

class UserPost {
  final String username;
  final String description;
  int likes;
  final int comments;
  final bool isReel;
  bool isLiked;
  final bool isSponsored;

  UserPost({
    required this.username,
    required this.description,
    required this.likes,
    required this.comments,
    required this.isReel,
    this.isLiked = false,
    this.isSponsored = false,
  });

  void incrementLikes() {
    if (!isLiked) {
      likes++;
      isLiked = true;
    } else {
      likes--;
      isLiked = false;
    }
  }

  void toggleLikeStatus() {
    if (isLiked) {
      isLiked = false;
      likes = likes > 0 ? likes - 1 : 0;
    } else {
      isLiked = true;
      likes++;
    }
  }
}

class TutorialRecipe {
  final String title;
  final List<String> steps;
  final String videoLink;
  final bool isTextOnly;

  TutorialRecipe({
    required this.title,
    required this.steps,
    required this.videoLink,
    this.isTextOnly = false,
  });
}

class AppState {
  static List<UserPost> posts = [
    UserPost(
      username: "DIY_Master",
      description: "Just finished this custom wooden shelf! Used reclaimed wood and simple tools. #DIY #Woodworking",
      likes: 234,
      comments: 45,
      isReel: false,
      isSponsored: false,
    ),
    UserPost(
      username: "CraftQueen",
      description: "Easy macrame wall hanging tutorial coming soon! Perfect for beginners 🌿",
      likes: 189,
      comments: 32,
      isReel: false,
      isSponsored: false,
    ),
    UserPost(
      username: "ToolShopPro",
      description: "SPONSORED: New cordless drill on sale! Perfect for all your DIY projects. Link in bio.",
      likes: 567,
      comments: 89,
      isReel: false,
      isSponsored: true,
    ),
    UserPost(
      username: "HomeRenovator",
      description: "Bathroom makeover complete! Swipe to see before & after. Total cost: \$500",
      likes: 892,
      comments: 156,
      isReel: false,
      isSponsored: false,
    ),
    UserPost(
      username: "QuickFix_Guru",
      description: "60-second reel: How to fix a leaky faucet! Save this for later 💧",
      likes: 1240,
      comments: 203,
      isReel: true,
      isSponsored: false,
    ),
  ];

  static List<TutorialRecipe> tutorials = [
    TutorialRecipe(
      title: "Build a Simple Bookshelf",
      steps: [
        "Measure and cut 4 wooden planks to 36 inches",
        "Sand all edges smooth",
        "Attach side supports with wood screws",
        "Mount shelf brackets",
        "Apply wood stain and seal"
      ],
      videoLink: "https://example.com/bookshelf-tutorial",
      isTextOnly: false,
    ),
    TutorialRecipe(
      title: "Create a Mason Jar Lamp",
      steps: [
        "Drill hole in mason jar lid",
        "Thread lamp cord through lid",
        "Attach light socket",
        "Add vintage Edison bulb",
        "Decorate jar as desired"
      ],
      videoLink: "https://example.com/lamp-tutorial",
      isTextOnly: false,
    ),
    TutorialRecipe(
      title: "Paint a Room Like a Pro",
      steps: [
        "Remove furniture and cover floors",
        "Clean walls and fill holes",
        "Apply painter's tape to edges",
        "Prime walls if needed",
        "Apply two coats of paint",
        "Remove tape while paint is slightly wet"
      ],
      videoLink: "https://example.com/painting-tutorial",
      isTextOnly: true,
    ),
    TutorialRecipe(
      title: "Install Floating Shelves",
      steps: [
        "Mark shelf position with level",
        "Locate wall studs",
        "Drill pilot holes",
        "Install mounting brackets",
        "Slide shelf onto brackets",
        "Secure with screws"
      ],
      videoLink: "https://example.com/shelves-tutorial",
      isTextOnly: false,
    ),
  ];
}