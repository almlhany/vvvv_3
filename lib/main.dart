import 'package:flutter/material.dart';

void main() => runApp(const TikTokApp());

const kBg = Color(0xFF000000);
const kCard = Color(0xFF1a1a1a);
const kAccent = Color(0xFFFF0050);
const kGrey = Color(0xFF686868);

class Video {
  final String id;
  final String username;
  final String avatar;
  final String description;
  final String videoThumbnail;
  final int likes;
  final int comments;
  final int shares;
  int currentLikes;
  bool isLiked;
  bool isFollowed;

  Video({
    required this.id,
    required this.username,
    required this.avatar,
    required this.description,
    required this.videoThumbnail,
    required this.likes,
    required this.comments,
    required this.shares,
    this.isLiked = false,
    this.isFollowed = false,
  }) : currentLikes = likes;
}

class TikTokApp extends StatelessWidget {
  const TikTokApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TikTok',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: kBg,
        colorScheme: const ColorScheme.dark(primary: kAccent, secondary: kAccent),
      ),
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
      home: const MainApp(),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentTab,
        children: [
          const HomeScreen(),
          const ExploreScreen(),
          const CreateScreen(),
          const MessagesScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentTab,
        onTap: (index) {
          setState(() => currentTab = index);
        },
        backgroundColor: kCard,
        selectedItemColor: Colors.white,
        unselectedItemColor: kGrey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.mail_outline), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Video> videos = [
    Video(
      id: '1',
      username: 'أحمد محمد',
      avatar: 'https://i.pravatar.cc/150?img=1',
      description: 'اليوم تعلمت شيء جديد في البرمجة 🚀',
      videoThumbnail: 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=400&h=600&fit=crop',
      likes: 1200,
      comments: 150,
      shares: 89,
    ),
    Video(
      id: '2',
      username: 'فاطمة سارة',
      avatar: 'https://i.pravatar.cc/150?img=2',
      description: 'أجمل غروب شمس شفته في حياتي 🌅',
      videoThumbnail: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&h=600&fit=crop',
      likes: 5600,
      comments: 420,
      shares: 320,
    ),
    Video(
      id: '3',
      username: 'علي الدعيع',
      avatar: 'https://i.pravatar.cc/150?img=3',
      description: 'رقصة جديدة تحبونها؟ 💃',
      videoThumbnail: 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=400&h=600&fit=crop',
      likes: 8900,
      comments: 650,
      shares: 550,
    ),
    Video(
      id: '4',
      username: 'ليلى محمود',
      avatar: 'https://i.pravatar.cc/150?img=4',
      description: 'تحدي الطعام الحار 🌶️',
      videoThumbnail: 'https://images.unsplash.com/photo-1495521821757-a1efb6729352?w=400&h=600&fit=crop',
      likes: 3400,
      comments: 280,
      shares: 200,
    ),
    Video(
      id: '5',
      username: 'محمود أحمد',
      avatar: 'https://i.pravatar.cc/150?img=5',
      description: 'الحيوانات الأليفة أفضل من الناس 🐕',
      videoThumbnail: 'https://images.unsplash.com/photo-1552053831-71594a27c62d?w=400&h=600&fit=crop',
      likes: 12000,
      comments: 890,
      shares: 650,
    ),
  ];

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'للك',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: videos.length,
        itemBuilder: (context, index) {
          return VideoCard(
            video: videos[index],
            onLikeToggle: (liked) {
              setState(() {
                videos[index].isLiked = liked;
                if (liked) {
                  videos[index].currentLikes++;
                } else {
                  videos[index].currentLikes--;
                }
              });
            },
            onFollowToggle: (followed) {
              setState(() {
                videos[index].isFollowed = followed;
              });
            },
            onCommentTap: () => _showComments(context, videos[index]),
            onShareTap: () => _showShare(context),
          );
        },
      ),
    );
  }

  void _showComments(BuildContext context, Video video) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kCard,
      isScrollControlled: true,
      builder: (context) => CommentSheet(video: video),
    );
  }

  void _showShare(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kCard,
      builder: (context) => ShareSheet(),
    );
  }
}

class VideoCard extends StatefulWidget {
  final Video video;
  final Function(bool) onLikeToggle;
  final Function(bool) onFollowToggle;
  final VoidCallback onCommentTap;
  final VoidCallback onShareTap;

  const VideoCard({
    required this.video,
    required this.onLikeToggle,
    required this.onFollowToggle,
    required this.onCommentTap,
    required this.onShareTap,
  });

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> with SingleTickerProviderStateMixin {
  late AnimationController _likeController;

  @override
  void initState() {
    super.initState();
    _likeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _likeController.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      widget.video.isLiked = !widget.video.isLiked;
      widget.onLikeToggle(widget.video.isLiked);
    });
    _likeController.forward().then((_) => _likeController.reverse());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(widget.video.videoThumbnail),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [kBg.withOpacity(0.8), Colors.transparent],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(widget.video.avatar),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.video.username,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.video.description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        widget.onFollowToggle(!widget.video.isFollowed);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: widget.video.isFollowed ? Colors.transparent : kAccent,
                          border: widget.video.isFollowed
                              ? Border.all(color: Colors.white)
                              : null,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: Text(
                          widget.video.isFollowed ? 'متابع' : 'متابعة',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: widget.video.isFollowed ? Colors.white : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: 12,
          bottom: 100,
          child: Column(
            children: [
              ScaleTransition(
                scale: Tween<double>(begin: 1, end: 1.3).animate(
                  CurvedAnimation(parent: _likeController, curve: Curves.easeInOut),
                ),
                child: GestureDetector(
                  onTap: _toggleLike,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.3),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          widget.video.isLiked
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: widget.video.isLiked ? kAccent : Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatNumber(widget.video.currentLikes),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: widget.onCommentTap,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.3),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: const Icon(
                        Icons.message_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatNumber(widget.video.comments),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: widget.onShareTap,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.3),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: const Icon(
                        Icons.share_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatNumber(widget.video.shares),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.3),
                ),
                padding: const EdgeInsets.all(12),
                child: const Icon(
                  Icons.music_note,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

class CommentSheet extends StatefulWidget {
  final Video video;

  const CommentSheet({required this.video});

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final TextEditingController _commentController = TextEditingController();
  final List<Comment> comments = [
    Comment(
      username: 'محمود علي',
      avatar: 'https://i.pravatar.cc/150?img=10',
      text: 'فيديو جميل جداً 👏',
      likes: 234,
      timestamp: '2 دقيقة',
    ),
    Comment(
      username: 'سارة أحمد',
      avatar: 'https://i.pravatar.cc/150?img=11',
      text: 'معجبة كتير بمحتواك',
      likes: 156,
      timestamp: '1 ساعة',
    ),
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'التعليقات',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close),
              ),
            ],
          ),
        ),
        const Divider(color: Colors.white12),
        Expanded(
          child: ListView.builder(
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index];
              return Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(comment.avatar),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                comment.username,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                comment.timestamp,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white54,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            comment.text,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.favorite_border,
                                size: 14,
                                color: Colors.white54,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                comment.likes.toString(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white54,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Text(
                                'رد',
                                style: TextStyle(
                                  fontSize: 10,
  