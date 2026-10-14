import 'package:flutter/material.dart';

void main() => runApp(const GalleryApp());

const kBg = Color(0xFF0F0F1E);
const kCard = Color(0xFF1A1A2E);
const kPurple = Color(0xFF9D4EDD);
const kPink = Color(0xFFFF006E);
const kCyan = Color(0xFF00D9FF);
const kGreen = Color(0xFF3A0CA3);

class Photo {
  final String id;
  final String title;
  final String imageUrl;
  final String category;
  bool isFavorite;

  Photo({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.category,
    this.isFavorite = false,
  });
}

class GalleryApp extends StatelessWidget {
  const GalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'معرض الصور',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: kBg,
        colorScheme: const ColorScheme.dark(primary: kPurple, secondary: kPink),
      ),
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Photo> allPhotos = [
    Photo(
      id: '1',
      title: 'منظر طبيعي',
      imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=400&fit=crop',
      category: 'طبيعة',
    ),
    Photo(
      id: '2',
      title: 'مدينة ليلاً',
      imageUrl: 'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=400&h=400&fit=crop',
      category: 'مدن',
    ),
    Photo(
      id: '3',
      title: 'الشاطئ الذهبي',
      imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&h=400&fit=crop',
      category: 'طبيعة',
    ),
    Photo(
      id: '4',
      title: 'غروب الشمس',
      imageUrl: 'https://images.unsplash.com/photo-1495567720989-cebdbdd97913?w=400&h=400&fit=crop',
      category: 'طبيعة',
    ),
    Photo(
      id: '5',
      title: 'فن عصري',
      imageUrl: 'https://images.unsplash.com/photo-1579783902614-e3fb5141b0cb?w=400&h=400&fit=crop',
      category: 'فن',
    ),
    Photo(
      id: '6',
      title: 'الجبال العالية',
      imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=400&fit=crop',
      category: 'طبيعة',
    ),
    Photo(
      id: '7',
      title: 'التصوير المعماري',
      imageUrl: 'https://images.unsplash.com/photo-1479839672679-a46482f0e7c8?w=400&h=400&fit=crop',
      category: 'معمار',
    ),
    Photo(
      id: '8',
      title: 'الزهور الملونة',
      imageUrl: 'https://images.unsplash.com/photo-1490727570938-ec5a6ff31d8e?w=400&h=400&fit=crop',
      category: 'طبيعة',
    ),
  ];

  List<Photo> filteredPhotos = [];
  String selectedCategory = 'الكل';
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredPhotos = allPhotos;
    searchController.addListener(_filterPhotos);
  }

  void _filterPhotos() {
    setState(() {
      searchQuery = searchController.text;
      _updateFiltered();
    });
  }

  void _updateFiltered() {
    filteredPhotos = allPhotos.where((photo) {
      final matchCategory = selectedCategory == 'الكل' || photo.category == selectedCategory;
      final matchSearch = photo.title.contains(searchQuery) ||
          photo.category.contains(searchQuery);
      return matchCategory && matchSearch;
    }).toList();
  }

  void _toggleFavorite(Photo photo) {
    setState(() {
      final index = allPhotos.indexOf(photo);
      allPhotos[index].isFavorite = !allPhotos[index].isFavorite;
    });
  }

  void _deletePhoto(Photo photo) {
    setState(() {
      allPhotos.removeWhere((p) => p.id == photo.id);
      _updateFiltered();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['الكل', 'طبيعة', 'مدن', 'فن', 'معمار'];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          '🖼️ معرض الصور',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // شريط البحث
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'ابحث عن الصور...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  filled: true,
                  fillColor: kCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),

              // التصنيفات
              const Text(
                'التصنيفات',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white54),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            selectedCategory = category;
                            _updateFiltered();
                          });
                        },
                        backgroundColor: Colors.transparent,
                        selectedColor: kPurple,
                        side: BorderSide(
                          color: isSelected ? Colors.transparent : Colors.white24,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // عداد الصور
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الصور (${filteredPhotos.length})',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white54,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: kPurple.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'المفضلة: ${allPhotos.where((p) => p.isFavorite).length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: kPink,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // شبكة الصور
              if (filteredPhotos.isEmpty)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Icon(Icons.image_not_supported_outlined,
                          size: 64, color: kPurple.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      const Text(
                        'لا توجد صور',
                        style: TextStyle(fontSize: 16, color: Colors.white54),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filteredPhotos.length,
                  itemBuilder: (context, index) {
                    final photo = filteredPhotos[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullScreenViewer(
                              photos: filteredPhotos,
                              initialIndex: index,
                              onFavoriteToggle: _toggleFavorite,
                              onDelete: _deletePhoto,
                            ),
                          ),
                        );
                      },
                      child: PhotoCard(
                        photo: photo,
                        onFavoriteToggle: () => _toggleFavorite(photo),
                        onDelete: () => _deletePhoto(photo),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class PhotoCard extends StatefulWidget {
  final Photo photo;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onDelete;

  const PhotoCard({
    required this.photo,
    required this.onFavoriteToggle,
    required this.onDelete,
  });

  @override
  State<PhotoCard> createState() => _PhotoCardState();
}

class _PhotoCardState extends State<PhotoCard> {
  bool _showMenu = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [kPurple.withOpacity(0.3), kPink.withOpacity(0.3)],
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Image.network(
                  widget.photo.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: kCard,
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 32),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, kBg.withOpacity(0.7)],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // العنوان والفئة
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.photo.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: kPurple.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.photo.category,
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
        // زر المفضلة
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: widget.onFavoriteToggle,
            child: Container(
              decoration: BoxDecoration(
                color: kBg.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(
                widget.photo.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: widget.photo.isFavorite ? kPink : Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
        // زر القائمة
        Positioned(
          top: 8,
          left: 8,
          child: GestureDetector(
            onTap: () => setState(() => _showMenu = !_showMenu),
            child: Container(
              decoration: BoxDecoration(
                color: kBg.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.more_vert, size: 20),
            ),
          ),
        ),
        // القائمة المنسدلة
        if (_showMenu)
          Positioned(
            top: 40,
            left: 8,
            child: Container(
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      widget.onDelete();
                      setState(() => _showMenu = false);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.delete, size: 16, color: kPink),
                          const SizedBox(width: 8),
                          const Text('حذف', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class FullScreenViewer extends StatefulWidget {
  final List<Photo> photos;
  final int initialIndex;
  final Function(Photo) onFavoriteToggle;
  final Function(Photo) onDelete;

  const FullScreenViewer({
    required this.photos,
    required this.initialIndex,
    required this.onFavoriteToggle,
    required this.onDelete,
  });

  @override
  State<FullScreenViewer> createState() => _FullScreenViewerState();
}

class _FullScreenViewerState extends State<FullScreenViewer> {
  late PageController _pageController;
  late int currentIndex;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPhoto = widget.photos[currentIndex];

    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => currentIndex = index);
            },
            itemCount: widget.photos.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onDoubleTap: () {
                  setState(() => _scale = _scale == 1.0 ? 2.0 : 1.0);
                },
                child: Transform.scale(
                  scale: _scale,
                  child: InteractiveViewer(
                    boundaryMargin: const EdgeInsets.all(20),
                    minScale: 1.0,
                    maxScale: 3.0,
                    child: Image.network(
                      widget.photos[index].imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Icon(Icons.error)),
                    ),
                  ),
                ),
              );
            },
          ),
          // الشريط العلوي
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [kBg.withOpacity(0.8), Colors.transparent],
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: kCard,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.arrow_back, size: 24),
                    ),
                  ),
                  Text(
                    '${currentIndex + 1}/${widget.photos.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      widget.onFavoriteToggle(currentPhoto);
                      setState(() {});
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: kCard,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        currentPhoto.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 24,
                        color: currentPhoto.isFavorite ? kPink : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // الشريط السفلي
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [kBg.withOpacity(0.8), Colors.transparent],
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentPhoto.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: kPurple.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      currentPhoto.category,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          widget.onDelete(currentPhoto);
                          if (currentIndex < widget.photos.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else if (currentIndex > 0) {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: kPink.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: kPink),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: const Text('حذف', style: TextStyle(color: kPink)),
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: currentIndex > 0
                                ? () => _pageController.previousPage(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    )
                                : null,
                            child: Container(
                              decoration: BoxDecoration(
                                color: kPurple.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.arrow_back_ios,
                                size: 20,
                                color: currentIndex > 0 ? kCyan : Colors.white30,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: currentIndex < widget.photos.length - 1
                                ? () => _pageController.nextPage(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    )
                                : null,
                            child: Container(
                              decoration: BoxDecoration(
                                color: kPurple.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                size: 20,
                                color: currentIndex < widget.photos.length - 1
                                    ? kCyan
                                    : Colors.white30,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}