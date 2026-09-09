import 'package:mind_whispers_app/features/reader/data/datasource/reader_remote_datasource.dart';
import 'package:mind_whispers_app/features/reader/data/models/author_ref_model.dart';
import 'package:mind_whispers_app/features/reader/data/models/category_model.dart';
import 'package:mind_whispers_app/features/reader/data/models/comment_model.dart';
import 'package:mind_whispers_app/features/reader/data/models/paginated_model.dart';
import 'package:mind_whispers_app/features/reader/data/models/post_model.dart';

const int _postsPerPage = 6;
const int _commentsPerPage = 10;

/// In-memory stand-in for the real `/categories`, `/posts`, and
/// `/posts/{id}/comments` endpoints (see API_CONTRACT.md) while the
/// backend for them doesn't exist yet — unlike auth, which has a live
/// spec (api-1.json). Seeded once per app run; mutations (add/delete
/// comment) only affect this process's memory.
///
/// Authorization for delete (owner/post-author/admin, per API_CONTRACT.md)
/// isn't enforced here — a fake datasource has no real request identity to
/// check it against. It's enforced at the UI layer instead (see
/// `PostDetailScreen`'s comment tile), the same way the UI would hide an
/// action a real 403 would also block server-side.
class ReaderFakeDataSource implements ReaderRemoteDataSource {
  late final List<CategoryModel> _categories;
  late final List<PostModel> _posts;
  late final List<CommentModel> _comments;
  int _nextCommentId = 1000;

  ReaderFakeDataSource() {
    _seed();
  }

  Future<void> _delay([int ms = 400]) =>
      Future.delayed(Duration(milliseconds: ms));

  @override
  Future<List<CategoryModel>> getCategories() async {
    await _delay(250);
    return List.unmodifiable(_categories);
  }

  @override
  Future<PaginatedModel<PostModel>> getPosts({
    int? categoryId,
    String? search,
    int page = 1,
  }) async {
    await _delay();

    final query = search?.trim().toLowerCase();
    final filtered = _posts.where((post) {
      if (post.status != 'published') return false;
      if (categoryId != null && post.category.id != categoryId) return false;
      if (query != null && query.isNotEmpty) {
        return post.title.toLowerCase().contains(query) ||
            post.excerpt.toLowerCase().contains(query);
      }
      return true;
    }).toList()..sort((a, b) => (b.publishedAt ?? b.createdAt).compareTo(a.publishedAt ?? a.createdAt));

    return _paginate(filtered, page, _postsPerPage);
  }

  @override
  Future<PostModel> getPost(int id) async {
    await _delay(250);
    return _posts.firstWhere(
      (post) => post.id == id,
      orElse: () => throw const ResourceNotFoundException('Post not found'),
    );
  }

  @override
  Future<PaginatedModel<CommentModel>> getComments(
    int postId, {
    int page = 1,
  }) async {
    await _delay(250);
    final filtered = _comments.where((c) => c.postId == postId).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return _paginate(filtered, page, _commentsPerPage);
  }

  @override
  Future<CommentModel> addComment({
    required int postId,
    required String body,
    required int authorId,
    required String authorName,
    String? authorAvatarUrl,
  }) async {
    await _delay(300);
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex == -1) {
      throw const ResourceNotFoundException('Post not found');
    }

    final comment = CommentModel(
      id: _nextCommentId++,
      body: body,
      author: AuthorRefModel(
        id: authorId,
        name: authorName,
        avatarUrl: authorAvatarUrl,
      ),
      postId: postId,
      createdAt: DateTime.now(),
    );
    _comments.add(comment);
    _posts[postIndex] = _bumpCommentCount(_posts[postIndex], 1);
    return comment;
  }

  @override
  Future<void> deleteComment(int id) async {
    await _delay(300);
    final comment = _comments.firstWhere(
      (c) => c.id == id,
      orElse: () => throw const ResourceNotFoundException('Comment not found'),
    );
    _comments.removeWhere((c) => c.id == id);
    final postIndex = _posts.indexWhere((post) => post.id == comment.postId);
    if (postIndex != -1) {
      _posts[postIndex] = _bumpCommentCount(_posts[postIndex], -1);
    }
  }

  PostModel _bumpCommentCount(PostModel post, int delta) {
    return PostModel(
      id: post.id,
      title: post.title,
      slug: post.slug,
      body: post.body,
      excerpt: post.excerpt,
      coverImageUrl: post.coverImageUrl,
      status: post.status,
      category: post.category,
      author: post.author,
      commentsCount: post.commentsCount + delta,
      createdAt: post.createdAt,
      publishedAt: post.publishedAt,
    );
  }

  PaginatedModel<T> _paginate<T>(List<T> all, int page, int perPage) {
    final total = all.length;
    final lastPage = total == 0 ? 1 : (total / perPage).ceil();
    final start = (page - 1) * perPage;
    final end = (start + perPage).clamp(0, total);
    final items = start >= total ? <T>[] : all.sublist(start, end);

    return PaginatedModel(
      items: items,
      currentPage: page,
      perPage: perPage,
      total: total,
      lastPage: lastPage,
    );
  }

  void _seed() {
    _categories = const [
      CategoryModel(id: 1, name: 'Fiction', slug: 'fiction'),
      CategoryModel(id: 2, name: 'Non-Fiction', slug: 'non-fiction'),
      CategoryModel(id: 3, name: 'Self-Dev', slug: 'self-dev'),
      CategoryModel(id: 4, name: 'Poetry', slug: 'poetry'),
    ];

    const maryam = AuthorRefModel(
      id: 1,
      name: 'Maryam Eid',
      avatarUrl: 'https://ui-avatars.com/api/?name=Maryam+Eid&background=2E6F5B&color=fff',
    );
    const omar = AuthorRefModel(
      id: 2,
      name: 'Omar Farouk',
      avatarUrl: 'https://ui-avatars.com/api/?name=Omar+Farouk&background=A78BFA&color=fff',
    );
    const layla = AuthorRefModel(
      id: 3,
      name: 'Layla Haddad',
      avatarUrl: 'https://ui-avatars.com/api/?name=Layla+Haddad&background=6B4FBB&color=fff',
    );
    const yusuf = AuthorRefModel(
      id: 4,
      name: 'Yusuf Kanaan',
      avatarUrl: 'https://ui-avatars.com/api/?name=Yusuf+Kanaan&background=B5793A&color=fff',
    );

    final fiction = _categories[0];
    final nonFiction = _categories[1];
    final selfDev = _categories[2];
    final poetry = _categories[3];

    DateTime daysAgo(int days) => DateTime.now().subtract(Duration(days: days));

    final postSeeds = <_PostSeed>[
      _PostSeed(
        title: 'On writing slowly',
        excerpt: 'Why the best sentences are the ones you were willing to throw away twice.',
        body:
            'There is a kind of writing that only shows up after the third draft has been '
            'deleted. It is tempting to publish the first clean paragraph that arrives, but '
            'the first clean paragraph is usually the one that sounds like everyone else.\n\n'
            'Slow writing is not about being precious. It is about noticing the sentence you '
            'wrote because it was easy, and asking whether it is also true. Most of the time '
            'it is not — it is just familiar.\n\n'
            'The paragraphs that survive a slow read are the ones that still feel necessary a '
            'week later, once the excitement of finishing has worn off.',
        category: nonFiction,
        author: maryam,
        daysAgo: 2,
      ),
      _PostSeed(
        title: 'The lighthouse keeper\'s daughter',
        excerpt: 'She counted the ships the way other children counted sheep.',
        body:
            'Every evening at six, Nadia climbed the hundred and forty stairs to sit beside '
            'her father while he lit the lamp. The sea below turned the color of a bruise, '
            'and somewhere past the reef, ships she would never board slid quietly toward '
            'harbors she had only heard named.\n\n'
            '"Which one is ours?" she asked, though she asked it every night and already knew '
            'the answer.\n\n'
            '"None of them," her father said, the same as always. "Ours is the one that '
            'doesn\'t need to be anywhere else."',
        category: fiction,
        author: layla,
        daysAgo: 5,
      ),
      _PostSeed(
        title: 'Five habits that quietly rebuilt my mornings',
        excerpt: 'None of them involve waking up at 5am, and that is the point.',
        body:
            'Most morning-routine advice assumes you have more willpower at 6am than you do '
            'at any other hour of the day, which has never once been true for me.\n\n'
            'What actually changed things was smaller: putting my shoes by the door the night '
            'before, writing tomorrow\'s first task before closing my laptop, and refusing to '
            'check my phone until I had looked out a window first.\n\n'
            'None of it is impressive. All of it stuck, which turned out to matter more.',
        category: selfDev,
        author: omar,
        daysAgo: 1,
      ),
      _PostSeed(
        title: 'What the archive would not tell us',
        excerpt: 'A year spent in a basement of city records, looking for one missing name.',
        body:
            'The clerk warned me the flood of 1962 had taken most of the ledgers from that '
            'decade, and she was right about the ledgers. She was wrong that nothing survived.\n\n'
            'Tucked inside a property deed, misfiled under a street that no longer exists, was '
            'a single receipt bearing my great-grandmother\'s signature — the only trace of her '
            'left in any public record.\n\n'
            'I keep a photograph of it now, not because it explains anything, but because it '
            'is proof she stood somewhere once and signed her name to it.',
        category: nonFiction,
        author: yusuf,
        daysAgo: 9,
      ),
      _PostSeed(
        title: 'Instructions for leaving a small town',
        excerpt: 'A poem about the roads that only make sense once you\'re already gone.',
        body:
            'Take the long way past the grain silo,\n'
            'not because it is faster —\n'
            'nothing here is faster —\n'
            'but because it is the only road\n'
            'that lets you watch the town\n'
            'get small in the mirror\n'
            'gently, like a held breath\n'
            'finally let go.\n\n'
            'Do not look for the moment it disappears.\n'
            'It will not announce itself.\n'
            'You will simply notice, later,\n'
            'that you have been driving\n'
            'through someone else\'s fields\n'
            'for miles.',
        category: poetry,
        author: layla,
        daysAgo: 3,
      ),
      _PostSeed(
        title: 'The productivity system that finally survived contact with a bad week',
        excerpt: 'Every system works when things are calm. Here is the one that held anyway.',
        body:
            'I have tried enough productivity systems to know the real test isn\'t a good '
            'Monday — it\'s the Thursday when three things go wrong before lunch.\n\n'
            'The version that survived was embarrassingly simple: one list, three items, '
            'written by hand. Not because handwriting is magic, but because the friction of '
            'rewriting the list every morning forced me to actually decide what mattered that '
            'day, instead of dragging forward everything I hadn\'t done the day before.\n\n'
            'It is not elegant. It has now survived four bad weeks in a row.',
        category: selfDev,
        author: omar,
        daysAgo: 6,
      ),
      _PostSeed(
        title: 'Letters we never sent',
        excerpt: 'A short story about the drawer where unfinished apologies go to wait.',
        body:
            'The drawer stuck a little, the way it always had, and Farid had to lift the '
            'handle before it would slide. Inside, seven envelopes, none of them sealed, all '
            'of them addressed to his brother.\n\n'
            'He had written the first one the week after the funeral neither of them attended, '
            'each side certain the other should apologize first. He had written one every year '
            'since, on the same date, and never once mailed it.\n\n'
            'This year he sealed it. He did not send it either. But sealing it felt, for the '
            'first time, like a decision rather than a habit.',
        category: fiction,
        author: maryam,
        daysAgo: 14,
      ),
      _PostSeed(
        title: 'Why I stopped reading books I wasn\'t enjoying',
        excerpt: 'Permission to quit at page forty, and what it did for my reading list.',
        body:
            'For years I finished every book I started, treating an unfinished novel as a '
            'small personal failure. This meant I read fewer books, not more — every '
            'disappointing one I forced through was a good one I didn\'t get to.\n\n'
            'The rule I use now is simple: forty pages, then an honest check-in. If nothing '
            'has made me want to know what happens next, I close it, no guilt attached.\n\n'
            'My reading list is shorter and better for it, which is the opposite of what I '
            'expected when I gave myself permission to quit.',
        category: selfDev,
        author: yusuf,
        daysAgo: 4,
      ),
      _PostSeed(
        title: 'The last translator in Qalaat Souq',
        excerpt: 'For forty years, one man decided which stories crossed the language line.',
        body:
            'Before the internet made every language searchable, a town like Qalaat Souq had '
            'exactly one person who could tell you what a French letter, a Turkish receipt, or '
            'an English telegram actually said. For forty years, that person was Abu Nabil.\n\n'
            'He kept no records of what he translated, on principle — "a translator who '
            'gossips is a spy," he told me once, only half joking. When he died, an entire '
            'category of the town\'s memory became permanently untranslatable.\n\n'
            'I spent a year trying to reconstruct even a fraction of what passed through his '
            'hands. I recovered almost none of it. That failure is its own kind of history.',
        category: nonFiction,
        author: yusuf,
        daysAgo: 11,
      ),
      _PostSeed(
        title: 'A short poem for the second cup of coffee',
        excerpt: 'The first cup is for waking up. The second cup is for deciding to stay awake.',
        body:
            'The first cup is a courtesy\n'
            'to whoever I was\n'
            'before the alarm.\n\n'
            'The second cup is a decision —\n'
            'to sit a while longer\n'
            'in the kind of morning\n'
            'that does not ask anything of me yet.',
        category: poetry,
        author: maryam,
        daysAgo: 0,
      ),
      _PostSeed(
        title: 'What twelve rejected drafts taught me about editors',
        excerpt: 'The best rejection letter I ever got didn\'t accept my story either.',
        body:
            'My twelfth rejection came with two paragraphs of notes I hadn\'t asked for, from '
            'an editor who clearly had no obligation to write them. The story still didn\'t '
            'sell. The notes changed how I wrote every story after it.\n\n'
            'What I learned, slowly and after too many drafts, is that a rejection with '
            'specifics is a gift disguised as a disappointment, and a form rejection is just '
            'information about fit, not verdict on the work.\n\n'
            'I still have all twelve letters. I only reread the one with notes.',
        category: nonFiction,
        author: omar,
        daysAgo: 20,
      ),
      _PostSeed(
        title: 'The house that kept getting smaller',
        excerpt: 'A story about the rooms we outgrow and the ones that outgrow us.',
        body:
            'When Hana was six, the kitchen table sat eight people comfortably. By the time '
            'she was sixteen, it sat four before elbows started colliding, though nobody had '
            'measured it twice.\n\n'
            'It wasn\'t the table. It was that six people had moved out one door at a time — a '
            'marriage, a job in another city, a falling-out nobody wanted to name at dinner — '
            'until the table\'s size stopped being the problem the room needed solving.\n\n'
            'Hana kept the table anyway, in an apartment where it barely fits two. She isn\'t '
            'sure yet what she\'s waiting to fill it again.',
        category: fiction,
        author: layla,
        daysAgo: 8,
      ),
      _PostSeed(
        title: 'The two-minute rule that actually changed my inbox',
        excerpt: 'A small habit that emptied a backlog I\'d been avoiding for a year.',
        body:
            'The rule is not new — if it takes less than two minutes, do it now instead of '
            'filing it for later. What surprised me was how much of my backlog was actually '
            'two-minute tasks I had been mentally filing as bigger than they were.\n\n'
            'Clearing them didn\'t just empty the inbox. It removed the background hum of a '
            'hundred small unfinished things, which turned out to be quieter than I expected '
            'and louder than I\'d noticed.',
        category: selfDev,
        author: maryam,
        daysAgo: 7,
      ),
      _PostSeed(
        title: 'Notes from a language I am forgetting on purpose',
        excerpt: 'What it costs to let a second language go, and why I chose to anyway.',
        body:
            'I spent four years becoming fluent in a language I no longer use, for a job I no '
            'longer have, in a city I no longer live in. Keeping it alive would take an hour a '
            'day I don\'t have to spare.\n\n'
            'So I am letting it go, deliberately, the way you might let a plant that needs '
            'more light than your apartment gets. Not every fluency has to become permanent to '
            'have been worth having.\n\n'
            'I still dream in it, occasionally. I have decided that is allowed to be enough.',
        category: nonFiction,
        author: layla,
        daysAgo: 16,
      ),
    ];

    var postId = 1;
    _posts = postSeeds.map((seed) {
      final publishedAt = daysAgo(seed.daysAgo);
      return PostModel(
        id: postId++,
        title: seed.title,
        slug: _slugify(seed.title),
        body: seed.body,
        excerpt: seed.excerpt,
        coverImageUrl: 'https://picsum.photos/seed/${_slugify(seed.title)}/800/450',
        status: 'published',
        category: seed.category,
        author: seed.author,
        commentsCount: 0,
        createdAt: publishedAt,
        publishedAt: publishedAt,
      );
    }).toList();

    final readers = <AuthorRefModel>[
      const AuthorRefModel(
        id: 100,
        name: 'Rana Saleh',
        avatarUrl: 'https://ui-avatars.com/api/?name=Rana+Saleh&background=6B4FBB&color=fff',
      ),
      const AuthorRefModel(
        id: 101,
        name: 'Karim Aziz',
        avatarUrl: 'https://ui-avatars.com/api/?name=Karim+Aziz&background=2E6F5B&color=fff',
      ),
      const AuthorRefModel(
        id: 102,
        name: 'Dina Fathi',
        avatarUrl: 'https://ui-avatars.com/api/?name=Dina+Fathi&background=A78BFA&color=fff',
      ),
    ];

    final commentBodies = [
      'This stayed with me longer than I expected it to.',
      'I read this twice in a row — the ending really lands.',
      'Not sure I agree with all of it, but beautifully put.',
      'Sending this to a friend who needs to read it today.',
      'The middle section is the part I keep thinking about.',
    ];

    _comments = [];
    var commentId = 1;
    for (var i = 0; i < _posts.length; i++) {
      final commentCount = i % 4; // 0-3 seeded comments per post
      for (var c = 0; c < commentCount; c++) {
        _comments.add(
          CommentModel(
            id: commentId++,
            body: commentBodies[(i + c) % commentBodies.length],
            author: readers[(i + c) % readers.length],
            postId: _posts[i].id,
            createdAt: _posts[i].publishedAt!.add(Duration(hours: c + 1)),
          ),
        );
      }
      _posts[i] = _bumpCommentCount(_posts[i], commentCount);
    }
    _nextCommentId = commentId + 999;
  }

  String _slugify(String title) {
    return title
        .toLowerCase()
        .replaceAll(RegExp(r"[^a-z0-9\s-]"), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '-');
  }
}

class _PostSeed {
  final String title;
  final String excerpt;
  final String body;
  final CategoryModel category;
  final AuthorRefModel author;
  final int daysAgo;

  const _PostSeed({
    required this.title,
    required this.excerpt,
    required this.body,
    required this.category,
    required this.author,
    required this.daysAgo,
  });
}
