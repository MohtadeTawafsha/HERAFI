import 'package:herafi/data/models/chatModel.dart';
import 'package:herafi/domain/entites/user.dart';

import 'Message.dart';

class chatEntity{
  String documentId;
  final UserEntity user;
  final Message? lastMessage;
  final int missedMessagesCountByMe;
  final int missedMessagesCountByOther;

  chatEntity({
    required this.user,
    required this.lastMessage,
    required this.missedMessagesCountByMe,
    required this.missedMessagesCountByOther,
    required this.documentId
});
  chatModel toModel(){
    return chatModel(user: user, lastMessage: lastMessage, missedMessagesCountByMe: missedMessagesCountByMe, missedMessagesCountByOther: missedMessagesCountByOther, documentId: documentId);
  }
}