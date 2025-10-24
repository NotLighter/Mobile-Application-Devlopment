// data_models.dart

class UserPost {
  final String username;
  final String description;
  int likes;
  final int comments;
  final bool isReel;
  bool isLiked;
  final bool isSponsored;

  // ✅ NEW: media links
  final String? imageUrl;   // For photo posts
  final String? videoUrl;   // For reel/video posts

  UserPost({
    required this.username,
    required this.description,
    required this.likes,
    required this.comments,
    required this.isReel,
    this.isLiked = false,
    this.isSponsored = false,
    this.imageUrl,
    this.videoUrl,
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
      description:
      "Just finished this custom wooden shelf! Used reclaimed wood and simple tools. #DIY #Woodworking",
      likes: 234,
      comments: 45,
      isReel: false,
      isSponsored: false,
      imageUrl: "https://www.allisajacobs.com/wp-content/uploads/2019/09/allisajacobsshelves-1-768x1024.jpg", // ✅ Example image link
    ),
    UserPost(
      username: "CraftQueen",
      description:
      "Easy macrame wall hanging tutorial coming soon! Perfect for beginners 🌿",
      likes: 189,
      comments: 32,
      isReel: false,
      isSponsored: false,
      imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQvxKTq5bNXFAD3NhbHLSJcRNHOS9qiot7NzA&s",
    ),
    UserPost(
      username: "ToolShopPro",
      description:
      "SPONSORED: New cordless drill on sale! Perfect for all your DIY projects. Link in bio.",
      likes: 567,
      comments: 89,
      isReel: false,
      isSponsored: true,
      imageUrl: "https://www.toolsmart.pk/cdn/shop/files/CDLI206021.jpg?v=1728039285&width=1000",
    ),
    UserPost(
      username: "HomeRenovator",
      description:
      "Bathroom makeover complete! Swipe to see before & after. Total cost: \$500",
      likes: 892,
      comments: 156,
      isReel: false,
      isSponsored: false,
      imageUrl: "https://plus.unsplash.com/premium_photo-1676320514136-5a15d9f97dfa?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NXx8YmF0aHJvb218ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&q=60&w=600",
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
