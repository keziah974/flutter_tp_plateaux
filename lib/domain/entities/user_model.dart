import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String pseudo;
  final String avatarEmoji;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.pseudo,
    required this.avatarEmoji,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      uid: doc.id,
      pseudo: data['pseudo'] as String,
      avatarEmoji: data['avatarEmoji'] as String? ?? '🎲',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pseudo': pseudo,
      'avatarEmoji': avatarEmoji,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({String? pseudo, String? avatarEmoji}) {
    return UserModel(
      uid: uid,
      pseudo: pseudo ?? this.pseudo,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [uid, pseudo, avatarEmoji, createdAt];
}
