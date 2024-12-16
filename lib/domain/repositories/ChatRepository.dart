import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:herafi/domain/entites/chat.dart';

import '../../core/status/error/Failure.dart';
import '../entites/Message.dart';

abstract class ChatRepository {
  Future<Either<Failure, void>> sendMessage(Message message,String chatId);
  Future<Either<Failure, List<Message>>> getMessages(chatEntity chat);
  Future<Either<Failure, Stream<List<Message>>>> getStreamMessages(chatEntity chat);
  Future<Either<Failure,List<chatEntity>>> fetchChats(String userId);
  Future<Either<Failure,chatEntity>> createChat(chatEntity chat);
}