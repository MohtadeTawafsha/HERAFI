import 'package:dartz/dartz.dart';
import 'package:herafi/domain/entites/chat.dart';

import '../../../core/status/error/Failure.dart';
import '../../repositories/ChatRepository.dart';

class createChatUseCase{
  final ChatRepository repository;

  createChatUseCase(this.repository);

  Future<Either<Failure, chatEntity>> call({required chatEntity chat}) async {
    return await repository.createChat(chat);
  }
}