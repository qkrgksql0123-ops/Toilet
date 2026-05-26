import 'package:bol_il_bwa/domain/entities/toilet.dart';
import 'package:bol_il_bwa/domain/entities/review.dart';
import 'package:bol_il_bwa/domain/entities/password_share.dart';

class MockData {
  static final List<Toilet> toilets = [
    Toilet(
      id: '1',
      name: '서울역 공중화장실',
      latitude: 37.5547,
      longitude: 126.9706,
      address: '서울시 중구 한강로1가 1-4',
      avgRating: 4.5,
      isLocked: false,
    ),
    Toilet(
      id: '2',
      name: '명동 공중화장실',
      latitude: 37.5625,
      longitude: 126.9840,
      address: '서울시 중구 명동 50-1',
      avgRating: 3.8,
      isLocked: true,
    ),
    Toilet(
      id: '3',
      name: '강남역 공중화장실',
      latitude: 37.4979,
      longitude: 127.0276,
      address: '서울시 강남구 강남역 대로 465',
      avgRating: 4.2,
      isLocked: false,
    ),
    Toilet(
      id: '4',
      name: '혜화역 공중화장실',
      latitude: 37.5867,
      longitude: 127.0027,
      address: '서울시 종로구 명륜4가 34',
      avgRating: 3.5,
      isLocked: false,
    ),
    Toilet(
      id: '5',
      name: '홍대입구역 공중화장실',
      latitude: 37.5545,
      longitude: 126.9252,
      address: '서울시 마포구 홍대입구역 1번 출구',
      avgRating: 4.0,
      isLocked: true,
    ),
  ];

  static final List<Review> reviewsForToilet1 = [
    Review(
      id: 'r1',
      toiletId: '1',
      userId: '유저1',
      rating: 5,
      comment: '깨끗하고 청결합니다!',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Review(
      id: 'r2',
      toiletId: '1',
      userId: '유저2',
      rating: 4,
      comment: '대체로 깔끔합니다.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Review(
      id: 'r3',
      toiletId: '1',
      userId: '유저3',
      rating: 4,
      comment: '환기가 잘 되어 있어요.',
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
  ];

  static final List<Review> reviewsForToilet2 = [
    Review(
      id: 'r4',
      toiletId: '2',
      userId: '유저4',
      rating: 3,
      comment: '문이 잠겨있어서 불편합니다.',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Review(
      id: 'r5',
      toiletId: '2',
      userId: '유저5',
      rating: 4,
      comment: '비번을 알면 깨끗합니다.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  static final List<PasswordShare> passwordsForToilet2 = [
    PasswordShare(
      id: 'pw1',
      toiletId: '2',
      password: '1234',
      userId: '유저4',
      likes: 5,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    PasswordShare(
      id: 'pw2',
      toiletId: '2',
      password: '5678',
      userId: '유저6',
      likes: 2,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  static final List<PasswordShare> passwordsForToilet5 = [
    PasswordShare(
      id: 'pw3',
      toiletId: '5',
      password: '2024',
      userId: '유저7',
      likes: 8,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  static List<Review> getReviewsForToilet(String toiletId) {
    switch (toiletId) {
      case '1':
        return reviewsForToilet1;
      case '2':
        return reviewsForToilet2;
      default:
        return [];
    }
  }

  static List<PasswordShare> getPasswordsForToilet(String toiletId) {
    switch (toiletId) {
      case '2':
        return passwordsForToilet2;
      case '5':
        return passwordsForToilet5;
      default:
        return [];
    }
  }

  static Toilet? getToiletById(String toiletId) {
    try {
      return toilets.firstWhere((t) => t.id == toiletId);
    } catch (e) {
      return null;
    }
  }
}
